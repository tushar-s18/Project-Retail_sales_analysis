# 📊 Power BI Dashboard – Retail Sales Analysis

This Power BI dashboard presents an interactive analysis of **Retail Sales** data using visuals, DAX measures, slicers, and drill-through navigation.

---

## Files Included

- `Retail_Sales_Analysis.pbix` – The Power BI report file.
- SQL files and sample data (in root or `/sql` directory).
- (Optional) Dashboard screenshots in the `/images` folder.

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
