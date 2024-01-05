-- ## Challenge

-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT * FROM inventory AS i
LEFT JOIN film AS f
ON i.film_id = f.film_id;

SELECT count(title) AS 'number of copys from Hunchback Impossible'  FROM (
SELECT title FROM inventory AS i
LEFT JOIN film AS f
ON i.film_id = f.film_id
) AS sub
WHERE title = "Hunchback Impossible";


-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
-- 1.query title, length
-- 2.query avg(length)
SELECT title, length FROM film;

SELECT avg(length) FROM film;

SELECT title, length FROM film
WHERE length > (SELECT avg(length) FROM film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
-- film +left+ fillm_actor +left+ actor
SELECT * FROM (
SELECT first_name, last_name, title FROM film AS fi
LEFT JOIN film_actor AS fa
ON fi.film_id = fa.film_id
LEFT JOIN actor AS a
ON fa.actor_id = a.actor_id
) AS sub
WHERE title = "Alone Trip";


-- **Bonus**:

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films. 
-- film +left+ film_category +left+ category
SELECT * FROM (
SELECT title, name FROM film AS f
LEFT JOIN film_category AS fc
ON f.film_id = fc.film_id
LEFT JOIN category AS c
ON fc.category_id = c.category_id
) AS sub
WHERE name = 'family';


-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
-- first_name & last_name & email --> customer
-- address as connector
-- city as connector
-- country --> country

SELECT * FROM country;

SELECT first_name, last_name, email  FROM (
SELECT * FROM customer as cu
LEFT JOIN address AS a
ON cu.address_id = a.address_id
LEFT JOIN city AS c
ON a.city_id = c.city_id
LEFT JOIN country AS co
ON c.country_id = co.country_id
WHERE country = 'Canada'
) AS sub;

SELECT cu.first_name as first_name, cu.last_name as last_name, cu.email as email, a.address as address, c.city as city, co.country as country FROM customer as cu
LEFT JOIN address AS a
ON cu.address_id = a.address_id
LEFT JOIN city AS c
ON a.city_id = c.city_id
LEFT JOIN country AS co
ON c.country_id = co.country_id
WHERE country = 'Canada';

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
-- max(count(film_id)) group by actor -->  
-- film +left+ film_actor +left+ actor
-- film__id where actor = most prolific actor

SELECT a.actor_id, count(f.film_id) AS num_of_films FROM film AS f
LEFT JOIN film_actor AS fa
ON f.film_id = fa.film_id
LEFT JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY a.actor_id
ORDER BY num_of_films DESC
LIMIT 1;

SELECT film_id FROM film_actor 
WHERE actor_id = (
  SELECT actor_id FROM (
    SELECT a.actor_id, count(f.film_id) AS num_of_films FROM film AS f
    LEFT JOIN film_actor AS fa
    ON f.film_id = fa.film_id
    LEFT JOIN actor AS a
    ON fa.actor_id = a.actor_id
    GROUP BY a.actor_id
    ORDER BY num_of_films DESC
    LIMIT 1) as sub1
);


-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
-- finding the most profitable customer:
-- customer_id --> customer
-- sum(amount) --> payment
SELECT customer_id FROM
(SELECT customer_id , sum(amount) AS sum_amount FROM payment
GROUP BY customer_id
ORDER BY sum_amount DESC
LIMIT 1) AS sub1;

-- finding the title of the film:
-- title --> film +left+ inventory +left+ rental --> where customer_id = most profitable customer 

SELECT f.title, r.customer_id FROM film AS f
LEFT JOIN inventory AS i
ON f.film_id = i.film_id
LEFT JOIN rental AS r
ON i.inventory_id = r.inventory_id
WHERE r.customer_id = 
	(SELECT customer_id FROM
		(SELECT customer_id , sum(amount) AS sum_amount FROM payment
		GROUP BY customer_id
		ORDER BY sum_amount DESC
		LIMIT 1
        ) AS sub1
	)
ORDER BY title;



-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.

-- customer_id where payment_amount > avg(payment_amount)

SELECT avg(sum_amount) AS avg_amount_per_customer FROM (
SELECT customer_id , sum(amount) AS sum_amount FROM payment
GROUP BY customer_id
ORDER BY sum_amount DESC
) AS sub1;



SELECT customer_id, sum(amount) AS sum_amount FROM payment
GROUP BY customer_id
HAVING sum_amount > (
SELECT avg(sum_amount) AS avg_amount_per_customer FROM (
SELECT customer_id , sum(amount) AS sum_amount FROM payment
GROUP BY customer_id
ORDER BY sum_amount DESC
) AS sub1
);

-- I try to join the table which i get to the table customer to get the first and last name to the customer_id
SELECT * FROM 
(SELECT customer_id, sum(amount) AS sum_amount FROM payment
GROUP BY customer_id
	HAVING sum_amount > (
	SELECT avg(sum_amount) AS avg_amount_per_customer FROM (
		SELECT customer_id , sum(amount) AS sum_amount FROM payment
		GROUP BY customer_id
		ORDER BY sum_amount DESC
		) AS sub1
	) AS sub2
) AS sub3    
LEFT JOIN customer AS c
ON sub3.customer_id = c.customer_id;