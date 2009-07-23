#! /usr/bin/perl

use Net::FTP;

print "\nConnecting to SEC server...";
$ftpbot = Net::FTP->new("ftp.sec.gov") or die "CONNECT FAIL";
$ftpbot->login("anonymous", "password") or die "LOGIN FAIL";
print "OK";


#first step is to retrieve the index file

print "\nRetrieve Index...";
$ftpbot->binary();
$ftpbot->cwd("/edgar/full-index") or die "CWD FAIL";
$ftpbot->get("master.gz") or die "GET FAIL";
print "OK"; 