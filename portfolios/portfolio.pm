use macro_expander;
use screen_sql;
use Charting;
use Date::Manip;
use POSIX;


my %positions;
my @trade_history;
my @actions;

my @equity_curve;

my $starting_cash;
my $current_cash;
my $position_count;
my $position_size;
my $risk_percent;
my $stop_loss;

my $max_equity;
my $max_drawdown;
my $max_drawdown_len;
my $drawdown_days;

sub init_portfolio {

    $starting_cash= 5000;
    $current_cash = $starting_cash;
    $risk_percent = .01;
    $stop_loss = 10;

    calculate_position_count();
    calculate_position_size($current_cash);

    $t = screen_from_file(shift);
    @actions = @$t;
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
    $percentof = $atrisk / ($stop_loss / 100);
    $position_count = int(100000 / $percentof);
}

sub add_positions {

    foreach $ticker (@_) {

	if(positions_available() && ! exists $positions{$ticker} ) {

	    $price = get_entry_price($ticker);
	    next if $price <= 0;

	    cache_ticker_history($ticker);

	    my $sharecount = int($position_size / $price);

	    if($sharecount >= 1) {

		$positions{$ticker}{'stop'} = $price * (1 - ($stop_loss/100));
		$positions{$ticker}{'sdate'} = get_exit_date();
		$positions{$ticker}{'shares'} = $sharecount;
		$positions{$ticker}{'start'} = $price;
		$positions{$ticker}{'mae'} = $price;

		$current_cash -= $sharecount * $price;
	    }
	}
    }
}


sub update_positions {

    return if get_date() eq "";

    @temp = keys %positions;
    @tlist = @ {set_ticker_list(\@temp)};
    @tact = @ {set_actions(\@actions)};


    init_filter();

    my $equity = 0;
    foreach $ticker (@temp) {
	if(pull_ticker_history($ticker)) {
	    if(filter_results($ticker)) {
		sell_position($ticker);
	    } else {

		$low = fetch_low_at(current_index());
		$positions{$ticker}{'mae'} = $low if $low < $positions{$ticker}{'mae'};

		if($positions{$ticker}{'stop'} >= $low) {
		    stop_position($ticker);
		} else {
		    $equity += (fetch_close_at($index) * $positions{$ticker}{'shares'});
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
    set_actions(\@tact);
}

sub sell_position {
    $ticker = shift;
    end_position($ticker, get_exit_price($ticker), get_exit_date());
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
	$avg_win = $sum_wins / $winning_trades;
	$avg_loss = $sum_losses / $losing_trades;

	print "\n" . scalar @trade_history . " trades";
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

    draw_line_chart(\@equity_curve);
}


1;
