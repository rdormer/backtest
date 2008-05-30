use screen_sql;
use Charting;
use Date::Manip;
use POSIX;


my @positions;
my @equity_curve;

my $starting_cash;
my $current_cash;
my $update_count;
my $update_threshold;
my $update_deposit;

my $max_equity;
my $max_drawdown;
my $max_drawdown_len;
my $drawdown_days;

sub init_portfolio {

    $starting_cash= 1000;
    $current_cash = $starting_cash;
    $update_threshold = 30;
    $update_deposit = 700;
}

sub positions_available {

    return 1;
}


sub add_positions {

    $position_size = $current_cash / scalar @_ if scalar @_ > 0;

    foreach $ticker (@_) {

	$price = get_entry_price($ticker);
	next if $price <= 0;

	cache_ticker_history($ticker);
	pull_ticker_history($ticker);

	my $sharecount = int($position_size / $price);

	if($sharecount >= 1) {

	    my %temp;

	    $temp{'ticker'} = $ticker;
	    $temp{'sdate'} = get_exit_date();
	    $temp{'shares'} = $sharecount;
	    $temp{'start'} = $price;

	    push @positions, \%temp;

	    $current_cash -= $sharecount * $price;
	}
    }
}


sub update_positions {

    return if get_date() eq "";

    if(++$update_count > $update_threshold) {
	$current_cash += $update_deposit;
	$starting_cash += $update_deposit;
	$update_count = 0;
    }

    $equity = get_total_equity();
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
}

sub sell_position {

}

sub stop_position {

}

sub end_position {

}


sub get_total_equity {

    my $total_equity = $current_cash;
    my $index = 0;#current_index();

    foreach (@positions) {
	my %t = %$_;
	pull_ticker_history($_);
	$total_equity += (fetch_close_at($index) * $positions{$_}{'shares'});

    }

    return $total_equity;
}


sub bywhen { 

    $d1 = $$a{'sdate'};
    $d2 = $$b{'sdate'};

    return Date_Cmp($d1, $d2);
}

sub print_portfolio_state {

    $final_day = get_date();
    foreach (@positions) {
	my %t = %$_;
	print "\n$t{'ticker'}\t$t{'shares'}\t$t{'sdate'}\t$t{'start'}";
	
	$final = get_price_at_date($t{'ticker'}, $final_day);
	$ret = (($final - $t{'start'}) / $t{'start'}) * 100;

	print"\t$final\t$ret";
	
    }

    $total = get_total_equity();
    $ret = (($total - $starting_cash) / $starting_cash) * 100;
    print "\n\nstart\\total: $starting_cash\\$total (return $ret)";

    $max_drawdown_len = $drawdown_days if ! $max_drawdown_len;
    
    if(scalar @trade_history > 0) {

	print "\n" . scalar @trade_history . " trades";
	print "\n$max_drawdown maximum drawdown";
	print "\n$max_drawdown_len days longest drawdown";
    }
    
    print "\n";

    draw_line_chart(\@equity_curve);
}


1;
