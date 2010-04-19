#! /usr/bin/perl
use HTML::TreeBuilder;

$ival = 1;
$urlend = "%5E" . $ARGV[0];
$getstring = "http://finance.yahoo.com/q/cp?s=" . $urlend;
$stocktable = `wget -q -O - \"$getstring\"`;
my $count;

do {

    my $parser = HTML::TreeBuilder->new;
    $parser->parse_content($stocktable);
    $parser->elementify();
    my $ptext = extract_text($parser);

    if($ptext =~ /Symbol Name Last Trade Change Volume(.+)All \|  A  \|  B  \|  C  \|  D  \|/) {

	$count = 0;
	@stocks = split(/[0-9]+,[0-9]+/, $1);

	foreach $i (@stocks) {

	    if($i =~ /([A-Z,-]+) .*/) {
		print "\n$1";
		$count++;
	    }
	}
    }
    
    $url = $getstring . "&c=$ival";
    $stocktable = `wget -q -O - \"$url\"`;
    $ival++;

} while ($count > 0);



sub extract_text {

    my $parse_tree = shift;
    my $page_text;

    foreach my $c ($parse_tree->content_list) {
        if(!ref $c) {
            $page_text .= " $c";
        } else {
            $page_text .= extract_text($c);
        }
    }

    return $page_text;
}
