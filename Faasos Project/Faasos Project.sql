CREATE DATABASE faasos

use faasos

drop table if exists driver;

CREATE TABLE driver
(driver_id integer,
reg_date date); 

INSERT INTO driver
(driver_id,reg_date) VALUES
(1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');

drop table if exists ingredients;

CREATE TABLE ingredients
(ingredients_id integer,
ingredients_name varchar(60)); 

INSERT INTO ingredients
(ingredients_id ,ingredients_name) VALUES 
(1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls
(roll_id integer,
roll_name varchar(30)); 

INSERT INTO rolls
(roll_id ,roll_name)  VALUES 
(1 ,'Non Veg Roll'),
(2 ,'Veg Roll');

drop table if exists rolls_recipes;

CREATE TABLE rolls_recipes
(roll_id integer,
ingredients varchar(24));

INSERT INTO rolls_recipes
(roll_id ,ingredients) VALUES 
(1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;

CREATE TABLE driver_order
(order_id integer,
driver_id integer,
pickup_time datetime,
distance VARCHAR(7),
duration VARCHAR(10),
cancellation VARCHAR(23));

INSERT INTO driver_order
(order_id,driver_id,pickup_time,distance,duration,cancellation) VALUES
(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2020 21:30:45','25km','25mins',null),
(8,2,'01-10-2020 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2020 18:50:20','10km','10minutes',null);

drop table if exists customer_orders;

CREATE TABLE customer_orders
(order_id integer,
customer_id integer,
roll_id integer,
not_include_items VARCHAR(4),
extra_items_included VARCHAR(4),
order_date datetime);

INSERT INTO customer_orders
(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) values 
(1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

-- PART 1 // Roll Metrics
--1. How many rolls were ordered?

SELECT COUNT(roll_id) AS Ordered_Rolls
FROM customer_orders;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT (customer_id)) AS Unique_customers
FROM customer_orders;

-- 3. How many sucessful orders were delivered by each driver?

SELECT driver_id ,COUNT(DISTINCT order_id) AS Delivered_orders
FROM driver_order
WHERE cancellation IS NULL OR cancellation NOT IN ('cancellation', 'Customer Cancellation')
GROUP BY driver_id;

-- 4. How many of each type of roll was delivered?
    
SELECT roll_id, COUNT(roll_id)
FROM customer_orders
WHERE order_id IN (
    SELECT order_id
    FROM (
        SELECT *,
               CASE
                   WHEN cancellation IN ('cancellation', 'Customer Cancellation') THEN 'C'
                   ELSE 'NC'
               END AS cancellation_status
        FROM driver_order
    ) AS subquery
    WHERE cancellation_status = 'NC'
)
GROUP BY roll_id;

-- 5. How many veg and non veg rolls were ordered by each customer? 

SELECT a.*, b.roll_name
FROM
(SELECT customer_id, roll_id, COUNT(roll_id) AS COUNT
from customer_orders
GROUP BY customer_id, roll_id) a
INNER JOIN rolls b
ON a.roll_id = b.roll_id;

-- 6. what was the maximum number of rolls delivered in a single order?

SELECT * FROM (
	SELECT *, RANK() OVER (order by COUNT DESC) RANK FROM (
	SELECT order_id, COUNT(roll_id) AS COUNT FROM (
	SELECT * FROM customer_orders WHERE order_id IN (
		SELECT order_id
		FROM (
			SELECT *,
				   CASE
					   WHEN cancellation IN ('cancellation', 'Customer Cancellation') THEN 'C'
					   ELSE 'NC'
				   END AS cancellation_status
			FROM driver_order
		) AS subquery
		WHERE cancellation_status = 'NC')) b
		GROUP BY order_id) c)d WHERE RANK = 1;


-- Data cleaning in customer orders table
with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) AS 
(
SELECT order_id,customer_id,roll_id, CASE WHEN not_include_items IS NULL or not_include_items = ' ' THEN '0' ELSE not_include_items END AS new_not_include_items,
CASE WHEN extra_items_included IS NULL or extra_items_included = ' ' or extra_items_included = 'NaN' THEN '0' ELSE extra_items_included END AS new_extra_items_included,
order_date FROM customer_orders
)
SELECT * FROM temp_customer_orders;

-- Data cleaning in driver orders table
WITH temp_driver_order (order_id,driver_id,pickup_time,distance,duration,cancellation) AS 
(
SELECT order_id,driver_id,pickup_time,distance,duration,
CASE WHEN cancellation IN ('cancellation','Customer Cancellation') THEN 0 ELSE 1 END as new_cancellation
FROM driver_order
)
SELECT * FROM temp_driver_order;

-- 7. For each customer, how many delivered rolls had at leat 1 change and how many had no changes?

with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) AS 
(
	SELECT order_id,customer_id,roll_id, 
	CASE WHEN not_include_items IS NULL or not_include_items = ' ' THEN '0' ELSE not_include_items END AS new_not_include_items,
	CASE WHEN extra_items_included IS NULL or extra_items_included = ' ' or extra_items_included = 'NaN' or extra_items_included = 'NULL' THEN '0' ELSE extra_items_included END AS new_extra_items_included,
	order_date FROM customer_orders
	)
	,
	temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) AS 
	(
	SELECT order_id,driver_id,pickup_time,distance,duration,
	CASE WHEN cancellation IN ('Cancellation','Customer Cancellation') THEN 0 ELSE 1 END as new_cancellation
	FROM driver_order
)
SELECT customer_id, change_no_change, COUNT(order_id) AS at_least_1_change FROM
(
SELECT *, CASE WHEN not_include_items ='0' AND extra_items_included = '0' THEN 'no change' ELSE 'change' END change_no_change 
FROM temp_customer_orders WHERE order_id IN (
SELECT order_ID
FROM temp_driver_order
WHERE new_cancellation !=0))a
GROUP BY customer_id, change_no_change ;


-- 8. How many rolls were delivered that had both exclusions and the extra?

with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) AS (
	SELECT order_id,customer_id,roll_id, 
	CASE WHEN not_include_items IS NULL or not_include_items = ' ' THEN '0' ELSE not_include_items END AS new_not_include_items,
	CASE WHEN extra_items_included IS NULL or extra_items_included = ' ' or extra_items_included = 'NaN' or extra_items_included = 'NULL' THEN '0' ELSE extra_items_included END AS new_extra_items_included,
	order_date FROM customer_orders
	)
	,
	temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) AS 
	(
	SELECT order_id,driver_id,pickup_time,distance,duration,
	CASE WHEN cancellation IN ('Cancellation','Customer Cancellation') THEN 0 ELSE 1 END as new_cancellation
	FROM driver_order
)
SELECT change_no_change, COUNT(change_no_change) FROM 
(SELECT *, CASE WHEN not_include_items !='0' AND extra_items_included != '0' THEN 'both included and excluded' ELSE 'either one included or excluded' END change_no_change 
FROM temp_customer_orders WHERE order_id IN (
SELECT order_ID
FROM temp_driver_order
WHERE new_cancellation !=0))a
GROUP BY change_no_change;

