package eps_lasttry;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my $rhash = $self->result_hash;

    if(exists $rhash->{basic_eps} && ! exists $rhash->{diluted_eps}) {
	$rhash->{diluted_eps} = $rhash->{basic_eps};
    }

    if(exists $rhash->{diluted_eps} && ! exists $rhash->{basic_eps}) {
	$rhash->{basic_eps} = $rhash->{$diluted_eps};
    }
}

1;
