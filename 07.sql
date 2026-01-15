-- Data Aggregation - Lab

-- 1. Departments Info
SELECT department_id,
	COUNT(*) AS `Number of employees` -- преброява служителите във всеки отдел
FROM `employees`
GROUP BY department_id -- групира служителите по отдели
ORDER BY department_id, `Number of employees`;  -- сортира първо по id на отдел, след това по служител

-- 2. Average Salary
SELECT department_id,
	ROUND(AVG(salary), 2) AS `Average Salary` -- закръглява резултата до втория знак след десетичната запетая
FROM `employees`
GROUP BY department_id
ORDER BY department_id ASC;    

-- 3. Minimum Salary
SELECT department_id,
	ROUND(MIN(salary), 2) AS `Min Salary` -- намира минималната заплата във всеки отдел и закръгля до 2-рия знак 
FROM `employees`
GROUP BY department_id   -- групира служителите по отдели
HAVING MIN(salary) > 800 -- филтрира само отдели, чиято минимална заплата е по-висока от 800
ORDER BY department_id;   

-- 4. Appetizers Count
SELECT
	COUNT(*) AS `Appetizers Cnt`
FROM `products`
	WHERE category_id = 2
    AND price > 8;
    
-- 5. Menu Prices
SELECT  category_id,
    ROUND(AVG(price), 2) AS `Average Price`,
    ROUND(MIN(price), 2) AS `Cheapest Product`,
    ROUND(MAX(price), 2) AS `Most Expensive Product`
FROM `products`
GROUP BY category_id
ORDER BY category_id;    
