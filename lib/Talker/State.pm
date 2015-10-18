package Talker::State;

use Moo::Role;
use Log::Any;
use overload '""' => 'stringify';
use JSON;

requires 'update_exits';

has 'exits'  => (is => 'rw'); 

has 'talker' => (is => 'rw');
has 'log'    => (is => 'lazy');

sub _build_log {
    my ($self) = @_;
    Log::Any->get_logger(category => ref($self));
}

sub update {
	my ($self) = @_;

	$self->update_exits();
}

sub stringify {
	my ($self) = @_;

	my $text = "";

	$text .= "exists: " . encode_json($self->exits) . ";";

	$text;
}

1;