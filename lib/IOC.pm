
package IOC;

use strict;
use warnings;

our $VERSION = '0.06';

use IOC::Exceptions;

use IOC::Container;
use IOC::Service;
use IOC::Registry;

1;

__END__

=head1 NAME

IOC - A lightweight IOC (Inversion of Control) framework

=head1 SYNOPSIS

  use IOC;
  
  my $container = IOC::Container->new();
  $container->register(IOC::Service->new('log_file' => sub { "logfile.log" }));
  $container->register(IOC::Service->new('logger' => sub { 
      my $c = shift; 
      return FileLogger->new($c->get('log_file'));
  }));
  $container->register(IOC::Service->new('application' => sub {
      my $c = shift; 
      my $app = Application->new();
      $app->logger($c->get('logger'));
      return $app;
  }));

  $container->get('application')->run();   

=head1 DESCRIPTION

This module provide a lightweight IOC or Inversion of Control framework. Inversion of Control, sometimes called Dependency Injection, is a component management style which aims to clean up component configuration and provide a cleaner, more flexible means of configuring a large application.

=head2 What is Inversion of Control

My favorite 10 second description of Inversion of Control is, "Inversion of Control is the inverse of Garbage Collection". This comes from Howard Lewis Ship, the creator of the HiveMind IoC Java framework. His point is that the way garbage collection takes care of the destruction of your objects, Inversion of Control takes care of the creation of your objects. However, this does not really explain why IoC is useful, for that you will have to read on.

You may be familiar with a similar style of component management called a Service Locator, in which a global Service Locator object holds instances of components which can be retrieved by key. The common style is to create and configure each component instance and add it into the Service Locator. The main drawback to this approach is the aligning of the dependencies of each component prior to inserting the component into the Service Locator. If your dependency requirements change, then your initialization code must change to accomidate. This can get quite complex when you need to re-arrange initialization ordering and such. The Inversion of Control style alleviates this problem by taking a different approach.

With Inversion of Control, you configure a set of individual Service objects, which know how to initialize their particular components. If these components have dependencies, the will resolve them through the IOC framework itself. This results in a loosly coupled configuration which places no expectation upon initialization order. If your dependency requirements change, you need only adjust your Service's initialization routine, the ordering will adapt on it's own.

For links to how other people have explained Inversion of Control, see the L<SEE ALSO> section.

=head2 Why Do I Need This?

Inversion of Control is not for everyone and really is most useful in larger applications. But if you are still wondering if this is for you, then here are a few questions you can ask yourself.

=over 4

=item Do you have more than a few Singletons in your code? 

If so, you are a likely canidate for IOC. Singletons can be very useful tools, but when they are overused, they quickly start to take on all the same problems of global variables that they were meant to solve. With the IOC framework, you can reduce several singletons down to one, the IOC::Registry singleton, and allow for more fine grained control over their lifecycles.

=item Is your initialization code overly complex?

One of the great parts about IOC is that all initialzation of dependencies will get resolved through the IOC framework itself. This allows your application to dynamically reconfigure it load order without you having to recode anything but the actual dependency change. 

=item Are you using some kind of Service Locator?

My whole reasoning for creating this module was that I was using a Service Locator object from which I dispensed all my components. This created a lot of delicate initialization code which would frequently be caused issues, and since the Service Locator was initialized I<after> all the services were, it was nessecary to resolve dependencies between components manually. 

=back

=head2 Diagrams

Here is a quick class relationship diagram, to help illustrate how the peices of this system fit together.

 +------------------+                  +--------------+                 +-------------------------+
 |  IOC::Container  |---(*services)--->| IOC::Service |---(instance)--->| <Your Component/Object> |
 +------------------+                  +--------------+                 +-------------------------+
           |
   (*sub-containers)
           | 
           V    
 +------------------+
 |  IOC::Container  |
 +------------------+   
 
I am not very good at UML Sequence diagrams, but here are a few examples of ones I have made.  
 
