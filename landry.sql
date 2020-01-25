/*
	AppTrader Group Assignment: OurApp
	Landry's SQL File

	This database has two tables:
	 - app_store_apps has 7197 rows with header
	 - play_store_apps has 10840 rows with header
*/

/***********************************************************
BEGIN FINAL QUERIES
	Put the final queries here at top of file for easier review
************************************************************/

/***********************************************************
END FINAL QUERIES
************************************************************/

/*********************************************************** 
NOTES
	Final File Content: final combined_apps table should like this:
		- name (filter out duplicates)
		- price 
		- rating (rounded to nearest .5)
		- genre
		- content rating (convert to common ratings)
		- projected monthly revenue
		- projected lifespan
	
	Content Ratings equivalances between stores. Convert Apple rating
	to Play rating.
		Play Store				Apple Store
		Unrated
		Everyone					4+
		Everyone 10+				9+
		Teen						12+
		Mature 17+					17+
		Adults only 18+
************************************************************/


/***********************************************************
BEGIN DISCOVERY
	Look in these tables, what's there?
	How is it organized?
	How do the two tables compare to each other in design?
************************************************************/

/** clean up the data 
	Using 'Instagram' as a test case, it seems that there are
	quite a few duplicates in the play_store_apps table
**/
	SELECT *
	FROM play_store_apps
	WHERE name = 'Instagram';

	SELECT COUNT(name) AS num_apps,
	COUNT(name) - COUNT(DISTINCT name) AS num_duplicates
	FROM play_store_apps;
	
--	There are 1181 duplicates in the database. 
--	These will need to be filtered out

/** Copy relevant PlayStore info into clean table 
	- DISTINCT name
	- price (cast as numeric to match AppStore)
	- rating
	- review_count
	- content_rating (do we need this?)
	- genre
**/

--	DROP TABLE play_store_clean; 

	SELECT 
		DISTINCT name, 
		CAST(REPLACE(price,'$','') AS numeric(5,2)) AS price, 
		rating,
		review_count, 
		content_rating, 
		genres AS genre
	INTO play_store_clean
	FROM play_store_apps;

/** Verify relevant PlayStore info is in new table **/
	SELECT * 
	FROM play_store_clean
	ORDER BY name;

--	DEBUGDEBUG: for some reason, there are still 690 duplicates.
--	Come back to this
	SELECT COUNT(name) AS num_apps,
	COUNT(name) - COUNT(DISTINCT name) AS num_duplicates
	FROM play_store_clean;

/** Copy relevant AppStore info into new table 
	- DISTINCT name
	- price
	- rating
	- review_count (cast as numeric to match PlayStore)
	- content_rating (do we need this?)
	- genre
**/
--	DROP TABLE app_store_clean;

	SELECT 
		DISTINCT name, 
		price,
		rating,
		CAST(review_count AS int), 
		content_rating, 
		primary_genre AS genre
	INTO app_store_clean
	FROM app_store_apps;

/** Verify relevant AppStore info is in new table **/
	SELECT * 
	FROM app_store_clean
	ORDER BY name;

--	DEBUGDEBUG: for some reason, there are still 2 duplicates.
--	Come back to this
	SELECT COUNT(name) AS num_apps,
	COUNT(name) - COUNT(DISTINCT name) AS num_duplicates
	FROM app_store_clean;

/** Combine both 'clean' tables into combined_apps table 
	- DISTINCT name
	- price
	- rating (rounded to nearest .5)
	- genre
	- content rating (convert to common ratings terms?)
**/
	
-- Building the subquery to combine the files
	SELECT * 
	FROM app_store_clean AS a
	UNION
	SELECT *
	FROM play_store_clean AS p
	ORDER BY name;


