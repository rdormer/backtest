use portfolios::stats;
use macro_expander;
use charting;
use POSIX;
use conf;

my %positions;

my @trade_slippage;
my @trade_history;
my @long_exits;
my @short_exits;

my @long_signals;
my @short_signals;

my @long_stop;
my @long_trail;

my @short_stop;
my @short_trail;

my @equity_curve;

my $starting_cash;
my $current_cash;
my $position_count;
my $risk_percent;

my $max_equity;

my $total_margin_calls;
my $total_short_equity;

my %dividend_cache;
my $dividend_payout;

sub init_long_portfolio {

    my $longexits = shift;
    @long_exits = @$longexits;

    my $longstop = shift;
    @long_stop = @$longstop;

    my $longtrail = shift;
    @long_trail = @$longtrail;

    generic_init(shift);
}

sub init_short_portfolio {

    my $shortexits = shift;
    @short_exits = @$shortexits;

    my $shortstop = shift;
    @short_stop = @$shortstop;

    my $shorttrail = shift;
    @short_trail = @$shorttrail;

    generic_init(shift);
}

sub generic_init {

    $risk_percent = conf::risk_percent();
    $starting_cash = conf::startwith();
    $current_cash = $starting_cash;

    my $slip = shift;
    @trade_slippage = @$slip;

    calculate_position_count();
    calculate_position_size();
}

sub positions_available {

    my $psize = calculate_position_size();
    return floor($current_cash / $psize);
}

sub calculate_position_size {

    my $sflag = conf::stop_equity() ? 1 : 0;
    my ($equity, $short) = get_sizing_equity($sflag);
    return ($equity / $position_count);
}

sub calculate_position_count {

    #notional % of a $100,000 portfolio

    $atrisk = 100000 * $risk_percent;
    $percentof = $atrisk / (10 / 100);
    $position_count = int(100000 / $percentof);
}

sub compute_stop {

    my $stopval = eval_expression(shift, shift);
    return sprintf("%.2f", $stopval);
}

sub add_positions {

    my $longs = shift;
    my $shorts = shift;

    #always process previous day's signals first
    process_signals();
    
    foreach (@$longs) {
	push @long_signals, $_;
    }

    foreach (@$shorts) {
	push @short_signals, $_;
    }
}

sub process_signals {

    my $longlen = scalar @long_signals;
    my $shortlen = scalar @short_signals;
    my $len = $longlen > $shortlen ? $longlen : $shortlen;
    my $psize = calculate_position_size();

    #alternate between starting a long position and a short
    #position to give both sides a fair shake at getting trades

    for(my $i = 0; $i < $len; $i++) {

	if($longlen > $i && positions_available() && ! exists $positions{$long_signals[$i]}) {
	    start_long_position($long_signals[$i], $psize);
	}

	if($shortlen > $i && positions_available() && ! exists $positions{$short_signals[$i]}) {
	    start_short_position($short_signals[$i], $psize);
	}
    }

    @long_signals = ();
    @short_signals = ();
}

sub start_long_position {

    my $ticker = shift;
    my $count = start_position($ticker, shift);

    if($count > 0) {

	my $price = $positions{$ticker}{'start'};
	my $stop = compute_stop(\@long_stop, $ticker);

	$current_cash -= $count * $price;
	$positions{$ticker}{'short'} = 0;
	$positions{$ticker}{'exit'} = \@long_exits;
	$positions{$ticker}{'stop'} = $stop;
	$positions{$ticker}{'risk'} = (($price - $stop) / $price) * 100;
    }
}

sub start_short_position {

    my $ticker = shift;
    my $count = start_position($ticker, shift);

    if($current_cash >= 2000 && $count > 0) {

	#we have to check to see if this new position takes us over the initial margin
	#requirement, and if it does, back out the trade

	if($current_cash < $total_short_equity + ($count * $price) * conf::initial_margin()) {
	    delete $positions{$ticker};
	} else {

	    my $price = $positions{$ticker}{'start'};
	    my $stop = initial_stop($price, 1);

	    $current_cash += $count * $price;
	    $positions{$ticker}{'short'} = 1;
	    $positions{$ticker}{'exit'} = \@short_exits;
	    $positions{$ticker}{'stop'} = $stop;
	    $positions{$ticker}{'risk'} = (($price - $stop) / $price) * -100;
	}
    }
}

