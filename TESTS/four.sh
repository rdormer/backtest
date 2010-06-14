#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress
./backtest.pl -tickers=AAON -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-12-06 -finish 2007-12-09 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 6238.61437 (return 24.7722874)
Paid out 50.78687 in dividends
QQQQ buy and hold: 4.55516014234876
60 trades
33 losing trades (avg loss -0.303510541228449)
27 wining trades (avg win 0.629439370877727)
30.4886257812121 maximum drawdown
149 days longest drawdown
0.45 win ratio
9.72733971997052 max adverse excursion
Expectancy 0.11631691921933
"

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades
./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-02-01 -finish 2007-02-01 --skip-progress --skip-trades --nocache

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

./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress 
./backtest.pl -tickers=ABII -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --nocache
