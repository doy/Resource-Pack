package Resource::Pack::Resource;
use Moose;
use MooseX::Types::Path::Class qw(Dir);
use Class::Load;

# ABSTRACT: a collection of resources

extends 'Bread::Board::Container';
with 'Resource::Pack::Installable';

=head1 SYNOPSIS

    my $resource = Resource::Pack::Resource->new(
        name         => 'test',
        install_from => data_dir,
    );
    $resource->add_file(
        name => 'test1',
        file => 'test.txt'
    );
    $resource->add_dir(
        name => 'test2',
    );
    $resource->add_url(
        name => 'jquery',
        url  => 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js',
    );
    $resource->install;

=head1 DESCRIPTION

This class is a collection of other resources. It can contain
L<Resource::Pack::File>, L<Resource::Pack::Dir>, L<Resource::Pack::URL>, and
other L<Resource::Pack::Resource> objects. It is a subclass of
L<Bread::Board::Container>, and consumes the L<Resource::Pack::Installable>
role.

=cut

=attr install_from_dir

Base dir, where the contents will be located. Defaults to the
C<install_from_dir> of the parent resource. The associated constructor argument
is C<install_from>.

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

=attr file_class

What class to use in add_file. Defaults to L<Resource::Pack::File>.

=cut

has 'file_class' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Resource::Pack::File',
);

=attr dir_class

What class to use in dir_file. Defaults to L<Resource::Pack::Dir>.

=cut

has 'dir_class' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Resource::Pack::Dir',
);

=attr url_class

What class to use in url_file. Defaults to L<Resource::Pack::URL>.

=cut

has 'url_class' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Resource::Pack::URL',
);

=method install

The install method for this class installs all of the resources that it
contains, except for other L<Resource::Pack::Resource> resources. To also
install contained Resource::Pack::Resource resources, use the C<install_all>
method.

=cut

sub install {
    my $self = shift;
    for my $service_name ($self->get_service_list) {
        my $service = $self->get_service($service_name);
        $service->install if $service->does('Resource::Pack::Installable');
    }
}

=method install_all

This method installs all contained resources, including other
L<Resource::Pack::Resource> resources.

=cut

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

=method add_file

Creates a L<Resource::Pack::File> resource inside this resource, passing any
arguments along to the constructor.

=cut

sub add_file {
    my $self = shift;
    Class::Load::load_class( $self->file_class );
    $self->add_service( $self->file_class->new(
        @_,
        parent => $self,
    ));
}

=method add_dir

Creates a L<Resource::Pack::Dir> resource inside this resource, passing any
arguments along to the constructor.

=cut

sub add_dir {
    my $self = shift;
    Class::Load::load_class( $self->dir_class );
    $self->add_service($self->dir_class->new(
        @_,
        parent => $self,
    ));
}

=method add_url

Creates a L<Resource::Pack::URL> resource inside this resource, passing any
arguments along to the constructor.

=cut

sub add_url {
    my $self = shift;
    Class::Load::load_class( $self->url_class );
    $self->add_service($self->url_class->new(
        @_,
        parent => $self,
    ));
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
