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
total: 4203.08416 (return -15.9383168)
Paid out 197.21416 in dividends
QQQQ buy and hold: -1.48984198645597
208 trades
146 losing trades (avg loss -0.0684931506849316)
62 wining trades (avg win 0.270700808335217)
66.6102483683097 maximum drawdown
55 days longest drawdown
0.298076923076923 win ratio
9.74439227960354 max adverse excursion
Expectancy 0.0326127409460743
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 3479.09677 (return -30.4180646)
Paid out 129.65677 in dividends
QQQQ buy and hold: -32.0993227990971
156 trades
127 losing trades (avg loss -0.000419276663899506)
29 wining trades (avg win 0.0288675538007396)
44.8314752452837 maximum drawdown
220 days longest drawdown
0.185897435897436 win ratio
9.53281123413449 max adverse excursion
Expectancy 0.00502507002503981
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
total: 5026.75574 (return 0.535114799999992)
Paid out 2.50074 in dividends
QQQQ buy and hold: 9.42173479561316
73 trades  (discarded 2 trades)
47 losing trades (avg loss -0.0211229741147552)
26 wining trades (avg win 0.020043650616899)
4.1847511385457 maximum drawdown
39 days longest drawdown
0.356164383561644 win ratio
2.21258134490239 max adverse excursion
Expectancy -0.0064608885938921
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache

