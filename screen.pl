#! /usr/bin/perl

use screen_data;
use macro_expander;
use conf;

conf::process_commandline(@ARGV);

if(conf::date()) {
    set_date(conf::date());
} else {
    set_date(`date "+%Y-%m-%d"`);
}

init_data();
@actions = parse_screen(conf::screen());
build_sweep_statement();

$tref = sub { return 0; };
@results = run_screen_loop($tref, @actions);

foreach $ticker (sort @results) {
    print "\n$ticker";
}

print "\n";



