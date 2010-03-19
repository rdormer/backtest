package sharecount_last_try;
use sharecount_mod;

our @ISA = qw(sharecount_mod);


sub process_hit {

    my $self = shift;
    my $hit = shift;
    my $auth, $issued, $outstanding;

    return if $self->all_filled();

    $hit =~ s/;//g;
    $hit =~ s/,//g;

    if($hit =~ /([0-9]+) shares authorized/i ||
       $hit =~ /authorized ([0-9]+) shares/i ||
       $hit =~ /authorized shares ([0-9]+)/i) {
	$auth = $1;
    }


#    print "\n\nLAST TRY: $hit";
}

1;
