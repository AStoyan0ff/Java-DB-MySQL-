-- Database Programmability - Exercise
-- USE SoftUni_db

-- 01. Employees with Salary Above 35000

DELIMITER //

CREATE PROCEDURE `usp_get_employees_salary_above_35000`()
BEGIN
	SELECT first_name, last_name
    FROM `employees`
    WHERE salary > 35000
    ORDER BY first_name, last_name;
END//

DELIMITER ;

CALL usp_get_employees_salary_above_35000();

-- 02. Employees with Salary Above Number

DELIMITER $$

CREATE PROCEDURE `usp_get_employees_salary_above`(IN min_salary DECIMAL(10, 4))
BEGIN
	SELECT first_name, last_name
    FROM `employees`
    WHERE salary >= min_salary
    ORDER BY first_name, last_name;
END $$

DELIMITER ;

CALL usp_get_employees_salary_above(45000.0000);

-- 03. Town Names Starting With

DELIMITER //

CREATE PROCEDURE `usp_get_towns_starting_with`(IN str VARCHAR(50))
BEGIN
	SELECT name AS `Town-Name`
    FROM `towns`
    WHERE name LIKE CONCAT(str, '%')
    ORDER BY name;
END //

DELIMITER ;

CALL usp_get_towns_starting_with('b');

-- 04. Employees from Town

DELIMITER $$

CREATE PROCEDURE `usp_get_employees_from_town`(town_name VARCHAR(50))
BEGIN
	SELECT e.first_name, e.last_name
    FROM `employees` e
    JOIN `addresses` a 
		  ON e.address_id = a.address_id
    JOIN `towns` t 
		  ON a.town_id = t.town_id
    WHERE t.name = town_name
    ORDER BY e.first_name, e.last_name;
END $$

DELIMITER ;

CALL usp_get_employees_from_town('sofia');

-- 05. Salary Level Function

DELIMITER //

CREATE FUNCTION `ufn_get_salary_level`(salary DECIMAL(10, 2))
RETURNS VARCHAR(10)
DETERMINISTIC

BEGIN
	DECLARE result VARCHAR(10);
    
    IF salary < 30000 THEN
		SET result = 'Low';
    ELSEIF salary BETWEEN 30000 AND 50000 THEN 
		SET result = 'Average';
    ELSE 
		SET result = 'High';
    END IF;
    
    RETURN result;
END // 

DELIMITER ;

SELECT 
    salary,
    ufn_get_salary_level(salary) AS `Result-Level`
FROM employees
ORDER BY salary DESC;

SELECT ufn_get_salary_level(13500.00);   
SELECT ufn_get_salary_level(43300.00);   
SELECT ufn_get_salary_level(125500.00);  

-- 06. Employees by Salary Level -- НЕ РАБОТИ С ФУНКЦИЯТА ПРИ ПРОВЕРКА (При мен работи)

DELIMITER $$

CREATE PROCEDURE `usp_get_employees_by_salary_level`(IN result VARCHAR(20))
BEGIN
	SELECT first_name, last_name
    FROM `employees`
    WHERE `ufn_get_salary_level`(salary) = result
    ORDER BY first_name DESC, last_name DESC;
END $$

DELIMITER ;

CALL usp_get_employees_by_salary_level('High');

-- 06. Employees by Salary Level --> работещ вариант 

DELIMITER $$

CREATE PROCEDURE `usp_get_employees_by_salary_level`(IN result VARCHAR(10))
BEGIN
    SELECT first_name, last_name
    FROM `employees`
    WHERE
        CASE
            WHEN salary < 30000 THEN 'Low'
            WHEN salary BETWEEN 30000 AND 50000 THEN 'Average'
            ELSE 'High'
        END = result
    ORDER BY first_name DESC, last_name DESC;
END $$

DELIMITER ;

CALL `usp_get_employees_by_salary_level`('High');

-- 07. Define Function - ВАРИАНТ 1
DELIMITER //

CREATE FUNCTION `ufn_is_word_comprised`(set_of_letters VARCHAR(50), word VARCHAR(50))	
RETURNS TINYINT
DETERMINISTIC

