-- Data Definition and Data Types - Exercise

CREATE DATABASE minions;
-- USE minions;

-- 01. Create Tables
CREATE TABLE minions (
	id int primary key auto_increment,
    name varchar(50) not null,
    age int
);

CREATE TABLE towns (
	town_id int primary key auto_increment,
    name varchar(50) not null
);

-- 02. Alter Minions Table 
ALTER TABLE minions
	ADD column town_id int,
	ADD foreign key (town_id) references towns(id);
    
-- 03. Insert Records in Both Tables
INSERT into towns
VALUES
	(1, 'Sofia'), 
	(2, 'Plovdiv'), 
	(3, 'Varna');

INSERT into minions
VALUES
	(1, 'Kevin', 22, 1),
    (2, 'Bob', 15, 3),
    (3, 'Steward', null, 2);  
    
-- 04. Truncate Table Minions
-- TRUNCATE TABLE minions;    

-- 05. Drop All Tables
-- DROP TABLE minions;
-- DROP TABLE towns;

-- 06. Create Table People
CREATE TABLE people (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    picture BLOB,
    height DECIMAL(5 , 2 ),
    weight DECIMAL(5 , 2 ),
    gender CHAR(1) NOT NULL,
    birthdate DATE NOT NULL,
    biography TEXT
);

INSERT INTO people (`name`, picture, height, weight, gender, birthdate, biography) 
VALUES
	('AStoyanoff', null, 1.80, 75.50, 'm', '2020-10-12', 'Born in Kyustendil. Software developer.'),
	('Maria', null, 1.65, 58.20, 'f', '2021-08-21', 'Marketing specialist.'),
	('Georgi', null, 1.78, 82.00, 'm', '2021-02-03', 'Former athlete and coach.'),
	('Elena', null, 1.70, 60.00, 'f', '2024-11-30', 'Graphic designer and artist.'),
	('Petar', null, 1.85, 90.75, 'm', '2025-01-17', 'Entrepreneur and investor.');
    
-- 07. Create Table Users
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(30)CHAR SET ASCII UNIQUE NOT NULL,
    `password` VARCHAR(26)CHAR SET ASCII NOT NULL,
    profile_picture BLOB,
    last_login_time DATETIME,
    is_deleted BOOLEAN
);    
  
INSERT INTO users (username, `password`, profile_picture, last_login_time, is_deleted) 
VALUES
	('user1', 'pass123', NULL, '2025-01-10 10:15:00', FALSE),
	('user2', 'secret456', NULL, '2025-02-05 14:30:00', FALSE),
	('admin', 'adminpass', NULL, '2025-03-01 09:00:00', FALSE),
	('guest', 'guestpass', NULL, '2025-01-20 18:45:00', TRUE),
	('tester', 'testpass', NULL, '2025-02-28 22:10:00', FALSE); 
    
-- 08. Change Primary Key
ALTER TABLE users
DROP primary key,
ADD CONSTRAINT pk_users PRIMARY KEY (id, username);  
-- ADD primary key (id, username);

-- 9. Set Default Value of a Field
ALTER TABLE users
MODIFY last_login_time DATETIME DEFAULT CURRENT_TIMESTAMP;  
-- MODIFY last_login_time datetime default now(); -->function

-- 10. Set Unique Field
ALTER TABLE users
DROP PRIMARY KEY,
	ADD PRIMARY KEY(id),
	ADD UNIQUE(username);
    
-- 11. Movies Database
CREATE TABLE directors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    director_name VARCHAR(50) NOT NULL,
    notes TEXT
);

CREATE TABLE genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL,
    notes TEXT
);

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    notes TEXT
);

CREATE TABLE movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    director_id INT NOT NULL,
    copyright_year INT NOT NULL,
    `length` INT NOT NULL,
    genre_id INT NOT NULL,
    category_id INT NOT NULL,
    rating DECIMAL(3 , 1 ) NOT NULL,
    notes TEXT
);

