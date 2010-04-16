package Resource::Pack::FromFile;
use Moose;
use MooseX::Types::Path::Class qw(File);
use Resource::Pack;

extends 'Resource::Pack::Resource';

=head1 NAME

Resource::Pack::FromFile - easily use external resource description files

=head1 SYNOPSIS

    # in data/resources
    url jquery => 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js';
    file app_js => 'app.js';
    file app_css => (
        file       => 'app.css',
        install_to => 'css',
    );
    dir 'images';

    # in installer script
    my $resource = Resource::Pack::FromFile->new(
        name          => 'my_app',
        resource_file => 'data/resources',
        install_to    => 'app',
    );
    $resource->install;

or

    package My::App::Resources;
    use Moose;
    extends 'Resource::Pack::FromFile';

    has '+name'          => (default => 'my_app');
    has '+resource_file' => (default => 'data/resources');

    my $resource = My::App::Resources->new(install_to => 'app');
    $resource->install;

=head1 DESCRIPTION

This is a subclass of L<Resource::Pack::Resource>, which handles loading a
resource definition from a separate file.

=cut

=head1 ATTRIBUTES

=cut

=head2 resource_file

The file to read the resource definition from. The containing directory is used
as the default for C<install_from>.

=cut

has resource_file => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
    required => 1,
);

sub BUILD {
    my $self = shift;
    resource $self => as {
        install_from(Path::Class::File->new($self->resource_file)->parent);
        include($self->resource_file);
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Resource::Pack;

=head1 AUTHORS

  Stevan Little <stevan.little@iinteractive.com>

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
