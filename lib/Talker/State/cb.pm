package Talker::State::cb;

use Moo;

with 'Talker::State';

sub update_exits {
    my ($self) = @_;

    my $exits = $self->talker->state->exits // [];
    $self->talker->state->exits($exits);

    $self->log->debug("updating exists");

    $self->talker->write_string(".look\n");
    $self->talker->read_while(sub {
        my $line = shift;

        if ($line =~ /^\*\*\s+exits\s*:\s+(.*)/) {
            $self->talker->state->exits( [split(/\s+/,$1)] );
            return 1;
        }

        return 0;
    },10);
}

sub update_area_users {
    my ($self) = @_;

    $self->talker->state->area_users([]);

    $self->log->debug("updating area_users");

    $self->talker->write_string(".look\n");
    $self->talker->read_while(sub {
        my $line = shift;

        if ($line =~ /^\*\*\s+you\s+see\s*:\s+(.*)/) {
            my $match = $1;
            $self->talker->state->area_users( [split(/\s+/,$match)] )
                    unless ($match =~ /area\s+is\s+empty/);
            return 1;
        }

        return 0;
    },10);
}

1;