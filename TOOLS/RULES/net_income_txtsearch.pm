package net_income_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuple_list = @{$self->get_tuples};
    my $sql_hash = $self->result_hash;

    for(my $index = 0; $index <= $#tuple_list; $index++) {

	my $curtoken = $tuple_list[ $index ][$self->keyindex];

	if($curtoken =~ /net income\s*\(loss\)?/i || $curtoken =~ /net earnings\s*\(loss\)?/i || 
	   $curtoken =~ /net loss$/i || $curtoken =~ /net earnings/i ||
	   $curtoken =~ /net \(loss\) income$/i || $curtoken =~ /net \(loss\)/i ||
	   $curtoken =~ /net income$/i) {

	    if($tuple_list[$index][$self->selection_offset] =~ /^-?[0-9]+\.?[0-9]?$/) {

		my $val = $tuple_list[$index][$self->selection_offset];
		$sql_hash->{net_income} = $self->apply_multiplier($val) if not exists $sql_hash->{net_income};
	    }
	} 
    }
}


1;
