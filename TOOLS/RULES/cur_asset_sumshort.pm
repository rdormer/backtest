package cur_asset_sumshort;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    my $longoff = $self->forward_term_search("long term", 0, "liabilities");

    if($longoff > 0) {

	my $sum = 0;

	for(my $i = 0; $i < $longoff; $i++) {
	    if($tuples[$i][$self->selection_offset] =~ /^[0-9]+$/ &&
		$tuples[$i][$self->keyindex] !~ /property and equipment/i) {

		$fuck1 = $tuples[$i][$self->keyindex];
		$fuck2 = $tuples[$i][$self->selection_offset];

#		print "\nTRYING OUT $fuck1 $fuck2";

		$sum += $tuples[$i][$self->selection_offset];
	    }
	}
	
	if($sum > 0) {
#	    die $sum;
	    $self->result_hash->{current_assets} = $sum;
	}
    }
}



1;
