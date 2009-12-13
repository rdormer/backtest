package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;

use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Document;

my $CATINDEX = 0;
my $KEYINDEX = 1;

#workaround for bug in this package
Algorithm::NaiveBayes->new();
$keymod = AI::Categorizer::Learner::NaiveBayes->restore_state('keys.sav');


my $selection_offset = 2;

my @tuple_list;
my @temp_tuple;

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
	$token =~ s/nil/0.0/g;
	$token =~ s/://g;

	if($token =~ /.*[A-Za-z].*/) {

	    add_tuple(\@temp_tuple);
	    @temp_tuple = ();
	    push @temp_tuple, $token;
	} else {

	    foreach (split /\s/, $token) {
		$_ =~ s/\,//g;
		$_ =~ s/\(/-/;
		$_ =~ s/\)//;
		$_ =~ s/\$//;
		push @temp_tuple, $_;
	    }
	}
    }
}

sub add_tuple {

    my $tuple = shift;
    my @new_tuple = @$tuple;

    return if @new_tuple < 1;
    my $doc = new AI::Categorizer::Document(content => $new_tuple[0]);
    $hypth = $keymod->categorize($doc);
    unshift @new_tuple, $hypth->best_category;
    push @tuple_list, \@new_tuple;

    if($main::dumptuples) {

	print "\n";
	for(my $i = 1; $i <= $#new_tuple; $i++) {
	    print "$new_tuple[$i] ";
	}

	print "\t($new_tuple[0])";
    }
}

sub clear {
    @tuple_list = ();
    @temp_tuple = ();
    %hitmap = ();
}

sub find_best_matches {

    my $cat = shift;
    add_tuple(\@temp_tuple);


    if($cat eq "balance sheets") {
	search_assets();
	search_liabilities();
	search_current_assets();
	search_current_liabilities();
    }

    if($cat eq "earnings statements" && ! wrong_timeframe()) {
	search_shares_outstanding();
	search_net_income();
	search_revenue();
	search_eps();
    }

    my @temp = @tuple_list;
    push @chunk_categories, $cat;
    push @chunk_list, \@temp;
}

sub finish_sweep {

    if(not exists $sql_hash->{net_income}) {
	retry_net_income();
    }

    retry_eps();

    @chunk_categories = ();
    @chunk_list = ();
}

