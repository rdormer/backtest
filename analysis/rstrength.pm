#! /usr/bin/perl

use DBI;
use screen_sql;

%rstrength;

$dbh = DBI->connect("DBI:mysql:finance", "perldb");

my $start_date;

sub relative_strength {

    $sdate = get_date();
    my $ticker = shift;
    my $count = shift;

    if($sdate ne $start_date) {
	generate_strength_table($count, $sdate);
	$start_date = $sdate;
    }

    return $rstrength{$ticker};
}

sub generate_strength_table {

    sub scomp {
	$rstrength{$a} <=> $rstrength{$b};
    }

    my $numdays = shift;
    my $atdate = shift;
    my $first = calculate_trading_date($atdate, $numdays);

    %rstrength = ();

    foreach (ticker_list()) {
	$dif = fetch_price_diff($_, $first, $atdate); 
	$rstrength{$_} = $dif;
    }


    my $i = 0;
    my $total = scalar keys %rstrength;
    foreach $k (sort scomp (keys (%rstrength))) {
	$i++;
	$rstrength{$k} = ($i / $total) * 100;
    }
}


sub calculate_trading_date {

    my $startdate = shift;
    my $numback = shift;

    $pull = "select date from historical where ticker='AAPL' and date <= '$startdate' order by date desc limit $numback";
    $check = $dbh->selectall_arrayref($pull);


    @t = @$check[$numback - 1];
    return $t[0][0];
}

sub fetch_price_diff {

    my $ticker = shift;
    my $d1 = shift;
    my $d2 = shift;
    my $val = 0;

    $sth = $dbh->prepare("select close from historical where ticker=? and date=?");
   
    $sth->execute($ticker, $d1);
    @t1 = $sth->fetchrow_array();

    $sth->execute($ticker, $d2);
    @t2 = $sth->fetchrow_array();

    if(@t1[0] != 0) {
	$val = ($t2[0] - $t1[0]) / $t1[0];
    }

    return $val;
}

1;
