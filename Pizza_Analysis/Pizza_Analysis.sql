--Basic:
--Retrieve the total number of orders placed.
select COUNT(order_id) as total_orders
From orders

--Calculate the total revenue generated from pizza sales.
select ROUND(SUM(p.price * od.quantity),2) as total_sales
from pizzas p
join order_details od
ON p.pizza_id = od.pizza_id

--Identify the highest-priced pizza.

select Top 1 name, p.price
from pizzas p
join pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC


--Identify the most common pizza size ordered.
select COUNT(order_details_id) as orders , size
from order_details
inner join pizzas 
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY size
ORDER BY orders DESC


--List the top 5 most ordered pizza types along with their quantities.
select Top 5 pt.name, SUM(od.quantity) quantity_ordered
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
On p.pizza_id = od.pizza_id
GROUP BY pt.name
Order by quantity_ordered DESC


--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, SUM(order_details.quantity) as quantity
from pizza_types
join pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
order by quantity desc

--Determine the distribution of orders by hour of the day.
select DATEPART(HOUR,time) busiest_hours, COUNT(order_id) orders
from orders
GROUP BY DATEPART(HOUR,time)
order by orders desc

--Join relevant tables to find the category-wise distribution of pizzas.
select category, count(*) pizza_types
from pizza_types
group by category
order by pizza_types DESC

--Group the orders by date and calculate the average number of pizzas ordered per day.
select AVG(quantity) as_avg_orders from 
(select date, SUM(order_details.quantity) as quantity
from orders
join order_details 
ON orders.order_id = order_details.order_id
GROUP BY date) a

--Determine the top 3 most ordered pizza types based on revenue.
select TOP 3 pizza_types.name, SUM(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC

--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category, ROund(ROUND(SUM(order_details.quantity * pizzas.price),0) / (select ROUND(SUM(p.price * od.quantity),2) as total_sales
from pizzas p
join order_details od
ON p.pizza_id = od.pizza_id) * 100,2) as percent_distribution
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY percent_distribution DESC

--Analyze the cumulative revenue generated over time.
with final as (
select orders.date, ROUND(SUM(order_details.quantity * pizzas.price),2) as revenue
from orders
Join order_details
ON orders.order_id = order_details.order_id
Join pizzas
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY orders.date)
select *, SUM(revenue) OVER (order by date ASC rows between unbounded preceding and current row) as cumulative_revenue
from final


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with top_rank as (
select pizza_types.category, pizza_types.name, SUM(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name)
, final as (
select *
, DENSE_RANK() OVER (partition by category order by revenue desc) rnk
from top_rank)
select * from final where rnk <=3