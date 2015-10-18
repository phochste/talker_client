package Talker::Action::new_login;

use Moo;

with 'Talker::Action';

has talker => (is => 'ro', required => 1);

our @greeting = (
        "Prr... ",
        "Iauww ! ",
        "Hehehe there is ",
        "Meow ? iauw iaw ",
        "Waf waf waf waf waf ",
        "Mo vint toch, ",
        "Meow :), ",
        "Iauhoi ",
        "Mmrrrrrauuuauauw ",
        "!! ",
        "Iauuawww Q ",
        "Yo iauw ",
        "Prrr iaw ",
        "Hee meowke "
        );

sub run {
    my ($self, $buffer) = @_;

    if ($buffer =~ /WALKING into [^:]+: (\w+)/) {
    	my $name = $1;
    	my $char = substr($name,-1,1);

    	my $text = $greeting[rand(@greeting)];

    	if    ($char =~ /[abdegijosu]/ )    { $text .= $name . "ke\n";  }
        elsif ($char =~ /[chkq]/)           { $text .= $name . "ske\n";  }
        elsif ($char =~ /[f]/)              { $text .= $name . "eneke\n"; }
        elsif ($char =~ /[lmnprtvwxyz]/)    { $text .= $name . "eke\n";  }

        sleep(1);

    	$self->talker->write_string($text);
    }
    elsif ($buffer =~ /\[ ENTERING [^:]+: (\w+)/) {
    	my $name = $1;
    	my $char = substr($name,-1,1);

    	my $text = $greeting[rand(@greeting)];

    	if    ($char =~ /[abdegijosu]/ )    { $text .= $name . "ke\n";  }
        elsif ($char =~ /[chkq]/)           { $text .= $name . "ske\n";  }
        elsif ($char =~ /[f]/)              { $text .= $name . "eneke\n"; }
        elsif ($char =~ /[lmnprtvwxyz]/)    { $text .= $name . "eke\n";  }

        sleep(1);

    	$self->talker->write_string($text);
    }
}

1;
