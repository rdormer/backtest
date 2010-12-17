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
total: 4925.68 (return -1.49%)
QQQQ buy and hold: 26.46%
3 trades (1 wins / 2 losses)
Win ratio 33.33%
Average win 0.909% / 0.091 R
Average loss -8.307% / -0.831 R
Maximum drawdown 1.609%
System quality number -2.0
Ulcer Index 0.0157
Standard deviation of returns 0.427
Sharpe ratio -4.500
Recovery factor 0.926
Max adverse excursion 0.000%
Expectancy -5.2347% / -0.5234 R
"

./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades
./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5000 (return 0.00%)
QQQQ buy and hold: 8.17%
"

./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress
./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4952.33237 (return -0.95%)
Paid out 50.86237 in dividends
QQQQ buy and hold: 25.95%
81 trades (22 wins / 58 losses)
Win ratio 27.16%
Average win 8.070% / 0.807 R
Average loss -4.914% / -0.491 R
Maximum drawdown 13.064%
System quality number -1.6
Ulcer Index 0.0463
Standard deviation of returns 2.449
Sharpe ratio 1.213
Recovery factor 0.073
Max adverse excursion 7.597%
Expectancy -1.3876% / -0.1385 R
"

time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades
time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "Expecting:
AAME

AAME

AAME

AAME

got: "

./screen.pl --screen TESTS/guppy1 --ticker=AAME --date 2010-09-16 --nocache
./screen.pl --screen TESTS/guppy2 --ticker=AAME --date 2010-09-16 --nocache

./screen.pl --screen TESTS/guppy1 --ticker=AAME --date 2010-09-16
./screen.pl --screen TESTS/guppy2 --ticker=AAME --date 2010-09-16


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "No Results! [test should terminate]"

./screen.pl -ticker=AAPL -date=2010-01-02 -screen TESTS/nosemi