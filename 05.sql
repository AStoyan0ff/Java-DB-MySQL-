-- Lab: Built-in Functions

-- 01. Find Book Titles - Вариант 1
SELECT title FROM `books`
	WHERE substring(title, 1, 3) = 'The'
	ORDER BY id;

-- 01. Find Book Titles - Вариант 2    
SELECT title FROM `books`
	WHERE title LIKE 'The%'
	ORDER BY id;    
    
-- 02. Replace Titles - Вариант 1
SELECT 
	replace(title, 'The', '***') AS title
FROM `books`
WHERE title LIKE 'The%'
ORDER BY id;    

-- 02. Replace Titles - Вариант 2
SELECT 
    CONCAT('***', SUBSTRING(title, 4)) AS title
FROM `books`
WHERE SUBSTRING(title, 1, 3) = 'The'
ORDER BY id;

-- 03. Sum Cost of All Books - Вариант 1
SELECT 
    round(SUM(cost), 2) AS total_price -- format
FROM books;

-- 03. Sum Cost of All Books - Вариант 2
SELECT 
    format(SUM(cost), 2) AS total_price -- format
FROM books;

-- 04. Days Lived
SELECT
	concat(first_name, ' ', last_name) AS 'Full Name',
    datediff(died, born) AS 'Days Lived'
FROM `authors`
ORDER BY id;    
    
-- 05. Harry Potter Books - Вариант 1
SELECT title
FROM `books`
	WHERE title LIKE '%Harry Potter%'
    ORDER BY id;
    
-- 05. Harry Potter Books - Вариант 2
SELECT title
FROM `books`
	WHERE title LIKE 'Harry Potter%' 
    ORDER BY id;    
