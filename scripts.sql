/* 1.	How many apps are in the Apple app store? How many apps are in 
the Android app store? */

SELECT COUNT (*)
FROM app_store_apps	Result: 7197

SELECT COUNT (*)
FROM play_store_apps	Result: 10840

/* 2.	What are some free apps that have a rating of 5 in the Apple 
app store? */

SELECT name, price, rating
    FROM app_store_apps
    WHERE price = (SELECT MIN(price) FROM app_store_apps)
	AND rating = 5
	ORDER BY rating


/* 3.	What are some of the lowest priced apps from the Android app 
store with a rating of 5? */

SELECT name, price, rating
    FROM play_store_apps
    WHERE price = (SELECT MIN(price) FROM play_store_apps)
     AND rating = 5
     ORDER BY rating

/* 4.	What are some apps from the Apple app store that are priced at 
either 0.99 cents or lower and have a rating of 5? */

SELECT *
FROM app_store_apps
WHERE rating = 5.0 
AND primary_genre LIKE 'Education'
AND price <=0.99
ORDER BY rating DESC
LIMIT 100;


/* 5.	Which apps from the app_store_apps have a price of 0 or 0.99 cent 
and are rated 5? */ 

SELECT *
FROM app_store_apps
WHERE (price = 0 OR price = 0.99)
AND rating = 5

-- 6.	How many apps are in both app stores? 

SELECT COUNT (apple.name)
FROM app_store_apps AS apple
LEFT JOIN play_store_apps AS android
ONE android.name = apple.name

-- 7.	What are the prices of the apps in both tables?

SELECT p.price, p.name AS play_store, a.price, a.name AS app_store
FROM play_store_apps AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
ORDER BY a.price DESC;
