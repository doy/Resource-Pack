package Resource::Pack::File;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);

use File::Copy::Recursive qw(fcopy);

with 'Resource::Pack::Installable', 'Bread::Board::Service';

has file => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
    required => 1,
);

sub get { shift->file }

has install_from => (
    is         => 'ro',
    isa        => Dir,
    coerce     => 1,
    lazy_build => 1,
);

sub _build_install_from {
    my $self = shift;
    if ($self->parent->has_install_from) {
        return $self->parent->install_from;
    }
    else {
        confess "install_from is required for File resources without a container";
    }
}

sub install {
    my $self = shift;
    fcopy(
        $self->install_from->file($self->file)->stringify,
        $self->install_to->file($self->file)->stringify,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
