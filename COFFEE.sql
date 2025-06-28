CREATE DATABASE COFFEE_SHOP_SALES_db;
USE COFFEE_SHOP_SALES_db;

SELECT * FROM coffee_shop_sales;
 
 DESCRIBE COFFEE_SHOP_SALES;
 
 -- changing datatype of transaction_date and transaction_time 
 
 SET SQL_SAFE_UPDATES = 0;
 UPDATE COFFEE_SHOP_SALES
 SET TRANSACTION_DATE = str_to_date(TRANSACTION_DATE, '%d-%m-%Y');
 
 ALTER TABLE COFFEE_SHOP_SALES
 MODIFY COLUMN TRANSACTION_DATE DATE;
 
 UPDATE COFFEE_SHOP_SALES
 SET TRANSACTION_TIME = str_to_date(TRANSACTION_TIME, '%H:%i:%s');
 
 ALTER TABLE COFFEE_SHOP_SALES
 MODIFY COLUMN TRANSACTION_TIME TIME;
 
-- change column name 
 
 ALTER TABLE COFFEE_SHOP_SALES 
 CHANGE COLUMN ï»¿transaction_id transaction_id int;
 
 DESCRIBE COFFEE_SHOP_SALES;
 
 SELECT * FROM coffee_shop_sales;
 
-- TOTAL SALES BY MONTH
 SELECT month(TRANSACTION_DATE) AS MONTH, ROUND(SUM(unit_price * transaction_qty),2) AS TOTAL_SALES
 FROM coffee_shop_sales
 group by month(TRANSACTION_DATE);

-- MONTH SALES DIFFERENCE
-- SELECTED MONTH / CURRENT MONTH(CM) - 5 MAY
-- PREVIOUS MONTH - 4 APRIL

SELECT month(TRANSACTION_DATE) AS MONTH, -- month
ROUND(SUM(unit_price * transaction_qty)) AS TOTAL_SALES,
(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- total sales 
OVER(ORDER BY MONTH(TRANSACTION_DATE))) / LAG(SUM(unit_price * transaction_qty), 1) -- month sales difference 
OVER(ORDER BY MONTH(TRANSACTION_DATE)) * 100 AS MOM_INCERSE_PRECENTAGE -- division by pervisus month sales 
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) IN (4,5)  -- for apirl and may month
GROUP BY MONTH(TRANSACTION_DATE)
ORDER BY MONTH(TRANSACTION_DATE);

-- TOTAL ORDERS BY MONTH 

SELECT count(transaction_id) AS TOTAL_ORDERS 
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 3; -- MARCH MONTH

-- MONTH SALES DIFFERENCE
-- SELECTED MONTH / CURRENT MONTH(CM) - 5 MAY
-- PREVIOUS MONTH - 4 APRIL

SELECT month(TRANSACTION_DATE) AS MONTH, -- month
ROUND(COUNT(transaction_id)) AS TOTAL_ORDERS, -- TOTAL ORDERS
(COUNT(transaction_id) - LAG(COUNT(transaction_id), 1)  
OVER(ORDER BY MONTH(TRANSACTION_DATE))) / LAG(COUNT(transaction_id), 1) -- month ORDERS difference 
OVER(ORDER BY MONTH(TRANSACTION_DATE)) * 100 AS MOM_INCERSE_PRECENTAGE -- division by pervisus month sales 
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) IN (4,5)  -- for apirl and may month
GROUP BY MONTH(TRANSACTION_DATE)
ORDER BY MONTH(TRANSACTION_DATE);

-- TOTAL QUANTITY SOLD BY MONTH 

SELECT SUM(transaction_QTY) AS TOTAL_QUANITY_SOLD 
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 6; -- june MONTH

-- MONTH TOTAL QUANTITY SOLD DIFFERENCE
-- SELECTED MONTH / CURRENT MONTH(CM) - 5 MAY
-- PREVIOUS MONTH - 4 APRIL

SELECT month(TRANSACTION_DATE) AS MONTH, -- month
ROUND(SUM(transaction_QTY)) AS TOTAL_QUANITY_SOLD, -- TOTAL QUANITY_SOLD 
(SUM(transaction_QTY) - LAG(SUM(transaction_QTY), 1)  
OVER(ORDER BY MONTH(TRANSACTION_DATE))) / LAG(SUM(transaction_QTY), 1) -- month ORDERS difference 
OVER(ORDER BY MONTH(TRANSACTION_DATE)) * 100 AS MOM_INCERSE_PRECENTAGE -- division by pervisus month sales 
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) IN (4,5)  -- for apirl and may month
GROUP BY MONTH(TRANSACTION_DATE)
ORDER BY MONTH(TRANSACTION_DATE);

-- total sales, total quantity sold, total order by date

SELECT 
concat(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS TOTAL_SALES,
concat(ROUND(sum(transaction_qty)/1000,1),'K') AS TOTAL_QTY_SOLD,
concat(ROUND(COUNT(transaction_id)/1000,1),'K') AS TOTAL_ORDERS
FROM coffee_shop_sales
WHERE TRANSACTION_DATE = '2023-03-27';

-- WEEKENDS AND WEEKDAYS SALES
-- WEEKDAYS - MON TO FRI 2,3,4,5,6
-- WEEKENDS - SAT & SUN 1, 7

SELECT 
	CASE WHEN dayofweek(TRANSACTION_DATE) IN (1,7) THEN 'WEEKENDS'
    ELSE 'WEEKDAYS'
    END AS DAY_TYPE,
    concat(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 5
GROUP BY CASE WHEN dayofweek(TRANSACTION_DATE) IN (1,7) THEN 'WEEKENDS'
    ELSE 'WEEKDAYS'
    END;
    
-- SALES BY STORE LOCATION
SELECT STORE_LOCATION,
concat(ROUND(SUM(unit_price*transaction_qty)/1000,2),'K') AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 6 -- JUNE MONTH
GROUP BY STORE_LOCATION
ORDER BY SUM(unit_price*transaction_qty) DESC ;


SELECT concat(ROUND(AVG(TOTAL_SALES)/1000,1),'K') AS AVG_SALES
FROM 
	(SELECT SUM(unit_price*transaction_qty) AS TOTAL_SALES
	FROM coffee_shop_sales
	WHERE MONTH(TRANSACTION_DATE) = 4
	GROUP BY TRANSACTION_DATE) AS INNER_QUERY;
    
SELECT day(TRANSACTION_DATE) AS DAY_OF_MONTH,
concat(ROUND(SUM(unit_price*transaction_qty)/1000,2),'K') AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 5
group by DAY(TRANSACTION_DATE)
order by DAY(TRANSACTION_DATE);

SELECT DAY_OF_MONTH,
CASE 
	WHEN TOTAL_SALES > AVG_SALES THEN 'ABOVE AVERAGE'
    WHEN TOTAL_SALES < AVG_SALES THEN 'BELOW AVERAGE'
    ELSE 'EQUAL TO AVERAGE'
    END AS SALES_STATUS,
    TOTAL_SALES
FROM 
(SELECT
	DAY(TRANSACTION_DATE) AS DAY_OF_MONTH,
    SUM(unit_price*transaction_qty) AS TOTAL_SALES,
    AVG(SUM(unit_price*transaction_qty)) OVER() AS AVG_SALES
FROM COFFEE_SHOP_SALES
WHERE MONTH(TRANSACTION_DATE) = 5
GROUP BY DAY(TRANSACTION_DATE)) SALES_DATA
ORDER BY DAY_OF_MONTH;

-- SALES WITH RESEPCT TO PRODUCT
SELECT product_category,
concat(ROUND(SUM(unit_price*transaction_qty)/1000,2),'K') AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 5
GROUP BY product_category
ORDER BY SUM(unit_price*transaction_qty) DESC ;

-- TOP 10 PRODUCTS BY SALES
SELECT product_TYPE,
concat(ROUND(SUM(unit_price*transaction_qty)/1000,2),'K') AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 5 AND PRODUCT_CATEGORY = 'COFFEE'
GROUP BY product_TYPE
ORDER BY SUM(unit_price*transaction_qty) DESC
LIMIT 10; 

-- SALES BY DAYS AND HOURS 
SELECT
concat(ROUND(SUM(unit_price*transaction_qty)/1000,2),'K') AS TOTAL_SALES,
SUM(TRANSACTION_QTY) AS TOTAL_QTY_SOLD,
COUNT(*) AS TOTAL_ORDERS
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 5 -- MAY
AND dayofweek(TRANSACTION_DATE) = 1 -- MONDAY
AND HOUR(TRANSACTION_TIME) = 14; -- HOUR OF 8


SELECT 
HOUR(TRANSACTION_TIME) AS HOURS,
concat(ROUND(SUM(unit_price*transaction_qty)/1000,2),'K') AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(TRANSACTION_DATE) = 5
GROUP BY HOUR(TRANSACTION_TIME)
ORDER BY HOUR(TRANSACTION_TIME);

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
