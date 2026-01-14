--Output the top 3 actors who have appeared the most in movies in the “Children” category. If several actors have the same number of movies, output all of them.

WITH actor_counts AS (
SELECT actor.actor_id, actor.first_name, actor.last_name, count(film_actor.film_id) AS count_film, DENSE_RANK() OVER (ORDER BY COUNT(film_actor.film_id) DESC) AS rank
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film_category ON film_actor.film_id = film_category.film_id 
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Children'
GROUP BY actor.actor_id, first_name, last_name
)
SELECT actor_id, first_name, last_name, count_film
FROM actor_counts
WHERE rank <= 2
ORDER BY count_film DESC
;