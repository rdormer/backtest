package eps_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    return if exists $self->result_hash->{diluted_eps} || exists $self->result_hash->{basic_eps};
    my @tuples = @{$self->get_tuples};

    for(my $index = 0; $index <= $#tuples; $index++) {

	next if $tuples[$index][$self->catindex] ne "Earnings per share";

	my $keyval = $tuples[$index][$self->keyindex];
	my $value = $tuples[$index][$self->selection_offset];

	if($value =~ /-?[0-9]*\.[0-9]+/) {

	    if($keyval =~ /diluted/i && $keyval =~ /basic/i) {
		$self->result_hash->{diluted_eps} = $value;
		$self->result_hash->{basic_eps} = $value;
	    } elsif($keyval =~ /diluted/i && ! exists $self->result_hash->{diluted_eps}) {
		$self->result_hash->{diluted_eps} = $value;
	    } elsif($keyval =~ /basic/i && ! exists $self->result_hash->{basic_eps}) {
		$self->result_hash->{basic_eps} = $value;
	    } elsif(! exists $self->result_hash->{basic_eps} && ! exists $self->result_hash->{diluted_eps}) {
		$self->result_hash->{diluted_eps} = $value;
		$self->result_hash->{basic_eps} = $value;
	    }
	}
    }
}

1;
