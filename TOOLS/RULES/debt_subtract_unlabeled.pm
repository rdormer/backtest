package debt_subtract_unlabeled;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my $res_hash = $self->result_hash;
    return if ! exists $res_hash->{total_equity};
    my @tuples = @{$self->get_tuples};

    if(! exists $res_hash->{total_liabilities}) {

	my $i, @last;

	for($i = $#tuples; $i >= 0; $i--) {

	    @last = @{ $tuples[$i] };
	    last if $#last >= 3;
	}

	if($#last >= 3) {

	    my $value = $last[$self->selection_offset + 2];
	    my $dif = $value - $res_hash->{total_equity};
	    $res_hash->{total_liabilities} = $self->apply_multiplier($dif);
	    return;
	}
    }
}

1;
