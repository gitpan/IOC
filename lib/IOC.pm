
package IOC;

use strict;
use warnings;

our $VERSION = '0.02';

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
#         || throw IOC::DuplicateContainerException "Duplicate Container '$name'";
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

I<B<NOTE:> This is B<very> alpha software, and a very early release of this module. There are many plans in the works, and should be coming soon as this project is currently under active development. That said, submission, suggestions and general critisism is welcomed and encouraged.>

This module provide a lightweight IOC or Inversion of Control framework. Inversion of Control, sometimes called Dependency Injection, is a component management style which aims to clean up component configuration and provide a cleaner, more flexible means of configuring a large application.

A similar style of component management is the Service Locator, in which a global Service Locator object holds instances of components which can be retrieved by key. The common style is to create and configure each component instance and add it into the Service Locator. The main drawback to this approach is the aligning of the dependencies of each component prior to inserting the component into the Service Locator. If your dependency requirements change, then your initialization code must change to accomidate. This can get quite complex when you need to re-arrange initialization ordering and such. The Inversion of Control style alleviates this problem by taking a different approach.

With Inversion of Control, you configure a set of individual Service objects, which know how to initialize their particular components. If these components have dependencies, the will resolve them through the IOC framework itself. This results in a loosly coupled configuration which places no expectation upon initialization order. If your dependency requirements change, you need only adjust your Service's initialization routine, the ordering will adapt on it's own.

Now, if you are confused by my description above, then I suggest going to this page (L<http://onestepback.org/index.cgi/Tech/Ruby/DependencyInjectionInRuby.rdoc>) and reading the description there. This author does a much better job than I could ever hope to in explaining Inversion of Control (or as he calls it Dependency Injection). It should also be noted that the code and IoC techniques in this module were taken largely from this article. For more links and information on this topic, see the L<SEE ALSO> section.

=head1 TO DO

=over 4

=item Create a tree-like Container manager

I can use a path syntax to climb the tree (ex: 'database/connection', 'logging/logger', 'logging/log_file', etc). This would allow a finer grainer organization of services and containers, however it would also only really be useful for larger projects.

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, below is the B<Devel::Cover> report on this module test suite.

 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 File                                  stmt branch   cond    sub    pod   time  total
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 IOC.pm                               100.0    n/a    n/a  100.0    n/a    9.6  100.0
 IOC/Exceptions.pm                    100.0    n/a    n/a  100.0    n/a   11.5  100.0
 IOC/Container.pm                     100.0   90.0   81.8  100.0  100.0   15.7   96.0
 IOC/Container/MethodResolution.pm    100.0  100.0    n/a  100.0    n/a    3.7  100.0
 IOC/Service.pm                       100.0  100.0   83.3  100.0  100.0   39.2   97.5
 IOC/Service/ConstructorInjection.pm  100.0  100.0   77.8  100.0  100.0    9.7   97.3
 IOC/Service/SetterInjection.pm       100.0  100.0   77.8  100.0  100.0   10.5   97.2
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------
 Total                                100.0   98.1   80.5  100.0  100.0  100.0   97.5
 ----------------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

Some IoC Article links

=over 4

=item The code here is based upon the code found in this article.

L<http://onestepback.org/index.cgi/Tech/Ruby/DependencyInjectionInRuby.rdoc>

=item This is a decent article on IoC with Java.

L<http://today.java.net/pub/a//today/2004/02/10/ioc.html>

=item An article by Martin Fowler about IoC

L<http://martinfowler.com/articles/injection.html>

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

