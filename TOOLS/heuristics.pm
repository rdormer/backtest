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
$current_asset_rules->init("cur_asset_txtsearch");

my $asset_rules = ruleset->new();
$asset_rules->init("asset_txtsearch", "asset_unlabeled_total");

my $debt_rules = ruleset->new();
$debt_rules->init("debt_txtsearch", "debt_subtract_equity", "debt_subtract_category", "debt_subtract_unlabeled");

my $cash_rules = ruleset->new();
$asset_rules->init("cash_txtsearch");

my $net_income_rules = ruleset->new();
$net_income_rules->init("net_income_txtsearch");

my $equity_rules = ruleset->new();
$equity_rules->init("equity_txtsearch", "equity_by_category");

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
    parse_rule->set_data(\@tuple_list, $sql_hash);

    if($cat eq "balance sheets") {
	$current_asset_rules->apply();
	$equity_rules->apply();
	$asset_rules->apply();
	$debt_rules->apply();
	$cash_rules->apply();
    }

    if($cat eq "earnings statements" && ! wrong_timeframe()) {
	$net_income_rules->apply();
	$epsrules->apply();
    }
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



1;
