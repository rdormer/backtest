package cur_debt_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    my $off = $self->backward_token_search("total current liabilities", $#tuples, "assets");
    
    if($off >= 0) {

	my $value = $tuples[$off][$self->selection_offset];
	if($value !~ /.*[A-Z]+.*/i && ! exists $self->result_hash->{current_liabilities}) {

	    $self->result_hash->{current_liabilities} = $value;
	}	
    }
}

1;
