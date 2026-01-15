--                                    STRING FUNCTION

-- 01. CONCAT() -> долепя текст и не игнорира NULL стойности
SELECT
	concat('Andrey', ' ', 'Stoyanoff') AS 'Full Name';
    
-- 02. CONCAT_WS() -> долепя тескстове с различни разделители (' ', '.', '-') 
-- и игнорира NULL стойности 
SELECT
	concat_ws(' - ','Andrey', 'Ivanov', 'Stoyanoff') AS 'Full Data';
    
-- 03. SUBSTRING() -> взима част от текст 
SELECT
	substring('ILikeJava', 6) AS 'Get Text'; -- 'Java' (вземи от 6-та позиция включително)
    
SELECT 
	substring('MySQLDataBase', 1, 5); -- 'MySQL' (вземи от 1ва позиция до 5та включително)
    
-- 04. REPLACE() -> заменя текст 
SELECT
	replace('I live in Sofia', 'Sofia', 'Blagoevgrad'); -- 'I live in Blagoevgrad'
    
-- 05. LTRIM() -> премахва празни пространства в началото на текста  
	-- RTIME() -> премахва празни пространства в края на тексата
SELECT
	ltrim('    MySQL'); -- 'MySQL'
    
SELECT
	rtrim('MySQL     '); -- 'MySQL'
    
SELECT
	ltrim(ltrim('	MySQL	')); -- Комбинирано премахване
    
-- 6. CHAR_LENGTH() -> колко е броя на символите в даден текст 
SELECT
	char_length('Hello'); -- 5 символа
    
-- 07. LENGTH() -> дава ни броя на байтовете в даден текст   
SELECT
	length('ЗДРАВЕЙ'); -- 7 букви по 2 байта = 14
    
-- 09. LEFT() -> взима определен брой символи от началото на текста
SELECT
	left('MySQL', 2); -- My
    
-- 10. RIGTH() -> взима определен брой символи от края на текста 
SELECT
	right('MySQL', 3); -- 'LQS'
    
-- 11. LOWER() -> преобразува текста в малки букви 
SELECT
	lower('ANDREY'); -- 'andrey'
    
-- 12. UPPER() -> преобразува текста в главни букви 
SELECT
	upper('andrey'); -- 'ANDREY'
    
-- 13. REVERSE() -> обръща текста на обратно
SELECT
	reverse('Andrey'); -- 'yerdnA'
    
-- 14. REPEAT() -> повтаряме текст определен брой пъти 
SELECT 
	repeat('Hello', 3); -- 'HelloHelloHello'
    
-- 15. LOCATE() -> намира позицията на текст в друг текст 
SELECT
	locate('SQL', 'MySQLDataBase'); -- 3 (позицията от която срещнем текста)
    
-- 16. INSERT() -> вмъква един текст в друг текст 
SELECT
	insert('MyDataBase', 3, 2, 'SQL'); -- (от позиция 3, махни 2 символа и сложи текста 'SQL') 'MySQLDataBase'
    
  
  
--                                          MATH FUNCTION

-- 1. Аритметични оператори ('+', '-', '*', '/', 'DIV', ('%' или 'MOD') 

SELECT 5 + 5; -- 10
SELECT 10 - 5; -- 5
SELECT 10 * 5; -- 50
SELECT 10 / 4;	-- 2.5
SELECT 10 DIV 4; -- 2 (целочислено деление)
SELECT 10 MOD 3; -- 1 (взимаме остатъка) деление с остатък (проверка дали числото е even/odd = 0/1)

-- 2. Математическите ФУНКЦИИ 

-- 01.PI() -> дава ни стойността на числото 'пи'
SELECT
	PI();
    
-- 02. ABS() -> дава ни абсолютната стойност на едно число(числото без неговия знак)
SELECT
	abs(-15); -- 15 без знака '-'
    
-- 03. SQRT() -> дава ни коренквадратен 
SELECT
	sqrt(9); -- 3

-- 04. POW() -> степенуване/ повдигане 
SELECT
	pow(2, 3); -- 2 на степен 3та = 8
    
-- 05. CONV() -> преобразуване в бройна с-ма 
SELECT
	conv('1010', 2, 10); -- преобразува числото 1010 от двоична бр с-ма в десетична = 10
    
-- 06.ROUND() -> закръгляне 
SELECT
	round(12.345, 2); -- закръгляне с 2 цифири след десетичната запетая = 12.35
    
SELECT
	round('12.4'); -- закръгляне от 0 до 4 надолу / закръгляне от 5 до 9 нагоре '12'
    
-- 07. FLOOR() -> закръгляне надолу до най-близкото число
SELECT
	floor(12.9); -- 12 
    
-- 08.  CEILING() -> закръгляне нагоре
SELECT
ceiling(12.9); -- 13  

-- 09. SIGN() -> показва числото дали е положително, отрицателно или 0
SELECT
	sign(-10); -- -1 (отрицателно)
    
SELECT
	sign(10); -- 1 (положително)
    
SELECT
	sign(0); -- 0 (нула)
    
    
-- 10. RAND() -> дава случайно число между 0 и 1
SELECT
	rand(); -- случайно число всеки път
    
SELECT
	rand(5); -- едно и също число всеки път
    
--                                       ФУНКЦИИ за ДАТИ

-- 01. NOW() -> дава ни текущата дата и час 
SELECT
	now(); -- 'YYYY-MM-DD' 'HH:MM:SS'
    
-- 02. EXTRACT() -> извличаме от някаква дата коя година е , кой месец е, кой ден е и т.н
SELECT
	extract(YEAR FROM '2025-01-15'); -- 2025
    
SELECT
	extract(MONTH FROM '2025-01-15'); -- 01
    
SELECT
	extract(DAY FROM '2026-01-14'); -- 14
    
SELECT
	extract(HOUR FROM now()); 

-- 03. TIMESTAMPDIFF() -> разликата м/у две дати 
-- разлика м/у две дати в години
SELECT
	timestampdiff(YEAR, '2026-01-15', '2025-01-15'); -- -1
    
SELECT
	timestampdiff(MONTH, '1985-01-03', now()); -- 492 
    
-- 04. DATEFORMAT() -> форматира дата по зададен шаблон 
-- %Y - година 
-- %m - месец 
-- %d - ден
-- %H - час 
-- %i - минути 
-- %s - секунди 
 
SELECT
	date_format(now(), '%d.%m.%Y'); -- 13.01.2026
    
SELECT
	date_format(now(), '%Y-%m-%d %H:%i:%s');
    
--                                      WILDCARDS

-- '%' -> показва ни 0, 1 ли повече символи 
-- '_' -> точно 1 символ 

SELECT * FROM `authors`
	WHERE first_name LIKE 'J%'; -- името започва с 'J'
    
SELECT * FROM `authors`
	WHERE first_name LIKE '%a'; -- името завършва с 'а'
    
SELECT * FROM `authors`
	WHERE first_name LIKE '%an%';    -- името съдържа сричката 'an'
    
    
SELECT * FROM `authors`
	WHERE first_name LIKE '_____'; -- име от 5 символа 
    
SELECT * FROM `authors`
	WHERE first_name LIKE '_а%'; -- втората буква е 'а' 
    
--                                            REGEX 

SELECT * FROM `authors`
	WHERE first_name REGEXP '[a-c]';
