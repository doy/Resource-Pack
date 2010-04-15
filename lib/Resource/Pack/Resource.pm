package Resource::Pack::Resource;
use Moose;
use MooseX::Types::Path::Class qw(Dir);

extends 'Bread::Board::Container';
with 'Resource::Pack::Installable';

=head1 NAME

Resource::Pack::Resource - a collection of resources

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

has install_from_dir => (
    is         => 'rw',
    isa        => Dir,
    coerce     => 1,
    init_arg   => 'install_from',
    predicate  => 'has_install_from_dir',
    lazy       => 1,
    default    => sub {
        my $self = shift;
        if ($self->has_parent) {
            return $self->parent->install_from_dir;
        }
        else {
            confess "install_from_dir is required for root containers";
        }
    },
);

# don't install subcontainer contents by default, unless they are explicit deps
sub install {
    my $self = shift;
    for my $service_name ($self->get_service_list) {
        my $service = $self->get_service($service_name);
        $service->install if $service->does('Resource::Pack::Installable');
    }
}

sub install_all {
    my $self = shift;
    for my $service_name ($self->get_service_list) {
        my $service = $self->get_service($service_name);
        $service->install if $service->does('Resource::Pack::Installable');
    }
    for my $container_name ($self->get_sub_container_list) {
        my $container = $self->get_sub_container($container_name);
        $container->install_all
            if $container->does('Resource::Pack::Installable');
    }
}

sub add_file {
    my $self = shift;
    require Resource::Pack::File;
    $self->add_service(Resource::Pack::File->new(
        @_,
        parent => $self,
    ));
}

sub add_dir {
    my $self = shift;
    require Resource::Pack::Dir;
    $self->add_service(Resource::Pack::Dir->new(
        @_,
        parent => $self,
    ));
}

sub add_url {
    my $self = shift;
    require Resource::Pack::URL;
    $self->add_service(Resource::Pack::URL->new(
        @_,
        parent => $self,
    ));
}

__PACKAGE__->meta->make_immutable;
no Moose;

=head1 AUTHORS

  Stevan Little <stevan.little@iinteractive.com>

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
