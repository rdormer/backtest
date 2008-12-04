use screen_sql;
use indicators;

my @tokens = qw(\+ - \* / <= >= < > ; = != AND OR NOT [()] [\d]+[\.]{0,1}[\d]* , MIN[VOHLC] MAX[VOHLC] AVG[VOHLC] EMA[VOHLC] [VOHLC]
                ROE EPS MACD SAR EARNINGS_GROWTH STRENGTH MCAP FLOAT BOLLINGER_UPPER BOLLINGER_LOWER RSI WILLIAMS_R );


my %arg_macro_table = ( "V" => "fetch_volume_at", "L" => "fetch_low_at", "MAXO" => "max_open", "MAXV" => "max_volume", 
			"MAXC" => "max_close", "O" => "fetch_open_at", "MINO" => "min_open", "MINH" => "min_high", 
			"MINL" => "min_low", "MINC" => "min_close", "MINV" => "min_volume", "C" => "fetch_close_at", 
			"MAXH" => "max_high", "MAXL" => "max_low", "AVGV" => "avg_volume", "AVGO" => "avg_open", 
			"AVGH" => "avg_high", "AVGL" => "avg_low", "AVGC" => "avg_close", "H" => "fetch_high_at",
			"MACD" => "compute_macd", "STRENGTH" => "fetch_strength"
);


my %noarg_macro_table = ( "ROE" => "fundamental_roe()", "EPS" => "fundamental_eps()", "MCAP" => "fundamental_mcap()",     
		    "FLOAT" => "fundamental_float()", "EARNINGS_GROWTH" => "fundamental_egrowth()", "=" => "==", "OR" => "||", "AND" => "&&",
);

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

	$prev = $raw_screen;

	foreach $token (@tokens) {
	    if($raw_screen =~ m/^[\s]*($token)(.*)/) {
		$raw_screen = $2;
		push @token_list, $1;
		break;
	    }

	    $raw_screen = "" if $raw_screen =~ /^[\s]+$/;
	}

	die "unrecognized token" if $prev eq $raw_screen;
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

    my $actions = shift;
    $token = next_token();

    while($token ne ";") {

	if(exists $noarg_macro_table{$token}) {
	    $current_action .= "$noarg_macro_table{$token}";
	    add_fundamental($token);
	} elsif(exists $arg_macro_table{$token}) {
	    $current_action .= "$arg_macro_table{$token}(";
	    capture_args();
	} else {
	    $current_action .= " $token";
	}


	$token = next_token();
    }

    $current_action = "if($current_action) {return 1;} else {return 0;}";
    push @$actions, $current_action;
    $current_action = "";
}

sub capture_args {

    my $max = 0;
    my $count = 0;
    my $arg = next_token();


    while($arg =~ /[0-9]+(\.){0,1}[0-9]*/ || $arg eq ",") {
	
	$max = $arg if $arg > $max;

	$current_action .= "$arg";
	$count++;
	
	$arg = next_token();
    }

    set_pull_limit($max);

    $current_action .= ")" if $count > 0;
    $current_action .= "0)" if $count == 0;

    unshift @token_list, $arg;
}

sub init_filter {
    @result_list = ();
}

sub filter_results {

    foreach $action (@action_list) {
	return if not eval($action);
    }

    push @result_list, shift;
}

sub do_final_actions {
    
    return @result_list;
}


1;