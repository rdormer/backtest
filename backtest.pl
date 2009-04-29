#! /usr/bin/perl

use conf;
use screen_sql;
use macro_expander;

conf::process_commandline(@ARGV);
conf::check_backtest_args();

eval "use portfolios::" . conf::portfolio();
$SIG{INT} = \&salvage_interrupt;

init_sql();

if(conf::long_positions()) {
    @long_exit = parse_screen(conf::exit_sig());
    @long_actions = parse_screen(conf::enter_sig());
    init_portfolio(@long_exit);
}

if(conf::short_positions()) {
    @short_exit = parse_screen(conf::short_exit_sig());
    @short_actions = parse_screen(conf::short_enter_sig());
}

set_date_range(conf::start(), conf::finish());
do_initial_sweep(conf::list());

while(next_test_day()) {

    if(positions_available()) {

	if(conf::long_positions()) {
	    @candidates = run_screen_loop(@long_actions);
	    add_positions(@candidates);
	}

	if(conf::short_positions()) {
	    @candidates = run_screen_loop(@short_actions);
	}
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
	filter_results($ticker, @_) if pull_ticker_history($ticker);
	break if @result_list >= positions_available();
    }

    my @results = do_final_actions();
    return @results;
}
