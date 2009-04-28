use macro_expander;
use screen_sql;
use Charting;
use Date::Manip;
use POSIX;
use conf;

eval "use strategies::" . conf::strategy();

my %positions;
my @trade_history;
my @actions;

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

my $discards;

sub init_portfolio {

    $risk_percent = conf::risk_percent();
    $starting_cash = conf::startwith();
    $current_cash = $starting_cash;

    calculate_position_count();
    calculate_position_size($current_cash);

    @actions = @_;
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

    my $sharecount = 0;

    foreach $ticker (@_) {

	if(positions_available() && ! exists $positions{$ticker} ) {

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

		$positions{$ticker}{'stop'} = initial_stop($price);
		$positions{$ticker}{'sdate'} = get_exit_date();
		$positions{$ticker}{'shares'} = $sharecount;
		$positions{$ticker}{'start'} = $price;
		$positions{$ticker}{'mae'} = $price;
		$current_cash -= $sharecount * $price;

	    } else {
		clear_history_cache($ticker);
	    }
	}
    }
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
	    if(filter_results($ticker, @actions)) {
		sell_position($ticker);
	    } else {

		update_stop(\%positions, $ticker);
		$low = fetch_low_at(current_index());

		if($positions{$ticker}{'stop'} >= $low) {
		    stop_position($ticker);
		} else {
		    $equity += (fetch_close_at($index) * $positions{$ticker}{'shares'});
		    $positions{$ticker}{'mae'} = $low if $low < $positions{$ticker}{'mae'};
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
    $ticker = shift;

    $dindex = search_array_date(get_exit_date(), $current_prices);
    $price = fetch_open_at($dindex);

    end_position($ticker, $price, get_exit_date());
}

sub stop_position {

    $ticker = shift;
    $cur = current_index();

    if(fetch_open_at($cur) < $positions{$ticker}{'stop'}) {
	end_position($ticker, fetch_open_at($cur), fetch_date_at($cur));
    } else {
	end_position($ticker, $positions{$ticker}{'stop'}, fetch_date_at($cur));
    }
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

    $positions{$target}{'end'} = $price;
    $positions{$target}{'edate'} = $edate;
    $ret = ($positions{$target}{'end'} - $positions{$target}{'start'}) / $positions{$target}{'start'};
    $positions{$target}{'return'} = $ret * 100;
    $positions{$target}{'ticker'} = $target;

    delete $positions{$target}{'mae'} if $ret <= 0;
    $current_cash += $positions{$target}{'shares'} * $price;

    push @trade_history, $positions{$target};
    clear_history_cache($target);
    delete $positions{$target};
}


sub get_total_equity {

    my $total_equity = $current_cash;
    my $index = 0;#current_index();
    foreach (keys %positions) {
	pull_ticker_history($_);
	$total_equity += (fetch_close_at($index) * $positions{$_}{'shares'});
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
