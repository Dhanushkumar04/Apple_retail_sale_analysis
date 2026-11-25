--Apple Retail Sale--

--Improving query performance

--et 149.522 ms
--pt 2.738 ms
--after creating index--
-- et 20.376
--pt 2.617

explain analyze
select * from sales
where product_id='P-44';

create index sales_product_id on sales(product_id);

--et 192.197 ms
--pt 0.143 ms
--after creating index--
-- et 13.883
--pt 2.492

explain analyze
select * from sales
where store_id='ST-31';

create index sales_store_id on sales(store_id);
--
create index sales_sale_date on sales(sale_date);

-- Business problems

-- Find the number of stores in each country

select country, count(store_id) as total_stores from stores
group by 1
order by 2 desc

--Calculate the total number of units sold by each store.

select s.store_id, st.store_name, sum(s.quantity) as total_units from sales as s
join stores as st
on st.store_id=s.store_id
group by 1,2
order by 3 desc

--Identify how many sales occurred in December 2023.

select count(sale_id) as total_sale_dec from sales where to_char(sale_date,'MM-YYYY')='12-2023'

--Determine how many stores have never had a warranty claim filed.

select count(*) from stores
where store_id not in (
						select distinct store_id
						from sales as s
						right join warranty as w
						on s.sale_id=w.sale_id
					)

--Calculate the percentage of warranty claims marked as "Pending".

select distinct repair_status from warranty

select round(count(claim_id)::numeric/(select count(*) from warranty)::numeric *100,2) as warranty_pending from warranty 
where repair_status='Pending'

--Identify which store had the highest total units sold in the last year.

select s.store_id, st.store_name, sum(s.quantity) from sales as s
join stores as st
on s.store_id=st.store_id
where sale_date >= (current_date - interval '3 year')
group by 1,2 
order by 3 desc
limit 1

--Count the number of unique products sold in the last year.

select count(distinct product_id) from sales
where sale_date >= (current_date - interval '3 year')

--Find the average price of products in each category.

select p.category_id, c.category_name,avg(p.price) as avg_price from products as p
join category c
on p.category_id=c.category_id
group by 1,2
order by 3 desc

--How many warranty claims were filed in 2024?

select * from warranty
select count(*) as warranty_claim_2024
from warranty
where extract(year from claim_date)=2024

--For each store, identify the best-selling day based on highest quantity sold.

select * from(
		select store_id, to_char(sale_date,'Day') as day_name,
		sum(quantity) as total_unit_sold,
		rank() over(partition by store_id order by sum(quantity) desc) as rank
		from sales group by 1,2
) as t1
where rank =1

--Level 2
--Identify the least selling product in each country for each year based on total units sold.

with product_rank as (
		select st.country,p.product_name,sum(s.quantity) as total_qty_sold,
		rank() over(partition by st.country order by sum(s.quantity)) as rank
		from sales as s
		join
		stores as st
		on s.store_id=st.store_id
		join
		products as p
		on s.product_id=p.product_id
		group by 1,2
)
select * from product_rank
where rank=1

--Calculate how many warranty claims were filed within 180 days of a product sale.

SELECT
    COUNT(*) AS total_warranty_claims
FROM warranty AS w
JOIN sales AS s
ON s.sale_id = w.sale_id
WHERE w.claim_date >= s.sale_date
AND w.claim_date <= s.sale_date + INTERVAL '180 days';

--Determine how many warranty claims were filed for products launched in the last two years.

select p.product_name,count(w.claim_id) as no_claim,
count(s.sale_id)
from warranty as w
right join
sales as s
on s.sale_id=w.sale_id
join products as p
on p.product_id=s.product_id
where p.launch_date >= current_date - interval '3 years'
group by 1
having count(w.claim_id)>0

--List the months in the last three years where sales exceeded 5,000 units in the USA.

