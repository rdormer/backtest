use macro_expander;
use screen_sql;
use Charting;
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

    foreach (@$longs) {
	if(positions_available() && ! exists $positions{$_} ) {
	    start_long_position($_);
	}
    }
}

sub start_long_position {

    if(start_position($_[0])) {
	$current_cash -= $sharecount * $price;
	$positions{$_[0]}{'short'} = 0;
	$positions{$_[0]}{'exit'} = \@long_exits;
	$positions{$_[0]}{'stop'} = initial_stop($price, 0);
    }
}

sub start_short_position {

    if(start_position($_[0])) {
	$current_cash += $sharecount * $price;
	$positions{$_[0]}{'short'} = 1;
	$positions{$_[0]}{'exit'} = \@short_exits;
	$positions{$_[0]}{'stop'} = initial_stop($price, 1);
    }
}

sub start_position {

    my $ticker = shift;

    cache_ticker_history($ticker);
    current_from_cache($ticker);
    $dindex = search_array_date(get_exit_date(), $current_prices);
    $price = fetch_open_at($dindex);

    if($price > 0) {
	$sharecount = int($position_size / $price);
    } else {
	$sharecount = 0;
    }

    if($sharecount >= 1) {

	$positions{$ticker}{'sdate'} = get_exit_date();
	$positions{$ticker}{'shares'} = $sharecount;
	$positions{$ticker}{'start'} = $price;
	$positions{$ticker}{'mae'} = $price;
	
    } else {
	clear_history_cache($ticker);
    }

    return $sharecount >= 1;
}


sub update_positions {

    return if get_date() eq "";

    @temp = keys %positions;
    @tlist = @ {set_ticker_list(\@temp)};

    init_filter();

    #we update our cash position before selling because interest payments, etc.
    #would tend to happen before settlement of a trade.  Then we loop through
    #each position to see if it hit a sell rule or was stopped out, calling our
    #update stop hook first - stops are updated at the start of each period.

    $current_cash = update_cash_balance($current_cash);

    my $equity = 0;
    foreach $ticker (@temp) {

	if(pull_ticker_history($ticker)) {
	    if(filter_results($ticker, @{ $positions{$ticker}{'exit'}})) {
		sell_position($ticker);
	    } else {

		update_stop(\%positions, $ticker);
		$cur_ticker_index = current_index();
		$low = fetch_low_at($cur_ticker_index);
		$high = fetch_high_at($cur_ticker_index);
		$isshort = $positions{$ticker}{'short'};

		if(! $isshort && ! stop_position($ticker, $low)) {
		    $equity += (fetch_close_at($index) * $positions{$ticker}{'shares'});
		    $positions{$ticker}{'mae'} = $low if $low < $positions{$ticker}{'mae'};
		} 

		if($isshort && ! stop_position($ticker, $high)) {
		    $positions{$ticker}{'mae'} = $high if $high > $positions{$ticker}{'mae'};
		} 
	    }
	}
    }

    $equity += $current_cash;
    push @equity_curve,$equity;

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

    $price = adjust_for_slippage($price);
    $amt = $positions{$target}{'shares'} * $price;
    $current_cash -= $amt if $positions{$target}{'short'};
    $current_cash += $amt if ! $positions{$target}{'short'};

    $positions{$target}{'end'} = $price;
    $positions{$target}{'edate'} = $edate;

    $ret = ($positions{$target}{'end'} - $positions{$target}{'start'}) / $positions{$target}{'start'};
    $ret = abs($ret) if $positions{$target}{'short'};

    $positions{$target}{'return'} = $ret * 100;
    $positions{$target}{'ticker'} = $target;
    delete $positions{$target}{'mae'} if $ret <= 0;

    push @trade_history, $positions{$target};
    clear_history_cache($target);
    delete $positions{$target};
}


sub get_total_equity {

    my $total_equity = $current_cash;
    my $index = 0;#current_index();
    foreach (keys %positions) {
	pull_ticker_history($_);
	$total_equity += (fetch_close_at($index) * $positions{$_}{'shares'}) if ! $positions{$_}{'short'};
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

    foreach (sort bywhen @trade_history) {

	my %trade = %$_;

	print "\n$trade{'ticker'}\t$trade{'shares'}\t$trade{'sdate'}\t$trade{'start'}\t$trade{'edate'}\t$trade{'end'}\t" . sprintf("%.3f", $trade{'return'}) . "%";

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


    foreach (keys %positions) {
	print "\n$_\t$positions{$_}{'shares'}\t$positions{$_}{'sdate'}\t$positions{$_}{'start'}\t(open)";
    }

    $total = get_total_equity();
    $ret = (($total - $starting_cash) / $starting_cash) * 100;
    print "\n\ntotal: $total (return $ret)";
    
    print "\nQQQQ buy and hold: " . change_over_period("QQQQ");

    $max_drawdown_len = $drawdown_days if ! $max_drawdown_len;
    
    if(scalar @trade_history > 0) {

	$win_ratio = $winning_trades / (scalar @trade_history);
	$avg_win = $sum_wins / $winning_trades if $winning_trades > 0;
	$avg_loss = $sum_losses / $losing_trades if $losing_trades > 0;

	print "\n" . scalar @trade_history . " trades";
	print "  (discarded $discards trades)" if $discards > 0;
	print "\n$losing_trades losing trades (avg loss $avg_loss)";
	print "\n$winning_trades wining trades (avg win $avg_win)";
	print "\n$max_drawdown maximum drawdown";
	print "\n$max_drawdown_len days longest drawdown";
	print "\n$win_ratio win ratio";
	print "\n$max_adverse max adverse excursion";
	
	$expectancy = ($win_ratio * $avg_win) + ((1 - $win_ratio) * $avg_loss);
	print "\nExpectancy $expectancy";

    }
    
    print "\n";

    if(conf::draw_curve()) {
	charting::draw_line_chart(\@equity_curve, conf::draw_curve());
   }
}


1;
