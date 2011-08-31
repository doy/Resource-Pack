#!/usr/bin/env perl

use lib 't/lib';
use Test::Resource::Pack;

our %installed;

{
    package Test::Resource::Pack::File;

    use Moose;

    extends 'Resource::Pack::File';
    after 'install' => sub { $installed{'file'}++ };
}

{
    package Test::Resource::Pack::Dir;

    use Moose;
    extends 'Resource::Pack::Dir';

    after 'install' => sub { $installed{'dir'}++ };
}

{
    package Test::Resource::Pack::URL;

    use Moose;
    extends 'Resource::Pack::URL';

    after 'install' => sub { $installed{'url'}++ };
}

package main;

use Resource::Pack::Resource;

my $container = Resource::Pack::Resource->new(
    name         => 'test',
    install_from => data_dir,
    file_class   => 'Test::Resource::Pack::File',
    dir_class    => 'Test::Resource::Pack::Dir',
    url_class    => 'Test::Resource::Pack::URL',
);

my $file = $container->add_file(
    name => 'test1',
    file => 'test.txt'
);
isa_ok($file, 'Test::Resource::Pack::File');

my $dir = $container->add_dir(
    name => 'test2',
);
isa_ok($dir, 'Test::Resource::Pack::Dir');

test_install($container, 'test.txt', 'test2');

is_deeply(
    \%installed,
    { file => 1, dir => 1 },
    'proper modifications'
);

done_testing;

 

