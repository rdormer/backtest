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
total: 3406.73368 (return -31.87%)
Paid out 195.10368 in dividends
QQQQ buy and hold: -1.49%
210 trades (47 wins / 163 losses)
Win ratio 22.38%
Average win 23.425% / 2.342 R
Average loss -9.309% / -0.931 R
Maximum drawdown 59.022%
System quality number -1.5
Ulcer Index 0.3527
Standard deviation of returns 23.761
Sharpe ratio -0.182
Recovery factor 0.540
Max adverse excursion 9.707%
Expectancy -1.9828% / -0.1984 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 2693.52393 (return -46.13%)
Paid out 116.49393 in dividends
QQQQ buy and hold: -32.10%
153 trades (18 wins / 132 losses)
Win ratio 11.76%
Average win 8.689% / 0.870 R
Average loss -7.155% / -0.715 R
Maximum drawdown 52.170%
System quality number -6.5
Ulcer Index 0.2127
Standard deviation of returns 13.377
Sharpe ratio -1.155
Recovery factor 0.884
Max adverse excursion 5.977%
Expectancy -5.2907% / -0.5290 R
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
total: 5244.75574 (return 4.90%)
Paid out 13.06074 in dividends
QQQQ buy and hold: 9.42%
37 trades (16 wins / 20 losses)
Win ratio 43.24%
Average win 1.476% / 0.148 R
Average loss -3.055% / -0.306 R
Maximum drawdown 3.551%
System quality number -2.1
Ulcer Index 0.0149
Standard deviation of returns 3.168
Sharpe ratio 0.168
Recovery factor 1.380
Max adverse excursion 0.000%
Expectancy -1.0960% / -0.1097 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache