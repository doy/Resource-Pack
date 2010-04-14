package Resource::Pack;
use Moose::Exporter;

use Bread::Board ();
use Carp qw(confess);

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
    $CC->add_service(Resource::Pack::File->new(@_));
}

sub dir ($@) {
    my $name = shift;
    unshift @_, 'dir' if @_ % 2 == 1;
    $CC->add_service(Resource::Pack::Dir->new(@_));
}

sub url ($@) {
    my $name = shift;
    unshift @_, 'url' if @_ % 2 == 1;
    $CC->add_service(Resource::Pack::URL->new(@_));
}

sub install_to ($) {
    $CC->install_to(shift);
}

sub install_from ($) {
    $CC->install_from(shift);
}

Moose::Exporter->setup_import_methods(
    also  => ['Bread::Board'],
    as_is => [qw(resource file dir url install_to install_from)],
);

1;
