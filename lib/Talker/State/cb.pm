package Talker::State::cb;

use Moo;

with 'Talker::State';

sub update_exits {
    my ($self) = @_;

    my $exits = $self->talker->{state}->exits // [];
    $self->talker->state->exits($exits);

    $self->log->debug("updating exists");

    $self->talker->write_string(".look\n");
    $self->talker->read_while(sub {
        my $line = shift;

        if ($line =~ /^\*\*\s+exits\s+:\s+(.*)/) {
            $self->talker->state->exits( [split(/\s+/,$1)] );
            return 1;
        }

        return 0;
    },10);
}

1;