-- MySQL Regular Exam - 20 June 2021 [softuni_taxi_company]

CREATE DATABASE `softuni_taxi_company`;
USE `softuni_taxi_company`;

-- 01. Table Design

CREATE TABLE `addresses` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE `categories` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(10) NOT NULL
);

CREATE TABLE `clients` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE `drivers` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT NOT NULL,
    rating FLOAT DEFAULT 5.5 NULL
);

CREATE TABLE `cars` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    make VARCHAR(20) NOT NULL,
    model VARCHAR(20) NULL,
    year INT DEFAULT 0 NOT NULL,
    mileage INT DEFAULT 0 NULL,
    `condition` CHAR(1) NOT NULL,
    category_id INT NOT NULL,
    
    FOREIGN KEY (category_id)
    REFERENCES `categories`(id)
);

CREATE TABLE `courses` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    from_address_id INT NOT NULL,
    start DATETIME NOT NULL,
    bill DECIMAL(10, 2) DEFAULT 10,
    car_id INT NOT NULL,
    client_id INT NOT NULL,
    
    FOREIGN KEY (from_address_id) REFERENCES `addresses`(id),
    FOREIGN KEY (car_id) REFERENCES `cars`(id),
    FOREIGN KEY (client_id) REFERENCES `clients`(id)
);

CREATE TABLE `cars_drivers` (
	car_id INT NOT NULL,
    driver_id INT NOT NULL,
    
    PRIMARY KEY (car_id, driver_id),
    
    FOREIGN KEY (car_id) REFERENCES `cars`(id),
    FOREIGN KEY (driver_id) REFERENCES `drivers`(id)
);

-- 02. INSERT

INSERT INTO `clients` (full_name, phone_number)
	SELECT
		CONCAT_WS(' ', first_name, last_name) AS `Full-name`,
        CONCAT('(088) 9999', id * 2) AS `Phone-Number`
FROM `drivers` 
WHERE id BETWEEN 10 AND 20; 

-- 03. UPDATE

UPDATE `cars`
	SET `condition` = 'C'
WHERE (mileage >= 800000 OR mileage IS NULL) 
AND YEAR <= 2010 AND make <> 'Mercedes-Benz';

-- 04. DELETE

DELETE FROM `clients` c
WHERE CHAR_LENGTH(c.full_name) > 3
AND NOT EXISTS
(
	SELECT 1
    FROM `courses` co
	WHERE co.client_id = c.id
);

-- 05. Cars

SELECT make, model, `condition`
FROM `cars`
ORDER BY id;

-- 06. Drivers And Cars

SELECT
    d.first_name,
    d.last_name,
    c.make,
    c.model,
    c.mileage
FROM `drivers` d
JOIN `cars_drivers` cd ON d.id = cd.driver_id
JOIN `cars` c ON c.id = cd.car_id
WHERE c.mileage IS NOT NULL
ORDER BY  c.mileage DESC, d.first_name ASC;

-- 07. Number of courses

SELECT c.id, c.make, c.mileage,
    COUNT(co.id) AS counter,
    ROUND(AVG(co.bill), 2) AS avg_bill
FROM `cars` c
LEFT JOIN `courses` co
    ON c.id = co.car_id
GROUP BY  c.id, c.make, c.mileage
HAVING COUNT(co.id) <> 2
ORDER BY counter DESC, id ASC;

-- 08. Regular clients

SELECT cl.full_name,
	COUNT(DISTINCT co.id) AS counter_of_car,
    ROUND(SUM(co.bill), 2) AS total_sum
FROM `clients` cl 
JOIN `courses` co 
	ON cl.id = co.client_id
WHERE SUBSTRING(cl.full_name, 2, 1) = 'a'
GROUP BY cl.id, cl.full_name
HAVING COUNT(DISTINCT co.car_id) > 1
ORDER BY cl.full_name;    
    
-- 09. Full info for courses

SELECT a.name AS name,
	CASE
		  WHEN HOUR(co.`start`) BETWEEN 6 AND 20 THEN 'Day'
      ELSE 'Night'
  END AS day_time,
    co.bill, 
    cl.full_name, 
    ca.make, 
    ca.model,
    cat.name AS gategory_name
FROM `courses` co 
JOIN `addresses` a
	ON co.from_address_id = a.id
JOIN `clients` cl 
	ON co.client_id = cl.id
JOIN `cars` ca 
	ON co.car_id = ca.id
JOIN `categories` cat 
	ON ca.category_id = cat.id
ORDER BY co.id;  

-- 10. Find all courses by client’s phone number

DELIMITER //

CREATE FUNCTION `udf_courses_by_client`(phone_num VARCHAR(20)) 
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE result INT; 
    
    SELECT COUNT(co.id) INTO result
    FROM `clients` cl
	LEFT JOIN `courses` co
		ON cl.id = co.client_id
    WHERE cl.phone_number = phone_num;    
    
    RETURN result;
END //

DELIMITER ;    

-- 11. Full info for address

DELIMITER $$

CREATE PROCEDURE `udp_courses_by_address`(IN address_name VARCHAR(100))
BEGIN
    SELECT a.name AS name, cl.full_name,
        CASE
            WHEN co.bill <= 20 THEN 'Low'
            WHEN co.bill <= 30 THEN 'Medium'
            ELSE 'High'
        END AS level_of_bill,
        ca.make,
        ca.`condition`,
        cat.name AS cat_name
    FROM `addresses` AS a
    JOIN `courses` AS co
        ON a.id = co.from_address_id
    JOIN `clients` AS cl
        ON co.client_id = cl.id
    JOIN `cars` AS ca
        ON co.car_id = ca.id
    JOIN `categories` AS cat
        ON ca.category_id = cat.id
    WHERE a.name = address_name
    ORDER BY ca.make ASC, cl.full_name ASC;
END $$	
    
DELIMITER ;
    
