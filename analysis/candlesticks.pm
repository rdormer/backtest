use screen_data;
use Finance::TA;

my (@cdl_opens, @cdl_highs, @cdl_lows, @cdl_closes);

#we only get away with a common setup
#routine because all of the TA-LIB functions
#for candlesticks take the exact same arguments

sub candle_setup {

    @cdl_opens = map $_->[OPEN_IND], @$current_prices;
    @cdl_highs = map $_->[HIGH_IND], @$current_prices;
    @cdl_lows = map $_->[LOW_IND], @$current_prices;
    @cdl_closes = map $_->[CLOSE_IND], @$current_prices;
}

sub MARUBOZU_Lookback {
    return 1;
}

sub candle_bullish_marubozu {

    return ($current_prices->[0][HIGH_IND] == $current_prices->[0][CLOSE_IND]) &&
       ($current_prices->[0][LOW_IND] == $current_prices->[0][OPEN_IND]) &&
       ($current_prices->[0][HIGH_IND] > $current_prices->[0][LOW_IND]);
}

sub candle_bearish_marubozu {

    return ($current_prices->[0][HIGH_IND] == $current_prices->[0][OPEN_IND]) &&
       ($current_prices->[0][LOW_IND] == $current_prices->[0][CLOSE_IND]) &&
       ($current_prices->[0][HIGH_IND] > $current_prices->[0][LOW_IND]);
}

sub candle_bullish_top {
    return spinning_top() > 0;
}

sub candle_bearish_top {
    return spinning_top() < 0;
}

sub spinning_top {

    candle_setup();
    my $val = TA_CDLSPINNINGTOP(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0];
}

sub candle_doji {

    candle_setup();
    my $val = TA_CDLDOJI(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0] > 0;
}

sub candle_dragonfly {

    candle_setup();
    my $val = TA_CDLDRAGONFLYDOJI(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0] > 0;
}

sub candle_gravestone {

    candle_setup();
    my $val = TA_CDLGRAVESTONEDOJI(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0] > 0;
}

sub candle_hammer {

    candle_setup();
    my $val = TA_CDLHAMMER(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0] > 0;

}

sub candle_hanging_man {

    candle_setup();
    my $val = TA_CDLHANGINGMAN(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0] > 0;
}

sub candle_inverted_hammer {

    candle_setup();
    my $val = TA_CDLINVERTEDHAMMER(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0] > 0;
}

sub candle_shooting_star {

    candle_setup();
    my $val = TA_CDLSHOOTINGSTAR(0, $#cdl_closes, \@cdl_opens, \@cdl_highs, \@cdl_lows, \@cdl_closes);
    return $val->[0] > 0;
}

1;
