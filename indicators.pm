use rstrength;
use screen_sql;
use Finance::TA;

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
sub fundamental_current_ratio { return $current_fundamentals{'current_ratio'}; }

sub fundamental_dcf { return indicator_dcf_valuation($current_fundamentals{'eps'}, 0, 1, 7); }

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


########
# All of the functions from here on are basically
# wrappers for the TA-LIB calls
########


sub array_exponential_avg {

    my $period = shift;
    my $index = shift;

    my $n = "ema$index$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @series = map @$_->[$index], @$current_prices;
    $len = @series - 1;

    my ($rcode, $start, $ema) = TA_EMA(0, $len, \@series, $period);

    $value_cache{$n} = $ema->[0];
    return $ema->[0];
}

sub compute_upper_bollinger {

    my $period = shift;
    my $deviation = shift;
    
    my $n = "$period$deviation" . "bbandu";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_bollinger_bands($period, $deviation);
    return $value_cache{$n};
}


sub compute_lower_bollinger {

    my $period = shift;
    my $deviation = shift;
    
    my $n = "$period$deviation" . "bbandl";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_bollinger_bands($period, $deviation);
    return $value_cache{$n};
}

sub compute_bollinger_bands {

    my $per = shift;
    my $dev = shift;
    my @upper, @middle, @lower;

    @closes = map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $uband, $midband, $lband) = TA_BBANDS(0, $len, \@closes, $per, $dev, $dev, $TA_MAType_SMA);

    my $base = "$per$dev";
    $value_cache{$base . "bbandl"} = $lband->[0];
    $value_cache{$base . "bbandm"} = $mband->[0];
    $value_cache{$base . "bbandu"} = $uband->[0];
}

sub compute_williams_r {

    my $period = shift;

    my $n = "willr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = map @$_->[3], @$current_prices;
    @lows = map @$_->[4], @$current_prices;
    @closes = map @$_->[5], @$current_prices;

    $len = @closes - 1;

    my ($rcode, $start, $willr) = TA_WILLR(0, $len, \@highs, \@lows, \@closes, $period);
    $value_cache{$n} = $willr->[0];
    return $willr->[0];
}


sub compute_rsi {

    my $period = shift;

    my $n = "rsi$period";
    return $value_cache{$n} if exists $value_cache{$n};


    @closes = map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $rsi) = TA_RSI(0, $len, \@closes, $period);
    $value_cache{$n} = $rsi->[0];
    return $rsi->[0];
}

sub compute_atr {

    my $period = shift;

    my $n = "atr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = map @$_->[3], @$current_prices;
    @lows = map @$_->[4], @$current_prices;
    @closes = map @$_->[5], @$current_prices;

    $len = @closes - 1;

    my ($rcode, $start, $atr) = TA_ATR(0, $len, \@highs, \@lows, \@closes, $period);
    $value_cache{$n} = $atr->[0];
    return $atr->[0];
}

sub compute_macd_signal {

    my $slow = shift;
    my $fast = shift;
    my $sig = shift;
    
    my $n = "$slow$fast$sig" . "macds";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_macd_values($slow, $fast, $sig);
    return $value_cache{$n};
}

sub compute_macd_hist {

    my $slow = shift;
    my $fast = shift;
    my $sig = shift;

    my $n = "$slow$fast$sig" . "macdh";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_macd_values($slow, $fast, $sig);
    return $value_cache{$n};
}


sub compute_macd {

    my $slow = shift;
    my $fast = shift;
    my $sig = shift;    

    my $n = "$slow$fast$sig" . "macd";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_macd_values($slow, $fast, $sig);
    return $value_cache{$n};
}

sub compute_macd_values {

    my $slow = shift;
    my $fast = shift;
    my $sig = shift;    

    @closes = map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $macd, $sig, $hist) = TA_MACD(0, $len, \@closes, $fast, $slow, $signal);

    my $base = "$slow$fast$sig";
    $value_cache{$base . "macds"} = $sig->[0];
    $value_cache{$base . "macdh"} = $hist->[0];
    $value_cache{$base . "macd"} = $macd->[0];
}

sub compute_momentum {

    my $period = shift;

    my $n = "mom$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @closes = map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $mom) = TA_MOM(0, $len, \@closes, $period);

    $value_cache{$n} = $mom->[0];
    return $mom->[0];
}

sub compute_sar {

    my $stepval = shift;
    my $maxval = shift;

    my $n = "sar$stepval$maxval";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = map @$_->[3], @$current_prices;
    @lows = map @$_->[4], @$current_prices;
    $len = @highs - 1;

    my ($rcode, $start, $count, $sar) = TA_SAR(0, $len, \@highs, \@lows, $stepval, $maxval);
    
    $value_cache{$n} = $sar->[0];
    return $sar->[0];
}

sub compute_roc {

    my $period = shift;

    my $n = "roc$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @closes = map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $roc) = TA_ROC(0, $len, \@closes, $period);

    $value_cache{$n} = $roc->[0];
    return $roc->[0];
}

1;
