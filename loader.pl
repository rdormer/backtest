#! /usr/bin/perl

use DBI;
use IPC::SysV;
use Date::Manip;
use Storable;

my %start_table;
my %ticker_handles;
my %seglenths;
my @holidays;

$dbh = DBI->connect("DBI:mysql:finance", "perldb");
$pull = $dbh->prepare("select date,open,high,low,close,splitadj,volume from historical where ticker=? order by date desc");
open(INFILE, $ARGV[0]);

while(<INFILE>) {

    chomp;
    $pull->execute($_);
    $data = $pull->fetchall_arrayref();

    @t = @$data;
    $start_table{$_} = $t[@t - 1][0];

    $tdata = "";
    foreach (@$data) {
	$tdata .= pack_row(@$_);
    }


    $seglengths{$_} = length $tdata;
    $ticker_handles{$_} = shmget(IPC_PRIVATE, $seglengths{$_}, IPC_CREAT | IPC_EXL | 0777 );
    die "couldn't allocate shared memory block" if $ticker_handles{$_} eq 0;
    shmwrite($ticker_handles{$_}, $tdata, 0, $seglengths{$_});
    print "\n$_";
}

holiday_list();


store \%start_table, 'sdates.svar';
store \%seglengths, 'lengths.svar';
store \%ticker_handles, 'handles.svar';
store \@holidays, 'holidays.svar';

print "\n";

sub pack_row {
    $foo = pack("A10fffffL", @_);
#    print "\n" . length $foo;
    return $foo;
}

sub holiday_list {

    $earliest = ParseDate("today");
    $tdate = UnixDate($earliest, "%Y-%m-%d");

    foreach (keys %start_table) {
	$cur = ParseDate($start_table{$_});
	$earliest = $cur if Date_Cmp($earliest, $cur) > 0;
    }

    $sdate = UnixDate($earliest, "%Y-%m-%d");

    #christmas, new year's, fourth of july
    push @t, ParseRecur("1*12:0:25:0:0:0***$sdate*$tdate");
    push @t, ParseRecur("1*7:0:4:0:0:0***$sdate*$tdate");
    push @t, ParseRecur("1*1:0:1:0:0:0***$sdate*$tdate");

    #thanksgiving, memorial day, MLK day, President's day, labor day 
    push @t, ParseRecur("1*11:4:4:0:0:0***$sdate*$tdate");
    push @t, ParseRecur("1*5:-1:1:0:0:0***$sdate*$tdate");
    push @t, ParseRecur("1*1:3:1:0:0:0***$sdate*$tdate");
    push @t, ParseRecur("1*2:3:1:0:0:0***$sdate*$tdate");
    push @t, ParseRecur("1*9:1:1:0:0:0***$sdate*$tdate");

    foreach (sort { Date_Cmp($a, $b) } @t) {
	push @holidays, UnixDate($_, "%Y%m%d");
    }
}

