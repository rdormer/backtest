use Cache::Memcached::Fast;
use TokyoCabinet;
use conf;

my %base_dates;
my %date_lookup;
my $splithandle;
my $divhandle;
my $d1;

my %epoch_date_cache;
my $cache_handle;

sub init_mod {    

    init_date_handling();

    $splithandle = TokyoCabinet::HDB->new();
    $splithandle->open("./CABS/splits", $splithandle->OREADER);

    $divhandle = TokyoCabinet::HDB->new();
    $divhandle->open("./CABS/dividends", $divhandle->OREADER);

    my $index = TokyoCabinet::HDB->new();
    $index->open("./CABS/epoch-index", $index->OREADER);

    $index->iterinit();
    while(defined(my $key = $index->iternext())){
	my $value = $index->get($key);
	if(defined($value)){
	    $base_dates{$key} = $value;
      	}
    }

    $cache_handle = new Cache::Memcached::Fast(  
	{servers => [{address => '/tmp/mcd.sock', noreply => 1}] ,
	 serialize_methods => [ \&store_history, \&unstore_history ]}
	);
}


sub store_history {

    my $ref = shift;
    my $rval = "";

    foreach(@$ref) {
	$rval .= pack("a10FFFFL", @$_);
    }

    return $rval;
}

sub unstore_history {

    my $len = length $_[0];
    my $idx = 0;

    my @rval;

    while($idx < $len) {
	
	my @t = unpack( "a10FFFFL", substr($_[0], $idx, 46));
	$idx += 46;

	if($t[0] != 0) {
	    push @rval, \@t;
	}
    }

    return \@rval;
}


sub init_date_handling {

    #create epoch starting 1/2/1950
    $d1 = new Date::Business(DATE => "19700101");
    $d1->subb(5218);

    #create mapping of epoch days to regular dates

    my $d = conf::finish();
   $d =~ s/-//g;

    my $curdate = new Date::Business(DATE => $d);
    my $startepoch = get_epoch_date(conf::start()) - 1000;  #TODO - fix this
    my $endepoch = get_epoch_date(conf::finish());

    for(my $i = $endepoch; $i >= $startepoch; $i--) {
	
	my $dstring = $curdate->image();
	substr $dstring, 4, 0, "-";
	substr $dstring, 7, 0, "-";
	$date_lookup{$i} = $dstring;
	$curdate->prevb();
    }
}

sub pull_history_by_limit {
    
    my $ticker = shift;
    my $date = shift;
    my $limit = shift;

    my $last = get_epoch_date($date) - $base_dates{$ticker};
    my $first = $last - $limit;

    return if $last < $limit;
    $first = 0 if $first < 0;

    my $mcd_data = $cache_handle->get($ticker);

    if(! $mcd_data) {

	my $data = read_loop($ticker, $first, $last, $limit);
	$cache_handle->set($ticker, $data);
	return $data;
    } 

    my $rval = read_from_mcache($mcd_data, $ticker, $first, $last);
    return $rval if $rval;

    $rval = extend_mcache_start($mcd_data, $ticker, $first, $last);
    return $rval if $rval;

    $rval = extend_mcache_end($mcd_data, $ticker, $first, $last);
    return $rval if $rval;
}

sub read_from_mcache {

    my $cachedat = shift;
    my $ticker = shift;
    my $start = shift;
    my $end = shift;

    my $lastindex = scalar @$cachedat - 1;
    my $mcd_start = get_epoch_date($cachedat->[0][DATE_IND]) - $base_dates{$ticker};
    my $mcd_end = get_epoch_date($cachedat->[$lastindex][DATE_IND]) - $base_dates{$ticker};

    if($mcd_start >= $end && $mcd_end <= $start) {

	my $edate = $date_lookup{ $end + $base_dates{$ticker} };
	my $f = search_array_date($edate, $cachedat);
	my @temp;

	for($i = 0; $i <= ($end - $start); $i++) {
	    push @temp, $cachedat->[$f];
	    $f++;
	}

	return \@temp;
    }
}

sub extend_mcache_end {

    my $cachedat = shift;
    my $ticker = shift;
    my $start = shift;
    my $end = shift;

    my $mcd_end = get_epoch_date($cachedat->[0][DATE_IND]) - $base_dates{$ticker};

    if($end > $mcd_end) {

	my $pulled = read_loop($ticker, $mcd_end, $end, $end - $mcd_end);
	
	my $i = 0;
	while(($pulled->[$i][DATE_IND] == $cachedat->[0][DATE_IND]) && $i < scalar (@$pulled)) {
	    $i++;
	}

	unshift @$cachedat, @$pulled[0..$i];
	$cache_handle->set($ticker, $cachedat);
	return $cachedat;
    }
}


