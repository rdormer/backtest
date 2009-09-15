package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;


#jump table for parsers for each categroy

my %parsers = ("Earnings per share" => \&parser_eps, "Calendar dates" => \&parser_dates,
    "Total Assets" => \&parser_assets);

#an array of tokens created by secbot, and
#a hash of hashes, indexed by category of token,
#and then it's offset in the array, with the value 
#being the score returned by the bayesian recognizer

my @token_list;
my %hitmap;

$sql_hash;

sub add_token {

    my $token = shift;
    if($token =~ /\s+/c) {
	
	#delete extraneous spacing
	$token  =~ s/^\s+//;
	$token =~ s/\s+$//;
	$token =~ s/\s{2,}/ /g;
	$token =~ s/\$\s/\$/g;
	$token =~ s/\(\s+/\(/g;
	$token =~ s/\s+\)/\)/g;
	$token =~ s/://g;

	if($token =~ /.*[A-Za-z].*/) {
	    push @token_list, $token;
	} else {

	    foreach (split /\s/, $token) {
		$_ =~ s/\,//g;
		$_ =~ s/\(/-/;
		$_ =~ s/\)//;
		$_ =~ s/\$//;
		push @token_list, $_;
	    }
	}
    }
}

sub clear {
    @token_list = ();
    %hitmap = ();
}

sub add_potential_hit {

    my $cat = shift;
    my $score = shift;
    my $offset = $#token_list;

    $hitmap{$cat}->{$offset} = $score;
}


sub find_best_matches {

    foreach $category (keys %hitmap) {

	$temp = $hitmap{$category};
	if(exists $parsers{$category}) {
	    $parsers{$category}->($temp);
	}
    }
}

sub parser_dates {

    my $off = shift;
}

sub parser_assets {

    my $asslist = shift;
    my @offs = keys %$asslist;

    if(@offs eq 1) {
	$sql_hash->{total_assets} = $token_list[$offs[0] + 1];
    } elsif (@offs gt 1) {

    }
}

sub parser_eps {

    my $epstokens = shift;

    #delete tokens not matching text heuristics
    foreach my $off (keys %$epstokens) {

	if($token_list[$off] !~ /.*per.*share.*/i && $token_list[$off] !~ /.*(basic|diluted).*/i) {
	    delete $epstokens->{$off};
	    next;
	} 
    }




   
	#if($token_list[$off + 1] !~ /\$\-*[0-9]*\.[0-9]+/) {

}


1;
