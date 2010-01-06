package cur_debt_sum;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};
    my $sum = 0;
    my $start;

    return if exists $self->result_hash->{current_liabilities};   

    for($start = 0; $start <= $#tuples; $start++) {
	last if $tuples[$start][$self->keyindex] =~ /liabilities/i;
    }

    for(my $cur = $start; $cur <= $#tuples; $cur++) {

	my $key = $tuples[$cur][$self->keyindex];
	
	if($key =~ /payable/i) {
	    $sum += $tuples[$cur][$self->selection_offset];
	}
    }

    if($sum > 0) {
	$self->result_hash->{current_liabilities} = $sum;
    }
}

1;
