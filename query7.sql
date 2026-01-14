--Output the category of movies that have the highest number of total rental hours in the city (customer.address_id in this city) and that start with the letter “a”. Do the same for cities that have a “-” in them. Write everything in one query.

WITH city_rental_hours AS (
SELECT category.name AS category_name, city, sum(EXTRACT(EPOCH FROM (rental.return_date - rental.rental_date)) / 3600) AS total_hours
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
JOIN customer ON rental.customer_id = customer.customer_id
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
GROUP BY category_name, city
),

ranked_categories AS (
SELECT category_name, sum(total_hours) AS total_hours, 'cities_starting_with_a' AS city_type, RANK() OVER (ORDER BY sum(total_hours) DESC) AS rank
FROM city_rental_hours
WHERE city ILIKE 'a%'
GROUP BY category_name
    
UNION ALL
    
SELECT category_name, sum(total_hours) AS total_hours, 'cities_with_dash' AS city_type, RANK() OVER (ORDER BY sum(total_hours) DESC) AS rank
FROM city_rental_hours
WHERE city LIKE '%-%'
GROUP BY category_name
)

SELECT city_type, category_name, total_hours
FROM ranked_categories
WHERE rank = 1
;