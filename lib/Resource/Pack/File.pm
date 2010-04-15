package Resource::Pack::File;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);

with 'Resource::Pack::Installable',
     'Bread::Board::Service',
     'Bread::Board::Service::WithDependencies';

has file => (
    is      => 'ro',
    isa     => File,
    coerce  => 1,
    lazy    => 1,
    default => sub { Path::Class::File->new(shift->name) },
);

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
            confess "install_from is required for File resources without a container";
        }
    },
);

has install_as => (
    is      => 'rw',
    isa     => File,
    coerce  => 1,
    lazy    => 1,
    default => sub { shift->file },
);

sub install_from_absolute {
    my $self = shift;
    $self->install_from_dir->file($self->file);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
