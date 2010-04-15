#!/usr/bin/env perl
use lib 't/lib';
use Test::Resource::Pack;

use Resource::Pack::Dir;

throws_ok { Resource::Pack::Dir->new(name => 'test', dir => 'css') }
          qr/install_from is required/,
          "install_from is required for lone Dirs";

{
    my $dir = Resource::Pack::Dir->new(
        name         => 'test',
        dir          => 'css',
        install_from => data_dir,
    );

    test_install($dir, file('css', 'style.css'), 'css');
}

{
    my $dir = Resource::Pack::Dir->new(
        name         => 'css',
        install_from => data_dir,
    );

    test_install($dir, file('css', 'style.css'), 'css');
}

done_testing;
