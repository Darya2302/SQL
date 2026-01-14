--Output cities with the number of active and inactive customers (active - customer.active = 1). Sort by the number of inactive customers in descending order.

SELECT city.city_id, city, count(CASE WHEN customer.active = 1 THEN customer.customer_id END) AS active_customers,
count(CASE WHEN customer.active = 0 THEN customer.customer_id END) AS inactive_customers
FROM city
JOIN address ON city.city_id = address.city_id
JOIN customer ON address.address_id = customer.address_id
GROUP BY city.city_id, city
ORDER BY inactive_customers DESC
;