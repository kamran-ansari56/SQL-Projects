select * from retail_sales;

-- Count Total number of rows in the data
select count(*) from retail_sales;

-- Check for Null values in the data
select * from retail_sales
   where transactions_id IS NULL
or sale_date IS NULL
or  sale_time IS NULL
or  customer_id IS NULL
or  gender IS NULL
or  age IS NULL
or  category IS NULL
or  quantiy IS NULL
or  price_per_unit = ' '
or  cogs IS NULL
or  total_sale IS NULL;

-- Remove Null values from the data
DELETE FROM retail_sales
where transactions_id IS NULL
or sale_date IS NULL
or  sale_time IS NULL
or  customer_id IS NULL
or  gender IS NULL
or  age IS NULL
or  category IS NULL
or  quantiy IS NULL
or  price_per_unit = ' '
or  cogs IS NULL
or  total_sale IS NULL


-- Data Exploration

-- How many sales we have done?
select count(*) as total_sales
from retail_sales;

-- How many distinct customers we have?
select count(distinct customer_id) as total_customers
from retail_sales;

-- How many unique categories we have?
select count(distinct category) as unqiue_category
from retail_sales


-- Data Analysis and Key Business Problems and its answers

-- Q1. Write a SQL Query to retreive all columns for sales made on '2022-11-05'
SELECT *
from retail_sales
where sale_date = '2022-11-05'

-- Q2. Write a SQL Query to retrive all transactions where the category is "clothing" and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
from retail_sales
Where sale_date BETWEEN '2022-11-01' AND '2022-11-30' AND category = 'Clothing' AND quantiy >= 4

-- Q3. Write a SQL Query to calculate total sales for each category
Select SUM(CAST(total_sale as int)) as total_sales, category
from retail_sales
group by category

-- Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category
select AVG(CAST(age as int)) as avg_age 
from retail_sales
where category = 'Beauty'

-- Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000
SELECT *
from retail_sales
where CAST(total_sale as int) > 1000

-- Q6. Write a SQL query to find the total number of transactions made by each gender in each category
SELECT count(*) as total_transactions, category, gender
from retail_sales
group by category, gender

-- Q7. Write a SQL query to calculate the average sales for each month. find out the best selling month in each year
select * from (
SELECT AVG(CAST(total_sale as int)) as avg_sale, month(sale_date) as month, YEAR(sale_date) as year_, RANK() OVER (PArtition by YEAR(sale_date) order by AVG(CAST(total_sale as int))desc) as rnk
from retail_sales
group by month(sale_date), YEAR(sale_date)) as t1
where rnk = 1

-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales
SELECT Top  5 SUM(CAST(total_sale as int)) as total_sales, customer_id
from retail_sales
group by customer_id
order by total_sales desc;

-- Q9. Write a SQL query to find the number of unique customers who purchased items from each category
select category, COUNT(DISTINCT customer_id) as uni
from retail_sales
group by category;


-- Q10. Write a SQL query to create each shift and number of orders
with hourly_sale as (
select *, 
		CASE 
			WHEN Datepart(HOUR , sale_time) < 12 then 'Morning'
			WHEN Datepart(HOUR , sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			Else 'Evening'
			end as bucket
from retail_sales) 
select bucket, count(*) as total_orders
from hourly_sale
group by bucket

;

