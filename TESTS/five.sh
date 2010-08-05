#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
AMMD
CAH
HSY
MCK
PPDI
"

./screen.pl -list TESTS/list7 -screen TESTS/tdsetup -date 2010-08-02
./screen.pl -list TESTS/list7 -screen TESTS/tdsetup -date 2010-08-02 -nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
AMMD
CAH
HSY
MCK
PPDI
"

./screen.pl -list TESTS/list7 -screen TESTS/tdsetup2 -date 2010-08-02
./screen.pl -list TESTS/list7 -screen TESTS/tdsetup2 -date 2010-08-02 -nocache