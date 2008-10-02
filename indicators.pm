use rstrength;
use screen_sql;

sub fetch_strength { return relative_strength(current_ticker(), shift); }
sub fetch_volatility { return statistical_volatility(shift); }

sub fetch_open_at { return $current_prices->[shift][2]; }
sub fetch_high_at { return $current_prices->[shift][3]; }
sub fetch_low_at { return $current_prices->[shift][4]; }
sub fetch_close_at { return $current_prices->[shift][5]; }
sub fetch_volume_at { return $current_prices->[shift][7]; }
sub fetch_date_at { return $current_prices->[shift][1]; }

sub max_open { return array_max(shift, 2); }
sub max_high { return array_max(shift, 3); }
sub max_low { return array_max(shift, 4); }
sub max_close { return array_max(shift, 5); }
sub max_volume { return array_max(shift, 7); }

sub min_open { return array_min(shift, 2); }
sub min_high { return array_min(shift, 3); }
sub min_low { return array_min(shift, 4); }
sub min_close { return array_min(shift, 5); }
sub min_volume { return array_min(shift, 7); }

sub avg_open { return array_avg(shift, 2); }
sub avg_high { return array_avg(shift, 3); }
sub avg_low { return array_avg(shift, 4); }
sub avg_close { return array_avg(shift, 5); }
sub avg_volume { return array_avg(shift, 7); }

sub exp_avg_open { return array_exponential_avg(shift, 2); }
sub exp_avg_high { return array_exponential_avg(shift, 3); }
sub exp_avg_low { return array_exponential_avg(shift, 4); }
sub exp_avg_close { return array_exponential_avg(shift, 5); }
sub exp_avg_volume { return array_exponential_avg(shift, 7); }

sub index_max_close { return array_max_index(shift, 5); }
sub index_min_close { return array_min_index(shift, 5); }

sub fundamental_eps { return $current_fundamentals{'eps'}; }
sub fundamental_roe { return $current_fundamentals{'return_on_equity'}; }
sub fundamental_mcap { return $current_fundamentals{'mcap'}; }
sub fundamental_float { return $current_fundamentals{'total_float'}; };
sub fundamental_egrowth { return $current_fundamentals{'qtrly_earnings_growth'}; }

sub compute_macd_signal { indicator_macd_signal(\@current_prices, shift); }

sub truncate_current_prices {

    $start = shift;
    $end = shift;

    my $saved = $current_prices;
    my @cur = @$saved[$start..$end];
    $current_prices = \@cur;
    return $saved;
}

sub array_max {
    my $total = shift;
    my $in = shift;

    my $n = "$in$total" . "max";

    if(!exists $value_cache{$n}) {
	scan_array_max($total, $in);
    }

    return $value_cache{$n};
}

sub array_min {
    my $total = shift;
    my $in = shift;

    my $n = "$in$total" . "min";

    if(!exists $value_cache{$n}) {
	scan_array_min($total, $in);
    }

    return $value_cache{$n};
}

sub array_max_index {
    my $total = shift;
    my $in = shift;

    my $n = "$in$total" . "maxin";

    if(!exists $value_cache{$n}) {
	scan_array_max($total, $in);
    }

    return $value_cache{$n};
}

sub array_min_index {
    my $total = shift;
    my $in = shift;

    my $n = "$in$total" . "minin";

    if(!exists $value_cache{$n}) {
	scan_array_max($total, $in);
    }

    return $value_cache{$n};
}



sub scan_array_max {

    my $limit = shift;
    my $index = shift;
    my $max = 0;
    my $loc = 0;

    for($i = 0; $i < $limit; $i++) {
	
	@t = @$current_prices[$i];
	if($t[0][$index] > $max) {
	    $max = $t[0][$index];
	    $loc = $i;
	}
    }

    $value_cache{"$index$limit" . "max"} = $max;
    $value_cache{"$index$limit" . "maxin"} = $loc;
}

sub scan_array_min {

    my $limit = shift;
    my $index = shift;
    my $min = 10000000;
    my $loc = 0;

     for($i = 0; $i < $limit; $i++) {
	
	@t = @$current_prices[$i];
	if($t[0][$index] < $min) {
	    $min = $t[0][$index];
	    $loc = $i;
	}
    }

    $value_cache{"$index$limit" . "min"} = $min;
    $value_cache{"$index$limit" . "minin"} = $loc;
}


sub array_avg {

    my $limit = shift;
    my $index = shift;
    my $total = 0;

    my $n = "$index$limit" . "avg";
    return $value_cache{$n} if exists $value_cache{$n};

    for($i = 0; $i < $limit; $i++) {
	@t = @$current_prices[$i];
	$total += $t[0][$index];
    }

    $value_cache{$n} = ($total / $limit);
    return $value_cache{$n};
}

