#!/usr/bin/env perl
# Patrick Hochstenbach <Patrick dot Hochstenbach at UGent dot be>
# (c)2015
$| = 1;

use lib qw(./lib);

use Talker::Action::random_action;
use Talker::Client;
use Getopt::Long;
use FindBin ();
use Config::Onion;
use File::Basename ();
use File::Spec::Functions qw(catfile);
use Log::Any::Adapter;
use Log::Log4perl;

my @argv      = @ARGV;

Log::Any::Adapter->set('Log4perl');
Log::Log4perl::init('./log4perl.conf');

my $config    = load_config();
my $logger    = Log::Log4perl->get_logger('talker_client');
my $script    = File::Basename::basename($0);
my $SELF      = catfile($FindBin::Bin, $script);

$SIG{HUP} =  sub {
      $logger->warn("got SIGHUP");
      exec($SELF, @argv) || die "$0: couldn't restart $SELF: $!";
};

my ($host,$port,$user,$password,$relogin,$background);

GetOptions(
    "host=s"     => \$host, 
    "port=i"     => \$port , 
    "user=s"     => \$user , 
    "password=s" => \$password, 
    "relogin"    => \$relogin,
    "background" => \$background,
);

my $talker    = shift;

usage() unless defined($talker);

die "no such talker: $talker" unless exists $config->{talker}->{$talker};

background() if $background;

if ($relogin) {
    while (1) {
        eval {
            $logger->info("enter run loop");
            run();
        };
        if ($@) {
            $logger->warn("caught: $@");
            $logger->warn("sleeping 300 seconds");
            sleep(300);
        }
    }
}
else {
    $logger->info("enter run loop");
    run();
}

sub run {
    my $x = Talker::Client->new(
            host           => $host     // $config->{talker}->{$talker}->{host},
            port           => $port     // $config->{talker}->{$talker}->{port},
            user           => $user     // $config->{talker}->{$talker}->{user},
            password       => $password // $config->{talker}->{$talker}->{password},
            name_regex     => $config->{login}->{name_regex} ,
            password_regex => $config->{login}->{password_regex} ,
    );

    $x->login;

    while (1) {
        $logger->info("re-loading configuration");
        $config = load_config();
        $x->run($config->{actions}, timeout => 60);

        my $action = Talker::Action::random_action->new(talker => $x);
        $logger->info("..executing $action");
        $action->run("");
    }

    $x->logout;
}

sub background {
    fork && exit(0);
}

sub load_config {
    my @config_dirs = ".";
    my @globs = map { 
            my $dir = $_;
            map { File::Spec->catfile($dir, "catmandu*.$_") } qw(yaml yml json pl) 
        }
        reverse @config_dirs;
 
    my $config = Config::Onion->new(prefix_key => '_prefix');
    $config->load_glob(@globs);
    $config->get;
}

sub usage {
    print STDERR <<EOF;
usage: $0 [options] talker

options:
    --host=...
    --port=...
    --user=...
    --password=...
    --relogin
    --background

EOF
    exit(1);
}

