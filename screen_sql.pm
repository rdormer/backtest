use DBI;
use conf;

my $dbh;

my $history_table = "historical";
my $fundamental_table = "fundamentals";

$pull_cmd = "select ticker,date,open,high,low,close,volume from $history_table where ticker=? and date <= ? order by date desc limit ?";
$cache_cmd = "select ticker,date,open,high,low,close,volume from $history_table where ticker=? and date >= ? and date <= ? order by date desc";
$fundamental_cmd = "select * from $fundamental_table where ticker=? and date <= ? order by date desc limit 1";
$div_cmd = "select ticker,date,divamt from dividends where ticker=? and date >= ? and date <= ?";


sub init_mod {    

    $dbh = DBI->connect(conf::connect_string(), conf::connect_user() );

}

sub pull_history_by_limit {
    
    my $ticker = shift;
    my $date = shift;
    my $limit = shift;

    my $pull_sql = $dbh->prepare($pull_cmd);
    $pull_sql->execute($ticker, $date, $limit);
    return $pull_sql->fetchall_arrayref();
}

sub pull_history_by_dates {

    my $ticker = shift;
    my $sdate = shift;
    my $edate = shift;

    my $pull_sql = $dbh->prepare($cache_cmd);
    $pull_sql->execute($ticker, $sdate, $edate);
    return $pull_sql->fetchall_arrayref();
}

sub pull_dividends {

    my $ticker = shift;
    my $startdate = shift;
    my $enddate = shift;

    $div_sql = $dbh->prepare($div_cmd);
    $div_sql->execute($ticker, $startdate, $enddate);
    return $div_sql->fetchall_hashref('date');    
}

sub pull_splits {

    my $ticker = shift;
    my $start = shift;
    my $end = shift;

    $split_sql = $dbh->prepare("select date,bef,after from splits where ticker=? and date >= ? and date <= ?");
    $split_sql->execute($ticker, $start, $end);
    return $split_sql->fetchall_arrayref();
}

1;
