use TokyoCabinet;
use conf;
use DBI;

my %base_dates;
my %date_lookup;
my $splithandle;
my $divhandle;
my $d1;

my %epoch_date_cache;

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
    my @rval;

    my $tchandle = TokyoCabinet::FDB->new();
    $tchandle->open("./CABS/$ticker", $tchandle->OREADER);
    
    my $last = get_epoch_date($date) - $base_dates{$ticker};
    my $first = $last;
    
    $first -= $limit - 1 if $limit > 1;
    if(($last + 1) < $limit || ($first + 1) < 1) {
	$tchandle->close();
	return;
    }

    foreach $curdate ($first .. $last) {

	my @row = unpack("FFFFL", $tchandle->get($curdate + 1));

	if($row[0] != "") {

	    unshift @row, $date_lookup{ ($curdate + $base_dates{$ticker}) };
	    unshift @rval, \@row; 
	}
    }

    my $left = $limit - @rval - 1;
    my $i = $first - 1;

    while($left >= 0 && $i >= 0) {

	my @row = unpack("FFFFL", $tchandle->get($i + 1));

	if($row[0] != "") {

	    unshift @row, $date_lookup{ ($i + $base_dates{$ticker}) };
	    push @rval, \@row; 
	    $left--;
	}

	$i--;
    }

    $tchandle->close();

    if(scalar @rval == $limit) {
	return \@rval;
    }
}

sub pull_history_by_dates {

    my $ticker = shift;
    my $sdate = shift;
    my $edate = shift;
    my @rval;

    #because of holidays this will end
    #up pulling slightly more than necessary 

    my $start = get_epoch_date($sdate) - $base_dates{$ticker};
    my $end = get_epoch_date($edate) - $base_dates{$ticker};
    $start = 0 if $start < 0;

    my $tchandle = TokyoCabinet::FDB->new();
    $tchandle->open("./CABS/$ticker", $tchandle->OREADER);

    foreach $curdate ($start..$end) {
	
	my @row = unpack("FFFFL", $tchandle->get($curdate + 1));

	if($row[0] != "") {

	    unshift @row, $date_lookup{ ($curdate + $base_dates{$ticker}) };
	    unshift @rval, \@row; 
	}
    }

    $tchandle->close();
    return \@rval;
}

sub pull_close_on_date {

    my $ticker = shift;
    my @closes;

    my $tchandle = TokyoCabinet::FDB->new();
    $tchandle->open("./CABS/$ticker", $tchandle->OREADER);

    foreach $day (@_) {
	my $index = get_epoch_date($day) - $base_dates{$ticker};
	my @temp = unpack("FFFFL", $tchandle->get($index + 1));
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
    my @splits;

    my $rawdata = $splithandle->get($ticker);

    for(my $i = 0; $i < length $rawdata; $i += 8) {

	my $part = substr $rawdata, $i, 8;
	my @split = unpack("LSS", $part);

	$split[0] = $date_lookup{ $split[0] + $base_dates{$ticker} };
	push @splits, \@split;
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
