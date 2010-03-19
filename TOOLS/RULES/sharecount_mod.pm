package sharecount_mod;
use parse_rule;

our @ISA = qw(parse_rule);

sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};
    my $raw = $self->recombine_tuples();
    my $rhash = $self->result_hash;


    if($raw =~ /.*(common.*paid).*/i) {
	my ($authorized, $issue, $out) = $self->process_hit($1);
	print "  a $authorized i $issue o $out";
	$rhash->{shares_authorized} = $authorized if $authorized ne "";
	$rhash->{shares_outstanding} = $out if $out ne "";
	$rhash->{shares_issued} = $issue if $issue ne "";
	return;
    }

    if($raw =~ /.*(common.*retained).*/i) {
	my ($authorized, $issue, $out) = $self->process_hit($1);
	print "  a $authorized i $issue o $out";
	$rhash->{shares_authorized} = $authorized if $authorized ne "";
	$rhash->{shares_outstanding} = $out if $out ne "";
	$rhash->{shares_issued} = $issue if $issue ne "";
	return;
    }
}

sub process_hit {

}

sub all_filled {
   
    my $self = shift;
    my $rhash = $self->result_hash;

    return exists $rhash->{shares_authorized} && $rhash->{shares_authorized} ne "" &&
	exists $rhash->{shares_outstanding} && $rhash->{shares_outstanding} ne "" &&
	exists $rhash->{shares_issued} && $rhash->{shares_issued} ne "";

}

1;
