#!/usr/bin/env perl
use lib 't/lib';
use Test::Resource::Pack;

use Resource::Pack::Resource;

{
    my $container = Resource::Pack::Resource->new(
        name         => 'test',
        install_from => data_dir,
    );
    $container->add_file(
        name => 'test1',
        file => 'test.txt'
    );
    $container->add_file(
        name         => 'test2',
        dependencies => {
            test1 => Bread::Board::Dependency->new(service_path => 'test1'),
        },
    );

    test_install($container->fetch('test2'), 'test.txt', 'test2');
}

done_testing;
