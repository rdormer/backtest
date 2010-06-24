#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
AAON	25	2007-12-07	19.8		19.0333333333333	-3.872%

total: 4980.83333333333 (return -0.383333333333339)
QQQQ buy and hold: 0.019113149847091
1 trades
1 losing trades (avg loss -3.87205387205388)
0 wining trades (avg win )
0.358422939068106 maximum drawdown
1 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -3.87205387205388
"

./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress
./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 6224.59437 (return 24.4918874)
Paid out 48.98687 in dividends
QQQQ buy and hold: 4.55516014234876
60 trades
33 losing trades (avg loss -0.303510541228449)
27 wining trades (avg win 0.629439370877727)
30.4976435723447 maximum drawdown
149 days longest drawdown
0.45 win ratio
9.72733971997052 max adverse excursion
Expectancy 0.11631691921933
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5009.31 (return 0.186200000000026)
QQQQ buy and hold: -32.0993227990971
9 trades
6 losing trades (avg loss -0.382588426066688)
3 wining trades (avg win 0.204370382015407)
0.762322659623703 maximum drawdown
466 days longest drawdown
0.333333333333333 win ratio
6.45950222989499 max adverse excursion
Expectancy -0.186935490039323
"

time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades
time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4279.72199999999 (return -14.4055600000001)
Paid out 34.56 in dividends
QQQQ buy and hold: 17.4377224199288
193 trades
130 losing trades (avg loss -0.0216902935936169)
63 wining trades (avg win 0.0625817830118906)
64.7794670075721 maximum drawdown
199 days longest drawdown
0.326424870466321 win ratio
8.8888888888889 max adverse excursion
Expectancy 0.00581820809626382
"

time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 7296.99562 (return 45.9399124000001)
Paid out 37.41312 in dividends
QQQQ buy and hold: 17.4377224199288
163 trades  (discarded 1 trades)
116 losing trades (avg loss -0.0863175600903015)
47 wining trades (avg win 0.107446808510638)
78.0678975060193 maximum drawdown
679 days longest drawdown
0.288343558282209 win ratio
9.72222222222223 max adverse excursion
Expectancy -0.030446852579601
"

time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache