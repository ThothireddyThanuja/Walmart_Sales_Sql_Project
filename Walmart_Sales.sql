CREATE DATABASE IF NOT EXISTS WALMART_SALES_DATA_ANALYSIS ;

USE WALMART_SALES_DATA_ANALYSIS ;

CREATE TABLE IF NOT EXISTS SALES (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL, 
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL, 
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT DECIMAL(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage DECIMAL(11, 9) NOT NULL,
    gross_income DECIMAL(12, 4) NOT NULL,
    rating DECIMAL(2,1) NOT NULL
);

-- -----------------------------------------------------------------------------------------------------------------
-- -------------------------------------------Feature Engineering --------------------------------------------------

-- time_of_day

SELECT ORDER_TIME,
		(   CASE 
				WHEN ORDER_TIME BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
				WHEN ORDER_TIME BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
				ELSE "Evening"
		     END 
	    ) AS time_of_day
FROM SALES;

ALTER TABLE SALES 
ADD COLUMN time_of_day VARCHAR(20) ;

UPDATE SALES 
SET time_of_day = (
CASE 
		WHEN ORDER_TIME BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN ORDER_TIME BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
END 
);

-- day_name

SELECT ORDER_DATE, DAYNAME(ORDER_DATE) AS day_name
FROM SALES;

ALTER TABLE SALES
ADD COLUMN day_name VARCHAR(10);

UPDATE SALES
SET day_name =  DAYNAME(ORDER_DATE) ;

 -- Month Name

SELECT ORDER_DATE, MONTHNAME(ORDER_DATE) AS month_name
FROM SALES;

ALTER TABLE SALES
ADD COLUMN 	month_name VARCHAR(10);

UPDATE SALES
SET month_name =  MONTHNAME(ORDER_DATE) ;

-- ----------------------------------------------------------------------------------------------------------
-- -------------------------------------------- Exploratory Data Analysis -----------------------------------


-- Generic Questions 

-- 1. How many unique cities does the data have? 

SELECT COUNT(DISTINCT city) AS UNIQUE_CITIES FROM sales ; -- 3

-- 2. In which city is each branch? 

SELECT 
	DISTINCT city,
	branch 
FROM SALES ; 


-- PRODUCT ANALYSIS

-- 1. How many unique product lines does the data have?  -- 6

SELECT 
	COUNT(DISTINCT product_line)
    AS UNIQUE_PRODUCT_LINE
FROM sales ; 

-- 2. What is the most common payment method?

SELECT 
	payment_method,
	COUNT(payment_method) AS Count_of_Payment_Method
FROM sales
GROUP BY payment_method
ORDER BY Count_of_Payment_Method DESC ;

-- 3. What is the most selling product line?

SELECT 
	product_line,
    COUNT(product_line) AS cnt
FROM SALES 
GROUP BY product_line
ORDER BY cnt DESC;

-- 4. What is the total revenue by month?

SELECT 
	month_name ,
    SUM(total) AS Total_Revenue
FROM sales
GROUP BY month_name 
ORDER BY Total_Revenue DESC;

-- 5. What month had the largest COGS?

SELECT 
	month_name AS Month_name,
    SUM(cogs) AS Cost_of_goods
FROM sales 
GROUP BY Month_name
ORDER BY Cost_of_goods DESC ;

-- 6. What product line had the largest revenue? 

SELECT product_line, SUM(total) AS Total_Revenue
FROM sales 
GROUP BY product_line
ORDER BY Total_Revenue DESC;

-- 7. What is the city with the largest revenue?

SELECT branch , city, SUM(total) AS Total_Revenue
FROM sales
GROUP BY city, branch
ORDER BY Total_Revenue DESC;

-- 8. What product line had the largest VAT?

SELECT  product_line, AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line 
ORDER BY avg_tax DESC ;

-- 9. Which branch sold more products than average product sold?

SELECT branch , SUM(quantity) AS Quantity
FROM sales
GROUP BY branch
HAVING Quantity > (SELECT AVG(quantity) FROM sales) ;

-- 10. What is the most common product line by gender?

SELECT product_line, Gender, COUNT(gender) AS cnt
FROM sales
GROUP BY gender, product_line 
ORDER BY cnt DESC;

-- 11. What is the average rating of each product line?

SELECT product_line, ROUND(AVG(rating),2) AS Average_Rating
From Sales
GROUP BY product_line
ORDER BY Average_Rating DESC ;

-- 12. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT product_line , SUM(Quantity) as Total_sales,
		   (CASE  WHEN SUM(QUANTITY) > (SELECT AVG(quantity) FROM sales)  THEN "Good"
				   ELSE "Bad" 
			END) AS Performance_Analysis
FROM sales
GROUP BY product_line
ORDER BY performance_Analysis DESC;

-- ---------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------Sales-------------------------------------------------------------------------

-- 1. Number of sales made in each time of the day per weekday? 

SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = "THURSDAY"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 2. Which of the customer types brings the most revenue?

SELECT Customer_type,
	   SUM(Total) AS Total_Revenue
FROM SALES
GROUP BY customer_type
ORDER BY Total_Revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city , AVG(VAT) as VAT
FROM sales
GROUP  BY City
ORDER BY VAT DESC;
 
 -- 4. Which customer type pays the most in VAT?
 
 SELECT customer_type , ROUND(AVG(VAT),2) AS Average_VAT
 FROM SALES
 GROUP BY customer_type
 ORDER BY Average_VAT DESC;

--      -----------------------------------------------------------------------
--      ----------------------------------Customer Analysis--------------------
               
	-- 1. How many unique customer types does the data have?
    
SELECT DISTINCT customer_type
FROM SALES;

-- 2. What is the most common payment method?

SELECT payment_method , COUNT(payment_method) AS CNT
FROM Sales
GROUP BY payment_method
ORDER BY CNT DESC;

-- 3. What is the most common customer type?

SELECT customer_type , COUNT(customer_type) AS CNT
FROM Sales
GROUP BY customer_type
ORDER BY CNT DESC;

-- 4. Which customer type buys the most? 

SELECT customer_type, COUNT(QUANTITY) AS CNT
FROM sales
GROUP BY customer_type
ORDER BY CNT DESC;

-- 5. What is the gender of most of the customers?

SELECT gender, COUNT(*) AS count_of_gender
FROM SALES
GROUP BY gender
ORDER BY count_of_gender DESC;

-- 6. What is the gender distribution per branch?

SELECT branch, GENDER, COUNT(gender) AS Gender_Distribution
FROM sales
GROUP BY Branch, GENDER
ORDER BY BRANCH, Gender_distribution DESC;

-- 7. Which time of the day do customers give most ratings?

SELECT time_of_day , ROUND(AVG(rating),2) AS Avg_ratings
FROM sales
GROUP BY time_of_day
ORDER BY Avg_ratings DESC;

-- 8. Which time of the day do customers give most ratings per branch?

SELECT Branch ,time_of_day , ROUND(AVG(rating),2) AS Avg_ratings
FROM sales
GROUP BY Branch , time_of_day
ORDER BY branch , Avg_ratings DESC;

-- 9. Which day of the week has the best avg ratings?

SELECT day_name, ROUND(AVG(rating),2) AS ratings
FROM sales
GROUP BY day_name
ORDER BY ratings DESC;

-- 10. Which day of the week has the best average ratings per branch?

SELECT branch , day_name, ROUND(AVG(rating),2) AS Ratings
FROM sales
GROUP BY branch , day_name
ORDER BY branch , ratings DESC;
