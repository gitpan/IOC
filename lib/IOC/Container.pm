
package IOC::Container;

use strict;
use warnings;

our $VERSION = '0.01';

use IOC::Exceptions;

sub new {
    my ($_class, $name) = @_;
    my $class = ref($_class) || $_class;
    my $container = {};
    bless($container, $class);
    $container->_init($name);
    return $container;
}

sub _init {
    my ($self, $name) = @_;
    $self->{services} = {};
    $self->{name} = $name || 'default';
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub register {
    my ($self, $service) = @_;
    (defined($service) && ref($service) && UNIVERSAL::isa($service, 'IOC::Service'))
        || throw IOC::InsufficientArguments "You must provide a valid IOC::Service object to register";
    my $name = $service->name();
    (!exists ${$self->{services}}{$name}) 
        || throw IOC::DuplicateServiceException "Duplicate Service Name '${name}'"; 
    $service->setContainer($self);
    $self->{services}->{$name} = $service;
}

sub get {
    my ($self, $name) = @_;
    (defined($name)) || throw IOC::InsufficientArguments "You must provide a name of the service";    
    (exists ${$self->{services}}{$name}) 
        || throw IOC::MissingServiceException "Unknown Service '${name}'";
    $self->{services}->{$name}->instance();
}

sub getServiceList {
    my ($self) = @_;
    return keys %{$self->{services}};
}

sub DESTROY {
    my ($self) = @_;
    # this will DESTROY all the
    # services it holds, since
    # a service can only have one
    # container, then this is okay
    # to do that, otherwise we would
    # need to deal with that.
    foreach my $service (values %{$self->{services}}) {
        defined $service && $service->DESTROY;
    } 
}

1;

__END__

=head1 NAME

IOC::Container - An IOC Container object

=head1 SYNOPSIS

  use IOC::Container;
  
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

In this IOC framework, the IOC::Container object holds instance of IOC::Service objects keyed by strings.

=head1 METHODS

=over 4

=item B<new ($container_name)>

A container can be named with the optional C<$container_name> argument, otherwise the container will have the name 'default'. 

=item B<name>

This will return the name of the container.

=item B<register ($service)>

Given a C<$service>, this will register the C<$service> as part of this container. The value returned by the C<name> method of the C<$service> object is as the key where this service is stored. This also will call C<setContainer> on the C<$service> and pass in it's own instance.

If C<$service> is not an instance of IOC::Service, or a subclass of it, an B<IOC::InsufficientArguments> exception will be thrown.

If the name of C<$service> already exists, then a B<IOC::DuplicateServiceException> exception is thrown.

=item B<get ($name)>

Given a C<$name> this will return the service instance that name corresponds to, if C<$name> is not defined, an exception is thrown.

If there is no service by that C<$name>, then a B<IOC::MissingServiceException> exception is thrown.

=item B<getServiceList>

Returns a list of all the named services available.

=back

=head1 TO DO

=over 4

=item Allow the option to use method names for finding services

Basically this will utilize AUTOLOAD to allow service names to be called as methods instead of string arguments to C<get>. The preliminary package name is: IOC::Container::MethodResolution

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

