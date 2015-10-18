package Talker::Action::say_yes;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

sub run {
    my ($self, $buffer) = @_;
}

1;