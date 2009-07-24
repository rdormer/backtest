#! /usr/bin/perl

use Getopt::Long;
use Net::FTP;

my $dataroot;
GetOptions('dataroot=s' => \$dataroot);

if($dataroot ne "") {
    chdir $dataroot;
}

print "\nConnecting to SEC server...";
$ftpbot = Net::FTP->new("ftp.sec.gov") or die "CONNECT FAIL";
$ftpbot->login("anonymous", "password") or die "LOGIN FAIL";
print "OK";



for(my $quarter = 1; $quarter <= 4; $quarter++) {

    fetch_quarter(2008, $quarter);
}






sub fetch_quarter {

    my $fiscal_year = shift;
    my $fiscal_quarter = shift;
    my $index_name = "master-$fiscal_year-$fiscal_quarter.gz";

    #first step is to retrieve the index file
    #and unzip it

    if(not -e $index_name) {
	print "\nRetrieve Index...";
	$ftpbot->binary();
	$ftpbot->cwd("/edgar/full-index/$fiscal_year/QTR$fiscal_quarter") or die "CWD FAIL";
	$ftpbot->get("master.gz", "$index_name") or die "GET FAIL";
	print "OK"; 
    }

    `gunzip -c $index_name > index.txt`;

    $ftpbot->ascii();
    open INDEX, "index.txt";

    #for each entry in the index download the data file for 
    #that entry if it's a quarterly report

    foreach $filing (<INDEX>) {

	chomp $filing;
	@fields = split /\|/, $filing;
	$fname = substr $fields[4], rindex($fields[4], "/") + 1;

	if($fields[2] eq "10-Q" && not -e $fname) {

	    print "\nFetch $fields[4]";	
	    $ftpbot->get("/" . $fields[4]) or print "\n" . $ftpbot->message;
	} 
    }
}
