-- 1. Who is the senior most employee based on job title?
select * 
from employee
where hire_date = (select MIN(hire_date) from employee);


-- 2. Which countries have the most Invoices?
with inv_cnt AS (
	select billing_country, count(*) invoices_count
	from invoice
	group by billing_country
	order by count(*) desc)
select * from inv_cnt limit 1;


-- 3. What are top 3 unique values of total invoice?
with top_3 as (
	select round(total::numeric, 3) as invoice_total, dense_rank() over(order by total desc) as rnk
	from invoice
)
select distinct invoice_total from top_3 where rnk<=3 order by invoice_total desc;


-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, round(sum(total)::numeric, 3) as invoice_total
from invoice
group by billing_city
order by sum(total) desc;


-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
with cust_list as (
	select cust.customer_id, cust.first_name||' '||cust.last_name cust_full_name, round(SUM(inv.total)::numeric, 3) as invoice_total
	from customer cust LEFT JOIN invoice inv ON cust.customer_id = inv.customer_id
	group by cust.customer_id, cust.first_name, cust.last_name, inv.customer_id
	order by SUM(inv.total) desc
)
select * 
from cust_list where invoice_total = (select MAX(invoice_total) from cust_list);


-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select distinct cust.email, cust.first_name, cust.last_name, gen.name
from customer cust 
LEFT JOIN invoice inv ON cust.customer_id = inv.customer_id
LEFT JOIN invoice_line inv_line ON inv.invoice_id = inv_line.invoice_id
LEFT JOIN track tr ON inv_line.track_id = tr.track_id
LEFT JOIN genre gen ON tr.genre_id = gen.genre_id
where UPPER(gen.name) LIKE '%ROCK%'
order by cust.email asc;

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands


-- 3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first









