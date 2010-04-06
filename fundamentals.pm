use screen_data;
use indicators;

sub fundamental_eps { return $current_fundamentals{'eps_diluted'}; }
sub fundamental_dcf { return compute_dcf_valuation($current_fundamentals{'eps_diluted'}, 0, 1, 7); }
sub fundamental_mcap { return $current_fundamentals{'shares_outstanding'} * fetch_close_at(0); }

sub fundamental_current_ratio { 
    return $current_fundamentals{'current_assets'} / $current_fundamentals{'current_debt'}; 
}

sub fundamental_pershare_revenue {
    return $current_fundamentals{'revenue'} / $current_fundamentals{'avg_shares_diluted'};
}

sub fundamental_price_sales {
    return fetch_close_at(0) / fundamental_pershare_revenue();
}

sub fundamental_profit_margin {
    return ($current_fundamentals{'net_income'} / $current_fundamentals{'revenue'}) * 100;
}

sub fundamental_roa {
    return $current_fundamentals{'net_income'} / $current_fundamentals{'total_assets'};
}

sub fundamental_roe { 
    return $current_fundamentals{'net_income'} / $current_fundamentals{'equity'};
}

sub fundamental_pershare_book {
    return $current_fundamentals{'equity'} / $current_fundamentals{'shares_outstanding'};
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

sub fundamental_float { return $current_fundamentals{'total_float'}; };
sub fundamental_egrowth { return $current_fundamentals{'qtrly_earnings_growth'}; }

1;
