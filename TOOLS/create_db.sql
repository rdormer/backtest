create database finance;
use finance;

create table dividends (date date, ticker varchar(6), divamt float);
create table splits (date date, ticker varchar(6), bef integer, after integer);
create table historical (date date, ticker varchar(6), open float, high float, low float, close float, volume integer unsigned);
create table fundamentals(date date, sec_file char(24), sec_name varchar(100), sec_industry varchar(100), sic_code integer, total_assets integer, eps_basic float, eps_diluted float);

create unique index histindex on historical (date, ticker);
create unique index divindex on dividends (date, ticker);
create unique index fundindex on fundamentals (date, sec_name);