select to_char(sale_date,'MM-YYYY') as month, sum(s.quantity) as total_unit_sold
from sales as s
join
stores as st
on s.store_id=st.store_id
where st.country='United States' and s.sale_date>=current_date - interval '3 year'
group by 1
having sum(s.quantity)>5000

--Identify the product category with the most warranty claims filed in the last three years.

select c.category_name,
count(w.claim_id) as total_claim
from warranty as w
left join sales as s
on w.sale_id=s.sale_id
join products as p
on p.product_id=s.product_id
join category as c
on c.category_id=p.category_id
where w.claim_date >= current_date - interval '3 year'
group by 1

--Level 3
--Determine the percentage chance of receiving warranty claims after each purchase for each country.

select country,total_unit_sold,total_claim,coalesce(total_claim::numeric/total_unit_sold::numeric *100,0) as risk from 
(select st.country,sum(s.quantity) as total_unit_sold,count(w.claim_id) as total_claim
from sales as s
join stores as st
on s.store_id=st.store_id
left join warranty w
on w.sale_id=s.sale_id
group by 1) t1
order by 4 desc

--Analyze the year-by-year growth ratio for each store.

with yearly_sales as(
		select s.store_id,st.store_name, extract(year from sale_date) as year, sum(s.quantity * p.price) as total_sale
		from sales as s
		join products as p
		on s.product_id=p.product_id
		join stores as st
		on st.store_id = s.store_id
		group by 1,2,3
		order by 2,3
),
growth_ratio as (
		
		select store_name,year,
		lag(total_sale,1) over(partition by store_name order by year) as last_year_sale, total_sale as current_year_sale from yearly_sales
		)
		select store_name,year,last_year_sale,current_year_sale,round((current_year_sale - last_year_sale)::numeric/last_year_sale::numeric * 100,3) as growth_ratio
		from growth_ratio
		where last_year_sale is not null

--Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.

select 
	case when p.price < 500 then 'Less Expenses Product'
		when p.price between 500 and 1000 then 'Mid Range Product'
		else 'Expensive Product'
		end as price_segmant,count(w.claim_id) as total_claim 
from warranty as w
left join sales as s
on w.sale_id = s.sale_id
join products as p
on p.product_id = s.product_id
where claim_date >= current_date - interval '5 year'
group by 1

--Identify the store with the highest percentage of "In Progress" claims relative to total claims filed.

with in_progress as (

		select s.store_id,count(w.claim_id) as in_progress
		from sales as s
		right join warranty as w
		on w.sale_id=s.sale_id
		where w.repair_status='In Progress'
		group by 1
),
total_claims as (

		select s.store_id,count(w.claim_id) as total_claims
		from sales as s
		right join warranty as w
		on w.sale_id=s.sale_id
		group by 1
)
select tc.store_id,st.store_name,ip.in_progress,tc.total_claims,round(ip.in_progress::numeric/tc.total_claims::numeric*100,2) as percentage_in_progress
from in_progress as ip
join total_claims as tc
on ip.store_id=tc.store_id
join stores as st
on tc.store_id = st.store_id

--Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.

with monthly_sales as (

		select store_id, extract(year from sale_date) as year, extract(month from sale_date) as month, sum(p.price * s.quantity) as total_revenue
		from sales as s
		join products as p
		on s.product_id = p.product_id
		group by 1,2,3
		order by 1,2,3
)
select store_id,month,year,total_revenue,sum(total_revenue) over(partition by store_id order by year,month) as running_total
from monthly_sales

--Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.

select p.product_name,
	case when s.sale_date between p.launch_date and p.launch_date + interval '6 month' then '0-6 month'
		when s.sale_date between p.launch_date + interval '6 month' and p.launch_date + interval '12 month' then '6-12 month'
		when s.sale_date between p.launch_date + interval '12 month' and p.launch_date + interval '18 month' then '12-18 month'
		else '18+ month'
	end as plc,
	sum(s.quantity) as total_qty_sale
from sales as s
join products as p
on s.product_id=p.product_id
group by 1,2
order by 1,3 desc