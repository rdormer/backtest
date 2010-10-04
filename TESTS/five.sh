#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
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
echo "
CLMT	9	2007-05-17	50.61	(open)		 

total: 4999.01 (return -0.0197999999999956)
QQQQ buy and hold: 8.17184216670558
"

./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress
./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 6663.305 (return 33.2661)
Paid out 53.635 in dividends
QQQQ buy and hold: 25.9467758444217
138 trades  (discarded 1 trades)
55 losing trades (avg loss -0.0791042959717659)
83 wining trades (avg win 0.0875608696646167)
11.4037599873891 maximum drawdown
19 days longest drawdown
0.601449275362319 win ratio
9.0956887486856 max adverse excursion
Expectancy 0.0211363471283773
"

time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades
time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
./screen.pl --screen TESTS/guppy1 --ticker=AAME --date 2010-09-16 --nocache
./screen.pl --screen TESTS/guppy2 --ticker=AAME --date 2010-09-16 --nocache

./screen.pl --screen TESTS/guppy1 --ticker=AAME --date 2010-09-16
./screen.pl --screen TESTS/guppy2 --ticker=AAME --date 2010-09-16


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "No Results! [test should terminate]"

./screen.pl -ticker=AAPL -date=2010-01-02 -screen TESTS/nosemi
