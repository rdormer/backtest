use screen_data;

my %rank_cache;
my $previous_date;

sub relative_strength {

    my $period = shift;
    my $rstrength = "((fetch_close_at(0) - fetch_close_at($period)) / fetch_close_at($period)) * 100";
    return rank_by($rstrength, $period + 1);
}

sub rank_by {

    my $expr = shift;
    my $pull = shift;
    my @statement = ([$expr, $pull]);

    if(get_date() ne $previous_date) {
	$previous_date = get_date();
	%rank_cache = ();
    }

    if(not exists $rank_cache{$expr}) {
	$rank_cache{$expr} = compute_rankings(\@statement);
    }

    return $rank_cache{$expr}{ current_ticker() };
}

sub compute_rankings {

    my $expression = shift;
    my %values;

    sub scomp {
	$values{$a} <=> $values{$b};
    }

    foreach (ticker_list()) {
	$values{$_} = eval_expression($expression, $_);
    }

    my @sorted = sort scomp keys %values;
    my $i = $#sorted - 1;

    my $len = scalar @sorted;
    for($i = 1; $i <= $len; $i++) {
	$values{ $sorted[$i - 1] } = ($i / $len) * 100;
    }


    return \%values;
}

1;
