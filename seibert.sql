-- How many rows are there in each app store? Play store = 10840 App store = 7197
/* 
SELECT COUNT(*) AS play_store_rows,
	(SELECT COUNT(*) AS app_store_rows
	FROM app_store_apps)
FROM play_store_apps;
*/

-- Does every row have a value for name? Yes.
/* 
SELECT count (*) - count (name) AS app_store_row_minus_name_count,
	(SELECT count(*) - count (name) AS play_store_row_minus_name_count
	FROM play_store_apps)
FROM app_store_apps;
*/

-- Are values for name unique in each store? 
-- No. Play store has a difference of 1181.
-- App store difference of 2.

/* 
SELECT count(name) - count(DISTINCT name)
FROM play_store_apps;
*/

/*
SELECT count(name) - count(DISTINCT name)
FROM app_store_apps;
*/

-- What do the rows that are the same look like?
-- App store has 2 apps, titled 'VR Roller Coaster' and 'Mannequin Challenge'
-- that have duplicates.
/*
SELECT name, COUNT(name)
FROM app_store_apps
GROUP BY name
ORDER BY count DESC;
*/

-- The query below indicates via substantial difference in app size and
-- content rating that the two versions of 'Mannequin Challenge' may
-- be two different apps. Each row of 'VR Roller Coaster' has similar
-- app size and content rating indicating that it may be a duplicate.

/* 
SELECT *
FROM app_store_apps
WHERE name = 'VR Roller Coaster'
	OR name ='Mannequin Challenge';
*/

-- The query below shows 9(!) rows for the title 'ROBLOX' and many duplicates of nearly 1000 apps.
/*
SELECT name, COUNT(name)
FROM play_store_apps
GROUP BY name
ORDER BY count DESC;
*/

-- A quick review of a couple of unique titles with many matches indicates via substantial similarity in
-- other fields that these two unique names have many duplicate rows in the table.
/*
SELECT *
FROM play_store_apps
WHERE name = 'ROBLOX'
	OR name ='8 Ball Pool'
ORDER BY name;
*/

-- Creating a temp table called play_store_grouped to put together all play store rows that have the same
-- name, rating, size, type, price, content_rating, and genre. I chose these fields to group because
-- they reference the assumptions in the project assignment README.md.
/*
CREATE TEMP TABLE play_store_grouped AS
	SELECT name, rating, size, type, price, content_rating, genres
	FROM play_store_apps
	GROUP BY name, rating, size, type, price, content_rating, genres;
*/

-- Viewing new temp table
/*
SELECT *
FROM play_store_grouped;
*/

-- Finding the difference of rows and unique names in the new temp table: 22

/* 
SELECT COUNT(*) - COUNT(DISTINCT name)
FROM play_store_grouped;
*/

-- What do the rows that remain duplicates in the play_store_grouped table look like?
-- Lots of generic app titles like 'Solitare', 'Call Blocker', and 'Ruler'.
/*
SELECT name, COUNT(name)
FROM play_store_grouped
GROUP BY name
ORDER BY count DESC;
*/

-- Taking a closer look at those apps show substaintial differences in size.
-- I think that each row in the play_store_grouped may now represent a unique
-- app, even if it doesn't have a unique name.
/*
SELECT *
FROM play_store_grouped
WHERE name = 'Solitaire' OR
	  name = 'Call Blocker' OR
	  name = 'Ruler'
ORDER BY name;
*/

-- Which apps are in both app stores?
-- Let's look at 'Solitaire' in both stores.
-- It doesn't seem clear to me that line 4, from the app_store_apps is the same
-- or different from any of the 3 solitaire apps from the play_store_grouped table, lines 1-3.
/*
SELECT name, rating, size, price, content_rating, genres
FROM play_store_grouped
WHERE name = 'Solitaire'
UNION
SELECT name, rating, size_bytes, currency, content_rating, primary_genre
FROM app_store_apps
WHERE name = 'Solitaire';
*/

-- What do the rows that have the same name in play_store_grouped and app_store_apps look like next to each other?
-- A quick review of all 331 apps that have the same name in app_store_apps and play_store_group
-- seem to show substainal similarities. Frequently apps will be in a similar genre/primary genre 
-- e.g. 'Travel & Local' and 'Travel'. Also apps that appear to be the same app in both stores will have similar
-- content_ratings e.g. 'Everyone' and '4+'. Apps that have very different ratings 'Everyone' vs '12+' seem
-- to have a fairly distinct title 'Allrecipes Dinner Spinner', Line 10 in below query. 'Teen' vs '17+' in 
-- 'BET NOW - Watch Shows', line 38. 'DIRECTV' and 'Discord - Chat for Gamers' in lines 65 and 66.
-- After reviewing the first half of the below query and finding substantial evidence for each app with a 
-- matching name being the same app in both stores (distinctive, case sensitive matching name, similar content_ratings,
-- similar genres/primary_genre, and/or similar prices) I'm completing the analysis with the assumption that names that are
-- the same between tables play_store_grouped and app_store_apps represent the same app. Going forward with only this
-- assumption will unfortunately exclude apps that are the same but have sightly different names in each database.
-- Without having a field for devoloper or company producing the app, I don't have a method of discovering these apps
-- without a very laborious process. This labor may be justified based on the extra value of purchasing an app that
-- is available in both stores. This will be computed in the final analysis.

