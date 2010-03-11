package sharecount_respectively;
use parse_rule;

our @ISA = qw(parse_rule);


sub run {

    my $self = shift;
    my @tuples = @{$self->get_tuples};
    my $raw = $self->recombine_tuples();

    if($raw =~ /.*(common.*paid).*/i) {
	my ($authorized, $issue, $out) = process_hit($1);
	print "  a $authorized i $issue o $out";
	$self->result_hash->{shares_authorized} = $authorized;
	$self->result_hash->{shares_outstanding} = $out;
	$self->result_hash->{shares_issued} = $issue;
	return;
    }

    if($raw =~ /.*(common.*retained).*/i) {
	my ($authorized, $issue, $out) = process_hit($1);
	print "  a $authorized i $issue o $out";
	$self->result_hash->{shares_authorized} = $authorized;
	$self->result_hash->{shares_outstanding} = $out;
	$self->result_hash->{shares_issued} = $issue;
	return;
    }
}


sub process_hit {

    my $hit = shift;
    my $auth, $issued, $outstanding;

    if($hit =~ /[0-9]+/ && $hit =~ /respectively/i) {

	$hit =~ s/;//g;
	$hit =~ s/,//g;

	if($hit =~ /([0-9]+) shares authorized/i ||
	   $hit =~ /authorized ([0-9]+) shares/i ||
	   $hit =~ /authorized shares ([0-9]+)/i) {
	    $auth = $1;
	}

	if($hit =~ /([0-9]+)( shares)? and ([0-9]+)( shares)? issued and outstanding (at|as of|on) .+ and .+ respectively/i) {
	    $issued = $1;
	    $outstanding = $3;
	    return ($auth, $issued, $outstanding);
	}

	if($hit =~ /issued and outstanding ([0-9]+)( shares)? and ([0-9]+)( shares)? respectively/i) {
	    $issued = $1;
	    $outstanding = $3;
	    return ($auth, $issued, $outstanding);
	}

	if($hit =~ /issued and outstanding ([0-9]+)( shares)? and ([0-9]+)( shares)? (at|as of|on) .+ and .+ respectively/i) {
	    $issued = $1;
	    $outstanding = $1;
	    return ($auth, $issued, $outstanding);
	}

	if($hit =~ /([0-9]+)( shares)? and ([0-9]+)( shares)? issued respectively/i) {
	    $issued = $1;
	    return ($auth, $issued, $outstanding);
	}

	if($hit =~ /([0-9]+)( shares)? and ([0-9]+)( shares)? outstanding respectively/i) {
	    $outstanding = $1;
	    return ($auth, $issued, $outstanding);
	}

	if($hit =~ /([0-9]+)( shares)? and ([0-9]+)( shares)? issued and outstanding(..respectively)?/i) {
	    $issued = $1;
	    $outstanding = $3;
	    return ($auth, $issued, $outstanding);
	}
    }

}
1;
