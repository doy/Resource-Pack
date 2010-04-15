package Resource::Pack::FromFile;
use Moose;
use MooseX::Types::Path::Class qw(File);
use Resource::Pack;

extends 'Resource::Pack::Resource';

has resource_file => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
    required => 1,
);

sub BUILD {
    my $self = shift;
    die "Can't find file " . $self->resource_file
        unless -f $self->resource_file;
    resource $self => as {
        install_from(Path::Class::File->new($self->resource_file)->parent);
        include($self->resource_file);
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
