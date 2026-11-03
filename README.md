# LOTUS RETAIL: SALES, PROFITABILITY & RETURN ANALYSIS (2020-2024)

## Project Overview

This project analyses Lotus Retail's sales, profitability, product performance, store performance, customer behavior, and product returns over the 2022–2024 period.

The objective was to investigate the company's sales and profitability performance, identify the products and categories contributing to revenue and gross profit, evaluate store and customer performance, and understand how product returns affect recognized revenue.

I used power query for data cleaning, SQL in Google BigQuery, I conducted data validation, investigated relationships across multiple tables, examined financial inconsistencies, and answered business questions. I then used Power BI to develop an interactive dashboard presenting the findings and supporting business decision-making.

The project places particular emphasis on data integrity, financial accuracy, and the application of appropriate business rules when analyzing cancelled orders, returned orders, refunds, rejected returns, and pending returns.


## Business Objectives

The main objectives of this project were to:

1. **Evaluate Sales Performance:** Examine sales revenue and gross profit trends over the 2022–2024 period to understand the company's overall financial performance.

2. **Assess Product Performance:** Identify the products, categories, and subcategories contributing most to revenue and gross profit, while identifying areas of weaker profitability.

3. **Evaluate Store Performance:** Compare store-level revenue, gross profit, customer activity, and average order value to understand differences in store performance.

4. **Analyze Customer Behavior:** Examine customer purchasing activity, spending patterns, and repeat purchasing behavior.

5. **Investigate Product Returns:** Analyze return outcomes, refund amounts, return reasons, and their financial impact on recognized revenue.

6. **Support Business Decision-Making:** Present validated findings and practical recommendations through an interactive Power BI dashboard.


## Dataset Overview

The analysis used seven tables from the `reinhardproject.LOTUS_RETAIL` dataset in Google BigQuery. These tables supported data cleaning, validation, business-question investigation, and the development of the Power BI dashboard.

| Table | Description |
|---|---|
| `Customers` | Contains customer information used to examine purchasing activity and customer behavior. |
| `Fact_Order_Details` | Contains product-level order details, including quantities, selling prices, line revenue, and line costs. |
| `Fact_Orders` | Contains order-level information, including order dates, order statuses, and order-related financial values. |
| `Store` | Contains store information used to compare performance across locations. |
| `Product` | Contains product attributes used to analyze performance across categories, subcategories, and brands. |
| `Returns` | Contains return information, including return outcomes, reasons, dates, and return amounts. |
| `Dim_Date` | Provides date attributes used for time-based analysis, filtering, and reporting. |

The seven tables were used to investigate sales performance, profitability, product performance, customer activity, store performance, and the financial impact of product returns.

The original dataset also included an employee table, which was uploaded to BigQuery but excluded from the analysis and Power BI data model.


## Tools and Technologies

| Tool | Purpose |
|---|---|
| **Power Query** | Used for data cleaning and preparation, including correcting data types and addressing data-quality issues. |
| **Google BigQuery (SQL)** | Used for data validation, investigating relationships across tables, analyzing sales and profitability, and answering business questions. |
| **Microsoft Power BI** | Used to build the data model, create DAX measures, develop interactive visuals, and present analytical findings through a dashboard. |


## Data Cleaning and Preparation

Data cleaning and preparation were carried out using Power Query before the data was used for SQL investigation and Power BI reporting.

The main objective was to improve data consistency, correct data types, remove duplicate records, and prepare the tables for reliable analysis.

The following cleaning activities were performed:

### 1. Customer Data

- Applied Trim to customer IDs to remove unwanted whitespace.
- Checked customer ID length and performed a uniqueness check to identify repeated IDs.
- Standardized gender values by applying consistent capitalization.
- Cleaned birth date values and converted them from text into the Date data type using the English (Ghana) locale.
- Removed trailing spaces from phone numbers while retaining the Text data type to preserve leading zeros.
- Converted registration dates from Text to Date.
- Identified and removed 50 excess duplicate records by checking all columns, reducing the customer table from 3,050 to 3,000 rows.

### 2. Date Dimension

- Converted the full date column from Text to Date.
- Changed numeric calendar attributes, including day number, month number, quarter number, year, day of the week, and week of the year, to Whole Number.
- Renamed ambiguous column headers such as `day` and `month` to `day_number` and `month_number` to make their purpose clearer.

These changes prepared the date dimension for sorting, filtering, time-based analysis, and Power BI time intelligence.

### 3. Product Data

- Converted `unit_cost`, `unit_price`, `stock_quantity`, and `is_active` from Text to Whole Number to support calculations and filtering.
- Retained the original `unit_cost_text` column as Text.
- Improved product-name readability by replacing pipe (`|`) separators with double quotation marks (`"`).
- Renamed `product_name_raw` to `product_name`.

### 4. Fact Orders

- Identified leading spaces in the `payment_method` column and applied Trim to standardize the values.
- Consolidated the order records from the separate 2022–2023 and 2024 tables by creating connections to both tables and appending them into a single query named `fact_orders`.

This provided one consolidated order table for analysis across the available period.

### Validation

Following the cleaning activities, the changes were checked to confirm that the intended corrections had been applied. Validation included checking data types, customer ID consistency, duplicate removal, text standardization, and successful table consolidation.

A detailed record of the data quality checks, findings, actions taken, reasons for the changes, and validation results is available in the accompanying Excel cleaning log.

**Supporting document:** [View the Data Cleaning Log](Documentation/Lotus_Retail_Cleaning_Log.xlsx)


## SQL Data Validation and Investigation

Google BigQuery was used to validate the cleaned data, examine relationships between tables, and investigate business questions.

### Data Validation

The following checks were performed:

