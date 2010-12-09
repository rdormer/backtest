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
total: 5316.35691 (return 6.33%)
Paid out 49.30691 in dividends
QQQQ buy and hold: 25.95%
84 trades (22 wins / 61 losses)
Win ratio 26.19%
Average win 7.922% / 0.792 R
Average loss -4.311% / -0.431 R
Maximum drawdown 9.836%
System quality number -1.4
Ulcer Index 0.0473
Standard deviation of returns 2.213
Sharpe ratio 1.766
Recovery factor 0.644
Max adverse excursion 7.597%
Expectancy -1.1073% / -0.1106 R
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