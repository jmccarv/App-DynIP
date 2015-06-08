package App::DynIP::Controller::Client;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

sub auto :Private {
    my ( $self, $c ) = @_;

    $c->log->warn("Admin should not be at /client")
        if ($c->stash->{is_admin});

    $c->detach('/go_away') unless $c->stash->{client};
}

sub update :Local :Args(0) {
    my ( $self, $c ) = @_;

    unless (defined $c->req->address) {
        $c->log->error("Could not get request address, something is terribly wrong!");
        $c->detach('/misconfigured');
    }

    $c->detach('/internal_error') 
        unless $c->model->update($c->stash->{client}, $c->req->address);

    $c->res->status(200);
    $c->res->body('');
}

__PACKAGE__->meta->make_immutable;

1;
