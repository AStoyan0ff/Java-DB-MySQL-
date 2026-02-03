CREATE DATABASE `management_system`;
USE `management_system`;

-- 00. Table Design

CREATE TABLE `planets` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE `spaceports` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    planet_id INT,
    
    CONSTRAINT fk_planets
    FOREIGN KEY (planet_id) 
    REFERENCES `planets`(id)
);

CREATE TABLE `spaceships` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(30) NOT NULL,
    light_speed_rate INT DEFAULT 0
);

CREATE TABLE `colonists` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    ucn CHAR(10) NOT NULL UNIQUE,
    birth_date DATE NOT NULL
);

CREATE TABLE `journeys` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    journey_start DATETIME NOT NULL,
    journey_end DATETIME NOT NULL,
    purpose ENUM('Medical', 'Technical', 'Educational', 'Military'),
    destination_spaceport_id INT,
    spaceship_id INT,
    
    CONSTRAINT fk_spaceports
    FOREIGN KEY (destination_spaceport_id) 
    REFERENCES `spaceports`(id),
    
    CONSTRAINT fk_spaceships
    FOREIGN KEY (spaceship_id) 
    REFERENCES `spaceships`(id)
);

CREATE TABLE `travel_cards` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    card_number CHAR(10) NOT NULL UNIQUE,
    job_during_journey ENUM('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'),
    colonist_id INT,
    journey_id INT,
    
    CONSTRAINT fk_colonists
    FOREIGN KEY (colonist_id) 
    REFERENCES `colonists`(id),
    
    CONSTRAINT fk_journevs
    FOREIGN KEY (journey_id) 
    REFERENCES `journeys`(id)
);

-- 01. INSERT

INSERT INTO `travel_cards` (card_number, job_during_journey, colonist_id, journey_id)
SELECT 
    CASE
        WHEN c.birth_date > '1980-01-01' THEN 
            CONCAT(YEAR(c.birth_date), 
			IF(DAY(c.birth_date) < 10, 
			CONCAT('', DAY(c.birth_date)), DAY(c.birth_date)),
			LEFT(c.ucn, 4))
            
        ELSE 
            CONCAT( YEAR(c.birth_date),
			IF(MONTH(c.birth_date) < 10, 
			CONCAT('', MONTH(c.birth_date)), MONTH(c.birth_date)),
			RIGHT(c.ucn, 4))
    END AS card_number,
    
    CASE
        WHEN c.id % 2 = 0 THEN 'Pilot'
        WHEN c.id % 3 = 0 THEN 'Cook'
        ELSE 'Engineer'
        
    END AS job_during_journey,
    c.id AS colonist_id,
    LEFT(c.ucn, 1) AS journey_id
FROM `colonists` c
WHERE c.id BETWEEN 96 AND 100;

-- 02. UPDATE 

UPDATE `journeys`
SET purpose = 
	CASE
		WHEN id % 2 = 0 THEN 'Medical'
        WHEN id % 3 = 0 THEN 'Technical'
        WHEN id % 5 = 0 THEN 'Educational'
        WHEN id % 7 = 0 THEN 'Military'
    END 
WHERE id % 2 = 0 OR id % 3 = 0 OR id % 5 = 0 OR id % 7 = 0;  

-- 03. DELETE

DELETE FROM `colonists` c  
WHERE NOT EXISTS (
	SELECT 1
    FROM `travel_cards` tc
    WHERE tc.colonist_id = c.id
);

-- 04. Extract all military journeys

SELECT id, journey_start, journey_end
FROM `journeys`
WHERE purpose = "Military"
ORDER BY journey_start;

-- 05. Extract the fastest spaceship

SELECT 
    s.name AS spaceship_name,
    sp.name AS spaceport_name
FROM `spaceships` s
JOIN `journeys` j 
	ON s.id = j.spaceship_id
JOIN `spaceports` sp 
	ON j.destination_spaceport_id = sp.id
WHERE s.light_speed_rate = 
(
    SELECT MAX(light_speed_rate) 
    FROM `spaceships`
);

-- 06. Extract - pilots younger than 30 years - вариант 1

