use DBI;
use Finance::QuoteHist::Yahoo;

my $filename = $ARGV[0];
my $startdate = $ARGV[1];
my $enddate = $ARGV[2];

open INFILE, $filename || die "couldn't open $filename";
$dbh = DBI->connect("DBI:mysql:finance", "perldb");
$ch = $dbh->prepare("insert into splits (date, ticker, bef, after) value (?, ?, ?, ?)");

foreach(<INFILE>) {

    chomp;
    
    $q = new Finance::QuoteHist::Yahoo(
	symbols => [$_],
	start_date => $startdate,
	end_date => $enddate
	);


    print "\n$_" if scalar @{$q->splits()} > 0;

    foreach $row ($q->splits()) {
	($symbol, $date, $post, $pre) = @$row;
	$ch->execute($date, $symbol, $pre, $post);
    }
}

