use DBI;

my $filename = $ARGV[0];
my $startdate = $ARGV[1];
my $enddate = $ARGV[2];

open INFILE, $filename || die "couldn't open $filename";
$dbh = DBI->connect("DBI:mysql:finance", "perldb");
$ch = $dbh->prepare("insert into dividends (date, ticker, divamt) value (?, ?, ?)");

foreach(<INFILE>) {

    chomp;
    $url = build_url($_);
    $rawdata = `wget -q "$url" -O -`;

    my @lines = split /\n/, $rawdata;

    for(my $i = 1; $i <= $#lines; $i++) {

	my @vals = split /,/, $lines[$i];
	($date, $amt) = @vals;
	$ch->execute($date, $_, $amt);
    }
}


sub build_url {

    my $ticker = shift;
    my @starts = split /-/, $startdate;
    my @ends = split /-/, $enddate;

    my $startmonth = $starts[0] - 1;
    my $endmonth = $ends[0] - 1;

    #assuming mm-dd-YYYY

    my $rval = "http://ichart.finance.yahoo.com/table.csv?s=$ticker" .
	"&a=$startmonth&b=$starts[1]&c=$starts[2]" .
	"&d=$endmonth&e=$ends[1]&f=$ends[2]&g=v&ignore=.csv";

    return $rval;
}
