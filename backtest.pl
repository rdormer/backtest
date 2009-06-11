#! /usr/bin/perl

use conf;
use screen_sql;
use macro_expander;

conf::process_commandline(@ARGV);
conf::check_backtest_args();
init_sql(conf::list());

eval "use portfolios::" . conf::portfolio();
$SIG{INT} = \&salvage_interrupt;

if(conf::long_positions()) {
    @long_exit = parse_screen(conf::exit_sig());
    @long_actions = parse_screen(conf::enter_sig());
}

if(conf::short_positions()) {
    @short_exit = parse_screen(conf::short_exit_sig());
    @short_actions = parse_screen(conf::short_enter_sig());
}

init_portfolio(\@long_exit, \@short_exit);
set_date_range(conf::start(), conf::finish());
build_sweep_statement();

while(next_test_day()) {

    if(positions_available()) {
    	@longs = run_screen_loop(@long_actions) if conf::long_positions();
	@shorts = run_screen_loop(@short_actions) if conf::short_positions();
	add_positions(\@longs, \@shorts);
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
    do_initial_sweep();

    foreach $ticker (@ticker_list) {
	filter_results($ticker, @_) if pull_ticker_history($ticker);
	break if @result_list >= positions_available();
    }

    my @results = do_final_actions();
    return @results;
}
