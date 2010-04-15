package Resource::Pack;
use Moose::Exporter;

use Bread::Board;
use Carp qw(confess);
use Scalar::Util qw(blessed);

use Resource::Pack::Dir;
use Resource::Pack::File;
use Resource::Pack::Resource;
use Resource::Pack::URL;

=head1 NAME

Resource::Pack - tools for managing application resources

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

=head1 EXPORTS

Resource::Pack exports everything that L<Bread::Board> exports, as well as:

=cut

our $CC;

=head2 resource

=cut

sub resource ($;$$) {
    my $name = shift;
    my $c;
    my $name_is_resource = blessed($name)
                        && $name->isa('Resource::Pack::Resource');
    if (@_ == 0) {
        return $name if $name_is_resource;
        return Resource::Pack::Resource->new(name => $name);
    }
    elsif (@_ == 1) {
        $c = $name_is_resource
            ? $name
            : Resource::Pack::Resource->new(name => $name);
    }
    else {
        confess "Parameterized resources are not currently supported";
    }
    my $body = shift;
    if (defined $CC) {
        $CC->add_sub_container($c);
    }
    if (defined $body) {
        local $_  = $c;
        local $CC = $c;
        $body->($c);
    }
    return $c;
}

=head2 file

=cut

sub file ($@) {
    my $name = shift;
    unshift @_, 'file' if @_ % 2 == 1;
    $CC->add_file(@_, name => $name);
}

=head2 dir

=cut

sub dir ($@) {
    my $name = shift;
    unshift @_, 'dir' if @_ % 2 == 1;
    $CC->add_dir(@_, name => $name);
}

=head2 url

=cut

sub url ($@) {
    my $name = shift;
    unshift @_, 'url' if @_ % 2 == 1;
    $CC->add_url(@_, name => $name);
}

=head2 install_to

=cut

sub install_to ($) {
    $CC->install_to_dir(shift);
}

=head2 install_from

=cut

sub install_from ($) {
    $CC->install_from_dir(shift);
}

=head2 install_as

=cut

sub install_as ($) {
    $CC->install_as(shift);
}

{
    no warnings 'redefine';
    sub include ($) {
        my $file = shift;
        my $resources = Path::Class::File->new($file)->slurp . ";\n1;";
        if (!eval $resources) {
            die "Couldn't compile $file: $@" if $@;
            die "Unknown error when compiling $file";
        }
    }
}

Moose::Exporter->setup_import_methods(
    also  => ['Bread::Board'],
    as_is => [qw(resource file dir url install_to install_from install_as
                 include)],
);

=head1 BUGS/CAVEATS

No known bugs.

Please report any bugs through RT: email
C<bug-resource-pack at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Resource-Pack>.

=head1 SEE ALSO

L<JS>

L<File::ShareDir>

L<Bread::Board>

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc Resource::Pack

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Resource-Pack>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Resource-Pack>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Resource-Pack>

=item * Search CPAN

L<http://search.cpan.org/dist/Resource-Pack>

=back

=head1 AUTHORS

  Stevan Little <stevan.little@iinteractive.com>

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
