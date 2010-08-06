#! /usr/bin/sh

wget http://www.libgd.org/releases/gd-2.0.35.tar.gz
gunzip gd-2.0.35.tar.gz && tar -xvf gd-2.0.35.tar
cd gd-2.0.35
./configure
make
make install
cd ..

perl -MCPAN -e "install Date::Business"
perl -MCPAN -e "install DBI"
perl -MCPAN -e "install DBD::mysql"
perl -MCPAN -e "install GD"
perl -MCPAN -e "install Chart::Lines"
perl -MCPAN -e "install POSIX"
perl -MCPAN -e "install inline"
perl -MCPAN -e "install Finance::QuoteHist::Yahoo"

perl -MCPAN -e "install Algorithm::NaiveBayes"
perl -MCPAN -e "install AI::Categorizer"
perl -MCPAN -e "install HTML::TreeBuilder"
perl -MCPAN -e "install Getopt::Long"
perl -MCPAN -e "install Net::FTP"
perl -MCPAN -e "install WWW::Mechanize"