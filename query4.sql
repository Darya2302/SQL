--Print the names of movies that are not in the inventory. Write a query without using the IN operator.

SELECT title
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
WHERE inventory IS NULL
;