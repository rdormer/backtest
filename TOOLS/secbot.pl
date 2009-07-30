#! /usr/bin/perl

use HTML::TreeBuilder;
use Getopt::Long;
use Net::FTP;

my $dataroot;
my $skipunzip;
my $skipexisting;
my $start_year = `date "+%Y"`;
my $end_year = $start_year;

GetOptions('dataroot=s' => \$dataroot, 'skipgzip' => \$skipunzip, 'startyear=i' => \$start_year,
    'endyear=i' => \$end_year, 'skipexisting' => \$skipexisting);

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

	if($fields[2] eq "10-Q") {

	    if(not -e $fname) {
		print "\nFetch $fields[4]\t[ $fields[1] ]";	
		$ftpbot->get("/" . $fields[4]) or print "\n" . $ftpbot->message;
	    
	    } elsif ($skipexisting) {
		next;
	    }

	    get_text($fname);
	} 
    }
}

#open up file, read it, set up tree, and kick off recursive parse

sub get_text {

    local($/, *RAWFILE);
    open RAWFILE, shift;
    my $raw = <RAWFILE>;

    my $parser = HTML::TreeBuilder->new;
    $parser->parse_content($raw);
    $parser->elementify();

    return extract_text($parser);
}

#recursive extraction of text from HTML parse tree

sub extract_text {

    my $parse_tree = shift;
    my $page_text;

    foreach my $c ($parse_tree->content_list) {
	if(!ref $c) {
	    $page_text .= " $c";
	} else {
	    $page_text .= extract_text($c);
	}
    }

    return $page_text;
}
