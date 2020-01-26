USE sakila;
SHOW tables;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in
-- upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, " ", last_name) AS actor_name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor,
-- of whom you know only the first name, "Joe." What is one query would you
-- use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%gen%";

-- 2c. Find all actors whose last names contain the letters LI. This time,
-- order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following
-- countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will
-- be performing queries on a description, so create a column in the table
-- actor named description and use the data type BLOB (Make sure to research
-- the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is
-- too much effort. Delete the description column.
ALTER TABLE actor DROP description;

-- 4a. List the last names of actors, as well as how many actors have that
-- last name.
SELECT last_name, count(last_name) AS num_actors
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last
-- name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) AS num_actors
FROM actor
GROUP BY last_name
HAVING num_actors >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table
-- as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

-- check record to verify
SELECT * FROM actor
WHERE last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out
-- that GROUCHO was the correct name after all! In a single query, if the
-- first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" and last_name = "WILLIAMS";

-- check record to verify
SELECT * FROM actor
WHERE last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would
-- you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

DESCRIBE address;

-- 6a. Use JOIN to display the first and last names, as well as the address,
-- of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM staff s
JOIN address a
ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in
-- August of 2005. Use tables staff and payment.
SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS total_rung_up
FROM staff s
JOIN payment p
ON s.staff_id = p.staff_id
WHERE p.payment_date >= "2005-08-01" and p.payment_date < "2005-09-01"
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film.
-- Use tables film_actor and film. Use inner join.
SELECT f.film_id, f.title, COUNT(fa.actor_id) AS num_actors
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the
-- inventory system?
SELECT f.film_id, f.title, COUNT(f.title) AS num_copies
FROM inventory i
JOIN film f
ON i.film_id = f.film_id
WHERE f.title = "Hunchback Impossible"
GROUP BY f.film_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the
-- total paid by each customer. List the customers alphabetically by last name:
SELECT c.customer_id, c.last_name, c.first_name, SUM(p.amount) AS total_paid
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also
-- soared in popularity. Use subqueries to display the titles of movies starting
-- with the letters K and Q whose language is English.
SELECT *
FROM (
	SELECT f.film_id, f.title, l.name
	FROM film f
	JOIN language l
	ON f.language_id = l.language_id
	WHERE (f.title LIKE "K%" OR f.title LIKE "Q%")
	) AS film_language
WHERE name = "English";

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id = (
		SELECT film_id
		FROM film
		WHERE title = "Alone Trip"
		)
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will
-- need the names and email addresses of all Canadian customers. Use joins to
-- retrieve this information.
SELECT first_name, last_name, email, country
FROM (
	SELECT first_name, last_name, email, city_id
	FROM customer c
	JOIN address a
	ON c.address_id = a.address_id
    ) AS customer_city
JOIN (
	SELECT city_id, country
	FROM city ci
	JOIN country co
	ON ci.country_id = co.country_id
	WHERE country = "Canada"
    ) AS city_id_country
USING (city_id);

-- 7d. Sales have been lagging among young families, and you wish to target all
-- family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_category
	WHERE category_id = (
		SELECT category_id
		FROM category
		WHERE name = "Family"
		)
	);

-- 7e. Display the most frequently rented movies in descending order.
SELECT film_id, title, rental_count
FROM film
JOIN (
	SELECT film_id, COUNT(inventory_id) AS rental_count
	FROM rental
	JOIN inventory
	USING (inventory_id)
	GROUP BY film_id
	) AS rental_count
USING (film_id)
ORDER BY rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS total_revenue
FROM payment p
JOIN staff s
USING (staff_id)
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store s
JOIN address a
USING (address_id)
JOIN (
	SELECT city_id, city, country
	FROM city ci
	JOIN country co
	ON ci.country_id = co.country_id
    ) AS city_country
USING (city_id);

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may
-- need to use the following tables: category, film_category, inventory, payment,
-- and rental.)
SELECT name AS genre, SUM(amount) AS genre_revenue
FROM payment
JOIN rental
USING (rental_id)
JOIN inventory
USING (inventory_id)
JOIN film_category
USING (film_id)
JOIN category
USING (category_id)
GROUP BY genre
ORDER BY genre_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of
-- viewing the Top five genres by gross revenue. Use the solution from the problem
-- above to create a view. If you haven't solved 7h, you can substitute another
-- query to create a view.
DROP VIEW IF EXISTS top_five_genre_by_revenue;

CREATE VIEW top_five_genre_by_revenue AS
SELECT name AS genre, SUM(amount) AS genre_revenue
FROM payment
JOIN rental
USING (rental_id)
JOIN inventory
USING (inventory_id)
JOIN film_category
USING (film_id)
JOIN category
USING (category_id)
GROUP BY genre
ORDER BY genre_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genre_by_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to
-- delete it.
DROP VIEW IF EXISTS top_five_genre_by_revenue;