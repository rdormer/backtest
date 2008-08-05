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


store \%start_table, 'sdates.svar';
store \%seglengths, 'lengths.svar';
store \%ticker_handles, 'handles.svar';

print "\n";

sub pack_row {
    $foo = pack("A10fffffL", @_);
#    print "\n" . length $foo;
    return $foo;
}

sub holiday_list {


}
