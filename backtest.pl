#! /usr/bin/perl

use conf;
use screen_data;
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

$tref = sub { return @result_list >= positions_available(); };

while(next_test_day()) {

    if(positions_available()) {
    	@longs = run_screen_loop($tref, @long_actions) if conf::long_positions();
	@shorts = run_screen_loop($tref, @short_actions) if conf::short_positions();
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
