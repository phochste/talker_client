package Talker::Action::random_action;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

our @talk = (
        ".emote licks her paws",
        ".emote streches and walks away",
        ".emote purrs",
        ".emote licks some beer from the floor",
        ".emote rolls over",
        ".emote sneezes",
        ".emote smiles",
        ".emote yawns",
        ".emote starts purring",
        ".emote lies down",
        ".emote winks",
        ".emote snickers",
        ".emote nods",
);

sub run {
	my ($self, $buffer) = @_;

	sleep(1);

    my $r = int(rand(100));

    if ($r <= 20) {
	   $self->talker->write_string($talk[rand(@talk)] . "\n");
    }
    elsif ($r < 50) {
       my @letters = ('a'..'z');
       my $random_letter = $letters[int rand @letters];
       $self->talker->write_string(".go $random_letter\n");
    }
}

1;