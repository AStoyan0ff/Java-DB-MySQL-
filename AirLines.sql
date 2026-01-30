-- Database Basics MySQL Retake Exam - 11 December 2022 (MySQL Retake Exam `Airlines DB`)

-- 01. Table Design 40/40

CREATE DATABASE `airlines`;
USE `airlines`;

CREATE TABLE `countries` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL UNIQUE,
    description TEXT,
    currency VARCHAR(5) NOT NULL
);

CREATE TABLE `airplanes` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    model VARCHAR(50) NOT NULL UNIQUE,
    passengers_capacity INT NOT NULL,
    tank_capacity DECIMAL(19, 2) NOT NULL,
    cost DECIMAL(19, 2) NOT NULL
);

CREATE TABLE `passengers` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    country_id INT NOT NULL,
    
	CONSTRAINT fk_passegers_countries
		FOREIGN KEY (country_id) 
		REFERENCES countries(id)
        
);

CREATE TABLE `flights` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    flight_code VARCHAR(30) NOT NULL UNIQUE,
    departure_country INT NOT NULL,
    destination_country INT NOT NULL,
    airplane_id INT NOT NULL,
    has_delay TINYINT(1),
    departure DATETIME,
    
	CONSTRAINT fk_flights_departure_country
		FOREIGN KEY (departure_country)
        REFERENCES countries(id),
        
    CONSTRAINT fk_flights_destination_country
		FOREIGN KEY (destination_country)
        REFERENCES countries(id),
        
    CONSTRAINT fk_flights_airplanes
		FOREIGN KEY (airplane_id)
        REFERENCES airplanes(id)
);

CREATE TABLE `flights_passengers` (
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,

    CONSTRAINT fk_fp_flights
        FOREIGN KEY (flight_id) 
        REFERENCES flights(id),

    CONSTRAINT fk_fp_passengers
        FOREIGN KEY (passenger_id) 
        REFERENCES passengers(id)
);

-- 02. INSERT  10/10

INSERT INTO `airplanes` (model, passengers_capacity, tank_capacity, cost)
SELECT
    CONCAT(REVERSE(first_name), '797') AS model,
    LENGTH(last_name) * 17 AS passengers_capacity,
    id * 790 AS tank_capacity,
    LENGTH(first_name) * 50.6 AS cost
FROM `passengers`
WHERE id <= 5;
   
-- 03. UPDATE 10/10

UPDATE `flights` AS f
JOIN `countries` AS c
	ON f.departure_country = c.id
SET f.airplane_id = f.airplane_id + 1
WHERE c.name = 'Armenia';    
    
-- 04. DELETE 10/10

DELETE f 
FROM `flights` AS f
LEFT JOIN `flights_passengers` AS fp
	ON f.id = fp.flight_id
WHERE fp.flight_id IS NULL;  

-- 05. Airplanes 10/10

SELECT 
	id, 
	model, 
    passengers_capacity, 
    tank_capacity, 
    cost
FROM `airplanes`
ORDER BY cost DESC, id DESC;  

-- 06. Flights from 2022 10/10

SELECT
	flight_code,
    departure_country,
    airplane_id,
    departure
FROM `flights`
WHERE YEAR(departure) = 2022
ORDER BY airplane_id, flight_code
LIMIT 20;
    
-- 07. Private flights 10/10

SELECT
	CONCAT(UPPER(LEFT(p.last_name, 2)), p.country_id) AS `Flight-Code`,
    CONCAT_WS(' ', p.first_name, last_name) AS `Full-Name`,
    p.country_id AS `Country-ID`
FROM `passengers` p 
LEFT JOIN flights_passengers fp
	ON p.id = fp.passenger_id
WHERE fp.flight_id IS NULL
ORDER BY p.country_id;    

-- 08. Leading destinations 10/10

SELECT c.name, c.currency,
	COUNT(fp.passenger_id) AS `Booket-Tickets`
FROM `countries` c
JOIN `flights` f
    ON c.id = f.destination_country
JOIN `flights_passengers` fp
	ON f.id = fp.flight_id
GROUP BY c.id, c.name, c.currency
HAVING COUNT(fp.passenger_id) >= 20
ORDER BY `Booket-Tickets` DESC;    

-- 09. Parts of the day 10/10

SELECT
	flight_code AS `Flight-Code`,
    departure AS `Departure-Time`,
	CASE
		WHEN HOUR(departure) BETWEEN 5 AND 11 THEN 'Morning'
		WHEN HOUR(departure) BETWEEN 12 AND 16 THEN 'Afternoon'
		WHEN HOUR(departure) BETWEEN 17 AND 20 THEN 'Evening'
		ELSE 'Night'
	END AS `Day-Part`
FROM `flights`
ORDER BY flight_code DESC;  

-- 10. Number of flights 15/15

DELIMITER //

CREATE FUNCTION `udf_count_flights_from_country`(country VARCHAR(50))
RETURNS INT 
DETERMINISTIC
BEGIN
	DECLARE result INT;
    
    SELECT COUNT(f.id)
    INTO result
    FROM `flights` f
    JOIN `countries` c
		ON f.departure_country = c.id
    WHERE c.name = country;
    
    RETURN result;
	
END // 

DELIMITER ;

SELECT `udf_count_flights_from_country`('Brazil') AS flights_count;

-- 11. Delay flight 15/15

DELIMITER //

CREATE PROCEDURE `udp_delay_flight`(code VARCHAR(50))
BEGIN
	UPDATE `flights`
		SET has_delay = TRUE,
        departure = DATE_ADD(departure, INTERVAL 30 MINUTE)
    WHERE flight_code = code;    
END //

DELIMITER ;
