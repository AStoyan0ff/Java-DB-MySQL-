-- EXERCISE: JOINs
-- USE `softuni_database`

-- 1. Employee Addresses
SELECT
	e.employee_id AS '#',
    e.job_title AS `Title`,
    a.address_id AS `# Address`,
    a.address_text AS `Full Address`
FROM `employees` e
JOIN `addresses` a
	ON e.address_id = a.address_id
ORDER BY a.address_id
LIMIT 5;    

-- 02. Addresses with Towns
SELECT 
    e.first_name AS `First Name`,
    e.last_name AS `Last Name`,
    t.name AS `Town`,
    a.address_text AS `Address`
FROM `employees` e
JOIN `addresses` a 
    ON e.address_id = a.address_id
JOIN `towns` t 
    ON a.town_id = t.town_id
ORDER BY e.first_name, e.last_name
LIMIT 5;

-- 03. Sales Employee
SELECT
	e.employee_id AS '#',
    e.first_name AS `First Name`,
    e.last_name AS `Last Name`,
    d.name AS `Department`
FROM `employees` e 
JOIN `departments`d 
	ON e.department_id = d.department_id
    WHERE d.name = 'Sales'
ORDER BY e.employee_id DESC;  

-- 04. Employee Departments
SELECT
	e.employee_id AS '#',
    e.first_name AS `First Name`,
    e.salary AS `Salary`,
    d.name AS `Department`
FROM `employees` e 
JOIN `departments`d 
	ON e.department_id = d.department_id
    WHERE e.salary > 15000 
ORDER BY d.department_id DESC
LIMIT 5; 

-- 05. Employees Without Project
SELECT 
    e.employee_id AS '#',
    e.first_name AS `First Name`
FROM `employees` AS e
LEFT JOIN `employees_projects` AS ep
    ON e.employee_id = ep.employee_id
WHERE ep.project_id IS NULL
ORDER BY e.employee_id DESC
LIMIT 3;
  
-- 06. Employees Hired After
SELECT 
	e.first_name AS `First Name`,
    e.last_name AS `Last Name`,
    e.hire_date AS `Date and Time`,
    d.name AS `Department`
FROM `employees` e
JOIN `departments` d 
	ON e.department_id = d.department_id
WHERE e.hire_date > '1999-01-01' 
AND d.name IN ('Sales', 'Finance')
ORDER BY e.hire_date;

-- 07. Employees with Project -> (83/100)
SELECT 
    e.employee_id AS '#',
    e.first_name AS `First-Name`,
    p.name AS `Project-Name`
FROM `employees` AS e
JOIN `employees_projects` AS ep
    ON e.employee_id = ep.employee_id
JOIN `projects` AS p
    ON ep.project_id = p.project_id
WHERE p.start_date >'2002-08-13 23:59:59'
AND p.end_date IS NULL
ORDER BY  e.first_name, p.name
LIMIT 5;

-- 08. Employee 24
SELECT 
    e.employee_id AS '#',
    e.first_name AS `First Name`,
IF(p.start_date >= '2005-01-01', NULL, p.name) AS `Projects`
FROM `employees` e
JOIN `employees_projects` ep
    ON e.employee_id = ep.employee_id
JOIN `projects` p
    ON ep.project_id = p.project_id
WHERE e.employee_id = 24
ORDER BY `Projects` ASC;

-- 09. Employee Manager
SELECT 
    e.employee_id AS '#',
    e.first_name AS `First Name`,
    e.manager_id AS `# Department`,
    em.first_name AS `Manager Name`
FROM `employees` AS e
JOIN `employees` AS em
    ON e.manager_id = em.employee_id
WHERE e.manager_id IN (3, 7)
-- WHERE e.manager_id = 3 OR e.manager_id = 7
ORDER BY e.first_name;


-- 10. Employee Summary
SELECT
	e.employee_id AS '#',
    CONCAT_WS(' ', e.first_name, e.last_name) AS `Employee Name`,
    CONCAT_WS(' ', em.first_name, em.last_name) AS `Manager Name`,
    d.name AS `Department Name`
FROM `employees` e 
JOIN `employees` em 
	ON e.manager_id = em.employee_id
JOIN `departments` d 
	ON e.department_id = d.department_id
ORDER BY e.employee_id ASC
LIMIT 5;    

