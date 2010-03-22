package parse_rule;

@ISA = qw/Exporter/;

our $KEYINDEX = 1;
our $CATINDEX = 0;
our @tuple_list;

my $selection_offset = 2;
my $result_hash;
my $multiplier;

sub new {

    my $self = {};
    bless $self;
    return $self;
}

#sub get_rule_result {
#    return %result_hash;
#}

sub keyindex {
    return $KEYINDEX;
}

sub catindex {
    return $CATINDEX;
}

sub selection_offset {
    return $selection_offset;
}

sub result_hash {
    return $result_hash;
}

sub set_data {

    my $self = shift;
    my $ref = shift;
    $result_hash = shift;
    $multiplier = shift;

    @tuple_list = @{ $ref };
}

sub get_tuples {

    my $self = shift;
    return \@tuple_list;
}

sub apply_multiplier {

    my $self = shift;
    my $inval = shift;
    return $inval * $multiplier;
}

#count term hits and find term hits are utilities 
#that check an array of indices into the token list
#to see if they contain search terms - not to be mistaken
#for functions that search the token list itself

sub count_term_hits {

    my $searcharr = shift;
    my $term = shift;
    my $count = 0;

    foreach(@$searcharr) {
	if($tuple_list[$_][$KEYINDEX] =~ /.*$term.*/i) {
	    $count++;
	}
    }

    return $count;
}

#does a search for a term, but only at indices specified by list argument
sub find_term {

    my $searcharr = shift;
    my $term = shift;

    foreach(@$searcharr) {
	if($tuple_list[$_][$KEYINDEX] =~ /.*$term.*/i) {
	    return $_;
	}
    }

    return 0;
}

sub forward_token_search {

    my $self = shift;
    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for(my $i = $start; $i <= $#tuple_list; $i++) {
	return $i if lc($tuple_list[$i][$KEYINDEX]) eq lc($searchval);
	last if $tuple_list[$i][$KEYINDEX] =~ /.*$endval.*/i;
    }

    return -1;
}

#does an exact match (string IS search value)
sub backward_token_search {

    my $self = shift;
    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for(my $i = $start; $i >= 0; $i--) {
	return $i if lc($tuple_list[$i][$KEYINDEX]) eq lc($searchval);
	last if $tuple_list[$i][$KEYINDEX] =~ /.*$endval.*/i;
    }

    return -1;
}


#does an approximate match (string CONTAINS search value)
sub forward_term_search {

    my $self = shift;
    my $searchval = shift;
    my $start = shift;
    my $endval = shift;

    for(my $i = $start; $i <= $#tuple_list; $i++) {
	return $i if $tuple_list[$i][$KEYINDEX] =~ /$searchval/i;
	last if $tuple_list[$i][$KEYINDEX] =~ /.*$endval.*/i;
    }

    return -1;
}


#inefficient, but sometimes necessary
sub recombine_tuples {

    my $self = shift;
    my $raw;

    foreach $tuple (@tuple_list) {

	@tup = @{$tuple};

	for($i = 1; $i <= $#tup; $i++) {
	    $raw .= "$tup[$i] ";
	}
    }

    return $raw;
}

1;
