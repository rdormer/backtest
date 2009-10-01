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
my $datecount;

$sql_hash;

sub add_token {

    my $token = shift;

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

    my $cat = $hypth->best_category;
    add_potential_hit($cat, $hypth->scores($cat));

    if($main::dumpkeys) {
	print "\n$cont\t($cat  score " . $hypth->scores($cat) .")";
    }
}

sub find_best_matches {

    my $cat = shift;

    if($cat eq "balance sheets") {
	search_assets();
	search_liabilities();
    }

#    foreach $category (keys %hitmap) {

#	$temp = $hitmap{$category};
#	if(exists $parsers{$category}) {
#	    $parsers{$category}->($temp, $category);
#	}
#    }
}

sub search_assets {

    my $off = forward_token_search("total assets", 0, "liabilities");
    if($off < 0) {
	$off = forward_token_search("total", 0, "liabilities");
	if($off < 0 && ! exists $sql_hash->{total_assets}) {

	    $off = 0;
	    while($token_list[$off] !~ /.*liabilities.*/i && $off < $#token_list) {
		$off++;
	    }

	    if($token_list[$off - 2] =~ /[0-9]+/) {
		$sql_hash->{total_assets} = $token_list[$off - 2];
		return;
	    }

	    #if we got here, we have a failure to find
	    log_error("couldn't find assets");
	    return;
	} 
    }

    #do not permit more than one value for this.  Some orgs
    #include subsidiary reports in their statements, some 
    #statements contain re-statements of earlier data.  Either way,
    #we don't need it, we assume the first value is the proper value

    if($token_list[$off + 1] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{total_assets}) {
	$sql_hash->{total_assets} = $token_list[$off + 1];
    }
}


sub search_liabilities {

    my $off = backward_token_search("total liabilities", $#token_list, "assets");
    if($off < 0) {
#	print "\nmiss, looking for TOTAL";
	$off = backward_token_search("total", $#token_list, "assets");
	if($off < 0) {
	    log_error("couldn't find total liabilities") if !exists $sql_hash->{total_liabilities};
	    return;
	}
    }

    if($token_list[$off + 1] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{total_liabilities}) {
	$sql_hash->{total_liabilities} = $token_list[$off + 1];
    }

#    print "\nafter forward search liabilities is $sql_hash->{total_liabilities}";
}



sub forward_token_search {

    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for($i = $start; $i <= $#token_list; $i++) {
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
	return $i if lc($token_list[$i]) eq lc($searchval);
	last if $token_list[$i] =~ /.*$endval.*/i;
    }

    return -1;
}


sub log_error {

    open ERRFILE, ">>secbot.log";
    print ERRFILE "\n" . shift;
    close ERRFILE;
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
