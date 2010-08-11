use Date::Business;
use screen_sql;

#these have to stay non-local for indicators.pm to work
#a quick word about $current_prices - it's a reference to a multidimensional
#array containing the price data for the current ticker - index 0 is the most
#recent day, and incrementing the index decrements the day - in other words
#going forward through the array goes backwards through time

#apparently not actually needed - but i'm keeping them 
#as comments for documentation purposes

#$current_prices;
#%value_cache;
#%current_fundamentals;

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

my @fundamental_list;
my $sweep_statement;

my $current_date;
my $today_obj;
my $date_index;
my @date_range;
my $current_ticker;

my $fund_pull_limit;
my @ticker_list;

my %data_cache;
my %split_cache;
my $progress;

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

    if(conf::cgi_handle()) {
	
	$progress = shmget(IPC_PRIVATE, 1000000, IPC_CREAT | IPC_EXL | 0777 );
	
	open INFILE, ">", conf::cgi_handle();
	print INFILE $progress;
	close INFILE;
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

    if(conf::cgi_handle()) {
	write_cgi($current_date);
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

    if($#date_range > 0) {
	conf::override_date_range($date_range[0], $date_range[$#date_range]);
    }
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

    for(my $i = 0; $i < scalar @_; $i++) {

	#set pull size and get the next batch
	#of data to evaluate the current statement

	my $maximum = $_[$i][1];
	my $count = 1;

	if($maximum > 1) {

	    $count = ($maximum - scalar @$current_prices);
	    $count++ if $i > 0;
	}

	my $data = pull_data($current_ticker, $date, $count, $maximum);
	my $last = $#{$data};

	#two cases to check for - one where we've pulled new data,
	#and one where we don't need to because there are two or more
	#statements that need the same amount of data

	if(($maximum > 1 && $count == 1) || ($last >= 0 && $data->[0][VOL_IND] > 0)) {

	    process_splits($current_ticker, $data);

	    $date = $data->[$last][DATE_IND] if $last >= 0;
	    shift @$data if $i > 0;
	    push @$current_prices, @$data;
	    return 0 if not eval($_[$i][0]);

	} else {
	    return 0;
	}
    }

    return 1;
}

sub pull_data {

    my $ticker = shift;
    my $sdate = shift;
    my $count = shift;
    my $max = shift;

    return if $sdate eq "";

    if(exists $data_cache{$ticker} && conf::usecache()) {

	my $fromcache = $data_cache{$ticker};
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
	    $number = ($count - $cachelen) + 1 if $cachelen < $count;
	    my $enddate = $fromcache->[$cachelen - 1][DATE_IND];
	    my $remain = pull_history_by_limit($ticker, $enddate, $number);

	    shift @$remain;
	    push @$fromcache, @$remain;

	} elsif ($cachelen > $max_limit && $needpull) {
	    pop @$fromcache;
	}

	#store back to the cache, and return data
	#trimmed down to match the size of our request

	$data_cache{$ticker} = $fromcache;
	return trim_data_array($fromcache, $sdate, $count);
    }

    #if we get here we're either not using the cache
    #or didn't have any data in it for this ticker yet

    my $cdata = pull_history_by_limit($ticker, $sdate, $count);

    if(conf::usecache() && scalar @$cdata > 0) {
	$data_cache{$ticker} = $cdata;
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

    my $start = 0;
    my $end = $#{$data};

    #if we actually need to trim...
    if(scalar @$data > $count) {

	$start = search_array_date($date, $data);
	$end = $start + $count - 1;
    }

    #copy data so we don't corrupt cache
    my @rval = ();
    foreach $i ($start..$end) {
	push @rval, [@{$data->[$i]}] if $data->[$i];
    }

    return \@rval;
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
    
    my $enddate = $date_range[$#date_range];
    my $histlen = scalar @$hist - 1;

    return if $histlen < 0;

    foreach $split (@$splitlist) {

	#if the current split is before the 
	#last day of our run and above current segment

	if($split->[SPLIT_DATE] le $enddate && $split->[SPLIT_DATE] gt $hist->[$histlen][DATE_IND]) {

	    my $ind = $histlen;

	    #if the current split is before the last day of our run,
	    #but the last date of our data is after it, it's in this segment

	    if($hist->[$0][DATE_IND] ge $split->[SPLIT_DATE]) {
		$ind = search_array_date($split->[SPLIT_DATE], $hist);
	    }

	    my $splitratio = $split->[SPLIT_BEFORE] / $split->[SPLIT_AFTER];

	    for(my $i = $histlen; $i > $ind; $i--) {
		@tt = map $_ * $splitratio, ($hist->[$i][1], $hist->[$i][2], $hist->[$i][3], $hist->[$i][4]);
		splice @{$hist->[$i]}, 1, 4, @tt;
	    }
	}
    }
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

sub write_cgi {

    my $data = shift;
    $data = "###$data###" if length $data > 10;
    shmwrite($progress, $data, 0, length $data);
}

sub change_over_period {

    my $ticker = shift;
    my ($start, $end) = pull_close_on_date($ticker, $date_range[0], $date_range[$#date_range]);

    if($start > 0) {
	return (($end - $start) / $start) * 100;
    }

    return -100;
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
