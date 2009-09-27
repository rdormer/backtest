package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;

use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Document;


#jump table for parsers for each categroy

my %parsers = ("Earnings per share" => \&parser_eps, "Total Liabilities and equity" => \&parser_lae);

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

#    if($token =~ /\s+/c) {
    if($token =~ /.*[A-Za-z0-9]+.*/) {

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

    if($cat eq "balance sheets") {
	search_assets();
#	search_equity();
#	search_liabilities();
#	parser_lae($hitmap{'Total Liabilities and equity'});
    }

    if($cat eq "earnings statements") {
#	search_revenue();
    }

#    foreach $category (keys %hitmap) {

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
#	print "\nmiss, looking for TOTAL";
	$off = forward_token_search("total", 0, "liabilities");
	if($off < 0) {
	    return;
	} else {
	    print "\nHIT ON SECOND";
	}
    }

    #do not permit more than one value for this.  Some orgs
    #include subsidiary reports in their statements, some 
    #statements contain re-statements of earlier data.  Either way,
    #we don't need it, we assume the first value is the proper value

    if($token_list[$off + 1] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{total_assets}) {
	$sql_hash->{total_assets} = $token_list[$off + 1];
    }

    print "\nafter forward search assets is $sql_hash->{total_assets}";
}


sub search_revenue {

    my $off = forward_token_search("total revenue", 0, "liabilities");
    if($off < 0) {
#	print "\nmiss, looking for TOTAL";
	$off = forward_token_search("total", 0, "liabilities");
	if($off < 0) {
	    return;
	} else {
	    print "\nHIT ON SECOND";
	}
    }

    if($token_list[$off + 1] !~ /.*[A-Z]+.*/i) {
	$sql_hash->{total_revenue} = $token_list[$off + 1];
    }

    print "\nafter forward search revenues is $sql_hash->{total_revenue}";

#    if(! exists $sql_hash->{total_assets}) {
#	dump_category($asslist, shift);
#    }
}

sub search_liabilities {

    my $off = backward_token_search("total liabilities", $#token_list, "assets");
    if($off < 0) {
	print "\nmiss, looking for TOTAL";
	$off = backward_token_search("total", $#token_list, "assets");
	if($off < 0) {
	    return;
	}
    }

    if($token_list[$off + 1] !~ /.*[A-Z]+.*/i) {
	$sql_hash->{total_liabilities} = $token_list[$off + 1];
    }

    print "\nafter forward search liabilities is $sql_hash->{total_liabilities}";

#    if(! exists $sql_hash->{total_assets}) {
#	dump_category($asslist, shift);
#    }
}


sub search_equity {

    my $off = backward_token_search("total equity", $#token_list, "assets");
    if($off < 0) {
	$off = backward_token_search("total stockholders equity", $#token_list, "assets");
	if($off < 0) {
	    return;
	}
    }

    if($token_list[$off + 1] !~ /.*[A-Z]+.*/i) {
	$sql_hash->{total_equity} = $token_list[$off + 1];
    }

    print "\nafter backward search equity is $sql_hash->{total_equity}";

#    if(! exists $sql_hash->{total_assets}) {
#	dump_category($asslist, shift);
#    }
}


sub parser_lae {

    my $cathash = shift;
    

}

sub forward_token_search {

    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for($i = $start; $i <= $#token_list; $i++) {
#	print "\n$trying ----$token_list[$i]---";
	return $i if lc($token_list[$i]) eq lc($searchval);
	last if $token_list[$i] =~ /.*$endval.*/i;
    }

    return -1;
}


sub backward_token_search {

    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for($i = $start; $i >= 0; $i--) {
#	print "\n$trying ----$token_list[$i]---";
	return $i if lc($token_list[$i]) eq lc($searchval);
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
