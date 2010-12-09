#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4957.83 (return -0.84%)
QQQQ buy and hold: 3.00%
2 trades (0 wins / 2 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -4.545% / -0.454 R
Maximum drawdown 0.903%
System quality number -2.1
Ulcer Index 0.0052
Standard deviation of returns 0.322
Sharpe ratio -2.846
Recovery factor 0.930
Max adverse excursion 0.000%
Expectancy -4.5448% / -0.4544 R
"

time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades
time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4923.87 (return -1.52%)
QQQQ buy and hold: -1.35%
4 trades (0 wins / 4 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -4.032% / -0.403 R
Maximum drawdown 1.583%
System quality number -3.1
Ulcer Index 0.0091
Standard deviation of returns 0.540
Sharpe ratio -2.456
Recovery factor 0.960
Max adverse excursion 0.000%
Expectancy -4.0315% / -0.4031 R
"

time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4958.24842 (return -0.84%)
Paid out 105.14842 in dividends
QQQQ buy and hold: 18.13%
39 trades (6 wins / 33 losses)
Win ratio 15.38%
Average win 3.387% / 0.339 R
Average loss -8.343% / -0.834 R
Maximum drawdown 15.206%
System quality number -3.2
Ulcer Index 0.0976
Standard deviation of returns 3.343
Sharpe ratio -2.258
Recovery factor 0.055
Max adverse excursion 4.630%
Expectancy -6.5384% / -0.6535 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4697.11 (return -6.06%)
Paid out 66.15 in dividends
QQQQ buy and hold: -1.35%
16 trades (0 wins / 16 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -6.376% / -0.638 R
Maximum drawdown 7.657%
System quality number -6.8
Ulcer Index 0.0437
Standard deviation of returns 2.286
Sharpe ratio -1.915
Recovery factor 0.791
Max adverse excursion 0.000%
Expectancy -6.3758% / -0.6376 R
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache