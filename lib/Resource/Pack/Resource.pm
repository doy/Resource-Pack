package Resource::Pack::Resource;
use Moose;
use MooseX::Types::Path::Class qw(Dir);

extends 'Bread::Board::Container';
with 'Resource::Pack::Installable';

has install_from => (
    is         => 'ro',
    isa        => Dir,
    coerce     => 1,
    predicate  => 'has_install_from',
    default    => sub {
        my $self = shift;
        if ($self->has_parent) {
            return $self->parent->install_from;
        }
        else {
            confess "install_from is required for root containers";
        }
    },
);

sub install {
    my $self = shift;
    for my $service_name ($self->get_service_list) {
        my $service = $self->get_service($service_name);
        $service->install if $service->does('Resource::Pack::Installable');
    }
    for my $container_name ($self->get_sub_container_list) {
        my $container = $self->get_sub_container($container_name);
        $container->install if $container->does('Resource::Pack::Installable');
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
