/*
	AppTrader Group Assignment: OurApp
	Landry's SQL File

	This database has two tables:
	 - app_store_apps has 7197 rows with header
	 - play_store_apps has 10840 rows with header
*/

/***********************************************************
BEGIN SETUP QUERIES
	Put the final queries here at top of file for easier review
************************************************************/
/** Copy relevant PlayStore info into clean table 
	- DISTINCT name
	- price (cast as numeric to match AppStore)
	- rating
	- review_count
	- content_rating (do we need this?)
	- genre
**/

DROP TABLE play_store_clean; 

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
DROP TABLE app_store_clean;

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

	SELECT COUNT(name) AS num_apps,
	COUNT(name) - COUNT(DISTINCT name) AS num_duplicates,
	(SELECT name FROM app_store_clean)
	FROM app_store_clean;

/** Combine both 'clean' tables into combined_apps table 
	- DISTINCT name
	- price
	- rating (rounded to nearest .5)
	- genre
	- content rating (convert to common ratings terms?)
**/
	
/**	Building the query to combine the files **/

	/** NOTE: this UNION is the wrong thing here. Use INNER JOIN
		to create the combined table
		SELECT * 
		FROM app_store_clean AS a
		UNION
		SELECT *
		FROM play_store_clean AS p
		ORDER BY name;

		SELECT subquery.*
		INTO combined_apps
		FROM 			
			(SELECT * 
			FROM app_store_clean AS a
			INNER JOIN play_store_clean AS p 
			ON a.name = p.name) AS subquery;
	**/

	SELECT * 
	FROM app_store_clean AS a
	INNER JOIN play_store_clean AS p 
	ON a.name = p.name;


DROP TABLE combined_apps;
/**	Combine the files **/
	CREATE TABLE combined_apps AS
	--	NOTE: SELECT statement needs to sort and combine columns
	SELECT a.name,
		CASE WHEN a.price > p.price THEN a.price 
			ELSE p.price END AS price,
		CASE WHEN a.rating > p.rating THEN a.rating 
			ELSE p.rating END AS rating,
		a.genre,
		a.content_rating
	FROM app_store_clean AS a
	INNER JOIN play_store_clean AS p 
	ON a.name = p.name;
	

/** CHECKPOINT **********************************/
/***********************************************/
/***********************************************/
/** Verify relevant info is in combined table **/
	SELECT * 
	FROM combined_apps
	ORDER BY name;

/**	Add columns and calculate values for 
	- base_cost = 10000 minimum
	- purchase_cost = if price < 1 then 10000 else (price * 10000)
	- advertising_cost = 1000 * projected_lifespan
	- projected_revenue = (10000 * projected_lifespan) - 
		(purchase_cost + advertising_cost)
	- projected_lifespan (in months) = (rating*2)+1)*12
		- initial lifespan is one year
		- for each 1/2 point increase in rating, lifespan increases
		  by 
**/
	ALTER TABLE combined_apps
		ADD rating_rounded numeric(2,1),
		ADD purchase_cost numeric(9,2),
		ADD advertising_cost numeric(9,2),
		ADD projected_revenue numeric(9,2),
		ADD projected_lifespan int;
		
/**	Round off rating values to nearest 0.5 in combined_apps */
	UPDATE combined_apps
		SET rating_rounded = ROUND(ROUND(rating * 2, 0) / 2, 1);
	
--	Calculate purchase_cost = if price < 1 then 10000 else (price * 10000)
	SELECT price,
		CASE WHEN price >= 1 THEN CAST(10000 * price AS int)
		ELSE 10000
		END AS purchase_cost
	FROM combined_apps;

/**	update purchase_cost in combined_apps */
	UPDATE combined_apps
	SET purchase_cost = CASE WHEN price >= 1 THEN 
		10000 * price
		ELSE 10000 END;

