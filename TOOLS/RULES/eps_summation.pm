package eps_summation;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    return if exists $self->result_hash->{diluted_eps} || exists $self->result_hash->{basic_eps};

    my $ref = shift;
    my @tuples = @{ $self->get_tuples };
    my $sum = 0;
    my $last = 0;

    for(my $index = 0; $index <= $#tuples; $index++) {
      
	my $keyval = $tuples[$index][$self->keyindex];
	my $value = $tuples[$index][$self->selection_offset];

	if($value =~ /-?[0-9]*\.[0-9]+/) {
	    $sum += $value;
	    $last = $value;
	}
    }

    if(($sum - $last) == $last && ($sum - $last) != 0) {
	$self->result_hash->{basic_eps} = $last;
	$self->result_hash->{diluted_eps} = $last;
    }
}


1;
