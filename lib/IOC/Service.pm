
package IOC::Service;

use strict;
use warnings;

our $VERSION = '0.01';

use IOC::Exceptions;

sub new {
    my ($_class, $name, $block, $container) = @_;
    my $class = ref($_class) || $_class;
    my $service = {};
    bless($service, $class);
    $service->_init($name, $block, $container);
    return $service;
}

sub _init {
    my ($self, $name, $block, $container) = @_;
    (defined($name)) || throw IOC::InsufficientArguments "Service object cannot be created without a name";
    (defined($block) && ref($block) eq 'CODE')
        || throw IOC::InsufficientArguments "Service object cannot be created without CODE block";
    # set the defaults
    $self->{_instance} = undef;
    # assign constructor args    
    $self->{name} = $name;
    $self->{block} = $block;
    # container is optional
    $self->{container} = $container;
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub setContainer {
    my ($self, $container) = @_;
    (defined($container) && ref($container) && UNIVERSAL::isa($container, 'IOC::Container'))
        || throw IOC::InsufficientArguments "container argument is incorrect";
    $self->{container} = $container;
}

sub instance {
    my ($self) = @_;
    unless (defined $self->{_instance}) {
        (defined($self->{container}))
            || throw IOC::IllegalOperation "Cannot create a service instance without setting container";    
        $self->{_instance} = $self->{block}->($self->{container});
        (defined($self->{_instance})) 
            || throw IOC::InitializationError "Service creation block returned undefined value";
    }
    return $self->{_instance};
}

sub DESTROY {
    my ($self) = @_;
    # remove the connnection to the instance
    # but do not attempt to DESTROY it, that
    # should be left up to the instance itself
    $self->{_instance} = undef if defined $self->{_instance};
    # remove the container instance as well
    # no need to DESTROY this either since 
    # not only could it still have other services
    # in it, but it it highly likely that the
    # call to DESTROY this object came from
    # its container anyway
    $self->{container} = undef if defined $self->{container};
}

1;

__END__

=head1 NAME

IOC::Service - An IOC Service object

=head1 SYNOPSIS

  use IOC::Service;
  
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

In this IOC framework, the IOC::Service object holds instances of components to be managed.

=head1 METHODS

=over 4

=item B<new ($name, $block, $container)>

Creates a service with a C<$name>, and uses the C<$block> argument to initialize the service on demand. An optional third argument is the C<$container> which tells the service which container is belongs in. This can also be set with the C<setContainer> method.

=item B<name>

Returns the name of the service instance.

=item B<setContainer ($container)>

Given a C<$container>, which is an instance of IOC::Container or a subclass of it, this method will associate the service instance with that container object.

=item B<instance>

This method returns the component held by the service object, the is basically the value returned by the C<$block> constructor argument.

=back

=head1 TO DO

=over 4

=item Create subclasses of IOC::Service for specialized behavior

The idea is to allow different types of injection by using different IOC::Service subclasses, such as; IOC::Service::ConstructorInjection, IOC::Service::SetterInjection, IOC::Service::InterfaceInjection. 

=item Allow a containerless IOC::Service 

Basically it would be IOC::Service::Containerless, and would not require a container. This may or may not be useful, we shall see.

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

