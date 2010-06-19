#! /usr/bin/perl
use Time::HiRes qw(usleep);

if(fork() != 0) {
    exit();
}

open CMD_QUEUE, "< ./commands" or die $!;
chdir("../../");

while(1) {

    while(<CMD_QUEUE>) {

	if($_ =~ /backtest|screen/) {
	    system("$_ &");
	}
    }

    usleep(250000);
}
