package equity_by_category;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuple_list = @{$self->get_tuples};
    my $sql_hash = $self->result_hash;

    return if exists $sql_hash->{total_equity};

    for(my $index = $#tuple_list; $index >= 0; $index--) {

	my $category = $tuple_list[ $index ][$self->catindex];
	my $key = $tuple_list[ $index ][$self->keyindex];

	if($category eq 'Equity' && $key !~ /liabilities/i) {

	    if($tuple_list[$index][$self->selection_offset] =~ /^-?[0-9]+\.?[0-9]?$/) {
		$sql_hash->{total_equity} = $tuple_list[$index][$self->selection_offset] if not exists $sql_hash->{total_equity};

		$val = $sql_hash->{total_equity};
	    }
	} 
    }
}


1;