-- 9. what was the total number or rolls ordered for each hour of the day?

SELECT 
hours_bucket, COUNT(hours_bucket) AS orders_placed FROM
(SELECT *, 
CONCAT(CAST(DATEPART(hour,order_date) AS VARCHAR), '-' ,CAST(DATEPART(hour,order_date) +1 AS VARCHAR)) AS hours_bucket
FROM customer_orders)a
GROUP BY hours_bucket;


-- 10. What was the number of orders for each day of the week?

SELECT DOW, COUNT(DISTINCT order_id) AS orders_placed FROM
(SELECT * ,
DATENAME(dw,order_date) DOW
FROM customer_orders)a
GROUP BY DOW;


-- PART 2 // Driver and Customer Experience

--	1.	What was the average timne in minutes took for rach driver to arrive at the FAASOS HQ to pick up the order?

SELECT driver_id, SUM(diff)/ COUNT(order_id) AS Avg_mins FROM
(
SELECT * FROM
(
SELECT *,
    row_number() OVER (PARTITION BY order_id ORDER BY diff) AS rnk
FROM (
    SELECT
        a.order_id,
        a.customer_id,
        a.roll_id,
        a.not_include_items,
        a.extra_items_included,
        a.order_date,
        b.driver_id,
        b.pickup_time,
        b.distance,
        b.duration,
        b.cancellation,
        ABS(DATEDIFF(MINUTE, a.order_date, b.pickup_time)) AS diff
    FROM
        customer_orders AS a
    INNER JOIN
        driver_order AS b ON a.order_id = b.order_id
    WHERE
        b.pickup_time IS NOT NULL
) AS subquery) b WHERE rnk = 1)c
GROUP BY driver_id;



