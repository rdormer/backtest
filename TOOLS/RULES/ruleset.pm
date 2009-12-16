package ruleset;

sub new {

    my @rules;
    my %ruleset = (rules => @rules);

    my $ref = \%ruleset;
    bless $ref;
    return $ref;
}

sub init {

    my $self = shift;
    my @names = @_;

    for(my $i = 0; $i <= $#names; $i++) {

	eval "use $names[$i]";
	my $newrule = {};
	bless $newrule, $names[$i];
	
	$newrule->new();
	push @{ $self->{rules} }, $newrule;
    }  
}


sub apply {

    my $self = shift;
    my @rules = @{ $self->{rules} };

    foreach $rule (@rules) {
	$rule->run();
    }
}

1;