-- 11. Min Average Salary
SELECT 
    MIN(avg_salary) AS `Min Avg Salary`
FROM (
SELECT 
	AVG(e.salary) AS 'avg_salary'
FROM employees AS e
GROUP BY e.department_id
) AS dept_avgs;

-- 12. Highest Peaks in Bulgaria
-- `countries` -> (country_code)
-- `mountains` -> (mountain_range)
-- `peaks` -> (peak_name, elevation)

SELECT 
    c.country_code AS `Codes`,
    m.mountain_range AS `Mountain`,
    p.peak_name AS `Peak Name`,
    p.elevation AS `Elevation`
FROM `countries` AS c
JOIN `mountains_countries` AS mc -- (свързваща таблица)
    ON c.country_code = mc.country_code
JOIN `mountains` AS m
    ON mc.mountain_id = m.id
JOIN `peaks` AS p
    ON m.id = p.mountain_id
WHERE c.country_code = 'BG'
AND p.elevation > 2835
ORDER BY p.elevation DESC;

-- 13. Count Mountain Ranges 
-- `countries` -> (county_code)
-- `mountains` -> (mountain_range)
SELECT 
    c.country_code AS `# Code`,
    COUNT(*) AS `Mountain-Range`
FROM `countries` AS c
JOIN `mountains_countries` AS mc
    ON c.country_code = mc.country_code
JOIN `mountains` AS m
    ON mc.mountain_id = m.id
WHERE c.country_code IN ('US', 'RU', 'BG')
GROUP BY c.country_code
ORDER BY `Mountain-Range` DESC;

-- 14. Countries with Rivers
-- `countries` -> (contry_name)
-- `rivers` -> (rivers_name)
SELECT 
    c.country_name AS `Countries`,
    r.river_name AS `Rivers-Name`
FROM `countries` c
LEFT JOIN `countries_rivers` cr
    ON c.country_code = cr.country_code
LEFT JOIN `rivers` r
    ON cr.river_id = r.id
WHERE c.continent_code = 'AF'
ORDER BY c.country_name ASC
LIMIT 5;
    
-- 15. *Continents and Currencies -> вариант 1
SELECT
    continent_code,
    currency_code,
    COUNT(*) AS currency_usage
FROM `countries`
GROUP BY continent_code, currency_code
HAVING COUNT(*) > 1
AND COUNT(*) = (
	SELECT
		COUNT(*)
	FROM `countries` AS c
	WHERE c.continent_code = countries.continent_code
	GROUP BY c.currency_code
	ORDER BY COUNT(*) DESC
	LIMIT 1
) ORDER BY continent_code, currency_code;

-- 15. *Continents and Currencies -> вариант 2 (CTE)
WITH currency_counts AS (
    SELECT
        continent_code,
        currency_code,
        COUNT(*) AS currency_usage
    FROM `countries`
    GROUP BY continent_code, currency_code
    HAVING COUNT(*) > 1
),
ranked_currencies AS (
    SELECT
        continent_code,
        currency_code,
        currency_usage,
        RANK() OVER (PARTITION BY continent_code 
        ORDER BY currency_usage DESC) AS rnk
    FROM currency_counts
)
SELECT
    continent_code,
    currency_code,
    currency_usage
FROM ranked_currencies
WHERE rnk = 1
ORDER BY continent_code, currency_code;

-- 16. Countries without any Mountains
SELECT
	COUNT(*) AS `Country-Count`
FROM `countries` AS c
LEFT JOIN `mountains_countries` AS mc
	ON c.country_code = mc.country_code
WHERE mc.mountain_id IS NULL;    
		
-- 17. Highest Peak and Longest River by Country
SELECT
    c.country_name,
    MAX(p.elevation) AS highest_peak,
    MAX(r.length) AS longest_river
FROM `countries` AS c
JOIN `mountains_countries` AS mc
    ON c.country_code = mc.country_code
JOIN `peaks` AS p
    ON mc.mountain_id = p.mountain_id
JOIN `countries_rivers` AS cr
    ON c.country_code = cr.country_code
JOIN `rivers` AS r
    ON cr.river_id = r.id
GROUP BY c.country_name
ORDER BY 
    highest_peak DESC,
    longest_river DESC,
    c.country_name ASC
LIMIT 5;
    
    
