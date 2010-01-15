package avg_shares_extend;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    return if exists $self->result_hash->{avg_shares_basic} && 
	exists $self->result_hash->{avg_shares_diluted};

    for(my $cur = 0; $cur <= $#tuples; $cur++) {

	my $keyval = $tuples[$cur][$self->keyindex];
	my $numval = $tuples[$cur][$self->selection_offset];

	next if $keyval !~ /weighted average/i && $keyval !~ /shares/i;

	#look to the next tuple and see if it's basic or diluted - if 
	#quantities are located there

	if(length $keyval < 100) {

	    if($tuples[$cur + 1][$self->keyindex] =~ /basic/i &&
	       $tuples[$cur + 1][$self->keyindex] =~ /diluted/i) {

		$self->result_hash->{avg_shares_basic} = $tuples[$cur + 1][$self->selection_offset];
		$self->result_hash->{avg_shares_diluted} = $tuples[$cur + 1][$self->selection_offset];
		return;
	    }

	    if(lc($tuples[$cur + 1][$self->keyindex]) eq 'basic') {
		$self->result_hash->{avg_shares_basic} = $tuples[$cur + 1][$self->selection_offset];
	    } elsif (lc($tuples[$cur + 1][$self->keyindex]) eq 'diluted') {
		$self->result_hash->{avg_shares_diluted} = $tuples[$cur + 1][$self->selection_offset];
	    }


	    if(lc($tuples[$cur + 2][$self->keyindex]) eq 'basic') {
		$self->result_hash->{avg_shares_basic} = $tuples[$cur + 2][$self->selection_offset];
	    } elsif (lc($tuples[$cur + 2][$self->keyindex]) eq 'diluted') {
		$self->result_hash->{avg_shares_diluted} = $tuples[$cur + 2][$self->selection_offset];
	    }
	}
    }
}

1;
