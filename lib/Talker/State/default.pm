package Talker::State::default;

use Moo;

with 'Talker::State';

sub update_exits {
    my ($self) = @_;

    my $exits = $self->talker->state->exits // [];
    $self->talker->state->exits($exits);
}

sub update_area_users {
	my ($self) = @_;

    my $area_users = $self->talker->state->area_users // [];
    $self->talker->state->area_users($area_users);
}

1;