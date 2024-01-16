show variables where variable_name like '%local%';

set global local_infile=ON;

drop database if exists stock_project;
create database if not exists stock_project;

use stock_project;

drop table if exists stocks;
create table stocks (
	stock_id int auto_increment primary key, 
	symbol varchar (10),
    name varchar (50),
    sector varchar (50)
	);
    
LOAD DATA LOCAL 
INFILE '/Users/sarahtakeda-byrne/Documents/Northeastern/Year 3/Y3S1/CS3200 Database Design/Project/Data/S&P500TickerSymbols.csv'
INTO TABLE stocks
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
lines terminated by '\r\n'
IGNORE 1 ROWS
(symbol, name, sector);

select *
from stocks;


drop table if exists index_fund;
create table index_fund (
	index_fund_id int auto_increment primary key,
    name varchar(100),
    country_code varchar(50));
	-- inserting just one index fund for now
insert into index_fund(name, country_code) values
('S&P500', 'USA');
select * from index_fund;

drop table if exists stock_connect_index;
create table stock_connect_index (
	stock_id int not null,
    index_fund_id int not null,
    primary key (stock_id, index_fund_id),
    constraint index_fund_fk_stock foreign key (stock_id) references stocks(stock_id),
    constraint stock_fk_index_fund foreign key (index_fund_id) references index_fund(index_fund_id));

insert into stock_connect_index(stock_id, index_fund_id) 
select stock_id, 1
from stocks;

select * from stock_connect_index;

drop table if exists index_fund_data;
create table index_fund_data (
	date date,
    price float,
    dividend float,
    earnings float);
    
LOAD DATA LOCAL 
INFILE '/Users/sarahtakeda-byrne/Documents/Northeastern/Year 3/Y3S1/CS3200 Database Design/Project/Data/s&p_index_fund_data.csv'
INTO TABLE index_fund_data
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(date, price, dividend, earnings);

select * from index_fund_data;

alter table index_fund_data add index_fund_id int;
alter table index_fund_data add constraint fk_index_fund_id foreign key(index_fund_id) references index_fund(index_fund_id);

	-- setting all index fund data to s&p500
update index_fund_data ifd
set ifd.index_fund_id = 1;

drop table if exists environment;
create table environment (
	date datetime unique not null,
    exchange_rate float,
    interest_rate float,
    expected_inflation float
    );
    
LOAD DATA LOCAL 
INFILE '/Users/sarahtakeda-byrne/Documents/Northeastern/Year 3/Y3S1/CS3200 Database Design/Project/Data/environment.csv'
INTO TABLE environment
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 2 ROWS;

select *
from environment;

drop table if exists stock_data;
create table stock_data (
	date datetime, 
    open float,
    high float, 
    low float,
    close float, 
    volume float, 
    ticker_symbol varchar(10)
    );
    
create index ticker_index on stock_data (ticker_symbol);


load data local 
infile '/Users/sarahtakeda-byrne/Documents/Northeastern/Year 3/Y3S1/CS3200 Database Design/Project/Data/clean_sp500_stock_2018_2023.csv'
into table stock_data
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
lines terminated by '\r\n'
IGNORE 1 ROWS;

drop table if exists company;
create table company (
	company_id int primary key auto_increment,
	name varchar(50),
    ticker_symbol varchar(10),
    isin_num varchar(50),
    city varchar(50),
    op_revenue int,
    num_employees int,
    ret_on_assets float,
    market_price_cur float
    );
    
load data local 
infile '/Users/sarahtakeda-byrne/Documents/Northeastern/Year 3/Y3S1/CS3200 Database Design/Project/Data/OSIRIS formatted - Sheet1 (1).csv'
into table company
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(name, ticker_symbol, isin_num, city, @op_revenue, @num_employees, @ret_on_assets, @market_price_cur)
set op_revenue = nullif(@op_revenue, ''),
num_employees = nullif(@num_employees, ''),
ret_on_assets = nullif(@ret_on_assets, ''),
market_price_cur = nullif(@market_price_cur, '');


