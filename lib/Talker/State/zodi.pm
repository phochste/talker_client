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

        if ($buffer =~ /^From .* you can .* to the ([^\.]+)/) {
            my $match = $1;
            $match =~ s{[\[\]\r\n]+}{};

            $self->talker->state->exits( [split(/\s*,\s*/,$match)] );

            return 1;
        }

        return 0;
    },10);
}

sub update_area {
    my ($self) = @_;

    my $area = $self->talker->state->area // "";
    $self->talker->state->area($area);

    $self->log->debug("updating area");

    $self->talker->write_string(".go\n");
    $self->talker->read_while(sub {
        my $line = shift;

        if ($line =~ /^From (.*) you can/) {
            $self->talker->state->area($1);
            return 1;
        }

        return 0;
    },10);
}

sub update_area_users {
    my ($self) = @_;

    $self->talker->state->area_users([]);

    $self->log->debug("updating area_users");

    $self->talker->write_string(".with\n");
    $self->talker->read_while(sub {
        my ($x,$buffer) = @_;

        if ($buffer =~ /^You can see (.*)\./) {
            my $match = $1;
            $match =~ s{[\[\]\r\n]+}{};

            $self->talker->state->area_users( [split(/\s*,\s*/,$match)] );

            return 1;
        }
        elsif ($buffer =~ /^You appear/) {
            return 0;
        }

        return 0;
    },10);
}

1;