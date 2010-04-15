package Resource::Pack::URL;
use Moose;
use MooseX::Types::Path::Class qw(File);
use MooseX::Types::URI qw(Uri);

use LWP::UserAgent;

with 'Resource::Pack::Installable',
     'Bread::Board::Service',
     'Bread::Board::Service::WithDependencies';

has url => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

has install_as => (
    is      => 'rw',
    isa     => File,
    coerce  => 1,
    lazy    => 1,
    default => sub { (shift->url->path_segments)[-1] },
);

sub install_from_absolute {
    my $self = shift;
    $self->url;
}

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
