#! /bin/sh

cd ../

echo "
total: 5000 (return 0.00%)
QQQQ buy and hold: -0.90%
"

./backtest.pl -tickers=ALLT -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress 
./backtest.pl -tickers=ALLT -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --nocache

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo " 
total: 5174.55 (return 3.49%)
Paid out 1.84 in dividends
QQQQ buy and hold: -0.90%
"

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 3916.1379 (return -21.68%)
Paid out 201.1179 in dividends
QQQQ buy and hold: -1.49%
201 trades (46 wins / 154 losses)
Win ratio 22.89%
Average win 22.145% / 2.214 R
Average loss -8.529% / -0.853 R
Maximum drawdown 59.995%
System quality number -1.2
Ulcer Index 0.3515
Standard deviation of returns 24.804
Sharpe ratio -0.060
Recovery factor 0.361
Max adverse excursion 9.707%
Expectancy -1.5094% / -0.1510 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 2994.6255 (return -40.11%)
Paid out 113.1355 in dividends
QQQQ buy and hold: -32.10%
119 trades (13 wins / 105 losses)
Win ratio 10.92%
Average win 10.307% / 1.032 R
Average loss -6.737% / -0.674 R
Maximum drawdown 49.855%
System quality number -4.8
Ulcer Index 0.1955
Standard deviation of returns 12.130
Sharpe ratio -1.169
Recovery factor 0.805
Max adverse excursion 5.977%
Expectancy -4.8752% / -0.4876 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5069.15 (return 1.38%)
Paid out 9.68 in dividends
QQQQ buy and hold: -0.90%
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5245.20574 (return 4.90%)
Paid out 13.06074 in dividends
QQQQ buy and hold: 9.42%
35 trades (15 wins / 19 losses)
Win ratio 42.86%
Average win 1.446% / 0.145 R
Average loss -3.127% / -0.313 R
Maximum drawdown 3.622%
System quality number -2.1
Ulcer Index 0.0153
Standard deviation of returns 3.186
Sharpe ratio 0.167
Recovery factor 1.353
Max adverse excursion 0.000%
Expectancy -1.1675% / -0.1168 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache