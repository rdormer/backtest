use analysis::indicators;

sub compute_averages {

    my $trade_list = shift;
    my $winning_trades = 0;
    my $losing_trades = 0;
    my $sum_losses = 0;
    my $sum_wins = 0;

    foreach (@$trade_list) {

	my %trade = %$_;

	if($trade{'return'} > 0) {
	    $winning_trades++;
	    $sum_wins += $trade{'return'};
	} elsif($trade{'return'} < 0) {
	    $losing_trades++;
	    $sum_losses += $trade{'return'};
	}
    }

    my $avg_win = $sum_wins / $winning_trades if $winning_trades > 0;
    my $avg_loss = $sum_losses / $losing_trades if $losing_trades > 0;
    return ($avg_win, $avg_loss, $winning_trades, $losing_trades);
}

sub compute_average_ratios {

    my $trade_list = shift;
    my $winning_trades = 0;
    my $losing_trades = 0;
    my $sum_losses = 0;
    my $sum_wins = 0;

    foreach (@$trade_list) {

	my %trade = %$_;

	if($trade{'rratio'} > 0) {
	    $winning_trades++;
	    $sum_wins += $trade{'rratio'};
	} elsif($trade{'return'} < 0) {
	    $losing_trades++;
	    $sum_losses += $trade{'rratio'};
	}
    }

    my $avg_win = $sum_wins / $winning_trades if $winning_trades > 0;
    my $avg_loss = $sum_losses / $losing_trades if $losing_trades > 0;
    return ($avg_win, $avg_loss, $winning_trades, $losing_trades);
}

sub compute_expectancy {

    my $trade_list = shift;
    my ($avg_win, $avg_loss, $winning_trades) = compute_averages($trade_list);
    my $win_ratio = $winning_trades / (scalar @$trade_list);
    return ($win_ratio * $avg_win) + ((1 - $win_ratio) * $avg_loss);
}

sub compute_expectancy_r {

    my $trade_list = shift;
    my ($avg_win, $avg_loss, $winning_trades) = compute_average_ratios($trade_list);
    my $win_ratio = $winning_trades / (scalar @$trade_list);
    return ($win_ratio * $avg_win) + ((1 - $win_ratio) * $avg_loss);
}

sub compute_max_adverse {

    my $trade_list = shift;
    my $max_adverse = 0;

    foreach (@$trade_list) {

	my %trade = %$_;

	if($trade{'return'} > 0) {
	    my $excursion = (($trade{'start'} - $trade{'mae'}) / $trade{'start'}) * 100;
	    $max_adverse = $excursion if $excursion > $max_adverse;
	}
    }

    return $max_adverse;
}

sub compute_max_drawdown {

    my $curve = shift;
    my $max = $curve->[0];
    my $min = $max;
    my $days = 0;
    my $drawdown = 0;

    foreach $equity (@$curve) {

	if($equity >= $max) {

	    $max = $equity;
	    $min = $max;

	} elsif ($equity <= $min) {

	    $min = $equity;
	    my $d = (($max - $min) / $max) * 100;
	    $drawdown = ($d > $drawdown ? $d : $drawdown);
	} 
    }
    
    return $drawdown;
}

sub compute_ulcer {

    my $equity_curve = shift;
    return ulcer_index(20, $equity_curve);
}


#Van K. Tharp's system quality number
#SQN=root(n)*expectancy/stdev(R)
#root(n) - square root of number of trades
#expectancy - the expectancy of your system in R multiples
#stddev(R) - standard deviation of your trade profits in R

sub compute_system_quality {

    my $trade_list = shift;
    my $num_root = sqrt(scalar @$trade_list);
    my $expect_r = compute_expectancy_r($trade_list);
    my $stddev = standard_deviation($trade_list, 'rratio');

    return 0 if $stddev == 0;
    return $num_root * ($expect_r / $stddev);
}

#the sharpe ratio is the average rate of returns
#divided by the standard deviation of those returns

sub compute_sharpe_ratio {

    my $equity_curve = shift;
    my $risk_free = shift;

    my $sum = 0;

    foreach (@$equity_curve) {
	my $ret = ($_->[0] - conf::startwith()) / conf::startwith();
	$sum += ($ret * 100);
    }
    
    my $rr = $sum / scalar @$equity_curve;
    my $sd = compute_standard_deviation($equity_curve);

    return 0 unless $sd;
    return ($rr - $risk_free) / $sd;

}

#standard deviation of monthly returns

sub compute_standard_deviation {

    my $equity_curve = shift;
    my @returns = ();
    my $month = 0;

    foreach $point (@$equity_curve) {

	if($point->[1] =~ /[0-9]{4}-([0-9]{2})-[0-9]{2}/) {

	    if($1 != $month) {

		my $ret = ($point->[0] - conf::startwith()) / conf::startwith();
		push @returns, {'ret' => $ret * 100};
		$month = $1;
	    }
	}
    }

    return standard_deviation(\@returns, 'ret');
}

#compute the population standard
#deviation of the given field

sub standard_deviation {

    my $trade_list = shift;
    my $field = shift;

    my $sum = 0;
    foreach(@$trade_list) {
	$sum += $_->{$field};
    }

    my $avg = $sum / scalar @$trade_list;
    my @deviations = map { ($_->{$field} - $avg) ** 2 } @$trade_list;

    $sum = 0;
    foreach(@deviations) {
	$sum += $_;
    }

    return sqrt( $sum / scalar @deviations );
}

1;
