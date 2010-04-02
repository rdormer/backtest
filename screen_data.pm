use Date::Business;
use screen_sql;

#these have to stay non-local for indicators.pm to work
#a quick word about $current_prices - it's a reference to a multidimensinoal
#array containing the price data for the current ticker - index 0 is the most
#recent day, and incrementing the index decrements the day - in other words
#going forward through the array goes backwards through time

$current_prices;
%value_cache;
%current_fundamentals;
%dividend_cache;

my $max_limit;

my %history_cache;
my @fundamental_list;
my $sweep_statement;

my $current_date;
my $today_obj;
my $date_index;
my @date_range;
my $current_ticker;

my $pull_fundamentals;

my @file_ticker_list;
my @ticker_list;

sub init_sql {

    my $file = shift;
    open(INFILE, $file);
    
    init_mod();

    $date_index = -1;
    $max_limit = 1;

    while(<INFILE>) {
	chomp;
	push @file_ticker_list, $_;
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

    my $notdone = $date_index < @date_range;

    if($notdone) {
	$date_index++;
	$current_date = $date_range[$date_index];
	print "$current_date\n\b\b\b\b\b\b\b\b\b\b";
    } else {
	$current_date = $date_range[$#date_range];
    }

    $d = $current_date;
    $d =~ s/-//g;
    $today_obj = new Date::Business(DATE => $d);

    return $notdone;
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

sub run_screen_loop {

    my $stop = shift;

    init_filter();
    do_initial_sweep();

    foreach $ticker (@ticker_list) {
	filter_results($ticker, @_) if pull_ticker_history($ticker);
	break if &$stop();
    }

    my @results = do_final_actions();
    return @results;
}


sub pull_ticker_history {

    $current_ticker = shift;

    if(exists $history_cache{$current_ticker}) {
	pull_from_cache($current_ticker);
    } else {
	$maximum = $max_limit + 1;
	$current_prices = pull_history_by_limit($current_ticker, $current_date, $maximum);
	pull_fundamental();

	process_splits($current_ticker, days_ago($maximum), $current_date, $current_prices);
    }

    %value_cache = ();
    return scalar @$current_prices >= $max_limit;
}    

sub pull_from_cache {

    my $ticker = shift;
    $current_prices = $history_cache{$ticker};
    my $low = search_array_date($current_date, $current_prices);

    if(fetch_date_at($low) ne $current_date) {

	$low = 0;
	$low++ while(fetch_date_at($low) gt $current_date && $low < $#{$current_prices});
    }

    $start = $low + $max_limit;
    $current_prices = [ @$current_prices[$low..$start] ];
}

sub current_from_cache {
    my $t = shift;
    $current_prices = $history_cache{$t};
}

sub cache_ticker_history {

    my $ticker = shift;

    $sd = new Date::Business(DATE => $today_obj);
    $sd->subb($max_limit + 1);
    $sdate = $sd->image();

    substr $sdate, 4, 0, "-";
    substr $sdate, 7, 0, "-";
    my $edate = $date_range[$#date_range];

    $href = pull_history_by_dates($ticker, $sdate, $edate);

    process_splits($ticker, $sdate, $edate, $href);
    $history_cache{$ticker} = $href;
    cache_dividends($ticker);
}    

sub cache_dividends {

    my $ticker = shift;
    $dividend_cache{$ticker} = pull_dividends($ticker, $current_date, $date_range[ $#date_range ]);
}


sub process_splits {

    my $ticker = shift;
    my $start_date = shift;
    my $end_date = shift;
    my $hist = shift;

    $splitlist = pull_splits($ticker, $start_date, $end_date);

    foreach $split (@$splitlist) {

	$ind = search_array_date($split->[0], $hist);
	$splitratio = $split->[2] / $split->[1];
	for(my $i = 0; $i <= $ind; $i++) {
	    @tt = map $_ * $splitratio, ($hist->[$i][2], $hist->[$i][3], $hist->[$i][4], $hist->[$i][5]);
	    splice @{$hist->[$i]}, 2, 4, @tt;
	}
    }
}

sub days_ago {

    my $date = new Date::Business(DATE => $today_obj);
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
    my $high = $#{$array};

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
    while($current_date lt $current && $i < $#{$current_prices}) {
	$i++;
	$current = fetch_date_at($i);
    }

    return $i;
}

sub current_ticker {
    return $current_ticker;
}

sub get_exit_date {
    return $date_range[$date_index + 1];
}

sub change_over_period {

    my $ticker = shift;
    my ($start, $end) = pull_close_on_date($ticker, $date_range[0], $date_range[$#date_range]);

    if($start > 0) {
	return (($end - $start) / $start) * 100;
    }

    return -100;
}

sub pull_fundamental {

    if($pull_fundamentals) {


    }
}

sub build_sweep_statement {

    if(@fundamental_list == 0) {
	return;
    }

    my $sweep_statement = "select ticker from fundamentals where ";

    foreach (@fundamental_list) {
	$sweep_statement .= " $_ and ";
    }

    $sweep_statement .= "date <= ? order by date desc limit 1";
}

sub do_initial_sweep {

    my $sweep_results;

    if($sweep_statement) {
	$sweep = $dbh->prepare($sweep_statement);
	$sweep->execute($current_date);
	$sweep_results = $sweep->fetchall_hashref("ticker");
    } else {
	@ticker_list = @file_ticker_list;
	return;
    }

    foreach (@file_ticker_list) {
	push(@ticker_list, $_) if exists $sweep_results->{$_};
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
