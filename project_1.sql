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



Looking at some of the dupes. They look like different apps made by different companies. 
So I will keep them in the table.



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



Join the tables.



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


lets take a look at the prices. There is a $ in the playstore, making it a text attribute, so i cant do a comparison. 
I have to convert to numeric attribute to make the columns compareable.
30 apps have different prices.
where there is a difference in price, looks like apple is the higher of the two.
no major differences.


SELECT p.name,
	   a.name,
	   p.price,
	   a.price
FROM play_store_grouped AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
WHERE CAST(REPLACE(p.price, '$', '') AS numeric) <> a.price
ORDER BY p.name;




Lets take a look at the ratings. First lets make a temp table to make viewing the results easier.

*/

CREATE TEMP TABLE combined_table
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
									ON p.name = a.name;
									


