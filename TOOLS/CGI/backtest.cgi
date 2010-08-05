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
    $command .= "--skip-progress --cgi-handle=" . $handle_file . " ";

    if($cgi->param("tickers")) {
	$command .= "-tickers=" . $cgi->param("tickers") . " ";
    } else {
	$command .= "-list /root/AUTO/stock_universe.txt ";
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
