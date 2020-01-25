/*
	AppTrader Group Assignment: OurApp
	Landry's SQL File

	This database has two tables:
	 - app_store_apps has 7197 rows with header
	 - play_store_apps has 10840 rows with header
*/

/***********************************************************
BEGIN SETUP QUERIES
	Set up the data for easier review
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
	SELECT DISTINCT a.name,
		CASE WHEN a.price > p.price THEN a.price 
			ELSE p.price END AS price,
		CASE WHEN a.rating > p.rating THEN a.rating 
			ELSE p.rating END AS rating,
		a.genre,
		a.content_rating
	FROM app_store_clean AS a
	INNER JOIN play_store_clean AS p 
	ON LOWER(a.name) = LOWER(p.name);
	

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
/** Verify relevant info is in combined table. **/
	SELECT * 
	FROM combined_apps
	ORDER BY name;

--	Look at top 20 apps by projected_revenue and rating
	SELECT * 
	FROM combined_apps
	ORDER BY projected_revenue DESC, rating_rounded 
	LIMIT 20;
	
/** There are 10 apps with a 5.0 rating. 
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
	
DROP TABLE top_ten_candidates;
--	Create top_ten_candidates table
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
	


/***********************************************************
DISCOVERY
	Look in the top_ten_candidates table, what's there?
************************************************************/
	
	SELECT * 
	FROM top_ten_candidates
	ORDER BY projected_revenue DESC;

/***********************************************************
DELIVERABLES
	Develop some general recommendations as to price range, genre, 
	content_rating for apps that the company should target.
	
	Develop a Top 10 List of the apps that App Trader should buy 
	next week for its Black Friday debut.
	
	Prepare a 5-10 minute presentation for the leadership team of 
	App Trader.
	
	Top Ten Results
	- all apps have 5.0 rating
	- most apps are free to download
	- game genre is most popular BUT a news app is more popular 
		than all other apps
	
	General Recommendations
	- Purchase the apps with 5.0 recommendation
	- 
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


				  
				  

