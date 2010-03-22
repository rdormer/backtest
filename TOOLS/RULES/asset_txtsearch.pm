package asset_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    my $off = $self->forward_token_search("total assets", 0, "liabilities", $ref);
    if($off < 0) {
	$off = $self->forward_token_search("total", 0, "liabilities", $ref);
    }

    if($off >= 0 && $tuples[$off][$self->selection_offset] !~ /.*[A-Z]+.*/i && 
       ! exists $self->result_hash->{total_assets}) {

	my $value = $tuples[$off][$self->selection_offset];
	$self->result_hash->{total_assets} = $self->apply_multiplier($value);

    }
}

1;
