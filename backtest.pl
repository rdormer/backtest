#! /usr/bin/perl

use conf;
use screen_data;
use macro_expander;

conf::process_commandline(@ARGV);
conf::check_backtest_args();
init_data();

eval "use portfolios::" . conf::portfolio();
$SIG{INT} = \&salvage_interrupt;

@slippage = parse_expression(conf::slippage()) if conf::slippage();

if(conf::long_positions()) {
    @long_exit = parse_screen(conf::exit_sig());
    @long_actions = parse_screen(conf::enter_sig());
    @long_stop = parse_expression(conf::long_stop());
    @long_trail = parse_expression(conf::long_trail()) if conf::long_trail();
    @long_filter = parse_screen(conf::long_filter()) if conf::long_filter();
    check_runtime_errors(\@long_actions, \@long_exit, \@long_stop, \@long_trail, \@long_filter);
    init_long_portfolio(\@long_exit, \@long_stop, \@long_trail, \@slippage);
}

if(conf::short_positions()) {
    @short_exit = parse_screen(conf::short_exit_sig());
    @short_actions = parse_screen(conf::short_enter_sig());
    @short_stop = parse_expression(conf::short_stop());
    @short_trail = parse_expression(conf::short_trail()) if conf::short_trail();
    @short_filter = parse_screen(conf::short_filter()) if conf::short_filter();
    check_runtime_errors(\@short_actions, \@short_exit, \@short_stop, \@short_trail, \@short_filter);
    init_short_portfolio(\@short_exit, \@short_stop, \@short_trail, \@slippage);
}

$tref = sub { return $_[0] >= positions_available(); };

while(next_test_day()) {

    if(positions_available()) {
    	@longs = run_screen_loop($tref, \@long_actions, \@long_filter) if conf::long_positions();
	@shorts = run_screen_loop($tref, \@short_actions, \@short_filter) if conf::short_positions();
	add_positions(\@longs, \@shorts);
    }

    update_positions();
}

print_portfolio_state();
print "\n";

sub salvage_interrupt {
    print_portfolio_state();
    print "\n";
    exit();
}