DROP TABLE combined_apps;
	
	SELECT subquery.*
	INTO combined_apps
	FROM 			
		(SELECT * 
		FROM app_store_clean AS a
		UNION
		SELECT *
		FROM play_store_clean AS p) AS subquery;





	/** How many apps are in both databases? 
	553 or 7422 depending on JOIN or LEFT JOIN.
	Which is correct? **/

		SELECT COUNT(apple.name)
		FROM app_store_apps AS apple
		INNER JOIN play_store_apps AS android
		ON android.name = apple.name;

	/** Display the apps that are in both databases **/
		SELECT *
		FROM app_store_apps AS apple
		INNER JOIN play_store_apps AS android
		ON LOWER(android.name) = LOWER(apple.name);

	/** Display app_store_apps by price DESC **/
		SELECT name, price, content_rating, primary_genre
		FROM app_store_apps AS apple
		ORDER BY price DESC;

	/** What content ratings used in app_store_apps?
		4+
		9+
		12+
		17+
	**/
		SELECT DISTINCT content_rating
		FROM app_store_apps
		ORDER BY content_rating DESC;

	/** What content ratings used in play_store_apps?
		"Unrated"
		"Teen"
		"Mature 17+"
		"Everyone 10+"
		"Everyone"
		"Adults only 18+"
	**/
		SELECT DISTINCT content_rating
		FROM play_store_apps
		ORDER BY content_rating DESC;

	/** Content Ratings equivalances?
		Play Store				Apple Store
		Unrated
		Everyone					4+
		Everyone 10+				9+
		Teen						12+
		Mature 17+					17+
		Adults only 18+
	**/

	/** Count duplicates in both databases **/
		SELECT COUNT (*), COUNT(DISTINCT name),
		COUNT (*) - COUNT(DISTINCT name) AS num_duplicates
		FROM app_store_apps AS apple;
		-- 2 duplicates in app_store_apps
		
		SELECT COUNT (*), COUNT(DISTINCT name),
		COUNT (*) - COUNT(DISTINCT name) AS num_duplicates
		FROM play_store_apps AS android;
		-- 1181 duplicates in play_store_apps



	/** This query recasts the AppStore price as a float **/
	--	SELECT CAST(REPLACE('$4.99','$','') AS float);

/** Combine clean app files **/

/* This query works but it includes duplicate names and NULL ratings
	SELECT subquery.*
	INTO combined_apps
	FROM 			
		(SELECT * 
		FROM app_store_clean AS a
		UNION
		SELECT *
		FROM play_store_clean AS p) AS subquery
	WHERE a.name = p.name;
*/
	/** Display the apps that are in both clean databases **/
		SELECT DISTINCT *
		FROM app_store_clean AS a
		INNER JOIN play_store_clean AS p
		ON LOWER(a.name) = LOWER(p.name);


/** Verify relevant info is in combined table **/
	SELECT * 
	FROM combined_apps
	WHERE rating IS NOT NULL
	ORDER BY name;
	
	-- YES, this works.
	
	

/** NOTE THESE WILL DROP NEW TABLES **/
--DROP TABLE play_store_clean;
--DROP TABLE app_store_clean;
--DROP TABLE combined_apps;

/***********************************************************
END DISCOVERY
************************************************************/

/* DEBUG DEBUG: These queries don't work

SELECT name, price, content_rating, primary_genre
FROM app_store_apps AS apple
UNION
SELECT name, CAST(price AS numeric(5,2)), content_rating, genres
FROM play_store_apps AS android;


SELECT name, price, content_rating, primary_genre
FROM app_store_apps AS apple
UNION
SELECT name, price, content_rating, genres
FROM play_store_apps AS android;
*/		  

/***********************************************************
DELIVERABLES
	Develop some general recommendations as to price range, genre, 
	content_rating for apps that the company should target.
	
	Develop a Top 10 List of the apps that App Trader should buy 
	next week for its Black Friday debut.
	
	Prepare a 5-10 minute presentation for the leadership team of 
	App Trader.
************************************************************/

				  
				  

