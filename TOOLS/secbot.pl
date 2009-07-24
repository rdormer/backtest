#! /usr/bin/perl

use Getopt::Long;
use Net::FTP;

my $dataroot;
GetOptions('dataroot=s' => \$dataroot);

print "\nConnecting to SEC server...";
$ftpbot = Net::FTP->new("ftp.sec.gov") or die "CONNECT FAIL";
$ftpbot->login("anonymous", "password") or die "LOGIN FAIL";
print "OK";


#first step is to retrieve the index file

if($dataroot ne "") {
    chdir $dataroot;
}

print "\nRetrieve Index...";
$ftpbot->binary();
$ftpbot->cwd("/edgar/full-index") or die "CWD FAIL";
$ftpbot->get("master.gz") or die "GET FAIL";
print "OK"; 

`gunzip --force master.gz`;

$ftpbot->ascii();
open INDEX, "master";

foreach $filing (<INDEX>) {

    chomp $filing;
    @fields = split /\|/, $filing;
    $fname = substr $fields[4], rindex($fields[4], "/") + 1;

    if($fields[2] eq "10-Q" && not -e $fname) {

	print "\nFetch $fields[4]";	
	$ftpbot->get("/" . $fields[4]) or print "\n" . $ftpbot->message;
    } 

    

}