INSERT INTO directors (director_name, notes)
VALUES
	('Christopher Nolan', 'Known for complex narratives'),
	('Steven Spielberg', 'Famous Hollywood director'),
	('Martin Scorsese', 'Crime and drama movies'),
	('Quentin Tarantino', 'Nonlinear storytelling'),
	('James Cameron', 'Epic and sci-fi films');
    
INSERT INTO genres (genre_name, notes)
VALUES
	('Action', 'Fast-paced movies'),
	('Drama', 'Emotionally driven'),
	('Sci-Fi', 'Futuristic themes'),
	('Crime', 'Criminal underworld'),
	('Adventure', 'Exploration and journeys');
    
INSERT INTO categories (category_name, notes)
VALUES
	('Feature Film', 'Standard movie length'),
	('Short Film', 'Under 40 minutes'),
	('Documentary', 'Based on real events'),
	('Animation', 'Animated movies'),
	('Independent', 'Low-budget films');
    
INSERT INTO movies (title, director_id, copyright_year, length, genre_id, category_id, rating, notes) 
VALUES
	('Inception', 1, 2010, 148, 3, 1, 8.8, 'Dream within a dream'),
	('Jurassic Park', 2, 1993, 127, 5, 1, 8.2, 'Dinosaurs revived'),
	('The Wolf of Wall Street', 3, 2013, 180, 2, 1, 8.2, 'Based on true story'),
	('Pulp Fiction', 4, 1994, 154, 4, 1, 8.9, 'Cult classic'),
	('Avatar', 5, 2009, 162, 3, 5, 7.8, 'Visual spectacle');    

-- Data Definition and Data Types - Exercise

CREATE DATABASE car_rental;
USE car_rental;

-- 12. Car Rental Database
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    daily_rate DECIMAL(10 , 2 ) NOT NULL,
    weekly_rate DECIMAL(10 , 2 ) NOT NULL,
    monthly_rate DECIMAL(10 , 2 ) NOT NULL,
    weekend_rate DECIMAL(10 , 2 ) NOT NULL
);

CREATE TABLE cars (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plate_number VARCHAR(20) NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    car_year INT NOT NULL,
    category_id INT NOT NULL,
    doors INT,
    picture BLOB,
    car_condition VARCHAR(50),
    available INT NOT NULL
);

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title VARCHAR(50),
    notes TEXT
);

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    driver_licence_number VARCHAR(50) NOT NULL,
    full_name VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    city VARCHAR(100),
    zip_code VARCHAR(20),
    notes TEXT
);

CREATE TABLE rental_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    customer_id INT NOT NULL,
    car_id INT NOT NULL,
    car_condition VARCHAR(50),
    tank_level DECIMAL(5 , 2 ),
    kilometrage_start INT,
    kilometrage_end INT,
    total_kilometrage INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT,
    rate_applied DECIMAL(10 , 2 ),
    tax_rate DECIMAL(5 , 2 ),
    order_status VARCHAR(20),
    notes TEXT
);

INSERT INTO categories (category, daily_rate, weekly_rate, monthly_rate, weekend_rate) 
VALUES
	('Economy', 30.00, 180.00, 700.00, 60.00),
	('Compact', 40.00, 240.00, 900.00, 80.00),
	('Luxury', 80.00, 480.00, 1800.00, 160.00);
    
INSERT INTO cars  (plate_number, make, model, car_year, category_id, doors, picture, car_condition, available)
VALUES
	('CA1234AA', 'Toyota', 'Yaris', 2020, 1, 4, null, 'Excellent', true),
	('CB5678BB', 'VW', 'Golf', 2019, 2, 4, null, 'Good', true),
	('CC9999CC', 'BMW', '5 Series', 2021, 3, 4, null, 'Excellent', false);
    
