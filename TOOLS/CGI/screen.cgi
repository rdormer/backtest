#! /usr/bin/perl

use CGI;

my $cgi = new CGI;

my $command = "./screen.pl ";
$command .= "-list TESTS/stock_universe.txt ";
$command .= "-screen " . dump_file($cgi->param("screen")) . " ";

my $handle = "/tmp/" . int(rand(100000)) . ".txt";
$command .= "--cgi-handle=$handle ";

chdir("../../");
system("$command &");
sleep(1);

print $cgi->start_html();

open INFILE, $handle;
print <INFILE>;
close INFILE;

print $cgi->end_html();

sub dump_file {

    my $str = shift;

    my $fname = "/tmp/" . int(rand(1000000));
    open OUTFILE, "+>$fname";
    print OUTFILE $str;
    close OUTFILE;

    return $fname;
}