-- 2. Is there any relationship betwwen the number of rools and how lomg the order takes to prepare?

SELECT order_id, COUNT(roll_id), SUM(diff)/COUNT(roll_id) FROM
 (SELECT
        a.order_id,
        a.customer_id,
        a.roll_id,
        a.not_include_items,
        a.extra_items_included,
        a.order_date,
        b.driver_id,
        b.pickup_time,
        b.distance,
        b.duration,
        b.cancellation,
        ABS(DATEDIFF(MINUTE, a.order_date, b.pickup_time)) AS diff
    FROM
        customer_orders AS a
    INNER JOIN
        driver_order AS b ON a.order_id = b.order_id
    WHERE
        b.pickup_time IS NOT NULL)a
	GROUP BY order_id;

	-- 3. what was the average distance travelled for each customer?

SELECT customer_id, SUM(distance)/COUNT(order_id) FROM
(SELECT * FROM (
SELECT *,
    row_number() OVER (PARTITION BY order_id ORDER BY diff) AS rnk
FROM (
    SELECT
        a.order_id,
        a.customer_id,
        a.roll_id,
        a.not_include_items,
        a.extra_items_included,
        a.order_date,
        b.driver_id,
        b.pickup_time,
        CAST(TRIM(REPLACE(b.distance,'km','')) AS DECIMAL(4,2)) distance ,
        b.duration,
        b.cancellation,
        ABS(DATEDIFF(MINUTE, a.order_date, b.pickup_time))  AS diff
    FROM
        customer_orders AS a
    INNER JOIN
        driver_order AS b ON a.order_id = b.order_id
    WHERE
        b.pickup_time IS NOT NULL
) a) b 
WHERE rnk = 1)c
GROUP BY customer_id;

-- 4. What was the difference between the longest and shortest delivery time for all orders?

SELECT MAX(duration) - min(duration) as diff FROM (
	SELECT CAST(CASE WHEN duration like '%min%' THEN LEFT(duration,CHARINDEX('m',duration) -1) ELSE duration END AS integer) AS duration
	FROM driver_order 
	where duration is not null) a;

-- 5. what was the average speed for each driver for each delivery and do you notice any trend of these values?

SELECT a.order_id, a.driver_id, a.distance/a.duration AS speed, b.cnt FROM
(
SELECT order_id, driver_id, CAST(TRIM(REPLACE(distance,'km','')) AS DECIMAL(4,2)) distance , 
CAST(CASE WHEN duration like '%min%' THEN LEFT(duration,CHARINDEX('m',duration) -1) ELSE duration END AS integer) AS duration
FROM driver_order where distance is NOT NULL)a INNER JOIN
(SELECT order_id, COUNT(roll_id) cnt FROM customer_orders GROUP BY order_id) b
ON a.order_id = b.order_id;


-- 6. What is the successful delivery percentage for each driver?

SELECT driver_id, s*1.0/t cancellaed_per FROM
(SELECT driver_id, SUM(can_per) s, COUNT(driver_id) t FROM
(SELECT driver_id, CASE WHEN LOWER(cancellation) LIKE '%cancel%' THEN 0 ELSE 1 END as can_per FROM driver_order)a
GROUP BY driver_id) b;