/*
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
*/

-- Is the price the same for all matching apps in both stores? No. 30 apps have different prices. 7 apps are 0 and .99
-- meaning that the difference in price will have no effect in the analysis as the purchase price will be the same.
/*
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
*/

-- App longetivity is measured in ratings rounded to 1/2 points. The below query shows that app store
-- apps are already rounded.
/*
SELECT rating
FROM app_store_apps
WHERE rating::text NOT LIKE '%.0' AND
	  rating::text NOT LIKE '%.5';
*/
-- This query shows that play_store_grouped ratings are not rounded.
/*
SELECT rating
FROM play_store_grouped
WHERE rating::text NOT LIKE '%.0' AND
	  rating::text NOT LIKE '%.5';
*/

-- Adding a rounded column to my play_store_grouped temp table.
/*
ALTER TABLE play_store_grouped
ADD rating_rounded numeric;
*/

--Adding rounded values to new column in play_store_grouped.
/*
UPDATE play_store_grouped
SET rating_rounded = ROUND(ROUND(rating * 2, 0) / 2, 1);
*/

-- Where does app_store_apps and play_store_grouped have different ratings after the round has been applied?
-- 143 rows. Going forward I will use the greater of the two ratings to determine the longevity of the app.
/*
SELECT p.name,
	   a.name,
	   p.rating_rounded,
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
AND p.rating_rounded <> a.rating
ORDER BY p.name;
*/

-- Making my play_store_grouped temp table a more permenant table with the title play_store_group
/*
SELECT *
INTO play_store_group
FROM play_store_grouped;
*/

-- Play store stored app prices as text, making them numeric in a new column so that prices can be compared.
-- adding column.
/*
ALTER TABLE play_store_group
ADD price_clean numeric (5, 2);
*/

-- Testing a select statement to modify the play_store_group price data.
/*
SELECT (REPLACE(price, '$', ''))::numeric (5, 2) AS price_clean
FROM play_store_group
ORDER BY price_clean DESC;
*/

-- Testing data cleaning and migration in a temp table, creating temp table with data:
/*
CREATE TEMP TABLE play_store_price_test AS
	SELECT name, price, price_clean
	FROM play_store_group;
*/

--Viewing temp table
/*
SELECT *
FROM play_store_price_test;
*/

-- Checking the conversion of prices in temp table
/*
UPDATE play_store_price_test
SET price_clean = (REPLACE(price, '$', ''))::numeric (5, 2);
*/
/*
SELECT price, price_clean
FROM play_store_price_test
ORDER BY price_clean DESC;
*/

-- Okay, that worked for updating the price. Modifying play_store_group
/*
UPDATE play_store_group
SET price_clean = (REPLACE(price, '$', ''))::numeric (5, 2);
*/

-- Profit = Revenue - Cost. Revenue is 10000/month * app longevity (in months). Cost is (price of app *10,000 with
-- a 10,000 minimum) + (1000 * app longevity) (in months). Showing name, greater price between app stores
-- greater rating between stores, primary_genre, content_rating, calculating purchase price (greater app price*10,000, min 10000),
-- months of longevity (((greater app rating*2)+1)*12 min 12), expected revenue (months of longevity * 10000),
-- expected cost (purchase price + (months of longevity*1000)) and profit (revenue - cost).
-- Sorted by expected profit, high to low.
/*
SELECT a.name,
	   CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END AS greater_price,
	   CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END AS greater_rating,
	   a.primary_genre,
	   a.content_rating,
	   CASE WHEN (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) <= 1 THEN 10000
	   	ELSE (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) * 10000 END AS purchase_price_of_app,
	   CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END AS months_of_longevity,
	   CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *10000 AS expected_revenue,
	   CASE WHEN (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) <= 1 THEN 10000
	   	ELSE (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) * 10000 END + 
	    CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *1000 AS expected_cost,
	   (CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *10000) -
			(CASE WHEN (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) <= 1 THEN 10000
	   	ELSE (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) * 10000 END + 
	    CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *1000) AS expected_profit
FROM app_store_apps AS a
INNER JOIN play_store_group AS p
ON a.name = p.name
ORDER BY expected_profit DESC;
*/