/**	Calculate lifespan in months
	- lifespan = 12
	- FOR EACH .5 OF rating, lifespan += 12
**/
	SELECT name, rating_rounded,
		CASE 
			WHEN rating_rounded = 1 THEN 24
			WHEN rating_rounded = 1.5 THEN 36
			WHEN rating_rounded = 2 THEN 60
			WHEN rating_rounded = 2.5 THEN 72
			WHEN rating_rounded = 3 THEN 84
			WHEN rating_rounded = 3.5 THEN 96
			WHEN rating_rounded = 4 THEN 108
			WHEN rating_rounded = 4.5 THEN 120
			WHEN rating_rounded = 5 THEN 132
			ELSE 12
			END AS lifespan
	FROM combined_apps;

/**	update lifespan in combined_apps **/
	UPDATE combined_apps
	SET projected_lifespan = 
		CASE 
			WHEN rating_rounded = 1 THEN 24
			WHEN rating_rounded = 1.5 THEN 36
			WHEN rating_rounded = 2 THEN 60
			WHEN rating_rounded = 2.5 THEN 72
			WHEN rating_rounded = 3 THEN 84
			WHEN rating_rounded = 3.5 THEN 96
			WHEN rating_rounded = 4 THEN 108
			WHEN rating_rounded = 4.5 THEN 120
			WHEN rating_rounded = 5 THEN 132
			ELSE 12 END;

--	Calculate advertising_cost = 1000 * projected_lifespan  
	SELECT name, projected_lifespan,
		projected_lifespan * 1000 AS advertising_cost
	FROM combined_apps;

--	Update advertising_cost in combined_apps
	UPDATE combined_apps
	SET advertising_cost = projected_lifespan * 1000;

--	Calculate projected_revenue = 10000 * projected_lifespan  
	SELECT name, projected_lifespan,
		(projected_lifespan * 10000) - (purchase_cost + advertising_cost)
		AS projected_revenue
	FROM combined_apps;

--	Update projected_revenue in combined_apps
	UPDATE combined_apps
	SET projected_revenue = 
		(projected_lifespan * 10000) - (purchase_cost + advertising_cost);

/** CHECKPOINT **********************************/
/***********************************************/
/***********************************************/
/** Verify relevant info is in combined table.

	Now that the combined table is fully populated, we can start
	looking deeper to see what's inside.
**/
	SELECT * 
	FROM combined_apps
	ORDER BY name;

/***********************************************************
BEGIN DISCOVERY
	Look in the combines table, what's there?
	How is it organized?
************************************************************/

--	Look at top ten apps by projected revenue
	SELECT * 
	FROM combined_apps
	ORDER BY projected_revenue DESC
	LIMIT 10;

--	Look at top ten apps by rating
	SELECT * 
	FROM combined_apps
	WHERE rating IS NOT NULL
	ORDER BY rating DESC
	LIMIT 10;

--	Look at top ten apps by rating
	SELECT * 
	FROM combined_apps
	ORDER BY projected_revenue DESC, genre 
	LIMIT 10;

--	There are quite a few apps with 5.0 rating.
	SELECT DISTINCT COUNT(rating_rounded) AS num_top_rating
	FROM combined_apps
	WHERE rating_rounded = 5.0;
	
/** There are 1078 apps with a 5.0 rating. 
	These apps have the longest lifespan and potentially the
		highest potential revenue. Look at them.
	They are all priced at $1 or less and have 5.0 ratings,
		definitely potential candidates for top ten list.
	Copy them into top_ten_candidates table
**/
--	Setup subquery
	SELECT DISTINCT * 
	FROM combined_apps
	WHERE rating_rounded = 5.0
	ORDER BY projected_revenue DESC;
	
--	Copy them into top_ten_candidates table
	SELECT subquery.*
	INTO top_ten_candidates
	FROM 			
		(SELECT DISTINCT * 
			FROM combined_apps
			WHERE rating_rounded = 5.0) AS subquery;

--	Verify relevant info is in top_ten_candidates table.
	SELECT * 
	FROM top_ten_candidates
	ORDER BY projected_revenue DESC;
	
	

-- Count dupes: there are quite a few. Will this affect deliverables?
	SELECT COUNT(name) AS num_apps,
	COUNT(name) - COUNT(DISTINCT name) AS num_duplicates
	FROM top_ten_candidates;



/**	NOTE 

**/


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
		- purchase_cost
		- advertising_cost
		- projected_revenue
		- projected_lifespan
	
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
	
*/
	

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

				  
				  

