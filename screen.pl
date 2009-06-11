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

init_sql(conf::list());
@actions = parse_screen(conf::screen());
build_sweep_statement();

@results = run_screen_loop();

foreach $ticker (sort @results) {
    print "\n$ticker";
}

print "\n";



sub run_screen_loop() {

    init_filter();
    do_initial_sweep();
    
    foreach $ticker (@ticker_list) {
	pull_ticker_history($ticker);
	filter_results($ticker, @actions);
    }

    my @results = do_final_actions();
    return @results;
}

