
sub update_cash_balance {
    return shift;
}

sub initial_stop {

    my $initial_price = shift;
    my $isshort = shift;
    my $stop;

    if($isshort) {
	$stop = $initial_price * 1.1;
    } else {
	$stop = $initial_price * 0.9;
    }

    return sprintf("%.2f", $stop);
}

sub update_stop {

    my $tickerinfo = shift;
    my $ticker = shift;
}

sub adjust_for_slippage {
    return shift;
}

1;
