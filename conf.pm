package conf;
require Exporter;
use Getopt::Long;

use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;
my $start_time;

$~ = 'HELPTEXT';

sub process_commandline {

    if(@_ == 0) {
	write;
	exit();
    }

    $start_time = time();

    GetOptions('date=s' => \$date, 'screen=s' => \$screenfile, 'list=s' => \$tickers, 'entry=s' => \$entryfile,
	'exit=s' => \$exitfile, 'start=s' => \$startdate, 'finish=s' => \$enddate, 'replay=s' => \$replay_list,
	'short-entry=s' => \$short_entry, 'short-exit=s' => \$short_exit, 'showreward' => \$showreward, 
	'init-margin=s' => \$initial_margin, 'maint-margin' => \$maint_margin, 'portfolio=s' => \$portfolio,
	'strategy=s' => \$strategy, 'start-with=s' => \$startwith, 'risk=s' => \$risk, 'curve' => \$curve,
	'connect-string=s' => \$connect_string, 'connect-user=s' => \$connect_user, 
	'skip-progress' => \$skip_progress, 'nocache' => \$disable_cache, 'skip-trades' => \$skip_trades,
	'tickers=s' => \$tickerlist, 'cgi-handle=s' => \$cgi_handle, 'timer' => \$use_timer);

    die "Couldn't open $tickers" if (! $tickerlist && ! -e $tickers);
    die "Couldn't open $screenfile" if $screenfile && ! -e $screenfile;
    die "Couldn't open $short_entry" if $short_entry && ! -e $short_entry;
    die "Couldn't open $replay_list" if $replay_list && ! -e $replay_list;
    die "Coudln't open $short_exit" if $short_exit && ! -e $short_exit;
    die "Couldn't open $entryfile" if $entryfile && ! -e $entryfile;
    die "Couldn't open $exitfile" if $exitfile && ! -e $exitfile;
}

sub date { return $date; }
sub screen { return $screenfile; }
sub list { return $tickers; }
sub enter_sig { return $entryfile; }
sub exit_sig { return $exitfile; }
sub start { return $startdate; }
sub finish { return $enddate; }
sub replay_list { return $replay_list; }
sub short_enter_sig { return $short_entry; }
sub short_exit_sig { return $short_exit; }
sub long_positions { return $entryfile || $exitfile; }
sub short_positions { return $short_entry || $short_exit; }
sub show_reward_ratio { return $showreward; }
sub noprogress { return $skip_progress; }
sub draw_curve { return $curve; }
sub usecache { return not $disable_cache; }
sub show_trades { return not $skip_trades; }
sub ticker_list { return $tickerlist; }
sub cgi_handle { return $cgi_handle; }
sub timer { return $use_timer; }

sub connect_string {
    return $connect_string if $connect_string;
    return "DBI:mysql:finance";
}

sub connect_user {
    return $connect_user if $connect_user;
    return "perldb";
}

sub initial_margin {
    return $initial_margin if $initial_margin;
    return 0.5;
}

sub maint_margin {
    return $maint_margin if $maint_margin;
    return 0.3;
}

sub portfolio { 
    return $portfolio if $portfolio;
    return "portfolio";
}

sub strategy { 
    return $strategy if $strategy;
    return "default";
}

sub startwith {

    return $startwith if $startwith;
    return 5000;
}

sub risk_percent {

    return ($risk / 100) if $risk;
    return 0.01;
}

sub check_backtest_args {

    die "Are you trying to go short, or long?  Arguments are inconclusive" if $exitfile and $short_entry;
    die "Are you trying to go short, or long?  Arguments are inconclusive" if $entryfile and $short_exit;
    die "You are using the same entry and exit" if $exitfile eq $entryfile;

    die "missing -list (ticker list file)" if not $tickers and not $tickerlist;
    die "missing -start (start date)" if not $startdate;
    die "missing -entry (entry signal)" if not $entryfile and long_positions();
    die "missing -exit (exit signal)" if not $exitfile and long_positions();
    die "missing -short-exit (exit signal)" if not $short_exit and $short_entry and short_positions();
    die "missing -short-entry (entry signal)" if not $short_entry and $short_exit and short_positions();
}

sub override_date_range {

    $startdate = shift;
    $enddate = shift;
}

sub elapsed_time {
    return time() - $start_time;
}

format HELPTEXT =

OPTIONS FOR BACKTESTER:

   -list <ticker list file>
   -start <starting date in YYYY-MM-DD>
   -finish <end date in YYYY-MM-DD>
   -entry <rule file>
   -exit <rule file>
   -short-exit <rule file>
   -short-entry <rule file>


OPTIONS FOR SCREENER:

   -list <ticker list file>
   -screen <rule file>
   -date <screen date in YYYY-MM-DD>
   

AVAILABLE INDICATORS:
  

   Relative Strength Index      RSI<period>
   Bollinger Bands              BOLLINGER_UPPER | BOLLINGER_LOWER<period>,<deviations>
   Average True Range           ATR<period>
   Williams %R                  WILLIAMS_R<period>
.


1;
