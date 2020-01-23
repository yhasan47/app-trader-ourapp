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
		LEFT JOIN play_store_apps AS android
		ON android.name = apple.name;

	/** Display the apps that are in both databases **/
		SELECT *
		FROM app_store_apps AS apple
		LEFT JOIN play_store_apps AS android
		ON android.name = apple.name;

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

				  
				  

