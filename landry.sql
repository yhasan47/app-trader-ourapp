/*
	AppTrader Group Assignment: OurApp
	Landry's SQL File

	This database has two tables:
	 - app_store_apps has 7197 rows with header
	 - play_store_apps has 10840 rows with header
*/

/***********************************************************
BEGIN DISCOVERY
	Look in these tables, what's there?
	How is it organized?
	How do the two tables compare to each other in design?
************************************************************/

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

	/** Copy relevant AppStore info into new table **/
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

		SELECT *
		FROM play_store_apps;

	/** Copy relevant PlayStore info into new table **/
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

	/** This query recasts the AppStore price as a float **/
		SELECT CAST(REPLACE('$4.99','$','') AS float);

/** Combine clean app files **/
	SELECT subquery.*
	INTO combined_apps
	FROM 			
		(SELECT * 
		FROM app_store_clean AS a
		UNION
		SELECT *
		FROM play_store_clean AS p) AS subquery;

/** Verify relevant info is in combined table **/
	SELECT * 
	FROM combined_apps
	ORDER BY price DESC;
	
	-- YES, this works
	
	
	
	

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

				  
				  

