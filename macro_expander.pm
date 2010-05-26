use analysis::indicators;
use analysis::fundamentals;
use analysis::demark;

my @tokens = qw(\+ - \* / <= >= < > ; = != AND OR NOT [()] [\d]+[\.]{0,1}[\d]* , CURRENT_RATIO MIN[VOHLC] MAX[VOHLC] 
                AVG[VOHLC] EMA[VOHLC] [VOHLC] ROE EPS SAR EARNINGS_GROWTH STRENGTH MCAP FLOAT BOLLINGER_UPPER BOLLINGER_LOWER
                RSI WILLIAMS_R ATR MACDS MACDH MACD MOMENTUM ROC BOP ADXR ADX ACCELERATION_UPPER ACCELERATION_LOWER ULTOSC 
                ADXR ADX OBV STOCH_FAST_[D|K] AROON_UP AROON_DOWN AROON_OSC EFFICIENCY_RATIO TD_COMBO_BUY TD_COMBO_SELL
                TD_SEQUENTIAL_BUY TD_SEQUENTIAL_SELL TD_SETUP_SELL TD_SETUP_BUY
);


my %arg_macro_table = ( "V" => "fetch_volume_at", "L" => "fetch_low_at", "MAXO" => "max_open", "MAXV" => "max_volume", 
			"MAXC" => "max_close", "O" => "fetch_open_at", "MINO" => "min_open", "MINH" => "min_high", 
			"MINL" => "min_low", "MINC" => "min_close", "MINV" => "min_volume", "C" => "fetch_close_at", 
			"MAXH" => "max_high", "MAXL" => "max_low", "AVGV" => "avg_volume", "AVGO" => "avg_open", 
			"AVGH" => "avg_high", "AVGL" => "avg_low", "AVGC" => "avg_close", "H" => "fetch_high_at",
			"MACD" => "compute_macd", "STRENGTH" => "fetch_strength", "WILLIAMS_R" => "compute_williams_r",
			"BOLLINGER_UPPER" => "compute_upper_bollinger", "BOLLINGER_LOWER" => "compute_lower_bollinger",
			"RSI" => "compute_rsi", "EMAC" => "exp_avg_close", "EMAO" => "exp_avg_open", "EMAH" => "exp_avg_high",
			"EMAL" => "exp_avg_low", "EMAV" => "exp_avg_volume", "ATR" => "compute_atr", "MACD" => "compute_macd",
			"MACDS" => "compute_macd_signal", "MACDH" => "compute_macd_hist", "MOMENTUM" => "compute_momentum",
			"ROC" => "compute_roc", "OBV" => "compute_obv", "ADX" => "compute_adx", "ADXR" => "compute_adx_r",
			"ACCELERATION_UPPER" => "compute_upper_accband", "ACCELERATION_LOWER" => "compute_lower_accband",
			"SAR" => "compute_sar", "ULTOSC" => "compute_ultosc", "STOCH_FAST_D" => "compute_fast_stoch_d",
			"STOCH_FAST_K" => "compute_fast_stoch_k", "AROON_UP" => "compute_aroon_up", 
			"AROON_DOWN" =>"compute_aroon_down", "AROON_OSC" => "compute_aroon_osc", "EFFICIENCY_RATIO" => "compute_efficiency_ratio"
);


my %noarg_macro_table = ( "ROE" => "fundamental_roe()", "EPS" => "fundamental_eps()", "MCAP" => "fundamental_mcap()",     
			  "FLOAT" => "fundamental_float()", "EARNINGS_GROWTH" => "fundamental_egrowth()", "=" => "==", 
			  "OR" => "||", "AND" => "&&", "BOP" => "compute_bop()", "OBV" => "compute_obv", 
			  "CURRENT_RATIO" => "fundamental_current_ratio()", "TD_SEQUENTIAL_BUY" => "td_sequential_buy()",
			  "TD_SEQUENTIAL_SELL" => "td_sequential_sell()", "TD_COMBO_BUY" => "td_combo_buy()", 
			  "TD_COMBO_SELL" => "td_combo_sell()", "TD_SETUP_BUY" => "td_buy_setup()", 
			  "TD_SETUP_SELL" => "td_sell_setup()"
);

my %lookback_table = ( "WILLIAMS_R" => "TA_WILLR", "ATR" => "TA_ATR", "ULTOSC" => "TA_ULTOSC", 
		       "ACCELERATION_UPPER" => "TA_ACCBANDS", "ACCELERATION_LOWER" => "TA_ACCBANDS", 
		       "AROON_UP" =>"TA_AROON", "AROON_DOWN" => "TA_AROON", "AROON_OSC" => "TA_AROONOSC",
		       "TD_COMBO_BUY" => "DEMARK", "TD_COMBO_SELL" => "DEMARK", "TD_SEQUENTIAL_BUY" => "DEMARK",
		       "TD_SEQUENTIAL_SELL" => "DEMARK", "TD_SETUP_SELL" => "DEMARK_SETUP", "TD_SETUP_BUY" => "DEMARK_SETUP"
);

my @token_list;
my $current_action;
my $current_limit;

sub tokenize {

    my $raw_screen = "";
    my $file = shift;
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

	die "unrecognized token in $file" if $prev eq $raw_screen;
    }
}

sub next_token {

    my $token = shift @token_list;
    return $token;
}

sub parse_screen {

    $t = screen_from_file(shift);
    return @$t;
}


sub screen_from_file {

    tokenize(shift);
    my @rlist;
    
    while(@token_list > 0) {
	parse_scan(\@rlist);
    }

    @rlist = sort {$a->[1] <=> $b->[1]} @rlist;
    return \@rlist;
}

sub parse_scan {

    my $actions = shift;
    $token = next_token();
    $current_limit = 1;

    while($token ne ";") {

	if(exists $noarg_macro_table{$token}) {

	    $current_action .= "$noarg_macro_table{$token}";
	    if($noarg_macro_table{$token} =~ /.*fundamental.*/) {
		set_fundamentals_limit(2); 
	    } elsif(exists $lookback_table{$token}) {
		$lcall = $lookback_table{$token} . "_Lookback()";
		set_pull(eval($lcall));
	    }

	} elsif(exists $arg_macro_table{$token}) {

	    $current_action .= "$arg_macro_table{$token}(";
	    capture_args($token);

	} else {
	    $current_action .= " $token";
	}


	$token = next_token();
    }

    my $act = "if($current_action) {return 1} else {return 0}";
    push @$actions, [$act, $current_limit];
    $current_action = "";
}

sub capture_args {

    my $max = 0;
    my $count = 0;
    my $arg = next_token();
    my $arglist;

    while($arg =~ /[0-9]+(\.){0,1}[0-9]*/ || $arg eq ",") {
	
	$max = $arg if $arg > $max;

	$arglist .= "$arg";
	$count++;
	
	$arg = next_token();
    }

    $arglist .= ")" if $count > 0;
    $arglist .= "0)" if $count == 0;
    $current_action .= $arglist;

    my $ltoken = shift;
    if(exists $lookback_table{$ltoken}) {
	$lcall = $lookback_table{$ltoken} . "_Lookback($arglist";
	set_pull(eval($lcall));
    } else {
	lookback_custom($ltoken, $arglist, $max);
    }

    unshift @token_list, $arg;
}

sub lookback_custom {

    my $ctoken = shift;
    my $alist = shift;
    my $maxval = shift;

    my $pullval = $maxval;

    if($ctoken =~ /EMA[VOHLC]/ && $alist =~ /([0-9]+)\)/) {
	$pullval = 4 * ($1 + 1);
    }

    if($ctoken =~ /RSI/ && $alist =~ /([0-9]+)\)/) {
	$pullval = 4 * $1;
    }

    if($ctoken =~ /STOCH_FAST_[K|D]/ && $alist =~ /([0-9]+)\)/) {
	$pullval = eval "TA_STOCHF_Lookback($1, $1, $TA_MAType_SMA)";
    }

    if($ctoken =~ /MACD[S]*/) {
	$pullval = $maxval * 4;
    }

    if($ctoken =~ /ADX[R]?/ && $alist =~ /([0-9]+)\)/) {
	$pullval = 5 * ($1 + 1);
    }

    set_pull($pullval);
}


sub set_pull {

    my $t = shift;
    $current_limit = $t if $t > $current_limit;
}

1;
