#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

BEGIN { 
    use_ok('IOC::Registry');  
    use_ok('IOC::Service');   
    use_ok('IOC::Container');  
}

can_ok("IOC::Registry", 'new');

my $reg = IOC::Registry->new();
isa_ok($reg, 'IOC::Registry');
isa_ok($reg, 'Class::StrongSingleton');

#is($reg, IOC::Registry->new(), '... this really is a singleton');

my $test1 = IOC::Container->new('test 1');
isa_ok($test1, 'IOC::Container');
my $test2 = IOC::Container->new('test 2');
isa_ok($test2, 'IOC::Container');
my $test3 = IOC::Container->new('test 3');
isa_ok($test3, 'IOC::Container');

my $test_sub_2_2;

lives_ok {

    $test_sub_2_2 = IOC::Container->new('sub test 2.2')
                        ->register(IOC::Service->new('test service 2.2-1' => sub { '2.2-1' }))
                        ->register(IOC::Service->new('test service 2.2-2' => sub { '2.2-2' }));

    $test1->addSubContainers(
        IOC::Container->new('sub test 1.1')
            ->register(IOC::Service->new('test service 1.1-1' => sub { '1.1-1' }))
            ->register(IOC::Service->new('test service 1.1-2' => sub { '1.1-2' })),
        IOC::Container->new('sub test 1.2')
            ->register(IOC::Service->new('test service 1.2-1' => sub { '1.2-1' }))
            ->register(IOC::Service->new('test service 1.2-2' => sub { '1.2-2' }))        
            ->addSubContainers(
                IOC::Container->new('sub test 1.2.1')
                    ->register(IOC::Service->new('test service 1.2.1-1' => sub { '1.2.1-1' })),
                IOC::Container->new('sub test 1.2.2')
                    ->register(IOC::Service->new('test service 1.2.2-1' => sub { '1.2.2-1' }))
                    ->register(IOC::Service->new('test service 1.2.2-2' => sub { '1.2.2-2' }))
                )
        );
    
    $test2->addSubContainers(
        IOC::Container->new('sub test 2.1')
            ->register(IOC::Service->new('test service 2.1-1' => sub { '2.1-1' }))
            ->addSubContainers(
                IOC::Container->new('sub test 2.1.1')
                    ->register(IOC::Service->new('test service 2.1.1-1' => sub { '2.1.1-1' })),
                IOC::Container->new('sub test 2.1.2')
                    ->register(IOC::Service->new('test service 2.1.2-1' => sub { '2.1.2-1' }))
                    ->register(IOC::Service->new('test service 2.1.2-2' => sub { '2.1.2-2' }))
                ),      
        $test_sub_2_2
        );
    
    $test3->register(IOC::Service->new('test service 3-1' => sub { '3-1' }))
          ->register(IOC::Service->new('test service 3-2' => sub { '3-2' }));
      
} '... created our hierarchy successfully';
                          
$reg->registerContainer($test1);
$reg->registerContainer($test2);
$reg->registerContainer($test3);                                              

is($test1, $reg->getRootContainer('test 1'), '... got the right container');
is($test2, $reg->getRootContainer('test 2'), '... got the right container');
is($test3, $reg->getRootContainer('test 3'), '... got the right container');
 
{
    my $service = $reg->searchForService('test service 2.1.2-2');                                                                  
    ok(defined($service), '... we found the service');
    is($service, '2.1.2-2', '... and the service is what we expected');                                                                            
}

{
    my $service = $reg->searchForService('test service 2.1.5-2');
    ok(!defined($service), '... we did not find the service');
}
                                                                                                
{
    my $container = $reg->searchForContainer('sub test 2.2');                                                                  
    ok(defined($container), '... we found the container');
    isa_ok($container, 'IOC::Container');
    is($container, $test_sub_2_2, '... and it is the container we expected');
}
   
{
    my $container = $reg->searchForContainer('sub test 2.2-Nothing');                                                                  
    ok(!defined($container), '... we did not find the container');
}

# check some errors

throws_ok {
    $reg->getRootContainer()
} "IOC::InsufficientArguments", '... got an error';

throws_ok {
    $reg->getRootContainer("Fail")
} "IOC::ContainerNotFound", '... got an error';

throws_ok {
    $reg->registerContainer()
} "IOC::InsufficientArguments", '... got an error';

throws_ok {
    $reg->registerContainer("Fail")
} "IOC::InsufficientArguments", '... got an error';

throws_ok {
    $reg->registerContainer([])
} "IOC::InsufficientArguments", '... got an error';

throws_ok {
    $reg->registerContainer(bless {} => "Fail")
} "IOC::InsufficientArguments", '... got an error';

throws_ok {
    $reg->registerContainer(IOC::Container->new('test 1'))
} "IOC::ContainerAlreadyExists", '... got an error';

