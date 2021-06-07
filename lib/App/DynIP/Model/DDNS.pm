package App::DynIP::Model::DDNS;
use Moose;
use namespace::autoclean;
use Proc::Lite;
use Log::Any qw($log);

BEGIN { extends 'Catalyst::Model' }

has nsupdate_key => ( is => 'ro', isa => 'Str', required => 1 );
has domain       => ( is => 'ro', isa => 'Str', required => 1 );
has name_server  => ( is => 'ro', isa => 'Str', required => 1 );
has on_change    => ( is => 'ro', isa => 'Str' );

sub fqdn {
    my ( $self, $hostname ) = @_;
    $hostname.'.'.$self->domain;
}

sub update {
    my ( $self, $hostname, $addr, $force ) = @_;

    die 'nsupdate_key not readable: '.$self->nsupdate_key
        unless -r $self->nsupdate_key;

    die 'no hostname to update'
        unless defined $hostname;

    my $fqdn = $self->fqdn($hostname);

    my $old_ip = $self->get_ip($hostname);
    if (defined $addr && !$force && $old_ip eq $addr) {
        $log->debug("No need to update $fqdn, update requested would make no change");
        return 1;
    }

    my @update = (
        "server ".$self->name_server,
        "zone ".$self->domain,
        "update delete $fqdn"
    );

    push @update, "update add $fqdn 86400 A $addr"
        if defined $addr;
                
    push @update, "send";

    $log->debug("Updating zone:");
    $log->debug($_) for @update;

    my $p = Proc::Lite->new(
        command => [qw(nsupdate -k), $self->nsupdate_key ],
        stdin => \@update
    )->run;

    $log->debug("Running on_change script ".$self->on_change) if $self->on_change;
    Proc::Lite->exec($self->on_change, $hostname, $old_ip, $addr)
        if $self->on_change;

    unless ($p->success) {
        $log->error("nsupdate failed, command was:");
        $log->error($_) for @update;
        $log->error("stderr was:");
        $log->error($_) for $p->stderr;

        return 0;
    }

    1;
}

sub get_ip {
    my ( $self, $hostname ) = @_;

    die 'no hostname to update'
        unless defined $hostname;

    my $fqdn = $self->fqdn($hostname);

    my $p = Proc::Lite->new(command => [qw(dig +short), "\@".$self->name_server, $fqdn]);

    $log->debug("running dig \@".$self->name_server." $fqdn");
    unless ($p->run->success) {
        $log->error("dig failed for $fqdn \@".$self->name_server."; dig stderr follows:");
        $log->error($_) for $p->stderr;
        die "dig failed for $fqdn \@".$self->name_server;
    }

    $p->stdout->[0];
}

__PACKAGE__->meta->make_immutable;

1;
