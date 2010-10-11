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
total: 4925.68 (return -1.48639999999999)
QQQQ buy and hold: 26.4571718195641
3 trades
2 losing trades (avg loss -5.0071530758226)
1 wining trades (avg win 0.909090909090901)
9.856 maximum drawdown
2 days longest drawdown
0.333333333333333 win ratio
0 max adverse excursion
Expectancy -3.0350717475181
"

./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades
./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5000 (return 0)
QQQQ buy and hold: 8.17184216670558
"

./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress
./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5316.35691 (return 6.32713819999999)
Paid out 49.30691 in dividends
QQQQ buy and hold: 25.9467758444217
84 trades
61 losing trades (avg loss -0.272997677482445)
22 wining trades (avg win 0.24150422632396)
62.9328663428756 maximum drawdown
37 days longest drawdown
0.261904761904762 win ratio
7.59713479487736 max adverse excursion
Expectancy -0.138247178866482
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