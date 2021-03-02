package Events;
use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Date;
use Readonly;
use Data::Dumper;
#
#
Readonly my $HOME     => $ENV{'HOME'};
Readonly my $TRUE     => 1;
Readonly my $FALSE    => 0;
#
my $esl_server;
sub startup ($self) {
    my $config  = $self->plugin('Config');

    #$self->log->level('debug');

    $self->log->info('new request');    
    my $routes  = $self->routes;
    
    $routes->get('/')->to(controller => 'esl', action => 'index');;
    $routes->websocket('/esl' => sub ($c) {
	# Increase inactivity timeout for connection to 300 seconds
	$c->inactivity_timeout(300);
    	$self->log->debug('Client connected');
	
	if(!$esl_server){
	    $self->log->debug('FS ESL not connected');
	    $esl_server = Mojo::IOLoop->client({port => 8021} => sub ($loop, $err, $client) {
		# Increase inactivity timeout for connection
		$client->timeout(60);
		my $buffer = '';
		$self->log->debug('connected to FS event server');
		$client->on(read => sub ($client, $bytes) {
		    # Process input
		    if($bytes =~ /auth\/request/ ){
			$self->log->debug('authenticate ClueCon with FS event server');
			$client->write("auth ClueCon\x0a\x0a");
		    }elsif($bytes =~ /\+OK\saccepted/ ){
			$self->log->debug('authenticatet OK');
			$c->tx->send({json => {
			    'Event-Date-Local'  => Mojo::Date->new(time)->to_string,
			    'Event-Name' => 'Authenticated OK',
				      }});
		    }elsif($bytes =~ /\+OK/ ){
			$self->log->debug('command OK, awaiting events');
			$c->tx->send({json => {
			    'Event-Date-Local'  => Mojo::Date->new(time)->to_string,
			    'Event-Name' => 'Command OK',
				      }});
		    }elsif($bytes =~ /\-ERR/ ){
			$self->log->debug('command Failed');
			my ($error) = $bytes =~ m/err\s+(.+)/i;
			$c->tx->send({json => {
			    'Event-Date-Local'  => Mojo::Date->new(time)->to_string,
			    'Event-Name' => 'Command Failed['.$error.']',
				      }});
		    }elsif($bytes =~ /^content-length:[^\x0a]+\x0acontent-type:[^\x0a]+text\/event-json/i ){ # seems like FS esl events aways starts with content-length, and ends with next event....(:0)
			my $i = 0;
			# for now read bytes into one or more readable eventes from FS
			# I would love to know if it's possible to limit or control the stream bytes vs. server protocol, pls. let me know if you know :-)
			while($bytes =~ m/content-length:[^\d]+(\d+)\x0a(content-type:[^\x0a]+)\x0a\x0a(.+?(?=content-len|$))/ig){ 
			    my ($len, $type, $body) = ($1, $2, $3);
			    $self->log->debug("\n" . $body);
			    my $json = decode_json $body;
			    $c->tx->send({json => $json});
			}
		    }else{
			$self->log->error('N/A not implemented');
			$self->log->debug("\n" . Dumper $bytes);
		    }
			    });
						     });
	}

	$c->on(message => sub {
	    my ($c, $msg) = @_;

	    my $stream = Mojo::IOLoop->stream($esl_server);
	    $stream->write("event json ".$msg."\x0a\x0a");
	    $c->tx->send({json => {
		'Event-Date-Local'  => Mojo::Date->new(time)->to_string,
		'Event-Name' => 'sendt: event json '.$msg,
			  }});
	    
	       });

	$c->on(finish => sub {
	    $self->log->debug('Client disconnected');
	       });
		       }
	);

    
    return $TRUE;
}
1;
