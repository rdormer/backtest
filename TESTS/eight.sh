#! /bin/sh

cd ../

echo "No Results"
./screen.pl --tickers AIG,CDE,FNSR --screen TESTS/six --date 2009-10-01

echo "
+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "No Results"

./screen.pl -date 2011-05-12 --tickers SPEX -screen TESTS/six


echo "
+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4503.14428571429 (return -9.94%)
Paid out 22.86 in dividends
QQQQ buy and hold: -19.70%
274 trades (136 wins / 122 losses)
Win ratio 49.64%
Average win 6.131% / 0.616 R
Average loss -7.639% / -0.764 R
Maximum drawdown 19.972%
System quality number -1.6
Ulcer Index 0.1038
Standard deviation of returns 5.604
Sharpe ratio -1.749
Recovery factor 0.498
Max adverse excursion 9.610%
Expectancy -0.8044% / -0.0792 R
"

./backtest.pl -start 2008-03-15 -finish 2009-04-20 -list TESTS/short-t.txt -entry TESTS/noleadingzero -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress
./backtest.pl -start 2008-03-15 -finish 2009-04-20 -list TESTS/short-t.txt -entry TESTS/noleadingzero -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4838.1525 (return -3.24%)
QQQQ buy and hold: 24.28%
12 trades (2 wins / 9 losses)
Win ratio 16.67%
Average win 46.610% / 3.140 R
Average loss -13.401% / -0.901 R
Maximum drawdown 11.881%
System quality number -0.5
Ulcer Index 0.0690
Standard deviation of returns 4.086
Sharpe ratio -1.363
Recovery factor 0.273
Max adverse excursion 87.684%
Expectancy -3.3991% / -0.2273 R
"

./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers AIG,CDE,FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress
./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers AIG,CDE,FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5119.59625 (return 2.39%)
QQQQ buy and hold: 24.28%
3 trades (1 wins / 1 losses)
Win ratio 33.33%
Average win 48.897% / 3.325 R
Average loss -24.096% / -1.667 R
Maximum drawdown 4.229%
System quality number -0.0
Ulcer Index 0.0250
Standard deviation of returns 2.279
Sharpe ratio 0.031
Recovery factor 0.565
Max adverse excursion 87.684%
Expectancy 0.2348% / -0.0028 R
"

./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress
./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
"
./backtest.pl --list TESTS/strength_list.txt --start=2006-01-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
./backtest.pl --list TESTS/strength_list.txt --start=2006-01-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
"

./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4990.99 (return -0.18%)
QQQQ buy and hold: 3.06%
2 trades (0 wins / 2 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -7.560% / -0.767 R
Maximum drawdown 0.978%
System quality number -4.6
Ulcer Index 0.0057
Standard deviation of returns 0.160
Sharpe ratio -4.915
Recovery factor 0.184
Max adverse excursion 0.000%
Expectancy -7.5598% / -0.7667 R 
"

./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2007-04-10  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2007-04-10  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache
