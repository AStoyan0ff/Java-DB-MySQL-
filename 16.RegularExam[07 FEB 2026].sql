-- MySQL Regular Exam - 07 FEB 2026 

CREATE DATABASE `go_roadie_exam`;
USE `go_roadie_exam`;

-- 01. Table Design

CREATE TABLE `cities` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `cars` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    brand VARCHAR(20) NOT NULL,
    model VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE `instructors` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL UNIQUE,
    has_a_license_from DATE NOT NULL
);

CREATE TABLE `driving_schools` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE,
    night_time_driving TINYINT(1) NOT NULL,
    average_lesson_price DECIMAL(10, 2) NULL,
    car_id INT NOT NULL,
    city_id INT NOT NULL,
    
    FOREIGN KEY (car_id) REFERENCES `cars`(id),
    FOREIGN KEY (city_id) REFERENCES `cities`(id)
);

CREATE TABLE `students` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL UNIQUE,
    age INT NULL,
    phone_number VARCHAR(20) NULL UNIQUE
);

CREATE TABLE `instructors_driving_schools` (
	instructor_id INT NULL,
    driving_school_id INT NOT NULL,
    
    FOREIGN KEY (instructor_id) REFERENCES `instructors`(id),
    FOREIGN KEY (driving_school_id) REFERENCES `driving_schools`(id)
);

CREATE TABLE `instructors_students` (
	instructor_id INT NOT NULL,
    student_id INT NOT NULL,
    
    FOREIGN KEY (instructor_id) REFERENCES `instructors`(id),
    FOREIGN KEY (student_id) REFERENCES `students`(id) 
); 

-- 02. INSERT

INSERT INTO `students` (first_name, last_name, age, phone_number)
SELECT
	LOWER(REVERSE(first_name)) AS `First-Name`,
    LOWER(REVERSE(last_name)) AS `Last-Name`,
    age + CAST(LEFT(phone_number, 1) AS UNSIGNED) AS `Age`,
    CONCAT('1+', phone_number) AS `Phone-Number`
FROM `students`
WHERE age < 20;    

-- 03 UPDATE

UPDATE `driving_schools` ds
JOIN `cities` c 
	ON ds.city_id = c.id
SET ds.average_lesson_price = ds.average_lesson_price + 30
WHERE c.name = 'London'
AND ds.night_time_driving = 1;


-- 04. DELETE

DELETE FROM `driving_schools`
WHERE night_time_driving = 0;

-- 05. Youngest students

SELECT
	CONCAT_WS(' ', first_name, last_name) AS `Full-Name`,
    age
FROM `students` 
WHERE first_name LIKE '%a%'
AND age =
(
	SELECT MIN(age)
    FROM `students`
    WHERE first_name LIKE '%a%'
) 
ORDER BY id;  

-- 06. Driving schools without instructors

SELECT ds.id, ds.name, c.brand
FROM `driving_schools` ds
LEFT JOIN `instructors_driving_schools` ids
    ON ds.id = ids.driving_school_id
JOIN `cars` c
    ON ds.car_id = c.id
WHERE ids.instructor_id IS NULL
ORDER BY c.brand, ds.id 
LIMIT 5;

-- 07. Instructors with more than one student

SELECT i.first_name, i.last_name,
    COUNT(isr.student_id) AS students_count,
    c.name AS city
FROM `instructors` i
JOIN `instructors_students` isr
    ON i.id = isr.instructor_id
JOIN `instructors_driving_schools` ids
    ON i.id = ids.instructor_id
JOIN `driving_schools` ds
    ON ids.driving_school_id = ds.id
JOIN `cities` c
    ON ds.city_id = c.id
GROUP BY i.id, c.name
HAVING COUNT(isr.student_id) > 1
ORDER BY students_count DESC, i.first_name ASC;

-- 08. Instructors' count by city

SELECT 
    c.name AS name,
    COUNT(DISTINCT ids.instructor_id) AS instructors_count
FROM `cities` c
JOIN `driving_schools` ds 
	ON c.id = ds.city_id
JOIN `instructors_driving_schools` ids 
	ON ds.id = ids.driving_school_id
GROUP BY c.name
HAVING COUNT(DISTINCT ids.instructor_id) > 0
ORDER BY instructors_count DESC;

-- 09. Instructors' experience level

SELECT 
    CONCAT_WS(' ', first_name, last_name) AS full_name,
    CASE 
        WHEN YEAR(has_a_license_from) >= 1980 AND YEAR(has_a_license_from) < 1990 THEN 'Specialist'
        WHEN YEAR(has_a_license_from) >= 1990 AND YEAR(has_a_license_from) < 2000 THEN 'Advanced'
        WHEN YEAR(has_a_license_from) >= 2000 AND YEAR(has_a_license_from) < 2008 THEN 'Experienced'
        WHEN YEAR(has_a_license_from) >= 2008 AND YEAR(has_a_license_from) < 2015 THEN 'Qualified'
        WHEN YEAR(has_a_license_from) >= 2015 AND YEAR(has_a_license_from) < 2020 THEN 'Provisional'
        WHEN YEAR(has_a_license_from) >= 2020 THEN 'Trainee'
        ELSE 'Unknown'
    END AS level
FROM `instructors`
WHERE has_a_license_from IS NOT NULL
ORDER BY YEAR(has_a_license_from), first_name;
    
-- 10. Extract the average lesson price by city

DELIMITER //

CREATE FUNCTION `udf_average_lesson_price_by_city`(city_name VARCHAR(40))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE result DECIMAL(10, 2);
    
    SELECT AVG(ds.average_lesson_price) 
    INTO result
    FROM `driving_schools` ds
    JOIN `cities` c 
		ON ds.city_id = c.id
    WHERE c.name = city_name;
    
    RETURN result;
END //

DELIMITER ;

SELECT c.name, 
	`udf_average_lesson_price_by_city`(c.name) AS average_lesson_price
FROM `cities` c
WHERE c.name = 'London';

-- 11. Find a driving school by the desired car brand

DELIMITER //

CREATE PROCEDURE `udp_find_school_by_car`(IN brand VARCHAR(20))
BEGIN
    SELECT 
        ds.name AS name,
        ds.average_lesson_price 
    FROM `driving_schools` ds
    JOIN `cars` c 
		ON ds.car_id = c.id
    WHERE c.brand = brand
    ORDER BY ds.average_lesson_price DESC;
END //

DELIMITER ;

CALL udp_find_school_by_car('Mercedes-Benz');
   
