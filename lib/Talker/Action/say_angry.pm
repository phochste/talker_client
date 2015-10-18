package Talker::Action::say_angry;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

our @talk = (
        ".emote thinks . o O (Nondeju!)",
        ".emotes pisses into your beer",
        "Roaaaaaaaarrr!",
        ".shout Miaau  help!!",
        ".sos Iaauuw.... :X(",
        ".emote claws you",
        ".shout ai ai ai ai :X(",
        ".semote bites and claws around her",
        "Iaauww !!Grrrrrrrrrrrrrr!!  :X(",
        "Prrrrrrrrrrrrrrt :XP''' ''"
        );

sub run {
	my ($self, $buffer) = @_;

	sleep(1);

	$self->talker->write_string($talk[rand(@talk)] . "\n");
}

1;
