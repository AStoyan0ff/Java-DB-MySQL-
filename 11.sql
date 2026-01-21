-- Lab: Subqueries and JOINs
-- USE `softuni_database`

-- 1. Managers -> Вариант 1
SELECT
	e.employee_id,
		CONCAT(first_name, ' ', last_name) AS `Full Name`,
    d.department_id,
    d.`name`
FROM `employees` AS e
RIGHT JOIN `departments` AS d
	ON d.manager_id = e.employee_id
ORDER BY e.employee_id
LIMIT 5;

-- 2. Towns and Addresses
SELECT
    t.town_id,
    t.name AS town_name,
    a.address_text
FROM `addresses` a
JOIN `towns` t
    ON a.town_id = t.town_id
WHERE t.name IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY t.town_id, a.address_id;

-- 3. Employees Without Managers
SELECT
	employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM `employees`
WHERE manager_id IS NULL;

-- 4. Higher Salary
SELECT
	COUNT(e.employee_id) AS 'count'
FROM `employees` AS e
WHERE e.salary > (
	SELECT AVG(salary) AS 'average_salary' 
	FROM `employees`
);
   
   
