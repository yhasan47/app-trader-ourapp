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
FROM app_store_apps
ORDER BY genres;
*/
