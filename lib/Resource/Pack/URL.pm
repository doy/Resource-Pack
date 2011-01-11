package Resource::Pack::URL;
use Moose;
use MooseX::Types::Path::Class qw(File);
use MooseX::Types::URI qw(Uri);
# ABSTRACT: a URL resource

use LWP::UserAgent;

with 'Resource::Pack::Installable',
     'Bread::Board::Service',
     'Bread::Board::Service::WithDependencies';

=head1 SYNOPSIS

    my $url = Resource::Pack::URL->new(
        name => 'jquery',
        url  => 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js',
    );
    $url->install;

=head1 DESCRIPTION

This class represents a URL to be downloaded and installed. It can also be
added as a subresource to a L<Resource::Pack::Resource>. This class consumes
the L<Resource::Pack::Installable>, L<Bread::Board::Service>, and
L<Bread::Board::Service::WithDependencies> roles.

=cut

=attr url

Required, read-only attribute for the source URL.

=cut

has url => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

=attr install_as

The name to use for the installed file. Defaults to the filename portion of the
C<url> attribute.

=cut

has install_as => (
    is      => 'rw',
    isa     => File,
    coerce  => 1,
    lazy    => 1,
    default => sub { (shift->url->path_segments)[-1] },
);

=method install_from_absolute

Returns the entire source url.

=cut

sub install_from_absolute {
    my $self = shift;
    $self->url;
}

=method install

Overridden to handle the downloading of the source file, before installing it.

=cut

sub install {
    my $self = shift;
    my $response = LWP::UserAgent->new->get($self->url->as_string);
    if ($response->is_success) {
        my $to = $self->install_to_absolute;
        $to->parent->mkpath unless -e $to->parent;
        my $fh = $to->openw;
        $fh->print($response->content);
        $fh->close;
    }
    else {
        confess "Could not fetch file " . $self->url->as_string
              . " because: " . $response->status_line;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
