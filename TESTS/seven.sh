#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 3988.17 (return -20.24%)
Paid out 2.07 in dividends
QQQQ buy and hold: -28.40%
348 trades (58 wins / 207 losses)
Win ratio 16.67%
Average win 14.456% / 1.449 R
Average loss -5.255% / -0.529 R
Maximum drawdown 33.210%
System quality number -3.9
Ulcer Index 0.1487
Standard deviation of returns 8.716
Sharpe ratio -0.262
Recovery factor 0.609
Max adverse excursion 9.639%
Expectancy -1.9694% / -0.1991 R
"

time ./backtest.pl -start 2008-03-15 -finish 2009-03-19 -list TESTS/short-t.txt -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress
time ./backtest.pl -start 2008-03-15 -finish 2009-03-19 -list TESTS/short-t.txt -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4979 (return -0.42%)
QQQQ buy and hold: 14.39%
4 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -2.074% / -0.209 R
Maximum drawdown 0.420%
System quality number -4.6
Ulcer Index 0.0012
Standard deviation of returns 0.000
Sharpe ratio 0.000
Recovery factor 1.000
Max adverse excursion 0.000%
Expectancy -2.0741% / -0.2090 R
"

./backtest.pl -start 2008-03-31 -finish 2008-06-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress --skip-trades
./backtest.pl -start 2008-03-31 -finish 2008-06-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4946 (return -1.08%)
QQQQ buy and hold: 5.49%
11 trades (1 wins / 4 losses)
Win ratio 9.09%
Average win 1.344% / 0.135 R
Average loss -3.060% / -0.306 R
Maximum drawdown 1.775%
System quality number -5.2
Ulcer Index 0.0109
Standard deviation of returns 0.514
Sharpe ratio -2.014
Recovery factor 0.608
Max adverse excursion 0.192%
Expectancy -2.6594% / -0.2660 R
"

./backtest.pl -start 2008-03-31 -finish 2008-09-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -trail TESTS/550138 --skip-progress --skip-trades
./backtest.pl -start 2008-03-31 -finish 2008-09-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -trail TESTS/550138 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 4976.96 (return -0.46%)
QQQQ buy and hold: 5.40%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -4.624% / -0.462 R
Maximum drawdown 0.461%
System quality number 0.0
Ulcer Index 0.0037
Standard deviation of returns 0.000
Sharpe ratio 0.000
Recovery factor 0.998
Max adverse excursion 0.000%
Expectancy -4.6243% / -0.4615 R
"

./backtest.pl -start 2008-03-15 -finish 2008-04-01 -tickers ABVA -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress
./backtest.pl -start 2008-03-15 -finish 2008-04-01 -tickers ABVA -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 5000 (return 0.00%)
QQQQ buy and hold: -100.00%
"

./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1998-07-06 -finish 2000-02-04 -entry TESTS/361437 -exit TESTS/604929 -filter TESTS/811740 -trail TESTS/671281 --skip-progress
./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1998-07-06 -finish 2000-02-04 -entry TESTS/361437 -exit TESTS/604929 -filter TESTS/811740 -trail TESTS/671281 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 19447.245 (return 288.94%)
Margin calls: 17915.4231333333
QQQQ buy and hold: -100.00%
863 trades (201 wins / 422 losses)
Win ratio 23.29%
Average win 9.137% / 0.922 R
Average loss -7.388% / -0.736 R
Maximum drawdown 95.029%
System quality number -12.9
Ulcer Index 0.7059
Standard deviation of returns 131.780
Sharpe ratio 0.745
Recovery factor 3.041
Max adverse excursion 0.000%
Expectancy -3.5392% / -0.3555 R
"

./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1991-10-01 -finish 1996-11-15 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades
./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1991-10-01 -finish 1996-11-15 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
FISI
"

./screen.pl -nocache -tickers FISI,WMG -screen TESTS/425803 -date 2011-02-01
./screen.pl -nocache -tickers FISI,WMG -screen TESTS/746722 -date 2011-02-01

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 5381.7 (return 7.63%)
QQQQ buy and hold: -100.00%
43 trades (12 wins / 21 losses)
Win ratio 27.91%
Average win 20.946% / 2.090 R
Average loss -9.147% / -0.901 R
Maximum drawdown 9.077%
System quality number -0.2
Ulcer Index 0.0217
Standard deviation of returns 3.377
Sharpe ratio 0.326
Recovery factor 0.841
Max adverse excursion 0.000%
Expectancy -0.7488% / -0.0665 R 
"

./backtest.pl -skip-progress -tickers TDSC -start 1991-12-12 -finish 1994-03-21 -entry TESTS/867213 -exit TESTS/190780 -trail TESTS/213106 --skip-trades
./backtest.pl -skip-progress -tickers TDSC -start 1991-12-12 -finish 1994-03-21 -entry TESTS/867213 -exit TESTS/190780 -trail TESTS/213106 --skip-trades --nocache