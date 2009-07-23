create database finance;

create table dividends (date date, ticker varchar(6), divamt float);
create table splits (date date, ticker varchar(6), int bef, int after);
create table historical (date date, ticker varchar(6), open float, high float, low float, close float, volume int unsigned);

create unique index histindex on historical (date, ticker);
create unique index divindex on dividends (date, ticker);
