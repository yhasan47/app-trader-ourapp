SELECT a.primary_genre, p.name, a.name, p.genres, p.price, a.price, p.content_rating, a.content_rating
FROM play_store_apps AS p
INNER JOIN app_store_apps AS a
ON p.name = a.name
WHERE a.primary_genre = 'Business'
ORDER BY a.primary_genre;      