sub extend_mcache_start {

    my $cachedat = shift;
    my $ticker = shift;
    my $start = shift;
    my $end = shift;

    my $lastindex = scalar @$cachedat - 1;
    my $mcd_start = get_epoch_date($cachedat->[$lastindex][DATE_IND]) - $base_dates{$ticker};

    if($start < $mcd_start) {

	my $enddate = get_epoch_date($cachedat->[$lastindex][DATE_IND]);
	$enddate -= $base_dates{$ticker} + 1;
	
	my $pulled = read_loop($ticker, $start, $enddate, $enddate - $start);
	push @$cachedat, @$pulled;

	$cache_handle->set($ticker, $cachedat);
	return $cachedat;
    }
}

sub read_loop {

    my $ticker = shift;
    my $first = shift;
    my $last = shift;
    my $limit = shift;
    my @rval;

    my $tchandle = TokyoCabinet::FDB->new();
    $tchandle->open("./CABS/$ticker", $tchandle->OREADER);

    return if $first > $tchandle->rnum();

    foreach $curdate ($first..$last) {

	my @row = unpack("FFFFL", $tchandle->get($curdate));

	if($row[0] != "") {

	    unshift @row, $date_lookup{ ($curdate + $base_dates{$ticker}) };
	    unshift @rval, \@row; 
	}
    }

    my $left = $limit - @rval;
    my $i = $first - 1;

    while($left >= 0 && $i >= 0) {

	my @row = unpack("FFFFL", $tchandle->get($i));

	if($row[0] != "") {

	    unshift @row, $date_lookup{ ($i + $base_dates{$ticker}) };
	    push @rval, \@row; 
	    $left--;
	}

	$i--;
    }


    $tchandle->close();
    return \@rval;
}

sub pull_history_by_dates {

    my $ticker = shift;
    my $sdate = shift;
    my $edate = shift;

    #because of holidays this will end
    #up pulling slightly more than necessary 

    my $start = get_epoch_date($sdate) - $base_dates{$ticker};
    my $end = get_epoch_date($edate) - $base_dates{$ticker};
    my $lim = $end - $start;

    return pull_history_by_limit($ticker, $edate, $lim); 
}

sub pull_close_on_date {

    my $ticker = shift;
    my @closes;

    my $tchandle = TokyoCabinet::FDB->new();
    $tchandle->open("./CABS/$ticker", $tchandle->OREADER);

    foreach $day (@_) {
	my $index = get_epoch_date($day) - $base_dates{$ticker};
	my @temp = unpack("FFFFL", $tchandle->get($index));
	push @closes, $temp[3];
    }

    $tchandle->close();
    return @closes;
}

sub pull_dividends {

    my $ticker = shift;
    my $startdate = shift;
    my $enddate = shift;
    my %divs;
    
    my $start = get_epoch_date($startdate) - $base_dates{$ticker};
    my $end = get_epoch_date($enddate) - $base_dates{$ticker};
    my $rawdata = $divhandle->get($ticker);

    for(my $i = 0; $i < length $rawdata; $i += 12) {

	my $part = substr $rawdata, $i, 12;
	my @div = unpack("LF", $part);

	if($div[0] >= $start && $div[0] <= $end) {

	    #need to insert into a hash with a named key
	    #for backwards compatibility with screen_sql.pm
	    my $day = $date_lookup{ $div[0] + $base_dates{$ticker} };
	    $divs{$day}->{'divamt'} = $div[1];
	}
    }

    return \%divs;
}

sub pull_splits {

    my $ticker = shift;
    my $sdate = shift;
    my $edate = shift;
    my @splits;

    my $start = get_epoch_date($sdate) - $base_dates{$ticker};
    my $end = get_epoch_date($edate) - $base_dates{$ticker};
    my $rawdata = $splithandle->get($ticker);

    for(my $i = 0; $i < length $rawdata; $i += 8) {

	my $part = substr $rawdata, $i, 8;
	my @split = unpack("LSS", $part);

	if($split[0] >= $start && $split[0] <= $end) {
	    $split[0] = $date_lookup{ $split[0] + $base_dates{$ticker} };
	    push @splits, \@split;
	}
    }

    return \@splits;
}

sub pull_fundamentals {

    my $ticker = shift;
    my $sdate = shift;
    my $count = shift;

#    $fund_sql->execute($ticker, $sdate, $count);
#    return $fund_sql->fetchall_hashref('quarter_date');
}

sub get_epoch_date {

    my $date = shift;
    $date =~ s/-//g;

    return $epoch_date_cache{$date} if exists $epoch_date_cache{$date};
    
    my $d2 = new Date::Business(DATE => $date);
    $epoch_date_cache{$date} = $d2->diffb($d1);
    return $epoch_date_cache{$date};
}



1;