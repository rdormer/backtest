#! /usr/bin/perl

use screen_sql;
use screen_compile;

if($ARGV[2]) {
    set_date($ARGV[2]);
} else {
    set_date(`date "+%Y-%m-%d"`);
}

init_sql();
parse_screen($ARGV[0]);

do_initial_sweep($ARGV[1]);
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

