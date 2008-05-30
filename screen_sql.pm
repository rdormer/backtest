use DBI;
use Date::Manip;

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

    my $sdate = shift;
    my $edate = shift;
    my $query = "select date from historical where ticker='IBM' and date >= '$sdate' and date <= '$edate'";
    @date_range = map {$_->[0]} @{$dbh->selectall_arrayref($query)};
}

sub pull_ticker_history {

    $current_ticker = shift;

#    print "\npulling $current_ticker";

    if(exists $history_cache{$current_ticker}) {
	pull_from_cache($current_ticker);
    } else {
	$maximum = $max_limit + 1;
	$pull_sql = $dbh->prepare("select * from historical where ticker=? and date <= ? order by date desc limit ?");
	$pull_sql->execute($current_ticker, $current_date, $maximum);
	$current_prices = $pull_sql->fetchall_arrayref();
	pull_fundamental();
    }

    %value_cache = ();
}    

sub pull_from_cache {

    my $ticker = shift;
    $current_prices = $history_cache{$ticker};
    
    my $i = 0;
    $i++ while fetch_date_at($i) ne $current_date and $i < @$current_prices;

#    return if $i >= @$current_prices;

    my @array = @$current_prices;
    @array = @array[$i..@array-1];
    $current_prices = \@array;
}


sub cache_ticker_history {

    $ticker = shift;
    $pull_sql = $dbh->prepare("select * from historical where ticker=? and date >= ? and date <= ? order by date desc");
    $pull_sql->execute($ticker, $current_date, $date_range[@date_range - 1]);
    $history_cache{$ticker} = $pull_sql->fetchall_arrayref();
}    

sub clear_history_cache {
    delete $history_cache{shift};
}

sub current_index {

    my $i = 0;
#    $i++ while fetch_date_at($i) ne $current_date;

    $d1 = ParseDate($current_date);
    while($i < @$current_prices) {

	$d2 = ParseDate(fetch_date_at($i));
	return $i if Date_Cmp($d2, $d1) <= 0;
	$i++;
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
    my @t = $dbh->selectrow_array("select open from historical where ticker='$ticker' and date='$date'");

    return $t[0];
}

sub get_splitadj_at_date {

    my $ticker = shift;
    my $date = shift;
    my @t = $dbh->selectrow_array("select splitadj from historical where ticker='$ticker' and date='$date'");

    return $t[0];
}

sub add_fundamental {

    if(! $pull_fundamentals) {
	$pull_fundamentals = $dbh->prepare("select * from fundamentals where ticker=?");
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
	 "eps" => "fundamentals"
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

1;
