
package IOC::Container::MethodResolution;

use strict;
use warnings;

our $VERSION = '0.01';

use IOC::Exceptions;

use base 'IOC::Container';

our $AUTOLOAD;

sub AUTOLOAD {
    my ($self) = @_;
    my $service_name = (split '::', $AUTOLOAD)[-1];
    (exists ${$self->{services}}{$service_name}) 
        || throw IOC::ServiceNotFound "Service '$service_name' not found";
    return $self->get($service_name);
}

1;

__END__

=head1 NAME

IOC::Container::MethodResolution - An IOC Container object which support method resolution of services

=head1 SYNOPSIS

  use IOC::Container;
  
  my $container = IOC::Container->new();
  $container->register(IOC::Service->new('log_file' => sub { "logfile.log" }));
  $container->register(IOC::Service->new('logger' => sub { 
      my $c = shift; 
      return FileLogger->new($c->log_file());
  }));
  $container->register(IOC::Service->new('application' => sub {
      my $c = shift; 
      my $app = Application->new();
      $app->logger($c->logger());
      return $app;
  }));

  $container->application()->run();       

=head1 DESCRIPTION

In this IOC framework, the IOC::Container::MethodResolution object holds instances of keyed IOC::Service objects which can be called as methods.

=head1 METHODS

There are no new methods for this subclass, but when a service is registered, the name of the service becomes a valid method for this particular container instance.

=head1 TO DO

=over 4

=item Work on the documentation

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, see the CODE COVERAGE section of L<IOC> for more information.

=head1 SEE ALSO

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

