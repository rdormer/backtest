#! /usr/bin/perl

use screen_sql;
use screen_compile;

$modname = "portfolio";
$modname = $ARGV[5] if $ARGV[5];
eval "use portfolios::$modname";

$SIG{INT} = \&salvage_interrupt;

init_sql();
parse_screen($ARGV[0]);
init_portfolio($ARGV[1]);
do_initial_sweep($ARGV[2]);
set_date_range($ARGV[3], $ARGV[4]);

while(next_test_day()) {

    if(positions_available()) {

	@candidates = run_screen_loop();
	add_positions(@candidates);
    }

    update_positions();
}

print_portfolio_state();


sub salvage_interrupt {
    print_portfolio_state();
    print "\n";
    exit();
}


sub run_screen_loop() {

    init_filter();

    foreach $ticker (@ticker_list) {
	pull_ticker_history($ticker);
	filter_results($ticker);
	break if @result_list >= positions_available();
    }

    my @results = do_final_actions();
    return @results;
}
