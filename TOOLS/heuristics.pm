package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;

use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Document;
use parse_rule;
use ruleset;

my $CATINDEX = 0;
my $KEYINDEX = 1;

my $selection_offset = 2;
my @tuple_list;
my @temp_tuple;


#workaround for bug in this package
Algorithm::NaiveBayes->new();
$keymod = AI::Categorizer::Learner::NaiveBayes->restore_state('keys.sav');

my $epsrules = ruleset->new();
$epsrules->init("eps_summation", "eps_txtsearch", "eps_lasttry");

my $current_asset_rules = ruleset->new();
$current_asset_rules->init("cur_asset_txtsearch", "cur_asset_sum");

my $current_liabilities = ruleset->new();
$current_liabilities->init("cur_debt_txtsearch", "cur_debt_sum");

my $asset_rules = ruleset->new();
$asset_rules->init("asset_txtsearch", "asset_unlabeled_total");

my $debt_rules = ruleset->new();
$debt_rules->init("debt_txtsearch", "debt_subtract_equity", "debt_subtract_category", "debt_subtract_unlabeled");

my $cash_rules = ruleset->new();
$cash_rules->init("cash_txtsearch");

my $net_income_rules = ruleset->new();
$net_income_rules->init("net_income_txtsearch");

my $equity_rules = ruleset->new();
$equity_rules->init("equity_txtsearch", "equity_by_category");

my $avg_shares_rules = ruleset->new();
$avg_shares_rules->init("avg_shares_txtsearch", "avg_shares_extend", "avg_shares_simple");

my $share_count_rules = ruleset->new();
$share_count_rules->init("sharecount_respectively", "sharecount_simple", "sharecount_last_try");

my $revenue_rules = ruleset->new();
$revenue_rules->init("revenue_txtsearch");

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
    preprocess_tuple(\@new_tuple);
    push @tuple_list, \@new_tuple;

    if($main::dumptuples) {

	print "\n";
	for(my $i = 1; $i <= $#new_tuple; $i++) {
	    print "$new_tuple[$i] ";
	}

	print "\t($new_tuple[0])";
    }
}

sub preprocess_tuple {

    my $tuple = shift;

    #move note numbers to the end of the key
    if($tuple->[$KEYINDEX] =~ /.*note$/i && $tuple->[$KEYINDEX + 1] =~ /[0-9]+/) {
	$tuple->[$KEYINDEX] .= $tuple->[$KEYINDEX + 1];
	splice @$tuple, $KEYINDEX + 1, 1;
    }

    #get rid of any extraneous delimiters (dots, dashes, etc)
  RESTART:
    for(my $ind = $KEYINDEX + 1; $ind < scalar @{$tuple}; $ind++) {
	if($tuple->[$ind] !~ /\w/) {
	    splice @$tuple, $ind, 1;
	    goto RESTART;
	}	
    }

    $tuple->[$KEYINDEX] =~ s/\.//g;
}

sub clear {
    @tuple_list = ();
    @temp_tuple = ();
}

sub find_best_matches {

    my $cat = shift;
    add_tuple(\@temp_tuple);
    parse_rule->set_data(\@tuple_list, $sql_hash, find_multiplier());

    if($cat eq "balance sheets") {
	$cash_rules->apply();
	$current_asset_rules->apply();
	$current_liabilities->apply();
	$share_count_rules->apply();
	$equity_rules->apply();
	$asset_rules->apply();
	$debt_rules->apply();
    }

    if($cat eq "earnings statements" && ! wrong_timeframe()) {
	$avg_shares_rules->apply();
	$net_income_rules->apply();
	$revenue_rules->apply();
	$epsrules->apply();
    }
}

sub find_multiplier() {

    for(my $i = 0; $i <= 9; $i++) {
	return 1000 if($tuple_list[$i][1] =~ /thousand/i); 
	return 1000000 if($tuple_list[$i][1] =~ /million/i); 
	return 1000000000 if($tuple_list[$i][1] =~ /billion/i); 
    }

    return 1;
}

sub finish_sweep {

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

    if($three_index < 0) {

	for(my $i = 0; $i <= $#tuple_list; $i++) {
	    if($tuple_list[$i][$KEYINDEX] =~ /quarter ended/i) {
		$three_index = $i;
		last;
	    }
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

sub do_sanity_check {

    #no eps data means it's probably not a publically traded company

    if(! exists $sql_hash->{basic_eps} && ! exists $sql_hash->{diluted_eps}) {
	print "   skipping (no eps data)";
	return "no eps data";
    }

    #willing to let average share data slide, since 
    #there's probably still a lot of other useful data to be had

    if(! exists $sql_hash->{avg_shares_diluted} && 
       ! exists $sql_hash->{avg_shares_basic}) {

	$sql_hash->{avg_shares_diluted} = null;
	$sql_hash->{avg_shares_basic} = null;
    }

    #if current assets/liabilities is bigger than total 
    #assets/liabilities, then something has gone wrong with parsing

    if($sql_hash->{current_liabilities} > $sql_hash->{total_liabilities} ||
       $sql_hash->{current_assets} > $sql_hash->{total_assets}) {

	return "current assets/liabilities are more than total";
    }

    if($sql_hash->{diluted_eps} > $sql_hash->{basic_eps}) {
	return "diluted earnings per share is more than basic earnings per share";
    }

    if($sql_hash->{avg_shares_diluted} < $sql_hash->{avg_shares_basic}) {
	return "diluted average shares is less than basic average shares";
    }

    #CIK is always ten digits

    if(length $sql_hash->{cik} != 10) {
	return "invalid CIK";
    }

    #force share counts to exist
    
    if(! exists $sql_hash->{shares_authorized} || $sql_hash->{shares_authorized} !~ /[0-9]+/) {
	$sql_hash->{shares_authorized} = null;
    }

    if(! exists $sql_hash->{shares_issued} || $sql_hash->{shares_issued} !~ /[0-9]+/) {
	$sql_hash->{shares_issued} = null;
    }

    if(! exists $sql_hash->{shares_outstanding} || $sql_hash->{shares_outstanding} !~ /[0-9]+/) {
	$sql_hash->{shares_outstanding} = null;
    }

    return "";
}

1;
