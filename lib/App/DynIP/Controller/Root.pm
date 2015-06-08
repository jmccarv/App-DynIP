package App::DynIP::Controller::Root;
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

App::DynIP::Controller::Root - Root Controller for App::DynIP

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

    # First thing, all valid clients/admins must have this header
    $c->detach('/go_away')
        unless defined $c->req->header('x-auth-token');


    # Admin user?
    if (defined $c->config->{admin_token}
        && $c->config->{admin_token} eq $c->req->header('x-auth-token')
    ) {
        $c->stash->{is_admin} = 1;
        return 1;
    }

    
    # Not admin, make sure we have our client config
    $c->forward('misconfigured'), return 0
        unless (defined $c->config->{clients} 
                && ref($c->config->{clients}) eq 'HASH');


    # Authenticate client and stash their hostname
    if (defined $c->config->{clients}->{$c->req->header('x-auth-token')}
    ) {
        $c->stash->{client} = $c->config->{clients}->{$c->req->header('x-auth-token')};
        return 1;
    }


    # I don't know who you are but you don't belong here
    $c->detach('/go_away');
}

sub go_away : Private {
    my ( $self, $c ) = @_;

    $c->response->status(401);
    $c->response->body('Go Away');
    0;
}

sub misconfigured : Private {
    my ( $self, $c ) = @_;

    $c->response->status(500);
    $c->response->body('Misconfiguration, whoops');
    0;
}

sub internal_error : Private {
    my ( $self, $c, $errmsg ) = @_;

    $c->response->status(500);
    $c->response->body(defined $errmsg ? $errmsg : 'Something went horribly wrong');
    0;
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
