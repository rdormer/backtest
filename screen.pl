#! /usr/bin/perl

use macro_expander;
use screen_data;
use conf;

conf::process_commandline(@ARGV);

if(conf::date()) {
    set_date(conf::date());
} else {
    set_date(`date "+%Y-%m-%d"`);
}

init_data();
@actions = parse_screen(conf::screen());

$tref = sub { return 0; };
@results = run_screen_loop($tref, @actions);

$reslist = "";

foreach $ticker (sort @results) {
    $reslist .= "\n$ticker";
}

$reslist .= "\n";
$reslist = "No Results!" if scalar @results == 0;

if(conf::cgi_handle()) {
    write_cgi($reslist);
} else {
    print $reslist;
}
