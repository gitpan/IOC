
package IOC::Service::ConstructorInjection;

use strict;
use warnings;

our $VERSION = '0.01';

use IOC::Exceptions;

use base 'IOC::Service';

sub new {
    my ($_class, $name, $component_class, $component_constructor, $parameters, $container) = @_;
    my $class = ref($_class) || $_class;
    my $service = {};
    bless($service, $class);
    $service->_init($name, $component_class, $component_constructor, $parameters, $container);
    return $service;
}

sub _init {
    my ($self, $name, $component_class, $component_constructor, $parameters, $container) = @_;
    (defined($component_class) && defined($component_constructor))
        || throw IOC::InsufficientArguments "You must provide a class and a constructor method";
    (defined($parameters) && ref($parameters) eq 'ARRAY')
        || throw IOC::InsufficientArguments "You must provide a set of parameters for the constructor as an Array reference";     
    $self->SUPER::_init(
        $name,
        sub {
            # get the IOC::Container object
            my $c = shift;
            eval { 
                no strict 'refs';
                # check if there is an entry in the 
                # symbol table for this class already
                # (meaning it has been loaded) and if 
                # not, then require it
                %{"${component_class}::"} || require $component_class 
            };
            # throw our exception if the class fails to load
            throw IOC::ClassLoadingError "The class '$component_class' could not be loaded" => $@ if $@;
            # check to see if the specified 
            # constructor is there
            my $constructor = $component_class->can($component_constructor);
            # if it is not, then throw our exception
            (defined($constructor)) 
                || throw IOC::ConstructorNotFound "The constructor '$component_constructor' could not be found for class '$component_class'";
            # now take care of the parameters
            for (my $i = 0; $i < scalar @{$parameters}; $i++) {
                # if the parameter is not been blessed
                # into the pseudo-package ComponentParameter
                # then we skip it, however ...
                next unless UNIVERSAL::isa($parameters->[$i], "ComponentParameter");
                # if it has been, then we derference it
                # into the name of the service expected
                # and use the IOC::Container to get an
                # instance of that service and replace 
                # that in the parameters array
                $parameters->[$i] = $c->get(${$parameters->[$i]});
            }                
            # now we have the class loaded, 
            # the constructor confirmed, and
            # the parameters realized, so we
            # can create the instance now
            return $component_class->$constructor(@{$parameters});
        },
        $container
        );
}

# class method
sub ComponentParameter { shift; bless(\(my $param = shift), "ComponentParameter") };

1;

__END__

=head1 NAME

IOC::Service::ConstructorInjection - An IOC Service object which uses Constructor Injection

=head1 SYNOPSIS

  use IOC::Service::ConstructorInjection;
  
  # this will call :
  #   FileLogger->new() 
  # when it creates a logger 
  # component instance
  my $service = IOC::Service::ConstructorInjection->new('logger' => ('FileLogger', 'new', []));

  # this will call :
  #    FileLogger->new($container->get('log_file'), "some other argument") 
  # when it creates a logger 
  # component instance
  my $service = IOC::Service::ConstructorInjection->new('logger' => (
                    'FileLogger', 'new', [
                        IOC::Service::ConstructorInjection->ComponentParameter('log_file'),
                        "some other argument"
                    ]));

=head1 DESCRIPTION

In this IOC framework, the IOC::Service::ConstructorInjection object holds instances of components to be managed.

=head1 METHODS

=over 4

=item B<new ($name, $component_class, $component_constructor, $parameters, $container)>

Creates a service with a C<$name>, and uses the C<$component_class> and C<$component_constructor> string arguments to initialize the service on demand. An optional fourth argument is the C<$container> which tells the service which container is belongs in. This can also be set with the C<setContainer> method.

If the C<$component_class> and C<$component_constructor> arguments are not defined, an B<IOC::InsufficientArguments> exception will be thrown. 

Upon request of the component managed by this service, an attempt will be made to load the C<$component_class>. If that loading fails, an B<IOC::ClassLoadingError> exception will be thrown with the details of the underlying error. If the C<$component_class> loads successfully, then it will be inspected for an available C<$component_constructor> method. If the C<$component_constructor> method is not found, an B<IOC::ConstructorNotFound> exception will be thrown. If the C<$component_constructor> method is found, then it will be called with the values found in C<$paramaters>. However, before C<$paramaters> are passed, they are first looped through looking for any "ComponentParameters" (these are place holders created with the class method C<ComponentParameter> (see below)), and replaces these items with the proper values extracted from the IOC framework.

=back

=head1 CLASS METHODS

=over 4

=item B<ComponentParameter ($component_name)>

Given a C<$component_name> this will create a place holder suitable for placement in the C<$parameters> argument of the C<new> method. The C<$component_name> must be the name of a valid service within the container of the requesting service.

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

=item Constructor Injection in the PicoContainer is explained on this page

L<http://docs.codehaus.org/display/PICO/Constructor+Injection>

=back

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
