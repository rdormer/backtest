#! /usr/bin/perl

use WWW::Mechanize;
use DBI;

$dbh = DBI->connect("DBI:mysql:finance", "perldb");
$ch = $dbh->prepare("insert into cikmap (ticker, cik) values (?, ?)");
open INFILE, $ARGV[0];

foreach(<INFILE>) {

    chomp;
    print "\n$_";
    my $res = enter_form($_);
    scrape_form($res, $_);
}


sub enter_form {

    my $entryval = shift;
    
    my $bot = WWW::Mechanize->new();

    $bot->get("http://www.sec.gov/edgar/searchedgar/companysearch.html") or die "couldn't fetch form";

    $bot->form_number(1);
    $bot->field("CIK", $entryval);
    return $bot->click_button(name => "Find");
}

sub scrape_form {

    my $pagedata = shift;
    my $ticker = shift;

    die "got no response" if not $pagedata;

    if($pagedata->content =~ /.*>([0-9]{10}) \(see all company filings\).*/) {
	print "  $1";
	$ch->execute($ticker, $1);
    }
}