- Checked order IDs for duplicate and null values.
- Checked customer and store records for consistency and uniqueness.
- Examined relationships between order records, order details, products, customers, stores, and returns.
- Compared financial values between the order-level and product-level tables.
- Investigated differences between recorded order revenue and revenue calculated from individual order details.
- Checked how discounts, order statuses, and return outcomes affected recognized revenue.

### Business Rules and Financial Treatment

Particular attention was given to the treatment of cancelled orders and product returns.

- Cancelled orders were excluded from recognized revenue.
- Completed orders were treated as sales with no recorded return.
- Refunded returns were deducted from recognized revenue.
- Rejected returns were retained in recognized revenue because the refund was not approved.
- Pending returns were treated as unresolved and were not classified as confirmed refunds or rejected returns.

These rules were established to ensure that revenue and profitability calculations reflected the financial outcomes recorded in the dataset.


**SQL queries:** [View the complete SQL analysis](SQL/Lotus_Retail_SQL_Queries.sql)




### Business Question 1: Product Category Performance

**Business Question**

How are the product categories performing in terms of revenue and profitability, and what recommendations can be made to management to improve profitability?


### Findings: Category Performance

Electronics generated the highest revenue (EGP 30.45 million), compared with Clothing (EGP 9.60 million). However, Clothing generated higher gross profit (EGP 4.56 million) than Electronics (EGP 3.96 million).
Clothing also recorded a higher gross profit margin of 47.46%, compared with 13.01% for Electronics. Despite Electronics having a much higher average order value, its lower margin indicates weaker profitability relative to its revenue.

### Further Investigation: Discount Rates

Average discount rates were equal across both categories at 7.88% for electronics and clothing. This suggest that the equal discount range alone does not explain electronics substantially lower gross profit margin.

### Recommendation

Management should investigate the cost structure and selling prices of Electronics products to identify the factors contributing to the lower gross profit margin. Reviewing product pricing and discount practices may help improve profitability while maintaining sales performance.



### Business Question 2: Quarterly Sales and Profitability Performance

**Business Question**

Management requires an analysis of quarterly sales and profitability performance to identify trends, evaluate changes in revenue and profitability over time, and support decisions to improve business performance throughout the year.

### Findings

Quarterly revenue growth varied across the three years. In 2023, revenue declined in Q1 and Q3 but increased in Q2 and Q4. In 2024, revenue recovered in Q1 and Q3, while Q2 experienced a slight decline.

Revenue, gross profit and profit margin did not peak in the same quarter. Q4 2024 generated the highest revenue, Q3 2024 generated the highest gross profit, and Q2 2024 achieved the highest profit margin.

Q1 2024 showed a notable difference between sales and profitability. Average order value increased by approximately 18.9% year over year, while the number of orders declined by approximately 8.5%. Revenue increased by 8.78%, but gross profit fell and profit margin declined from 22.21% to 18.98%.


### Recommendations

Management should monitor quarterly revenue, order volume, average order value, gross profit and margin together to understand changes in sales and profitability. Q1 2024 warrants further investigation into costs and category-level profitability to determine why higher average order value and revenue did not translate into higher gross profit.




### Business Question 3: Financial Impact of Product Returns

**Business Question**

How do product returns affect the company's revenue and profitability, and what actions can management take to reduce their financial impact?


### Findings

Of the 1,056 orders with recorded return requests, 819 (77.56%) were Refunded, representing 3,206,996.50 in return amounts. These refunded orders had an associated original gross profit of 688,688.00 that was no longer retained from those sales, assuming full refunds and that the original product costs remain expenses. Another 150 orders (14.20%) were Pending, representing 402,529.50 in return amounts and 96,079.50 in associated original gross profit. The remaining 87 orders (8.24%) were Rejected, representing 403,586.50 in return amounts; under the established business rule, these amounts remain included in revenue.

### Recommendations

1.**Investigate the main drivers of refunds:** Examine refunded orders by product, category, and store to identify where return activity is concentrated.
2.**Monitor pending requests:** Track outstanding return requests and their value so management can resolve them promptly and assess their eventual financial impact.
3.**Reduce avoidable returns:** Investigate the reasons for returns, where available, and consider targeted actions such as improving product descriptions, quality checks, or customer guidance.


## Power BI Dashboard


### 1. Executive Overview

Provides a high-level summary of Lotus Retail's overall performance through key performance indicators, revenue trends, category performance, and key business insights. Year, category and store filters allow us to explore performance across different business dimensions.


### 2. Product Performance

Examines product and subcategory performance using revenue, gross profit, profit margin, units sold, and average selling price. The page highlights top-performing products and subcategories, helping management identify major revenue contributors and areas where profitability could be improved.


### 3. Store & Customer Performance

Evaluates performance across store locations and customer purchasing activity. The page compares store revenue, gross profit contribution, average order value, customer counts, and ordering patterns to identify differences in store performance and customer behavior.


### 4. Returns & Financial Impact

Examines product return outcomes and their financial implications. The page analyses refunded, rejected, and pending return requests, refund amounts, return reasons, and trends to help management understand the impact of returns and identify opportunities to reduce avoidable refunds.

![Executive Overview](Screenshots/01_Executive_Overview.png)


## Project Files

The project repository is organised into the following folders and files:

| Folder/File | Description |
|---|---|
| `README.md` | Project overview, business objectives, analytical findings, recommendations, and dashboard documentation. |
| `SQL/` | Contains the SQL queries used for data validation and business-question investigations. |
| `Documentation/` | Contains the Excel data cleaning log documenting data-quality checks, cleaning actions, and validation results. |
| `PowerBI/` | Contains the Power BI report file (`.pbix`). |
| `Screenshots/` | Contains screenshots of the four dashboard pages and the Power BI data model. |




