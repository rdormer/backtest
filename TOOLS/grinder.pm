
@value_generators = (\&bollinger_up, \&bollinger_low, \&macd, \&avgc, \&ppo, \&exp_avgc);

sub bollinger_up {
    my $per = int rand(50);
    return "BOLLINGER_UPPER$per,2";
}

sub bollinger_low {
    my $per = int rand(50);
    return "BOLLINGER_LOWER$per,2";
}

sub macd {
    return "MACD10,12,9";
}

sub avgc {

    my $per = int rand(200);
    return "AVGC$per";
}

sub exp_avgc {

    my $per = int rand(200);
    return "EMAC$per";
}

sub ppo {
    return "PPO12,29,9";
}

sub atr {
    my $per = int rand(50);
    return "ATR$per";
}

1;