sub start_position {

    my $ticker = shift;
    my $position_size = shift;
    my $sharecount = 0;

    return 0 if get_date() eq conf::finish();

    my $temp = pull_history_by_limit($ticker, get_date(), 1, 1);
    my $price = $temp->[0][OPEN_IND];
    my $volume = $temp->[0][VOL_IND];

    return 0 if $temp->[0][DATE_IND] ne get_date();

    if($price > 0) {

	$sharecount = int($position_size / $price);

	if($sharecount >= 1 && $sharecount < $volume) {

	    if(not exists $dividend_cache{$ticker}) {
		$dividend_cache{$ticker} = pull_dividends($ticker, get_date(), conf::finish());
	    }

	    $positions{$ticker}{'sdate'} = get_date();
	    $positions{$ticker}{'shares'} = $sharecount;
	    $positions{$ticker}{'start'} = $price;
	    $positions{$ticker}{'mae'} = $price;
	    return $sharecount;
	}
    }

    return 0;
}

sub split_adjust_position {

    my $ticker = shift;
    my $splitlist = pull_splits($ticker);

    foreach $split (@$splitlist) {

	if($split->[SPLIT_DATE] eq get_date()) {

	    my $share_ratio = $split->[SPLIT_AFTER] / $split->[SPLIT_BEFORE];
	    my $price_ratio = $split->[SPLIT_BEFORE] / $split->[SPLIT_AFTER];
	    my $current = $positions{$ticker};

	    $current->{'stop'} *= $price_ratio;
	    $current->{'start'} *= $price_ratio;
	    $current->{'shares'} *= $share_ratio;

	    my $shares = $current->{'shares'};

	    if(int($shares) != $shares) {
		
		#return the value of any fractional shares back to
		#the holder as cash and round the number of shares down
   
		my $remainder = $shares - int($shares);
		my $data = pull_data($ticker, get_date(), 1);
		my $price = $data->[0][OPEN_IND];
		$current_cash += ($price * $remainder);
		$current->{'shares'} -= $remainder;
	    }

	    $current->{'start'} = sprintf("%.2f", $current->{'start'});
	    $current->{'split'} = 1;
	    last;
	}
    }
}

sub update_positions {

    return if get_date() eq "";

    @temp = keys %positions;
    @tlist = @ {set_ticker_list(\@temp)};

    #we update our cash position before selling because interest payments, etc.
    #would tend to happen before settlement of a trade.  Then we loop through
    #each position to see if it hit a sell rule or was stopped out, calling our
    #update stop hook first - stops are updated at the start of each period.

#    $current_cash = update_cash_balance($current_cash);

    foreach $ticker (@temp) {

	#if the ending date of a position is set, it means
	#we sold it - process the sell at the open of this day

	if(get_date() eq $positions{$ticker}{'edate'}) {
	    my $data = pull_history_by_limit($ticker, get_date(), 1);
	    end_position($ticker, $data->[0][OPEN_IND], get_date());
	    next;
	}

	#don't split adjust the first day or it could throw some
	#edge cases out of whack.  Also, can't pay out dividends first day.

	if(get_date() gt $positions{$ticker}{'sdate'}) {
	    split_adjust_position($ticker);
	    update_balance_dividend($ticker);
	}

	#check against sell rules, update stats and
	#stops if we're not closing the position

	if(filter_results($ticker, $positions{$ticker}{'exit'})) {
	    $positions{$ticker}{'edate'} = get_exit_date();
	} else {

	    update_stop($ticker);

	    $low = fetch_low_at(0);
	    $high = fetch_high_at(0);
	    $isshort = $positions{$ticker}{'short'};

	    if(fetch_volume_at(0) > 0) {

		stop_position($ticker, $low) and next if ! $isshort;
		stop_position($ticker, $high) and next if $isshort;

		if(! $isshort) {
		    $positions{$ticker}{'mae'} = $low if $low < $positions{$ticker}{'mae'};
		} 

		if($isshort) {
		    $positions{$ticker}{'mae'} = $high if $high > $positions{$ticker}{'mae'};
		} 
	    }
	}
    }

    my ($equity, $sequity) = get_total_equity();
    $total_short_equity = $sequity;
    push @equity_curve, [ $equity, get_date() ];

    #if we're over our maintenance margin for shorts,
    #add cash and note how much we'd be called for

    if(($total_short_equity * conf::maint_margin()) > $current_cash) {
	my $val = $total_short_equity * conf::maint_margin() - $current_cash;
	$current_cash += $val;
	$total_margin_calls += $val;
    }

    set_ticker_list(\@tlist);
}

sub update_stop {

    my $ticker = shift;
    my $old_stop = $new_stop = $positions{$ticker}{'stop'};

    if($positions{$ticker}{'short'} && @short_trail) {
	$new_stop = compute_stop(\@short_trail, $ticker);
	$new_stop = $old_stop if $new_stop > $old_stop;
    } 

    if(! $positions{$ticker}{'short'} && @long_trail) {
	$new_stop = compute_stop(\@long_trail, $ticker);
	$new_stop = $old_stop if $new_stop < $old_stop;
    }

    $positions{$ticker}{'stop'} = $new_stop;
}

