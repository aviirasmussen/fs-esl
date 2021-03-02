package Events::Controller::Esl;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::JSON qw(decode_json encode_json);
#
use Carp;
use Data::Dumper;
use Readonly;

sub index ($self) {
    my $json = $self->req->json;
    my $body = $self->req->body;
    $self->render(template => 'index');
}
1;