-- add company id as foreign key in stocks
alter table stocks add company_id int;
alter table stocks add constraint fk_company_id foreign key(company_id) references company(company_id);

update stocks st
inner join company co
	on co.ticker_symbol = st.symbol
set st.company_id = co.company_id;

select * 
from stocks;

-- add stock_id as foreign key in stock_data
alter table stock_data add stock_id int;
alter table stock_data add constraint fk_stock_id foreign key(stock_id) references stocks(stock_id);
alter table stock_data add constraint unique_stock_data unique(date, stock_id);

update stock_data sd
inner join stocks st
	on sd.ticker_symbol = st.symbol
set sd.stock_id = st.stock_id;

-- create sector names table
drop table if exists sectors;
create table sectors (
	sector_id int auto_increment primary key,
    sector_name varchar(25)
    );
    
load data local 
infile '/Users/sarahtakeda-byrne/Documents/Northeastern/Year 3/Y3S1/CS3200 Database Design/Project/Data/sector_names.csv'
into table sectors
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
lines terminated by '\r\n'
IGNORE 1 ROWS
(sector_name);

select * from sectors;

-- create sector data table
drop table if exists sector_data;
create table sector_data (
	date datetime,
    value float,
    sector_name varchar(25)
    );
    
load data local 
infile '/Users/sarahtakeda-byrne/Documents/Northeastern/Year 3/Y3S1/CS3200 Database Design/Project/Data/sector_index_data.csv'
into table sector_data
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
lines terminated by '\r\n' 
IGNORE 1 ROWS;

select * from sector_data;

-- add sector id as a foreign key and remove sector name from sector_data
alter table sector_data add sector_id int;
alter table sector_data add constraint fk_sector_id foreign key(sector_id) references sectors(sector_id);
alter table sector_data add constraint uniqueness_sector_data unique(date, sector_id);

update sector_data sed
inner join sectors se
	on sed.sector_name = se.sector_name
set sed.sector_id = se.sector_id;

alter table sector_data drop sector_name;

select distinct sector_id
from sector_data;

-- add sector_id as a foreign key in the stocks table and remove sector_name

alter table stocks add sector_id int;
alter table stocks add constraint fk_sectors_id foreign key(sector_id) references sectors(sector_id);

update stocks st
inner join sectors se
	on st.sector = se.sector_name
set st.sector_id = se.sector_id;

alter table stocks drop sector;
select * from stocks;

-- how much does company size influence stock price
	-- maybe we can try to find the average company size of companies which have closing price
	-- of below average and avg company size of companies with above avg closing price
select 
	co.name,
	co.num_employees,
    sd.close,
    sd.date
from company co join stocks st using (company_id)
join stock_data sd using (stock_id)
where sd.date between '2023-05-01' and '2023-05-01'
and co.num_employees is not null
order by sd.close desc; -- this gives the num employees and close number for each company.

select 
    avg(sd.close) as 'avg_price'
from company co join stocks st using (company_id)
join stock_connect_index sci using (stock_id)
join stock_data sd using (stock_id)
where sd.date between '2023-05-01' and '2023-05-01'
and co.num_employees is not null and sci.index_fund_id = 1
order by sd.close desc; -- this gives the avg closing price for all stocks in s&p500

select sd.close from stock_data sd
where sd.date between '2023-05-01' and '2023-05-01';

select 
	(select 
	avg(co.num_employees)
from company co join stocks st using (company_id)
join stock_connect_index sci using (stock_id)
join stock_data sd using (stock_id)
where sd.date between '2023-05-01' and '2023-05-01'
and sci.index_fund_id = 1
and co.num_employees is not null
and sd.close >= (select 
		avg(sd.close) as 'avg_price'
		from company co join stocks st using (company_id)
		join stock_data sd using (stock_id)
		where sd.date between '2023-05-01' and '2023-05-0`'
		and co.num_employees is not null
		order by sd.close desc)) 'avg_size_above_avg',
