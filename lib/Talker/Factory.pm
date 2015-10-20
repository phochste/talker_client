package Talker::Factory;

use Moo::Role;
use Module::Path qw[ module_path ];
use Module::Runtime qw[ use_module compose_module_name ];
use Log::Any;
use namespace::clean;

sub factory {
    my ($self,$prefix,$req) = (shift,shift,shift);

    my $logger = Log::Any->get_logger(category => ref($self));

    $logger->info("composing $prefix $req");
    my $module = compose_module_name($prefix,$req);

    unless (defined module_path($module)) {
        $logger->error("unknown $prefix ($req => $module)");
        return undef;
    }

    my $inst;

    $logger->debug("creating new $module");
    eval {
        $inst = use_module($module)->new(@_);
    };
    if ($@) {
        $logger->error("failed to create new $module instance");
        return undef;
    }

    $logger->debug("got a $inst");
    
    $inst;
}

1;