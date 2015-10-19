package Talker::State;

use Moo::Role;
use Log::Any;
use overload '""' => 'stringify';
use JSON;

requires 'update_exits';
requires 'update_area_users';

has 'exits'      => (is => 'rw');
has 'area_users' => (is => 'rw');

has 'talker'     => (is => 'rw');
has 'log'        => (is => 'lazy');

sub _build_log {
    my ($self) = @_;
    Log::Any->get_logger(category => ref($self));
}

sub update {
	my ($self) = @_;

	$self->update_exits();
	$self->update_area_users();
}

sub stringify {
	my ($self) = @_;

	my $text = "";

	$text .= "exits: " . encode_json($self->exits) . "; ";
	$text .= "area_users: " . encode_json($self->area_users) . "; ";

	$text;
}

1;