#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4930.26 (return -1.39480000000001)
QQQQ buy and hold: 2.99727520435967
3 trades
3 losing trades (avg loss -0.177304964539002)
0 wining trades (avg win )
1.42360000000001 maximum drawdown
20 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -0.177304964539002
"

time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades
time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4914.42 (return -1.71160000000002)
QQQQ buy and hold: -1.34996931887912
6 trades
5 losing trades (avg loss -0.106382978723401)
1 wining trades (avg win 1.2486992715921)
1.8934546850507 maximum drawdown
44 days longest drawdown
0.166666666666667 win ratio
0 max adverse excursion
Expectancy 0.119464062995849
"

time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5231.14502333333 (return 4.62290046666665)
Paid out 107.68169 in dividends
QQQQ buy and hold: 18.1264108352145
46 trades
36 losing trades (avg loss -0.107557052001497)
10 wining trades (avg win 0.257741516781013)
12.551938066106 maximum drawdown
233 days longest drawdown
0.217391304347826 win ratio
8.98940738620098 max adverse excursion
Expectancy -0.028144319657473
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4763.83 (return -4.7234)
Paid out 66.15 in dividends
QQQQ buy and hold: -1.34996931887912
21 trades
20 losing trades (avg loss 0)
1 wining trades (avg win 1.2486992715921)
6.82095713204706 maximum drawdown
44 days longest drawdown
0.0476190476190476 win ratio
0 max adverse excursion
Expectancy 0.0594618700758144
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache

