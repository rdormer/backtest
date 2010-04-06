use screen_data;

sub fundamental_eps { return $current_fundamentals{'eps'}; }
sub fundamental_roe { return $current_fundamentals{'return_on_equity'}; }
sub fundamental_mcap { return $current_fundamentals{'mcap'}; }
sub fundamental_float { return $current_fundamentals{'total_float'}; };
sub fundamental_egrowth { return $current_fundamentals{'qtrly_earnings_growth'}; }
sub fundamental_current_ratio { return $current_fundamentals{'current_ratio'}; }

sub fundamental_dcf { return indicator_dcf_valuation($current_fundamentals{'eps'}, 0, 1, 7); }

sub indicator_dcf_valuation {

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
