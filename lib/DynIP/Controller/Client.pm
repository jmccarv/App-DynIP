package DynIP::Controller::Client;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

sub index :Path('/client') :Args(0) {
    my ( $self, $c ) = @_;

    #print "Hello from client ".$c->stash->{client}." - ".$c->req->address."\n";
    my $addr = $c->req->address;
    my $server = $c->config->{name_server};
    my $domain = $c->config->{domain};
    my $fqdn = $c->stash->{client}.'.'.$domain;

    $c->forward('misconfigured'), return 0
        unless defined $addr && defined $server && defined $domain && defined $fqdn;

my $update = <<EOT;
server $server
zone $domain
update delete $fqdn
update add $fqdn 86400 A $addr
send
EOT

    print "update:\n$update\n";

    $c->res->status(200);
    $c->res->body('');
}

__PACKAGE__->meta->make_immutable;

1;
