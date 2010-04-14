package Resource::Pack::Installable;
use Moose::Role;
use MooseX::Types::Path::Class qw(Dir);

requires 'install';

has _install_to_dir => (
    is         => 'rw',
    isa        => Dir,
    coerce     => 1,
    predicate  => '_has_install_to_dir',
    init_arg   => 'install_to',
);

sub _install_to_parts {
    my $self = shift;
    if ($self->has_parent && $self->parent->does(__PACKAGE__)) {
        if ($self->_has_install_to_dir) {
            return ($self->parent->_install_to_parts, $self->_install_to_dir);
        }
        else {
            return $self->parent->_install_to_parts;
        }
    }
    else {
        if ($self->_has_install_to_dir) {
            return $self->_install_to_dir;
        }
        else {
            return;
        }
    }
}

sub install_to_dir {
    my $self = shift;
    return Path::Class::Dir->new($self->_install_to_parts);
}

after install => sub {
    my $self = shift;
    if ($self->does('Bread::Board::Service::WithDependencies')) {
        for my $dep ($self->get_all_dependencies) {
            $dep->[1]->service->install(@_);
        }
    }
};

no Moose::Role;

1;
