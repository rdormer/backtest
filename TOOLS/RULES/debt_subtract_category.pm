package debt_subtract_category;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my $res_hash = $self->result_hash;
    return if ! exists $res_hash->{total_equity};
    my @tuples = @{$self->get_tuples};

    if(! exists $res_hash->{total_liabilities}) {

	for(my $off = $#tuples; $off >= 0; $off--) {

	    $curcategory = $tuples[$off][$self->catindex];
	    if($curcategory eq "Total Liabilities and equity") {

		$debtval = $tuples[$off][$self->selection_offset] - $res_hash->{total_equity};

		if($debtval > 0) {
		    $res_hash->{total_liabilities} = $self->apply_multiplier($debtval);
		    return;
		}
	    }
	}
    }
}

1;
