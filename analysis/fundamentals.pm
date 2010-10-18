use screen_data;
use analysis::indicators;

my %current_fundamentals;
my $current_ticker;
my @date_list;

sub fundamental_dcf { return compute_dcf_valuation($current_fundamentals{'eps_diluted'}, 0, 1, 7); }
sub fundamental_egrowth { return $current_fundamentals{'qtrly_earnings_growth'}; }

sub load_precheck {

    my $ticker = shift;
    return if $current_ticker eq current_ticker();

    my $count = shift;
    $current_ticker = current_ticker();
    my $temp = pull_fundamentals($current_ticker, get_date(), $count + 1);
    %current_fundamentals = %$temp;
    @date_list = reverse sort keys %current_fundamentals;
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

    my $d = $date_list[$index];
    $d =~ s/-//g;

    #if reporting day was a weekend, then
    #we use next bussiness day for fetching close
    my $date = new Date::Business(DATE => $d);
    my $wday = $date->day_of_week();

    if($wday == 0 || $wday == 6) {
	$date->nextb();
    }

    #re-insert dashes
    my $d = $date->image();
    substr $d, 4, 0, "-";
    substr $d, 7, 0, "-";

    my @close = pull_close_on_date(current_ticker(), $d);
    return $current_fundamentals{$date_list[$index]}{'shares_outstanding'} * $close[0];
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

sub compute_dcf_valuation {

    my $eps = shift;
    my $init_growth = shift;
    my $perp_growth = shift;
    my $benchmark = shift;
    	
    $eps *= (1 + ($init_growth/100));  	
    $dcf = $eps / (1 + ($benchmark/100));

    $eps *= (1 + ($init_growth/100));  	
    $dcf += $eps / (1 + ($benchmark/100)) ** 2;

    for($i = 3; $i < 100; $i++) {

	$eps *= (1 + ($perp_growth/100));  	
	$dcf += $eps / (1 + ($benchmark/100)) ** $i;
    }

    return $dcf;
}

1;
