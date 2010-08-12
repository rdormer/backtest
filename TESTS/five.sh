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

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4983.12 (return -0.337599999999984)
QQQQ buy and hold: 26.4571718195641
4 trades
3 losing trades (avg loss -3.3381020505484)
1 wining trades (avg win 7.14285714285714)
1.21011228826998 maximum drawdown
1 days longest drawdown
0.25 win ratio
0 max adverse excursion
Expectancy -0.717862252197017
"

./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades
./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";

time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades
time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades --nocache