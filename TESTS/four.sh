#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5000 (return 0.00%)
QQQQ buy and hold: 0.02%
"

./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress
./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5007.91786 (return 0.16%)
Paid out 47.22786 in dividends
QQQQ buy and hold: 4.56%
50 trades (17 wins / 33 losses)
Win ratio 34.00%
Average win 14.365% / 1.436 R
Average loss -8.141% / -0.814 R
Maximum drawdown 18.116%
System quality number -0.2
Ulcer Index 0.1235
Standard deviation of returns 5.077
Sharpe ratio 0.834
Recovery factor 0.009
Max adverse excursion 6.903%
Expectancy -0.4889% / -0.0489 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4896.4 (return -2.07%)
QQQQ buy and hold: -32.10%
9 trades (3 wins / 6 losses)
Win ratio 33.33%
Average win 1.741% / 0.174 R
Average loss -4.559% / -0.456 R
Maximum drawdown 2.695%
System quality number -2.3
Ulcer Index 0.0069
Standard deviation of returns 0.504
Sharpe ratio -1.263
Recovery factor 0.768
Max adverse excursion 2.264%
Expectancy -2.4588% / -0.2457 R
"

time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades
time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4372.786 (return -12.54%)
Paid out 35.74 in dividends
QQQQ buy and hold: 17.44%
144 trades (35 wins / 107 losses)
Win ratio 24.31%
Average win 22.907% / 2.297 R
Average loss -8.458% / -0.856 R
Maximum drawdown 39.149%
System quality number -0.4
Ulcer Index 0.1713
Standard deviation of returns 15.180
Sharpe ratio 0.731
Recovery factor 0.320
Max adverse excursion 8.889%
Expectancy -0.8350% / -0.0896 R
"

time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5888.90578 (return 17.78%)
Paid out 34.54578 in dividends
QQQQ buy and hold: 17.44%
140 trades (31 wins / 108 losses)
Win ratio 22.14%
Average win 12.852% / 1.286 R
Average loss -8.480% / -0.851 R
Maximum drawdown 40.600%
System quality number -3.3
Ulcer Index 0.2005
Standard deviation of returns 10.516
Sharpe ratio -0.478
Recovery factor 0.438
Max adverse excursion 9.722%
Expectancy -3.7567% / -0.3774 R
"

time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache