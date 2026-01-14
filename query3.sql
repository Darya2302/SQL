--Output the category of movies on which the most money was spent.

SELECT  name, sum(replacement_cost) as total_cost
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
GROUP BY name
ORDER BY total_cost DESC
LIMIT 1
;