-- MySQL Exam Preparation I -> `Summer Olympics` [12 October 2024]

-- 01. Table Design 40/40

CREATE DATABASE `summer_olympics`;
-- USE `summer_olympics`;

CREATE TABLE `countries` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `sports` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE `disciplines` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE,
    sport_id INT NOT NULL,
    
    CONSTRAINT fk_disciplines_sports
		FOREIGN KEY (sport_id)
        REFERENCES sports(id)
);

CREATE TABLE `athletes` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    age INT NOT NULL,
    country_id INT NOT NULL,
    
    CONSTRAINT fk_athletes_countries
		FOREIGN KEY (country_id) 
        REFERENCES countries(id)
);

CREATE TABLE `medals` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    type VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE `disciplines_athletes_medals` (
	discipline_id INT NOT NULL,
    athlete_id INT NOT NULL,
    medal_id INT NOT NULL,
    
    PRIMARY KEY (discipline_id, athlete_id),
    
    CONSTRAINT fk_discipline
		FOREIGN KEY (discipline_id)
		REFERENCES disciplines(id),
    
    CONSTRAINT fk_athlete
		FOREIGN KEY (athlete_id)
        REFERENCES athletes(id),
        
    CONSTRAINT fk_medals
		FOREIGN KEY (medal_id)
        REFERENCES medals(id),
        
    UNIQUE (discipline_id, athlete_id),
    UNIQUE (discipline_id, medal_id)
);

-- 02. Insert 10/10

INSERT INTO `athletes` (first_name, last_name, age, country_id)
SELECT
	UPPER(a.first_name) AS first_name,
    CONCAT(a.last_name, ' comes from ', c.name) AS last_name,
    a.age + a.country_id AS age, -- -> новата възраст = възрастта + country_id
    a.country_id
FROM `athletes` AS a
JOIN `countries` AS c
	ON a.country_id = c.id
WHERE c.name LIKE 'A%';
  
-- 03. Updade 10/10

UPDATE `disciplines`
	SET `name` = REPLACE(`name`, 'weight', '')
    WHERE `name` LIKE '%weight%';
    
-- 04. Delete 10/10

SELECT *
FROM `athletes`
	WHERE age > 35;

DELETE FROM `athletes`
	WHERE age > 35;

-- 05. Countries without athletes 10/10

SELECT
	c.id,
    c.name
FROM `countries` AS c
LEFT JOIN `athletes` AS a
	ON c.id = a.country_id
WHERE a.id IS NULL
ORDER BY c.name DESC
LIMIT 15;    

-- 06. Youngest medalists 10/10

SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS `Full-Name`,
    a.age
FROM `athletes` AS a
JOIN `disciplines_athletes_medals` AS dam
    ON a.id = dam.athlete_id
WHERE a.age = 
(
    SELECT MIN(a2.age)
    FROM `athletes` AS a2
    JOIN `disciplines_athletes_medals` AS dam2
        ON a2.id = dam2.athlete_id
)
ORDER BY a.id ASC
LIMIT 2;

-- 07. Athletes without medals 10/10

SELECT
	a.id,
    a.first_name,
    a.last_name
FROM `athletes` AS a
LEFT JOIN `disciplines_athletes_medals` AS dm
	ON a.id = dm.athlete_id
WHERE dm.athlete_id IS NULL
ORDER BY a.id;    
 
-- 08. Athletes with medals divided by sports 10/10

SELECT
    a.id,
    a.first_name,
    a.last_name,
    COUNT(dam.medal_id) AS medals_count,
    s.name AS sport
FROM `athletes` a
JOIN `disciplines_athletes_medals` dam
    ON a.id = dam.athlete_id
JOIN `disciplines` d
    ON dam.discipline_id = d.id
JOIN `sports` s
    ON d.sport_id = s.id
GROUP BY
    a.id, s.id
ORDER BY
    medals_count DESC,
    a.first_name ASC
LIMIT 10;

-- 09. Age groups of the athletes 10/10

SELECT
	CONCAT_WS(' ', a.first_name, a.last_name) AS `Full-Name`,
    CASE
		WHEN a.age <= 18 THEN 'Teenager'
        WHEN a.age > 18 AND a.age <= 25 THEN 'Young adult'
        ELSE 'Adult'
    END AS `Age-Group`
FROM `athletes` AS a
ORDER BY a.age DESC, a.first_name ASC;   

-- 10. Find the total count of medals by country 15/15

DELIMITER $$

CREATE FUNCTION `udf_total_medals_count_by_country`(country_name VARCHAR(40))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_medals INT;

    SELECT COUNT(dam.medal_id)
    INTO total_medals
    FROM `countries` AS c
    JOIN `athletes` AS a
        ON c.id = a.country_id
    JOIN `disciplines_athletes_medals` AS dam
        ON a.id = dam.athlete_id
    WHERE c.name = country_name;

    RETURN total_medals;
END $$

DELIMITER ;

SELECT
    c.name AS country_name,
    `udf_total_medals_count_by_country`('Bahamas') AS count_of_medals
FROM `countries` AS c
WHERE c.name = 'Bahamas';

-- 11. Update athlete's information 15/15

DELIMITER $$

CREATE PROCEDURE `udp_first_name_to_upper_case`(letter CHAR(1))
BEGIN

	UPDATE `athletes`
    SET first_name = UPPER(first_name)
    WHERE first_name LIKE CONCAT('%', letter);
    
END $$

DELIMITER ;

-- CALL udp_first_name_to_upper_case('s');
