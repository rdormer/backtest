#! /usr/bin/perl

$ival = 1;
$urlend = "%5E" . $ARGV[0];
$getstring = "http://finance.yahoo.com/q/cp?s=" . $urlend;
$stocktable = `wget -q -O - \"$getstring\"`;
$flag = 1;

do {

    if($stocktable =~ /($urlend)([A-Z,-]+)(&amp)/) {
	@stocks = split(/,/, $2);
	foreach $i (@stocks) {
	    print "$i\n" if length $i > 0;
	}
    }
    else {
	$flag = 0;
    }


    $url = $getstring . "&c=$ival";
    $stocktable = `wget -q -O - \"$url\"`;
    $ival++;

} while ($flag);

