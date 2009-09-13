package heuristics;

require Exporter;
use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;
$VERSION = 1.0;


#an array of tokens created by secbot, and
#a hash of hashes, indexed by category of token,
#and then it's offset in the array, with the value 
#being the score returned by the bayesian recognizer

my @token_list;
my %hitmap;


sub add_potential_hit {

    my $cat = shift;
    my $score = shift;
    my $offset = shift;

    $hitmap{$cat}->{$offset} = $score;
#    print "\nadded $cat at $offset with score $score";
}


sub find_best_matches {

    foreach $category (keys %hitmap) {

	$temp = $hitmap{$category};
	foreach $offset (keys %$temp) {


	}
    }
}


1;
