create database finance;
use finance;

create table dividends (date date, ticker varchar(6), divamt float) row_format=fixed;
create table splits (date date, ticker varchar(6), bef integer, after integer) row_format=fixed;
create table historical (date date, ticker varchar(6), open float, high float, low float, close float, volume integer unsigned) row_format=fixed;

create table fundamentals(filed_date date, quarter_date date, sec_file char(24), sec_name varchar(100), 
sec_industry varchar(100), sic_code integer, cik char(10), total_assets integer unsigned, 
current_assets integer unsigned, total_debt integer unsigned, current_debt integer unsigned, 
cash integer unsigned, equity integer, net_income integer, revenue integer unsigned, 
avg_shares_basic integer unsigned, avg_shares_diluted integer unsigned, eps_basic float, 
eps_diluted float, shares_authorized integer unsigned, shares_issued integer unsigned, 
shares_outstanding integer unsigned);

create unique index histindex on historical (date, ticker);
create unique index divindex on dividends (date, ticker);
create unique index qtr_index on fundamentals (quarter_date, sec_name);
create unique index filed_index on fundamentals (filed_date, sec_name);

create user 'perldb'@'localhost';
grant all privileges on finance.* to 'perldb'@'localhost';