package Talker::Action::say_orange;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

sub run {
    my ($self, $buffer) = @_;

    sleep(1);

    $self->talker->write_string("Rrrrainbow iaaauuww\n");
}

1;