use DBI;
use Storable;
use Date::Manip;
use Date::Business;

%start_dates;
%ticker_handles;
%segment_lengths;
@trading_holidays;

my $history_table = "historical";
my $fundamental_table = "fundamentals";

#these have to stay global for indicators.pm to work
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

    $t = retrieve('sdates.svar');
    %start_dates = %$t;

    $t = retrieve('lengths.svar');
    %segment_lengths = %$t;

    $t = retrieve('handles.svar');
    %ticker_handles = %$t;

    #precompute trading holidays
    $t = retrieve('holidays.svar');
    foreach (@$t) {
	push @trading_holidays, new Date::Business(DATE => $_);
    }
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

	foreach (@trading_holidays) {
	    next DATELOOP if $_->eq($date) == 0;
	}

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
	$current_prices = pull_from_shmem($current_ticker, $current_date, $maximum);

#	pull_fundamental();
    }

    %value_cache = ();
#    print "\nVALUE " . @$current_prices;
    return @$current_prices;
}    

sub pull_from_cache {

    my $ticker = shift;
 #   print "\npulling $ticker from cache";

    $current_prices = $history_cache{$ticker};

    my $i = @$current_prices - 1;
    $i-- while $i > 0 and fetch_date_at($i) ne $current_date;
#    print "\nfor $ticker we found at $i out of " . @$current_prices;   

    my @array = @$current_prices;
    @array = @array[$i..@array-1];
    $current_prices = \@array;
}

sub cache_ticker_history {

    $ticker = shift;

    print "\ncaching history for $ticker";
    

    $end_date = $date_range[@date_range - 1];
    ($cur, $end) = parse_two_dates($current_date, $end_date);
    $dif = $end->diffb($cur);

#    my $holidays = 0;
#    foreach (@trading_holidays) {
#	$holidays++ if $_->lt($end) && $_->gt($cur);
#    }

#    $dif -= $holidays;

#    print "\n$holidays holidays";

    $history_cache{$ticker} = pull_from_shmem($ticker, $end_date, $dif); 

#    $pull_sql = $dbh->prepare("select * from $history_table where ticker=? and date >= ? and date <= ? order by date desc");
#    $pull_sql->execute($ticker, $current_date, $date_range[@date_range - 1]);
#    $history_cache{$ticker} = $pull_sql->fetchall_arrayref();
}    

sub clear_history_cache {
    delete $history_cache{shift};
}

sub current_index {

    my $i = 0;

    ($target, $current) = parse_two_dates($current_date, fetch_date_at($i));
    while($target->lt($current) && $i < @$current_prices - 1) {

	$i++;
	$cur = fetch_date_at($i);
	$cur =~ s/-//g;
	$current = new Date::Business(DATE => $cur);
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

#    my $ticker = shift;
#    my $date = shift;
#    my @t = $dbh->selectrow_array("select open from $history_table where ticker='$ticker' and date='$date'");

    $t = pull_from_shmem(shift, shift, 1);

    return $t->[0][2];
}

sub get_splitadj_at_date {

#    my $ticker = shift;
#    my $date = shift;
#    my @t = $dbh->selectrow_array("select splitadj from $history_table where ticker='$ticker' and date='$date'");

    $t = pull_from_shmem(shift, shift, 1);

    return $t->[0][6];


#    return $t[0];
}

sub change_over_period {

    my $ticker = shift;
    my $start = get_splitadj_at_date($ticker, $date_range[0]);
    my $end = get_splitadj_at_date($ticker, $date_range[@date_range - 1]);

    return (($end - $start) / $start) * 100;
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


my $ROWSIZE = 34;

sub pull_from_shmem {

    my $ticker = shift;
    my $enddate = shift;
    my $pull_size = shift;
    my @ticker_data;

    $pull_size *= $ROWSIZE;

    #if the start date is before the current ticker's data 
    #starts, then we have nothing to return

    ($ed, $sd) = parse_two_dates($enddate, $start_dates{$ticker});
    return null if $sd->gt($ed);


    #if we got here, go ahead and pull

    $tmp = "";
    $end_offset = locate_date($ticker, $enddate);
    $end_offset = $segment_lengths{$ticker} if $end_offset > $segment_lengths{$ticker};
    shmread($ticker_handles{$ticker}, $tmp, $segment_lengths{$ticker} - $end_offset, $pull_size);

    for($i = 0; $i < length $tmp; $i += $ROWSIZE) {

	@cur_row = unpack "A10fffffL", substr $tmp, $i, $ROWSIZE;
	unshift @cur_row, $ticker;
	push @ticker_data, [ @cur_row ];
    }

    return \@ticker_data;
}

sub locate_date {

    my $ticker = shift;
    my $target_date = shift;

    ($ed, $sd) = parse_two_dates($target_date, $start_dates{$ticker});

    my $holidays = 0;
    foreach (@trading_holidays) {
	$holidays++ if $_->lt($ed) && $_->gt($sd);
    }

    $dif = $ed->diffb($sd);
    $dif -= $holidays;

#    print "\n$dif days with $holidays holidays between $start_dates{$ticker} and $target_date";

    return $dif * $ROWSIZE;
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
