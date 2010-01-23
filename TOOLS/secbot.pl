#! /usr/bin/perl

use heuristics;

use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Document;
use HTML::TreeBuilder;
use Getopt::Long;
use Net::FTP;
use DBI;

my $FILE_SIZE_CUTOFF = 5000000;

my $dataroot, $dumpchunks, $datafile, $dumpsql, $spiderwait;
my $skipexisting, $skipdownload, $skipdb, $dumpfin;
my $start_year = `date "+%Y"`;
my $end_year = $start_year;
my $start_qtr = 1, $end_qtr = 4;
$dumpkeys;

GetOptions('dataroot=s' => \$dataroot, 'startyear=i' => \$start_year, 'endyear=i' => \$end_year, 
	   'skipexisting' => \$skipexisting, 'skipindex' => \$skipdownload, 
	   'dumpchunks' => \$dumpchunks, 'skipdb' => \$skipdb, 'start-quarter=i' => \$start_qtr, 
	   'end-quarter=i' => \$end_qtr, 'datafile=s' => \$datafile, 'dumpfinancials' => \$dumpfin,
	   'dumptuples' => \$dumptuples, 'dumpsql' => \$dumpsql, 'spider-wait=s' => \$spiderwait);

my $database = DBI->connect("DBI:mysql:finance", "perldb") or die "couldn't open database" if not $skipdb;

#workaround for bug in this package
Algorithm::NaiveBayes->new();
my $c = AI::Categorizer::Learner::NaiveBayes->restore_state('model.sav');

if($dataroot ne "") {
    chdir $dataroot;
    unlink("secbot.log");
}

if($datafile) {
    process_data_file($datafile);
    exit(0);
}

print "\nConnecting to SEC server...";
$ftpbot = Net::FTP->new("ftp.sec.gov") or die "CONNECT FAIL";
$ftpbot->login("anonymous", "password") or die "LOGIN FAIL";
print "OK";


for(my $year = $start_year; $year <= $end_year; $year++) {
    for(my $quarter = $start_qtr; $quarter <= $end_qtr; $quarter++) {
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

    if(not $skipdownload) { 
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

	print "\nprocess $fname";

	if(not -e $fname) {
	    sleep($spiderwait) if $spiderwait > 0;
	    print "\nFetch $fields[4]\t[ $fields[1] ]";	
	    $ftpbot->get("/" . $fields[4]) or print "\n" . $ftpbot->message;
	    
	} elsif ($skipexisting) {
	    return;
	}

	process_data_file($fname);
    } 
}


sub process_data_file {

    my $file = shift;
    my %sql_vals;

    print "\nfile does not exist!\n" if ! -e $file;
    return if -s $file > $FILE_SIZE_CUTOFF;

    $sql_vals{sec_file} = $file;
    $heuristics::sql_hash = \%sql_vals;

    my $tenq = get_text($file);
    parse_sec_header($tenq, \%sql_vals);
    categorize_chunks($tenq);
    write_sql(\%sql_vals);
}

#open up file, read it, set up tree, and kick off recursive parse

sub get_text {

    local($/, *RAWFILE);
    open RAWFILE, shift;
    my $raw = <RAWFILE>;

    my $parser = HTML::TreeBuilder->new;
    $parser->parse_content($raw);
    $parser->elementify();
    my $ptext = extract_text($parser);

    $parser->delete;
    return $ptext;
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
	    
	    if($hypth->best_category ne "boilerplate") {
		process_financials($_, $hypth->best_category);
	    }
	}
    }

    heuristics::finish_sweep();
}

sub process_financials {

    my $chunk = shift;
    my $category = shift;
    my $wantchars = 0;
    my $token;

    $chunk =~ tr/[A-Za-z0-9,().\-%:$\/\\;]/ /c;
    @tuples = split /\s/, $chunk;
    heuristics::clear();

    if($dumpfin) {
	print "\n\n======!!!!+++=======\n($category)\n$chunk\n";
    }

    foreach $tuple (@tuples) {

	if($tuple eq "") {
	    next;
	}

	if($tuple =~ /[A-Z]/i) {

	    if( ! $wantchars) {
		heuristics::add_token($token);
		$token = $tuple;
		$wantchars = 1;
		next;
	    }

	} else {

	    if($wantchars) {
		heuristics::add_token($token);
		$token = $tuple;
		$wantchars = 0;
		next;
	    }
	}

	$token .= " $tuple";
    }

    heuristics::find_best_matches($category);
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

    if($raw =~ /.*STANDARD INDUSTRIAL CLASSIFICATION:\s+(\D+)?\[([0-9]+)\].*/) {

	$sql->{sic_code} = $2;

	#has to come after to avoid overwriting $2
	my $industry = $1;
	$industry =~ s/'/\\'/g;
	$sql->{sec_industry} = $industry;
    }

    if($raw =~ /.*CENTRAL INDEX KEY:\s+([0-9]+).*/) {
	$sql->{cik} = $1;
    }
    
}

sub write_sql {

    if(! $skipdb) {
	
	my $vals = shift;
	
        my $error = heuristics::do_sanity_check();
	if(length $error > 0) {
	    update_log($vals, $error);
	    return;
	}

$heresql = <<DONE;
	insert into fundamentals (date, sec_file, sec_name, sec_industry, sic_code, cik, total_assets, 
	current_assets, total_debt, current_debt, cash, equity, net_income, revenue, avg_shares_basic, 
	avg_shares_diluted, eps_basic, eps_diluted) values ($vals->{date}, '$vals->{sec_file}', 
        '$vals->{sec_name}', '$vals->{sec_industry}', $vals->{sic_code}, '$vals->{cik}', $vals->{total_assets}, 
        $vals->{current_assets}, $vals->{total_liabilities}, $vals->{current_liabilities}, $vals->{cash}, 
        $vals->{total_equity}, $vals->{net_income}, $vals->{revenue}, $vals->{avg_shares_basic}, 
        $vals->{avg_shares_diluted}, $vals->{basic_eps}, $vals->{diluted_eps});
DONE

	if($dumpsql) {
	    print "\n\n$heresql\n\n";
	}

	$put_sql = $database->prepare($heresql) or update_log($vals);
	$put_sql->execute() or update_log($vals);
    }
}


sub update_log {

    my $dbgvals = shift;
    my $errstring = shift;
    open ERRORFILE, ">>secbot.log";

    print ERRORFILE "\n$errstring\n\n";
    
    foreach (keys %$dbgvals) {
	print ERRORFILE "$_ = $dbgvals->{$_}\n";
    }

    print ERRORFILE "================\n";
    close ERRORFILE;
}
