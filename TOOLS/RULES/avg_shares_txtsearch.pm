package avg_shares_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    for(my $cur = 0; $cur <= $#tuples; $cur++) {

	my $keyval = $tuples[$cur][$self->keyindex];
	my $numval = $tuples[$cur][$self->selection_offset];

	next if $keyval !~ /weighted average/i && $keyval !~ /shares/i;

	#try to find either diluted and basic in one key, or diluted or basic,
	#followed immediately by the next key with just that value

	if($numval !~ /[A-Z]/i && length $keyval < 100) {

	    if($keyval =~ /diluted/i && $keyval =~ /basic/i) {
		$self->result_hash->{avg_shares_diluted} = $numval;
		$self->result_hash->{avg_shares_basic} = $numval;
		return;
	    }

	    if($keyval =~ /diluted/i && $keyval !~ /basic/i) {

		$self->result_hash->{avg_shares_diluted} = $numval;
		if(lc($tuples[$cur + 1][$self->keyindex]) eq "basic") {
		    $self->result_hash->{avg_shares_basic} = $tuples[$cur + 1][$self->selection_offset];
		    return;
		}
	    }

	    if($keyval =~ /basic/i && $keyval !~ /diluted/i) {

		$self->result_hash->{avg_shares_basic} = $numval;
		if(lc($tuples[$cur + 1][$self->keyindex]) eq "diluted") {
		    $self->result_hash->{avg_shares_diluted} = $tuples[$cur + 1][$self->selection_offset];
		    return;
		}
	    }
	}
    }
}

1;
