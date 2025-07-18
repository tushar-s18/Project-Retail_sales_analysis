# 🛍️ Retail Sales Data Analysis – SQL & Power BI

This project demonstrates end-to-end data analysis on **Retail Sales** data using **SQL Server** for backend analysis and **Power BI** for interactive visualization.

---

## 🗃️ Tech Stack

- **Backend**: SQL Server, T-SQL  
- **Visualization**: Power BI, DAX  
- **Data Source**: `Retail_sales.csv`

---

## 📌 Objective

To derive business insights from retail sales data using SQL and visualize them in Power BI dashboards, covering:

- Sales performance
- Top-performing categories and customers
- Customer demographics
- Time-based sales patterns and shifts
- Drill-through and interactive reports

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

## 🧮 SQL Analysis

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
```

```sql
   SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
```

```sql
   SELECT DISTINCT category FROM retail_sales;
```
## Business Questions Answered

### 1. Sales made on 2022-11-05
   ```sql
   SELECT * FROM retail_sales
   WHERE sale_date = '2022-11-05';
   ```
### 2. 'Clothing' sales with quantity > 3 in Nov 2022
   ```sql
   SELECT * FROM retail_sales
   WHERE MONTH(sale_date) = 11
   AND
   category = 'Clothing'
   AND
   quantity > 3;
   ```
### 3. Total sales and orders by category
   ```sql
   SELECT
   category,
   SUM(total_sale) AS Net_Sale,
   COUNT(*) AS total_orders
   FROM retail_sales
   GROUP BY category;
   ```
### 4. Average age of customers (Beauty category)
   ```sql
   SELECT AVG(age) FROM retail_sales
   WHERE category = 'Beauty';
   ```
### 5. Transactions with sales > 1000
   ```sql
   SELECT * FROM retail_sales
   WHERE total_sale > 1000;
   ```
### 6. Gender-wise sales by category
   ```sql
   SELECT
   gender,
   category,
   COUNT(*) AS Total_Transactions
   FROM retail_sales
   GROUP BY gender, category;
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
   FROM retail_sales
   GROUP BY customer_id
   ORDER BY Total_Sale DESC;
   ```
### 9. Unique customers by category
   ```sql
   SELECT
   category,
   COUNT(DISTINCT customer_id) AS cnt_unique_cust
   FROM retail_sales
   GROUP BY category;
   ```
### 10. Sales shift analysis (Morning, Afternoon, Evening)
   ```sql
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
   ```


## 📊 Power BI Dashboard

An interactive dashboard built on the same dataset, offering visual insight into sales trends, top customers, category performance, and sales shifts.

---

## 📋 Page 1: Sales Overview

### Visual Elements:

- **Header**: `RETAIL SALES`
- **KPI Cards**:
  - `Total Sale`: Total revenue.
  - `Top 5 Customers - Sale`: Sum of sales for the top 5 customers.

    ```DAX
    Top5CustomerSales =
    SUMX(
        TOPN(
            5,
            VALUES(retail_sales[customer_id]),
            CALCULATE(SUM(retail_sales[total_sale])),
            DESC
        ),
        CALCULATE(SUM(retail_sales[total_sale]))
    )
    ```

- **Slicer Filters**:
  - Year
  - Gender
  - Category

- **Top 5 Customers Table**:
  - Shows customer ID, total sales, and ranking.
  - DAX used for ranking:

    ```DAX
    Top_5_Rank =
    IF (
        HASONEVALUE(retail_sales[customer_id]),
        RANKX(
            ALL(retail_sales[customer_id]),
            CALCULATE(SUM(retail_sales[total_sale])),
            ,
            DESC
        )
    )
    ```

  - Applied filter: Top N = 5 customers by sales.

- **Pie Chart – Total Sales by Shift**  
  Created using a derived column:

    ```DAX
    Shift =
    SWITCH(
        TRUE(),
        HOUR(retail_sales[sale_time]) < 12, "Morning",
        HOUR(retail_sales[sale_time]) < 17, "Afternoon",
        "Evening"
    )
    ```

  - Drill-through enabled to **Page 4: Sales by Shift**

- **Stacked Column Chart – Total Sales by Category**
  - Drill-through enabled to **Page 3: Total Sales by Category**

- **Line Chart – Total Sales by Month**

---

## Page 2: Sales Details

- **Same KPI Cards and Slicer Filters** as Page 1.
- **Stacked Column Chart – Sales Status by Shift**:
  
  Created with a custom column:

  ```DAX
  Sale_Status =
  IF (
      retail_sales[total_sale] <= 500, "Low Sale",
      IF (
          retail_sales[total_sale] <= 1500, "Normal Sale",
          "High Sale"
      )
  )
