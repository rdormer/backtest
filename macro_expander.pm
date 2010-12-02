use analysis::indicators;
use analysis::candlesticks;
use analysis::fundamentals;
use analysis::demark;
use analysis::rank;

my @tokens = qw(\+ - \* / <= >= < > ; = != [0-9]+\| RANK\| AND OR NOT [()] [\d]+[\.]{0,1}[\d]* , CURRENT_RATIO MIN[VOHLC] CDL_BULL_MARUBOZU CMO
                COM_CHAN_INDEX CDL_BEAR_MARUBOZU CDL_BULL_SPINNING_TOP CDL_BEAR_SPINNING_TOP CDL_DOJI CDL_DRAGONFLY CDL_GRAVESTONE 
                OBV CDL_HAMMER CDL_HANGMAN CDL_INVERTED_HAMMER CDL_SHOOTING_STAR MAX[VOHLC] AVG[VOHLC] EMA[VOHLC] [VOHLC] ROE EPS 
                SAR EARNINGS_GROWTH STRENGTH MCAP FLOAT BOLLINGER_UPPER BOLLINGER_LOWER RSI WILLIAMS_R ATR MACDS MACDH MACD MOMENTUM 
                ROC BOP ADXR ADX ACCELERATION_UPPER ACCELERATION_LOWER ULTOSC ADXR ADX STOCH_FAST_[D|K] AROON_UP AROON_DOWN 
                AROON_OSC EFFICIENCY_RATIO TD_COMBO_BUY TD_COMBO_SELL TD_SEQUENTIAL_BUY TD_SEQUENTIAL_SELL TD_SETUP_SELL TD_SETUP_BUY 
                PPO FOR_TICKER[\s]+[A-Z]{1,5} KELTNER_LOWER KELTNER_UPPER MFI WMA[VOHLC] STD_DEV ROA REV_PERSHARE PROFIT_MARGIN
                BOOK_PERSHARE TOTAL_ASSETS CURRENT_ASSETS TOTAL_DEBT CURRENT_DEBT CASH EQUITY NET_INCOME REVENUE STRENGTH TRENDSCORE
                RWI_LOW RWI_HIGH DIVIDEND_YIELD PRICE_EARNINGS DISCOUNTED_CASH_FLOW TREND_INTENSITY PAYOUT_RATIO ULCER_INDEX RAVI
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
			"STOCH_FAST_K" => "compute_fast_stoch_k", "AROON_UP" => "compute_aroon_up", "AROON_DOWN" =>"compute_aroon_down", 
			"AROON_OSC" => "compute_aroon_osc", "EFFICIENCY_RATIO" => "compute_efficiency_ratio", "PPO" => "compute_ppo", 
			"KELTNER_UPPER" => "compute_upper_keltner", "KELTNER_LOWER" => "compute_lower_keltner", "COM_CHAN_INDEX" => "compute_cci",
			"MFI" => "compute_mfi", "CMO" => "compute_cmo", "WMAC" => "wma_close", "WMAO" => "wma_open",
			"WMAH" => "wma_high", "WMAL" => "wma_low", "WMAV" => "wma_volume", "STD_DEV" => "compute_standard_dev",
			"EPS" => "fundamental_eps", "FLOAT" => "fundamental_float", "CURRENT_RATIO" => "fundamental_current_ratio", 
			"ROE" => "fundamental_roe", "MCAP" => "fundamental_mcap", "EARNINGS_GROWTH" => "fundamental_egrowth", 
			"ROA" => "fundamental_roa", "REV_PERSHARE" => "fundamental_pershare_revenue", 
			"PROFIT_MARGIN" => "fundamental_profit_margin", "BOOK_PERSHARE" => "fundamental_pershare_book",
			"TOTAL_ASSETS" => "fundamental_total_assets", "CURRENT_ASSETS" => "fundamental_current_assets",
			"TOTAL_DEBT" => "fundamental_total_debt", "CURRENT_DEBT" => "fundamental_current_debt",
			"CASH" => "fundamental_cash", "EQUITY" => "fundamental_equity", "NET_INCOME" => "fundamental_net_income",
			"REVENUE" => "fundamental_revenue", "STRENGTH" => "relative_strength", "RWI_LOW" => "random_walk_low",
			"RWI_HIGH" => "random_walk_high", "DISCOUNTED_CASH_FLOW" => "fundamental_dcf", 
			"TREND_INTENSITY" => "compute_trend_intensity", "ULCER_INDEX" => "compute_ulcer_index", "RAVI" => "compute_ravi"
);


my %noarg_macro_table = ( "=" => "==", "OR" => "||", "AND" => "&&", "BOP" => "compute_bop()", "OBV" => "compute_obv", 
			  "TD_SEQUENTIAL_BUY" => "td_sequential_buy()", "TD_SEQUENTIAL_SELL" => "td_sequential_sell()", 
			  "TD_COMBO_BUY" => "td_combo_buy()", "TD_COMBO_SELL" => "td_combo_sell()", "TD_SETUP_BUY" => "td_buy_setup()", 
			  "TD_SETUP_SELL" => "td_sell_setup()", "CDL_BULL_MARUBOZU" => "candle_bullish_marubozu()",
			  "CDL_BEAR_MRUBOZU" => "candle_bearish_marubozu()", "CDL_BULL_SPINNING_TOP" => "candle_bullish_top()",
			  "CDL_BEAR_SPINNING_TOP" => "candle_bearish_top()", "CDL_DOJI" => "candle_doji()", 
			  "CDL_DRAGONFLY" => "candle_dragonfly()", "CDL_GRAVESTONE" => "candle_gravestone()", 
			  "CDL_HAMMER" => "candle_hammer()", "CDL_HANGMAN" => "candle_hanging_man()", 
			  "CDL_INVERTED_HAMMER" => "candle_inverted_hammer", "CDL_SHOOTING_STAR" => "candle_shooting_star()",
			  "TRENDSCORE" => "compute_trend_score()", "COPPOCK" => "compute_coppock()", 
			  "DIVIDEND_YIELD" => "fundamental_div_yield()", "PRICE_EARNINGS" => "fundamental_price_earnings()",
			  "PAYOUT_RATIO" => "fundamental_payout_ratio()"
);

my %lookback_table = ( "ACCELERATION_UPPER" => "TA_ACCBANDS", "ACCELERATION_LOWER" => "TA_ACCBANDS", 
		       "TD_COMBO_BUY" => "DEMARK", "TD_COMBO_SELL" => "DEMARK", "TD_SEQUENTIAL_BUY" => "DEMARK",
		       "TD_SEQUENTIAL_SELL" => "DEMARK", "TD_SETUP_SELL" => "DEMARK_SETUP", "TD_SETUP_BUY" => "DEMARK_SETUP",
		       "CDL_BULL_MARUBOZU" => "MARUBOZU", "CDL_BEAR_MARUBOZU" => "MARUBOZU", 
		       "CDL_BULL_SPINNING_TOP" => "TA_CDLSPINNINGTOP", "CDL_BEAR_SPINNING_TOP" => "TA_CDLSPINNINGTOP",
		       "CDL_DOJI" => "TA_CDLDOJI", "CDL_DRAGONFLY" => "TA_CDLDRAGONFLYDOJI", 
		       "CDL_GRAVESTONE" => "TA_CDLGRAVESTONEDOJI", "CDL_HAMMER" => "TA_CDLHAMMER", 
		       "CDL_HANGMAN" => "CDL_HANGINGMAN", "CDL_INVERTED_HAMMER" => "TA_CDLINVERTEDHAMMER",
		       "CDL_SHOOTING_STAR" => "TA_CDLSHOOTINGSTAR", "ULTOSC" => "TA_ULTOSC", "AROON_OSC" => "TA_AROONOSC", 
);

my %transform_table = ( "FOR_TICKER[\\s]+[A-Z]{1,5}" => \&process_for_ticker, "[0-9]+\\|" => \&process_days_ago,
    "RANK\\|" => \&process_rank);

my @token_list;
my $current_action;
my $current_limit;
my $complete_meta;
my $rank_pull;
my $rank_flag;

sub tokenize {

    my $raw_screen = "";
    my $file = shift;
    open(INFILE, $file);


    while(<INFILE>) {
	chomp;
	$raw_screen .= "$_ " if $_ !~ /#.+/;
    }

    while($raw_screen) {

	$prev = $raw_screen;

	foreach $token (@tokens) {

	    if($raw_screen =~ m/^[\s]*($token)(.*)/) {
		$raw_screen = $2;
		push @token_list, $1;
		last;
	    }

	    $raw_screen = "" if $raw_screen =~ /^[\s]+$/;
	}

	die "unrecognized token in $file" if $prev eq $raw_screen;
    }
}

sub next_token {
    return shift @token_list;
}

sub parse_screen {

    $t = screen_from_file(shift);
    return @$t;
}

#do an end run around parse_scan to return
#just the expression without the if statement

sub parse_expression {

    tokenize(shift);
    my $act = parse_statement();
    $current_action = "";
    return [$act, $current_limit];
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
    parse_statement();
    my $act = "if($current_action) {return 1} else {return 0}";
    push @$actions, [$act, $current_limit];
    $current_action = "";
}

