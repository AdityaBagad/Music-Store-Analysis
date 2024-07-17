-- 1. Who is the senior most employee based on job title?
select * 
from employee
where hire_date = (select MIN(hire_date) from employee);


-- 2. Which countries have the most Invoices?
select billing_country, count(*) invoices_count
from invoice
group by billing_country
order by count(*) desc
limit 1;


-- 3. What are top 3 unique values of total invoice?
with top_3 as (
	select round(total::numeric, 3) as invoice_total, dense_rank() over(order by total desc) as rnk
	from invoice
)
select distinct invoice_total from top_3 where rnk<=3 order by invoice_total desc;


/*
 * Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
 * Write a query that returns one city that has the highest sum of invoice totals. 
 * Return both the city name & sum of all invoice totals
*/
select billing_city, round(sum(total)::numeric, 3) as invoice_total
from invoice
group by billing_city
order by sum(total) desc;


/*
 * Who is the best customer? The customer who has spent the most money will be declared the best customer. 
 * Write a query that returns the person who has spent the most money
*/
with cust_list as (
	select cust.customer_id, 
		cust.first_name||' '||cust.last_name cust_full_name, 
		round(SUM(inv.total)::numeric, 3) as invoice_total
	from customer cust LEFT JOIN invoice inv ON cust.customer_id = inv.customer_id
	group by cust.customer_id, cust.first_name, cust.last_name, inv.customer_id
	order by SUM(inv.total) desc
)
select * from cust_list where invoice_total = (select MAX(invoice_total) from cust_list);


/*
 * Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
 * Return your list ordered alphabetically by email starting with A
*/
select distinct cust.email, cust.first_name, cust.last_name, gen.name
from customer cust 
INNER JOIN invoice inv ON cust.customer_id = inv.customer_id
INNER JOIN invoice_line inv_line ON inv.invoice_id = inv_line.invoice_id
INNER JOIN track tr ON inv_line.track_id = tr.track_id
INNER JOIN genre gen ON tr.genre_id = gen.genre_id
where UPPER(gen.name) LIKE 'ROCK'
order by cust.email asc;

/*
 * Let's invite the artists who have written the most rock music in our dataset. 
 * Write a query that returns the Artist name and total track count of the top 10 rock bands
*/
select art.artist_id, art.name as artist_name, count(tr.track_id) as total_track_count
from genre gen 
INNER JOIN track tr ON gen.genre_id = tr.genre_id
INNER JOIN album alb ON tr.album_id = alb.album_id
INNER JOIN artist art ON alb.artist_id = art.artist_id
where UPPER(gen.name) LIKE 'ROCK'
group by art.artist_id
order by count(tr.track_id) desc;


/*
 * Return all the track names that have a song length longer than the average song length. 
 * Return the Name and Milliseconds for each track. 
 * Order by the song length with the longest songs listed first
 */
select tr.name, tr.milliseconds 
from track tr
where tr.milliseconds > (select round(avg(milliseconds)::numeric, 3) from track)
order by tr.milliseconds desc;


/*
 * Find how much amount spent by each customer on best selling artist? 
 * Write a query to return customer name, artist name and total spent
 */
-- First Get Best selling artist
with best_selling_artist as (
	select art.artist_id, art.name as artist_name, sum(il.unit_price*il.quantity) as total_sales
	from artist art
	inner join album alb on artist.artist_id = alb.artist_id 
	inner join track tr on album.album_id = tr.album_id 
	inner join invoice_line il on tr.track_id = il.track_id 
	group by art.artist_id
	order by total_sales desc
	limit 1
) 
-- Then Find all the Customers who have bought songs of best selling artists
select cust.first_name, cust.last_name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from customer cust
inner join invoice inv on cust.customer_id = inv.customer_id 
inner join invoice_line il on inv.invoice_id = il.invoice_id 
inner join track tr on il.track_id = track.track_id
inner join album alb on tr.album_id = alb.album_id
inner join best_selling_artist bsa on alb.artist_id = bsa.artist_id
group by cust.customer_id
order by 4;


/*
 * We want to find out the most popular music Genre for each country. 
 * We determine the most popular genre as the genre with the highest amount of purchases. 
 * Write a query that returns each country along with the top Genre. 
 * For countries where the maximum number of purchases is shared return all Genres
 */
with country_genre as (
	select 
		i.billing_country, 
		g."name" as genre, 
		count(i.total) highest_amount_purchases, 
		dense_rank() over(partition by i.billing_country order by count(i.total) desc) as rnk
	from genre g inner join track t on g.genre_id = t.genre_id 
	inner join invoice_line il on t.track_id = il.track_id 
	inner join invoice i on il.invoice_id = i.invoice_id
	group by i.billing_country, g.genre_id 
	order by i.billing_country asc, count(i.total) desc
)
select billing_country, genre, highest_amount_purchases from country_genre where rnk<=1;  


/* 
 * Write a query that determines the customer that has spent the most on music for each country. 
 * Write a query that returns the country along with the top customer and how much they spent. 
 * For countries where the top amount spent is shared, provide all customers who spent this amount
 */




