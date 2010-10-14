#! /usr/bin/perl

fetch_list($ARGV[0]);

sub fetch_list {

    my $exchange = shift;
    my $url = "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=$exchange&render=download";

    my $raw = `wget -q "$url" -O -`;
    my @lines = split /\n/, $raw;

    foreach (@lines) {
	my @parts = split /,/, $_;
	$parts[0] =~ s/\"//g;
	print "\n$parts[0]";
    }
}
