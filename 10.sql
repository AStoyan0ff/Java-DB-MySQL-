-- Table Relations - Exercise

CREATE DATABASE `relations`;
USE `relations`;

-- 01. One-To-One Relationship

CREATE TABLE `passports` (
	passport_id INT PRIMARY KEY AUTO_INCREMENT,
    passport_number VARCHAR(20) NOT NULL UNIQUE
);

INSERT INTO `passports` (passport_number)
VALUES
	('N34FG21B'),
	('K65LO4R7'),
	('ZE657QP2');
    
CREATE TABLE `people` (
	person_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    passport_id INT UNIQUE,
    
		CONSTRAINT fk_passport
		  FOREIGN KEY (passport_id)
		  REFERENCES passports(passport_id)
);  

INSERT INTO `people` (first_name, salary, passport_id)
VALUES
	('Roberto', 43300.00, 102),
	('Tom', 56100.00, 103),
	('Yana', 60200.00, 101);
    
SELECT 
    pe.person_id,
    pe.first_name,
    FORMAT(pe.salary, 2) AS salary,  pa.passport_number 
FROM `people` pe
JOIN `passports` pa
	ON pe.passport_id = pa.passport_id;

-- 02. One-To-Many Relationship

CREATE TABLE `manufacturers` (
	manufacturer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    established_on DATE
); 

INSERT INTO `manufacturers` (name, established_on)
VALUES
	('BMW', '1916-03-01'),
	('Tesla', '2003-01-01'),
	('Lada', '1966-05-01');
    
CREATE TABLE `models` (
	model_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    manufacturer_id INT,
    
		CONSTRAINT fk_manufacturer
        FOREIGN KEY (manufacturer_id)
        REFERENCES manufacturers(manufacturer_id)
);  

INSERT INTO `models` (model_id, name, manufacturer_id) 
VALUES
	(101, 'X1', 1),
	(102, 'i6', 1),
	(103, 'Model S', 2),
	(104, 'Model X', 2),
	(105, 'Model 3', 2),
	(106, 'Nova', 3);
    
SELECT 
	m.model_id,
	m.name AS model_name,
    mf.name AS manufacturer_name,
    mf.established_on
FROM `models` m
JOIN manufacturers  mf
	ON m.manufacturer_id = mf.manufacturer_id;

-- Вариант 2 (по-кратък)    
SELECT * 
FROM `manufacturers` m
JOIN `models` md
	ON md.manufacturer_id = m.manufacturer_id;
     
-- 03. Many-To-Many Relationship

CREATE TABLE `exams` (
	exam_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);   

INSERT INTO `exams` (exam_id, name)
VALUES
	(101, 'Spring MVC'),
	(102, 'Neo4j'),
	(103, 'Oracle 11g');
    
CREATE TABLE `students` (
	student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);    

INSERT INTO `students` (student_id, name) 
VALUES
	(1, 'Mila'),
	(2, 'Toni'),
	(3, 'Ron');
    
CREATE TABLE `students_exams` (
	student_id INT,
  exam_id INT,
  PRIMARY KEY (student_id, exam_id),
  
		FOREIGN KEY (student_id)
		REFERENCES students(student_id),
		FOREIGN KEY (exam_id)
		REFERENCES exams(exam_id)
);  

INSERT INTO `students_exams` (student_id, exam_id)
VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103);
    
SELECT 
    s.name AS student_name,
    e.name AS exam_name
FROM `students_exams` se
JOIN `students` s 
	ON se.student_id = s.student_id
JOIN `exams` e 
	ON se.exam_id = e.exam_id
ORDER BY s.name;   

-- 04. Self-Referencing

CREATE TABLE `teachers` (
	teacher_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  manager_id INT,
    
    CONSTRAINT fk_manager_teachers
		  FOREIGN KEY (manager_id)
      REFERENCES teachers(teacher_id)
); 

INSERT INTO `teachers` (teacher_id, name, manager_id)
VALUES
	(101, 'John', NULL),
	(106, 'Greta', 101),
	(105, 'Mark', 101),
	(102, 'Maya', 106),
	(103, 'Silvia', 106),
	(104, 'Ted', 105);
    
SELECT
	t.name AS teacher,
	m.name AS manager
FROM `teachers` t
LEFT JOIN teachers m 
	ON t.manager_id = m.teacher_id;
    
-- 05. Online Store Database

CREATE TABLE `item_types` (
	item_type_id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE `items` (
	item_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  item_type_id INT(11) NOT NULL,
    
		CONSTRAINT fk_items_item_type
			FOREIGN KEY (item_type_id)
      REFERENCES item_types(item_type_id)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
);

CREATE TABLE `cities` (
	city_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE customers (
    customer_id INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    birthday DATE,
    city_id INT(11) NOT NULL,
    
    CONSTRAINT fk_customers_cities
        FOREIGN KEY (city_id)
        REFERENCES cities(city_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE `orders` (
	order_id INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  customer_id INT(11)NOT NULL,
    
    CONSTRAINT fk_orders_customers
		  FOREIGN KEY (customer_id)
      REFERENCES customers(customer_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_id INT(11) NOT NULL,
    item_id INT(11) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    
    CONSTRAINT fk_order_items_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
        
    CONSTRAINT fk_order_items_items
        FOREIGN KEY (item_id)
        REFERENCES items(item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 06. University Database (Ще пробвам без CONSTRAINT)

CREATE DATABASE `university`;
USE `university`;

CREATE TABLE `subjects` (
    subject_id INT(11) AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL
);

CREATE TABLE `majors` (
    major_id INT(11) AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE `students` (
    student_id INT(11) AUTO_INCREMENT PRIMARY KEY,
    student_number VARCHAR(12) NOT NULL,
    student_name VARCHAR(50) NOT NULL,
    major_id INT(11) NOT NULL,
    
    FOREIGN KEY (major_id)
	  REFERENCES majors(major_id)
);

CREATE TABLE `payments` (
    payment_id INT(11) AUTO_INCREMENT PRIMARY KEY,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(8,2) NOT NULL,
    student_id INT(11) NOT NULL,
    
    FOREIGN KEY (student_id)
	  REFERENCES students(student_id)
);

CREATE TABLE `agenda` (
    student_id INT(11) NOT NULL,
    subject_id INT(11) NOT NULL,
    PRIMARY KEY (student_id, subject_id),
    
    FOREIGN KEY (student_id)
	  REFERENCES students(student_id),
    FOREIGN KEY (subject_id)
	  REFERENCES subjects(subject_id)
);

-- 09. Peaks in Rila (USE DATABASE `geography `)

SELECT
	m.mountain_range,
  p.peak_name,
  p.elevation
FROM `peaks` AS p
JOIN `mountains` m 
	ON p.mountain_id = m.id
WHERE m.mountain_range = 'Rila'
ORDER BY p.elevation DESC;    
    
 -- Yabba-Dabba-Doo ;)   
