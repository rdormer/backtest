#! /usr/bin/perl

use DBI;

my @months = qw(null Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my %dvals = ("Jan" => "01", "Feb" => "02", "Mar" => "03", "Apr" => "04",
	     "May" => "05", "Jun" => "06", "Jul" => "07", "Aug" => "08",
	     "Sep" => "09", "Oct" => "10", "Nov" => "11", "Dec" => "12");

my $filename = $ARGV[0];
my $startdate = unformat_date($ARGV[1]);
my $enddate = unformat_date($ARGV[2]);
my $exchange = $ARGV[3];

open(TICKERS, $filename) || die "could'nt open file $filename\n";
$dbh = DBI->connect("DBI:mysql:finance", "perldb");
$ch = $dbh->prepare("insert into historical (ticker, date, open, high, low, close, volume) values (?, ?, ?, ?, ?, ?, ?);");


foreach $ticker (<TICKERS>) {

    chomp($ticker);
    print "\n$ticker";

    my $url = "http://www.google.com/finance/historical?q=$exchange:$ticker&startdate=$startdate&enddate=$enddate&output=csv";
    my $raw = `wget -q "$url" -O -`;
    my @lines = split /\n/, $raw;

    for(my $i = 1; $i <= $#lines; $i++) {

	my @vals = split /,/, $lines[$i];
        ($date, $open, $high, $low, $close, $volume) = @vals;
	$date = format_date($date);

        $ch->execute($ticker, $date, $open, $high, $low, $close, $volume);	
    }
}


sub format_date {

    my $date = shift;
    @bits = split /-/, $date;
    return "$bits[2]-$dvals{$bits[1]}-$bits[0]";
}

sub unformat_date {

    my $date = shift;
    @bits = split /-/, $date;
    
    $mval = int($bits[0]);
    $month = $months[$mval];
    return "$month+$bits[1]\%2C+$bits[2]";
}
