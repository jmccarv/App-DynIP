package DynIP::Controller::Root;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

DynIP::Controller::Root - Root Controller for DynIP

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;
#
#    # Hello World
#    $c->response->body( $c->welcome_message );
#}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub auto :Private {
    my ( $self, $c ) = @_;

    # Make sure they're authorized to be here
    #my $token = $c->config->{AuthToken};

    $c->forward('misconfigured'), return 0
        unless (defined $c->config->{clients} 
                && ref($c->config->{clients}) eq 'HASH');

    unless (defined $c->req->header('x-auth-token') 
            &&      defined $c->config->{clients}->{$c->req->header('x-auth-token')}) {

        $c->response->status(401);
        $c->response->body('Go Away');

        return 0;
    }

    $c->stash->{client} = $c->config->{clients}->{$c->req->header('x-auth-token')};

    1;
}

sub misconfigured : Private {
    my ( $self, $c ) = @_;

    $c->response->status(500);
    $c->response->body('Misconfiguration, whoops');
    return 0;
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
