#!/usr/bin/env perl

use lib qw(./lib);
use Talker::Action::random_action;
use Talker::Client;
use Log::Any::Adapter;
use Log::Log4perl;
 
Log::Any::Adapter->set('Log4perl');
Log::Log4perl::init('./log4perl.conf');

my $logger = Log::Log4perl->get_logger('talker_client');
my $talker = shift;

die "usage: $0 talker" unless defined($talker);
die "no such talker: $talker" unless exists Catmandu->config->{talker}->{$talker};

my $x = Talker::Client->new(
        host           => Catmandu->config->{talker}->{$talker}->{host} ,
        port           => Catmandu->config->{talker}->{$talker}->{port} ,
        user           => Catmandu->config->{talker}->{$talker}->{user} ,
        password       => Catmandu->config->{talker}->{$talker}->{password} ,
        name_regex     => Catmandu->config->{login}->{name_regex} ,
        password_regex => Catmandu->config->{login}->{password_regex} ,
);

$x->login;

while (1) {
	$logger->info("re-loading configuration");
	Catmandu->load;
	$x->run(Catmandu->config->{actions}, timeout => 60);

	my $action = Talker::Action::random_action->new(talker => $x);
        $logger->info("..executing $action");
	$action->run("");
}

$x->logout;
