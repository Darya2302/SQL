--Output the number of movies in each category, sorted descending.

SELECT name, count(film.film_id) AS film_count
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
GROUP BY name
ORDER BY film_count DESC
;


--Output the 10 actors whose movies rented the most, sorted in descending order.

SELECT actor.actor_id, first_name, last_name, count(rental_id) AS rental_count
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY actor.actor_id
ORDER BY rental_count DESC
LIMIT 10
;


--Output the category of movies on which the most money was spent.

SELECT  name, sum(amount) as total_cost
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.store_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY total_cost DESC
LIMIT 1
;


--Print the names of movies that are not in the inventory. Write a query without using the IN operator.

SELECT title
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
WHERE inventory_id IS NULL
;


--Output the top 3 actors who have appeared the most in movies in the “Children” category. If several actors have the same number of movies, output all of them.

WITH actor_counts AS (
SELECT actor.actor_id, actor.first_name, actor.last_name, count(film_actor.film_id) AS count_film, ROW_NUMBER() OVER (ORDER BY COUNT(film_actor.film_id) DESC) AS row
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film_category ON film_actor.film_id = film_category.film_id 
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Children'
GROUP BY actor.actor_id, first_name, last_name
)

SELECT actor_id, first_name, last_name, count_film
FROM actor_counts
WHERE count_film >= (SELECT count_film FROM actor_counts WHERE row = 3)
ORDER BY count_film DESC
;


--Output cities with the number of active and inactive customers (active - customer.active = 1). Sort by the number of inactive customers in descending order.

SELECT city.city_id, city, count(CASE WHEN customer.active = 1 THEN customer.customer_id END) AS active_customers,
count(CASE WHEN customer.active = 0 THEN customer.customer_id END) AS inactive_customers
FROM city
JOIN address ON city.city_id = address.city_id
JOIN customer ON address.address_id = customer.address_id
GROUP BY city.city_id, city
ORDER BY inactive_customers DESC
;


--Output the category of movies that have the highest number of total rental hours in the city (customer.address_id in this city) and that start with the letter “a”. Do the same for cities that have a “-” in them. Write everything in one query.

WITH city_rental_hours AS (
SELECT category.name AS category_name, city, SUM(EXTRACT(EPOCH FROM (rental.return_date - rental.rental_date)) / 3600) AS total_hours
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
JOIN customer ON rental.customer_id = customer.customer_id
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
WHERE rental.return_date IS NOT NULL
GROUP BY category.name, city
),

ranked_categories AS (
SELECT city, category_name, total_hours, ROW_NUMBER() OVER (PARTITION BY city ORDER BY total_hours DESC) AS rank
FROM city_rental_hours
WHERE city ILIKE 'a%'

UNION ALL

SELECT city, category_name, total_hours, ROW_NUMBER() OVER (PARTITION BY city ORDER BY total_hours DESC) AS rank
FROM city_rental_hours
WHERE city LIKE '%-%'
)

SELECT city, category_name, total_hours
FROM ranked_categories
WHERE rank = 1
ORDER BY city
;