#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

BEGIN { 
    use_ok('IOC::Container::MethodResolution');  
    use_ok('IOC::Service');  
}

can_ok("IOC::Container::MethodResolution", 'new');

my $container = IOC::Container::MethodResolution->new('MyMethodResolutionTest');
isa_ok($container, 'IOC::Container::MethodResolution');

can_ok($container, 'register');
$container->register(IOC::Service->new('log' => sub { 'Log' }));

can_ok($container, 'name');
is($container->name(), 'MyMethodResolutionTest', '... the name is as we expect it to be');

my $value;
lives_ok {
    $value = $container->log();
} '... the method resolved correctly';

is($value, 'Log', '... and the value is as we expected');

throws_ok {
    $container->Fail();
} "IOC::ServiceNotFound", '... the service must exists or we get an exception';