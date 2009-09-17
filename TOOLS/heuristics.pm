package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;

use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Document;


#jump table for parsers for each categroy

my %parsers = ("Earnings per share" => \&parser_eps, "Calendar dates" => \&parser_dates,
    "Total Assets" => \&parser_assets);

#workaround for bug in this package
Algorithm::NaiveBayes->new();
$keymod = AI::Categorizer::Learner::NaiveBayes->restore_state('keys.sav');


#an array of tokens created by secbot, and
#a hash of hashes, indexed by category of token,
#and then it's offset in the array, with the value 
#being the score returned by the bayesian recognizer

my @token_list;
my %hitmap;

$sql_hash;

sub add_token {

    my $token = shift;
    if($token =~ /\s+/c) {
	
	#delete extraneous spacing
	$token  =~ s/^\s+//;
	$token =~ s/\s+$//;
	$token =~ s/\s{2,}/ /g;
	$token =~ s/\$\s/\$/g;
	$token =~ s/\(\s+/\(/g;
	$token =~ s/\s+\)/\)/g;
	$token =~ s/://g;

	if($token =~ /.*[A-Za-z].*/) {
	    push @token_list, $token;
	} else {

	    foreach (split /\s/, $token) {
		$_ =~ s/\,//g;
		$_ =~ s/\(/-/;
		$_ =~ s/\)//;
		$_ =~ s/\$//;
		push @token_list, $_;
	    }
	}
    }
}

sub clear {
    @token_list = ();
    %hitmap = ();
}

sub add_potential_hit {

    my $cat = shift;
    my $score = shift;
    my $offset = $#token_list;

    $hitmap{$cat}->{$offset} = $score;
}

sub parse_keys {

    my $cont = shift;
    my $doc = new AI::Categorizer::Document(content => $cont);
    $hypth = $keymod->categorize($doc);

    $cat = $hypth->best_category;
    heuristics::add_potential_hit($cat, $hypth->scores($cat));

    if($main::dumpkeys) {
	print "\n$cont\t($cat  score " . $hypth->scores($cat) .")";
    }
}

sub find_best_matches {

    my $cat = shift;

#    search_assets();

#    foreach $category (keys %hitmap) {
#
#	$temp = $hitmap{$category};
#	if(exists $parsers{$category}) {
#	    $parsers{$category}->($temp, $category);
#	}
#    }
}

sub parser_dates {

    my $off = shift;
}

sub search_assets {

    my $off = forward_token_search("total assets", 0, "liabilities");
    if($off < 0) {
	print "\nmiss, looking for TOTAL";
	$off = forward_token_search("total", 0, "liabilities");
	if($off < 0) {
	    return;
	}
    }

    if($token_list[$off + 1] !~ /.*[A-Z]+.*/i) {
	$sql_hash->{total_assets} = $token_list[$off + 1];
    }

    print "\nafter forward search it is $sql_hash->{total_assets}";
}

sub parser_assets {

    my $asslist = shift;

     foreach(keys %$asslist) {
	if($token_list[$_] =~ /total assets/i) {
	    $sql_hash->{total_assets} = $token_list[$_ + 1];
	    return;
	}
    }

#    $tindex = forward_token_search("total", 0, "liabilities");
#    if($tindex > 0 && $token_list[$tindex + 1] !~ /[A-Z]+/i) {
#	print "\nmatch on forward token search";
#	$sql_hash->{total_assets} = $token_list[$tindex + 1];
#    }


    if(! exists $sql_hash->{total_assets}) {
	dump_category($asslist, shift);
    }
}

sub parser_eps {

    my $epstokens = shift;

    #delete tokens not matching text heuristics
    foreach my $off (keys %$epstokens) {

	if($token_list[$off] !~ /.*per.*share.*/i && $token_list[$off] !~ /.*(basic|diluted).*/i) {
	    delete $epstokens->{$off};
	    next;
	} 
    }


	#if($token_list[$off + 1] !~ /\$\-*[0-9]*\.[0-9]+/) {
}


sub forward_token_search {

    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for($i = $start; $i <= $#token_list; $i++) {
	return $i if $token_list[$i] =~ /$searchval/i;
	last if $token_list[$i] =~ /.*$endval.*/i;
    }

    return -1;
}


sub dump_category {

    my $cat = shift;
    my $name = shift;
    open ERRFILE, ">>secbot.log";

    print ERRFILE "CATEGORY: $name\n";
    foreach (keys %$cat) {
	print ERRFILE "$token_list[$_] $token_list[$_ + 1]  score: $cat->{$_}\n";
    }
    print ERRFILE "\n";

    close ERRFILE;
}


1;