sub search_net_income {

    if($tuple_list[0][$KEYINDEX] !~ /three months.*/i && $tuple_list[0][$KEYINDEX] !~ /quarter ended.*/i) {
	return;
    }

    for(my $index = 0; $index <= $#tuple_list; $index++) {

	my $curtoken = $tuple_list[ $index ][$KEYINDEX];

	if($curtoken =~ /net income( \(loss\))?/i || 
	   $curtoken =~ /net loss$/i ||
	   $curtoken =~ /net \(loss\) income$/i) {
		
	    if($tuple_list[$index][$selection_offset] =~ /^-?[0-9]+$/) {

		$sql_hash->{net_income} = $tuple_list[$index][$selection_offset] if not exists $sql_hash->{net_income};
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
    for(my $catindex = 0; $catindex <= $#chunk_categories; $catindex++) {

	if($chunk_categories[$catindex] eq 'earnings statements') {

	    #hate constructing a new array here
	    @tuples = @{$chunk_list[$catindex]};

	    for(my $index = 0; $index <= $#tuples; $index++) {

		if($tuples[$index][$KEYINDEX] =~ /$searchterm$/i) {
		    $sql_hash->{net_income} = $tuples[$index][$selection_offset];
		    last SEARCH_LOOP;
		}
	    }
	}
    }
}


sub retry_eps {

    if(exists $sql_hash->{basic_eps} && ! exists $sql_hash->{diluted_eps}) {
	$sql_hash->{diluted_eps} = $sql_hash->{basic_eps};
    }

    if(exists $sql_hash->{diluted_eps} && ! exists $sql_hash->{basic_eps}) {
	$sql_hash->{basic_eps} = $sql_hash->{$diluted_eps};
    }
}

sub search_revenue {

    foreach(@tuple_list) {

	if($_ =~ /revenue/i || $_ =~ /gross profit/i || $_ =~ /income before/i) {
#	    print "  HIT";
	}

    }

}


sub search_current_assets {

    my $off = forward_token_search("total current assets", 0, "liabilities");

    if($tuple_list[$off][$selection_offset] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{current_assets}) {
	$sql_hash->{current_assets} = $tuple_list[$off][$selection_offset];
    }
}

sub search_current_liabilities {

    my $off = backward_token_search("total current liabilities", $#tuple_list, "assets");

    if($tuple_list[$off][$KEYINDEX] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{current_liabilities}) {
	$sql_hash->{current_liabilities} = $tuple_list[$off][$selection_offset];
    }
}

sub search_assets {

    my $off = forward_token_search("total assets", 0, "liabilities");
    if($off < 0) {
	$off = forward_token_search("total", 0, "liabilities");
	if($off < 0 && ! exists $sql_hash->{total_assets}) {

	    #$off is post incremented so we don't need to go all the way to the last element
	    #this is for the case where assets is not labeled, but just a bottom line total

	    $off = 0;
	    while($tuple_list[$off][$KEYINDEX] !~ /.*liabilities.*/i && $off < $#tuple_list) {
		$off++;
	    }

	    my $tuplesize = @{ $tuple_list[$off - 1] };
	    my $assetval = $tuple_list[$off - 1][$tuplesize - $selection_offset]; #TODO <-- check this

	    if($assetval =~ /[0-9]+/) {
		$sql_hash->{total_assets} = $assetval;
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

    if($tuple_list[$off][$selection_offset] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{total_assets}) {
	$sql_hash->{total_assets} = $tuple_list[$off][$selection_offset];
    }
}


sub search_liabilities {

    my $off = backward_token_search("total liabilities", $#tuple_list, "assets");
    if($off < 0) {

	$off = backward_token_search("total", $#tuple_list, "assets");
	if($off < 0) {
	    return;
	}
    }

    if($tuple_list[$off][$selection_offset] !~ /.*[A-Z]+.*/i && ! exists $sql_hash->{total_liabilities}) {
	$sql_hash->{total_liabilities} = $tuple_list[$off][$selection_offset];
    }
}

sub search_eps {

    my $hits = shift;
    my $topcat = shift;

    if( ! try_eps_summation()) {
	try_eps_lexsearch();
    }
}

sub try_eps_lexsearch {

    for(my $index = 0; $index <= $#tuple_list; $index++) {

	next if $tuple_list[$index][$CATINDEX] ne "Earnings per share";

	my $keyval = $tuple_list[$index][$KEYINDEX];
	my $value = $tuple_list[$index][$selection_offset];

	if(extend_category_match($_)) {
	    
#	    $keyval = $keyval . $token_list[$_ + 1];
#	    $value = $token_list[$_ + 1 + $selection_offset];
	}

	if($value =~ /-?[0-9]*\.[0-9]+/) {

	    if($keyval =~ /diluted/i && $keyval =~ /basic/i) {
		$sql_hash->{diluted_eps} = $value;
		$sql_hash->{basic_eps} = $value;
	    } elsif($keyval =~ /diluted/i && ! exists $sql_hash->{diluted_eps}) {
		$sql_hash->{diluted_eps} = $value;
	    } elsif($keyval =~ /basic/i && ! exists $sql_hash->{basic_eps}) {
		$sql_hash->{basic_eps} = $value;
	    } elsif(! exists $sql_hash->{basic_eps} && ! exists $sql_hash->{diluted_eps}) {
		$sql_hash->{diluted_eps} = $value;
		$sql_hash->{basic_eps} = $value;
	    }
	}
    }
}

sub try_eps_summation {

    my $sum = 0;
    my $last = 0;
    
    for(my $index = 0; $index <= $#tuple_list; $index++) {
	    
	my $keyval = $tuple_list[$index][$KEYINDEX];
	my $value = $tuple_list[$index][$selection_offset];

	if(extend_category_match($_)) {
	    
#	    $keyval = $keyval . $token_list[$_ + 1];
#	    $value = $token_list[$_ + 1 + $selection_offset];
	}

	if($value =~ /-?[0-9]*\.[0-9]+/) {
	    $sum += $value;
	    $last = $value;
	}
    }

    if(($sum - $last) == $last && ($sum - $last) != 0) {
	$sql_hash->{basic_eps} = $last;
	$sql_hash->{diluted_eps} = $last;
	return 1;
    } else {
	return 0;
    }
}


sub search_shares_outstanding {

    my $shares;
    my @potential_hits;

    for(my $index = 0; $index <= $#tuple_list; $index++) {

	if(extend_category_match($_)) {
#	    $shares = $token_list[$_ + $selection_offset + 1];
#	    $index++;
	} else {
	    $shares = $tuple_list[$index][$selection_offset];
	}

	if(length $tuple_list[$index][$KEYINDEX] < 150 && $shares =~ /\d+/ && $shares > 1) {
	    push @potential_hits, $index;
	}
    }


    if(@potential_hits == 1) {
	my $ind = $potential_hits[0] + 1;
	$sql_hash->{shares_outstanding} = $tuple_list[$ind][$selection_offset];
    } else {

	if(count_term_hits(\@potential_hits, "diluted") == 1) {
	    my $match = find_term(\@potential_hits, "diluted");
	    $sql_hash->{shares_outstanding} = $tuple_list[$match][$selection_offset];
	} else {
#		print "\nALTERNATE HIT COUNT IS " . count_term_hits(\@potential_hits, "diluted");
	}
    } 
}

#sub to check and make sure there is quarterly data 
#in this chunk, if not, we can discard said chunk
sub wrong_timeframe {

    my $three_index = -1;
    my $six_index = -1;

    for(my $i = 0; $i <= $#tuple_list; $i++) {
	if($tuple_list[$i][$KEYINDEX] =~ /three months/i) {
	    $three_index = $i;
	    last;
	}
    }


    for(my $i = 0; $i <= $#tuple_list; $i++) {
	if($tuple_list[$i][$KEYINDEX] =~ /six months/i) {
	    $six_index = $i;
	    last;
	}
    }

    return $six_index >= 0 && $three_index < 0;
}

sub extend_category_match {

#    my $hitindex = shift;
    
#    if($tuple_list[$hitindex + 1] =~ /.*(basic|diluted)/i || 
#       $token_list[$hitindex] =~ /.*note$/i) {
	
#	return 1;
#    }

    return 0;
}

#count term hits and find term hits are utilities 
#that check an array of indices into the token list
#to see if they contain search terms - not to be mistaken
#for functions that search the token list itself

sub count_term_hits {

    my $searcharr = shift;
    my $term = shift;
    my $count = 0;

    foreach(@$searcharr) {
	if($tuple_list[$_][$KEYINDEX] =~ /.*$term.*/i) {
	    $count++;
	}
    }

    return $count;
}

sub find_term {

    my $searcharr = shift;
    my $term = shift;

    foreach(@$searcharr) {
	if($tuple_list[$_][$KEYINDEX] =~ /.*$term.*/i) {
	    return $_;
	}
    }

    return 0;
}

sub forward_token_search {

    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for($i = $start; $i <= $#tuple_list; $i++) {
	return $i if lc($tuple_list[$i][$KEYINDEX]) eq lc($searchval);
	last if $tuple_list[$i][$KEYINDEX] =~ /.*$endval.*/i;
    }

    return -1;
}


sub backward_token_search {

    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for($i = $start; $i >= 0; $i--) {
	return $i if lc($tuple_list[$i][$KEYINDEX]) eq lc($searchval);
	last if $tuple_list[$i][$KEYINDEX] =~ /.*$endval.*/i;
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
