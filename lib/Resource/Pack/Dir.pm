package Resource::Pack::Dir;
use Moose;
use MooseX::Types::Path::Class qw(Dir);

use File::Copy::Recursive qw(dircopy);

with 'Resource::Pack::Installable',
     'Bread::Board::Service',
     'Bread::Board::Service::WithDependencies';

has dir => (
    is      => 'ro',
    isa     => Dir,
    coerce  => 1,
    lazy    => 1,
    default => sub { Path::Class::Dir->new(shift->name) },
);

sub get { shift->dir }

has install_from_dir => (
    is         => 'rw',
    isa        => Dir,
    coerce     => 1,
    init_arg   => 'install_from',
    predicate  => 'has_install_from_dir',
    default    => sub {
        my $self = shift;
        if ($self->has_parent && $self->parent->has_install_from_dir) {
            return $self->parent->install_from_dir;
        }
        else {
            confess "install_from is required for Dir resources without a container";
        }
    },
);

sub install {
    my $self = shift;
    dircopy(
        $self->install_from_dir->subdir($self->dir)->stringify,
        $self->install_to_dir->subdir($self->dir)->stringify,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
