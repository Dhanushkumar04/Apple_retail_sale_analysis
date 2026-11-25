--Category & Stores are parent table

create table stores(
store_id varchar(5) primary key,
store_name varchar(30),
city varchar(25),
country varchar(25)
);

create table category(
category_id varchar(10) primary key,
category_name varchar(20)
);

create table products
(
product_id varchar(10) primary key,
product_name varchar(35),
category_id varchar(10),
launch_date date,
price float,
constraint fk_category foreign key (category_id) references category(category_id)
);

create table sales
(
sale_id varchar(15) primary key,
sale_date date,
store_id varchar(10),
product_id varchar(10),
quantity int,
constraint fk_store foreign key(store_id) references stores(store_id),
constraint fk_product foreign key (product_id) references products(product_id)
);

create table warranty
(
claim_id varchar(10) primary key,
claim_date date,
sale_id varchar(15),
repair_status varchar(15),
constraint fk_orders foreign key (sale_id) references sales(sale_id)
);

select 'Schema created successfully' as Success_Message;

SET datestyle = 'ISO, DMY';

copy public.sales(sale_id, sale_date, store_id, product_id, quantity) FROM 'D:/download/apple_retail_sales/sales.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

SELECT * FROM sales LIMIT 10;
SELECT COUNT(*) FROM sales;

SELECT * FROM category LIMIT 10;
SELECT COUNT(*) FROM category;

SELECT * FROM products LIMIT 10;
SELECT COUNT(*) FROM products;

SELECT * FROM stores LIMIT 10;
SELECT COUNT(*) FROM stores;

SELECT * FROM warranty LIMIT 10;
SELECT COUNT(*) FROM warranty;

