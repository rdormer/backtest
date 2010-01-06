package cur_asset_sum;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    return if exists $self->result_hash->{current_assets};   
    return if ! exists $self->result_hash->{cash};

    my $sum = $self->result_hash->{cash};
    
    foreach $current (@tuples) {

	@cur = @{$current};
	my $key = $cur[$self->keyindex];
	last if $key =~ /liabilities/;
	
	if($key =~ /receivable/i ||
	   $key =~ /inventory/i  ||
	   $key =~ /prepaid/i    ||
	   $key =~ /securities/i ||
	   $key =~ /deposit/i) {

	    $sum += $cur[$self->selection_offset];
	}
    }

    if($sum > $self->result_hash->{cash}) {
	$self->result_hash->{current_assets} = $sum;
    }
}

1;
