
package IOC;

use strict;
use warnings;

our $VERSION = '0.04';

use IOC::Exceptions;

use IOC::Container;
use IOC::Service;

# 
# my %CONTAINERS;
# 
# sub registerContainerInstance {
#     my ($class, $container) = @_;
#     (defined($container) && ref($container) && UNIVERSAL::isa($container, 'IOC::Container'))
#         || throw IOC::InsufficientArguments "You must supply a valid IOC::Container object";
#     my $container_name = $container->name();
#     (!exists $CONTAINERS{$name})
#         || throw IOC::ContainerAlreadyExists "Duplicate Container '$name'";
#     $CONTAINER{$name} = $container;
# }
# 
# sub getContainerNameList {
#     my ($class) = @_;
#     return keys %CONTAINERS;
# }

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

A similar style of component management is the Service Locator, in which a global Service Locator object holds instances of components which can be retrieved by key. The common style is to create and configure each component instance and add it into the Service Locator. The main drawback to this approach is the aligning of the dependencies of each component prior to inserting the component into the Service Locator. If your dependency requirements change, then your initialization code must change to accomidate. This can get quite complex when you need to re-arrange initialization ordering and such. The Inversion of Control style alleviates this problem by taking a different approach.

With Inversion of Control, you configure a set of individual Service objects, which know how to initialize their particular components. If these components have dependencies, the will resolve them through the IOC framework itself. This results in a loosly coupled configuration which places no expectation upon initialization order. If your dependency requirements change, you need only adjust your Service's initialization routine, the ordering will adapt on it's own.

For links to how other people have explained Inversion of Control, see the L<SEE ALSO> section.

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
       
=head1 TO DO   

=over 4

=item Work on the documentation

=item Create a top-level IOC::Registry

This would be a singleton object, which could be used to serve a something like a top-level container. I need to think this one out more.

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, below is the B<Devel::Cover> report on this module test suite.

 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 File                                  stmt branch   cond    sub    pod   time  total
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 IOC.pm                               100.0    n/a    n/a  100.0    n/a   38.2  100.0
 IOC/Exceptions.pm                    100.0    n/a    n/a  100.0    n/a    5.9  100.0
 IOC/Interfaces.pm                    100.0    n/a    n/a  100.0    n/a    5.6  100.0
 IOC/Container.pm                     100.0   96.7   93.1  100.0  100.0   25.7   98.4
 IOC/Container/MethodResolution.pm    100.0  100.0    n/a  100.0    n/a    1.4  100.0
 IOC/Service.pm                       100.0  100.0   83.3  100.0  100.0   11.9   97.5
 IOC/Service/ConstructorInjection.pm  100.0  100.0   77.8  100.0  100.0    4.1   97.3
 IOC/Service/SetterInjection.pm       100.0  100.0   77.8  100.0  100.0    4.2   97.2
 IOC/Visitor/ServiceLocator.pm        100.0  100.0   77.8  100.0  100.0    3.2   97.0
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 Total                                100.0   98.8   85.3  100.0  100.0  100.0   98.0
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

Some IoC Article links

=over 4

=item The code here was originally inspired by the code found in this article.

L<http://onestepback.org/index.cgi/Tech/Ruby/DependencyInjectionInRuby.rdoc>

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

