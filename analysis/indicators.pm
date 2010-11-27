#use rstrength;
use screen_data;
use Finance::TA;

sub fetch_strength { return relative_strength(current_ticker(), shift); }
sub fetch_volatility { return statistical_volatility(shift); }

sub fetch_open_at { return $current_prices->[shift][OPEN_IND]; }
sub fetch_high_at { return $current_prices->[shift][HIGH_IND]; }
sub fetch_low_at { return $current_prices->[shift][LOW_IND]; }
sub fetch_close_at { return $current_prices->[shift][CLOSE_IND]; }
sub fetch_volume_at { return $current_prices->[shift][VOL_IND]; }
sub fetch_date_at { return $current_prices->[shift][DATE_IND]; }

sub max_open { return array_max(shift, OPEN_IND); }
sub max_high { return array_max(shift, HIGH_IND); }
sub max_low { return array_max(shift, LOW_IND); }
sub max_close { return array_max(shift, CLOSE_IND); }
sub max_volume { return array_max(shift, VOL_IND); }

sub min_open { return array_min(shift, OPEN_IND); }
sub min_high { return array_min(shift, HIGH_IND); }
sub min_low { return array_min(shift, LOW_IND); }
sub min_close { return array_min(shift, CLOSE_IND); }
sub min_volume { return array_min(shift, VOL_IND); }

sub avg_open { return array_avg(shift, OPEN_IND); }
sub avg_high { return array_avg(shift, HIGH_IND); }
sub avg_low { return array_avg(shift, LOW_IND); }
sub avg_close { return array_avg(shift, CLOSE_IND); }
sub avg_volume { return array_avg(shift, VOL_IND); }

sub exp_avg_open { return array_exponential_avg(shift, OPEN_IND); }
sub exp_avg_high { return array_exponential_avg(shift, HIGH_IND); }
sub exp_avg_low { return array_exponential_avg(shift, LOW_IND); }
sub exp_avg_close { return array_exponential_avg(shift, CLOSE_IND); }
sub exp_avg_volume { return array_exponential_avg(shift, VOL_IND); }

sub wma_open { return array_weighted_avg(shift, OPEN_IND); }
sub wma_high { return array_weighted_avg(shift, HIGH_IND); }
sub wma_low { return array_weighted_avg(shift, LOW_IND); }
sub wma_close { return array_weighted_avg(shift, CLOSE_IND); }
sub wma_volume { return array_weighted_avg(shift, VOL_IND); }

sub init_indicators {
    TA_Initialize();
}

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
	my @sorted = sort { $b->[$in] <=> $a->[$in] } @$current_prices[0..$total];
	$value_cache{$n} = $sorted[0][$in];
    }

    return $value_cache{$n};
}

