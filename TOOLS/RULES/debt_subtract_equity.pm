package debt_subtract_equity;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my $res_hash = $self->result_hash;
    return if ! exists $res_hash->{total_equity};
    my @tuples = @{$self->get_tuples};

    if(! exists $res_hash->{total_liabilities}) {

	for(my $off = $#tuples; $off >= 0; $off--) {

	    $token = $tuples[$off][$self->keyindex];
	    if($token =~ /liabilities/i && $token =~ /equity/i && $token =~ /total/i) {

		$debtval = $tuples[$off][$self->selection_offset] - $res_hash->{total_equity};
		$res_hash->{total_liabilities} = $self->apply_multiplier($debtval);
		return;
	    }
	}
    }
}

1;
