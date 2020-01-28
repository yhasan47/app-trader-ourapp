/*App Trader will purchase apps for 10,000 times the price of the app. 
For apps that are priced from free up to $1.00, the purchase price is $10,000.


SELECT  p.name, a.name, p.genres, a.primary_genre, p.price, a.price, p.content_rating, a.content_rating
FROM play_store_apps AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
ORDER BY p.price DESC;

only 79 are not free
*/

/*
what genres are the most popular?

How many categories of genres?
Play_store: 119.
App_store:	23.
*/

/*
SELECT DISTINCT(primary_genre)
FROM app_store_apps
ORDER BY primary_genre;

SELECT DISTINCT(genres)
FROM play_store_apps
ORDER BY genres;
*/

/*
How can i see which genre is the most bought?
Couldnt filter genres bc they are text
*/


----------------------- STARTING NEW -------------------------------------


/*

Are there duplicates?
2 for app store
1181 for play store



SELECT COUNT(name) - COUNT(DISTINCT name)
FROM app_store_apps;

SELECT COUNT(name) - COUNT(DISTINCT name)
FROM play_store_apps;



Because play store has so many duplicates, i have to remove them to make my queries more accurate.
HOW? Make a temp table. use the group clause to narrow down the search. Use columns that pertain to read.me.



CREATE TEMP TABLE play_store_grouped AS SELECT name, rating, size, type, price, content_rating, genres
										FROM play_store_apps
										GROUP BY name, rating, size, type, price, content_rating, genres;

SELECT * FROM play_store_grouped;   



--Looking at some of the dupes. They look like different apps made by different companies. 
--So I will keep them in the table.



SELECT name, count(name) - count(DISTINCT name) as dupes
FROM play_store_grouped
GROUP BY name
ORDER BY dupes DESC;

SELECT *
FROM play_store_grouped
WHERE name = 'Solitaire' OR
	  name = 'Bubble Shooter' OR
	  name = 'Chess Free' OR
	  name = 'Flashlight'
ORDER BY name;



--Join the tables.



SELECT p.name,
	   a.name,
	   p.rating,
	   a.rating,
	   p.size,
	   a.size_bytes,
	   p.price,
	   a.price,
	   p.content_rating,
	   a.content_rating,
	   p.genres,	   
	   a.primary_genre
FROM play_store_grouped AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
ORDER BY p.name;


--lets take a look at the prices. There is a $ in the playstore, making it a text attribute, so i cant do a comparison. 
--I have to convert to numeric attribute to make the columns compareable.
--30 apps have different prices.
--where there is a difference in price, looks like apple is the higher of the two.
--no major differences.


SELECT p.name,
	   a.name,
	   p.price,
	   a.price
FROM play_store_grouped AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
WHERE CAST(REPLACE(p.price, '$', '') AS numeric) <> a.price
ORDER BY p.name;
*/



--Lets take a look at the ratings. First lets make a temp table to make viewing the results easier.

/*

CREATE TEMP TABLE combined_table AS
									SELECT 	p.name AS pname,
	   										a.name AS aname,
	   										p.rating AS prating,
	   										a.rating AS arating,
	   										p.size AS psize,
	   										a.size_bytes AS asize,
	   										p.price AS pprice,
	   										a.price AS aprice,
	   										p.content_rating AS pcontent_rating,
	   										a.content_rating AS acontent_rating,
	   										p.genres AS  pgenres,	   	
	   										a.primary_genre AS aprimary_genres
										
									FROM play_store_grouped AS p
									INNER JOIN app_store_apps AS a
									ON LOWER(p.name) = LOWER(a.name);

									
SELECT *
FROM combined_table;
*/



--cant compare playstore ratings because they are not rounded to nearest .5 or .0.
--WHERE rating::text NOT LIKE '%.0' AND				This way is will query exactly what i need.
--	  rating::text NOT LIKE '%.5';

/*
SELECT arating, prating
FROM combined_table;
*/