Calling C<get> on an instance of IOC::Container.
 
   MyObject         IOC::Container                IOC::Service
      |                   |                             |
     +-+                  |                             |
     | | get($name)      +-+                            |
     | |---------------->| |                            |
     | |                 | | instance()                +-+               
     | |                 | |-------------------------->| |
     | |                 | |                           | |
     | |                 | |        <service instance> | |        
     | |<----------------| |<--------------------------| | 
     +-+                 +-+                           +-+
      |                   |                             |    
      |                   |                             |

Calling C<find> on an instance of IOC::Container.

   MyObject         IOC::Container          IOC::Visitor::ServiceLocator
      |                   |                             |
     +-+                  |                             |
     | | find($path)     +-+                            |
     | |---------------->| |                            |
     | |                 | | new($path)                +-+               
     | |                 | |-------------------------->| |
     | |                 | |                           | |
     | |                 | |                <$visitor> | |        
     | |                 | |<--------------------------| |
     | |                 | |                           | |
     | |                 | | accept($visitor)          | |
     | |                 | |------------------+        | |
     | |                 | |                  |        | |      
     | |                 |+-+<----------------+        | |
     | |                 || |                          | |
     | |                 || | visit ($self)            | |      
     | |                 || |------------------------->| |
     | |                 || |                          | |
     | |                 || |       <service instance> | | 
     | |<----------------|| |<-------------------------| |   
     | |                 |+-+                          | |
     +-+                 +-+                           +-+
      |                   |                             |    
      |                   |                             |
          
=head1 TO DO   

=over 4

=item Work on the documentation

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, below is the B<Devel::Cover> report on this module test suite.

 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 File                                  stmt branch   cond    sub    pod   time  total
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 IOC.pm                               100.0    n/a    n/a  100.0    n/a    4.9  100.0
 IOC/Exceptions.pm                    100.0    n/a    n/a  100.0    n/a    5.5  100.0
 IOC/Interfaces.pm                    100.0    n/a    n/a  100.0    n/a    6.0  100.0
 IOC/Registry.pm                      100.0   97.4   77.8  100.0  100.0   12.5   98.3
 IOC/Container.pm                     100.0   97.4   93.1  100.0  100.0   34.8   98.6
 IOC/Container/MethodResolution.pm    100.0  100.0    n/a  100.0    n/a    1.4  100.0
 IOC/Service.pm                       100.0  100.0   83.3  100.0  100.0   14.0   97.4
 IOC/Service/ConstructorInjection.pm  100.0  100.0   77.8  100.0  100.0    3.9   97.3
 IOC/Service/SetterInjection.pm       100.0  100.0   77.8  100.0  100.0    4.1   97.2
 IOC/Visitor/SearchForContainer.pm    100.0   90.0   77.8  100.0  100.0    2.5   95.1
 IOC/Visitor/SearchForService.pm      100.0  100.0   77.8  100.0  100.0    4.0   96.7
 IOC/Visitor/ServiceLocator.pm        100.0  100.0   77.8  100.0  100.0    6.4   97.0
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 Total                                100.0   97.9   83.2  100.0  100.0  100.0   97.8
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

Some IoC Article links

=over 4

=item The code here was originally inspired by the code found in this article.

L<http://onestepback.org/index.cgi/Tech/Ruby/DependencyInjectionInRuby.rdoc>

=item Dependency Injection is the Inverse of Garbage Collection

L<http://howardlewisship.com/blog/2004/08/dependency-injection-mirror-of-garbage.html>

=item This is a decent article on IoC with Java.

L<http://today.java.net/pub/a//today/2004/02/10/ioc.html>

=item An article by Martin Fowler about IoC

L<http://martinfowler.com/articles/injection.html>

=item This is also sometimes called the Hollywood Principle

L<http://c2.com/cgi/wiki?HollywoodPrinciple>

=back

Here is a list of some Java frameworks which use the IoC technique.

=over 4

=item B<Avalon>

L<http://avalon.apache.org/products/runtime/index.html>

=item B<Spring Framework>

L<http://www.springframework.org/>

=item B<PicoContainer>

L<http://www.picocontainer.org>

=back

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

