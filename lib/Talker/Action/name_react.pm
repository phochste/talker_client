package Talker::Action::name_react;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

our @talk = (
        "Meow...",
        "He he he",
        "Prrrr mmmh",
        ".emote licks her paws",
        ".emote runs through the area",
        ".emote snickers",
        "Miau au au au",
        "Waff!",
        "Iauw, ..auw, ..mauw",
        ".emote sneezes",
        "Meow...meow",
        "Iauu?",
        "re re reow eoaw",
        "Prrr =)",
        "Iauw .. meow",
        "Pprrr auw..iaw",
        ".emote nods",
        "iauw auw auw",
        "Iuaw lag ... hmmmrr..",
        "Mauw hehehe",
        "Prrrr?",
        ".emote licks her paws",
        ".emote streches and walks away",
        ".emote purrs",
        ".emote licks some beer from the floor",
        ".emote rolls over",
        ".emote sneezes",
        ".emote smiles",
        ".emote snickers",
        ".emote nods"
        );

sub run {
	my ($self, $buffer) = @_;

	sleep(1);

	$self->talker->write_string($talk[rand(@talk)] . "\n");
}

1;
