-- MySQL Regular Exam - 15 October 2022 

CREATE DATABASE `Restaurant`;
USE `Restaurant`;

-- 01. Table Design 40/40

CREATE TABLE `products` (
	  id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL UNIQUE,
    type VARCHAR(30) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE `clients` (
	  id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birthdate DATE NOT NULL,
    card VARCHAR(50),
    review TEXT
);

CREATE TABLE `tables` (
	  id INT PRIMARY KEY AUTO_INCREMENT,
    floor INT NOT NULL,
    reserved TINYINT(1),
    capacity INT NOT NULL
);

CREATE TABLE `waiters` (
	  id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(50),
    salary DECIMAL(10, 2)
); 

CREATE TABLE `orders` (
	  id INT PRIMARY KEY AUTO_INCREMENT,
    table_id INT NOT NULL,
    waiter_id INT NOT NULL,
    order_time TIME NOT NULL,
    payed_status TINYINT(1),
    
    FOREIGN KEY (table_id) REFERENCES tables(id),
    FOREIGN KEY (waiter_id) REFERENCES waiters(id)
);

CREATE TABLE `orders_clients` (
	  order_id INT,
    client_id INT,
    
	  FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (client_id) REFERENCES clients(id)    
);

CREATE TABLE `orders_products` (
	  order_id INT,
    product_id INT,
        
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 02. INSERT 10/10

INSERT INTO `products` (name, type, price)
SELECT
	  CONCAT(last_name, ' specialty')AS `Cocktail-Name`, 'Cocktail' ,
    CEIL(salary * 0.01) AS `Salary`
FROM `waiters`
WHERE id > 6;    

-- 03. UPDATE 10/10

UPDATE `orders`
	SET table_id = table_id - 1
WHERE id BETWEEN 12 AND 23 AND table_id > 1;    

-- 04. DELETE 10/10 - вариант 1

DELETE w
FROM `waiters` w
LEFT JOIN `orders` o 
	ON w.id = o.waiter_id
WHERE o.id IS NULL;

-- 04. DELETE 10/10 - вариант 2

DELETE FROM `waiters`
WHERE id NOT IN 
(
    SELECT DISTINCT waiter_id
    FROM `orders`
);

-- 05. Clients - вариант 1 - 10/10

SELECT *
FROM `clients`
ORDER BY birthdate DESC, id DESC;    

-- 05. Clients - вариант 2 10/10

SELECT 
    id,
    first_name,
    last_name,
    birthdate,
    card,
    review
FROM `clients`
ORDER BY birthdate DESC;
    
-- 06. Birthdate 10/10

SELECT
    first_name, 
    last_name,
    birthdate,
    review
FROM `clients`
WHERE card IS NULL 
AND YEAR(birthdate) BETWEEN 1978 AND 1993
ORDER BY last_name DESC, id ASC
LIMIT 5;    

-- 7 Accounts 10/10

SELECT
	  CONCAT(last_name, first_name, 
    CHAR_LENGTH(first_name), 'Restaurant') AS username,
    REVERSE(SUBSTRING(email, 2, 12)) AS password
FROM `waiters`
WHERE salary IS NOT NULL
ORDER BY password DESC;   

-- 08. Top from menu 10/10

SELECT p.id, p.name,
	COUNT(*) AS count
FROM `orders_products` op
JOIN `products` p
	ON p.id = op.product_id
GROUP BY p.id, p.name
HAVING COUNT(*) >= 5
ORDER BY count DESC, p.name ASC;    

-- 09. Availability 10/10

SELECT
    t.id AS table_id,
    t.capacity,
    COUNT(oc.client_id) AS count_clients,
    CASE
        WHEN t.capacity > COUNT(oc.client_id) THEN 'Free seats'
        WHEN t.capacity = COUNT(oc.client_id) THEN 'Full'
        ELSE 'Extra seats'
    END AS availability
FROM `tables` t
JOIN `orders` o ON o.table_id = t.id
LEFT JOIN `orders_clients` oc ON oc.order_id = o.id
WHERE t.floor = 1
GROUP BY t.id, t.capacity
ORDER BY table_id DESC;
   
-- 10. Extract bill 15/15
 
DELIMITER $$

CREATE FUNCTION `udf_client_bill`(full_name VARCHAR(50))
RETURNS DECIMAL(19,2)
DETERMINISTIC
BEGIN
    DECLARE result DECIMAL(19,2);

    SELECT
        IFNULL(SUM(p.price), 0)
    INTO result
    FROM `clients` c
    JOIN `orders_clients` oc ON oc.client_id = c.id
    JOIN `orders` o ON o.id = oc.order_id
    JOIN `orders_products` op ON op.order_id = o.id
    JOIN `products` p ON p.id = op.product_id
    WHERE CONCAT(c.first_name, ' ', c.last_name) = full_name;

    RETURN result;
END $$

DELIMITER ;

SELECT c.first_name, c.last_name,
    `udf_client_bill`('Silvio Blyth') AS bill
FROM `clients` c
WHERE c.first_name = 'Silvio' 
AND c.last_name = 'Blyth';
 
-- 11. Happy hour 15/15

DELIMITER //

CREATE PROCEDURE `udp_happy_hour`(IN type VARCHAR(50))
BEGIN
	UPDATE `products` p
  SET price = price * 0.80
  WHERE price >= 10.00 AND p.type = type;
END //

DELIMITER ;
 
CALL udp_happy_hour('Cognac');
 
