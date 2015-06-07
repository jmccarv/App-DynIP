package DynIP::Controller::Admin;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

sub auto :Private {
    my ( $self, $c ) = @_;

    $c->detach('/go_away') unless $c->stash->{is_admin};
}

sub update :Local :Args(2) {
    my ( $self, $c, $hostname, $ip ) = @_;    

    $c->detach('/internal_error') 
        unless $c->model->update($hostname, $ip);

    $c->res->status(200);
    $c->res->body('');
}

sub delete :Local :Args(1) {
    my ( $self, $c, $hostname ) = @_;

    $c->detach('/internal_error') 
        unless $c->model->update($hostname);

    $c->res->status(200);
    $c->res->body('');
}

__PACKAGE__->meta->make_immutable;

1;
