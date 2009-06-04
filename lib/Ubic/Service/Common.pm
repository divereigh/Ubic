package Ubic::Service::Common;

use strict;
use warnings;

=head1 NAME

Ubic::Service::Common - common way to construct new service by specifying several callbacks

=head1 SYNOPSIS

    $service = Ubic::Service::Common->new({
        start => sub {
            # implementation-specific
        },
        stop => sub {
            # implementation-specific
        },
        status => sub {
            # implementation-specific
        },
        name => "yandex-ppb-something",
        port => 1234,
    });
    $service->start;

=head1 DESCRIPTION

Each service should provide safe C<start()>, C<stop()> and C<status()> methods.

=cut

use Params::Validate qw(:all);

use base qw(Ubic::Service::Skeleton);

use Yandex::Lockf;
use Yandex::Persistent;

=head1 CONSTRUCTOR

C<< Ubic::Service::Common->new($params) >>

Construct service object.

Possible parameters:

=over

=item I<start>

Mandatory sub reference providing service start mechanism.

=item I<stop>

The same for stop.

=item I<status>

Mandatory sub reference checking if service is alive.

It should return one of C<running>, C<not running>, C<broken> values.

This code will be used as safety check against double start and as a watchdog.

=item I<name>

Service's name.

=item I<port>

Service's port.

=back

=cut
sub new {
    my $class = shift;
    my $params = validate(@_, {
        start       => { type => CODEREF },
        stop        => { type => CODEREF },
        status      => { type => CODEREF },
        name        => { type => SCALAR, regex => qr/^[\w.-]+$/, optional => 1 }, # violates Ubic::Service incapsulation...
        port        => { type => SCALAR, regex => qr/^\d+$/, optional => 1},
    });
    my $self = bless {%$params} => $class;
    return $self;
}

sub port {
    my ($self) = @_;
    return $self->{port};
}

sub status_impl {
    my ($self) = @_;
    $self->{status}->();
}

sub start_impl {
    my ($self) = @_;
    $self->{start}->();
}

sub stop_impl {
    my ($self) = @_;
    $self->{stop}->();
}

=head1 AUTHOR

Vyacheslav Matjukhin <mmcleric@yandex-team.ru>

=cut

1;

