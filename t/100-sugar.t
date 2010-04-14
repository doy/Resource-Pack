#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use Path::Class;

{
    package My::App::Resources;
    use Moose;
    use Resource::Pack;

    extends 'Resource::Pack::Resource';

    has '+name' => (default => 'my_app');

    sub BUILD {
        my $self = shift;

        resource $self => as {
            install_from(Path::Class::Dir->new($FindBin::Bin, 'data', '100'));

            url jquery => 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js';
            file app_js => 'app.js';
            file app_css => (
                file       => 'app.css',
                install_to => 'css',
            );
            dir 'images';
        };
    }

    no Resource::Pack;
    no Moose;
}

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

done_testing;
