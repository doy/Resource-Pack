package Resource::Pack;
use Moose::Exporter;

use Bread::Board ();
use Carp qw(confess);
use Scalar::Util qw(blessed);

use Resource::Pack::Dir;
use Resource::Pack::File;
use Resource::Pack::Resource;
use Resource::Pack::URL;

our $CC;

sub resource ($;$$) {
    my $name = shift;
    my $c;
    my $name_is_resource = blessed($name)
                        && $name->isa('Resource::Pack::Resource');
    if (@_ == 0) {
        return $name if $name_is_resource;
        return Resource::Pack::Resource->new(name => $name);
    }
    elsif (@_ == 1) {
        $c = $name_is_resource
            ? $name
            : Resource::Pack::Resource->new(name => $name);
    }
    else {
        confess "Parameterized resources are not currently supported";
    }
    my $body = shift;
    if (defined $CC) {
        $CC->add_sub_container($c);
    }
    if (defined $body) {
        local $_  = $c;
        local $CC = $c;
        $body->($c);
    }
    return $c;
}

sub file ($@) {
    my $name = shift;
    unshift @_, 'file' if @_ % 2 == 1;
    $CC->add_file(@_, name => $name);
}

sub dir ($@) {
    my $name = shift;
    unshift @_, 'dir' if @_ % 2 == 1;
    $CC->add_dir(@_, name => $name);
}

sub url ($@) {
    my $name = shift;
    unshift @_, 'url' if @_ % 2 == 1;
    $CC->add_url(@_, name => $name);
}

sub install_to ($) {
    $CC->install_to_dir(shift);
}

sub install_from ($) {
    $CC->install_from_dir(shift);
}

Moose::Exporter->setup_import_methods(
    also  => ['Bread::Board'],
    as_is => [qw(resource file dir url install_to install_from)],
);

1;
