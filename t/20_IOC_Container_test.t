#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

BEGIN { 
    use_ok('IOC::Container');  
    use_ok('IOC::Service');  
}

can_ok("IOC::Container", 'new');

my $container = IOC::Container->new();
isa_ok($container, 'IOC::Container');

can_ok($container, 'name');
can_ok($container, 'register');
can_ok($container, 'get');

is($container->name(), 'default', '... our container is named default');

# check register errors

throws_ok {
    $container->register()
} "IOC::InsufficientArguments", '... cannot register without a service object';

throws_ok {
    $container->register("Fail")
} "IOC::InsufficientArguments", '... cannot register without a service object';

throws_ok {
    $container->register([])
} "IOC::InsufficientArguments", '... cannot register without a service object';

throws_ok {
    $container->register(bless({}, "Fail"))
} "IOC::InsufficientArguments", '... cannot register without a service object';

my $service = IOC::Service->new('logger' => sub { 'Logger' });
isa_ok($service, 'IOC::Service');

lives_ok {
    $container->register($service);
} '... service registered successfully';

# check duplicate errors

throws_ok {
    $container->register($service);    
} "IOC::DuplicateServiceException", '... cannot register duplicate named service';

# check get errors

throws_ok {
    $container->get()
} "IOC::InsufficientArguments", '... cannot get without a service without a name';

throws_ok {
    $container->get('Fail')
} "IOC::MissingServiceException", '... cannot get without a service that does not exist';

my $fetched_service;

lives_ok {
    $fetched_service = $container->get('logger')
} '... got the service successfully';

ok(defined($fetched_service), '... we got a fetched service');
is($fetched_service, 'Logger', '... and it is the service instance we expected');

