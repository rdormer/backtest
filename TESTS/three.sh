#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4957.83 (return -0.843400000000001)
QQQQ buy and hold: 2.99727520435967
2 trades
2 losing trades (avg loss -0.747213779128668)
0 wining trades (avg win )
10.177 maximum drawdown
20 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -0.747213779128668
"

time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades
time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4923.87 (return -1.52260000000002)
QQQQ buy and hold: -1.34996931887912
4 trades
4 losing trades (avg loss -0.373606889564334)
0 wining trades (avg win )
1.58260000000002 maximum drawdown
44 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -0.373606889564334
"

time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4958.24842 (return -0.835031599999984)
Paid out 105.14842 in dividends
QQQQ buy and hold: 18.1264108352145
39 trades
33 losing trades (avg loss -0.302755071147442)
6 wining trades (avg win 0.0370851103282024)
15.2064706180522 maximum drawdown
3 days longest drawdown
0.153846153846154 win ratio
4.62962962962963 max adverse excursion
Expectancy -0.250471966305035
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4697.11 (return -6.05780000000003)
Paid out 66.15 in dividends
QQQQ buy and hold: -1.34996931887912
16 trades
16 losing trades (avg loss -0.256782945736435)
0 wining trades (avg win )
7.65700000000002 maximum drawdown
44 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -0.256782945736435
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache

