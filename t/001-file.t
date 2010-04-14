#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;
use FindBin;
use Path::Class;

use Resource::Pack::File;

throws_ok { Resource::Pack::File->new(name => 'test', file => 'test.txt') }
          qr/install_from is required/,
          "install_from is required for lone Files";

{
    my $file = Resource::Pack::File->new(
        name         => 'test',
        file         => 'test.txt',
        install_from => dir($FindBin::Bin, 'data', '001'),
    );

    ok(!-e 'test.txt', "doesn't exist yet");
    $file->install;
    ok(-e 'test.txt', "installed properly");

    unlink 'test.txt';
}

{
    my $file = Resource::Pack::File->new(
        name         => 'test',
        install_from => dir($FindBin::Bin, 'data', '001'),
    );

    ok(!-e 'test', "doesn't exist yet");
    $file->install;
    ok(-e 'test', "installed properly with default file name");

    unlink 'test';
}

done_testing;