SELECT DISTINCT
	s.name, s.manufacturer
FROM `spaceships` s 
JOIN `journeys` j 
	ON s.id = j.spaceship_id
JOIN `travel_cards` tc 
	ON j.id = tc.journey_id
JOIN `colonists` c 
	ON tc.colonist_id = c.id   
WHERE tc.job_during_journey = 'Pilot' 
AND TIMESTAMPDIFF(YEAR, c.birth_date, '2019-01-01') < 30
ORDER BY s.name;

-- 06. Extract - pilots younger than 30 years - вариант 2 (subquery)

SELECT s.name, s.manufacturer
FROM `spaceships` s
WHERE s.id IN 
(
    SELECT DISTINCT j.spaceship_id
    FROM `journeys` j
    JOIN `travel_cards` tc 
		  ON j.id = tc.journey_id
    JOIN `colonists` c 
		  ON tc.colonist_id = c.id
    WHERE tc.job_during_journey = 'Pilot'
	AND c.birth_date > DATE_SUB('2019-01-01', INTERVAL 30 YEAR)
)
ORDER BY s.name;

-- 07. Extract all educational mission planets and spaceports

SELECT
	p.name AS `Planet-Name`,
    sp.name AS `Spaceport-Name`
FROM `planets` p 
JOIN `spaceports` sp 
	ON p.id = sp.planet_id
JOIN `journeys` j 
	ON sp.id = j.destination_spaceport_id
WHERE j.purpose = 'Educational'
ORDER BY `Spaceport-Name` DESC; 

 -- 08. Extract all planets and their journey count
 
SELECT 
	p.name AS planet_name,
    COUNT(jr.id) AS jounery_count
FROM `planets` p 
JOIN `spaceports` sp 
	ON p.id = sp.planet_id
JOIN `journeys` jr
	ON sp.id = jr.destination_spaceport_id
GROUP BY p.id, p.name
ORDER BY jounery_count DESC, planet_name ASC;

-- 09. Extract the less popular job

SELECT 
    tc.job_during_journey AS job_name
FROM `travel_cards` tc
WHERE tc.journey_id = 
(
    SELECT id 
    FROM `journeys` 
    ORDER BY TIMESTAMPDIFF(SECOND, journey_start, journey_end) DESC 
    LIMIT 1
)
GROUP BY tc.job_during_journey
ORDER BY COUNT(*) ASC
LIMIT 1;

-- 10 . Get colonists count

DELIMITER $$

CREATE FUNCTION `udf_count_colonists_by_destination_planet`(planet_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE result INT DEFAULT 0;
    
    SELECT COUNT(DISTINCT tc.colonist_id) 
    INTO result
    FROM `travel_cards` tc
    JOIN `journeys` j 
		  ON tc.journey_id = j.id
    JOIN `spaceports` sp 
		  ON j.destination_spaceport_id = sp.id
    JOIN `planets` p 
		  ON sp.planet_id = p.id
    WHERE p.name = planet_name;
    
    RETURN result;
END $$

DELIMITER ;

SELECT p.name, udf_count_colonists_by_destination_planet('Otroyphus') AS count
FROM planets AS p
WHERE p.name = 'Otroyphus';

-- 11. Modify spaceship

DELIMITER $$

CREATE PROCEDURE `udp_modify_spaceship_light_speed_rate`
(
    spaceship_name VARCHAR(50), 
    light_speed_rate_increase INT
)
BEGIN
    DECLARE result INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    SELECT COUNT(*) 
    INTO result
    FROM spaceships
    WHERE name = spaceship_name;
    
    IF result = 0 THEN
        ROLLBACK;
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
        
    ELSE
        UPDATE `spaceships`
        SET light_speed_rate = light_speed_rate + light_speed_rate_increase
        WHERE name = spaceship_name;
        
        COMMIT;
    END IF;
END $$

DELIMITER ;

CALL udp_modify_spaceship_light_speed_rate('Na Pesho koraba', 1914); -- Error
CALL udp_modify_spaceship_light_speed_rate('USS Templar', 5); -- light_speed_rate 11
