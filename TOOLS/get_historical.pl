#! /usr/bin/perl

use Getopt::Long;
use DBI;

my $filename, $startdate, $enddate, $exchange, $useyahoo, $usegoogle;
my @lines;

my @months = qw(null Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my %dvals = ("Jan" => "01", "Feb" => "02", "Mar" => "03", "Apr" => "04",
	     "May" => "05", "Jun" => "06", "Jul" => "07", "Aug" => "08",
	     "Sep" => "09", "Oct" => "10", "Nov" => "11", "Dec" => "12");

GetOptions('tickerlist=s' => \$filename, 'startdate=s' => \$startdate,
	   'enddate=s' => \$enddate, 'exchange=s' => \$exchange, 
	   'yahoo' => \$useyahoo, 'google' => \$usegoogle);

if($usegoogle) {
    $startdate = unformat_date($startdate);
    $enddate = unformat_date($enddate);
}

open(TICKERS, $filename) || die "could'nt open file $filename\n";
$dbh = DBI->connect("DBI:mysql:finance", "perldb");
$ch = $dbh->prepare("insert into historical (ticker, date, open, high, low, close, volume) values (?, ?, ?, ?, ?, ?, ?);");


foreach $ticker (<TICKERS>) {

    chomp($ticker);
    print "\n$ticker";

    if($usegoogle) {
	@lines = fetch_from_google($ticker);
    } else {
	@lines = fetch_from_yahoo($ticker);
    }

    for(my $i = 1; $i <= $#lines; $i++) {

	my @vals = split /,/, $lines[$i];
        ($date, $open, $high, $low, $close, $volume) = @vals;
	$date = format_date($date);
        $ch->execute($ticker, $date, $open, $high, $low, $close, $volume);	
    }
}


sub fetch_from_google {

    my $ticker = shift;

    my $url = "http://www.google.com/finance/historical?q=$exchange:$ticker&startdate=$startdate&enddate=$enddate&output=csv";
    my $raw = `wget -q "$url" -O -`;
    my @days = split /\n/, $raw;
    return @days;
}

sub fetch_from_yahoo {

    my $ticker = shift;
    my @first = split /-/, $startdate;
    my @last = split /-/, $enddate;

    $first[0]--;
    $last[0]--;

    my $url = "http://ichart.finance.yahoo.com/table.csv?s=$ticker&a=$first[0]&b=$first[1]&c=$first[2]";
    $url .= "&g=d&d=$last[0]&e=$last[1]&f=$last[2]&ignore=.csv";

    my $raw = `wget -q "$url" -O -`;
    my @days = split /\n/, $raw;
    return @days;
}

sub format_date {

    my $date = shift;

    if($usegoogle) {
	@bits = split /-/, $date;
	return "$bits[2]-$dvals{$bits[1]}-$bits[0]";
    } else {
	return $date;
    }
}

sub unformat_date {

    my $date = shift;
    @bits = split /-/, $date;

    #assuming mm-dd-YYYY
    
    $mval = int($bits[0]);
    $month = $months[$mval];
    return "$month+$bits[1]\%2C+$bits[2]";
}
