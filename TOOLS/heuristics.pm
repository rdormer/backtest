package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;

use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Document;


#jump table for parsers for each categroy

my %parsers = ("Shares Outstanding" => \&process_shares_outstanding, "Earnings per share" => \&process_diluted_eps);

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
my $selection_offset = 1;

my @chunk_list;
my @chunk_categories;

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
	search_current_assets();
	search_current_liabilities();
    }

    if($cat eq "earnings statements") {
	search_net_income();
    }

    foreach $category (keys %hitmap) {

	$temp = $hitmap{$category};
	if(exists $parsers{$category}) {
	    $parsers{$category}->($temp, $cat);
	}
    }

    my @temp = @token_list;
    push @chunk_categories, $cat;
    push @chunk_list, \@temp;
}

sub finish_sweep {

    if(not exists $sql_hash->{net_income}) {
	retry_net_income();
    }

    @chunk_categories = ();
    @chunk_list = ();
}

sub search_net_income {

    if($token_list[0] !~ /three months.*/i && $token_list[0] !~ /quarter ended.*/i) {
	return;
    }

    for(my $index = 0; $index < $#token_list; $index++) {

	my $curtoken = $token_list[ $index ];

	if($curtoken =~ /net income( \(loss\))?/i || 
	   $curtoken =~ /net loss$/i ||
	   $curtoken =~ /net \(loss\) income$/i) {
		
	    if($token_list[$index + $selection_offset] =~ /^-?[0-9]+$/) {

		$sql_hash->{net_income} = $token_list[$index + $selection_offset] if not exists $sql_hash->{net_income};
		return;
	    }
	} 
    }
}

#if we didn't find net income under one of it's common names in the earnings statements, then
#we need to search for it under a different name, which can be found by looking at the first
#line of the cash flow statement - which is always net income (or whatever it's called).

sub retry_net_income {

    my $searchterm;

  CATEGORY_LOOP:
    for(my $catindex = 0; $catindex <= $#chunk_categories; $catindex++) {
	if($chunk_categories[$catindex] eq 'cash flow statements') {

	    @temp = @{$chunk_list[$catindex]};
	    foreach(@temp) {
		
		if(/Operating activities (.*)/i) {
		    $searchterm = $1;
		    last CATEGORY_LOOP;
		}
	    }
	}
    }

    #why bother searching for the key when we already found it in the 
    #cash flow statements?  Because it may not be the right value.
    #a lot of cash flow statements are in odd time increments (i.e. not quarterly)

  SEARCH_LOOP:
    for(my $catindex = 0; $catindex < $#chunk_categories; $catindex++) {

	if($chunk_categories[$catindex] eq 'earnings statements') {

	    #hate constructing a new array here
	    @tokens = @{$chunk_list[$catindex]};

	    for(my $index = 0; $index < $#tokens; $index++) {

		if($tokens[$index] =~ /$searchterm$/i) {
		    $sql_hash->{net_income} = $tokens[$index + $selection_offset];
		    last SEARCH_LOOP;
		}
	    }
	}
    }
}


sub search_current_assets {

    my $off = forward_token_search("total current assets", 0, "liabilities");

    if($token_list[$off + $selection_offset] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{current_assets}) {
	$sql_hash->{current_assets} = $token_list[$off + $selection_offset];
    }
}

sub search_current_liabilities {

    my $off = backward_token_search("total current liabilities", $#token_list, "assets");

    if($token_list[$off + $selection_offset] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{current_liabilities}) {
	$sql_hash->{current_liabilities} = $token_list[$off + $selection_offset];
    }
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
		$sql_hash->{total_assets} = $token_list[$off - 2];  ##### <----------THIS???
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

    if($token_list[$off + $selection_offset] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{total_assets}) {
	$sql_hash->{total_assets} = $token_list[$off + $selection_offset];
    }
}


sub search_liabilities {

    my $off = backward_token_search("total liabilities", $#token_list, "assets");
    if($off < 0) {

	$off = backward_token_search("total", $#token_list, "assets");
	if($off < 0) {
	    log_error("couldn't find total liabilities") if !exists $sql_hash->{total_liabilities};
	    return;
	}
    }

    if($token_list[$off + $selection_offset] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{total_liabilities}) {
	$sql_hash->{total_liabilities} = $token_list[$off + $selection_offset];
    }
}

sub process_diluted_eps {

    my $hits = shift;
    my $topcat = shift;

    if($topcat eq 'earnings statements') {

	foreach (keys %$hits) {

	    my $value = $token_list[$_ + $selection_offset];
	    if($value =~ /-?[0-9]+\.[0-9]+/) {

		if($token_list[$_] =~ /diluted/i && $token_list[$_] =~ /basic/i) {
		    $sql_hash->{diluted_eps} = $value;
		    $sql_hash->{basic_eps} = $value;
		} elsif($token_list[$_] =~ /diluted/i && ! exists $sql_hash->{diluted_eps}) {
		    $sql_hash->{diluted_eps} = $value;
		} elsif($token_list[$_] =~ /basic/i && ! exists $sql_hash->{basic_eps}) {
		    $sql_hash->{basic_eps} = $value;
		} elsif(! exists $sql_hash->{basic_eps} && ! exists $sql_hash->{diluted_eps}) {
		    $sql_hash->{diluted_eps} = $value;
		    $sql_hash->{basic_eps} = $value;
		}
	    }
	}
    }
}

sub process_shares_outstanding {

    my $hits = shift;
    my $topcat = shift;
    my $shares, $index;

    my @potential_hits;

    if($topcat eq "earnings statements") {

	foreach (keys %$hits) {

	    $index = $_;

	    if(extend_category_match($_)) {
		$shares = $token_list[$_ + $selection_offset + 1];
		$index++;
	    } else {
		$shares = $token_list[$_ + $selection_offset];
	    }

	    if(length $token_list[$index] < 150 && $shares =~ /\d+/ && $shares > 1) {
		push @potential_hits, $index;
	    }
	}


	if(@potential_hits == 1) {
	    my $ind = $potential_hits[0] + 1;
	    $sql_hash->{shares_outstanding} = $token_list[$ind];
	} else {

	    if(count_term_hits(\@potential_hits, "diluted") == 1) {
		my $match = find_term(\@potential_hits, "diluted");
		$sql_hash->{shares_outstanding} = $token_list[$match + $selection_offset];
	    } else {
#		print "\nALTERNATE HIT COUNT IS " . count_term_hits(\@potential_hits, "diluted");
	    }
	} 
    }
}

sub extend_category_match {

    my $hitindex = shift;
    
    if($token_list[$hitindex + 1] =~ /.*(basic|diluted)/i) {
	return 1;
    }

    return 0;
}

sub count_term_hits {

    my $searcharr = shift;
    my $term = shift;
    my $count = 0;

    foreach(@$searcharr) {
	if($token_list[$_] =~ /.*$term.*/i) {
	    $count++;
	}
    }

    return $count;
}

sub find_term {

    my $searcharr = shift;
    my $term = shift;

    foreach(@$searcharr) {
	if($token_list[$_] =~ /.*$term.*/i) {
	    return $_;
	}
    }

    return 0;
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
