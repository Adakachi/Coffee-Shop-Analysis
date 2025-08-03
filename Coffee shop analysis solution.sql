-- Coffee Shop Data Analysis

-- Q1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
	ROUND((population * 0.25)/1000000, 2)  AS coffee_consumers_in_millions,
    city_rank
FROM city
ORDER BY 2 DESC

-- Q2 Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the 1st half of 2024?

SELECT 
	ci.city_name,
	SUM(s.total) AS total_revenue
 FROM sales AS s
 JOIN customers AS c
 ON s.customer_id = c.customer_id
 JOIN city AS ci
 ON ci.city_id = c.city_id
 WHERE 
	EXTRACT(YEAR FROM s.sale_date) = 2024
	AND
	EXTRACT(quarter FROM s.sale_date) IN(1,2)
GROUP BY ci.city_name
ORDER BY total_revenue DESC

-- Q3 Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	p.product_name,
    COUNT(s.sale_id) AS total_orders
FROM products as p
LEFT JOIN
sales AS S
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC

-- 4.	Average Sales Amount per City
-- What is the average sales amount per customer in each city
SELECT 
	ci.city_name,
	SUM(s.total) AS total_revenue,
    count(distinct s.customer_id) AS total_customer,
    round(
		SUM(s.total)/count(distinct s.customer_id),2) AS avg_sales_per_customer
 FROM sales AS s
 JOIN customers AS c
 ON s.customer_id = c.customer_id
 JOIN city AS ci
 ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC

-- Q5 City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers

SELECT 
	ci.city_name,
    (population * 0.25)/1000000 AS coffee_consumers_in_millions,
    COUNT(distinct c.customer_id) AS unique_customer
FROM sales AS s
 JOIN customers AS c
 ON s.customer_id = c.customer_id
 JOIN city AS ci
 ON ci.city_id = c.city_id
group by c.city_id
ORDER BY coffee_consumers_in_millions DESC

-- Q6 Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT 
	c.city_name,
	p.product_name,
    COUNT(s.sale_id) AS total_orders
FROM sales as s
JOIN products AS p
ON s.product_id = p.product_id
JOIN customers AS cux
ON cux.customer_id = s.customer_id
JOIN city as c
on c.city_id = cux.city_id
GROUP BY c.city_name, p.product_name
ORDER BY c.city_name, total_orders DESC

-- 7.	Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT 
	ci.city_name,
    COUNT(distinct c.customer_id) AS unique_customer
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
JOIN products AS p
ON s.product_id = p.product_id
where s.product_id <= 14
GROUP BY ci.city_name 

-- 8.	Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

SELECT 
	ci.city_name,
    ci.estimated_rent AS total_rent,
    
    SELECT 
	ci.city_name,
	(population * 0.25)/1000000 AS estimated_coffee_consumers_in_millions,
    ci.estimated_rent AS total_rent,
    COUNT(distinct c.customer_id) AS total_customers,
    sum(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
JOIN products AS p
ON s.product_id = p.product_id
GROUP BY 1, 2, 3
order by 5 DESC

    sum(s.total) as total_sales,
    round((sum(s.total)/count(distinct s.customer_id)),2) AS Avg_sales_per_customer,
    round(ci.estimated_rent/count(distinct s.customer_id),2) AS Avg_rent_per_customer
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
JOIN products AS p
ON s.product_id = p.product_id
GROUP BY ci.estimated_rent, ci.city_name
order by Avg_rent_per_customer DESC

-- Q9 Monthly Sales Growth
-- growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
WITH
monthly_sales
as
(	SELECT 
	ci.city_name,
    extract(month from sale_date) AS month,
    extract(year from sale_date) AS year,
    sum(s.total) AS total_sales
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id 
JOIN products AS p
ON s.product_id = p.product_id
group by 1, 2, 3
order by 1, 3, 2
),
Growth_ratio_table
as
(	
    select 
	city_name,
    month,
    year,
    total_sales,
    LAG(total_sales, 1) OVER(partition by city_name order by year, month) AS last_month_sale,
	round((total_sales-(LAG(total_sales, 1) OVER(partition by city_name order by year, month)))/(LAG(total_sales, 1) OVER(partition by city_name order by year, month)) * 100, 2) AS Growth_ratio
FROM monthly_sales
)
Select
	city_name,
    month,
    year,
    total_sales,
	last_month_sale,
    Growth_ratio
FROM Growth_ratio_table
WHERE growth_ratio IS NOT NULL

-- 10 Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
SELECT 
	ci.city_name,
	(population * 0.25)/1000000 AS estimated_coffee_consumers_in_millions,
    ci.estimated_rent AS total_rent,
    COUNT(distinct c.customer_id) AS unique_customers,
    sum(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
JOIN products AS p
ON s.product_id = p.product_id
GROUP BY 1, 2, 3
order by 5 DESC




















	
