package Talker::State::zodi;

use Moo;

with 'Talker::State';

sub update_exits {
    my ($self) = @_;

    my $exits = $self->talker->{state}->exits // [];
    $self->talker->state->exits($exits);

    $self->log->debug("updating exists");

    $self->talker->write_string(".go\n");
    $self->talker->read_while(sub {
        my ($x,$buffer) = @_;

        if ($buffer =~ /^From .* you can go to the ([^\.]+)/) {
            my $match = $1;
            $match =~ s{[\[\]\r\n]+}{};

            $self->talker->state->exits( [split(/\s*,\s*/,$match)] );

            return 1;
        }

        return 0;
    },10);
}

1;