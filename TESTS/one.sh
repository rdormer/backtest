#! /bin/sh

cd ../

echo "
ACOR	12	2010-04-16	38.56	(open)		 

total: 4983.56 (return -0.33%)
QQQQ buy and hold: -1.26%
"

./backtest.pl -tickers ACOR -entry TESTS/in2 -exit TESTS/out -start 2010-04-15 -finish 2010-04-20 --skip-progress
./backtest.pl -tickers ACOR -entry TESTS/in2 -exit TESTS/out -start 2010-04-15 -finish 2010-04-20 --skip-progress  --nocache

echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "
ACOR	25	2006-11-21	19.35	2006-12-08	16.73	-13.540% 

total: 4934.5 (return -1.31%)
QQQQ buy and hold: -0.90%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -13.540% / -1.358 R
Maximum drawdown 1.674%
System quality number 0.0
Ulcer Index 0.0071
Standard deviation of returns 0.175
Sharpe ratio -3.909
Recovery factor 0.783
Max adverse excursion 0.000%
Expectancy -13.5401% / -1.3575 R
"

./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress  
./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --nocache

echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";

echo "
total: 3308.76812 (return -33.82%)
Paid out 53.65812 in dividends
QQQQ buy and hold: 17.44%
207 trades (51 wins / 152 losses)
Win ratio 24.64%
Average win 16.769% / 1.685 R
Average loss -8.502% / -0.855 R
Maximum drawdown 51.976%
System quality number -2.0
Ulcer Index 0.2376
Standard deviation of returns 16.754
Sharpe ratio -0.305
Recovery factor 0.651
Max adverse excursion 8.889%
Expectancy -2.2761% / -0.2290 R
";

time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades

time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache


echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "
total: 4995.52 (return -0.09%)
QQQQ buy and hold: 18.82%
16 trades (4 wins / 12 losses)
Win ratio 25.00%
Average win 17.612% / 1.760 R
Average loss -9.846% / -0.985 R
Maximum drawdown 9.057%
System quality number -0.9
Ulcer Index 0.0509
Standard deviation of returns 2.117
Sharpe ratio -1.338
Recovery factor 0.010
Max adverse excursion 7.589%
Expectancy -2.9813% / -0.2987 R
";


time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades --nocache