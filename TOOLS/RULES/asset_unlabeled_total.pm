package asset_unlabeled_total;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    return if exists $self->result_hash->{total_assets};
    my @tuples = @{$self->get_tuples};

    #$off is post incremented so we don't need to go all the way to the last element
    #this is for the case where assets is not labeled, but just a bottom line total

    my $off = 0;
    while($tuples[$off][$self->keyindex] !~ /.*liabilities.*/i && $off < $#tuples) {
	$off++;
    }

    my $tuplesize = @{ $tuples[$off - 1] };
    my $assetval = $tuples[$off - 1][$tuplesize - $self->selection_offset]; #TODO <-- check this

    if($assetval =~ /[0-9]+/) {
	$self->result_hash->{total_assets} = $self->apply_multiplier($assetval);
    }
}

1;
