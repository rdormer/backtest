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
total: 3308.76812 (return -33.8246376)
Paid out 53.65812 in dividends
QQQQ buy and hold: 17.4377224199288
207 trades
152 losing trades (avg loss -0.00471609130352762)
51 wining trades (avg win 0.106862745098039)
51.9762409173219 maximum drawdown
291 days longest drawdown
0.246376811594203 win ratio
8.8888888888889 max adverse excursion
Expectancy 0.0227743466504816
";

time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades

time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache


echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "
total: 4995.52 (return -0.0895999999999913)
QQQQ buy and hold: 18.8190110417667
16 trades
12 losing trades (avg loss -0.833333333333333)
4 wining trades (avg win 2.65437583296312)
9.05696029921688 maximum drawdown
212 days longest drawdown
0.25 win ratio
7.58928571428572 max adverse excursion
Expectancy 0.038593958240781
";


time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades --nocache