-- Creating a new table with these columns and rows:
/*
CREATE TABLE joined_stores_profit AS
SELECT a.name,
	   CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END AS greater_price,
	   CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END AS greater_rating,
	   a.primary_genre,
	   a.content_rating,
	   CASE WHEN (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) <= 1 THEN 10000
	   	ELSE (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) * 10000 END AS purchase_price_of_app,
	   CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END AS months_of_longevity,
	   CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *10000 AS expected_revenue,
	   CASE WHEN (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) <= 1 THEN 10000
	   	ELSE (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) * 10000 END + 
	    CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *1000 AS expected_cost,
	   (CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *10000) -
			(CASE WHEN (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) <= 1 THEN 10000
	   	ELSE (CASE WHEN a.price > p.price_clean THEN a.price ELSE p.price_clean END) * 10000 END + 
	    CASE WHEN (CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END) = 0 THEN 12
	   	ELSE (((CASE WHEN a.rating > p.rating_rounded THEN a.rating ELSE p.rating_rounded END)*2) + 1)*12 END *1000) AS expected_profit
FROM app_store_apps AS a
INNER JOIN play_store_group AS p
ON a.name = p.name
ORDER BY expected_profit DESC;
*/


-- Can any apps that are only on one store match or exceed the expected profits of the top 194 of 331 that are on both stores (>=1070000)?
-- Treating null values in the play_store_group as 0. Query below shows no. Greatest expected_profit of an app not in both app stores is
-- 518000. This same calculation would be true for both stores individually, and these results make sense. If the only difference
-- is a greater revenue without a greater cost then apps on both stores are a much better place to start.

/*
SELECT p.name,
	   p.rating_rounded, 
	   p.price_clean, 
	   p.genres,
	   CASE WHEN p.price_clean <= 1 THEN 10000
	   	ELSE p.price_clean * 10000 END AS purchase_price_of_app,
	   CASE WHEN p.rating_rounded IS NULL THEN 12
	   	ELSE ((p.rating_rounded*2) + 1)*12 END AS months_of_longevity,
	   (CASE WHEN p.rating_rounded IS NULL THEN 12
	   	ELSE ((p.rating_rounded*2) + 1)*12 END) *5000 AS expected_revenue,
	   (CASE WHEN p.price_clean <= 1 THEN 10000
	   	ELSE p.price_clean * 10000 END) + (CASE WHEN p.rating_rounded IS NULL THEN 12
	   	ELSE ((p.rating_rounded*2) + 1)*12 END)*1000 AS expected_cost,
	   ((CASE WHEN p.rating_rounded IS NULL THEN 12
	   	ELSE ((p.rating_rounded*2) + 1)*12 END) *5000) -
			((CASE WHEN p.price_clean <= 1 THEN 10000
	   	ELSE p.price_clean * 10000 END) + (CASE WHEN p.rating_rounded IS NULL THEN 12
	   	ELSE ((p.rating_rounded*2) + 1)*12 END)*1000) AS expected_profit
FROM play_store_group as p
LEFT JOIN app_store_apps as a
ON p.name = a.name
WHERE a.name IS NULL
ORDER BY expected_profit DESC;
*/

-- Does content rating or genera cluster in a way that might help make a decision? Average expected profit grouped by
-- primary genre doesn't show a huge difference between the largest avg (1070000) and the smallest (826100)
-- This indicates to me that genera might not be an efficient metric to purchase apps on.
/*
SELECT primary_genre, AVG(expected_profit)
FROM joined_stores_profit
GROUP BY primary_genre
ORDER BY avg DESC;
*/

--What about content rating? Averages here were even more similar, 1305695 for the highest and 1025204.
/*
SELECT content_rating, AVG(expected_profit)
FROM joined_stores_profit
GROUP BY content_rating
ORDER BY avg DESC;
*/


-- General recommendations: An app that costs 9.99 and has a 4.5 rating has better expected profits than a free app with a 4.0 rating.
-- The company should focus on high ratings (5.0 and 4.5) and choose low cost apps within those high ratings.
-- Neither content rating nor genre seem to be logical groups to chose an app to market.

-- Top 10 apps for Black Friday: Fernanfloo, The Guardian, Geometry Dash Lite, PewDiePie's Tuber Simulator, ASOS, Egg, Inc.,
-- Domino's Pizza USA, Cytus, H*nest Meditation, and The EO Bar.
/*
SELECT name
FROM joined_stores_profit
ORDER BY expected_profit DESC
LIMIT 10;
*/

-- The below query shows 9 apps that have differences in case between names. None of these
-- have a 5 star rating so they won't effect the top 10 list.
/*
SELECT p.name, a.name, p.price_clean, a.price, p.rating_rounded, a.rating
FROM play_store_group AS p
INNER JOIN app_store_apps AS a
ON LOWER(p.name) = LOWER(a.name)
WHERE p.name <> a.name;
*/
