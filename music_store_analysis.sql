-- 1. Who is the senior most employee based on job title?
SELECT * 
FROM employee
WHERE hire_date = (SELECT MIN(hire_date) FROM employee);


-- 2. Which countries have the most Invoices?
SELECT billing_country, count(*) invoices_count
FROM invoice
GROUP BY billing_country
ORDER BY count(*) DESC
limit 1;


-- 3. What are top 3 unique values of total invoice?
WITH top_3 AS (
	SELECT round(total::numeric, 3) AS invoice_total, dense_rank() over(ORDER BY total DESC) AS rnk
	FROM invoice
)
SELECT distinct invoice_total FROM top_3 WHERE rnk<=3 ORDER BY invoice_total DESC;


/*
4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals
*/
SELECT billing_city, round(sum(total)::numeric, 3) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY sum(total) DESC;


/*
5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money
*/
WITH cust_list AS (
	SELECT cust.customer_id, 
		cust.first_name||' '||cust.lASt_name cust_full_name, 
		round(SUM(inv.total)::numeric, 3) AS invoice_total
	FROM customer cust LEFT JOIN invoice inv ON cust.customer_id = inv.customer_id
	GROUP BY cust.customer_id, cust.first_name, cust.lASt_name, inv.customer_id
	ORDER BY SUM(inv.total) DESC
)
SELECT * FROM cust_list WHERE invoice_total = (SELECT MAX(invoice_total) FROM cust_list);


/*
6. Write query to return the email, first name, lASt name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A
*/
SELECT distinct cust.email, cust.first_name, cust.lASt_name, gen.name
FROM customer cust 
INNER JOIN invoice inv ON cust.customer_id = inv.customer_id
INNER JOIN invoice_line inv_line ON inv.invoice_id = inv_line.invoice_id
INNER JOIN track tr ON inv_line.track_id = tr.track_id
INNER JOIN genre gen ON tr.genre_id = gen.genre_id
WHERE UPPER(gen.name) LIKE 'ROCK'
ORDER BY cust.email ASc;

/*
7. Let's invite the artists who have written the most rock music in our datASet. 
Write a query that returns the Artist name and total track count of the top 10 rock bands
*/
SELECT 
	art.artist_id, 
	art.name AS artist_name, 
	count(tr.track_id) AS total_track_count
FROM genre gen 
INNER JOIN track tr ON gen.genre_id = tr.genre_id
INNER JOIN album alb ON tr.album_id = alb.album_id
INNER JOIN artist art ON alb.artist_id = art.artist_id
WHERE UPPER(gen.name) LIKE 'ROCK'
GROUP BY art.artist_id
ORDER BY count(tr.track_id) DESC;


/*
8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first
 */
SELECT tr.name, tr.milliseconds 
FROM track tr
WHERE tr.milliseconds > (SELECT round(avg(milliseconds)::numeric, 3) FROM track)
ORDER BY tr.milliseconds DESC;


/*
9, Find how much amount spent by each customer on best selling artist? 
Write a query to return customer name, artist name and total spent
 */
-- First Get Best selling artist
WITH best_selling_artist AS (
	SELECT 
		art.artist_id, 
		art.name AS artist_name, 
		sum(il.unit_price*il.quantity) AS total_sales
	FROM artist art
		inner join album alb ON artist.artist_id = alb.artist_id 
		inner join track tr ON album.album_id = tr.album_id 
		inner join invoice_line il ON tr.track_id = il.track_id 
	GROUP BY art.artist_id
	ORDER BY total_sales DESC
	limit 1
) 
-- Then Find all the Customers who have bought songs of best selling artists
SELECT 
	cust.first_name, 
	cust.lASt_name, 
	sum(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM customer cust
	inner join invoice inv ON cust.customer_id = inv.customer_id 
	inner join invoice_line il ON inv.invoice_id = il.invoice_id 
	inner join track tr ON il.track_id = track.track_id
	inner join album alb ON tr.album_id = alb.album_id
	inner join best_selling_artist bsa ON alb.artist_id = bsa.artist_id
GROUP BY cust.customer_id
ORDER BY 4;


/*
10. We want to find out the most popular music Genre for each country. 
We determine the most popular genre AS the genre with the highest amount of purchASes. 
Write a query that returns each country along with the top Genre. 
For countries WHERE the maximum number of purchASes is shared return all Genres
 */
WITH country_genre AS (
	SELECT 
		inv.billing_country, 
		gen.name AS genre, 
		count(inv.total) highest_amount_purchASes, 
		dense_rank() over(partition by inv.billing_country ORDER BY count(inv.total) DESC) AS rnk
	FROM genre gen 
		inner join track tr ON gen.genre_id = tr.genre_id 
		inner join invoice_line il ON tr.track_id = il.track_id 
		inner join invoice inv ON il.invoice_id = inv.invoice_id
	GROUP BY inv.billing_country, gen.genre_id 
	ORDER BY inv.billing_country ASc, count(inv.total) DESC
)
SELECT billing_country, genre, highest_amount_purchASes FROM country_genre WHERE rnk<=1;  


/* 
11. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries WHERE the top amount spent is shared, provide all customers who spent this amount
 */
WITH customer_country AS (
	SELECT 
		inv.billing_country, 
		cust.first_name||' '||cust.lASt_name AS customer_name, 
		round(sum(inv.total)::numeric, 3) AS total_spent,
		rank() over(partition by inv.billing_country ORDER BY round(sum(inv.total)::numeric, 3) DESC) AS rnk
	FROM customer cust 
		inner join invoice inv ON cust.customer_id = inv.customer_id
	GROUP BY cust.customer_id, inv.billing_country
	ORDER BY inv.billing_country, customer_name
)
SELECT billing_country, customer_name, total_spent FROM customer_country WHERE rnk<=1;

