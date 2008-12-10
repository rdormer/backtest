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


###########
# All of the functions from here on are basically
# wrappers for the TA-LIB calls
###########


sub array_exponential_avg {

    my $period = shift;
    my $index = shift;

    my $n = "ema$index$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @series = reverse map @$_->[$index], @$current_prices;
    $len = @series - 1;

    my ($rcode, $start, $ema) = TA_EMA(0, $len, \@series, $period);
    $value_cache{$n} = $ema->[@$ema - 1];
    
    return $ema->[@$ema - 1];
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

    @closes = reverse map @$_->[5], @$current_prices;
    @closes = splice @closes, -($per);
    my ($rcode, $start, $uband, $midband, $lband) = TA_BBANDS(0, $per, \@closes, $per, $dev, $dev, $TA_MAType_SMA);

    my $base = "$per$dev";
    $value_cache{$base . "bbandl"} = $lband->[0];
    $value_cache{$base . "bbandm"} = $mband->[0];
    $value_cache{$base . "bbandu"} = $uband->[0];
}

sub compute_williams_r {

    my $period = shift;

    my $n = "willr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;
    @closes = reverse map @$_->[5], @$current_prices;
    
    @highs = splice @highs, -($period);
    @lows = splice @lows, -($period);
    @closes = splice @closes, -($period);

    my ($rcode, $start, $willr) = TA_WILLR(0, $period, \@highs, \@lows, \@closes, $period);
    $value_cache{$n} = $willr->[0];
    return $willr->[0];
}


sub compute_rsi {

    my $period = shift;

    my $n = "rsi$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @closes = reverse map @$_->[5], @$current_prices;
    @closes = splice @closes, -($period * 4);
    $len = @closes - 1;

    my ($rcode, $start, $rsi) = TA_RSI(0, $len, \@closes, $period);
    $value_cache{$n} = $rsi->[@$rsi - 1];
    return $rsi->[@$rsi - 1];
}

sub compute_atr {

    my $period = shift;

    my $n = "atr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;
    @closes = reverse map @$_->[5], @$current_prices;
    
    @highs = splice @highs, -($period + 1);
    @lows = splice @lows, -($period + 1);
    @closes = splice @closes, -($period + 1);

    my ($rcode, $start, $atr) = TA_ATR(0, $period, \@highs, \@lows, \@closes, $period);
    $value_cache{$n} = $atr->[0];
    return $atr->[0];
}

sub compute_macd_signal {

    my $fast = shift;
    my $slow = shift;
    my $sig = shift;
    
    my $n = "$slow$fast$sig" . "macds";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_macd_values($fast, $slow, $sig);
    return $value_cache{$n};
}

sub compute_macd_hist {

    my $fast = shift;
    my $slow = shift;
    my $sig = shift;

    my $n = "$slow$fast$sig" . "macdh";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_macd_values($fast, $slow, $sig);
    return $value_cache{$n};
}


sub compute_macd {

    my $fast = shift;
    my $slow = shift;
    my $sig = shift;    

    my $n = "$slow$fast$sig" . "macd";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_macd_values($fast, $slow, $sig);
    return $value_cache{$n};
}

##
## TODO: Will leave it for now, but sooner or later, this will
## have to be revisited - if signal period is larger than slow
## EMA period, MACD values may be calculated incorrectly for want
## of a longer lookback period.

sub compute_macd_values {

    my $fast = shift;
    my $slow = shift;
    my $sig = shift;    

    @closes = reverse map @$_->[5], @$current_prices;
    @closes = splice @closes, -($slow * 4);
    $len = @closes - 1;

    my ($rcode, $count, $macd, $sig, $hist) = TA_MACD(0, $len, \@closes, $fast, $slow, $signal);

    my $last = @$macd - 1;
    my $base = "$slow$fast$sig";
    $value_cache{$base . "macds"} = $sig->[$last];
    $value_cache{$base . "macdh"} = $hist->[$last];
    $value_cache{$base . "macd"} = $macd->[$last];
}

#in keeping with the spirit of not calling reverse on the map
#unless necessary, here we just multiply the momentum by -1
#to get the same result faster

sub compute_momentum {

    my $period = shift;

    my $n = "mom$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @closes = map @$_->[5], @$current_prices;
    my ($rcode, $start, $mom) = TA_MOM(0, $period, \@closes, $period);

    $value_cache{$n} = $mom->[0] * -1;
    return $mom->[0] * -1;
}

sub compute_sar {

    my $stepval = shift;
    my $maxval = shift;

    my $n = "sar$stepval$maxval";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;
    $len = @highs - 1;

    my ($rcode, $start, $sar) = TA_SAR(0, $len, \@highs, \@lows, $stepval, $maxval);

    $value_cache{$n} = $sar->[@$sar - 1];
    print "\n$current_prices->[0][0] $value_cache{$n}";
    return $sar->[0];
}

sub compute_roc {

    my $period = shift;

    my $n = "roc$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @closes = reverse map @$_->[5], @$current_prices;
    @closes = splice @closes, -($period + 1);

    my ($rcode, $start, $roc) = TA_ROC(0, $period, \@closes, $period);
    $value_cache{$n} = $roc->[0];
    return $roc->[0];
}

