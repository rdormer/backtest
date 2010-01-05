package equity_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuple_list = @{$self->get_tuples};
    my $sql_hash = $self->result_hash;

    for(my $index = 0; $index <= $#tuple_list; $index++) {

	my $curtoken = $tuple_list[ $index ][$self->keyindex];

	if($curtoken =~ /total stockholders/i || $curtoken =~ /total shareholders/i) {

	    if($tuple_list[$index][$self->selection_offset] =~ /^-?[0-9]+\.?[0-9]?$/) {
		$sql_hash->{total_equity} = $tuple_list[$index][$self->selection_offset] if not exists $sql_hash->{total_equity};
	    }
	} 
    }
}


1;
