#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Resource::Pack::URL;

{
    my $url = Resource::Pack::URL->new(
        name => 'jquery',
        url  => 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js',
    );
    ok(!-e 'jquery.min.js', "doesn't exist yet");
    $url->install;
    ok(-e 'jquery.min.js', "installed properly");
    like(Path::Class::File->new('jquery.min.js')->slurp,
         qr/jQuery JavaScript Library/,
         "got jquery");

    unlink 'jquery.min.js';
}

done_testing;
