package revenue_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);
my @tuple_list;
my $self;

sub run {

    $self = shift;
    @tuple_list = @{$self->get_tuples};
    my $sql_hash = $self->result_hash;

    my @terms = ("total revenue", "total revenues", "net revenue", 
		 "net revenues", "revenue", "revenues", "net sales", "sales");

    foreach(@terms) {

	my $value = look_for_term($_);
	if($value =~ /[0-9]+/) {
	    $sql_hash->{revenue} = $value if ! exists $sql_hash->{revenue};
	    return;
	}
    }


    foreach(@terms) {

	my $value = grep_for_term($_);
	if($value =~ /[0-9]+/) {
	    $sql_hash->{revenue} = $value if ! exists $sql_hash->{revenue};
	    return;
	}
    }
}




sub look_for_term {

    my $term = shift;

    for(my $index = 0; $index <= $#tuple_list; $index++) {

	my $curtoken = $tuple_list[ $index ][$self->keyindex];

	if(lc($curtoken) eq lc($term)) {

	    if($tuple_list[$index][$self->selection_offset] =~ /^-?[0-9]+\.?[0-9]?$/) {
		return $tuple_list[$index][$self->selection_offset];
	    }
	} 
    }
}


sub grep_for_term {

    my $term = shift;

    for(my $index = 0; $index <= $#tuple_list; $index++) {

	my $curtoken = $tuple_list[ $index ][$self->keyindex];

	if($curtoken =~ /$term/i) {

	    if($tuple_list[$index][$self->selection_offset] =~ /^-?[0-9]+\.?[0-9]?$/) {
		return $tuple_list[$index][$self->selection_offset];
	    }
	} 
    }
}


1;