sub compute_obv {

    my $period = shift;

    my $n = "obv$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @closes = map @$_->[5], @$current_prices;
    @volume = map @$_->[7], @$current_prices;

    my ($rcode, $start, $count, $obv) = TA_OBV(0, $period, \@closes, \@volume);

    print "\n$rcode $start $count $obv";

    $value_cache{$n} = $obv->[0];
    return $obv->[0];
}

sub compute_bop {

    my $n = "bop";
    return $value_cache{$n} if exists $value_cache{$n};

    @opens = map @$_->[2], @$current_prices;
    @highs = map @$_->[3], @$current_prices;
    @lows = map @$_->[4], @$current_prices;
    @closes = map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $bop) = TA_BOP(0, $len, \@opens, \@highs, \@lows, \@closes);

    $value_cache{$n} = $bop->[0];
    return $bop->[0];
}


sub compute_adx {

    my $period = shift;

    my $n = "adx$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;
    @closes = reverse map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $adx) = TA_ADX(0, $len, \@highs, \@lows, \@closes, $period);

    $olen = @$adx;
    print "\n$rcode $start $adx retlen $olen";
    print "\n$current_prices->[0][0] adx is $adx->[0]";

    $value_cache{$n} = $adx->[0];
    return $adx->[0];
}


sub compute_adx_r {

    my $period = shift;
    
    my $n = "adxr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;
    @closes = reverse map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $adxr) = TA_ADXR(0, $len, \@highs, \@lows, \@closes, $period);

    $value_cache{$n} = $adxr->[0];
    return $adxr->[0];
}

sub compute_ultosc {

    my $period1 = shift;
    my $period2 = shift;
    my $period3 = shift;

    my $n = "ultosc$period1$period2$period3";
    return $value_cache{$n} if exists $value_cache{$n};

    @highs =  reverse map @$_->[3], @$current_prices;
    @lows =  reverse map @$_->[4], @$current_prices;
    @closes = reverse map @$_->[5], @$current_prices;

    @highs = splice @highs, -($period3 + 1);
    @lows = splice @lows, -($period3 + 1);
    @closes = splice @closes, -($period3 + 1);

    my ($rcode, $start, $ultosc) = TA_ULTOSC(0, $period3, \@highs, \@lows, \@closes, $period1, $period2, $period3);

    $value_cache{$n} = $ultosc->[0];
    return $ultosc->[0];
}

sub compute_upper_accband {

    my $period = shift;
    
    my $n = "$period" . "accbandu";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_acceleration_bands($period);
    return $value_cache{$n};
}


sub compute_lower_accband {

    my $period = shift;
    
    my $n = "$period" . "accbandl";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_acceleration_bands($period);
    return $value_cache{$n};
}

sub compute_acceleration_bands {

    print "\ncall compute";

    my $per = shift;
    my @upper, @middle, @lower;

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;
    @closes = reverse map @$_->[5], @$current_prices;
    my $len = @closes - 1;

    my ($rcode, $start, $uband, $midband, $lband) = TA_ACCBANDS(0, $len, \@highs, \@lows, \@closes, $per);

    "\n$len $uband->[0] $midband->[0] $lband->[0]";

    $value_cache{$per . "accbandl"} = $lband->[0];
    $value_cache{$per . "accbandm"} = $midband->[0];
    $value_cache{$per . "accbandu"} = $uband->[0];
}

sub compute_fast_stoch_d {

    my $period = shift;

    my $n = "faststochd$period";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_fast_stoch($period, $period);
    return $value_cache{$n};
}

sub compute_fast_stoch_k {

    my $period = shift;

    my $n = "faststochk$period";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_fast_stoch($period, $period);
    return $value_cache{$n};
}

sub compute_fast_stoch {

    my $d_period = shift;
    my $k_period = shift;

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;
    @closes = reverse map @$_->[5], @$current_prices;
    $len = @closes - 1;

    my ($rcode, $start, $fast_k, $fast_d) = TA_STOCHF(0, $len, \@highs, \@lows, \@closes, $k_period, $d_period, $TA_MAType_SMA);

    $len = @$fast_d - 1;
    $value_cache{"faststochk$k_period"} = $fast_k->[$len];
    $value_cache{"faststochd$d_period"} = $fast_d->[$len];
}

sub compute_aroon_up {

    my $period = shift;

    my $n = "aroonup$period";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_aroon($period);
    return $value_cache{$n};
}

sub compute_aroon_down {

    my $period = shift;

    my $n = "aroond$period";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_aroon($period);
    return $value_cache{$n};
}

sub compute_aroon {

    my $period = shift;

    @highs = reverse map @$_->[3], @$current_prices;
    @lows = reverse map @$_->[4], @$current_prices;

    @highs = splice @highs, -($period + 1);
    @lows = splice @lows, -($period + 1);
    $len = @highs - 1;

    my ($rcode, $start, $down, $up) = TA_AROON(0, $len, \@highs, \@lows, $period);

    $len = @$up - 1;
    $value_cache{"aroonup$period"} = $up->[$len];
    $value_cache{"aroond$period"} = $down->[$len];
}

1;
