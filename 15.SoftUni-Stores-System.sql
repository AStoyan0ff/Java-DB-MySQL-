-- MySQL Exam - 17 Oct 2020 part 1 [SoftUni Stores System]

CREATE DATABASE `sss`;
USE `sss`;

-- 01. Table Design

CREATE TABLE `pictures` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    url VARCHAR(100) NOT NULL,
    added_on DATETIME NOT NULL
);

CREATE TABLE `categories` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE,
    best_before DATE,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    picture_id INT NOT NULL,
    
    FOREIGN KEY (category_id) REFERENCES `categories`(id),
    FOREIGN KEY (picture_id) REFERENCES `pictures`(id)
);

CREATE TABLE `towns` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE `addresses` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    town_id INT NOT NULL,
    
    FOREIGN KEY (town_id) REFERENCES `towns`(id)
);

CREATE TABLE `stores` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL UNIQUE,
    rating FLOAT NOT NULL,
    has_parking BOOLEAN DEFAULT FALSE,
    address_id INT NOT NULL,
    
    FOREIGN KEY (address_id) REFERENCES `addresses`(id)
);

CREATE TABLE `products_stores` (
	product_id INT NOT NULL,
    store_id INT NOT NULL,
    
    PRIMARY KEY (product_id, store_id)
);

CREATE TABLE `employees` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(15) NOT NULL,
    middle_name CHAR(1),
    last_name VARCHAR(20) NOT NULL,
    salary DECIMAL(19, 2) NOT NULL DEFAULT 0,
    hire_date DATE NOT NULL,
    manager_id INT,
    store_id INT NOT NULL,
    
    FOREIGN KEY (manager_id) REFERENCES `employees`(id),
    FOREIGN KEY (store_id) REFERENCES `stores`(id)
);

-- MySQL Exam - 18 Oct 2020 part 2  [SoftUni Stores System]

USE `sss`;

-- 02. INSERT

INSERT INTO `products_stores` (product_id, store_id)
SELECT p.id, 1
FROM `products` p
LEFT JOIN `products_stores` ps
	ON p.id = ps.product_id
WHERE ps.product_id IS NULL;    

-- 03. UPDATE

SELECT e.*
FROM `employees` e
JOIN `stores` st 
	ON e.store_id = st.id
WHERE e.hire_date > '2003-12-31'
AND st.name NOT IN ('Cardguard', 'Veribet');


UPDATE `employees` e
JOIN `stores` st
	ON e.store_id = st.id
SET e.manager_id = 3, e.salary = e.salary - 500
WHERE e.hire_date > '2003-12-31' 
AND st.name NOT IN ('Cardguard', 'Veribet');    

-- 04. DELETE

SELECT e.*
FROM `employees` e
LEFT JOIN `employees` m
	ON m.manager_id = e.id
WHERE e.manager_id IS NOT NULL
AND e.salary >= 6000
AND m.id IS NULL;


DELETE e
FROM `employees` e
LEFT JOIN `employees` m
    ON m.manager_id = e.id
WHERE e.manager_id IS NOT NULL
AND e.salary >= 6000
AND m.id IS NULL;

-- 05. Employees 

SELECT 
	e.first_name AS 'First-Name',
    e.middle_name AS 'Middle-Name',
    e.last_name AS 'Last-Name',
    e.salary AS 'Salary', 
    e.hire_date AS 'Hire-Date'
FROM `employees` e
ORDER BY e.hire_date DESC;

-- 06. Products with old pictures

SELECT
	p.name AS 'Product-Name',
    p.price AS 'Price',
    p.best_before AS 'Best-Before',
    CONCAT(SUBSTRING(p.description, 1, 10), '...') AS 'Short-Desc',
    pic.url AS 'URL'
FROM `products` p 
JOIN `pictures` pic
	ON p.picture_id = pic.id
WHERE CHAR_LENGTH(p.description) > 100
AND YEAR(pic.added_on) < 2019
AND p.price > 20
ORDER BY p.price DESC;  

-- 07. Counts of products in stores

SELECT
    t.name,
    t.product_count,
    t.avg
FROM 
(
    SELECT s.id, s.name,
        COUNT(ps.product_id) AS product_count,
        ROUND(AVG(p.price), 2) AS avg
    FROM `stores` s
    LEFT JOIN `products_stores` ps
        ON s.id = ps.store_id
    LEFT JOIN `products` p
        ON ps.product_id = p.id
    GROUP BY s.id, s.name
) AS t
ORDER BY
    t.product_count DESC,
    t.avg DESC,
    t.id;

-- 08. Specific employee

SELECT
    CONCAT_WS(' ', e.first_name, e.last_name) AS 'Full-Name',
    s.name AS 'Store-Name',
    a.name AS 'Address',
    e.salary AS 'Salary'
FROM `employees` e
JOIN `stores` s ON e.store_id = s.id
JOIN `addresses` a ON a.id = s.id
WHERE e.salary < 4000
AND a.name LIKE '%5%'
AND CHAR_LENGTH(s.name) > 8
AND e.last_name LIKE '%n';


-- 09. Find all information of stores

SELECT
    REVERSE(s.name) AS `Reversed-Names`,
    CONCAT(UPPER(t.name), '-', a.name) AS `Full-Addresses`,
    COUNT(e.id) AS `Employee-Counts`
FROM `stores` s
JOIN `addresses` a ON s.address_id = a.id
JOIN `towns` t ON a.town_id = t.id
JOIN `employees` e ON s.id = e.store_id
GROUP BY s.id, s.name, a.name, t.name
HAVING `Employee-Counts` >= 1
ORDER BY `Full-Addresses`;
     
-- 10. Find name of top paid employee by store name

DELIMITER $$

CREATE FUNCTION `udf_top_paid_employee_by_store`(store_name VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(100);
    
    SELECT 
        CONCAT
		(	
			e.first_name, ' ', e.middle_name, '. ',  e.last_name,
            ' works in store for ', 
            FLOOR(DATEDIFF('2020-10-18', e.hire_date) / 365), 
            ' years'
        ) INTO result
    FROM `employees` e
    JOIN `stores` s ON e.store_id = s.id
    WHERE s.name = store_name
    ORDER BY e.salary DESC
    LIMIT 1;
    
    RETURN result;
END $$

DELIMITER ;

-- 11. Update product price by address  

DELIMITER $$

CREATE PROCEDURE `udp_update_product_price`(address_name VARCHAR(50))
BEGIN
    UPDATE `products` p
		JOIN `products_stores` ps ON p.id = ps.product_id
		JOIN `stores` s ON ps.store_id = s.id
		JOIN `addresses` a ON s.address_id = a.id
    SET p.price = 
        CASE 
            WHEN LEFT(a.name, 1) = '0' THEN p.price + 100
            ELSE p.price + 200
        END
    WHERE a.name = address_name;
END $$

DELIMITER ;


