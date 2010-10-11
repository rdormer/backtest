#! /bin/sh

cd ../

echo "
total: 5000 (return 0)
QQQQ buy and hold: -0.902934537246046
"

./backtest.pl -tickers=ALLT -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress 
./backtest.pl -tickers=ALLT -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --nocache

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo " 
total: 5174.55 (return 3.491)
Paid out 1.84 in dividends
QQQQ buy and hold: -0.902934537246046
"

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 3767.8379 (return -24.6432420000001)
Paid out 188.8679 in dividends
QQQQ buy and hold: -1.48984198645597
202 trades
156 losing trades (avg loss -0.0641025641025641)
45 wining trades (avg win 0.318297207576645)
72.272552850089 maximum drawdown
71 days longest drawdown
0.222772277227723 win ratio
9.70654627539504 max adverse excursion
Expectancy 0.0210855038457746
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 2994.6255 (return -40.10749)
Paid out 113.1355 in dividends
QQQQ buy and hold: -32.0993227990971
119 trades
105 losing trades (avg loss -0.0700280112044818)
13 wining trades (avg win 0.0394073139974785)
67.6602545356712 maximum drawdown
3 days longest drawdown
0.109243697478992 win ratio
5.97701149425288 max adverse excursion
Expectancy -0.0580728916446038
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5069.15 (return 1.38299999999999)
Paid out 9.68 in dividends
QQQQ buy and hold: -0.902934537246046
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5245.20574 (return 4.90411479999999)
Paid out 13.06074 in dividends
QQQQ buy and hold: 9.42173479561316
35 trades
19 losing trades (avg loss -0.140559112915822)
15 wining trades (avg win 0.0712589073634197)
49.3336 maximum drawdown
11 days longest drawdown
0.428571428571429 win ratio
0 max adverse excursion
Expectancy -0.0497799613675753
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache

