use List::Util 'shuffle';
use Date::Business;
use screen_sql;

#a quick word about $current_prices - it's a reference to a multidimensional
#array containing the price data for the current ticker - index 0 is the most
#recent day, and incrementing the index decrements the day - in other words
#going forward through the array goes backwards through time

use constant {
    DATE_IND => 0,
    OPEN_IND => 1,
    HIGH_IND => 2,
    LOW_IND => 3,
    CLOSE_IND => 4,
    VOL_IND => 5
};

use constant {
    SPLIT_DATE => 0,
    SPLIT_BEFORE => 1,
    SPLIT_AFTER => 2
};

my $max_limit;
my $cache_size = 0;

my $current_date;
my $date_index;
my @date_range;

my $current_ticker;
my @ticker_list;

my %data_cache;
my %split_cache;

sub init_data {

    if(conf::list()) {

	open(INFILE, conf::list());
    
	while(<INFILE>) {
	    chomp;
	    push @ticker_list, $_;
	}
    }

    if(conf::ticker_list()) {

	my $list = conf::ticker_list();
	@ticker_list = split /,/, $list;
    }

    if(conf::randomize_list()) {
	@ticker_list = shuffle(@ticker_list);
    }

    if(conf::blacklist()) {
	my @list = split /,/, conf::blacklist();
	remove_tickers(\@list);
    }

    set_date_range(conf::start(), conf::finish());

    $date_index = -1;
    $max_limit = 1;
    init_mod();
    init_indicators();
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

    my $notdone = $date_index < $#date_range;

    if($notdone) {
	$date_index++;
	set_date($date_range[$date_index]);
    } else {
	set_date($date_range[$#date_range]);
    }

    if(! conf::noprogress()) {
#        conf::output("$current_date\n\b\b\b\b\b\b\b\b\b\b");
	conf::output($current_date);
    }

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

    if($#date_range > 0) {
	conf::override_date_range($date_range[0], $date_range[$#date_range]);
    }
}


#do a "context switch" of state to N days ago
#eval is sufficient because this is called 
#from filter_results, and all data is present

sub days_ago {

    my $daycount = shift;
    my $statement = shift;
    reset_indicators();

    my $save_date = get_date();
    my $save_pull = $current_prices;
    my $day = fetch_date_at($daycount);
    set_date($day);

    $current_prices = [];
    foreach($daycount..scalar @$save_pull) {
	push @$current_prices, $save_pull->[$_];
    }

    my $rval = eval($statement);
    $current_prices = $save_pull;
    set_date($save_date);
    reset_indicators();

    return $rval;
}

sub eval_expression {

    my $exp = shift;
    my $ticker = shift;
    my $day = get_date();

    reset_indicators();
    my $temp = $current_prices;
    $current_prices = pull_data($ticker, $day, $exp->[0][1], $exp->[0][1]);
    $current_prices = process_splits($ticker, $current_prices);

    my $rval = eval($exp->[0][0]);
    $current_prices = $temp;
    return $rval;
}

sub force_data_load {
    $current_ticker = shift;
    return 1;
}

sub trade_filter {

    my $filter = shift;
    my $len = scalar @$filter - 1;

    for(my $i = 0; $i <= $len; $i++) {

	if($filter->[$i][1] == 0) {
	    eval($filter->[$i][0]);
	} else {
	    my $last = scalar @$filter - 1;
	    my @temp = map { [@$_] } @$filter[$i..$last];
	    return filter_results($current_ticker, \@temp);
	}
    }
}

sub run_filter {

    my $filter = shift;

    if(@$filter > 0 ) {
	$max_limit = $filter->[scalar @$filter - 1][1];
	return trade_filter($filter);
    }

    return 1;
}

sub run_screen_loop {

    my $stop = shift;
    my $criteria = shift;
    my @results;

    if(run_filter(shift)) {

	$max_limit = $criteria->[scalar @$criteria - 1][1];

	foreach $ticker (@ticker_list) {

	    if(filter_results($ticker, $criteria)) {
		push @results, $ticker;
		last if &$stop(scalar @results);
	    }
	}
    }

    return @results;
}

sub filter_results {

    $current_ticker = shift;
    my $criteria = shift;
    $current_prices = ();

    reset_indicators();
    my $date = get_date();

    for(my $i = 0; $i < scalar @$criteria; $i++) {

	#set pull size and get the next batch
	#of data to evaluate the current statement

	my $maximum = $criteria->[$i][1];
	my $count = 1;

	if($maximum > 1) {

	    $count = ($maximum - scalar @$current_prices);
	    $count++ if $i > 0;
	}

	my $data = pull_data($current_ticker, $date, $count, $maximum);
	my $last = $#{$data};

	#two cases to check for - one where we've pulled new data,
	#and one where we don't need to because there are two or more
	#statements that need the same amount of data.  Also, we
	#only need to check the volume on the first iteration of the loop.

	if(($last >= 0 && ($i > 0 ? 1 : $data->[0][VOL_IND] > 0)) || 
	   ($maximum > 1 && $count == 1)) {
	    
	    $data = process_splits($current_ticker, $data);
	    $date = $data->[$last][DATE_IND] if $last >= 0;
	    shift @$data if $i > 0;
	    push @$current_prices, @$data;

	    $result = eval($criteria->[$i][0]);
	    return 0 unless $result;

	} else {
	    return 0;
	}
    }

    return check_for_gaps();
}

sub pull_data {

    my $ticker = shift;
    my $sdate = shift;
    my $count = shift;
    my $max = shift;

    return if $sdate eq "";

    if(exists $data_cache{$ticker} && conf::usecache()) {

	my $fromcache = from_cache($ticker);
	my $needpull = $fromcache->[0][DATE_IND] lt $sdate;

	#add data to the front of the cache if we need to

	if($needpull) {

	    my $cdata = pull_history_by_dates($ticker, $fromcache->[0][DATE_IND], $sdate);

	    if($fromcache->[0][DATE_IND] lt $cdata->[0][DATE_IND]) {
		pop @$cdata if scalar @$cdata > 1;
		unshift @$fromcache, @$cdata;
	    }
	}

	#now check the back of the cache, add data if we need
	#to, and trim it down to keep memory if we don't.  Only
	#trim memory if we needed to add an entry, though.

	my $cachelen = scalar @$fromcache;

	if($cachelen < $max) {

	    my $number = $count;

	    #we only need to change the count if we're pulling data 
	    #from within the cache, or starting at the top of the cache, 
	    #and we don't have enough in it

	    if($cachelen < $count && $fromcache->[0][DATE_IND] eq $sdate) {
		$number = ($count - $cachelen) + 1;
	    } elsif ($fromcache->[0][DATE_IND] gt $sdate) {
		my $start = search_array_date($sdate, $fromcache);
		$number = $count - ($cachelen - $start) + 1;
	    }

	    my $enddate = $fromcache->[$cachelen - 1][DATE_IND];
	    my $remain = pull_history_by_limit($ticker, $enddate, $number);

	    shift @$remain;
	    push @$fromcache, @$remain;

	} elsif ($cachelen > $max_limit) {
	    my $trim = $cachelen - $max_limit;
	    splice @$fromcache, -($trim), $trim;
	}

	#store back to the cache, and return data
	#trimmed down to match the size of our request

	to_cache($ticker, $fromcache);
	return trim_data_array($fromcache, $sdate, $count);
    }

    #if we get here we're either not using the cache
    #or didn't have any data in it for this ticker yet

    my $cdata = pull_history_by_limit($ticker, $sdate, $count);

    if(conf::usecache() && scalar @$cdata > 0) {
	to_cache($ticker, $cdata);
    }

    return $cdata;
}

sub trim_data_array {

    my $data = shift;
    my $date = shift;
    my $count = shift;

    #don't even bother if we 
    #don't have enough data
    return if scalar @$data < $count;

    $start = search_array_date($date, $data);
    $end = $start + $count - 1;

    my @rval = ();
    foreach $i ($start..$end) {
	push @rval, $data->[$i] if $data->[$i];
    }

    if(scalar @rval == $count) {
	return \@rval;
    }
}

#grab split data and apply it to the price data we've pulled.
#note that this is the only remaining routine not using the
#index constants

sub process_splits {

    my $ticker = shift;
    my $hist = shift;
    my $splitlist;

    if(exists $split_cache{$ticker}) {
	$splitlist = $split_cache{$ticker};
    } else {
	$splitlist = pull_splits($ticker);
	$split_cache{$ticker} = $splitlist if conf::usecache();
    }
    
    my $enddate = (scalar @$date_range > 0 ? $date_range[$#date_range] : $current_date);
    my $histlen = scalar @$hist - 1;

    return if $histlen < 0;

    foreach $split (@$splitlist) {

	#if split date is before the last day of the 
	#simulation then try to process it

	if($split->[SPLIT_DATE] le $enddate) {

	    #if we're using cached data we need to 
	    #copy it first to avoid corrupting the cache

	    if(exists $data_cache{$ticker}) {

		my @rval;
		foreach (@$hist) {
		    push @rval, [@$_];
		}
		
		$hist = \@rval;
	    }

	    my $ind = 0;

	    #if the split date is less than the last day of 
	    #pulled data, search for the split point within that data

	    if($split->[SPLIT_DATE] le $hist->[0][DATE_IND]) {
		$ind = search_array_date($split->[SPLIT_DATE], $hist);
	    }

	    my $splitratio = $split->[SPLIT_BEFORE] / $split->[SPLIT_AFTER];

	    for(my $i = $histlen; $i > $ind; $i--) {
		@tt = map $_ * $splitratio, ($hist->[$i][1], $hist->[$i][2], $hist->[$i][3], $hist->[$i][4]);
		splice @{$hist->[$i]}, 1, 4, @tt;
	    }
	}
    }

    return $hist;
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

#checks validity of statements by trying to evaluate them
#and inspecting the flag for eval.  We have to do this
#since statements are executed dynamically, so we can't 
#know if they have errors until we try to run them.

sub check_runtime_errors {

    my $day = (get_date() ? get_date() : $date_range[0]);
    generate_bogus_fundamentals($day);
    my $t = $current_prices;

    my @row;
    $row[OPEN_IND] = 1;
    $row[HIGH_IND] = 3;
    $row[LOW_IND] = 0.5;
    $row[CLOSE_IND] = 2;

    foreach $statements (@_) {

	next if scalar @$statements == 0;

	$current_prices = ();
	my $len = $statements->[scalar @$statements - 1][1];

	for(0..$len) {
	    push @$current_prices, \@row;
	}

	foreach(@$statements) {
	    eval($_->[0]);
	    conf::output("syntax error on statement '" . statement_from_action($_->[0]) . "'", 1) if $@;
	}
    }

    $current_prices = $t;
}

sub remove_tickers {

    my $blacklist = shift;

    foreach $remove (@$blacklist) {

	for(my $i = 0; $i < scalar @ticker_list; $i++) {
	    
	    if($ticker_list[$i] eq $remove) {
		$foo = splice @ticker_list, $i, 1;
		last;
	    }
	}
    }
}

sub to_cache {

    my $ticker = shift;
    my $data = shift;
    my $rowc = scalar @$data;

    if(exists $data_cache{$ticker}) {
	my $t = $data_cache{$ticker};
	$cache_size -= scalar @$t;
	$cache_size += $rowc;
	$data_cache{$ticker} = $data;
    
    } elsif($cache_size < conf::cache_size()) {
	$data_cache{$ticker} = $data;
	$cache_size += $rowc;
    }
}

sub from_cache {
    my $ticker = shift;
    return $data_cache{$ticker};
}

sub check_for_gaps {
 
    my $len = scalar @$current_prices;
    my $d1 = fetch_date_at(0);
    
    $d1 =~ s/-//g;
    my $date1 = new Date::Business(DATE => $d1);
    
    for($i = 1; $i < $len; $i++) {
      $d2 = fetch_date_at($i);
      $d2 =~ s/-//g;
      $date2 = new Date::Business(DATE => $d2);
      return 0 if $date1->diffb($date2) > 5;
      $date1 = $date2;
    }

    return 1;
}

sub show {

   my $ref = shift;
   
   print "\narray length is " . scalar @$ref;
   print " for $current_ticker";

   foreach(@$ref) {
       print "\n$_->[0]\t$_->[1]\t$_->[2]\t$_->[3]\t$_->[4]\t$_->[5]";
   }

   print "\n======";
}

1;
