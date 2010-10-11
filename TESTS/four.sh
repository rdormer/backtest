#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5000 (return 0)
QQQQ buy and hold: 0.019113149847091
"

./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress
./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4945.39454 (return -1.0921092)
Paid out 43.68454 in dividends
QQQQ buy and hold: 4.55516014234876
56 trades
41 losing trades (avg loss -0.243780243413657)
15 wining trades (avg win 0.707762557077626)
47.3298145304313 maximum drawdown
28 days longest drawdown
0.267857142857143 win ratio
5.5301296720061 max adverse excursion
Expectancy 0.0110972924322225
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4898.27 (return -2.03460000000003)
QQQQ buy and hold: -32.0993227990971
9 trades
6 losing trades (avg loss -0.947603121516166)
3 wining trades (avg win 0.544023662388423)
11.741478023605 maximum drawdown
467 days longest drawdown
0.333333333333333 win ratio
2.26379500078604 max adverse excursion
Expectancy -0.450394193547969
"

time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades
time ./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4540.545 (return -9.18910000000004)
Paid out 34.56 in dividends
QQQQ buy and hold: 17.4377224199288
145 trades
108 losing trades (avg loss -0.0571904566533637)
35 wining trades (avg win 0.582447855175128)
55.508604381389 maximum drawdown
207 days longest drawdown
0.241379310344828 win ratio
8.8888888888889 max adverse excursion
Expectancy 0.0972049979259275
"

time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list6 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 6962.18812 (return 39.2437624000001)
Paid out 33.89812 in dividends
QQQQ buy and hold: 17.4377224199288
129 trades
98 losing trades (avg loss -0.0333555703802535)
30 wining trades (avg win 0.181666666666667)
78.9788217835195 maximum drawdown
679 days longest drawdown
0.232558139534884 win ratio
9.72222222222223 max adverse excursion
Expectancy 0.016649601026007
"

time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list5 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache