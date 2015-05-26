package DynIP::Controller::Client;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use Proc::Lite;

BEGIN { extends 'Catalyst::Controller' }

sub auto :Private {
    my ( $self, $c ) = @_;

    $c->log->warn("Admin should not be at /client")
        if ($c->stash->{is_admin});

    $c->detach('/go_away') unless $c->stash->{client};
}

sub index :Path('/client') :Args(0) {
    my ( $self, $c ) = @_;

    my $addr = $c->req->address;
    my $server = $c->config->{name_server};
    my $domain = $c->config->{domain};
    my $fqdn = $c->model->fqdn($c->stash->{client});

    $c->detach('/misconfigured')
        unless defined $addr && defined $server && defined $domain && defined $fqdn;

    $c->detach('/internal_error') 
        unless $c->model->update($c->stash->{client}, $c->req->address);

    $c->res->status(200);
    $c->res->body('');
}

__PACKAGE__->meta->make_immutable;

1;
