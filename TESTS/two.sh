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
total: 5015.61 (return 0.312199999999975)
Paid out 1.84 in dividends
QQQQ buy and hold: -0.902934537246046
2 trades
2 losing trades (avg loss -6.77002583979328)
0 wining trades (avg win )
2.57856406637205 maximum drawdown
2 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -6.77002583979328
"

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4928.17797 (return -1.43644060000001)
Paid out 193.25797 in dividends
QQQQ buy and hold: -1.48984198645597
206 trades
142 losing trades (avg loss -0.0704225352112677)
64 wining trades (avg win 0.7301944971537)
60.2624098381914 maximum drawdown
54 days longest drawdown
0.310679611650485 win ratio
9.88120950323973 max adverse excursion
Expectancy 0.178312853484645
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 3606.25877 (return -27.8748246)
Paid out 121.79877 in dividends
QQQQ buy and hold: -32.0993227990971
137 trades
111 losing trades (avg loss -0.0114820703055996)
26 wining trades (avg win 0.387999097676517)
46.9118327896059 maximum drawdown
220 days longest drawdown
0.18978102189781 win ratio
8.98940738620098 max adverse excursion
Expectancy 0.0643318739829772
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
total: 5029.58574 (return 0.591714799999991)
Paid out 2.50074 in dividends
QQQQ buy and hold: 9.42173479561316
73 trades  (discarded 2 trades)
47 losing trades (avg loss -0.0211229741147552)
26 wining trades (avg win 0.020043650616899)
4.15935400071271 maximum drawdown
39 days longest drawdown
0.356164383561644 win ratio
2.21258134490239 max adverse excursion
Expectancy -0.0064608885938921
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache

