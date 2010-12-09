#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4952.48 (return -0.95%)
QQQQ buy and hold: 19.68%
2 trades (1 wins / 1 losses)
Win ratio 50.00%
Average win 3.333% / 0.333 R
Average loss -12.899% / -1.290 R
Maximum drawdown 1.306%
System quality number -0.8
Ulcer Index 0.0122
Standard deviation of returns 0.421
Sharpe ratio -3.177
Recovery factor 0.727
Max adverse excursion 0.000%
Expectancy -4.7826% / -0.4783 R
"

./backtest.pl -ticker=AACC -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=AACC -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5011.96 (return 0.24%)
QQQQ buy and hold: 1.66%
1 trades (1 wins / 0 losses)
Win ratio 100.00%
Average win 2.410% / 0.241 R
Average loss 0.000% / 0.000 R
Maximum drawdown 0.000%
System quality number 0.0
Ulcer Index 0.0000
Standard deviation of returns 0.120
Sharpe ratio -2.911
Recovery factor 
Max adverse excursion 0.000%
Expectancy 2.4096% / 0.2407 R
"

./backtest.pl -ticker=AZPN -start 2010-07-29 -finish 2010-08-04 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=AZPN -start 2010-07-29 -finish 2010-08-04 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5133.756595 (return 2.68%)
QQQQ buy and hold: 19.68%
6 trades (3 wins / 3 losses)
Win ratio 50.00%
Average win 18.304% / 1.830 R
Average loss -9.224% / -0.925 R
Maximum drawdown 2.753%
System quality number 0.6
Ulcer Index 0.0140
Standard deviation of returns 2.092
Sharpe ratio 0.886
Recovery factor 0.973
Max adverse excursion 2.377%
Expectancy 4.5402% / 0.4525 R
"

./backtest.pl -ticker=ABCB -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=ABCB -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4995.5 (return -0.09%)
QQQQ buy and hold: -2.28%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -0.909% / -0.091 R
Maximum drawdown 0.126%
System quality number 0.0
Ulcer Index 0.0009
Standard deviation of returns 0.045
Sharpe ratio -12.711
Recovery factor 0.714
Max adverse excursion 0.000%
Expectancy -0.9091% / -0.0909 R
"

./backtest.pl -ticker=ACCL -start 2009-10-29 -finish 2009-11-03 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=ACCL -start 2009-10-29 -finish 2009-11-03 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4990.31 (return -0.19%)
QQQQ buy and hold: -2.24%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -1.982% / -0.198 R
Maximum drawdown 0.194%
System quality number 0.0
Ulcer Index 0.0016
Standard deviation of returns 0.000
Sharpe ratio 0.000
Recovery factor 0.980
Max adverse excursion 0.000%
Expectancy -1.9821% / -0.1984 R
"

./backtest.pl -tickers=ABCO -start 2009-10-22 -finish 2009-10-28 -entry TESTS/binventry -exit TESTS/binvexit --skip-progress --skip-trades
./backtest.pl -tickers=ABCO -start 2009-10-22 -finish 2009-10-28 -entry TESTS/binventry -exit TESTS/binvexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5196.53 (return 3.93%)
Paid out 27.18 in dividends
QQQQ buy and hold: 7.68%
24 trades (8 wins / 16 losses)
Win ratio 33.33%
Average win 24.285% / 2.428 R
Average loss -10.001% / -1.000 R
Maximum drawdown 9.531%
System quality number 0.4
Ulcer Index 0.0315
Standard deviation of returns 2.400
Sharpe ratio -0.637
Recovery factor 0.412
Max adverse excursion 7.973%
Expectancy 1.4275% / 0.1426 R
"

./backtest.pl -tickers=ADTN list -entry TESTS/bol_dayago1 -exit TESTS/tdout -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades
./backtest.pl -tickers=ADTN list -entry TESTS/bol_dayago1 -exit TESTS/tdout -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5792.43 (return 15.85%)
QQQQ buy and hold: 7.68%
29 trades (11 wins / 18 losses)
Win ratio 37.93%
Average win 24.700% / 2.470 R
Average loss -6.668% / -0.667 R
Maximum drawdown 5.666%
System quality number 1.3
Ulcer Index 0.0189
Standard deviation of returns 5.305
Sharpe ratio 1.309
Recovery factor 2.797
Max adverse excursion 6.549%
Expectancy 5.2303% / 0.5231 R
"

./backtest.pl -tickers=AAPL list -entry TESTS/bol_dayago2 -exit TESTS/out -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades
./backtest.pl -tickers=AAPL list -entry TESTS/bol_dayago2 -exit TESTS/out -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 3397.265 (return -32.05%)
Paid out 18.46 in dividends
QQQQ buy and hold: -22.06%
256 trades (78 wins / 177 losses)
Win ratio 30.47%
Average win 8.121% / 0.812 R
Average loss -5.630% / -0.563 R
Maximum drawdown 49.736%
System quality number -2.7
Ulcer Index 0.3001
Standard deviation of returns 17.968
Sharpe ratio -1.345
Recovery factor 0.644
Max adverse excursion 9.556%
Expectancy -1.4402% / -0.1441 R
"

./backtest.pl --entry TESTS/macd_in --exit TESTS/macd_out --start 2007-11-01 --finish 2009-10-30 --list TESTS/n100.txt --skip-trades --skip-progress
./backtest.pl --entry TESTS/macd_in --exit TESTS/macd_out --start 2007-11-01 --finish 2009-10-30 --list TESTS/n100.txt --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5133.756595 (return 2.68%)
QQQQ buy and hold: -100.00%
6 trades (3 wins / 3 losses)
Win ratio 50.00%
Average win 18.304% / 1.830 R
Average loss -9.224% / -0.925 R
Maximum drawdown 2.753%
System quality number 0.6
Ulcer Index 0.0106
Standard deviation of returns 1.920
Sharpe ratio 0.441
Recovery factor 0.973
Max adverse excursion 2.377%
Expectancy 4.5402% / 0.4525 R
"

./backtest.pl --ticker=ABCB --start 2009-01-01 --finish 2010-10-01 --entry TESTS/bcontentry --exit TESTS/bcontexit --skip-trades --skip-progress
./backtest.pl --ticker=ABCB --start 2009-01-01 --finish 2010-10-01 --entry TESTS/bcontentry --exit TESTS/bcontexit --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 8862.03 (return 77.24%)
QQQQ buy and hold: -77.22%
57 trades (26 wins / 29 losses)
Win ratio 45.61%
Average win 35.139% / 3.519 R
Average loss -5.595% / -0.560 R
Maximum drawdown 8.582%
System quality number 1.9
Ulcer Index 0.0257
Standard deviation of returns 28.119
Sharpe ratio 0.828
Recovery factor 9.001
Max adverse excursion 9.600%
Expectancy 12.9855% / 1.3008 R
"

./backtest.pl --ticker=HANS --start=2000-01-01 --finish=2007-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
./backtest.pl --ticker=HANS --start=2000-01-01 --finish=2007-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache