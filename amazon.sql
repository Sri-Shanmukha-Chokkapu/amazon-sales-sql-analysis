/* 
============================================================
SQL Capstone Project - Amazon Sales Data Analysis
Author: Sri Shanmukha Chokkapu
Project Type: SQL and Business Analytics Capstone
============================================================

Purpose:
The primary objective of this capstone project is to analyze Amazon sales data
from three branches and extract insights related to product performance,
sales trends, customer behavior, revenue, VAT, gross income, and ratings.

Dataset:
The dataset contains 1,000 sales transactions from three branches located in:
- Mandalay
- Yangon
- Naypyitaw

The dataset includes 17 columns related to invoices, branches, customers,
products, revenue, payment methods, VAT, gross income, and ratings.

============================================================
*/


/* 
============================================================
1. DATABASE CREATION
============================================================
*/

DROP DATABASE IF EXISTS capstone_project;

CREATE DATABASE capstone_project;

USE capstone_project;


/* 
============================================================
2. TABLE CREATION
============================================================

Note:
After creating this table, import the Amazon.csv file using MySQL Table Data Import Wizard.
Encoding used: UTF-8
*/

CREATE TABLE amazon (
    invoice_id VARCHAR(30) NOT NULL,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT DECIMAL(10,4) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage DECIMAL(11,9) NOT NULL,
    gross_income DECIMAL(10,2) NOT NULL,
    rating DECIMAL(3,1) NOT NULL
);


/* 
============================================================
3. DATA CHECKS
============================================================

Run these checks after importing the CSV file.
*/

SELECT * 
FROM amazon
LIMIT 10;

SELECT COUNT(*) AS total_rows
FROM amazon;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(invoice_id) AS invoice_id_count,
    COUNT(branch) AS branch_count,
    COUNT(city) AS city_count,
    COUNT(customer_type) AS customer_type_count,
    COUNT(gender) AS gender_count,
    COUNT(product_line) AS product_line_count,
    COUNT(unit_price) AS unit_price_count,
    COUNT(quantity) AS quantity_count,
    COUNT(VAT) AS VAT_count,
    COUNT(total) AS total_count,
    COUNT(date) AS date_count,
    COUNT(time) AS time_count,
    COUNT(payment_method) AS payment_method_count,
    COUNT(cogs) AS cogs_count,
    COUNT(gross_margin_percentage) AS gross_margin_percentage_count,
    COUNT(gross_income) AS gross_income_count,
    COUNT(rating) AS rating_count
FROM amazon;


/*
Null check:
Since all fields were created as NOT NULL, the table should not contain NULL values
if the import is successful.
*/

SELECT *
FROM amazon
WHERE invoice_id IS NULL
   OR branch IS NULL
   OR city IS NULL
   OR customer_type IS NULL
   OR gender IS NULL
   OR product_line IS NULL
   OR unit_price IS NULL
   OR quantity IS NULL
   OR VAT IS NULL
   OR total IS NULL
   OR date IS NULL
   OR time IS NULL
   OR payment_method IS NULL
   OR cogs IS NULL
   OR gross_margin_percentage IS NULL
   OR gross_income IS NULL
   OR rating IS NULL;


/* 
============================================================
4. FEATURE ENGINEERING
============================================================

New fields:
1. time_of_day: Morning, Afternoon, Evening
2. day_name: Day of week
3. month_name: Month of year
*/

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE amazon
ADD COLUMN time_of_day VARCHAR(20);

UPDATE amazon
SET time_of_day = 
    CASE 
        WHEN time BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END;


ALTER TABLE amazon
ADD COLUMN day_name VARCHAR(10);

UPDATE amazon
SET day_name = DAYNAME(date);


ALTER TABLE amazon
ADD COLUMN month_name VARCHAR(12);

UPDATE amazon
SET month_name = MONTHNAME(date);


/*
Check engineered columns.
*/

SELECT 
    invoice_id,
    date,
    time,
    time_of_day,
    day_name,
    month_name
FROM amazon
LIMIT 20;


/* 
============================================================
5. BUSINESS QUESTIONS AND ANALYSIS
============================================================
*/


/* 
------------------------------------------------------------
Q1. What is the count of distinct cities in the dataset?
------------------------------------------------------------
*/

SELECT 
    COUNT(DISTINCT city) AS number_of_cities
FROM amazon;

-- Insight: There are 3 distinct cities in the dataset.


/* 
------------------------------------------------------------
Q2. For each branch, what is the corresponding city?
------------------------------------------------------------
*/

SELECT DISTINCT 
    branch,
    city
FROM amazon
ORDER BY branch;

-- Insight: Each branch corresponds to one city.


/* 
------------------------------------------------------------
Q3. What is the count of distinct product lines in the dataset?
------------------------------------------------------------
*/