sub update_balance_dividend {

    my $ticker = shift;

    if(exists $dividend_cache{$ticker} && exists $dividend_cache{$ticker}->{ get_date() }) {

	my $div = $dividend_cache{$ticker}->{ get_date() }->{'divamt'};
	my $payout = $positions{$ticker}{'shares'} * $div;

	if($positions{$ticker}{'short'}) {
	    $current_cash -= $payout;
	} else {
	    $current_cash += $payout;
	    $dividend_payout += $payout;
	}
    }
}

sub stop_position {

    my $ticker = shift;
    my $price = shift;

    #for long positions, if the low of the day was below the stop, we're stopped out
    if(! $positions{$ticker}{'short'} && $positions{$ticker}{'stop'} >= $price) {

	#if open was less than the stop we have to sell at the open
	if(fetch_open_at(0) < $positions{$ticker}{'stop'}) {
	    end_position($ticker, fetch_open_at(0), fetch_date_at(0));
	} else {
	    end_position($ticker, $positions{$ticker}{'stop'}, fetch_date_at(0));
	}

	return 1;
    }

    #for short positions, if the high of the day was above the stop, we're stopped out
    if($positions{$ticker}{'short'} && $positions{$ticker}{'stop'} <= $price) {

	#if open was more than the stop we have to sell at the open
	if(fetch_open_at(0) > $positions{$ticker}{'stop'}) {
	    end_position($ticker, fetch_open_at(0), fetch_date_at(0));
	} else {
	    end_position($ticker, $positions{$ticker}{'stop'}, fetch_date_at(0));
	}

	return 1;
    }

    return 0;
}

sub end_position {

    my $target = shift;
    my $price = shift;
    my $edate = shift;

    my $shares = $positions{$target}{'shares'};
    $positions{$target}{'end'} = $price;
    $positions{$target}{'edate'} = $edate;

    $amt = $shares * $price;
    $amt -= eval_expression(\@trade_slippage, $target) if @trade_slippage;
    $current_cash -= $amt if $positions{$target}{'short'};    #is this right?
    $current_cash += $amt if ! $positions{$target}{'short'};

    my $startval = $positions{$target}{'start'} * $shares;
    my $ret = ($amt - $startval) / $startval;
    $ret = -($ret) if $positions{$target}{'short'};
    $ret *= 100;

    $positions{$target}{'rratio'} = $ret / $positions{$target}{'risk'} if $positions{$target}{'risk'};
    $positions{$target}{'return'} = $ret;
    $positions{$target}{'ticker'} = $target;
    delete $positions{$target}{'mae'} if $ret <= 0;

    push @trade_history, $positions{$target};
    delete $positions{$target};
}

sub get_sizing_equity {

    my $temp = $current_prices;
    my $equity = $current_cash;
    my $stopflag = shift;

    foreach (keys %positions) {

	if($stopflag) {
	    $equity += $positions{$_}{'stop'} * $positions{$_}{'shares'};
	} else {
	    $current_prices = pull_data($_, get_date(), 2);
	    $equity += fetch_close_at(1) * $positions{$_}{'shares'};
	}
    }

    $current_prices = $temp;
    return $equity;
}

sub get_total_equity {

    my $total_equity = $current_cash;
    my $short_equity = 0;

    foreach (keys %positions) {

	$current_prices = pull_data($_, get_date(), 1);

	if($positions{$_}{'short'}) {
	    $short_equity += (fetch_close_at(0) * $positions{$_}{'shares'});
	} else {
	    $total_equity += (fetch_close_at(0) * $positions{$_}{'shares'});
	}
    }

    return ($total_equity, $short_equity);
}

sub position_time {

    my $ticker = current_ticker();
    my ($start, $now) = parse_two_dates($positions{$ticker}{'sdate'}, get_date());
    return ($now->diffb($start) + 1);
}

sub position_return_percent {

    my $ticker = current_ticker();
    my $start = $positions{$ticker}{'start'};
    my $current = fetch_close_at(0);
    my $ret = ($current - $start) / $start;
    return $ret * 100;
}

sub position_return_r {

    my $ticker = current_ticker();
    my $cur = position_return_percent();
    return $cur / $positions{$ticker}{'risk'};
}

sub position_shares {
    return $positions{current_ticker()}{'shares'};
}

sub position_buy_price {
    return $positions{current_ticker()}{'start'};
}

