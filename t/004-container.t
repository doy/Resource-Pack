#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use Path::Class;

use Resource::Pack::Resource;
use Resource::Pack::File;

{
    my $container = Resource::Pack::Resource->new(
        name         => 'test',
        install_from => dir($FindBin::Bin, 'data', '004'),
    );
    $container->add_file(
        name => 'test1',
        file => 'test.txt'
    );
    $container->add_file(
        name => 'test2',
    );

    ok(!-e 'test.txt', "first file doesn't exist yet");
    ok(!-e 'test2', "second file doesn't exist yet");
    $container->install;
    ok(-e 'test.txt', "first file exists");
    ok(-e 'test2', "second file exists");

    unlink 'test.txt';
    unlink 'test2';
}

done_testing;