SELECT 
    COUNT(DISTINCT product_line) AS product_line_count
FROM amazon;

-- Insight: There are 6 distinct product lines.


/* 
------------------------------------------------------------
Q4. Which payment method occurs most frequently?
------------------------------------------------------------
*/

SELECT 
    payment_method,
    COUNT(*) AS frequency_count
FROM amazon
GROUP BY payment_method
ORDER BY frequency_count DESC;

-- Insight: This shows the most frequently used payment method.


/* 
------------------------------------------------------------
Q5. Which product line has the highest quantity sold?
------------------------------------------------------------
*/

SELECT 
    product_line,
    SUM(quantity) AS total_quantity_sold
FROM amazon
GROUP BY product_line
ORDER BY total_quantity_sold DESC
LIMIT 1;

-- Insight: This identifies the product line with the highest sales volume.


/* 
------------------------------------------------------------
Q6. How much revenue is generated each month?
------------------------------------------------------------
*/

SELECT 
    month_name,
    ROUND(SUM(total), 2) AS total_revenue
FROM amazon
GROUP BY month_name
ORDER BY total_revenue DESC;

-- Insight: This shows monthly revenue performance.


/* 
------------------------------------------------------------
Q7. In which month did the cost of goods sold reach its peak?
------------------------------------------------------------
*/

SELECT 
    month_name,
    ROUND(SUM(cogs), 2) AS total_cogs
FROM amazon
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- Insight: This identifies the month with the highest cost of goods sold.


/* 
------------------------------------------------------------
Q8. Which product line generated the highest revenue?
------------------------------------------------------------
*/

SELECT 
    product_line,
    ROUND(SUM(total), 2) AS total_revenue
FROM amazon
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- Insight: This identifies the highest revenue-generating product line.


/* 
------------------------------------------------------------
Q9. Which city recorded the highest revenue?
------------------------------------------------------------
*/

SELECT 
    city,
    ROUND(SUM(total), 2) AS total_revenue
FROM amazon
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- Insight: This identifies the city with the highest revenue.


/* 
------------------------------------------------------------
Q10. Which product line generated the highest VAT amount?
------------------------------------------------------------

Note:
This query calculates the highest total VAT amount, not VAT percentage.
*/

SELECT 
    product_line,
    ROUND(SUM(VAT), 2) AS total_VAT
FROM amazon
GROUP BY product_line
ORDER BY total_VAT DESC
LIMIT 1;

-- Insight: This identifies the product line with the highest VAT amount.


/* 
------------------------------------------------------------
Q11. For each product line, classify performance as Good or Bad
based on whether total quantity sold is above or below the
average total quantity sold across product lines.
------------------------------------------------------------

Correct logic:
Compare product line total sales against the average product line total,
not against average transaction quantity.
*/

WITH product_sales AS (
    SELECT 
        product_line,
        SUM(quantity) AS total_quantity_sold
    FROM amazon
    GROUP BY product_line
),
average_product_sales AS (
    SELECT 
        AVG(total_quantity_sold) AS average_quantity_sold
    FROM product_sales
)
SELECT 
    ps.product_line,
    ps.total_quantity_sold,
    ROUND(aps.average_quantity_sold, 2) AS average_quantity_sold,
    CASE 
        WHEN ps.total_quantity_sold > aps.average_quantity_sold THEN 'Good'
        ELSE 'Bad'
    END AS sales_performance
FROM product_sales ps
CROSS JOIN average_product_sales aps
ORDER BY ps.total_quantity_sold DESC;


/* 
------------------------------------------------------------
Q12. Identify the branch that exceeded the average number of
products sold across branches.
------------------------------------------------------------

Correct logic:
Compare branch total quantity against average branch total quantity.
*/

WITH branch_sales AS (
    SELECT 
        branch,
        city,
        SUM(quantity) AS total_quantity_sold
    FROM amazon
    GROUP BY branch, city
),
average_branch_sales AS (
    SELECT 
        AVG(total_quantity_sold) AS average_branch_quantity
    FROM branch_sales
)
SELECT 
    bs.branch,
    bs.city,
    bs.total_quantity_sold,
    ROUND(abs.average_branch_quantity, 2) AS average_branch_quantity
FROM branch_sales bs
CROSS JOIN average_branch_sales abs
WHERE bs.total_quantity_sold > abs.average_branch_quantity
ORDER BY bs.total_quantity_sold DESC;


/* 
------------------------------------------------------------
Q13. Which product line is most frequently associated with each gender?
------------------------------------------------------------
*/

WITH ranked_products AS (
    SELECT 
        gender,
        product_line,
        COUNT(invoice_id) AS total_purchases,
        RANK() OVER (
            PARTITION BY gender 
            ORDER BY COUNT(invoice_id) DESC
        ) AS product_rank
    FROM amazon
    GROUP BY gender, product_line
)
SELECT 
    gender,
    product_line,
    total_purchases
FROM ranked_products
WHERE product_rank = 1;


/* 
------------------------------------------------------------
Q14. Calculate the average rating for each product line.
------------------------------------------------------------
*/

SELECT 
    product_line,
    ROUND(AVG(rating), 2) AS average_rating
FROM amazon
GROUP BY product_line
ORDER BY average_rating DESC;

-- Insight: This shows which product lines have stronger customer satisfaction.


/* 
------------------------------------------------------------
Q15. Count sales occurrences for each time of day on every weekday.
------------------------------------------------------------
*/

SELECT 
    day_name,
    time_of_day,
    COUNT(*) AS sales_count
FROM amazon
GROUP BY day_name, time_of_day
ORDER BY sales_count DESC;

-- Insight: This identifies when the most sales transactions occur.


/* 
------------------------------------------------------------
Q16. Which customer type contributes the highest revenue?
------------------------------------------------------------
*/

SELECT 
    customer_type,
    ROUND(SUM(total), 2) AS total_revenue
FROM amazon
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- Insight: This identifies the most valuable customer type by revenue.


/* 
------------------------------------------------------------
Q17. Which city generated the highest VAT amount?
------------------------------------------------------------

Note:
This is VAT amount, not VAT percentage.
*/

SELECT 
    city,
    ROUND(SUM(VAT), 2) AS total_VAT
FROM amazon
GROUP BY city
ORDER BY total_VAT DESC
LIMIT 1;

-- Insight: This identifies the city with the highest total VAT amount.


/* 
------------------------------------------------------------
Q18. Which customer type generated the highest VAT amount?
------------------------------------------------------------
*/

SELECT 
    customer_type,
    ROUND(SUM(VAT), 2) AS total_VAT
FROM amazon
GROUP BY customer_type
ORDER BY total_VAT DESC
LIMIT 1;

-- Insight: This identifies the customer type with the highest VAT contribution.


/* 
------------------------------------------------------------
Q19. What is the count of distinct customer types in the dataset?
------------------------------------------------------------
*/

SELECT 
    COUNT(DISTINCT customer_type) AS customer_type_count
FROM amazon;

-- Insight: This shows the number of customer categories.


/* 
------------------------------------------------------------
Q20. What is the count of distinct payment methods in the dataset?
------------------------------------------------------------
*/

SELECT 
    COUNT(DISTINCT payment_method) AS payment_method_count
FROM amazon;

-- Insight: This shows the number of payment methods used.


/* 
------------------------------------------------------------
Q21. Which customer type occurs most frequently?
------------------------------------------------------------
*/

SELECT 
    customer_type,
    COUNT(*) AS frequency_count
FROM amazon
GROUP BY customer_type
ORDER BY frequency_count DESC
LIMIT 1;

-- Insight: This shows the most frequent customer type.


/* 
------------------------------------------------------------
Q22. Which customer type has the highest purchase frequency?
------------------------------------------------------------
*/

SELECT 
    customer_type,
    COUNT(invoice_id) AS purchase_frequency
FROM amazon
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

-- Insight: This identifies the customer type with the most purchases.


/* 
------------------------------------------------------------
Q23. What is the predominant gender among customers?
------------------------------------------------------------
*/

SELECT 
    gender,
    COUNT(*) AS gender_count
FROM amazon
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 1;

-- Insight: This identifies the most represented customer gender.


/* 
------------------------------------------------------------
Q24. What is the gender distribution within each branch?
------------------------------------------------------------
*/

SELECT 
    branch,
    city,
    gender,
    COUNT(*) AS gender_count
FROM amazon
GROUP BY branch, city, gender
ORDER BY branch, gender;

-- Insight: This compares gender distribution across branches.


/* 
------------------------------------------------------------
Q25. Which time of day has the highest number of ratings?
------------------------------------------------------------

This measures rating count, not average rating score.
*/

SELECT 
    time_of_day,
    COUNT(rating) AS rating_count
FROM amazon
GROUP BY time_of_day
ORDER BY rating_count DESC;

-- Insight: This identifies when customers most frequently provide ratings.


/* 
------------------------------------------------------------
Q26. Which time of day has the highest average rating?
------------------------------------------------------------

This measures average rating score.
*/

SELECT 
    time_of_day,
    ROUND(AVG(rating), 2) AS average_rating
FROM amazon
GROUP BY time_of_day
ORDER BY average_rating DESC;

-- Insight: This identifies the time period with the highest average customer satisfaction.


/* 
------------------------------------------------------------
Q27. Which time of day has the highest average rating for each branch?
------------------------------------------------------------
*/

WITH branch_time_rating AS (
    SELECT 
        branch,
        city,
        time_of_day,
        ROUND(AVG(rating), 2) AS average_rating,
        RANK() OVER (
            PARTITION BY branch 
            ORDER BY AVG(rating) DESC
        ) AS rating_rank
    FROM amazon
    GROUP BY branch, city, time_of_day
)
SELECT 
    branch,
    city,
    time_of_day,
    average_rating
FROM branch_time_rating
WHERE rating_rank = 1
ORDER BY branch;

-- Insight: This identifies the best-rated time of day for each branch.


/* 
------------------------------------------------------------
Q28. Which day of the week has the highest average rating?
------------------------------------------------------------
*/

SELECT 
    day_name,
    ROUND(AVG(rating), 2) AS average_rating
FROM amazon
GROUP BY day_name
ORDER BY average_rating DESC
LIMIT 1;

-- Insight: This identifies the day with the highest average customer rating.


/* 
------------------------------------------------------------
Q29. Which day of the week has the highest average rating for each branch?
------------------------------------------------------------
*/

WITH branch_day_rating AS (
    SELECT
        branch,
        city,
        day_name,
        ROUND(AVG(rating), 2) AS average_rating,
        RANK() OVER (
            PARTITION BY branch 
            ORDER BY AVG(rating) DESC
        ) AS rating_rank
    FROM amazon
    GROUP BY branch, city, day_name
)
SELECT 
    branch,
    city,
    day_name,
    average_rating
FROM branch_day_rating
WHERE rating_rank = 1
ORDER BY branch;

-- Insight: This identifies the best-rated day for each branch.


/* 
------------------------------------------------------------
Q30. Which branch generated the highest revenue?
------------------------------------------------------------
*/

SELECT 
    branch,
    city,
    ROUND(SUM(total), 2) AS total_revenue
FROM amazon
GROUP BY branch, city
ORDER BY total_revenue DESC
LIMIT 1;


/* 
------------------------------------------------------------
Q31. Which branch generated the highest gross income?
------------------------------------------------------------
*/

SELECT 
    branch,
    city,
    ROUND(SUM(gross_income), 2) AS total_gross_income
FROM amazon
GROUP BY branch, city
ORDER BY total_gross_income DESC
LIMIT 1;


/* 
------------------------------------------------------------
Q32. Which product line generated the highest gross income?
------------------------------------------------------------
*/

SELECT 
    product_line,
    ROUND(SUM(gross_income), 2) AS total_gross_income
FROM amazon
GROUP BY product_line
ORDER BY total_gross_income DESC
LIMIT 1;


/* 
------------------------------------------------------------
Q33. What is the average rating by city?
------------------------------------------------------------
*/

SELECT 
    city,
    ROUND(AVG(rating), 2) AS average_rating
FROM amazon
GROUP BY city
ORDER BY average_rating DESC;


/* 
------------------------------------------------------------
Q34. What is the revenue distribution by gender?
------------------------------------------------------------
*/

SELECT 
    gender,
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(*) AS transaction_count
FROM amazon
GROUP BY gender
ORDER BY total_revenue DESC;


/* 
------------------------------------------------------------
Q35. What is the revenue distribution by payment method?
------------------------------------------------------------
*/

SELECT 
    payment_method,
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(*) AS transaction_count
FROM amazon
GROUP BY payment_method
ORDER BY total_revenue DESC;


/* 
============================================================
6. FINAL ANALYSIS SUMMARY
============================================================

Product Analysis:
- The dataset contains six product lines.
- Product line performance can be evaluated by quantity sold, revenue, VAT, gross income, and rating.
- The highest-selling product line by quantity may differ from the highest revenue-generating product line.
- Average rating by product line helps understand customer satisfaction.

Sales Analysis:
- Monthly revenue and COGS show sales and cost patterns across January, February, and March.
- Time of day, day name, and month name features help identify sales patterns by time period.
- Branch-level revenue and gross income help compare business performance across Mandalay, Yangon, and Naypyitaw.

Customer Analysis:
- Customer type analysis helps identify which customer segment contributes more revenue, VAT, and purchase frequency.
- Gender analysis helps understand customer distribution and revenue contribution.
- Rating analysis by time of day, day of week, branch, and city helps identify customer satisfaction patterns.

Business Use:
- These insights can support decisions related to product line strategy, customer targeting,
  payment method optimization, branch performance monitoring, and promotional timing.

Limitations:
- The dataset includes only 1,000 transactions.
- Data is limited to three branches and a short time period.
- This project is descriptive and exploratory, not predictive.
- The results should be used for business insight generation, not final strategic decisions without more data.

============================================================
END OF SQL CAPSTONE PROJECT
============================================================
*/
