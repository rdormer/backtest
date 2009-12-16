package cur_asset_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    my $off = $self->forward_token_search("total current assets", 0, "liabilities");
    
    if($off >= 0) {

	$value = $tuples[$off][$self->selection_offset];
	if($value !~ /.*[A-Z]+.*/i && ! exists $self->result_hash->{current_assets}) {

	    $self->result_hash->{current_assets} = $value;;
	}	
    }
}

1;
