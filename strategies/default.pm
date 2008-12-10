
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
}

sub adjust_for_slippage {
    return shift;
}

1;
