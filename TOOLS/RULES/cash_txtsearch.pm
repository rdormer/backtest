package cash_txtsearch;
use parse_rule;

our @ISA = qw(parse_rule);


sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};

    my $cae = $self->forward_term_search("cash and cash equivalents", 0, "liabilities");
    my $c = $self->forward_term_search("cash", 0, "liabilities");

    if($cae >= 0 && ! exists $self->result_hash->{cash}) {

	my $value = $tuples[$cae][$self->selection_offset];
	$self->result_hash->{cash} = $self->apply_multiplier($value); 

    } elsif ($c >= 0 && ! exists $self->result_hash->{cash}) {

	my $value = $tuples[$c][$self->selection_offset];
	$self->result_hash->{cash} = $self->apply_multiplier($value);

    }
}

1;
