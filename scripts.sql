-- The database has two table: app_store_apps and play_store_apps

-- 1.	What are the name of the tables in the database?

SELECT table_name 
FROM information_schema.tables
WHERE table_schema = 'public';

-- 2.	How many apps are in the Apple app store? How many apps are in the Android app store?

SELECT COUNT (*)
FROM app_store_apps	Result: 7197

SELECT COUNT (*)
FROM play_store_apps	Result: 10840

-- 3.	How many apps are duplicated in the app store? How many apps are duplicated in the play store?

SELECT COUNT(name) - COUNT(DISTINCT name) AS duplicate_apps
FROM app_store_apps;		Result: 2

SELECT COUNT(name) - COUNT(DISTINCT name) AS duplicate_apps
FROM play_store_apps;		Result: 1181

-- 4.	Which apps in the app store and play store are duplicated and how many times are they duplicated? 

SELECT name, COUNT(name) 
FROM app_store_apps
GROUP BY name
HAVING COUNT(name) > 1
ORDER BY COUNT DESC

SELECT name, COUNT(name) 
FROM play_store_apps
GROUP BY name
HAVING COUNT(name) > 1
ORDER BY count DESC


-- 5.	Create a table to change the price value that's in text into numeric form. 

SELECT 
	DISTINCT name, 
	CAST(REPLACE(price,'$','') AS numeric(5,2)) AS price, 
	rating,
	review_count, 
	content_rating, 
	genres AS genre
	INTO play_store_price_fix
	FROM play_store_apps;
	
-- 6.	What are the prices of the apps in both tables?

SELECT DISTINCT price
FROM app_store_apps
ORDER BY price

SELECT DISTINCT price
FROM play_store_apps
ORDER BY price

SELECT  p.name, a.name, p.genres, a.primary_genre, p.price, a.price, p.content_rating, a.content_rating
FROM play_store_apps AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
ORDER BY p.price DESC;


/* Creating a temp table called play_store_grouped to put together all play store rows that 
have the same name, rating, size, type, price, content_rating, and genre. */ 

CREATE TEMP TABLE play_store_grouped AS
	SELECT name, rating, size, type, price, content_rating, genres
	FROM play_store_apps
	GROUP BY name, rating, size, type, price, content_rating, genres;
	
-- Finding the difference of rows and unique names in the new temp table: 22

/* 
SELECT COUNT(*) - COUNT(DISTINCT name)
FROM play_store_grouped;


-- 7.	How many apps in the app store have a price of 0 and rating of 5?

SELECT COUNT (DISTINCT name)
FROM app_store_apps
WHERE price = 0 AND rating = 5;

-- 8.	How many different genres are there in the app store? Play store?

SELECT DISTINCT primary_genre
FROM app_store_apps

SELECT DISTINCT genres
FROM play_store_apps

-- 9.	What are some free apps that have a rating of 5 in the Apple app store? 

SELECT name, price, rating
    FROM app_store_apps
    WHERE price = (SELECT MIN(price) FROM app_store_apps)
	AND rating = 5
	ORDER BY rating


-- 10.	What are some of the lowest priced apps from the Android app store with a rating of 5? 

SELECT name, price, rating
    FROM play_store_apps
    WHERE price = (SELECT MIN(price) FROM play_store_apps)
     AND rating = 5
     ORDER BY rating

-- 11.	What are some apps from the Apple app store that are priced at either 0.99 cents or lower and have a rating of 5? 

SELECT *
FROM app_store_apps
WHERE rating = 5.0 
AND primary_genre LIKE 'Education'
AND price <=0.99
ORDER BY rating DESC
LIMIT 100;


-- 12.	Which apps from the app_store_apps have a price of 0 or 0.99 cent and are rated 5?

SELECT *
FROM app_store_apps
WHERE (price = 0 OR price = 0.99)
AND rating = 5

-- 13.	How many apps are in both app stores?

SELECT COUNT (apple.name)
FROM app_store_apps AS apple
LEFT JOIN play_store_apps AS android
ON android.name = apple.name

--14.	Is the price the same for all matching apps in both stores?

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
AND CAST(REPLACE(p.price, '$', '') AS numeric) <> a.price
ORDER BY p.name;

-- 15.	What are some different content ratings in the app store? And play store apps?

SELECT DISTINCT content_rating
FROM app_store_apps
ORDER BY content_rating

SELECT DISTINCT content_rating
FROM play_store_apps
ORDER BY content_rating




