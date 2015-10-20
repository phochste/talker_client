package Talker::Action::say_area;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

our @talk = (
        "Mrrrauw ",
        "Meow ",
        "Iauw ",
        "Miaaw ",
        "Prrrr ",
        "Prr mmrreow ",
        ".emote points at the sign ",
        );

sub run {
    my ($self, $buffer) = @_;

    my $area = $self->talker->state->area;

    sleep(3);

    my $text = $talk[rand(@talk)] . "$area\n";
    $self->talker->write_string($text);
}

1;