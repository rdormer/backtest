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