-- Data Definition And Data Types - Lab

CREATE DATABASE `gamebar`;
USE `gamebar`;

-- 01. Create Tables
CREATE TABLE `employees` (
    id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

-- Create table 2
CREATE TABLE `categories` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Create table 3
CREATE TABLE `products` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    category_id INT NOT NULL
);

-- 02. Insert Data in Tables
INSERT INTO `employees` (first_name, last_name)
VALUES
	('Andrey', 'Stoyanoff'),
    ('Doncho', 'Angelov'),
    ('Maraya', 'Ivanova');
    
-- 03. Alter Tables
ALTER TABLE `employees`
	ADD COLUMN middle_name VARCHAR(50);

-- 04. Modifying Columns
ALTER TABLE `employees`
	MODIFY COLUMN middle_name VARCHAR(100);      
