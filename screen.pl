#! /usr/bin/perl

use screen_sql;
use macro_expander;
use conf;

conf::process_commandline(@ARGV);

if(conf::date()) {
    set_date(conf::date());
} else {
    set_date(`date "+%Y-%m-%d"`);
}

init_sql();
parse_screen(conf::screen());

do_initial_sweep(conf::list());
@results = run_screen_loop();

foreach $ticker (sort @results) {
    print "\n$ticker";
}

print "\n";



sub run_screen_loop() {

    init_filter();

    foreach $ticker (@ticker_list) {
	pull_ticker_history($ticker);
	filter_results($ticker);
    }

    my @results = do_final_actions();
    return @results;
}

