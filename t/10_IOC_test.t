#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

BEGIN { 
    use_ok('IOC');
    use_ok('IOC::Exceptions');    
    use_ok('IOC::Container');
    use_ok('IOC::Service');    
}


{
    package FileLogger;
    sub new { bless { log_file => $_[1] } => $_[0] }
    
    package Application;
    sub new { bless { logger => undef } => $_[0] }
    sub logger { $_[0]->{logger} = $_[1] }
    sub run {}
}	

lives_ok {

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
    
} '... our framework works';
