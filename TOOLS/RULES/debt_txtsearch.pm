package debt_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    my $off = $self->backward_token_search("total liabilities", $#tuples, "assets");
    if($off < 0) {
	$off = $self->backward_token_search("total", $#tuples, "assets");
    }

    if($off >= 0 && $tuples[$off][$self->selection_offset] !~ /.*[A-Z]+.*/i && 
       ! exists $self->result_hash->{total_liabilities}) {

	my $val = $tuples[$off][$self->selection_offset];
	$self->result_hash->{total_liabilities} = $self->apply_multiplier($val);

    }
}

1;
