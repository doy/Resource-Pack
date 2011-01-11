package Resource::Pack::Dir;
use Moose;
use MooseX::Types::Path::Class qw(Dir);
# ABSTRACT: a directory resource

with 'Resource::Pack::Installable',
     'Bread::Board::Service',
     'Bread::Board::Service::WithDependencies';

=head1 SYNOPSIS

    my $dir = Resource::Pack::Dir->new(
        name         => 'test',
        dir          => 'css',
        install_from => data_dir,
    );
    $dir->install;

=head1 DESCRIPTION

This class represents a directory to be installed. It can also be added as a
subresource to a L<Resource::Pack::Resource>. This class consumes the
L<Resource::Pack::Installable>, L<Bread::Board::Service>, and
L<Bread::Board::Service::WithDependencies> roles.

=cut

=attr dir

Read-only attribute for the source directory. Defaults to the service name.

=cut

has dir => (
    is      => 'ro',
    isa     => Dir,
    coerce  => 1,
    lazy    => 1,
    default => sub { Path::Class::Dir->new(shift->name) },
);

=attr install_from_dir

Base dir, where C<dir> is located. Defaults to the C<install_from_dir> of the
parent resource. The associated constructor argument is C<install_from>.

=cut

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

=attr install_as

The name to use for the installed directory. Defaults to C<dir>.

=cut

has install_as => (
    is      => 'rw',
    isa     => Dir,
    coerce  => 1,
    lazy    => 1,
    default => sub { shift->dir },
);

=method install_from_absolute

Entire path to the source directory (concatenation of C<install_from_dir> and
C<dir>).

=cut

sub install_from_absolute {
    my $self = shift;
    $self->install_from_dir->subdir($self->dir);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
