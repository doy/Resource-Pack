#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use Path::Class;

use Resource::Pack::FromFile;

{
    my $resource = Resource::Pack::FromFile->new(
        name          => 'my_app',
        resource_file => Path::Class::File->new($FindBin::Bin, 'data', '101', 'resources'),
        install_to    => 'app',
    );
    ok(!-e $_, "$_ doesn't exist yet")
        for map { "app/$_" } qw(app.js css css/app.css images images/logo.png jquery.min.js);
    $resource->install;
    ok(-e $_, "$_ exists!")
        for map { "app/$_" } qw(app.js css css/app.css images images/logo.png jquery.min.js);
    like(file('app', 'jquery.min.js')->slurp,
        qr/jQuery JavaScript Library/,
        "got correct jquery");

    dir('app')->rmtree;
}

{
    package My::App::Resources;
    use Moose;
    extends 'Resource::Pack::FromFile';

    has '+name' => (default => 'my_app');
    has '+resource_file' => (
        default => sub {
            Path::Class::File->new($FindBin::Bin, 'data', '101', 'resources')
        },
    );
}

{
    my $resource = My::App::Resources->new(install_to => 'app');
    ok(!-e $_, "$_ doesn't exist yet")
        for map { "app/$_" } qw(app.js css css/app.css images images/logo.png jquery.min.js);
    $resource->install;
    ok(-e $_, "$_ exists!")
        for map { "app/$_" } qw(app.js css css/app.css images images/logo.png jquery.min.js);
    like(file('app', 'jquery.min.js')->slurp,
        qr/jQuery JavaScript Library/,
        "got correct jquery");

    dir('app')->rmtree;
}

done_testing;
