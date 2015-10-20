package Talker::State;

use Moo::Role;
use Log::Any;
use JSON;

requires 'update_exits';
requires 'update_area_users';

has 'exits'      => (is => 'rw');
has 'area_users' => (is => 'rw');

has 'talker'     => (is => 'rw');;
has 'log'        => (is => 'lazy');

sub _build_log {
    my ($self) = @_;
    Log::Any->get_logger(category => ref($self));
}

sub update {
	my ($self) = @_;

	$self->log->debug("update_exits");
	$self->update_exits();

	$self->log->debug("update_area_users");
	$self->update_area_users();
}

sub as_string {
	my ($self) = @_;

	my $text = "";

	$text .= "exits: " . encode_json($self->exits) . "; ";
	$text .= "area_users: " . encode_json($self->area_users) . "; ";

	$text;
}

1;