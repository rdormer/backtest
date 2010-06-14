#! /usr/bin/perl

use CGI;

my $cgi = new CGI;
my $handle = "/tmp/" . int(rand(100000)) . ".txt";
my $cmd = make_command($handle);

chdir("../../");
system("$cmd &");
sleep(1);

print $cgi->start_html();

open INFILE, $handle;
print <INFILE>;
close INFILE;

print $cgi->end_html();


sub make_command {

    my $command = "./backtest.pl ";
    $command .= "-list TESTS/list4 ";
    $command .= "-start " . $cgi->param("start") . " ";
    $command .= "-finish " . $cgi->param("end") . " ";
    $command .= "--skip-progress --cgi-handle=" . shift . " ";

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
