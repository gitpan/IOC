#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

BEGIN {    
    use_ok('IOC::Service::ConstructorInjection');   
    use_ok('IOC::Container');    
}

{ # create a package for a dummy service
    package Logger;
    sub new {
        my ($class, $file, $format_string) = @_;
        return bless {
            file          => $file,
            format_string => $format_string 
            } => $class;
    }
    
    package File;
    sub new { bless {} => $_[0] }
}

can_ok("IOC::Service::ConstructorInjection", 'new');

my $service = IOC::Service::ConstructorInjection->new('logger' => 
                                ('Logger', 'new' => [ 
                                    IOC::Service::ConstructorInjection->ComponentParameter('file'),
                                    "Log %d %s"
                                ]));
isa_ok($service, 'IOC::Service::ConstructorInjection');
isa_ok($service, 'IOC::Service');

my $service2 = IOC::Service::ConstructorInjection->new('file' => ('File', 'new', []));
isa_ok($service2, 'IOC::Service::ConstructorInjection');
isa_ok($service2, 'IOC::Service');

my $container = IOC::Container->new();
isa_ok($container, 'IOC::Container');

$container->register($service);
$container->register($service2);

can_ok($service, 'instance');

my $logger = $service->instance();
isa_ok($logger, 'Logger');
isa_ok($logger->{file}, 'File');

# check some errors now

throws_ok {
    IOC::Service::ConstructorInjection->new('file');
} "IOC::InsufficientArguments", '... cannot create a constructor injection without a component class';

throws_ok {
    IOC::Service::ConstructorInjection->new('file' => ("Fail"));
} "IOC::InsufficientArguments", '... cannot create a constructor injection without a component class constructor';

throws_ok {
    IOC::Service::ConstructorInjection->new('file' => ("Fail", 'new'));
} "IOC::InsufficientArguments", '... cannot create a constructor injection without a parameter list';

throws_ok {
    IOC::Service::ConstructorInjection->new('file' => ("Fail", 'new', "Fail"));
} "IOC::InsufficientArguments", '... cannot create a constructor injection without an array ref as parameter list';

throws_ok {
    IOC::Service::ConstructorInjection->new('file' => ("Fail", 'new', {}));
} "IOC::InsufficientArguments", '... cannot create a constructor injection without an array ref as parameter list';

throws_ok {
    IOC::Service::ConstructorInjection->new('file2' => ("Fail", 'new', []), $container)->instance;
} "IOC::ClassLoadingError", '... cannot create a constructor injection without real class';

throws_ok {
    IOC::Service::ConstructorInjection->new('file3' => ("File", 'noNew', []), $container)->instance;
} "IOC::ConstructorNotFound", '... cannot create a constructor injection without a proper class constructor name';