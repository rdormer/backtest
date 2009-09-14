package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;


#jump table for parsers for each categroy

my %parsers = ("Earnings per share" => \&parser_eps);

#an array of tokens created by secbot, and
#a hash of hashes, indexed by category of token,
#and then it's offset in the array, with the value 
#being the score returned by the bayesian recognizer

my @token_list;
my %hitmap;

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

	if($token =~ /.*[A-Za-z].*/) {
	    push @token_list, $token;
	} else {

	    foreach (split /\s/, $token) {
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
	foreach $offset (keys %$temp) {
	    if(exists $parsers{$category}) {
		$parsers{$category}->($offset);
	    }
	}
    }
}

sub parser_eps {

    my $off = shift;

    
#    print "\n$token_list[$off]  ----$token_list[$off + 1]-----   $token_list[$off + 2]";


}


1;
