use DBI;
use Date::Business;


my $history_table = "historical";
my $fundamental_table = "fundamentals";

my $pull_cmd = "select ticker,date,open,high,low,close,splitadj,volume from $history_table where ticker=? and date <= ? order by date desc limit ?";
my $cache_cmd = "select ticker,date,open,high,low,close,splitadj,volume from $history_table where ticker=? and date >= ? and date <= ? order by date desc";

#these have to stay non-local for indicators.pm to work
#a quick word about $current_prices - it's a reference to a multidimensinoal
#array containing the price data for the current ticker - index 0 is the most
#recent day, and incrementing the index decrements the day - in other words
#going forward through the array goes backwards through time

$current_prices;
%value_cache;
%current_fundamentals;

my $dbh;
my $max_limit;

my %table_list;
my %history_cache;

my $current_date;
my $date_index;
my @date_range;
my $current_ticker;

my $pull_fundamentals;

@ticker_list;

sub init_sql() {
    
    $dbh = DBI->connect("DBI:mysql:finance", "perldb");
    $date_index = -1;
    $max_limit = 1;
}

sub set_ticker_list {

    @rval = @ticker_list;
    $t = shift;
    @ticker_list = @$t;
    return \@rval;
}

sub ticker_list {
    return @ticker_list;
}


sub next_test_day {

    if($date_index < @date_range) {
	$date_index++;
	$current_date = $date_range[$date_index];
	print "$current_date\n\b\b\b\b\b\b\b\b\b\b";
#	print "\n$current_date";
	return 1;
    }

    $current_date = $date_range[@date_range - 1];
    return 0;
}

sub set_date {
    $current_date = shift;
}

sub get_date {
    return $current_date;
}

sub set_date_range {

    ($date, $end_date) = parse_two_dates(shift, shift);
    $date->prevb();

  DATELOOP:
    while($date->lt($end_date)) {

	$date->nextb();
	$d = $date->image();

#	foreach (@trading_holidays) {
#	    next DATELOOP if $_->eq($date) == 0;
#	}

	substr $d, 4, 0, "-";
	substr $d, 7, 0, "-";
	push @date_range, $d;
    }
}

sub pull_ticker_history {

    $current_ticker = shift;

    if(exists $history_cache{$current_ticker}) {
	pull_from_cache($current_ticker);
    } else {
	$maximum = $max_limit + 1;
	$pull_sql = $dbh->prepare($pull_cmd);
	$pull_sql->execute($current_ticker, $current_date, $maximum);
	$current_prices = $pull_sql->fetchall_arrayref();
	pull_fundamental();

#	process_splits(days_ago($current_date, $maximum), $current_date, $current_prices);
    }

    %value_cache = ();
    return scalar @$current_prices >= $max_limit;
}    

sub pull_from_cache {

    my $ticker = shift;
    $current_prices = $history_cache{$ticker};

    my $high = @$current_prices - 1;
    my $low = search_array_date($current_date, $current_prices);

    if(fetch_date_at($low) ne $current_date) {

	$low = 0;
	$low++ while(fetch_date_at($low) gt $current_date && $low < @$current_prices - 1);
    }

#    $len = @$current_prices - 1;
#    $current_prices = [ @$current_prices[$low..$len] ];

    $start = $low + $max_limit;
    $current_prices = [ @$current_prices[$low..$start] ];
}


sub cache_ticker_history {

    $ticker = shift;

    $s = $current_date;
    $s =~ s/-//g;
    $sd = new Date::Business(DATE => $s);
    $sd->subb($max_limit + 1);
    $sdate = $sd->image();

    substr $sdate, 4, 0, "-";
    substr $sdate, 7, 0, "-";
    my $edate = $date_range[@date_range - 1];

    $pull_sql = $dbh->prepare($cache_cmd);
    $pull_sql->execute($ticker, $sdate, $edate);

    my $href = $pull_sql->fetchall_arrayref();
#    process_splits($sdate, $edate, $href);
    $history_cache{$ticker} = $href
}    

sub process_splits {

    my $start_date = shift;
    my $end_date = shift;
    my $hist = shift;

    $split_sql = $dbh->prepare("select date,bef,after from splits where ticker=? and date <= ? and date >= ?");
    $split_sql->execute($current_ticker, $end_date, $start_date);

    $splitlist = $split_sql->fetchall_arrayref();
    foreach $split (@$splitlist) {

	$ind = search_array_date(@$split[0], $hist);
	$splitratio = @$split[1] / @$split[2];
	for($i = $ind + 1; $i < @$hist; $i++) {

	    @tt = map $_ * $splitratio, ($hist->[$i][2], $hist->[$i][3], $hist->[$i][4], $hist->[$i][5]);
	    splice @{$hist->[$i]}, 2, 4, @tt;

#	    print "\n --- ";
#	    foreach $c (@$hist->[$i]) {
#		print "$c->[1] $c->[2] $c->[3] $c->[4] $c->[5]";
#	    }
	}
    }
}

