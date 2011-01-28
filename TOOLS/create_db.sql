create database finance;
use finance;

create table dividends (date date not null, ticker varchar(5) not null, divamt float not null) row_format=fixed;
create table splits (date date not null, ticker varchar(5) not null, bef integer not null, after integer not null) row_format=fixed;
create table cikmap (ticker varchar(5), cik char(10));

create table historical (date date not null, ticker varchar(5) not null, open float not null, high float not null, 
low float not null, close float not null, volume integer unsigned not null) row_format=fixed;

create table fundamentals(filed_date date, quarter_date date, sec_file char(24), sec_name varchar(100), 
sec_industry varchar(100), sic_code integer, cik char(10), total_assets bigint unsigned, 
current_assets bigint unsigned, total_debt bigint unsigned, current_debt bigint unsigned, 
cash bigint unsigned, equity integer, net_income integer, revenue bigint unsigned, 
avg_shares_basic bigint unsigned, avg_shares_diluted bigint unsigned, eps_basic float, 
eps_diluted float, shares_authorized bigint unsigned, shares_issued bigint unsigned, 
shares_outstanding bigint unsigned, ticker varchar(5));

create unique index histindex on historical (ticker, date);
create unique index divindex on dividends (ticker, date);
create unique index splitindex on splits (ticker, date);
create unique index qtr_index_t on fundamentals (quarter_date, ticker);
--create unique index qtr_index on fundamentals (quarter_date, sec_name);
--create unique index filed_index on fundamentals (filed_date, sec_name);
create unique index cik_index on fundamentals (cik, filed_date);
create unique index cik_index on cikmap (ticker, cik);

create user 'perldb'@'localhost';
grant all privileges on finance.* to 'perldb'@'localhost';