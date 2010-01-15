package avg_shares_simple;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    return if exists $self->result_hash->{avg_shares_basic} || 
	exists $self->result_hash->{avg_shares_diluted};

    for(my $cur = 0; $cur <= $#tuples; $cur++) {

	my $keyval = $tuples[$cur][$self->keyindex];
	my $numval = $tuples[$cur][$self->selection_offset];

	next if $keyval !~ /weighted average/i && $keyval !~ /shares/i;

	if($numval !~ /[A-Z]/i && length $keyval < 100) {
	    $self->result_hash->{avg_shares_diluted} = $numval;
	    $self->result_hash->{avg_shares_basic} = $numval;
	    return;
	}
    }
}

1;
