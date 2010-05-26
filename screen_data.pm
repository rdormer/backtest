use Date::Business;
use screen_sql;

#these have to stay non-local for indicators.pm to work
#a quick word about $current_prices - it's a reference to a multidimensional
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

my $fund_pull_limit;
my @ticker_list;

sub init_data {

    my $file = shift;
    open(INFILE, $file);
    
    while(<INFILE>) {
	chomp;
	push @ticker_list, $_;
    }

    set_date_range(conf::start(), conf::finish());

    $date_index = -1;
    $max_limit = 1;
    init_mod();
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
    } else {
	$current_date = $date_range[$#date_range];
    }

    if(! conf::noprogress()) {
	print "$current_date\n\b\b\b\b\b\b\b\b\b\b";
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

sub adjust_start {

    my $date = shift;
    
    $date->nextb();
    $date->prevb();

    my $t = $date->image();
    substr $t, 4, 0, "-";
    substr $t, 7, 0, "-";

    if($t ne conf::start()) {
	$date->nextb();
    }
}

sub set_date_range {

    ($date, $end_date) = parse_two_dates(shift, shift);
    adjust_start($date);

  DATELOOP:
    while($date->lt($end_date)) {

	$d = $date->image();

#	foreach (@trading_holidays) {
#	    next DATELOOP if $_->eq($date) == 0;
#	}

	substr $d, 4, 0, "-";
	substr $d, 7, 0, "-";
	push @date_range, $d;
	$date->nextb();
    }

    conf::override_date_range($date_range[0], $date_range[$#date_range]);
}

sub run_screen_loop {

    my $stop = shift;
    my @results;

    $max_limit = $_[$#_][1];

    foreach $ticker (@ticker_list) {

	if(filter_results($ticker, @_)) {
	    push @results, $ticker;
	    last if &$stop(scalar @results);
	}
    }

    return @results;
}

sub filter_results {

    $current_ticker = shift;
    $current_prices = ();
    %value_cache = ();
    
    my $date = $current_date;

    for(my $i = 0; $i <= $#_; $i++) {

	my $maximum = $_[$i][1] + 1;
	my $data = pull_history_by_limit($current_ticker, $date, $maximum);

	if(scalar @$data > 0 && $data->[0][VOLUME_IND] > 0) {
	    
	    process_splits($current_ticker, days_ago($max_limit), $date, $data);

	    splice @$data, 0, 1 if $i > 0;
	    push @$current_prices, @$data;
	    return 0 if not eval($_[$i][0]);

	    $date = $data->[$#data][DATE_IND];
	
	} else {
	    return 0;
	}
    }

    return 1;
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


#grab split data and apply it to the price data we've pulled.
#note that this is the only remaining routine not using the
#index constants defined in indicators.pm

sub process_splits {

    my $ticker = shift;
    my $start_date = shift;
    my $end_date = shift;
    my $hist = shift;

    $splitlist = pull_splits($ticker, $start_date, $end_date);

    foreach $split (@$splitlist) {

	if($hist->[@$hist][DATE_IND] lt $split->[0]) {
	    $ind = search_array_date($split->[0], $hist);
	} else {
	    $ind = scalar @$hist - 1;
	}

	$splitratio = $split->[2] / $split->[1];
	for(my $i = 0; $i <= $ind; $i++) {
	    @tt = map $_ * $splitratio, ($hist->[$i][1], $hist->[$i][2], $hist->[$i][3], $hist->[$i][4]);
	    splice @{$hist->[$i]}, 1, 4, @tt;
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

	$buf = $array->[$mid][DATE_IND];

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

sub set_fundamentals_limit {
    my $lim = shift;
    $fund_pull_limit = $lim if $lim > $fund_pull_limit;
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

sub get_date_image {

    my $d = shift;
    
    my $rval = $d->image();
    substr $rval, 4, 0, "-";
    substr $rval, 7, 0, "-";

    return $rval;
}

1;
