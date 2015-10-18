package Talker::Action::calculate;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

our @talk = (
        "Prrrrrrt :p'' ",
        "Meow ?" ,
        ".emote stares at you" ,
        ".emote eyebrows frown",
        "Prrr hehehe prr",
        ".th 42?"
        );

our @talk2 = (
        ".emote licks her paws",
        ".emote streches and walks away",
        ".emote snors",
        ".emote licks some beer from the floor",
        ".emote rolls over",
        ".emote sneezes",
        ".emote smiles",
        ".emote snickers",
        ".emote nods"
        );

sub run {
    my ($self, $buffer) = @_;

    if ($buffer =~ /[0-9]{2,}/) {
        sleep(1);
        my $answer = int(rand(1000));
        $self->talker->write_string("$answer !\n");

        sleep(2);
        $self->talker->write_string($talk[rand(@talk2)] . "\n");
    }
    elsif ($buffer =~ /([0-9]{1})\s*([+*\/-])\s*([0-9]{1})/) {
       my $left  = $1;
       my $op    = $2;
       my $right = $3;
       my $answer;

       sleep(1);

       eval "\$answer = $left $op $right";

       if ($@) {
            $self->talker->write_string($talk[rand(@talk)] . "\n");
            return;
       }

       my $text;

       if (int(rand(10)) < 8) {
            $self->talker->write_string("$answer !\n");
       }
       else {
            $answer += 1 - int(rand(3));
            $self->talker->write_string("$answer ?\n");

            sleep(1);
            $self->talker->write_string($talk[rand(@talk2)] . "\n");
       }
    }
}

1;
