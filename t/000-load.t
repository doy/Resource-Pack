#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN {
    my @modules = qw(
        Resource::Pack
        Resource::Pack::File
        Resource::Pack::Dir
        Resource::Pack::URL
        Resource::Pack::FromFile
    );

    for my $mod (@modules) {
        use_ok($mod) or BAIL_OUT("Couldn't load module $mod");
    }
}

done_testing;
