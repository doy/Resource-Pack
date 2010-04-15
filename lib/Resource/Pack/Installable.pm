package Resource::Pack::Installable;
use Moose::Role;
use MooseX::Types::Path::Class qw(Dir);

use File::Copy::Recursive ();

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
    $self->_install_to_dir(@_);
    return Path::Class::Dir->new($self->_install_to_parts);
}

sub install_to_absolute {
    my $self = shift;
    my $to = $self->install_to_dir;
    if ($self->can('get')) {
        $to = $self->isa('Resource::Pack::Dir')
            ? Path::Class::Dir->new($to, $self->get)
            : Path::Class::File->new($to, $self->get);
    }
    return $to;
}

sub install {
    my $self = shift;
    my $from = $self->install_from_absolute->stringify;
    my $to   = $self->install_to_absolute->stringify;
    File::Copy::Recursive::rcopy($from, $to)
        or die "Couldn't copy $from to $to: $!";
}

after install => sub {
    my $self = shift;
    if ($self->does('Bread::Board::Service::WithDependencies')) {
        for my $dep ($self->get_all_dependencies) {
            $dep->[1]->service->install(@_);
        }
    }
};

sub get { shift->install_as }

no Moose::Role;

1;
