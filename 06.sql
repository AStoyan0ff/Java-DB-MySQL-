-- Exercises: Built-in Functions

-- 01. Find Names of All Employees by First Name 
SELECT first_name, last_name
FROM `employees`
	WHERE lower(first_name) LIKE 'Sa%' -- function()
ORDER BY employee_id;
    
-- 02. Find Names of All Employees by Last Name
SELECT first_name, last_name
FROM `employees`
	WHERE lower(last_name) LIKE '%ei%'
ORDER BY employee_id;
    
-- 03. Find First Names of All Employess
SELECT first_name
FROM `employees`
	WHERE department_id IN (3, 10) 
	AND YEAR(hire_date) 
	BETWEEN 1995 AND 2005
ORDER BY employee_id;    

-- 04. Find All Employees Except Engineers
SELECT first_name, last_name
FROM `employees`
	WHERE lower(job_title) NOT LIKE '%engineer%'
ORDER BY employee_id;   

-- 05. Find Towns with Name Length - Вариант 1
SELECT `name`
FROM `towns`
	WHERE char_length(`name`) IN (5, 6)
ORDER BY `name`;  

-- 05. Find Towns with Name Length - Вариант 2
SELECT `name`
FROM `towns`
	WHERE length(`name`) BETWEEN 5 AND 6
ORDER BY `name`;   

-- 06. Find Towns Starting With - Вариант 1
SELECT town_id, `name`
FROM `towns`
	WHERE `name` LIKE 'M%' OR 
		  `name` LIKE 'K%' OR 
          `name` LIKE 'B%' OR 
          `name` LIKE 'E%'
ORDER BY `name`;

-- 06. Find Towns Starting With - Вариант 2
SELECT town_id, `name`
FROM `towns`
	WHERE left(upper(`name`), 1) IN ('M', 'K', 'B', 'E')
ORDER BY `name`;    

-- 07. Find Towns Not Starting With
SELECT town_id, `name`
FROM `towns`
	WHERE `name` NOT LIKE 'R%' 
	AND `name` NOT LIKE 'B%' 
	AND `name` NOT LIKE 'D%' 
ORDER BY `name`; 

-- 08. Create View Employees Hired After
CREATE VIEW v_employees_hired_after_2000 AS
	SELECT first_name, last_name
    FROM `employees`
		WHERE YEAR(hire_date) > 2000;
        
SELECT * FROM v_employees_hired_after_2000;       

-- 09. Length of Last Name
SELECT first_name, last_name
FROM `employees`
	WHERE length(last_name) = 5
ORDER BY employee_id;    

-- 10. Countries Holding 'A'
SELECT country_name, iso_code
FROM `countries`
	WHERE (length(lower(country_name)) 
		 - length(REPLACE(lower(country_name), 'a', ''))) >= 3
ORDER BY iso_code;    

-- 11. Mix of Peak and River Names - Вариант 1
SELECT p.peak_name, r.river_name,
    lower(concat(p.peak_name, substring(r.river_name, 2))) AS mix
FROM peaks AS p
JOIN rivers AS r
    ON lower(RIGHT(p.peak_name, 1)) = lower(LEFT(r.river_name, 1))
ORDER BY mix;
 
-- 12. Games From 2011 and 2012 Year
SELECT `name`, 
	date_format(start, '%Y-%m-%d') AS start
FROM `games`
	WHERE year(start) IN (2011, 2012)
ORDER BY start, `name`
LIMIT 50;    

-- 13. User Email Providers
SELECT user_name,
	substring_index(email, '@', -1) AS `email provider`
FROM `users`
ORDER BY `email provider`, user_name;    

--  14. Get Users with IP Address Like Pattern
SELECT user_name, ip_address
FROM `users`
	WHERE ip_address LIKE '___.1%.%.___'
ORDER BY user_name;  

-- 15. Show All Games with Duration
SELECT
    `name` AS game,
    CASE
        WHEN HOUR(start) >= 0 AND HOUR(start) < 12 THEN 'Morning'
        WHEN HOUR(start) >= 12 AND HOUR(start) < 18 THEN 'Afternoon'
        WHEN HOUR(start) >= 18 AND HOUR(start) < 24 THEN 'Evening'
    END AS `Part of the Day`,
    CASE
        WHEN duration IS NULL THEN 'Extra Long'
        WHEN duration <= 3 THEN 'Extra Short'
        WHEN duration > 3 AND duration <= 6 THEN 'Short'
        WHEN duration > 6 AND duration <= 10 THEN 'Long'
        ELSE 'Extra Long'
    END AS Duration
FROM `games`
ORDER BY game;

-- 16. Orders Table
CREATE TABLE `orders` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50),
    order_date DATETIME
);

INSERT INTO orders (id, product_name, order_date) 
VALUES
	(1, 'Butter', '2016-09-19 00:00:00'),
	(2, 'Milk', '2016-09-30 00:00:00'),
	(3, 'Cheese', '2016-09-04 00:00:00'),
	(4, 'Bread', '2015-12-20 00:00:00'),
	(5, 'Tomatoes', '2015-01-01 00:00:00');


SELECT product_name, order_date, 
	date_add(order_date, interval 3 DAY) AS pay_due,
	date_add(order_date, interval 1 MONTH) AS delivery_due
FROM `orders`
ORDER BY id;
  