--Round playstore ratings so i can figure out the longevity. 
/*
ALTER TABLE play_store_grouped
ADD COLUMN rating_rounded numeric;





UPDATE play_store_grouped
SET rating_rounded = ROUND(ROUND(rating * 2, 0) / 2, 1);




SELECT rating_rounded
FROM play_store_grouped;


SELECT 	p.name,
		a.name,
		p.rating_rounded,
		a.rating,
		p.price,
		a.price,
		p.genres,
		a.primary_genre
FROM play_store_grouped AS p
INNER JOIN app_store_apps AS a
ON a.name = p.name
WHERE p.rating_rounded <> a.rating;

----------------------------- started over again. picked up at cleaning the price and rating columns for easier comparisons---

SELECT *
FROM play_store_group;


ALTER TABLE play_store_group
ADD price_clean numeric (5,2)


UPDATE play_store_group
SET price_clean = (REPLACE(price, '$', ''))::numeric (5, 2);

SELECT *
FROM play_store_group
ORDER BY price_clean DESC;

/*

CREATE TABLE playstore AS 
SELECT name, rating, size, type, price, content_rating, genres
FROM play_store_apps
GROUP BY name, rating, size, type, price, content_rating, genres;

 
ALTER TABLE playstore
ADD price_clean numeric;

UPDATE playstore
SET price_clean = CAST(REPLACE(price, '$', '') AS numeric);

SELECT *
FROM playstore
ORDER BY price_clean DESC;


ALTER TABLE playstore
ADD rating_rounded numeric;

UPDATE playstore
SET rating_rounded = ROUND((ROUND(rating * 2, 0) / 2), 1);


SELECT rating, rating_rounded
FROM playstore;



SELECT 	p.name,
		a.name,
		p.price_clean,
		a.price,
		p.rating_rounded,
		a.rating,
		p.genres,
		a.primary_genre,
		p.content_rating,
		a.content_rating
FROM playstore AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
ORDER BY p.name;


CREATE TABLE joined_tables AS
SELECT 	p.name AS play_name,
		a.name AS apple_name,
		p.price_clean AS play_price,
		a.price AS apple_price,
		p.rating_rounded AS play_rating,
		a.rating AS apple_rating,
		p.genres AS play_genres,
		a.primary_genre AS apple_genres,
		p.content_rating AS play_content_rating,
		a.content_rating AS apple_content_rating
FROM playstore AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
ORDER BY p.name;


SELECT *
FROM joined_tables;


ALTER TABLE joined_tables
ADD greater_price numeric,
ADD greater_rating numeric,
ADD longevity numeric,
ADD total_expense numeric,
ADD total_revenue numeric,
ADD total_profit numeric,
ADD purchase_price numeric;


UPDATE joined_tables
SET greater_price = CASE 	WHEN play_price > apple_price 
							THEN play_price 
							ELSE apple_price END;

UPDATE joined_tables
SET greater_rating = CASE 	WHEN play_rating > apple_rating 
							THEN play_rating 
							ELSE apple_rating END;
							

SELECT play_price, apple_price, greater_price, play_rating, apple_rating, greater_rating
FROM joined_tables
ORDER BY play_price DESC;



UPDATE joined_tables
SET longevity = CASE 	WHEN greater_rating = 0.5 THEN 24
						WHEN greater_rating = 1.0 THEN 36
						WHEN greater_rating = 1.5 THEN 48
						WHEN greater_rating = 2.0 THEN 60
						WHEN greater_rating = 2.5 THEN 72
						WHEN greater_rating = 3.0 THEN 84
						WHEN greater_rating = 3.5 THEN 96
						WHEN greater_rating = 4.0 THEN 108
						WHEN greater_rating = 4.5 THEN 120
						WHEN greater_rating = 5.0 THEN 132
						ELSE 12 END;

UPDATE joined_tables
SET purchase_price = CASE	WHEN greater_price >= 1.0 
							THEN greater_price * 10000
							ELSE 10000 END;

SELECT play_name, apple_name, play_price, apple_price, purchase_price, greater_rating, longevity
FROM joined_tables
ORDER BY play_price DESC;


UPDATE joined_tables
SET	total_expense = (longevity * 1000) + purchase_price,
	total_revenue = longevity * 5000


SELECT *
FROM joined_tables;


UPDATE joined_tables
SET total_profit = total_revenue - total_expense;
*/

SELECT *
FROM joined_tables
ORDER BY total_profit desc;



