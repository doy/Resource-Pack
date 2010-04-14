#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;
use FindBin;
use Path::Class;

use Resource::Pack::Dir;

throws_ok { Resource::Pack::Dir->new(name => 'test', dir => 'css') }
          qr/install_from is required/,
          "install_from is required for lone Dirs";

{
    my $dir = Resource::Pack::Dir->new(
        name         => 'test',
        dir          => 'css',
        install_from => dir($FindBin::Bin, 'data', '002'),
    );

    ok(!-d 'css', "doesn't exist yet");
    $dir->install;
    ok(-d 'css', "installed properly");
    ok(-f 'css/style.css', "installed properly");

    unlink 'css/style.css';
    rmdir 'css';
}

{
    my $dir = Resource::Pack::Dir->new(
        name         => 'css',
        install_from => dir($FindBin::Bin, 'data', '002'),
    );

    ok(!-d 'css', "doesn't exist yet");
    $dir->install;
    ok(-d 'css', "installed properly");
    ok(-f 'css/style.css', "installed properly");

    unlink 'css/style.css';
    rmdir 'css';
}

done_testing;