BEGIN
	DECLARE i INT DEFAULT 1;
    DECLARE curr_char CHAR(1);
    DECLARE letter_idx INT;
    
    WHILE i <= CHAR_LENGTH(word) DO
        SET curr_char = SUBSTRING(word, i, 1);
        SET letter_idx = LOCATE(curr_char, set_of_letters);
        IF letter_idx = 0 THEN
            RETURN 0;
            
        ELSE
            SET set_of_letters = CONCAT(
              SUBSTRING(set_of_letters, 1, letter_idx - 1),
              SUBSTRING(set_of_letters, letter_idx + 1)
            );
        END IF;
        SET i = i + 1;
    END WHILE;
    
    RETURN 1;
END //
    
DELIMITER ;

SELECT ufn_is_word_comprised('oistmiahf', 'Sofia') AS result;   
SELECT ufn_is_word_comprised('oistmiahf', 'halves') AS result; 
SELECT ufn_is_word_comprised('bobr', 'Rob') AS result;         
SELECT ufn_is_word_comprised('pppp', 'Guy') AS result;

-- 07. Define Function - ВАРИАНТ 2 [REGEXP]

DELIMITER $$

CREATE FUNCTION `ufn_is_word_comprised`(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS TINYINT
DETERMINISTIC
BEGIN
   
    IF word REGEXP CONCAT('^[', set_of_letters, ']+$') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
    
END $$

DELIMITER ;

SELECT ufn_is_word_comprised('oistmiahf', 'Sofia') AS result;

-- USE DATABASE `bank_account`

-- 08. Find Full Name

DELIMITER //

CREATE PROCEDURE `usp_get_holders_full_name`()
BEGIN
	SELECT 
		CONCAT_WS(' ', first_name, last_name) AS `Full-Name`
  FROM `account_holders`
  ORDER BY `Full-Name` ASC;
END //

DELIMITER ;

CALL `usp_get_holders_full_name`();

-- 09. People with Balance Higher Than -> (not included in final score)


DELIMITER $$

CREATE PROCEDURE `usp_get_holders_with_balance_higher_than`(IN min_balance DECIMAL(10, 2))
BEGIN
    SELECT
        ah.first_name AS `Full-Name`,
        ah.last_name AS `Last-Name`
    FROM `account_holders` ah
    JOIN `accounts` a 
		ON ah.id = a.account_holder_id
    GROUP BY ah.id, ah.first_name, ah.last_name
    HAVING SUM(a.balance) > min_balance
    ORDER BY ah.id ASC;
END $$

DELIMITER ;

CALL `usp_get_holders_with_balance_higher_than`(7000);

-- 10. Future Value Function 

DELIMITER //

CREATE FUNCTION `ufn_calculate_future_value`
(
	initial_sum DECIMAL(10, 4), 	-- начална сума
    yearly_interest_rate DOUBLE, 	-- годишна лихва
    years INT						-- брой години
)
RETURNS DECIMAL(10, 4)
DETERMINISTIC
BEGIN
	RETURN initial_sum * POW((1 + yearly_interest_rate), years); -- формулата :)
END //

DELIMITER ;

SELECT `ufn_calculate_future_value`(1000, 0.5, 5) AS `Output`;

-- 11. Calculating Interest

										-- USE `bank_account`;

DELIMITER $$

CREATE PROCEDURE `usp_calculate_future_value_for_account`(IN pr_account_id INT, IN pr_interest_rate DECIMAL(10, 4))
BEGIN
    SELECT
        a.id AS '#',
        ah.first_name AS 'First-Name',
        ah.last_name AS 'Last-Name',
        CAST(a.balance AS DECIMAL(15,4)) AS 'Current-Balance',
        CAST(a.balance * POW((1 + pr_interest_rate), 5) AS DECIMAL(15,4)) AS 'Balance-Five-Years'
    FROM `accounts` a
    JOIN `account_holders` ah
        ON a.account_holder_id = ah.id
    WHERE a.id = pr_account_id;
END $$

DELIMITER ;


CALL `usp_calculate_future_value_for_account`(1, 0.1);

-- 12. Deposit Money

DELIMITER //

