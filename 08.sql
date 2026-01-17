-- Exercises: Data Aggregation

-- 01. Records’ Count
SELECT 
	COUNT(*) AS 'Count'
FROM `wizzard_deposits`;

-- 02. Longest Magic Wand
SELECT
	MAX(magic_wand_size) AS `Longest magic wand`
FROM `wizzard_deposits`;    
    
-- 03. Longest Magic Wand per Deposit Groups
SELECT deposit_group,
    MAX(magic_wand_size) AS longest_magic_wand
FROM `wizzard_deposits`
GROUP BY deposit_group
ORDER BY longest_magic_wand ASC, deposit_group ASC;

-- 04. Smallest Deposit Group per Magic Wand Size
SELECT deposit_group
FROM `wizzard_deposits`
GROUP BY deposit_group
ORDER BY AVG(magic_wand_size) ASC
LIMIT 1;

-- 05. Deposits Sum
SELECT deposit_group,
	SUM(deposit_amount) AS 'total_sum'
FROM `wizzard_deposits`
GROUP BY deposit_group 
ORDER BY total_sum ASC;   

-- 06. Deposits Sum for Ollivander Family
SELECT deposit_group,
    SUM(deposit_amount) AS total_sum
FROM `wizzard_deposits`
	WHERE magic_wand_creator = 'Ollivander family'
GROUP BY deposit_group
ORDER BY deposit_group ASC;

-- 07. Deposits Filter
SELECT deposit_group,
    SUM(deposit_amount) AS total_sum
FROM `wizzard_deposits`
	WHERE magic_wand_creator = 'Ollivander family'
GROUP BY deposit_group
HAVING SUM(deposit_amount) < 150000
ORDER BY total_sum DESC;
  
-- 08. Deposit Charge
SELECT deposit_group, magic_wand_creator,
	MIN(deposit_charge) AS 'min_deposit_charge'
FROM `wizzard_deposits`
GROUP BY deposit_group, magic_wand_creator
ORDER BY magic_wand_creator ASC, deposit_group ASC;  

-- 09. Age Groups [CASE-END] -> вариант 1
SELECT
    CASE
        WHEN age BETWEEN 0 AND 10 THEN  '[0-10]'
        WHEN age BETWEEN 11 AND 20 THEN '[11-20]'
        WHEN age BETWEEN 21 AND 30 THEN '[21-30]'
        WHEN age BETWEEN 31 AND 40 THEN '[31-40]'
        WHEN age BETWEEN 41 AND 50 THEN '[41-50]'
        WHEN age BETWEEN 51 AND 60 THEN '[51-60]'
        ELSE '[61+]'
    END AS age_group,
    COUNT(*) AS wizard_count
FROM `wizzard_deposits`
GROUP BY age_group
ORDER BY wizard_count ASC;
  
-- 10. First Letter
SELECT
	LEFT(first_name, 1) AS `First Latter`
FROM `wizzard_deposits`
	WHERE deposit_group = 'Troll Chest'
GROUP BY `First Latter`
ORDER BY `First Latter` ASC;    

-- 11. Average Interest
SELECT deposit_group, is_deposit_expired,
    AVG(deposit_interest) AS 'average_interest'
FROM `wizzard_deposits`
	WHERE deposit_start_date > '1985-01-01'
GROUP BY deposit_group, is_deposit_expired
ORDER BY deposit_group DESC, is_deposit_expired ASC;
 
-- 12. Employees Minimum Salaries
SELECT department_id,
    MIN(salary) AS `Minimum Salaries`
FROM `employees`
	WHERE department_id IN (2, 5, 7)
	AND hire_date > '2000-01-01'
GROUP BY department_id
ORDER BY department_id ASC;

-- 13. Employees Average Salaries -> -- използвах временна таблица ... (TEMPORARY) без запис в базата
CREATE TEMPORARY TABLE `high_paid_employees` AS -- може и обикновенна таблица ... 
	SELECT * FROM `employees`
		WHERE salary > 30000;
        
DELETE FROM `high_paid_employees`
WHERE manager_id = 42;
        
UPDATE `high_paid_employees`
	SET salary = salary + 5000
	WHERE department_id = 1;
    
SELECT department_id,
    AVG(salary) AS `Average Salaries`
FROM `high_paid_employees`
GROUP BY department_id
ORDER BY department_id ASC;
    
-- 14. Employees Maximum Salaries
SELECT department_id,
    MAX(salary) AS `Max Salaries`
FROM `employees`
GROUP BY department_id
HAVING MAX(salary) < 30000 OR  MAX(salary) > 70000
ORDER BY department_id ASC;

-- 15. Employees Count Salaries
SELECT
	COUNT(salary) AS ' ' -- заменяме с нищо ... интервал 
FROM `employees`
	WHERE manager_id IS NULL;
    
-- 16. 3rd Highest Salary
SELECT department_id, (
      SELECT DISTINCT salary
        FROM employees e2
        WHERE e2.department_id = e1.department_id
        ORDER BY salary DESC
        LIMIT 1 OFFSET 2
    ) AS `3rd Highest Salary`  
FROM employees e1
GROUP BY department_id
HAVING `3rd Highest Salary` IS NOT NULL
ORDER BY department_id ASC;
    
-- 17. Salary Challenge
SELECT first_name, last_name, department_id
FROM employees e1
	WHERE salary > (
		SELECT AVG(salary)
		FROM employees e2
		WHERE e2.department_id = e1.department_id
	)
ORDER BY department_id, employee_id
LIMIT 10;

-- 18. Departments Total Salaries
SELECT department_id,
	SUM(salary) AS `Total Salaries`
FROM `employees`
GROUP BY department_id
ORDER BY department_id ASC;    

-- Yabba-Dabba-Doo :) 
