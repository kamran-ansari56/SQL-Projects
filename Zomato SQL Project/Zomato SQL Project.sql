create database zomato

use zomato


drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1. what is the total amount each customer spent on zomato?

SELECT a.userid, SUM(b.price) AS total_spent
FROM SALES a
INNER JOIN PRODUCT b
ON a.product_id = b.product_id
GROUP BY a.userid;

-- 2. How many days has each customer visited zomato?

SELECT userid, COUNT( DISTINCT created_date) distinct_days
FROM sales
GROUP BY userid;

-- 3. what was the first product purchased by each customer?

SELECT * FROM (
SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date ) rnk from sales) a
WHERE rnk = 1

-- 4. what is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT userid, count(product_id) cnt FROM SALES WHERE product_id =
(
SELECT TOP 1 product_id
FROM sales
GROUP BY product_id
ORDER BY COUNT(product_id)  DESC)
GROUP BY userid

-- 5. which item was the most popular for each customer?

SELECT * FROM
(
SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt desc) rnk FROM
(
SELECT userid, product_id, COUNT(product_id) cnt
FROM SALES
GROUP BY userid, product_id)a)b
WHERE rnk = 1

-- 6. which item was purchased first by the customer after they became a member?

SELECT * FROM
(
SELECT c.*, RANK() OVER (PARTITION BY userid ORDER BY created_date) rnk FROM
(
SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date
FROM SALES a
INNER JOIN goldusers_signup b
ON a.userid = b.userid AND created_date > gold_signup_date) c) d WHERE rnk = 1;

--	7. which item was purchased just before the customer became a member?

SELECT * FROM
(
SELECT c.*, RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) rnk FROM
(
SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date
FROM SALES a
INNER JOIN goldusers_signup b
ON a.userid = b.userid AND created_date <=  gold_signup_date) c) d WHERE rnk = 1;

-- 8. what is the total orders and amount spent for each member before they became a member?

SELECT userid, COUNT(created_date) AS order_purchased , SUM(price) AS total_amount_spent FROM
(
SELECT c.*, d.price FROM
(
SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date
FROM SALES a
INNER JOIN goldusers_signup b
ON a.userid = b.userid AND created_date <=  gold_signup_date)c
INNER JOIN product d
ON c.product_id = d.product_id) e
GROUP BY userid;

--	9.	If buying each product generates points for eg 5rs = 2 Zomato points and each product has different purchasing points for eg for p1 5rs = 1 Zomato point, 
-- for p2 10rs = 5 Zomato points and p3 5rs = 1 zomato point, calculate points collected by each customers and for whoch product most points have been given till date.


SELECT userid, SUM(total_points)*2.5 total_cashback_earned FROM
(
SELECT e.*, amt/points total_points FROM
(
SELECT d.*, CASE WHEN product_id = 1 THEN 5 WHEN product_id = 2 THEN 2 when product_id = 3 THEN 5 ELSE 0 END AS points FROM
(
SELECT c.userid, c.product_id, SUM(price) amt FROM
(SELECT a.*, b.price 
FROM sales a
INNER JOIN product b
ON a.product_id = b.product_id) c
GROUP BY userid, product_id) d ) e ) f
GROUP BY userid ;

SELECT  * FROM
(
SELECT *, RANK() OVER (ORDER BY total_points_earned DESC) rnk FROM
(
SELECT product_id, SUM(total_points) total_points_earned FROM
(
SELECT e.*, amt/points total_points FROM
(
SELECT d.*, CASE WHEN product_id = 1 THEN 5 WHEN product_id = 2 THEN 2 when product_id = 3 THEN 5 ELSE 0 END AS points FROM
(
SELECT c.userid, c.product_id, SUM(price) amt FROM
(SELECT a.*, b.price 
FROM sales a
INNER JOIN product b
ON a.product_id = b.product_id) c
GROUP BY userid, product_id) d ) e ) f
GROUP BY product_id) f ) g
WHERE rnk = 1;

-- 10. In the first one year after a customer joins the gold program (includinh their join date) irrespective of what the customer has purchased they earn 5 zomato points for every 10 rs spent
-- who earned more and what was their points earnings in first year?



SELECT c.*, d.price*0.5 total_points_earned FROM
(
SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date
FROM SALES a
INNER JOIN goldusers_signup b
ON a.userid = b.userid AND created_date >=  gold_signup_date AND created_date <= DATEADD(YEAR,1 , gold_signup_date)) c
INNER JOIN product d
ON c.product_id = d.product_id ;