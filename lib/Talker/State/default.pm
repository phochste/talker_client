package Talker::State::default;

use Moo;

with 'Talker::State';

sub update_exits {
    my ($self) = @_;

    my $exits = $self->talker->state->exits // [];
    $self->talker->state->exits($exits);
}

1;