INSERT INTO employees (first_name, last_name, title, notes)
VALUES
	('Ivan', 'Petrov', 'Manager', null),
	('Maria', 'Ivanova', 'Clerk', null),
	('Georgi', 'Dimitrov', 'Clerk', 'Part-time');
    
INSERT INTO customers (driver_licence_number, full_name, address, city, zip_code, notes)  
VALUES
	('DL123456', 'Peter Johnson', 'Main Street 5', 'Sofia', '1000', null),
	('DL654321', 'Anna Smith', 'Second Ave 10', 'Plovdiv', '4000', null),
	('DL987654', 'John Brown', 'Sea Blvd 3', 'Varna', '9000', 'VIP client');
    
INSERT INTO rental_orders 
	(employee_id, customer_id, car_id, car_condition, tank_level, 
	kilometrage_start, kilometrage_end, total_kilometrage, start_date, end_date, 
	total_days, rate_applied, tax_rate, order_status, notes)
VALUES
	(1, 1, 1, 'Excellent', 50.00, 12000, 12200, 200, '2024-01-10', '2024-01-15', 5, 30.00, 20.00, 'Completed', null),
	(2, 2, 2, 'Good', 40.00, 50000, 50300, 300, '2024-02-01', '2024-02-07', 6, 40.00, 20.00, 'Completed', null),
	(3, 3, 3, 'Excellent', 60.00, 8000, 8200, 200, '2024-03-05', '2024-03-10', 5, 80.00, 20.00, 'Open', 'Long-term client');
	   
    
-- Data Definition and Data Types - Exercise

CREATE DATABASE soft_uni;
-- USE soft_uni;

-- 13. Basic Insert - only INSERT take get JUDGE
CREATE TABLE towns (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE addresses (
	id INT PRIMARY KEY AUTO_INCREMENT,
    address_text VARCHAR(50) NOT NULL,
    town_id INT NOT NULL,
    
		CONSTRAINT fk_addresses_towns
			FOREIGN KEY (town_id)
            REFERENCES towns(id)
); 

CREATE TABLE departments (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
	id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    address_id INT,
    
    CONSTRAINT fk_employees_departments
        FOREIGN KEY (department_id)
        REFERENCES departments(id),
        
    CONSTRAINT fk_employees_addresses
        FOREIGN KEY (address_id)
        REFERENCES addresses(id)
);

INSERT INTO towns (name)
VALUES
	('Sofia'),
    ('Plovdiv'),
    ('Varna'),
    ('Burgas');
   
INSERT INTO departments (name)
VALUES
	('Engineering'),
	('Sales'),
    ('Marketing'),
    ('Software Development'),
    ('Quality Assurance');
    
INSERT INTO addresses (address_text, town_id)
VALUES
	('Boris Sarafov 26', 1),
    ('Melnik 3', 2),
    ('Kliment Ohridski 55', 3),
    ('Vitosha 17', 4),
    ('Prilep 7', 1);
    
INSERT INTO employees (first_name, middle_name, last_name, job_title, department_id, hire_date, salary, address_id) 
VALUES
	('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00, 1),
	('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00, 2),
	('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25, 3),
	('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00, 4),
	('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88, 5);
    
-- 14. Basic Select All Fields
SELECT * FROM towns;
SELECT * FROM departments;
SELECT * FROM employees;  

-- 15. Basic Select All Fields and Order Them
SELECT * FROM towns
	ORDER BY name;

SELECT * FROM departments
	ORDER BY name;

SELECT * FROM employees
	ORDER BY salary DESC;
    
-- 16. Basic Select Some Fields
SELECT name
	FROM towns
	ORDER BY name;

SELECT name
	FROM departments
	ORDER BY name;

SELECT first_name, last_name, job_title, salary
	FROM employees
	ORDER BY salary DESC; 
    
-- 17. Increase Employees Salary
UPDATE employees
	SET salary = salary * 1.10;

SELECT salary
	FROM employees;
    
      
    
