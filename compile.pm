use screen_sql;
use indicators;

my @tokens = qw(AND OR NOT \+ - \* / MIN[VOHLC][\d]+ MAX[VOHLC][\d]+ AVG[VOHLC][\d]+ [VOHLC][\d]*
		MACD[S]*[\d,]+[\d] VALUE[\d,]+[\d] [MBK] ABS <= >= < > ; = [\s]*[-]?[\d]+ [(|)] ROE 
		EPS MCAP PEG FLOAT STRENGTH[\d]+ VOLATILITY[\d]+);

my @action_list = ();
my @goto_list = ();
my @parse_stack = ();


my @action_list;
my @result_list;
my $current_action;
my @token_list;

sub set_actions {

    @rval = @action_list;
    $t = shift;
    @action_list = @$t;
    return \@rval;
}

sub tokenize {

    my $raw_screen = "";
    my $file = shift;

    die "could not open $file" if (! -e  $file);
    open(INFILE, $file);


    while(<INFILE>) {
	chomp;
	$raw_screen .= "$_ ";
    }

    while($raw_screen) {
	foreach $token (@tokens) {
	    if($raw_screen =~ m/^[\s]*($token)(.*)/) {
		$raw_screen = $2;
		push @token_list, $1;

		print "\n$1";

		break;
	    }

	    $raw_screen = "" if $raw_screen =~ /^[\s]+$/;
	}
    }
}

sub next_token {

    my $token = shift @token_list;
    while($token =~ /[()]+/) {
	$current_action .= $token;
	$token = shift @token_list;
    }

    return $token;
}

sub parse_screen {

    $t = screen_from_file(shift);
    @action_list = @$t;
}


sub screen_from_file {

    tokenize(shift);
    my @rlist;
    
    while(@token_list > 0) {
	parse_scan(\@rlist);
    }

    return \@rlist;
}


sub parse_scan {



}

1;
