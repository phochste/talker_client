package Talker::Action::say_hello;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

our @talk = (
        "Mrrrauw :x ",
        "Moew hello ",
        "Iauw hi.. ",
        "Miaaw mo vint toch, ",
        "Prrrr hehehe, prrhello ",
        "Doei ",
        "Yo muaw .. ",
        ":) ",
        "Prr mmrreow ",
        "Meoweke yoke ",
        "Mrrgoodmorrrning ",
        "Meowww terrre ",
        "Hi iauwww ",
        "Meowwwke hi "
        );

sub run {
   my ($self, $buffer) = @_;

    if ($buffer =~ /^(\w+)/) {
       my $name = $1;
       sleep(1);
       my $text = $talk[rand(@talk)] . "$name\n";
       $self->talker->write_string($text);
    }
}

1;
