# Retail Sales Data Analysis using SQL

This project involves building and analyzing a **Retail Sales** dataset using SQL Server. The analysis covers key business questions, data cleaning, exploratory analysis, and deriving insights based on transactional retail sales data.

## Project Structure

- **Database**: `Retail_sales_analysis`
- **Table**: `retail_sales`
- **Data Source**: CSV file (`Retail_sales.csv`)
- **Tech Stack**: SQL Server, T-SQL

---

## Objective

To perform data analysis on retail sales data using SQL to answer common business questions such as:
- Total sales volume
- Best performing product categories
- Top customers
- Time-based sales trends (shift analysis)
- Customer demographics and behavior

---

## Dataset Schema

| Column            | Description                      |
|-------------------|----------------------------------|
| transactions_id   | Unique transaction ID            |
| sale_date         | Date of sale                     |
| sale_time         | Time of sale                     |
| customer_id       | Unique customer ID               |
| gender            | Customer gender                  |
| age               | Customer age                     |
| category          | Product category (e.g., Clothing, Beauty) |
| quantity          | Quantity sold                    |
| price_per_unit    | Price per unit                   |
| cogs              | Cost of goods sold               |
| total_sale        | Total sale value                 |

---

## Setup Instructions

1. **Create database and table**
   ```sql
   CREATE DATABASE Retail_sales_analysis;
   USE Retail_sales_analysis;

   DROP TABLE IF EXISTS retail_sales;
   CREATE TABLE retail_sales (
       transactions_id INT PRIMARY KEY,
       sale_date DATE,
       sale_time TIME,
       customer_id INT,
       gender VARCHAR(15),
       age INT,
       category VARCHAR(15),
       quantity INT,
       price_per_unit FLOAT,
       cogs FLOAT,
       total_sale FLOAT
   );
## Import CSV Data
   ```sql
   BULK INSERT retail_sales
   FROM 'C:\temp\Retail_sales.csv'
   WITH (
       FORMAT='CSV',
       FIRSTROW=2
   );
```
## Data Cleaning
Checked for NULL values in essential columns.
   ```sql
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
      ```
## Exploratory Data Analysis
   ```sql
   SELECT COUNT(*) FROM retail_sales;

   SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

   SELECT DISTINCT category FROM retail_sales;
   ```
## Business Questions Answered

### 1. Sales made on 2022-11-05
   ```sql
   SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';
   ```
### 2. 'Clothing' sales with quantity > 3 in Nov 2022
   ```sql
   SELECT * FROM retail_sales
   WHERE MONTH(sale_date) = 11 AND category = 'Clothing' AND quantity > 3;
   ```
### 3. Total sales and orders by category
   ```sql
   SELECT category, SUM(total_sale) AS Net_Sale, COUNT(*) AS total_orders
   FROM retail_sales GROUP BY category;
   ```
### 4. Average age of customers (Beauty category)
   ```sql
   SELECT AVG(age) FROM retail_sales WHERE category = 'Beauty';
   ```
### 5. Transactions with sales > 1000
    ```sql
   SELECT * FROM retail_sales WHERE total_sale > 1000;
   ```
### 6. Gender-wise sales by category
   ```sql
   SELECT gender, category, COUNT(*) AS Total_Transactions
   FROM retail_sales GROUP BY gender, category;
   ```
### 7. Best month each year (based on avg sale)
   ```sql
   SELECT * FROM (
   SELECT YEAR(sale_date) AS Year, MONTH(sale_date) AS Month,
         AVG(total_sale) AS Average_Sales,
         RANK() OVER (PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS Rank
   FROM retail_sales
   GROUP BY YEAR(sale_date), MONTH(sale_date)
   ) AS t WHERE Rank = 1;
   ```
### 8. Top 5 customers by total sale
   ```sql
   SELECT TOP 5 customer_id, SUM(total_sale) AS Total_Sale
   FROM retail_sales GROUP BY customer_id ORDER BY Total_Sale DESC;
   ```
### 9. Unique customers by category
   ```sql
   SELECT category, COUNT(DISTINCT customer_id) AS cnt_unique_cust
   FROM retail_sales GROUP BY category;
   ```
### 10. Sales shift analysis (Morning, Afternoon, Evening)
   ```sql
   WITH hourly_sale AS (
   SELECT *,
       CASE 
         WHEN DATEPART(hour, sale_time) < 12 THEN 'Morning'
         WHEN DATEPART(hour, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
         ELSE 'Evening'
       END AS Shift
   FROM retail_sales
   )
   SELECT Shift, COUNT(*) AS no_of_orders
   FROM hourly_sale GROUP BY Shift;
   ```
