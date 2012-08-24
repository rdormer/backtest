use TokyoCabinet;
use conf;
use DBI;

my $cab_directory;
my %base_dates;
my %date_lookup;
my $datehandle;
my $fundhandle;
my $splithandle;
my $divhandle;
my $d1;

my %epoch_date_cache;

sub init_mod {    

    init_date_handling();
    
    my $cabs = $ENV{TICKER_CAB_PATH};
    $cab_directory = ($cabs ? $cabs : "./CABS");

    $splithandle = TokyoCabinet::HDB->new();
    $splithandle->open("$cab_directory/splits", $splithandle->OREADER);

    $divhandle = TokyoCabinet::HDB->new();
    $divhandle->open("$cab_directory/dividends", $divhandle->OREADER);

    $datehandle = TokyoCabinet::HDB->new();
    $datehandle->open("$cab_directory/fund-dates", $datehandle->OREADER);

    $fundhandle = TokyoCabinet::FDB->new();
    $fundhandle->open("$cab_directory/fund-data", $fundhandle->OREADER);

    my $index = TokyoCabinet::HDB->new();
    $index->open("$cab_directory/epoch-index", $index->OREADER);

    $index->iterinit();
    while(defined(my $key = $index->iternext())){
	my $value = $index->get($key);
	if(defined($value)){
	    $base_dates{$key} = $value;
      	}
    }
}

sub open_history_file {
  
  my $filename = shift;
  $filename =~ tr/\//:/;
  my $tchandle = TokyoCabinet::FDB->new();
  $tchandle->open("$cab_directory/$filename", $tchandle->OREADER);
  return $tchandle;
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

    my $tchandle = open_history_file($ticker);
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

    my $tchandle = open_history_file($ticker);
    
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

    my $tchandle = open_history_file($ticker);
    
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
    my %funds;

    my $dateblock = $datehandle->get($ticker);
    my $startdate = get_epoch_date($sdate);
    my $index = 0;

    do {

	my $keyblock = substr($dateblock, $index, 8);
	my ($day, $key) = unpack("LL", $keyblock);

	if($day <= $startdate) {

	    my $d = {};
	    my $row = $fundhandle->get($key);
	    my @data = unpack("QQQQQQQQLLF", $row);

	    ($d->{'total_assets'}, $d->{'current_assets'}, $d->{'total_debt'}, $d->{'current_debt'}, 
	     $d->{'cash'}, $d->{'revenue'}, $d->{'avg_shares_diluted'}, $d->{'shares_outstanding'}, 
	     $d->{'equity'}, $d->{'net_income'}, $d->{'eps_diluted'}) = @data;

	    my $qtrdate = $date_lookup{$day};
	    $funds{$qtrdate} = $d;
	}

	$index += 8;

    } while ($index < length $dateblock && keys %funds < $count);

    return \%funds;
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
