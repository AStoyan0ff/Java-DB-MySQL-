-- Lab: Database Programmability and Transactions
-- USE `softuni_database

-- 01. Count Employees by Town

DELIMITER $$

CREATE FUNCTION `ufn_count_employees_by_town`(town_name VARCHAR(50))
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA

BEGIN
    DECLARE result INT;

    SELECT COUNT(*)
    INTO result
    FROM `employees` e
    JOIN `addresses` a 
		ON e.address_id = a.address_id
    JOIN `towns` t 
		ON a.town_id = t.town_id
    WHERE t.name = town_name;

    RETURN result;
END $$

DELIMITER ;

SELECT `ufn_count_employees_by_town`('Sofia') AS count;

-- 01. Count Employees by Town - вариант 2 Деси

DELIMITER $$

CREATE FUNCTION `ufn_count_employees_by_town_desi`(town_name VARCHAR(50))
RETURNS INT
DETERMINISTIC

BEGIN
	RETURN (
		SELECT COUNT(*)
        FROM `employees` e
			  JOIN `addresses` a ON e.address_id = a.address_id
			  JOIN `towns` t ON a.town_id = t.town_id
        WHERE t.name = town_name    
    );
END $$

DELIMITER ;

-- 2. Employees Promotion

DELIMITER $$
CREATE PROCEDURE `usp_raise_salaries`(dept_name VARCHAR(50))
BEGIN
	UPDATE `employees`
    SET salary = salary * 1.05
    WHERE department_id = (
		SELECT department_id
        FROM `departments`
        WHERE name = dept_name
    );
END $$    

DELIMITER ;
CALL `usp_raise_salaries`('Finace');

-- 3. Employees Promotion By ID -> Вариант без TRANSACTION

DELIMITER //

CREATE PROCEDURE `usp_raise_salary_by_id` (IN id INT)
BEGIN
	IF (
		SELECT 1
        FROM `employees` 
        WHERE employee_id = id
    ) THEN 
		UPDATE `employees`
		SET salary = salary * 1.05
        WHERE employee_id = id;
     END IF;   
END //

DELIMITER ;   

CALL `usp_raise_salary_by_id`(17); 
SELECT * FROM `employees`;

-- 3. Employees Promotion By ID -> Вариант c TRANSACTION

DELIMITER $$

CREATE PROCEDURE `usp_raise_salary_by_id_transaction` (IN p_id INT)
BEGIN
    START TRANSACTION;

    UPDATE `employees`
    SET salary = salary * 1.05
    WHERE employee_id = p_id;
    
    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
    
END $$

DELIMITER ;

CALL usp_raise_salary_by_id_transaction(17);

-- 3. Employees Promotion By ID -> Вариант c TRANSACTION c (DECLARE)

DELIMITER $$

CREATE PROCEDURE usp_raise_salary_by_id_declare(IN p_id INT)
BEGIN
    DECLARE result INT DEFAULT 0;
    START TRANSACTION;

    SELECT COUNT(*)
    INTO result
    FROM `employees`
    WHERE employee_id = p_id;

    IF result = 0 THEN
        ROLLBACK;
    ELSE
        UPDATE `employees`
        SET salary = salary * 1.05
        WHERE employee_id = p_id;
        COMMIT;
    END IF;
END $$

DELIMITER ;


-- 4. Triggered 100/100

DELIMITER $$

CREATE TABLE `deleted_employees` (
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    salary DECIMAL(10, 2) NOT NULL
);

CREATE TRIGGER tr_delete
AFTER DELETE ON `employees`
FOR EACH ROW

BEGIN
	INSERT INTO `deleted_employees`
    VALUES (
		OLD.e.employee_id,
		OLD.e.first_name,
		OLD.e.last_name,
		OLD.e.middle_name,
		OLD.e.job_title,
		OLD.e.department_id,
		OLD.e.salary
		); 
END $$

DELETE FROM `employees`
WHERE employee_id = 12;


DELIMITER ;