CREATE PROCEDURE `usp_deposit_money`(IN a_account_id INT, IN a_money_amount DECIMAL(10, 4))
BEGIN
    START TRANSACTION;

    IF a_money_amount <= 0 THEN
        ROLLBACK;
    ELSE
        UPDATE `accounts`
			SET balance = ROUND(balance + a_money_amount, 4) 
        WHERE id = a_account_id;

        IF ROW_COUNT() = 0 THEN
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;

CALL `usp_deposit_money`(1, 10);

-- 13. Withdraw Money

DELIMITER !!!

CREATE PROCEDURE `usp_withdraw_money`(IN a_account_holder_id INT, IN a_money_amount DECIMAL(19, 4))
BEGIN

    DECLARE trans_balance DECIMAL(19, 4);
    START TRANSACTION;
    
    IF a_money_amount <= 0 THEN
        ROLLBACK;
        
    ELSE
        SELECT balance
        INTO trans_balance
        FROM `accounts`
        WHERE id = a_account_holder_id
        FOR UPDATE;

        IF trans_balance IS NULL THEN
            ROLLBACK;
       
        ELSEIF trans_balance < a_money_amount THEN
            ROLLBACK;
            
        ELSE
            UPDATE `accounts`
            SET balance = ROUND(balance - a_money_amount, 4)
            WHERE id = a_account_holder_id;
            COMMIT;
            
        END IF;
    END IF;
    
END !!!

DELIMITER ;

CALL usp_withdraw_money(1, 10);

-- 14. Money Transfer

DELIMITER !!!

CREATE PROCEDURE usp_transfer_money( IN a_from_account_id INT, IN a_to_account_id INT, IN a_amount DECIMAL(19,4))
BEGIN

    DECLARE from_balance DECIMAL(19,4);
    DECLARE to_balance DECIMAL(19,4);

    START TRANSACTION;

    IF a_amount <= 0 OR a_from_account_id = a_to_account_id THEN
        ROLLBACK;
        
    ELSE
        SELECT ROUND(balance, 4)
        INTO from_balance
        FROM `accounts`
        WHERE id = a_from_account_id
        FOR UPDATE;

        SELECT ROUND(balance, 4)
        INTO to_balance
        FROM `accounts`
        WHERE id = a_to_account_id
        FOR UPDATE;

        IF from_balance IS NULL OR to_balance IS NULL THEN
            ROLLBACK;
        
        ELSEIF from_balance < a_amount THEN
            ROLLBACK;
            
        ELSE
            UPDATE `accounts`
            SET balance = ROUND(balance - a_amount, 4)
            WHERE id = a_from_account_id;

            UPDATE `accounts`
            SET balance = ROUND(balance + a_amount, 4)
            WHERE id = a_to_account_id;

            COMMIT;
        END IF;
    END IF;
END !!!

DELIMITER ;

CALL `usp_transfer_money`(1, 2, 10);


-- 15. Log Accounts Trigger (not included in final score) -> [Trigger]

CREATE TABLE `logs` (
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    old_sum DECIMAL(20, 4),
    new_sum DECIMAL(20, 4)
);

DELIMITER $$

CREATE TRIGGER `tr_log_accounts`
AFTER UPDATE ON `accounts`
FOR EACH ROW
INSERT INTO `logs` (account_id, old_sum, new_sum)
SELECT 
	OLD.id, 
		ROUND(OLD.balance,4), 
    ROUND(NEW.balance,4)
WHERE OLD.balance <> NEW.balance;

DELIMITER ;

-- 16. Emails Trigger 

CREATE TABLE `notification_emails` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipient INT,
    subject VARCHAR(100),
    body TEXT
);

DELIMITER $$

CREATE TRIGGER `tr_notification_emails`
AFTER INSERT ON `logs`
FOR EACH ROW
INSERT INTO `notification_emails`(recipient, subject, body)
VALUES (
    NEW.account_id,
		CONCAT('Balance change for account: ', NEW.account_id),
		CONCAT('On ', DATE_FORMAT(NOW(), '%b %d %Y at %h:%i:%s %p'), ' your balance was changed from ',
	NEW.old_sum, ' to ',  NEW.new_sum, '.'
    )
);

DELIMITER ;
