
package IOC::Registry;

use strict;
use warnings;

our $VERSION = '0.01';

use IOC::Exceptions;
use IOC::Interfaces;

use IOC::Visitor::SearchForService;
use IOC::Visitor::SearchForContainer;

use base 'Class::StrongSingleton';

sub new {
    my ($_class) = @_;
    my $class = ref($_class) || $_class;
    my $registry = {
        containers => {}
        };
    bless($registry, $class);
    $registry->_init();
    return $registry;
}

sub getRootContainer {
    my ($self, $name) = @_;
    (defined($name)) || throw IOC::InsufficientArguments "You must supply a name of a container";
    (exists ${$self->{containers}}{$name}) 
        || throw IOC::ContainerNotFound "There is no container by the name '${name}'";     
    return $self->{containers}->{$name};
}

sub searchForContainer {
    my ($self, $container_to_find) = @_;
    my $container_found;
    foreach my $container (values %{$self->{containers}}) {
        $container_found = $container->accept(IOC::Visitor::SearchForContainer->new($container_to_find));
        last if defined $container_found;
    }
    return $container_found;
}

sub searchForService {
    my ($self, $service_to_find) = @_;
    my $service;
    foreach my $container (values %{$self->{containers}}) {
        $service = $container->accept(IOC::Visitor::SearchForService->new($service_to_find));
        last if $service;
    }
    return $service;
}

sub registerContainer {
    my ($self, $container) = @_;
    (defined($container) && ref($container) && UNIVERSAL::isa($container, 'IOC::Container'))
        || throw IOC::InsufficientArguments "You must supply a valid IOC::Container object";
    my $name = $container->name();
    (!exists ${$self->{containers}}{$name})
        || throw IOC::ContainerAlreadyExists "Duplicate Container '$name'";
    $self->{containers}->{$name} = $container;
}

1;

__END__

=head1 NAME

IOC::Registry - Registry singleton for the IOC Framework

=head1 SYNOPSIS

  use IOC::Registry;

  my $container = IOC::Container->new('database');
  my $other_container = IOC::Container->new('logging');
  # ... bunch of IOC::Container creation code omitted
  
  # create a registry singleton
  my $reg = IOC::Registry->new();
  $reg->registerContainer($container);
  $reg->registerContainer($other_container);
  
  # ... somewhere later in your program
  
  my $reg = IOC::Registry->instance(); # get the singleton
  
  # and try and find a service
  my $service = $reg->searchForService('laundry') || die "Could not find the logger service";
  
  my $database = $reg->getRootContainer('database');

=head1 DESCRIPTION

This is a singleton object which is meant to be used as a global registry for all your IoC needs. 

=head1 METHODS

=over 4

=item B<new>

Creates a new singleton instance of the Registry, the same singleton will be returned each time C<new> is called after the first one. 

=item B<registerContainer ($container)>

=item B<getRootContainer ($name)>

=item B<searchForContainer ($name)>

=item B<searchForService ($name)>

=back

=head1 TO DO

=over 4

=item Work on the documentation

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, see the CODE COVERAGE section of L<IOC> for more information.

=head1 SEE ALSO

=over 4

=item L<Class::StrongSingleton>

This is a subclass of Class::StrongSingleton, if you want to know about how the singleton-ness is handled, check there.

=back

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

