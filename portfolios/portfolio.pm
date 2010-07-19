use macro_expander;
use charting;
use POSIX;
use conf;

eval "use strategies::" . conf::strategy();

my %positions;
my @trade_history;
my @long_exits;
my @short_exits;

my @equity_curve;

my $starting_cash;
my $current_cash;
my $position_count;
my $position_size;
my $risk_percent;

my $max_equity;
my $max_drawdown;
my $max_drawdown_len;
my $drawdown_days;

my $cur_ticker_index;
my $discards;

my $total_margin_calls;
my $total_short_equity;

my %dividend_cache;
my $dividend_payout;

sub init_portfolio {

    my $longexits = shift;
    my $shortexits = shift;

    $risk_percent = conf::risk_percent();
    $starting_cash = conf::startwith();
    $current_cash = $starting_cash;

    calculate_position_count();
    calculate_position_size($current_cash);

    @long_exits = @$longexits;
    @short_exits = @$shortexits;
}


sub positions_available {

    return floor($current_cash / $position_size);
}

sub calculate_position_size {
    $newcapital = shift;
    $position_size += $newcapital / $position_count;
}

sub calculate_position_count {

    #notional % of a $100,000 portfolio

    $atrisk = 100000 * $risk_percent;
    $percentof = $atrisk / (10 / 100);
    $position_count = int(100000 / $percentof);
}

sub add_positions {

    my $longs = shift;
    my $shorts = shift;

    my $longlen = scalar @$longs;
    my $shortlen = scalar @$shorts;
    my $len = $longlen > $shortlen ? $longlen : $shortlen;

    for(my $i = 0; $i < $len; $i++) {

	if($longlen > 0 && $longlen > $i && positions_available() && ! exists $positions{$longs->[$i]}) {
	    start_long_position($longs->[$i]);
	}

	if($shortlen > 0 && $shortlen > $i && positions_available() && ! exists $positions{$shorts->[$i]}) {
	    start_short_position($shorts->[$i]);
	}
    }
}

sub start_long_position {

    my $count = start_position($_[0]);

    if($count > 0) {

	my $price = $positions{$_[0]}{'start'};
	my $stop = initial_stop($price, 0);

	$current_cash -= $count * $price;
	$positions{$_[0]}{'short'} = 0;
	$positions{$_[0]}{'exit'} = \@long_exits;
	$positions{$_[0]}{'stop'} = initial_stop($price, 0);
	$positions{$_[0]}{'risk'} = (($price - $stop) / $price) * 100;
    }
}

sub start_short_position {

    my $count = start_position($_[0]);
    if($current_cash >= 2000 && $count > 0) {

	#we have to check to see if this new position takes us over the initial margin
	#requirement, and if it does, back out the trade

	if($current_cash < $total_short_equity + ($count * $price) * conf::initial_margin()) {
	    delete $positions{$_[0]};
	} else {

	    my $price = $positions{$_[0]}{'start'};
	    my $stop = initial_stop($price, 1);

	    $current_cash += $count * $price;
	    $positions{$_[0]}{'short'} = 1;
	    $positions{$_[0]}{'exit'} = \@short_exits;
	    $positions{$_[0]}{'stop'} = $stop;
	    $positions{$_[0]}{'risk'} = (($price - $stop) / $price) * -100;
	}
    }
}