sub array_min {
    my $total = shift;
    my $in = shift;

    my $n = "$in$total" . "min";

    if(!exists $value_cache{$n}) {
	my @sorted = sort { $b->[$in] <=> $a->[$in] } @$current_prices[0..$total];
	$value_cache{$n} = $sorted[$#sorted][$in];
    }

    return $value_cache{$n};
}

sub array_avg {

    my $limit = shift;
    my $index = shift;
    my $total = 0;

    my $n = "$index$limit" . "avg";
    return $value_cache{$n} if exists $value_cache{$n};

    for($i = 0; $i < $limit; $i++) {
	$total += $current_prices->[$i][$index];
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

sub compute_trend_score {

    my $score = 0;

    for(my $i = 11; $i <= 20; $i++) {
	
	if(fetch_close_at(0) > fetch_close_at($i)) {
	    $score++;
	} else {
	    $score--;
	}
    }

    return $score;
}

sub random_walk_high {

    my $period = shift;
    my $range = compute_atr($period);

    my $rwi = (fetch_high_at(0) - fetch_low_at($period)) / $range;
    $rwi *= (1 / sqrt($period));
    
    return $rwi;
}

sub random_walk_low {

    my $period = shift;
    my $range = compute_atr($period);

    my $rwi = (fetch_high_at($period) - fetch_low_at(0)) / $range;
    $rwi *= (1 / sqrt($period));
    
    return $rwi;
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

    my @series = reverse map $_->[$index], @$current_prices;

    my ($rcode, $start, $ema) = TA_EMA(0, $#series, \@series, $period);
    $value_cache{$n} = $ema->[@$ema - 1];
    
    return $ema->[@$ema - 1];
}

sub array_weighted_avg {

    my $period = shift;
    my $index = shift;

    my $n = "wma$index$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @series = reverse map $_->[$index], @$current_prices;

    my ($rcode, $start, $wma) = TA_WMA(0, $#series, \@series, $period);
    $value_cache{$n} = $wma->[@$wma - 1];

    return $value_cache{$n};
}

sub compute_upper_bollinger {

    my $period = shift;
    my $deviation = shift;
    
    my $n = "$period" . "bbandu" . $deviation;
    return $value_cache{$n} if exists $value_cache{$n};

    compute_bollinger_bands($period, $deviation);
    return $value_cache{$n};
}


sub compute_lower_bollinger {

    my $period = shift;
    my $deviation = shift;
    
    my $n = "$period" . "bbandl" . $deviation;
    return $value_cache{$n} if exists $value_cache{$n};

    compute_bollinger_bands($period, $deviation);
    return $value_cache{$n};
}

sub compute_bollinger_bands {

    my $per = shift;
    my $dev = shift;

    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    @closes = splice @closes, -($per);
    my ($rcode, $start, $uband, $midband, $lband) = TA_BBANDS(0, $per, \@closes, $per, $dev, $dev, $TA_MAType_SMA);

    my $len = @$lband - 1;
    $value_cache{"$per" . "bbandl" . $dev} = $lband->[0];
    $value_cache{"$per" . "bbandm" . $dev} = $midband->[0];
    $value_cache{"$per" . "bbandu" . $dev} = $uband->[0];
}

sub compute_lower_keltner {

    my $period = shift;
    my $mult = shift;
    my $rper = shift;

    my $n = "keltner$period" . "lo$mult";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_keltner_bands($period, $mult, $rper);
    return $value_cache{$n};
}

sub compute_upper_keltner {

    my $period = shift;
    my $mult = shift;
    my $rper = shift;

    my $n = "keltner$period" . "up$mult";
    return $value_cache{$n} if exists $value_cache{$n};

    compute_keltner_bands($period, $mult, $rper);
    return $value_cache{$n};
}

sub compute_keltner_bands {

    my $period = shift;
    my $mult = shift;
    my $rper = shift;

    my $center_band = exp_avg_close($period);
    my $range = compute_atr($rper);

    my $n = "keltner$period" . "lo$mult";
    $value_cache{$n} = $center_band - ($mult * $range);

    $n = "keltner$period" . "up$mult";
    $value_cache{$n} = $center_band + ($mult * $range);
}

sub compute_williams_r {

    my $period = shift;

    my $n = "willr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    
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

    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    @closes = splice @closes, -($period * 4);

    my ($rcode, $start, $rsi) = TA_RSI(0, $#closes, \@closes, $period);
    $value_cache{$n} = $rsi->[@$rsi - 1];
    return $rsi->[@$rsi - 1];
}

sub compute_atr {

    my $period = shift;

    my $n = "atr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;

    @highs = splice @highs, -($period + 1);
    @lows = splice @lows, -($period + 1);
    @closes = splice @closes, -($period + 1);

    my ($rcode, $start, $atr) = TA_ATR(0, $#closes, \@highs, \@lows, \@closes, $period);
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

    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    @closes = splice @closes, -($slow * 4);
    $len = @closes - 1;

    my ($rcode, $count, $macd, $signal, $hist) = TA_MACD(0, $len, \@closes, $fast, $slow, $sig);

    my $last = @$macd - 1;
    my $base = "$slow$fast$sig";
    $value_cache{$base . "macds"} = $signal->[$last];
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

    my @closes = map $_->[CLOSE_IND], @$current_prices;
    my ($rcode, $start, $mom) = TA_MOM(0, $period, \@closes, $period);

    $value_cache{$n} = $mom->[0] * -1;
    return $value_cache{$n};
}

sub compute_sar {

    my $stepval = shift;
    my $maxval = shift;

    my $n = "sar$stepval$maxval";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    $len = @highs - 1;

    my ($rcode, $start, $sar) = TA_SAR(0, $len, \@highs, \@lows, $stepval, $maxval);

    $value_cache{$n} = $sar->[@$sar - 1];
    return $sar->[0];
}

sub compute_roc {

    my $period = shift;

    my $n = "roc$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    @closes = splice @closes, -($period + 1);

    my ($rcode, $start, $roc) = TA_ROC(0, $period, \@closes, $period);
    $value_cache{$n} = $roc->[0];
    return $roc->[0];
}

sub compute_obv {

    my $period = shift;

    my $n = "obv$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @closes = map $_->[CLOSE_IND], @$current_prices;
    my @volume = map $_->[VOL_IND], @$current_prices;

    my ($rcode, $start, $obv) = TA_OBV(0, $period, \@closes, \@volume);

    $value_cache{$n} = $obv->[0];
    return $obv->[0];
}

sub compute_bop {

    my $n = "bop";
    return $value_cache{$n} if exists $value_cache{$n};

    my @opens = map $_->[OPEN_IND], @$current_prices;
    my @highs = map $_->[HIGH_IND], @$current_prices;
    my @lows = map $_->[LOW_IND], @$current_prices;
    my @closes = map $_->[CLOSE_IND], @$current_prices;

    my ($rcode, $start, $bop) = TA_BOP(0, $#closes, \@opens, \@highs, \@lows, \@closes);

    $value_cache{$n} = $bop->[0];
    return $bop->[0];
}


sub compute_adx {

    my $period = shift;

    my $n = "adx$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;

    my ($rcode, $start, $adx) = TA_ADX(0, $#closes, \@highs, \@lows, \@closes, $period);

    $final = @$adx - 1;
    $value_cache{$n} = $adx->[$final];
    return $adx->[$final];
}


sub compute_adx_r {

    my $period = shift;
    
    my $n = "adxr$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;

    my ($rcode, $start, $adxr) = TA_ADXR(0, $#closes, \@highs, \@lows, \@closes, $period);

    $final = @$adxr - 1;
    $value_cache{$n} = $adxr->[$final];
    return $adxr->[$final];
}

sub compute_ultosc {

    my $period1 = shift;
    my $period2 = shift;
    my $period3 = shift;

    my $n = "ultosc$period1$period2$period3";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs =  reverse map $_->[HIGH_IND], @$current_prices;
    my @lows =  reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;

    @highs = splice @highs, 0, $period3 + 1;
    @lows = splice @lows, 0, $period3 + 1;
    @closes = splice @closes, 0, $period3 + 1;

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

    my $per = shift;
    my (@upper, @middle, @lower);

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;

    my ($rcode, $start, $uband, $midband, $lband) = TA_ACCBANDS(0, $#closes, \@highs, \@lows, \@closes, $per);

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

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;

    my ($rcode, $start, $fast_k, $fast_d) = TA_STOCHF(0, $#closes, \@highs, \@lows, \@closes, $k_period, $d_period, $TA_MAType_SMA);

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

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;

    @highs = splice @highs, -($period + 1);
    @lows = splice @lows, -($period + 1);

    my ($rcode, $start, $down, $up) = TA_AROON(0, $#highs, \@highs, \@lows, $period);

    $len = @$up - 1;
    $value_cache{"aroonup$period"} = $up->[$len];
    $value_cache{"aroond$period"} = $down->[$len];
}

sub compute_aroon_osc {

    my $period = shift;

    my $n = "aroono$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;

    @highs = splice @highs, -($period + 1);
    @lows = splice @lows, -($period + 1);

    my ($rcode, $start, $osc) = TA_AROONOSC(0, $#highs, \@highs, \@lows, $period);
    $value_cache{"aroono$period"} = $osc->[0];
    return $osc->[0];
}

sub compute_cci {

    my $period = shift;

    my $n = "cci$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;

    @highs = splice @highs, -($period);
    @lows = splice @lows, -($period);
    @closes = splice @closes, -($period);

    my ($rcode, $start, $cci) = TA_CCI(0, $#closes, \@highs, \@lows, \@closes, $period);

    $value_cache{$n} = $cci->[0];
    return $value_cache{$n};
}

sub compute_ppo {

    my $fast = shift;
    my $slow = shift;
    
    my $n = "$slow$fast" . "ppo";
    return $value_cache{$n} if exists $value_cache{$n};

    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    my ($rcode, $start, $ppo) = TA_PPO(0, $#closes, \@closes, $fast, $slow, 1);

    my $len = scalar @$ppo - 1;
    $value_cache{$n} = $ppo->[$len];

    return $value_cache{$n};
}

sub compute_efficiency_ratio {

    my $period = shift;
    $period--;

    my $enumerator = $current_prices->[0][CLOSE_IND] - $current_prices->[$#current_prices][CLOSE_IND];
    my $denominator = 0;

    for(my $i = 0; $i < $period; $i++) {
	$denominator += abs( $current_prices->[$i][CLOSE_IND] - $current_prices[$i + 1][CLOSE_IND] );
    }

    return ($enumerator / $denominator) * 100;
}

sub compute_mfi {

    my $period = shift;

    my $n = "mfi$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @highs = reverse map $_->[HIGH_IND], @$current_prices;
    my @lows = reverse map $_->[LOW_IND], @$current_prices;
    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    my @volume = reverse map $_->[VOL_IND], @$current_prices;

    @highs = splice @highs, -($period + 1);
    @lows = splice @lows, -($period + 1);
    @closes = splice @closes, -($period + 1);
    @volume = splice @volume, -($period + 1);

    my ($rcode, $start, $mfi) = TA_MFI(0, $#closes, \@highs, \@lows, \@closes, \@volume, $period);
    $value_cache{$n} = $mfi->[0];
    return $value_cache{$n};
}

sub compute_cmo {

    my $period = shift;

    my $n = "chandeo$period";
    return $value_cache{$n} if exists $value_cache{$n};

    my @closes = map $_->[CLOSE_IND], @$current_prices;
    @closes = splice @closes, -($period + 1);

    my ($rcode, $start, $cmo) = TA_CMO(0, $#closes, \@closes, $period);

    $value_cache{$n} = $cmo->[0];
    return $value_cache{$n};
}

sub compute_standard_dev {

    my $period = shift;
    my $devcount = shift;

    my $n = "$period" . "stdev$devcount";
    return $value_cache{$n} if exists $value_cache{$n};

    my @closes = reverse map $_->[CLOSE_IND], @$current_prices;
    @closes = splice @closes, -($period + 1);

    my ($rcode, $start, $dev) = TA_STDDEV(0, $#closes, \@closes, $period, $devcount);
    $value_cache{$n} = $dev->[1];
    return $value_cache{$n};
}

1;
