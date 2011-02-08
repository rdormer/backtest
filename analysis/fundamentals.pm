use screen_data;
use analysis::indicators;

my %current_fundamentals;
my $current_ticker;
my @date_list;

sub fundamental_egrowth { return $current_fundamentals{'qtrly_earnings_growth'}; }

sub load_precheck {

    my $ticker = shift;
    my $count = shift;

    return if $ticker eq "";

    $count++;

    if($current_ticker ne current_ticker()) {
	%current_fundamentals = ();
	@date_list = ();
    }

    my $qtr_count = scalar keys %current_fundamentals;

    if($count > $qtr_count) {

	my $fdate = get_date();

	if($qtr_count > 0) {
	    $fdate = subtract_day($date_list[$#date_list]);
	    $count -= $qtr_count;
	}

	$current_ticker = current_ticker();
	my $temp = pull_fundamentals($current_ticker, $fdate, $count);
    
	%current_fundamentals = %$temp;
	push @date_list, reverse sort keys %current_fundamentals;
    }
}

sub subtract_day {

    my $day = shift;

    $day =~ s/-//g;
    $date = new Date::Business(DATE => $day);
    $date->subb(1);

    my $rval = $date->image();
    substr $rval, 4, 0, "-";
    substr $rval, 7, 0, "-";

    return $rval;
}

sub get_basic {

    my $index = shift;
    my $value = shift;

    load_precheck(current_ticker(), $index);
    return $current_fundamentals{$date_list[$index]}{$value};
}

sub fundamental_total_assets {
    return get_basic(shift, 'total_assets');
}

sub fundamental_current_assets {
    return get_basic(shift, 'current_assets');
}

sub fundamental_total_debt {
    return get_basic(shift, 'total_debt');
}

sub fundamental_current_debt {
    return get_basic(shift, 'current_debt');
}

sub fundamental_cash {
    return get_basic(shift, 'cash');
}

sub fundamental_equity {
    return get_basic(shift, 'equity');
}

sub fundamental_net_income {
    return get_basic(shift, 'net_income');
}

sub fundamental_revenue {
    return get_basic(shift, 'revenue');
}

sub fundamental_mcap { 

    my $index = shift;
    load_precheck(current_ticker(), $index);
    return $current_fundamentals{$date_list[$index]}{'shares_outstanding'} * fetch_close_at(0);
}

sub fundamental_eps {

    my $index = shift;
    load_precheck(current_ticker(), $index);
    return $current_fundamentals{$date_list[$index]}{'eps_diluted'};
}

sub fundamental_float { 

    my $index = shift;
    load_precheck(current_ticker(), $index);
    return $current_fundamentals{$date_list[$index]}{'total_float'}; 
}

sub fundamental_current_ratio { 

    my $index = shift;
    load_precheck(current_ticker(), $index);
    my $current = $current_fundamentals{$date_list[$index]};
    return $current->{'current_assets'} / $current->{'current_debt'}; 
}

sub fundamental_roe { 

    my $index = shift;
    load_precheck(current_ticker(), $index);
    my $current = $current_fundamentals{$date_list[$index]};
    return $current->{'net_income'} / $current->{'equity'};
}

sub fundamental_roa {

    my $index = shift;
    load_precheck(current_ticker(), $index);
    my $current = $current_fundamentals{$date_list[$index]};
    return $current->{'net_income'} / $current->{'total_assets'};
}

sub fundamental_pershare_revenue {

    my $index = shift;
    load_precheck(current_ticker(), $index);
    my $current = $current_fundamentals{$date_list[$index]};
    return $current->{'revenue'} / $current->{'avg_shares_diluted'};
}

sub fundamental_profit_margin {

    my $index = shift;
    load_precheck(current_ticker(), $index);
    my $current = $current_fundamentals{$date_list[$index]};
    return ($current->{'net_income'} / $current->{'revenue'}) * 100;
}

sub fundamental_pershare_book {

    my $index = shift;
    load_precheck(current_ticker(), $index);
    my $current = $current_fundamentals{$date_list[$index]};
    return $current->{'equity'} / $current->{'shares_outstanding'};
}

sub fundamental_price_sales {
    return fetch_close_at(0) / fundamental_pershare_revenue();
}

sub fundamental_yearly_dividend {

    my $today = get_date();

    my $d = $today;
    $d =~ s/-//g;
    my $start = new Date::Business(DATE => $d);
    $start->sub(365);

    #reset to previous business day if 
    #exactly one year ago was not a business day
    if($start->day_of_week() == 0 || $start->day_of_week() == 6) {
	$start->prevb() 
    }

    my $rval = $start->image();
    substr $rval, 4, 0, "-";
    substr $rval, 7, 0, "-";

    my $divs = pull_dividends(current_ticker(), $rval, $today);
    my $sum = 0;

    foreach(keys %$divs) {
	$sum += $divs->{$_}->{'divamt'};
    }

    return $sum;
}

sub fundamental_div_yield {
    return (fundamental_yearly_dividend() / fetch_close_at(0)) * 100;
}

sub fundamental_price_earnings {
    return fetch_close_at(0) / fundamental_yearly_eps();
}

sub fundamental_yearly_eps {

    #don't care about return value
    #just forcing a load here

    fundamental_eps(3);
    my $eps = 0;

    for(my $i = 0; $i < 4; $i++) {
	$eps += $current_fundamentals{$date_list[$index]}{'eps_diluted'};
    }

    return $eps;
}

sub fundamental_payout_ratio {
    return sprintf("%.2f", (fundamental_yearly_dividend() / fundamental_yearly_eps()) * 100);
}

sub fundamental_dcf {

    my $init_growth = shift;
    my $perp_growth = shift;
    my $benchmark = shift;

    my $eps = fundamental_yearly_eps();
    return 0 if $perp_growth >= $benchmark;
    return 0 if $eps <= 0;

    $eps *= (1 + ($init_growth/100));  	
    $dcf = $eps / (1 + ($benchmark/100));

    $eps *= (1 + ($init_growth/100));  	
    $dcf += $eps / (1 + ($benchmark/100)) ** 2;

    for($i = 3; $i < 500; $i++) {

	$eps *= (1 + ($perp_growth/100));  	
	$dcf += $eps / (1 + ($benchmark/100)) ** $i;
    }

    return sprintf("%.2f", $dcf);
}

1;
