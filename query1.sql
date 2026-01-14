--Output the number of movies in each category, sorted descending.

SELECT name, count(film.film_id) AS film_count
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
GROUP BY name
ORDER BY film_count DESC
;
