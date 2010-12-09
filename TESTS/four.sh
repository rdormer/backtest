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
total: 4945.39454 (return -1.09%)
Paid out 43.68454 in dividends
QQQQ buy and hold: 4.56%
56 trades (15 wins / 41 losses)
Win ratio 26.79%
Average win 15.988% / 1.598 R
Average loss -6.940% / -0.694 R
Maximum drawdown 17.789%
System quality number -0.4
Ulcer Index 0.1182
Standard deviation of returns 4.610
Sharpe ratio 0.805
Recovery factor 0.061
Max adverse excursion 5.530%
Expectancy -0.7986% / -0.0798 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4898.27 (return -2.03%)
QQQQ buy and hold: -32.10%
9 trades (3 wins / 6 losses)
Win ratio 33.33%
Average win 1.741% / 0.174 R
Average loss -4.559% / -0.456 R
Maximum drawdown 2.657%
System quality number -2.3
Ulcer Index 0.0068
Standard deviation of returns 0.494
Sharpe ratio -1.282
Recovery factor 0.764
Max adverse excursion 2.264%
Expectancy -2.4588% / -0.2457 R
"

time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades
time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4540.545 (return -9.19%)
Paid out 34.56 in dividends
QQQQ buy and hold: 17.44%
145 trades (35 wins / 108 losses)
Win ratio 24.14%
Average win 22.757% / 2.282 R
Average loss -8.494% / -0.861 R
Maximum drawdown 35.665%
System quality number -0.5
Ulcer Index 0.1514
Standard deviation of returns 14.304
Sharpe ratio 0.862
Recovery factor 0.258
Max adverse excursion 8.889%
Expectancy -0.9509% / -0.1028 R
"

time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 6962.18812 (return 39.24%)
Paid out 33.89812 in dividends
QQQQ buy and hold: 17.44%
129 trades (30 wins / 98 losses)
Win ratio 23.26%
Average win 13.560% / 1.357 R
Average loss -8.488% / -0.852 R
Maximum drawdown 42.472%
System quality number -2.7
Ulcer Index 0.1935
Standard deviation of returns 12.239
Sharpe ratio -0.224
Recovery factor 0.924
Max adverse excursion 9.722%
Expectancy -3.3603% / -0.3386 R
"

time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache