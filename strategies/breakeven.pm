#implements a trailing stop to breakeven point


sub update_cash_balance {
    return shift;
}

sub initial_stop {

    my $initial_price = shift;
    return $initial_price * 0.9;
}

sub update_stop {

    my $tickerinfo = shift;
    my $ticker = shift;

    my $stop = $tickerinfo->{$ticker}{'stop'};
    if($stop < $tickerinfo->{$ticker}{'start'}) {

	$newstop = fetch_low_at(0) * 0.9;
	$tickerinfo->{$ticker}{'stop'} = $newstop if $newstop > $stop;
    }
}

sub adjust_for_slippage {
    return shift;
}

1;