sub start_position {

    my $ticker = shift;
    my $sharecount = 0;

    return 0 if get_date() eq conf::finish();

    my $temp = pull_history_by_limit($ticker, get_exit_date(), 1);
    my $price = $temp->[0][OPEN_IND];
    my $volume = $temp->[0][VOL_IND];

    return 0 if $temp->[0][DATE_IND] ne get_exit_date();

    if(not exists $dividend_cache{$ticker}) {
	$dividend_cache{$ticker} = pull_dividends($ticker, get_date(), conf::finish());
    }

    if($price > 0) {

	$sharecount = int($position_size / $price);

	if($sharecount >= 1 && $sharecount < $volume) {

	    $positions{$ticker}{'sdate'} = get_exit_date();
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
		$remainder = sprintf("%.2f", $remainder);
	
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

    $current_cash = update_cash_balance($current_cash);

    my $equity = 0;
    $total_short_equity = 0;

    foreach $ticker (@temp) {

	#don't split adjust the first day or it could throw some
	#edge cases out of whack.  Also, can't pay out dividends first day.

	if(get_date() gt $positions{$ticker}{'sdate'}) {
	    split_adjust_position($ticker);
	    update_balance_dividend($ticker);
	}


	#check against sell rules, update stats and
	#stops if we're not closing the position

	if(filter_results($ticker, @{ $positions{$ticker}{'exit'}})) {
	    sell_position($ticker);
	} else {

	    update_stop(\%positions, $ticker);
	    $cur_ticker_index = current_index();
	    $low = fetch_low_at($cur_ticker_index);
	    $high = fetch_high_at($cur_ticker_index);
	    $isshort = $positions{$ticker}{'short'};

	    if(fetch_volume_at($cur_ticker_index) > 0) {

		if(! $isshort && ! stop_position($ticker, $low)) {
		    $equity += (fetch_close_at($cur_ticker_index) * $positions{$ticker}{'shares'});
		    $positions{$ticker}{'mae'} = $low if $low < $positions{$ticker}{'mae'};
		} 

		if($isshort && ! stop_position($ticker, $high)) {
		    $total_short_equity += (fetch_close_at($cur_ticker_index) * $positions{$ticker}{'shares'});
		    $positions{$ticker}{'mae'} = $high if $high > $positions{$ticker}{'mae'};
		} 
	    }
	}
    }

    $equity += $current_cash;
    push @equity_curve,$equity;

    if(($total_short_equity * conf::maint_margin()) > $current_cash) {
	my $val = $total_short_equity * conf::maint_margin() - $current_cash;
	$current_cash += $val;
	$total_margin_calls += $val;
    }

    if($equity > $max_equity) {
	$max_equity = $equity;
	$max_drawdown_len = $drawdown_days if $drawdown_days > $max_drawdown_len;
	$drawdown_days = 0;
    } else {
	$drawdown = ($max_equity - $equity) / $max_equity;
	$drawdown *= 100;
	$max_drawdown = $drawdown if $drawdown > $max_drawdown;
	$drawdown_days++;
    }

    set_ticker_list(\@tlist);
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

sub sell_position {

    $dindex = search_array_date(get_exit_date(), $current_prices);
    $price = fetch_open_at($dindex);
    end_position(shift, $price, get_exit_date());
}

sub stop_position {

    my $ticker = shift;
    my $price = shift;

    #for long positions, if the low of the day was below the stop, we're stopped out
    if(! $positions{$ticker}{'short'} && $positions{$ticker}{'stop'} >= $price) {

	#if open was less than the stop we have to sell at the open
	if(fetch_open_at($cur_ticker_index) < $positions{$ticker}{'stop'}) {
	    end_position($ticker, fetch_open_at($cur_ticker_index), fetch_date_at($cur_ticker_index));
	} else {
	    end_position($ticker, $positions{$ticker}{'stop'}, fetch_date_at($cur_ticker_index));
	}

	return 1;
    }

    #for short positions, if the high of the day was above the stop, we're stopped out
    if($positions{$ticker}{'short'} && $positions{$ticker}{'stop'} <= $price) {

	#if open was more than the stop we have to sell at the open
	if(fetch_open_at($cur_ticker_index) > $positions{$ticker}{'stop'}) {
	    end_position($ticker, fetch_open_at($cur_ticker_index), fetch_date_at($cur_ticker_index));
	} else {
	    end_position($ticker, $positions{$ticker}{'stop'}, fetch_date_at($cur_ticker_index));
	}

	return 1;
    }

    return 0;
}

sub end_position {

    my $target = shift;
    my $price = shift;
    my $edate = shift;

    if($edate eq $positions{$target}{'sdate'} && $price == $positions{$target}{'start'}) {
	$current_cash += $positions{$target}{'shares'} * $price;
	delete $positions{$target};
	$discards++;
	return;
    }

    $amt = $positions{$target}{'shares'} * $price;
    $amt = adjust_for_slippage($amt, $positions{$target}{'shares'}, $price);
    $current_cash -= $amt if $positions{$target}{'short'};
    $current_cash += $amt if ! $positions{$target}{'short'};

    $positions{$target}{'end'} = $price;
    $positions{$target}{'edate'} = $edate;

    $ret = ($positions{$target}{'end'} - $positions{$target}{'start'}) / $positions{$target}{'start'};
    $ret = -($ret) if $positions{$target}{'short'};
    $ret *= 100;

    $positions{$target}{'return'} = $ret;
    $positions{$target}{'ticker'} = $target;
    $positions{$target}{'rratio'} = $ret / $positions{$target}{'risk'};
    delete $positions{$target}{'mae'} if $ret <= 0;

    push @trade_history, $positions{$target};
    delete $positions{$target};
}


sub get_total_equity {

    my $total_equity = $current_cash;

    foreach (keys %positions) {
	$current_prices = pull_data($_, get_date(), 1);
	$total_equity += (fetch_close_at(0) * $positions{$_}{'shares'}) if ! $positions{$_}{'short'};
    }

    return $total_equity;
}


sub bywhen { 
    return $$a{'sdate'} gt $$b{'sdate'};
}

sub print_portfolio_state {

    my $winning_trades = 0;
    my $losing_trades = 0;
    my $sum_losses = 0;
    my $sum_wins = 0;
    my $max_adverse = 0;

    my $delim = "\t";
    my $newline = "\n";
    my $end = '';

    if(conf::cgi_handle()) {
	$delim = "</td><td>";
	$newline = "<tr><td>";
	$end = "</td></tr>";
    }


    my $text, $summary;

    foreach (sort bywhen @trade_history) {

	my %trade = %$_;
	
	if(conf::show_trades()) {
	    
	    $text .= "$newline$trade{'ticker'}$delim$trade{'shares'}$delim$trade{'sdate'}$delim$trade{'start'}$delim$trade{'edate'}$delim$trade{'end'}$delim" . sprintf("%.3f", $trade{'return'}) . "%";

	    if(conf::show_reward_ratio()) {
		$text .= "$delim" . sprintf("%.3f", $trade{'rratio'});
	    }

	    if($trade{'split'}) {
		$text .= "$delim [split adjusted]";
	    }
	}

	$text .= $end;

	if($trade{'return'} > 0) {
	    $winning_trades++;
	    $sum_wins = $trade{'return'};
	    $excursion = (($trade{'start'} - $trade{'mae'}) / $trade{'start'}) * 100;
	    $max_adverse = $excursion if $excursion > $max_adverse;
	} else {
	    $losing_trades++;
	    $sum_losses = $trade{'return'};
	}
    }

    if(conf::show_trades()) {

	foreach (keys %positions) {
	    $text .= "$newline$_$delim$positions{$_}{'shares'}$delim$positions{$_}{'sdate'}$delim$positions{$_}{'start'}$delim(open)$delim$delim$end";
	}
    }


    $total = get_total_equity();
    $ret = (($total - $starting_cash) / $starting_cash) * 100;
    $summary .= $newline . $newline . "total: $total (return $ret)$end";
    $summary .= $newline . "Margin calls: $total_margin_calls$end" if $total_margin_calls > 0;
    $summary .= $newline . "Paid out $dividend_payout in dividends$end" if $dividend_payout > 0;
    
    $summary .= "$newline" . "QQQQ buy and hold: " . change_over_period("QQQQ") . $end;

    $max_drawdown_len = $drawdown_days if ! $max_drawdown_len;
    
    if(scalar @trade_history > 0) {
 
	$win_ratio = $winning_trades / (scalar @trade_history);
	$avg_win = $sum_wins / $winning_trades if $winning_trades > 0;
	$avg_loss = $sum_losses / $losing_trades if $losing_trades > 0;

	$summary .= "$newline" . scalar @trade_history . " trades";
        $summary .= "  (discarded $discards trades)" if $discards > 0;
	$summary .= $end;

	$summary .= $newline. "$losing_trades losing trades (avg loss $avg_loss)$end";
	$summary .= $newline. "$winning_trades wining trades (avg win $avg_win)$end";
	$summary .= $newline . "$max_drawdown maximum drawdown$end";
	$summary .= $newline . "$max_drawdown_len days longest drawdown$end";
	$summary .= $newline . "$win_ratio win ratio$end";
	$summary .= $newline . "$max_adverse max adverse excursion$end";
	
	$expectancy = ($win_ratio * $avg_win) + ((1 - $win_ratio) * $avg_loss);
	$summary .= $newline . "Expectancy $expectancy$end";

    }

    if(conf::cgi_handle()) {

	my $output = "###<table class='sortable' id='results'>";

	if(scalar @trade_history > 0) {
	    $output .= "<tr><th>Ticker</th><th>Shares</th><th>Buy Date</th>";
	    $output .= "<th>Buy Price</th><th>Sell Date</th><th>Sell Price</th><th>Return</th></tr>";
	}

	$output .= "$text</table><table>$summary</table>###";
	shmwrite(get_cgi(), $output, 0, length $output);

    } else {
	print "$text $summary";
    }

    if(conf::draw_curve()) {
	charting::draw_line_chart(\@equity_curve, conf::draw_curve());
    }
}


1;
