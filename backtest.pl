#! /usr/bin/perl

use conf;
use screen_sql;
use macro_expander;

conf::process_commandline(@ARGV);
conf::check_backtest_args();

eval "use portfolios::" . conf::portfolio();
$SIG{INT} = \&salvage_interrupt;

init_sql();
parse_screen(conf::enter_sig());
init_portfolio(conf::exit_sig());
do_initial_sweep(conf::list());
set_date_range(conf::start(), conf::finish());

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
	filter_results($ticker) if pull_ticker_history($ticker);
	break if @result_list >= positions_available();
    }

    my @results = do_final_actions();
    return @results;
}