sub parse_statement {

    $token = next_token();
    $current_limit = 1;

    while($token ne "" && $token ne ";") {

	if(exists $noarg_macro_table{$token}) {

	    $current_action .= "$noarg_macro_table{$token}";
	    if(exists $lookback_table{$token}) {
		$lcall = $lookback_table{$token} . "_Lookback()";
		set_pull(eval($lcall));
	    } else {
		lookback_custom($token, "", 0);
	    }

	} elsif(exists $arg_macro_table{$token}) {

	    $current_action .= "$arg_macro_table{$token}(";
	    capture_args($token);

	} elsif( ! probe_transform_table($token)) {
	    
	    handle_meta() if $token =~ /<|>|=|<=|>=|!=|AND|OR/;
	    $current_action .= " $token";
	} 

	$token = next_token();
    }

    handle_meta();
    return $current_action;
}

sub handle_meta {

    if($complete_meta) {
	
	if($rank_flag) {
	    $current_action .= "', $rank_pull)";
	    $rank_pull = 0;
	    $rank_flag = 0;
	    $current_limit = 0;
	} else {
	    $current_action .= "')";
	}

	$complete_meta = 0;
    }
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
	set_pull(eval($lcall) + $complete_meta);
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

    if($ctoken =~/[OHLCV]/) {
	$pullval++ if $pullval > 0;
    }

    #EMA and PPO both need similar lookback periods
    #because PPO is using EMA as it's average function

    if($ctoken =~ /EMA[VOHLC]/ && $alist =~ /([0-9]+)\)/) {
	$pullval = 4 * ($1 + 1);
    }

    if($ctoken =~ /PPO/) {

	if($alist =~ /[0-9]+,([0-9]+)\)/) {
	    $pullval = 4 * ($1 + 1);
	}
    }

    if($ctoken =~ /KELTNER/) {

	if($alist =~ /([0-9]+),.+/) {
	    $pullval = 4 * ($1 + 1);
	}
    }

    #get around bugs in ta-lib's lookback functions
    if($ctoken =~ /WILLIAMS_R/) {
	$pullval = $maxval;
    }

    if($ctoken =~ /AROON_(UP|DOWN)/) {
	$pullval = $maxval + 1;
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

    if($ctoken =~ /ATR?/ && $alist =~ /([0-9]+)\)/) {
	$pullval = $1 + 1;
    }

    if($ctoken =~ /COM_CHAN_INDEX/ && $alist =~ /([0-9]+)/) {
	$pullval = $1;
    }

    if($ctoken =~ /MFI/ && $alist =~ /([0-9]+)/) {
	$pullval = $1 + 1;
    }

    if($ctoken =~ /CMO/ && $alist =~ /([0-9]+)/) {
	$pullval = $1 + 1;
    }

    if($ctoken =~ /STD_DEV/ && $alist =~ /([0-9]+),.+/) {
	$pullval = $1 + 1;
    }

    if($ctoken =~ /RWI_LOW/ || $ctoken =~ /RWI_HIGH/) {
	$pullval = $alist + 1;
    }

    if($ctoken =~ /TREND_INTENSITY/ && $alist =~ /([0-9]+),[0-9]+/) {
	$pullval = $1;
    }

    if($ctoken =~ /RAVI/ && $alist =~ /[0-9]+,([0-9]+)/) {
	$pullval = $1;
    }

    if($ctoken =~ /DISCOUNTED_CASH_FLOW/) {
	$pullval = 1;
    }

    if($ctoken =~ /STRENGTH/ || $ctoken =~ /PAYOUT_RATIO/) {
	$pullval = 0;
    }

    if($ctoken =~ /TRENDSCORE/) {
	$pullval = 21;
    }

    set_pull($pullval + $complete_meta);
}

sub probe_transform_table {

    my $token = shift;

    foreach(keys %transform_table) {

	if($token =~ /$_/) {
	    my $fcall = $transform_table{$_};
	    $fcall->($token);
	    return 1;
	}
    }
}

sub process_for_ticker {
    my $insymbol = shift;
    if($insymbol =~ /FOR_TICKER[\s]+(.*)/) {
	$current_action .= "force_data_load('$1')";
	$current_limit = 0;
    }
}

sub process_days_ago {

    my $daycount = shift;
    if($daycount =~ /([0-9]+)\|/) {
	$current_action .= "days_ago($1, '";
	$complete_meta = $1;
    }
}

sub process_rank {

    $current_action .= "rank_by('";
    $complete_meta = 1;
    $rank_flag = 1;
}

sub set_pull {

    my $t = shift;
    $rank_pull = $t;
    $current_limit = $t if $t > $current_limit;
}

1;
