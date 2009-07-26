#! /usr/bin/perl

use Getopt::Long;
use Net::FTP;

my $dataroot;
my $skipunzip;
my $start_year = `date "+%Y"`;
my $end_year = $start_year;

GetOptions('dataroot=s' => \$dataroot, 'skipgzip' => \$skipunzip, 'startyear=i' => \$start_year,
    'endyear=i' => \$end_year);

if($dataroot ne "") {
    chdir $dataroot;
}

print "\nConnecting to SEC server...";
$ftpbot = Net::FTP->new("ftp.sec.gov") or die "CONNECT FAIL";
$ftpbot->login("anonymous", "password") or die "LOGIN FAIL";
print "OK";


for(my $year = $start_year; $year <= $end_year; $year++) {
    for(my $quarter = 1; $quarter <= 4; $quarter++) {
	fetch_quarter($year, $quarter);
    }
}





sub fetch_quarter {

    my $fiscal_year = shift;
    my $fiscal_quarter = shift;
    my $index_name = "master-$fiscal_year-$fiscal_quarter.gz";

    print "\ndownloading for $fiscal_year quarter $fiscal_quarter";

    #first step is to retrieve the index file
    #and unzip it

    if(not -e $index_name) {
	print "\nRetrieve Index...";
	$ftpbot->binary();
	$ftpbot->cwd("/edgar/full-index/$fiscal_year/QTR$fiscal_quarter") or die "CWD FAIL";
	$ftpbot->get("master.gz", "$index_name") or die "GET FAIL";
	print "OK"; 
    }

    if(not $skipunzip) { 
	print "\nunzip index file";
	`gunzip -c $index_name > index.txt`;
    }

    $ftpbot->ascii();
    open INDEX, "index.txt";

    #for each entry in the index download the data file for 
    #that entry if it's a quarterly report

    foreach $filing (<INDEX>) {

	chomp $filing;
	@fields = split /\|/, $filing;
	$fname = substr $fields[4], rindex($fields[4], "/") + 1;

	if($fields[2] eq "10-Q" && not -e $fname) {

	    print "\nFetch $fields[4]\t[ $fields[1] ]";	
	    $ftpbot->get("/" . $fields[4]) or print "\n" . $ftpbot->message;
	} 
    }
}
