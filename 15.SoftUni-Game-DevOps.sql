-- MySQL Retake Exam - 6 August 2021 

CREATE DATABASE `softuni_game_db`;
USE `softuni_game_db`;

-- 01. Table Design

CREATE TABLE `addresses` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE `categories` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(10) NOT NULL
);

CREATE TABLE `offices` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    workspace_capacity INT NOT NULL,
    website VARCHAR(50) NULL,
    address_id INT NOT NULL,
    
    FOREIGN KEY (address_id) 
    REFERENCES `addresses`(id)
);

CREATE TABLE `employees` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    job_title VARCHAR(20) NOT NULL,
    happiness_level CHAR(1) NOT NULL
);

CREATE TABLE `teams` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL,
    office_id INT NOT NULL,
    leader_id INT NOT NULL UNIQUE,
    
    FOREIGN KEY (office_id) 
    REFERENCES `offices`(id),
    
    FOREIGN KEY (leader_id) 
    REFERENCES `employees`(id)
);

CREATE TABLE `games` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT NULL,
    rating FLOAT DEFAULT 5.5 NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    release_date DATE NULL,
    team_id INT NOT NULL,
    
    FOREIGN KEY (team_id) 
    REFERENCES `teams`(id)
);

CREATE TABLE `games_categories` (
	game_id INT NOT NULL,
    category_id INT NOT NULL, 
    
    PRIMARY KEY (game_id, category_id)    
);

-- 02. INSERT

INSERT INTO `games` (name, rating, budget, team_id)
	SELECT
		LOWER(REVERSE(SUBSTRING(t.name, 2))) AS `Name`,
        t.id AS `Rating`,
        t.leader_id * 1000 AS `Budget`,
        t.id AS `Team-ID`
FROM `teams` t
WHERE t.id BETWEEN 1 AND 9;       

-- 03. UPDATE 

UPDATE `employees` e
JOIN `teams` t
	ON e.id = t.leader_id
SET e.salary = e.salary + 1000
WHERE e.age < 40 AND e.salary < 5000;

-- 04. DELETE 

DELETE g 
FROM `games` g 
LEFT JOIN `games_categories` gc
	ON g.id = gc.game_id
WHERE gc.category_id IS NULL
AND g.release_date IS NULL; 

-- 05. Employees

SELECT 
	e.first_name, 
	e.last_name, 
    e.age, e.salary, 
    e.happiness_level
FROM `employees` e
ORDER BY e.salary, e.id;

-- 06. Addresses of the teams

SELECT
	t.name AS `Team-Name`,
    a.name AS `Address-Name`,
    LENGTH(a.name) AS `Count`
FROM `teams` t
JOIN `offices` o 
	ON t.office_id = o.id
JOIN `addresses` a
	ON o.address_id = a.id
WHERE o.website IS NOT NULL
ORDER BY t.name, a.name;    

-- 07. Categories Info

SELECT c.name,
	COUNT(g.id) AS `Games-Count`,
    ROUND(AVG(g.budget), 2) AS `Avg-Budget`,
    MAX(g.rating) AS `Max-Rating`
FROM `categories` c  
JOIN `games_categories` gc 
	ON c.id = gc.category_id
JOIN `games` g 
	ON gc.game_id = g.id
GROUP BY c.id, c.name
HAVING MAX(g.rating) >= 9.5
ORDER BY `Games-Count` DESC, c.name;   

-- 08. Games of 2022

SELECT
    g.name,
    g.release_date,
    CONCAT(SUBSTRING(g.`description`, 1, 10), '...') AS summary,
    CASE
        WHEN MONTH(g.release_date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(g.release_date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(g.release_date) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(g.release_date) BETWEEN 10 AND 12 THEN 'Q4'
    END AS `quarter`,
    
    t.name AS team_name
FROM `games` AS g
JOIN `teams` AS t
    ON g.team_id = t.id
WHERE YEAR(g.release_date) = 2022
AND MONTH(g.release_date) % 2 = 0
AND g.name LIKE '% 2'
ORDER BY `quarter`;

-- 09. Full info for games

SELECT
    g.name,
    CASE
        WHEN g.budget < 50000 THEN 'Normal budget'
        ELSE 'Insufficient budget'
    END AS budget_level,
    
    t.name AS team_name,
    a.name AS address_name
FROM `games`  g
LEFT JOIN `games_categories`  gc
    ON g.id = gc.game_id
JOIN teams AS t
    ON g.team_id = t.id
JOIN `offices`  o
    ON t.office_id = o.id
JOIN `addresses` a
    ON o.address_id = a.id
WHERE g.release_date IS NULL
  AND gc.category_id IS NULL
ORDER BY g.name;

-- 10. Find all basic information for a game

DELIMITER $$

CREATE FUNCTION `udf_game_info_by_name`(game_name VARCHAR(20))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(255);

    SELECT
        CONCAT('The ', g.name,
		' is developed by a ', t.name,
		' in an office with an address ', a.name)
    INTO result
    FROM `games` g
    JOIN `teams` t
        ON g.team_id = t.id
    JOIN `offices` o
        ON t.office_id = o.id
    JOIN `addresses` AS a
        ON o.address_id = a.id
    WHERE g.name = game_name
    LIMIT 1;

    RETURN result;
END $$

DELIMITER ;

SELECT udf_game_info_by_name('Bitwolf') AS info;
  
-- 11. Update Budget of the Games

DELIMITER $$

CREATE PROCEDURE `udp_update_budget`(min_game_rating FLOAT)
BEGIN
    UPDATE `games` g
    LEFT JOIN `games_categories` gc
        ON g.id = gc.game_id
    SET
        g.budget = g.budget + 100000,
        g.release_date = DATE_ADD(g.release_date, INTERVAL 1 YEAR)
    WHERE gc.category_id IS NULL
	AND g.rating > min_game_rating
	AND g.release_date IS NOT NULL;
END $$

DELIMITER ;
