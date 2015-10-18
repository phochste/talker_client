package Talker::Client;

use Moo;
use Catmandu;
use Catmandu::Util qw(:is);
use IO::Socket;
use IO::Select;
use POSIX;
use Carp;

with 'Catmandu::Logger';

has host           => (is => 'ro', required => 1);
has port           => (is => 'ro', required => 1);
has user           => (is => 'ro', required => 1);
has password       => (is => 'ro', required => 1);
has name_regex     => (is => 'ro', required => 1);
has password_regex => (is => 'ro', required => 1);

has state          => (is => 'rw');

has last_talk_time => (is => 'rw', default => sub { time; });
has socket   => (is => 'lazy');

sub _build_socket {
    my ($self) = @_;

    my $host   = $self->host;
    my $port   = $self->port;

    $self->log->info("connecting to $host:$port");

    my $socket = new IO::Socket::INET (
            PeerAddr  => $host,
            PeerPort  => $port,
            Proto     => 'tcp'
            );

    die "Read socket could not be created. Reason: $!\n" unless ($socket);

    $self->log->info("connected");

    fcntl($socket, F_SETFL(), O_NONBLOCK());

    $socket;
}

sub login {
    my ($self) = @_;

    my $name           = $self->user;
    my $password       = $self->password;
    my $name_regex     = $self->name_regex;
    my $password_regex = $self->password_regex;

    $self->log->info("logging in $name");
    $self->log->debug("password $password");

    $name         .= "\n";
    $password     .= "\n";

    $self->log->info("scanning for login prompt");
    $self->read_while(
        $self->search_string(@$name_regex)
    );
    
    $self->log->info("send $name");
    $self->write_string($name);

    $self->log->info("scanning for password prompt");
    $self->read_while(
        $self->search_string(@$password_regex)
    );

    $self->log->info("send password");
    $self->write_string($password);
}

sub logout {
    my ($self) = @_;
    close($self->socket);
}

##
# Read data until the reference to the function returns a integer higher than 0
# ReadUntilFunctionTrue returns a reference to an array :
#
#       array[0] = data on which the function reacted
#               array[1] = return value of the function
#
sub read_while {
    my  ($self,$func,$timeout) = @_;

    croak "read_while needs subroutine" unless $func;

    my $read_handles  = new IO::Select($self->socket);
    my $write_handles = new IO::Select($self->socket);

    my $buf = '';
    my $ret;

    $self->log->info("entering read_while loop");

    while (1) {
        my ($read_ready) = $read_handles->can_read($timeout);

        unless (defined($read_ready) && $timeout) {
            $self->log->info("timeout $timeout reached");
            return undef;
        }

        my $bytes_read   = sysread($self->socket,$buf,1024);

        if (defined($bytes_read)) {
            if ($bytes_read == 0) {
                $self->log->info("connection closed");
                die "Connection closed";
            }

            if ($bytes_read > 0) {
                $self->log->info("read " . length($buf) . " bytes");
                if (($ret = $func->($buf)) > 0) { return [$buf,$ret]; }
            }
        }
    }
}

#
# WriteString waits until the socket is free for writing and writes
# data on the socket
#
sub write_string {
    my  ($self,$string) = @_;
    my  ($sock,$read_ready,$write_ready);
    my  $bytes_read;
    my  $buf;

    my $read_handles  = new IO::Select($self->socket);
    my $write_handles = new IO::Select($self->socket);

    $self->last_talk_time(time);

    while (1) {
        ($read_ready,$write_ready) =
            IO::Select->select($read_handles,$write_handles,undef);

        foreach $sock (@$read_ready) {
            $bytes_read = sysread($self->socket,$buf,1024);

            if (defined($bytes_read)) {
                if ($bytes_read == 0) {
                    die "Connection closed";
                }
            }
        }

        foreach $sock (@$write_ready) {
            syswrite($self->socket,$string,length($string));
            return ;
        }
    }
}

##
# Returns a function that can search for strings
#
# my $sub = $self->search_string('AA','BB');
# if ($sub->('Text')) {
#   warn "Found something";    
# }
sub search_string {
    my ($self,@needle_array) = @_;

    $self->log->debug("searching for: " . join("/",@needle_array));

    return sub {
        my  ($haystack) = @_;

        for my $line (split(/\n/,$haystack)) {
            $self->log->debug("scanning: $line");
            foreach my $needle (@needle_array) {
                return 1 if ($line =~ /$needle/);
            }
        }

        return 0;
    }
}

#
# run an event loop
#
# options:
#       timeout: number of seconds to wait
sub run {
    my ($self,$actions, %options) = @_;

    $self->log->info("entering run loop");
    while(1) {   
        my $ret = $self->read_while(sub {
            my $line = shift;
            chop($line);
            $line =~ s{\033\[\w+}{}g;

            return 1 unless (length($line) && $line =~ /\S/);

            $self->log->debug("scanning: $line");
            $self->log->debug("raw: " . join(",",unpack("H*",$line)));

            my $action = $self->find_action($actions,$line);

            if (defined $action) {
                eval {
                    my $pkg = Catmandu::Util::require_package($action,'Talker::Action');
                    $self->log->info("..executing $pkg");
                    my $act = $pkg->new(talker => $self);
                    my $ret = $act->run($line);
                };

                if ($@) {
                    $self->log->error($@);
                }
            }

            1;
        }, $options{timeout});

        last if $options{timeout} && ! defined($ret);
    }

    $self->log->info("exit run loop");
    1;
}

sub find_action {
    my ($self,$actions,$line) = @_;

    for my $pair (@$actions) {
        my $regex  = [keys %$pair]->[0];
        my $action = $pair->{$regex};

        $self->log->debug("[~] /$regex/");

        if ($line =~ /$regex/) {
            $self->log->debug("+ found match");

            if (is_array_ref($action)) {
                return $self->find_action($action,$line);
            }
            else {
                return $action;
            }
        }
        else {
            $self->log->debug("- found match");
        }
    }

    return undef;
}

1;
