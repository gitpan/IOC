
package IOC::Exceptions;

use strict;
use warnings;

our $VERSION = '0.03';

use Class::Throwable qw(
        IOC::ServiceNotFound
        IOC::ServiceAlreadyExists
        IOC::ContainerNotFound
        IOC::ContainerAlreadyExists
        IOC::IllegalOperation
        IOC::InsufficientArguments
        IOC::InitializationError
        IOC::ClassLoadingError
        IOC::ConstructorNotFound
        IOC::MethodNotFound
        );

$Class::Throwable::DEFAULT_VERBOSITY = 2;

1;

__END__

=head1 NAME

IOC::Exceptions - Exception objects for the IOC Framework

=head1 SYNOPSIS

  use IOC::Exceptions;

=head1 DESCRIPTION

=head1 EXCEPTIONS

=over 4

=item B<IOC::ServiceNotFound>

=item B<IOC::ServiceAlreadyExists>

=item B<IOC::ContainerNotFound>

=item B<IOC::ContainerAlreadyExists>

=item B<IOC::InsufficientArguments>

=item B<IOC::IllegalOperation>

=item B<IOC::InitializationError>

=item B<IOC::ClassLoadingError>

=item B<IOC::ConstructorNotFound>

=item B<IOC::MethodNotFound>

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

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
