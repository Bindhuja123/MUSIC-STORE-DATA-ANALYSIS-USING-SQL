-- Q1: Who is the senior most employee based on job title?

SELECT * FROM EMPLOYEE 
ORDER BY LEVELS DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT BILLING_COUNTRY, COUNT(INVOICE_ID) AS MAX_INVOICE 
FROM INVOICE
GROUP BY BILLING_COUNTRY 
ORDER BY MAX_INVOICE DESC


/* Q3: What are top 3 values of total invoice? */
SELECT TOTAL AS TOP_3 FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT BILLING_CITY, SUM(TOTAL) AS TOTAl_INVOICE
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY TOTAL_INVOICE DESC
LIMIT 1


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, SUM(I.TOTAL) AS TOTAL_SPENDING
FROM CUSTOMER C
INNER JOIN INVOICE I
ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY TOTAL_SPENDING DESC
LIMIT 1


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT C.EMAIL, C.FIRST_NAME, C.LAST_NAME, G.NAME
FROM CUSTOMER C
INNER JOIN INVOICE I
ON C.CUSTOMER_ID = I.CUSTOMER_ID
INNER JOIN INVOICE_LINE INVO
ON I.INVOICE_ID = INVO.INVOICE_ID
INNER JOIN TRACK T
ON INVO.TRACK_ID = T.TRACK_ID
INNER JOIN GENRE G
ON T.GENRE_ID = G.GENRE_ID
WHERE G.NAME='Rock'
ORDER BY EMAIL


SELECT DISTINCT EMAIL, FIRST_NAME, LAST_NAME,
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT ART.NAME, TRA.GENRE_ID, COUNT(ALB.TITLE) AS TOTAL_TRACK
FROM ARTIST ART 
INNER JOIN ALBUM ALB
ON ART.ARTIST_ID = ALB.ARTIST_ID
INNER JOIN TRACK TRA
ON ALB.ALBUM_ID = TRA.ALBUM_ID
WHERE TRA.GENRE_ID::INTEGER= 1
GROUP BY ART.NAME, TRA.GENRE_ID
ORDER BY TOTAL_TRACK DESC
LIMIT 10



/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT NAME, MILLISECONDS FROM TRACK
WHERE  MILLISECONDS > (SELECT AVG(MILLISECONDS) AS AVG_SEC FROM TRACK)
ORDER BY MILLISECONDS DESC



/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH BEST_SELLING_ARTIST AS(
	SELECT ART.ARTIST_ID, ART.NAME, SUM(INL.UNIT_PRICE*INL.QUANTITY) AS TOTAL_SALES, COUNT(ART.NAME)
	FROM INVOICE_LINE INL
	JOIN TRACK ON TRACK.TRACK_ID = INL.TRACK_ID
	JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
	JOIN ARTIST ART ON ART.ARTIST_ID = ALBUM.ARTIST_ID
	GROUP BY 1, 2
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, BSA.NAME, SUM(INL.UNIT_PRICE*INL.QUANTITY) AS AMOUNT_SPEND
FROM INVOICE I
JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE INL ON INL.INVOICE_ID = I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID = INL.TRACK_ID
JOIN ALBUM ALB ON ALB.ALBUM_ID = T.ALBUM_ID
JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID = ALB.ARTIST_ID
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

SELECT * FROM INVOICE_LINE;
SELECT * FROM GENRE;

WITH POPULAR_GENRE AS(
	SELECT COUNT(INVOICE_LINE.QUANTITY) AS TOTAL_QUANTITY, CUSTOMER.COUNTRY,GENRE.NAME, GENRE.GENRE_ID, 
	ROW_NUMBER() OVER(PARTITION BY CUSTOMER.COUNTRY ORDER BY COUNT(INVOICE_LINE.QUANTITY) DESC) AS ROWNUM
    FROM INVOICE_LINE 
	JOIN INVOICE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
	JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
	JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
	JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM POPULAR_GENRE WHERE ROWNUM <= 1



/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

SELECT * FROM CUSTOMER;
SELECT * FROM INVOICE;

WITH PREMIUM_CUSTOMER AS(
	SELECT CUSTOMER.CUSTOMER_ID, INVOICE.BILLING_COUNTRY,CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, SUM(TOTAL) AS TOTAL_SPEND,
	ROW_NUMBER() OVER(PARTITION BY INVOICE.BILLING_COUNTRY ORDER BY SUM(TOTAL) DESC) AS ROWNUM
	FROM CUSTOMER
	JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
	GROUP BY 1,2,3,4
	ORDER BY 2, 5 DESC
)
SELECT * FROM PREMIUM_CUSTOMER