sub position_sell_price {
    return $positions{current_ticker()}{'end'};    
}

sub bywhen { 
    return $$a{'sdate'} gt $$b{'sdate'};
}

sub print_portfolio_state {

    my $delim = "\t";
    my $newline = "\n";
    my $end = '';

    my $text, $summary;

    foreach (sort bywhen @trade_history) {

	my %trade = %$_;
	
	if(conf::show_trades()) {
	    
	    $text .= "\n$trade{'ticker'}\t$trade{'shares'}\t$trade{'sdate'}\t$trade{'start'}\t$trade{'edate'}\t$trade{'end'}\t" . sprintf("%.3f", $trade{'return'}) . "%";

	    if(conf::show_reward_ratio()) {
		$text .= "\t" . sprintf("%.3f", $trade{'rratio'});
	    }

	    if($trade{'split'}) {
		$text .= "\t [split adjusted]";
	    }
	}
    }

    if(conf::show_trades()) {

	foreach (keys %positions) {
	    $text .= "\n$_\t$positions{$_}{'shares'}\t$positions{$_}{'sdate'}\t$positions{$_}{'start'}\t(open)\t\t";
	}
    }

    my ($total, $xx) = get_total_equity();
    $ret = (($total - $starting_cash) / $starting_cash) * 100;
    $ret = sprintf("%.2f", $ret);

    $summary .= "\n\ntotal: $total (return $ret%)";
    $summary .= "\nMargin calls: $total_margin_calls" if $total_margin_calls > 0;
    $summary .= "\nPaid out $dividend_payout in dividends" if $dividend_payout > 0;
    
    my $compare = conf::benchmark();
    $summary .= "\n$compare buy and hold: " . sprintf("%.2f", change_over_period($compare)) . "%";

    if(scalar @trade_history > 0) {
 
	my @returns = map {$_->[0]} @equity_curve;

	my ($avg_win, $avg_loss, $winning_trades, $losing_trades) = compute_averages(\@trade_history);
	my ($avg_r_win, $avg_r_loss) = compute_average_ratios(\@trade_history);
	my $win_ratio = ($winning_trades / (scalar @trade_history)) * 100;
	my $stddev = compute_standard_deviation(\@equity_curve);
	my $max_drawdown = compute_max_drawdown(\@returns);
	my $sharpe = compute_sharpe_ratio(\@equity_curve, 0.5);

	my $system_quality = sprintf("%.1f", compute_system_quality(\@trade_history));
	my $recovery = sprintf("%.3f", (abs($ret) / $max_drawdown)) if $max_drawdown != 0;

	$sharpe = sprintf("%.3f", $sharpe);
	$win_ratio = sprintf("%.2f", $win_ratio);	
	$stddev = sprintf("%.3f", $stddev);
	$avg_win = sprintf("%.3f", $avg_win);
	$avg_loss = sprintf("%.3f", $avg_loss);
	$avg_r_win = sprintf("%.3f", $avg_r_win);
	$avg_r_loss = sprintf("%.3f", $avg_r_loss);
	$max_drawdown = sprintf("%.3f", $max_drawdown);
	$ulcer_index = sprintf("%.4f", 	compute_ulcer(\@returns));
	$mae = sprintf("%.3f", compute_max_adverse(\@trade_history));
	$expect = sprintf("%.4f", compute_expectancy(\@trade_history));
	$expect_r = sprintf("%.4f", compute_expectancy_r(\@trade_history));

	$summary .= "\n" . scalar @trade_history . " trades ";
	$summary .= "($winning_trades wins / $losing_trades losses)";
	$summary .= "\nWin ratio $win_ratio%";
 	$summary .= "\nAverage win $avg_win% / $avg_r_win R";
 	$summary .= "\nAverage loss $avg_loss% / $avg_r_loss R";
	$summary .= "\nMaximum drawdown $max_drawdown%";
	$summary .= "\nSystem quality number $system_quality"; 
	$summary .= "\nUlcer Index $ulcer_index";
	$summary .= "\nStandard deviation of returns $stddev";
	$summary .= "\nSharpe ratio $sharpe";
	$summary .= "\nRecovery factor $recovery";
	$summary .= "\nMax adverse excursion $mae%";
	$summary .= "\nExpectancy $expect% / ";
	$summary .= "$expect_r R";
    }

    if(conf::timer()) {
	$summary .= "\nElapsed Time: " . conf::elapsed_time() . " seconds";
    }

    $output .= "$text ^^^^^ $summary";
    conf::output($output);

    if(conf::draw_curve()) {
	charting::draw_line_chart(\@equity_curve, conf::draw_curve());
    }
}


1;
