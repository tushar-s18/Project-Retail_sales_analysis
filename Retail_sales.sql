CREATE DATABASE Retail_sales_analysis;

Use Retail_sales_analysis

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales(
 transactions_id INT PRIMARY KEY,	
 sale_date DATE,	 
 sale_time TIME,	
 customer_id INT,
 gender	VARCHAR(15),
 age INT,
 category VARCHAR(15),	
 quantity INT,
 price_per_unit FLOAT,	
 cogs	FLOAT,
 total_sale FLOAT
            );

-- import the file
BULK INSERT retail_sales
FROM 'C:\temp\Retail_sales.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)

SELECT TOP 5 * FROM retail_sales;

SELECT COUNT(*) FROM retail_sales

-- Data Cleaning

SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales

SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
select * from retail_sales
where sale_date= '2022-11-05'

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022
select * from retail_sales
where Month(sale_date)= 11 AND
    category= 'Clothing' AND
	quantity>3

-- Q.3 Write a SQL query to calculate the total sales for each category
select category, 
SUM(total_sale) as Net_Sale, 
COUNT(*) as total_orders
from retail_sales
Group by category

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select category, AVG(age) as Average_age
from retail_sales
where category= 'Beauty'
Group by category

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
Select * from retail_sales
where total_sale>1000

-- Q.6 Write a SQL query to find the total number of transactions made by each gender in each category.
select gender,category,
Count(*) as Total_trasaction
from retail_sales
group by
category,
gender
order by 1

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select * from(
select Year(sale_date) as Year,
Month(sale_date) as Month,
avg(total_sale) as Average_sales,
rank() over(partition by Year(sale_date) order by avg(total_sale)DESC)as Rank
from retail_sales
group by Year(sale_date),
Month(sale_date)
) as t1
where Rank=1

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
Select TOP 5 
customer_id,
Sum(total_sale) as Total_Sale
from retail_sales
Group by customer_id
Order by Total_Sale DESC

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cust
FROM retail_sales
GROUP BY category

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
with hourly_sale AS(
select *,
Case
	when Datepart(hour,sale_time) <12 then 'Morning'
	when Datepart(hour,sale_time) Between 12 and 17 then 'Afternoon'
	else 'Evening'
	End as Shift
from retail_sales
)

select shift,
Count(*) as no_of_orders
from hourly_sale
group by shift
