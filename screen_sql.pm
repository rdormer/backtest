use DBI;
use conf;

my $dbh;

my $history_table = "historical";
my $fundamental_table = "fundamentals";

my $pull_cmd = "select ticker,date,open,high,low,close,volume from $history_table where ticker=? and date <= ? order by date desc limit ?";
my $cache_cmd = "select ticker,date,open,high,low,close,volume from $history_table where ticker=? and date >= ? and date <= ? order by date desc";
my $fundamental_cmd = "select * from $fundamental_table where ticker=? and date <= ? order by date desc limit 1";
my $div_cmd = "select ticker,date,divamt from dividends where ticker=? and date >= ? and date <= ?";
my $split_cmd = "select date,bef,after from splits where ticker=? and date >= ? and date <= ?";
my $ondate_cmd = "select close from historical where ticker=? and date=?";

my $pull_sql, $cache_sql, $split_sql, $div_sql, $date_cmd;

sub init_mod {    

    $dbh = DBI->connect(conf::connect_string(), conf::connect_user() );

    $cache_sql = $dbh->prepare($cache_cmd);
    $split_sql = $dbh->prepare($split_cmd);
    $date_cmd = $dbh->prepare($ondate_cmd);
    $pull_sql = $dbh->prepare($pull_cmd);
    $div_sql = $dbh->prepare($div_cmd);
}

sub pull_history_by_limit {
    
    my $ticker = shift;
    my $date = shift;
    my $limit = shift;

    $pull_sql->execute($ticker, $date, $limit);
    return $pull_sql->fetchall_arrayref();
}

sub pull_history_by_dates {

    my $ticker = shift;
    my $sdate = shift;
    my $edate = shift;

    $cache_sql->execute($ticker, $sdate, $edate);
    return $cache_sql->fetchall_arrayref();
}

sub pull_close_on_date {

    my $ticker = shift;
    my @closes;

    foreach $day (@_) {
	$date_cmd->execute($ticker, $day);
	my @t = $date_cmd->fetchrow_array();
	push @closes, $t[0];
    }

    return @closes;
}

sub pull_dividends {

    my $ticker = shift;
    my $startdate = shift;
    my $enddate = shift;

    $div_sql->execute($ticker, $startdate, $enddate);
    return $div_sql->fetchall_hashref('date');    
}

sub pull_splits {

    my $ticker = shift;
    my $start = shift;
    my $end = shift;

    $split_sql->execute($ticker, $start, $end);
    return $split_sql->fetchall_arrayref();
}

1;
