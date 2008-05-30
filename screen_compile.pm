use screen_sql;
use indicators;

my @tokens = qw(AND OR NOT \+ - \* / MIN[VOHLC][\d]+ MAX[VOHLC][\d]+ AVG[VOHLC][\d]+ [VOHLC][\d]*
		MACD[S]*[\d,]+[\d] VALUE[\d,]+[\d] [MBK] ABS <= >= < > ; = [\s]*[-]?[\d]+ [(|)] ROE 
		EPS MCAP PEG FLOAT EARNINGS_GROWTH STRENGTH[\d]+ VOLATILITY[\d]+);

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

    my $actions = shift;

    my %logicals = ("AND" => "&&", "OR" => "||");
    $token = parse_condition(next_token());

    if(exists $logicals{$token}) {

	$current_action .= " $logicals{$token} ";
	$token = parse_condition(next_token());
    }


    if($token =~ /;/) {

	$current_action = "if($current_action) {return 1;} else {return 0;}";
	push @$actions, $current_action;
	$current_action = "";
    }
}

sub parse_condition {

    $token = shift;
    $token = parse_expression($token);

    if($token =~ /<|>|<=|>=/) {
	$current_action .= " $token ";
        return parse_expression(next_token());
    }

    if($token =~ /=/) {		
	$current_action .= " == ";
	return parse_expression(next_token());
    }
}

sub parse_expression {

    $token = shift;
    $token = parse_var($token);

    if($token =~ /[\+\-\*\/]/) {
	$current_action .= " $token ";
	$token = parse_expression(next_token());
    }

    return $token;
}

sub parse_var {

    $token = shift;

    my %fund_table = (
		      "EPS" => "fundamental_eps",
		      "ROE" => "fundamental_roe",
		      "MCAP" => "fundamental_mcap",
		      "FLOAT" => "fundamental_float",
		      "EARNINGS_GROWTH" => "fundamental_egrowth"
		  );

    if($fund_table{$token}) {

	add_fundamental($token);
	$current_action .= $fund_table{$token} . "()";

    } elsif($token =~ /[MAX|MIN|AVG]+[VOHLC][\d]*/ || $token =~ /STRENGTH[\d]+/ 
       || $token =~ /[VOHLC][\d]*/ || $token =~ /MACD[S][\d,]+[\d]/) 
    {
	$current_action .= expand_data_expression($token);
    
    } elsif($token =~ /[-]*[\d]+/) {

	if($token_list[0] =~ /[BMK]/) {
	    $mult = next_token();
	    $current_action .= " " . expand_alpha_expression($token, $mult) . " ";
	} else {
	    $current_action .= " $token ";
	}
    }

    return next_token();
}


sub expand_alpha_expression {

    $base = shift;
    $multiplier = shift;

    if($multiplier =~ /B/) {
	return $base * 1000000000;
    }

    if($multiplier =~ /M/) {
	return $base * 1000000;
    }

    if($multiplier =~ /K/) {
	return $base * 1000;
    }
}

sub expand_data_expression {

    my $exp = shift;

    my %table = (
	"V" => "fetch_volume_at",
	"O" => "fetch_open_at",
	"H" => "fetch_high_at",
	"L" => "fetch_low_at",
	"C" => "fetch_close_at",
	"MAXC" => "max_close",
	"MAXV" => "max_volume",
        "MAXO" => "max_open",
	"MINC" => "min_close",
        "MINV" => "min_volume",
	"AVGC" => "avg_close",
	"AVGV" => "avg_volume",
	"DAYMAXC" => "index_max_close",
        "DAYMINC" => "index_min_close",	 
	"MACD" => "compute_macd",
	"MACDS" => "compute_macd_signal"
	);


    if($exp =~ /STRENGTH([\d]+)/) {
	return "fetch_strength($1)";
    }

    if($exp =~ /VOLATILITY([\d]+)/) {
	return "fetch_volatility($1)";
    }

    if($exp =~ /(MACD[S]*)([\d,]+[\d])/) {

	set_pull_limit(args_max($2) * 2);
	return $table{$1} . "($2)";
    }

    if($exp =~ /([MAX|MIN|AVG]*[VOHLC])([\d]*)/) {

	if($2) {
	    set_pull_limit($2);
	    return $table{$1} . "($2)";
	} else {
	    return $table{$1} . "(0)";
	}
    } 
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

sub args_max {

    @t = split /,/, shift;

    $max = 0;
    foreach $val (@t) {
	$max = $val if $val > $max;
    }

    return $max;
}

1;
