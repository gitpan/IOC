#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;
use Test::Exception;

BEGIN {
    use_ok('IOC::Container');
    use_ok('IOC::Service::SetterInjection');
}

# Cyclical dependencies:
#     +---+
#  +--| A |<-+
#  |  +---+  |
#  |  +---+  |
#  +->| B |--+
#     +---+

{
    my $c = IOC::Container->new();
    $c->register(IOC::Service->new('a' => sub { (shift)->get('b') }));
    $c->register(IOC::Service->new('b' => sub { (shift)->get('a') }));
    
    throws_ok {
        $c->get('a');
    } 'IOC::IllegalOperation', '... got the error we expected';
    like($@->toString(1), qr/The 'a' service is currently locked/, '... correct dependency found'); 
}

# Graph Dependecies
#       +---+
#    +--| C |<-+
#    |  +---+  |
#  +-V-+     +---+
#  | D |     | F |
#  +---+     +-^-+
#    |  +---+  |
#    +->| E |--+
#       +---+
 
{
    my $c = IOC::Container->new();
    $c->register(IOC::Service->new('c' => sub { (shift)->get('d') }));
    $c->register(IOC::Service->new('d' => sub { (shift)->get('e') }));
    $c->register(IOC::Service->new('e' => sub { (shift)->get('f') }));
    $c->register(IOC::Service->new('f' => sub { (shift)->get('c') }));
    
    throws_ok {
        $c->get('c');
    } 'IOC::IllegalOperation', '... got the error we expected';
    like($@->toString(1), qr/The 'c' service is currently locked/, '... correct dependency found'); 
}
 
# Graph Dependecies
#       +---+
#    +--| G |<-+
#    |  +---+  |
#  +-V-+     +---+  +---+  +---+
#  | H |     | J |  | K |->| L |
#  +---+     +-^-+  +-^-+  +---+
#   | |  +---+ |      |
#   | +->| I |-+      |
#   |    +---+        |
#   +-----------------+

{
    my $c = IOC::Container->new();
    $c->register(IOC::Service->new('g' => sub { (shift)->get('h') }));              
    $c->register(IOC::Service->new('h' => sub { $_[0]->get('k'), $_[0]->get('i') }));                  
    $c->register(IOC::Service->new('i' => sub { (shift)->get('j') }));                  
    $c->register(IOC::Service->new('j' => sub { (shift)->get('g') }));                       
    $c->register(IOC::Service->new('k' => sub { (shift)->get('l') }));   
    $c->register(IOC::Service->new('l' => sub { '... this is the end' }));       
    
    throws_ok {
        $c->get('g');
    } 'IOC::IllegalOperation', '... got the error we expected';
    like($@->toString(1), qr/The 'g' service is currently locked/, '... correct dependency found');    
} 
 
