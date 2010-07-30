#! /usr/bin/perl

use CGI;

my $cgi = new CGI;

my $command = "./screen.pl -nocache ";
$command .= "-list TESTS/stock_universe.txt ";
$command .= "-screen " . dump_file($cgi->param("screen")) . " ";

my $handle = "/tmp/" . int(rand(100000)) . ".txt";
$command .= "--cgi-handle=$handle ";

send_command($command);
sleep(1);

print $cgi->header();

open INFILE, $handle;
print <INFILE>;
close INFILE;

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