sub array_exponential_avg {

    my $limit = shift;
    my $index = shift;
    my $weight = 2 / ($limit + 1);
    my $total = 0;

    my $n = "$index$limit" . "eavg";
    return $value_cache{$n} if exists $value_cache{$n};

    #first compute the moving average of the first $limit days
    my $t = truncate_current_prices($limit, $limit *2);
    my $previous_avg = array_avg($limit, $index);
    $current_prices = $t;
    %value_cache = ();

    #now apply the exponential average calculation to the remaining $limit days
    for($i = $limit - 1; $i >= 0; $i--) {
	@t = @$current_prices[$i];
	$cur_avg = (($t[0][$index] - $previous_avg) * $weight) + $previous_avg;
	$previous_avg = $cur_avg;
    }


    $value_cache{$n} = $cur_avg;
    return $value_cache{$n};
}


#uses the optionvue "extreme value" method to compute the
#statistical volatility of an issue.  This is the repetition, for
#each trading day, of the equation 0.627 * sqrt(365.25) * ln(daily high / daily low)
#these volatility values for each day are then exponentially averaged
#over the whole range, and the average computed is taken to be the
#statistical volatility

sub statistical_volatility {
 
    my $number = shift;

    $yearroot = 19.111514853616391;
    $leadconst = 0.627;
    $num = 0.0;
    $dnm = 0.0;
    $a = 1.0;
        

    for($i = 0; $i < $number; $i++) {
	$high = fetch_high_at($i);
	$low = fetch_low_at($i);;
	$dsv = $leadconst * $yearroot * log($high / $low);
	$num = $num + ($a * $dsv);
	$dnm = $dnm + $a;
	$a = $a * 0.95;
    }

    return ($num / $dnm);
}

sub compute_macd {

    my $first_avg = shift;
    my $second_avg = shift;
    return exp_avg_close($first_avg) - exp_avg_close($second_avg);
}

sub compute_macd_signal {

    my $count = shift;
    my $avg_1 = shift;
    my $avg_2 = shift;
    my @macd_history;

    for(my $i = $count * 2; $i >= 0; $i--) {

	my $len = @$current_prices;
	my $t = truncate_current_prices($i, $len);
	push @macd_history, compute_macd($avg_2, $avg_1);
	$current_prices = $t;
    }

    my $sum = 0;
    for(my $i = 0; $i < $count; $i++) {
	$sum += $macd_history[$i];
    }
    
    my $prev_avg = $sum / $count;
    my $weight = 2 / ($count + 1);

    for(my $i = $count; $i <= @macd_history; $i++) {
	$cur_avg = ($macd_history[$i] * $weight) + ($prev_avg * (1 - $weight));
	$prev_avg = $cur_avg;
    }


    return $prev_avg;
}


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

sub calculate_parabolic_sar {


    my $evt, $sar, $prev_sar;
    my $init_alpha = shift;
    my $alpha_max = shift;
    my $step = shift;
   
    $init_alpha = 0.02;
    $alpha = 0.02;
    $step = 0.02;
    $alpha_max = .2;

    my $islong = 0;

    # The first SAR value is calculated by taking the difference between
    # the high price and the low price and multiplying the difference by
    # the initial acceleration factor.

    @t = @$current_prices[@$current_prices - 1];
    $next_sar = ($t[0][3] - $t[0][4]) * $init_alpha;
    $evt = $t[0][4] if ! $long;
    $evt = $t[0][5] if $long;


    for($i = @$current_prices - 2; $i >= 0; $i--) {

	@t = @$current_prices[$i];
	$cur_price = $t[0][5];

	#if sar pierces the price low for it's day
	#then a new trend is signaled, which means

	# 1 - the first sar for new trend is the last evt value
	# 2 - the acceleration factor is reset to it's initial value
	# 3 - $long = ! $long
	if($next_sar > $t[0][4]) {
	    $prev_sar = $evt;
	    $alpha = $init_alpha;
	    $islong = ! $islong;
	}

	if($islong && $cur_price > $evt) {
	    $evt = $cur_price;
	    $alpha += $step if $alpha < $alpha_max;
	}


	if(! $islong && $cur_price < $evt) {
	    $evt = $cur_price;
	    $alpha += $step if $alpha < $alpha_max;
	}

	$sar = $next_sar;
	$next_sar = $prev_sar + $alpha * ($evt - $prev_sar);
	$prev_sar = $sar;

	#if tommorrow's sar pierces the price low for today or yesterday
	#then we must set it to the lowest low of the last two days
	$next_sar = $t[0][4] if $next_sar > $t[0][4];
	@t = @$current_prices[$i + 1];
	$next_sar = $t[0][4] if $next_sar > $t[0][4];
    }

    print "\n$sar";
    return $next_sar;
}

1;
