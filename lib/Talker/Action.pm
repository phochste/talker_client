package Talker::Action;

use Moo::Role;
use Log::Any;

requires 'run';

has 'log'    => (is => 'lazy');
 
sub _build_log {
    my ($self) = @_;
    Log::Any->get_logger(category => ref($self));
}

1;