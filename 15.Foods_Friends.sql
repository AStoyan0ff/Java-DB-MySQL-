-- Databases Basics MySQL Retake Exam - 6 December 2024
-- Foods Friends

CREATE DATABASE `foods_friends`;
USE `foods_friends`;

-- 01. Table Design 40/40

CREATE TABLE `restaurants` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE,
    type VARCHAR(20) NOT NULL,
    non_stop TINYINT(1) NOT NULL
);

CREATE TABLE `customers` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    regular TINYINT(1) NOT NULL,
    
		CONSTRAINT uq_full_name
			UNIQUE (first_name, last_name)
);

CREATE TABLE `offerings` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE,
    price DECIMAL(19, 2) NOT NULL,
    vegan TINYINT(1) NOT NULL,
    restaurant_id INT NOT NULL,
    
		CONSTRAINT fk_offerings_restaurants
			FOREIGN KEY(restaurant_id)
            REFERENCES restaurants(id)
);

CREATE TABLE `orders` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    number VARCHAR(10) NOT NULL UNIQUE,
    priority VARCHAR(10) NOT NULL,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    
		CONSTRAINT fk_orders_customers
			FOREIGN KEY (customer_id)
            REFERENCES customers(id),
            
        CONSTRAINT fk_orders_restaurants
			FOREIGN KEY (restaurant_id)
            REFERENCES restaurants(id)
);

CREATE TABLE `orders_offerings` (
    order_id INT NOT NULL,
    offering_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    PRIMARY KEY (order_id, offering_id),
    
    CONSTRAINT fk_of_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(id),
        
    CONSTRAINT fk_of_offerings
        FOREIGN KEY (offering_id)
        REFERENCES offerings(id),
        
    CONSTRAINT fk_of_restaurants
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(id)
);

-- 02. Insert 10/10

INSERT INTO `offerings` (name, price, vegan, restaurant_id)
	SELECT
		CONCAT(name, ' costs:'),
        price, vegan, restaurant_id
    FROM `offerings`
    WHERE name LIKE 'Grill%';
    
-- 03. Update 10/10

UPDATE `offerings`
	SET name = UPPER(name)
    WHERE name LIKE '%Pizza%';
    
-- 04 Delete 10/10

DELETE FROM `restaurants`
WHERE `name` LIKE '%fast%'
OR `type` LIKE '%fast%';

-- 05. Get all offerings from restaurant 10/10

SELECT o.name, o.price
FROM `offerings` o
JOIN `restaurants` r 
	ON o.restaurant_id = r.id
WHERE r.name = 'Burger Haven'
ORDER BY o.id;    

-- 06. Get all customers without orders 10/10

SELECT 
	c.id,
    c.first_name,
    c.last_name
FROM `customers` c 
LEFT JOIN `orders` o 
	ON c.id = o.customer_id
WHERE o.id IS NULL
ORDER BY c.id;    

-- 07. Get all offerings from orders of the customer 10/10

SELECT o.id, o.`name`
FROM `customers` AS c
JOIN `orders` AS ord 
	ON c.id = ord.customer_id
JOIN `orders_offerings` AS oo 
	ON ord.id = oo.order_id
JOIN `offerings` AS o 
	ON oo.offering_id = o.id
WHERE c.first_name = 'Sofia'
AND c.last_name = 'Sanchez'
AND o.vegan = 0
ORDER BY o.id;

-- 08 . Get all restaurants with regular customers 10/10

SELECT DISTINCT 
	r.id, 
    r.name
FROM `restaurants` r
JOIN `orders` o
    ON r.id = o.restaurant_id
JOIN `customers` c
    ON o.customer_id = c.id
JOIN `orders_offerings` oo
    ON o.id = oo.order_id
JOIN `offerings` ofr
    ON oo.offering_id = ofr.id
WHERE c.regular = 1
AND ofr.vegan = 1
AND o.priority = 'high'
ORDER BY r.id;
    
-- 09. Offering price categories 15/15

SELECT `name`,
	CASE
		WHEN price <= 10 THEN 'cheap'
        WHEN price > 10 AND price <= 25 THEN 'affordable'
        ELSE 'expensive'
    END AS price_category
FROM `offerings`
ORDER BY price DESC, `name` ASC;    

-- 10. Get offerings average price per restaurant

DELIMITER $$

CREATE FUNCTION `udf_get_offerings_average_price_per_restaurant`(restaurant VARCHAR(40))
RETURNS DECIMAL(10,2)
DETERMINISTIC

BEGIN
    DECLARE price DECIMAL(10,2);

    SELECT ROUND(AVG(ofr.price), 2)
    INTO price
    FROM `offerings` ofr
    JOIN `restaurants`  res
        ON ofr.restaurant_id = res.id
    WHERE res.name = restaurant;

    RETURN price;
END $$

DELIMITER ;

SELECT 
    res.name AS restaurant_name,
    `udf_get_offerings_average_price_per_restaurant`('Burger Haven') 
	AS average_offering_price
FROM `restaurants` res
WHERE res.name = 'Burger Haven';

-- 11. Update offering prices 15/15

DELIMITER //

CREATE PROCEDURE udp_update_prices (restaurant_type VARCHAR(40))
    
BEGIN

    UPDATE `offerings` AS ofr
    JOIN `restaurants` AS res
        ON ofr.restaurant_id = res.id
    SET ofr.price = ofr.price + 5.00
    WHERE res.type = restaurant_type
    AND res.non_stop = 1;
      
END //

DELIMITER ;

CALL udp_update_prices('buffet');