sub days_ago {

    my $d = shift;

    $d =~ s/-//g;
    my $date = new Date::Business(DATE => $d);
    $date->subb(shift);
    
    my $rval = $date->image();
    substr $rval, 4, 0, "-";
    substr $rval, 7, 0, "-";

    return $rval;
}

sub search_array_date {

    my $target = shift;
    my $array = shift;

    my $low = 0;
    my $high = @$array - 1;

    while($low < $high) {

	$mid = int(($low + $high) / 2);

	$buf = $array->[$mid][1];

	if($buf gt $target) {
	    $low = $mid + 1;
	} else {
	    $high = $mid;
	}
    }

    return $low;
}

sub clear_history_cache {
    delete $history_cache{shift};
}

sub current_index {

    my $i = 0;

    my $current = fetch_date_at($i);
    while($current_date lt $current && $i < @$current_prices - 1) {
	$i++;
	$current = fetch_date_at($i);
    }

    return $i;
}

sub current_ticker {
    return $current_ticker;
}

sub get_exit_price {
    return get_price_at_date(shift, get_exit_date());
}

sub get_entry_price {
    return get_price_at_date(shift, get_exit_date());
}

sub get_ending_price {
    return get_price_at_date(shift, $date_range[@date_range - 1]);
}

sub get_exit_date {
    return $date_range[$date_index + 1];
}

sub get_price_at_date {

    my $ticker = shift;
    my $date = shift;
    my @t = $dbh->selectrow_array("select open from $history_table where ticker='$ticker' and date >= '$date' order by date asc limit 1");

    return $t[0];
}

sub get_splitadj_at_date {

    my $ticker = shift;
    my $date = shift;
    my @t = $dbh->selectrow_array("select splitadj from $history_table where ticker='$ticker' and date='$date'");

    return $t[0];
}

sub change_over_period {

    my $ticker = shift;
    my $start = get_splitadj_at_date($ticker, $date_range[0]);
    my $end = get_splitadj_at_date($ticker, $date_range[@date_range - 1]);

    if($start > 0) {
	return (($end - $start) / $start) * 100;
    }

    return -100;
}


sub add_fundamental {

    if(! $pull_fundamentals) {
	$pull_fundamentals = $dbh->prepare("select * from $fundamental_table where ticker=?");
    }
}

sub pull_fundamental {

    if($pull_fundamentals) {

	$pull_fundamentals->execute($current_ticker);
	$ref = $pull_fundamentals->fetchrow_hashref;
	%current_fundamentals = %$ref;
    }
}

sub add_sweep_clause {

    $field = shift;
    my %field_tables = (
	 "position" => "relative_strength",
	 "earnings" => "earnings",
	 "eps" => "$fundamental_table"
	 );

    $table = $field_tables{$field};
    $table_list{$table} = true;
}

sub build_sweep_statement {

    @tables = keys %table_list;
    $statement = "select " . $tables[0] . ".ticker from ";

    foreach $table (@tables) {
	$statement .= "$table, ";	
    }

    $statement = substr($statement, 0, length($statement) - 2); 

    if(@tables > 1) {

	$statement .= " where ";
	for($i = 0; $i <= @tables - 2; $i++) {

	    $statement .= $tables[$i] . ".ticker = ";
	    $statement .= $tables[$i + 1] . ".ticker ";

	    if(@tables > 2 && $i < @tables - 2) {
		$statement .= " and ";
	    }
	}
    }

    return $statment;
}

sub do_initial_sweep {

    my $sweep_results;

    $sweep_statement = build_sweep_statement();

    open(INFILE, shift);

    if($sweep_statement) {
	$sweep_sql = $dbh->prepare($sweep_statement);
	$sweep_sql->execute();
	$sweep_results = $sweep_sql->fetchall_hashref("ticker");
    }

    while(<INFILE>) {
	chomp;
	push(@ticker_list, $_) if $sweep_sql and exists $sweep_results->{$_};
	push(@ticker_list, $_) if not $sweep_sql;
    }

}

sub set_pull_limit {

    $lim = shift;
    $max_limit = $lim if $lim > $max_limit;
}

sub parse_two_dates {

    my $d1 = shift;
    my $d2 = shift;

    $d1 =~ s/-//g;
    $d2 =~ s/-//g;

    $date1 = new Date::Business(DATE => $d1);
    $date2 = new Date::Business(DATE => $d2);

    return ($date1, $date2);
}

1;
