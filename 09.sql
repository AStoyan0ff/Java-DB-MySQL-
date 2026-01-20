-- 										Lab: Table Relations

-- One-To-Many / Many-To-One
-- Many-To-Many
-- One-To-One

-- 										`CASCADE` Operation

-- "Когато се промени или изтрие ред от родителската таблица
-- същото се прави и със свързаните редове в дъщерната таблица"

-- ON DELETE CASCADE -> автоматично изтрива всички редове в дъщерната таблица
-- които имат FOREIGN KEY към изтрития ред в родителската таблица

-- Когато изтриеш ред от таблица mountains:
-- DELETE FROM `mountains` 
-- 	 WHERE id = 5;

-- Автоматично се изтриват всички върхове, които имат:
-- mountain_id = 5
-- Без да пишеш допълнителен DELETE за `peaks`

-- 										ДРУГИ `CASCADE` ОПЦИИ:

-- ON DELETE CASCADE -> Трие дъщерните редове...
-- ON DELETE SET NULL -> Задава NULL на FOREIGN KEY...
-- ON DELETE RESTRICT -> Забранява ИЗТРИВНЕ...
-- ON UPDATE CASCADE -> Обновява FK при промяна на PK...

-- 1. Mountains and Peaks (1:N)
CREATE TABLE `mountains` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `peaks` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    mountain_id INT,
    
    CONSTRAINT fk_peaks_mountains
	FOREIGN KEY (mountain_id)
	REFERENCES mountains(id)
    
);
DESCRIBE peaks;

-- 2. Trip Organization (USE `camp`)
SELECT 
	v.driver_id, 
	v.vehicle_type,
	CONCAT(c.first_name, ' ', c.last_name) AS `Driver Name`
FROM `vehicles` v
JOIN `campers` c
	ON v.driver_id = c.id;
    
-- 03. SoftUni Hiking
SELECT r.starting_point, r.end_point, r.leader_id,
	CONCAT(c.first_name, ' ', c.last_name) AS `Leader Name`
FROM `routes` r 
JOIN `campers` c 
	ON r.leader_id = c.id;
    
-- 04. Delete Mountains
CREATE TABLE `mountains` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `peaks` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    mountain_id INT,
    
    CONSTRAINT fk_peaks_mountains
	FOREIGN KEY (mountain_id)
	REFERENCES mountains(id)
    	ON DELETE CASCADE
);
-- Yabba-Dabba-Doo ;)
