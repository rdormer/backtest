package parse_rule;

@ISA = qw/Exporter/;

our $KEYINDEX = 1;
our $CATINDEX = 0;
our @tuple_list;

my $selection_offset = 2;
my $result_hash;

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

    @tuple_list = @{ $ref };
}

sub get_tuples {

    my $self = shift;
    return \@tuple_list;
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

1;
