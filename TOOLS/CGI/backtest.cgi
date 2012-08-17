#! /usr/bin/perl
use CGI;

my $cgi = new CGI;
my $handle = "/tmp/" . int(rand(100000)) . ".txt";
my $cmd = make_command($handle);

send_command($cmd);
print_handle($handle);

sub make_command {

    my $handle_file = shift;

    my $command = "./backtest.pl ";
    $command .= "-start " . $cgi->param("start") . " ";
    $command .= "-finish " . $cgi->param("end") . " ";
    $command .= "--timer --cgi-handle=" . $handle_file . " ";

    if($cgi->param("tickers")) {
	$command .= "-tickers=" . $cgi->param("tickers") . " ";
    } else {

	if($cgi->param("universe")) {
	    $command .= "-list $ENV{TICKER_STATE_PATH}/" . $cgi->param("universe") . ".txt ";
	} else {
	    $command .= "-list $ENV{TICKER_STATE_PATH}/completed.txt ";
	}
    }

    if($cgi->param("entry")) {
	$command .= "-entry " . dump_file($cgi->param("entry")) . " ";
    }

    if($cgi->param("exit")) {
	$command .= "-exit " . dump_file($cgi->param("exit")) . " ";
    }

    if($cgi->param("shortentry")) {
	$command .= "-short-entry " . dump_file($cgi->param("shortentry")) . " ";
    }

    if($cgi->param("shortexit")) {
	$command .= "-short-exit " . dump_file($cgi->param("shortexit")) . " ";
    }

    if($cgi->param("filter")) {
	$command .= "-filter " . dump_file($cgi->param("filter")) . " ";
    }

    if($cgi->param("initstop")) {
	$command .= "-stop " . dump_file($cgi->param("initstop")) . " ";
    }

    if($cgi->param("trailstop")) {
	$command .= "-trail " . dump_file($cgi->param("trailstop")) . " ";
    }

    if($cgi->param("shortfilter")) {
	$command .= "-short-filter " . dump_file($cgi->param("shortfilter")) . " ";
    }

    if($cgi->param("shortinitstop")) {
	$command .= "-short-stop " . dump_file($cgi->param("shortinitstop")) . " ";
    }

    if($cgi->param("shorttrailstop")) {
	$command .= "-short-trail " . dump_file($cgi->param("shorttrailstop")) . " ";
    }

    if($cgi->param("risk")) {
	$command .= "-risk " . $cgi->param("risk") . " ";
    }

    if($cgi->param("startcash")) {
	$command .= "-start-with " . $cgi->param("startcash") . " ";
    }

    if($cgi->param("startmargin")) {
	$command .= "-init-margin " . $cgi->param("startmargin") . " ";
    }

    if($cgi->param("maintmargin")) {
	$command .= "-maint-margin " . $cgi->param("maintmargin") . " ";
    }

    if($cgi->param("benchmark")) {
	$command .= "-benchmark " . $cgi->param("benchmark") . " ";
    }

    if($cgi->param("slip")) {
	$command .= "-slip " . dump_file($cgi->param("slip")) . " ";
    }

    if($cgi->param("randomize")) {
	$command .= "-randomize ";
    }

    if($cgi->param("blacklist")) {
	$command .= "-blacklist=" . $cgi->param("blacklist") . " ";
    }

    return $command;
}


sub dump_file {

    my $str = shift;

    my $fname = "/tmp/" . int(rand(1000000));
    open OUTFILE, "+>$fname";
    print OUTFILE $str;
    close OUTFILE;

    return $fname;
}

sub send_command {

    my $command = shift;

    open QUEUE, "> ./commands";
    print QUEUE $command;
    close QUEUE;

    while(not -e $handle) {
	;
    }
}

sub print_handle {

    my $fhandle = shift;

    print $cgi->header();
    open INFILE, $fhandle;
    print <INFILE>;
    close INFILE;
}