(select 
	avg(co.num_employees)
from company co join stocks st using (company_id)
join stock_connect_index sci using (stock_id)
join stock_data sd using (stock_id)
where sd.date between '2023-05-01' and '2023-05-01'
and sci.index_fund_id = 1
and co.num_employees is not null
and sd.close < (select 
		avg(sd.close) as 'avg_price'
		from company co join stocks st using (company_id)
		join stock_data sd using (stock_id)
		where sd.date between '2023-05-01' and '2023-05-01'
		and co.num_employees is not null
		order by sd.close desc)) as 'avg_size_below_avg';
        

-- Company size according to above or below average stock price
SELECT
    AVG(CASE WHEN sd.close >= avg_data.avg_price THEN co.num_employees END) AS avg_size_above_avg,
    AVG(CASE WHEN sd.close < avg_data.avg_price THEN co.num_employees END) AS avg_size_below_avg
FROM
    company co
    JOIN stocks st USING (company_id)
    JOIN stock_connect_index sci USING (stock_id)
    JOIN stock_data sd USING (stock_id)
JOIN (
    SELECT AVG(sd.close) AS avg_price
    FROM company co
    JOIN stocks st USING (company_id)
    JOIN stock_data sd USING (stock_id)
    WHERE
        sd.date BETWEEN '2023-05-01' AND '2023-05-01'
        AND co.num_employees IS NOT NULL
) AS avg_data ON 1=1
WHERE
    sd.date BETWEEN '2023-05-01' AND '2023-05-01'
    AND sci.index_fund_id = 1
    AND co.num_employees IS NOT NULL;
    
SELECT
    AVG(CASE WHEN sd.close >= avg_data.avg_price THEN co.num_employees END) AS avg_size_above_avg,
    AVG(CASE WHEN sd.close < avg_data.avg_price THEN co.num_employees END) AS avg_size_below_avg
FROM
    company co
    JOIN stocks st USING (company_id)
    JOIN stock_connect_index sci USING (stock_id)
    JOIN stock_data sd USING (stock_id)
JOIN (
    SELECT AVG(sd.close) AS avg_price
    FROM company co
    JOIN stocks st USING (company_id)
    JOIN stock_data sd USING (stock_id)
    WHERE
        sd.date BETWEEN '2022-05-01' AND '2022-05-01'
        AND co.num_employees IS NOT NULL
) AS avg_data ON 1=1
WHERE
    sd.date BETWEEN '2022-05-01' AND '2022-05-01'
    AND sci.index_fund_id = 1
    AND co.num_employees IS NOT NULL;

-- which companies had the widest price range in 2022
select
	sd.ticker_symbol,
	st.name,
    round((max(sd.open) - min(sd.open)),2) as 'price_range',
    sec.sector_name
from stocks st join stock_data sd using (stock_id)
join stock_connect_index sci using (stock_id)
join sectors sec on (st.sector_id = sec.sector_id)
where sci.index_fund_id = 1
	and sd.date between '2022-01-01' and '2022-12-31'
group by sd.ticker_symbol, st.name, sec.sector_name
order by price_range desc
limit 10;

select
	se.sector_name,
    round((max(sd.value) - min(sd.value)),2) as 'price_range'
from sectors se join sector_data sd using (sector_id)
where sd.date between '2022-01-01' and '2022-12-31'
group by se.sector_name
order by price_range desc;

-- What companies had the most severe changes in open and closed prices during 2017? List the top 50 instances. 
select
	co.name,
    date(sd.date) as 'date',
    (sd.close - sd.open) as 'price_change'
from stock_data sd join stocks st using (stock_id)
join company co using (company_id)
order by price_change
limit 20;

-- top populated sectors
select
	sec.sector_name,
    count(stock_id) as 'num_stocks'
from sectors sec join stocks sto using (sector_id)
group by sec.sector_name
order by num_stocks desc;


