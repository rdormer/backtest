#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4952.48 (return -0.950400000000009)
QQQQ buy and hold: 19.6829268292683
2 trades
1 losing trades (avg loss -12.8985507246377)
1 wining trades (avg win 3.33333333333333)
1.3060742819781 maximum drawdown
259 days longest drawdown
0.5 win ratio
0 max adverse excursion
Expectancy -4.78260869565218
"

./backtest.pl -ticker=AACC -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=AACC -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5011.96 (return 0.239200000000001)
QQQQ buy and hold: 1.66265587398818
1 trades
0 losing trades (avg loss )
1 wining trades (avg win 2.40963855421688)
 maximum drawdown
1 days longest drawdown
1 win ratio
0 max adverse excursion
Expectancy 2.40963855421688
"

./backtest.pl -ticker=AZPN -start 2010-07-29 -finish 2010-08-04 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=AZPN -start 2010-07-29 -finish 2010-08-04 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 8275.1274 (return 65.502548)
QQQQ buy and hold: 19.6829268292683
8 trades
4 losing trades (avg loss -2.50569476082004)
4 wining trades (avg win 0.129802699896155)
5.68559026625085 maximum drawdown
49 days longest drawdown
0.5 win ratio
2.28452751817238 max adverse excursion
Expectancy -1.18794603046194
"

./backtest.pl -ticker=ABCB -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=ABCB -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4995.5 (return -0.09)
QQQQ buy and hold: -2.2808267997149
1 trades
1 losing trades (avg loss -0.909090909090906)
0 wining trades (avg win )
0.126000000000004 maximum drawdown
2 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -0.909090909090906
"

./backtest.pl -ticker=ACCL -start 2009-10-29 -finish 2009-11-03 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=ACCL -start 2009-10-29 -finish 2009-11-03 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4990.31 (return -0.193799999999992)
QQQQ buy and hold: -2.23966751327638
1 trades
1 losing trades (avg loss -1.98212203653324)
0 wining trades (avg win )
0.193799999999992 maximum drawdown
3 days longest drawdown
0 win ratio
0 max adverse excursion
Expectancy -1.98212203653324
"

./backtest.pl -tickers=ABCO -start 2009-10-22 -finish 2009-10-28 -entry TESTS/binventry -exit TESTS/binvexit --skip-progress --skip-trades
./backtest.pl -tickers=ABCO -start 2009-10-22 -finish 2009-10-28 -entry TESTS/binventry -exit TESTS/binvexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5196.53 (return 3.93060000000005)
Paid out 27.18 in dividends
QQQQ buy and hold: 7.68122899663947
24 trades
16 losing trades (avg loss -0.624018838304553)
8 wining trades (avg win 3.05429864253394)
18.4548458280205 maximum drawdown
683 days longest drawdown
0.333333333333333 win ratio
7.97266514806379 max adverse excursion
Expectancy 0.60208698864161
"

./backtest.pl -tickers=ADTN list -entry TESTS/bol_dayago1 -exit TESTS/tdout -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades
./backtest.pl -tickers=ADTN list -entry TESTS/bol_dayago1 -exit TESTS/tdout -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5792.43 (return 15.8486)
QQQQ buy and hold: 7.68122899663947
29 trades
18 losing trades (avg loss -0.131369534137196)
11 wining trades (avg win 0.102938148877975)
17.8772223460098 maximum drawdown
442 days longest drawdown
0.379310344827586 win ratio
6.54899573950093 max adverse excursion
Expectancy -0.0424942060969586
"

./backtest.pl -tickers=AAPL list -entry TESTS/bol_dayago2 -exit TESTS/out -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades
./backtest.pl -tickers=AAPL list -entry TESTS/bol_dayago2 -exit TESTS/out -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 3397.265 (return -32.0547)
Paid out 18.46 in dividends
QQQQ buy and hold: -22.0555555555556
256 trades
177 losing trades (avg loss -0.0293884187657413)
78 wining trades (avg win 0.000693656854890316)
49.7358024642658 maximum drawdown
517 days longest drawdown
0.3046875 win ratio
9.55555555555555 max adverse excursion
Expectancy -0.0202227863500801
"

./backtest.pl --entry TESTS/macd_in --exit TESTS/macd_out --start 2007-11-01 --finish 2009-10-30 --list TESTS/n100.txt --skip-trades --skip-progress
./backtest.pl --entry TESTS/macd_in --exit TESTS/macd_out --start 2007-11-01 --finish 2009-10-30 --list TESTS/n100.txt --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5133.756595 (return 2.67513190000001)
QQQQ buy and hold: -100
6 trades
3 losing trades (avg loss -2.57787325456499)
3 wining trades (avg win 0.173070266528207)
2.75349099388474 maximum drawdown
207 days longest drawdown
0.5 win ratio
2.37741456166419 max adverse excursion
Expectancy -1.20240149401839
"

./backtest.pl --ticker=ABCB --start 2009-01-01 --finish 2010-10-01 --entry TESTS/bcontentry --exit TESTS/bcontexit --skip-trades --skip-progress
./backtest.pl --ticker=ABCB --start 2009-01-01 --finish 2010-10-01 --entry TESTS/bcontentry --exit TESTS/bcontexit --skip-trades --skip-progress --nocache