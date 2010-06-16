#! /bin/sh

cd ../

echo "
ACOR	12	2010-04-16	38.56	(open)

total: 4983.56 (return -0.32880000000001)
QQQQ buy and hold: -1.25673249551167
"

./backtest.pl -tickers ACOR -entry TESTS/in2 -exit TESTS/out -start 2010-04-15 -finish 2010-04-20 --skip-progress
./backtest.pl -tickers ACOR -entry TESTS/in2 -exit TESTS/out -start 2010-04-15 -finish 2010-04-20 --skip-progress  --nocache

echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "

ACOR	25	2006-11-21	19.35	2006-12-08	16.73	-13.540%

total: 4934.5 (return -1.31)
QQQQ buy and hold: -0.902934537246046
1 trades
1 losing trades (avg loss -13.5400516795866)
0 wining trades (avg win )
1.67380691441666 maximum drawdown
12 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -13.5400516795866
"

./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress  
./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --nocache

echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";

echo "
total: 7881.15762 (return 57.6231523999999)
Paid out 69.18512 in dividends
QQQQ buy and hold: 17.4377224199288
291 trades  (discarded 1 trades)
200 losing trades (avg loss -0.014098690835851)
91 wining trades (avg win 0.0433258497774627)
85.104456849577 maximum drawdown
200 days longest drawdown
0.312714776632302 win ratio
9.72222222222223 max adverse excursion
Expectancy 0.00385881155525401
";

time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades

time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache


echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "
total: 5071.65 (return 1.43299999999999)
QQQQ buy and hold: 18.8190110417667
17 trades
12 losing trades (avg loss -0.833333333333333)
5 wining trades (avg win 2.78987116836961)
14.9678575602914 maximum drawdown
115 days longest drawdown
0.294117647058824 win ratio
7.08229426433916 max adverse excursion
Expectancy 0.232315049520474
";


time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades

time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades --nocache