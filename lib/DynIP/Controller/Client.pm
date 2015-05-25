package DynIP::Controller::Client;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

sub index :Path('/client') :Args(0) {
    my ( $self, $c ) = @_;

    print "Hello from client ".$c->stash->{client}." - ".$c->req->address."\n";

    $c->res->status(200);
    $c->res->body('');
}

__PACKAGE__->meta->make_immutable;

1;
