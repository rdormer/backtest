package sharecount_simple;
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

    if($hit =~ /issued and outstanding ([0-9]+)( shares)?/i) {
	return ($auth, $1, $1);
    }

    if($hit =~ /([0-9]+)( shares)? issued and outstanding/i) {
	return ($auth, $1, $1);
    }

    if($hit =~ /([0-9]+)( shares)? issued and ([0-9]+)( shares)? outstanding/i) {
	return ($auth, $1, $3);
    }
}

1;
