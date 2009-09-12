#! /usr/bin/perl

use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Document;
use HTML::TreeBuilder;
use Getopt::Long;
use Net::FTP;
use DBI;

my $dataroot;
my $skipunzip;
my $dumpchunks;
my $skipexisting;
my $skipdownload;
my $start_year = `date "+%Y"`;
my $end_year = $start_year;

my $database = DBI->connect("DBI:mysql:finance", "perldb") or die "couldn't open database";

GetOptions('dataroot=s' => \$dataroot, 'skipgzip' => \$skipunzip, 'startyear=i' => \$start_year,
    'endyear=i' => \$end_year, 'skipexisting' => \$skipexisting, 'skipdownload' => \$skipdownload,
    'dumpchunks' => \$dumpchunks);

#workaround for bug in this package
Algorithm::NaiveBayes->new();
$c = AI::Categorizer::Learner::NaiveBayes->restore_state('model.sav');

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

    if(not -e $index_name and ! $skipdownload) {
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
	download_filing($filing);
    }
}


sub download_filing {

    @fields = split /\|/, shift;
    $fname = substr $fields[4], rindex($fields[4], "/") + 1;

    if($fields[2] eq "10-Q") {

	if(not -e $fname) {
	    print "\nFetch $fields[4]\t[ $fields[1] ]";	
	    $ftpbot->get("/" . $fields[4]) or print "\n" . $ftpbot->message;
	    
	} elsif ($skipexisting) {
	    return;
	}

	my %sql_vals;
	$sql_vals{sec_file} = $fname;

	my $tenq = get_text($fname);
	parse_sec_header($tenq, \%sql_vals);
	categorize_chunks($tenq, \%sql_vals);
	write_sql(\%sql_vals);
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


sub categorize_chunks {

    my @chunks = split /(Condensed|Consolidated)/i, shift;


    foreach (@chunks) {

	if(length $_ > 300) {

	    if($dumpchunks) {
		print "\n\n\n======!!!!+++=======\n\n\n$_";
	    }

	    my $chunkdoc = AI::Categorizer::Document->new(content => $_);	    
	    $hypth = $c->categorize($chunkdoc);
	    
	    if($hypth->best_category eq "financial statements") {


	    }
	}
    }
}

sub parse_sec_header {

    my $raw = shift;
    my $sql = shift;

    if($raw =~ /.*COMPANY CONFORMED NAME:\s+([A-Z]+.*)\s*CENTRAL INDEX.*/) {
	$sql->{sec_name} = $1;
    }

    if($raw =~ /.*FILED AS OF DATE:\s+([0-9]+).*/) {
	$sql->{date} = $1;
    }

    if($raw =~ /.*STANDARD INDUSTRIAL CLASSIFICATION:\s+(\D+)\[([0-9]+)\].*/) {
	$sql->{sec_industry} = $1;
	$sql->{sic_code} = $2;
    }
}

sub write_sql {

    my $tablevals = shift;

    my $cmd = "insert into fundamentals (date, sec_file, sec_name, sec_industry, sic_code) values";
    $cmd .= "($tablevals->{date}, '$tablevals->{sec_file}', '$tablevals->{sec_name}', '$tablevals->{sec_industry}', $tablevals->{sic_code})";

    $put_sql = $database->prepare($cmd);
    $put_sql->execute();
}
