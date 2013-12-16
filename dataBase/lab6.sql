--Laboratory 6
--1.Создайте последовательность 
CREATE SEQUENCE GENERATOR_ID
	START WITH 1
	INCREMENT BY 1
	NOMAXVALUE
	NOCYCLE;
	
--2.Добавьте в схему базы данных, разработанную Вами в лабораторной работе
--  №1, новую сущность. Создайте для этой сущности таблицу (таблицы). 
--	Причем, поле этой таблицы с ограничением первичного ключа должно 
--	заполняться с помощью последовательности. Заполните таблицу данными.
CREATE TABLE CONTRACT
		(ID_CONTRACT NUMBER(6) PRIMARY KEY,
		STARTDATE DATE,
		ENDDATE DATE,
		SALARY NUMBER(12),
		ID_SELLER NUMBER(4) REFERENCES SELLER(ID_SELLER));
		
INSERT INTO CONTRACT VALUES(GENERATOR_ID.NEXTVAL, 
							to_date('20-5-2011', 'dd-mm-yyyy'), 
							to_date('20-5-2014', 'dd-mm-yyyy'),
							1000000,
							1);
INSERT INTO CONTRACT VALUES(GENERATOR_ID.NEXTVAL, 
							to_date('25-7-2010', 'dd-mm-yyyy'), 
							to_date('25-7-2015', 'dd-mm-yyyy'),
							1800000,
							2);
INSERT INTO CONTRACT VALUES(GENERATOR_ID.NEXTVAL, 
							to_date('15-10-2012', 'dd-mm-yyyy'), 
							to_date('15-10-2017', 'dd-mm-yyyy'),
							3000000,
							3);

--3.Создайте индексы для тех полей базы данных, для которых это необходимо
CREATE INDEX SELLER_NAME ON SELLER(NAME);
CREATE INDEX SELLER_ADDRESS ON SELLER(ADDRESS);
CREATE INDEX STORAGE_ADDRESS ON STORAGES(ADDRESS);
CREATE INDEX BOOK_PUBLISHER ON BOOK(PUBLISHER);
CREATE INDEX BOOK_TITLE ON BOOK(TITLE);
CREATE INDEX AUTHOR_FIRSTNAME ON AUTHOR(FIRSTNAME);
CREATE INDEX AUTHOR_LASTNAME ON AUTHOR(LASTNAME);

--4.В одну из таблиц добавьте поле (внешний ключ), значения которого 
--  ссылаются на поле – первичный ключ этой таблицы. Составьте запросы 
--	на выборку данных с использованием рефлексивного соединения  
ALTER TABLE SELLER ADD (ID_CONTRACT NUMBER(6));
ALTER TABLE SELLER ADD CONSTRAINT ID_CONTRACT_FK 
			FOREIGN KEY (ID_CONTRACT) 
			REFERENCES CONTRACT(ID_CONTRACT);
ALTER TABLE SELLER ADD(RECOMMENDED_ID_SELLER NUMBER(4));
ALTER TABLE SELLER ADD CONSTRAINT ID_SELLER_FK 
			FOREIGN KEY (RECOMMENDED_ID_SELLER) 
			REFERENCES SELLER(ID_SELLER);

UPDATE SELLER SET RECOMMENDED_ID_SELLER = 2 WHERE ID_SELLER = 1;
UPDATE SELLER SET RECOMMENDED_ID_SELLER = 1 WHERE ID_SELLER = 2;
UPDATE SELLER SET RECOMMENDED_ID_SELLER = 2 WHERE ID_SELLER = 3;			
			
			
UPDATE SELLER SET ID_CONTRACT = 1 WHERE ID_SELLER = 1;
UPDATE SELLER SET ID_CONTRACT = 2 WHERE ID_SELLER = 2;
UPDATE SELLER SET ID_CONTRACT = 3 WHERE ID_SELLER = 3;

SELECT * FROM SELLER;

SELECT (SELECT NAME FROM SELLER WHERE SELLER.ID_SELLER = S.ID_SELLER) 
		|| ' WORKS FROM ' 
		|| C.STARTDATE 
		|| ' TO ' 
		|| C.ENDDATE AS 'DESCRIBE CONTRACT'
			FROM CONTRACT S INNER JOIN CONTRACT C ON S.ID_CONTRACT = C.ID_SELLER;
--Составьте запросы на выборку данных с использованием следующих операторов,
--конструкций и функций языка SQL:
--5.простого оператора CASE ();
SELECT TITLE, CASE PUBLISHER 
		WHEN 'ABC' THEN 'EXPENSIVE'
		WHEN 'ANDOR' THEN 'MEDIUM'
		ELSE 'LOW' END AS price_book 
	FROM BOOK;

--6.поискового оператора CASE();
SELECT TITLE, PUBLISHER, 
	CASE WHEN AMOUNT < 20 THEN 'NEED TO BUY' 
	WHEN AMOUNT >= 20 AND AMOUNT < 30 THEN 'NORMALLY'
	WHEN AMOUNT >= 30 THEN 'SUPER' END AS BOOKS_STATE 
		FROM BOOK_STORAGES JOIN BOOK ON BOOK_STORAGES.ISBN = BOOK.ISBN;

--7.оператора WITH();
--	название книги, издателя и адрес магазина, где заканчиваются книги
WITH NEED_BUY AS 
	(SELECT ISBN 
		FROM BOOK_STORAGES WHERE AMOUNT < 20)
SELECT TITLE, PUBLISHER, ADDRESS
	FROM BOOK_STORAGES JOIN BOOK USING(ISBN) JOIN STORAGES USING(ADDRESS) 
		WHERE ISBN IN (SELECT * FROM NEED_BUY);

--8.встроенного представления();
SELECT PUBLISHER, TITLE, LASTNAME
	FROM BOOK_AUTHOR 
	JOIN BOOK USING(ISBN)
	JOIN (SELECT ID_AUTHOR, LASTNAME 
			FROM AUTHOR 
			WHERE LASTNAME IN ('CARLSON', 'SMITH')) USING(ID_AUTHOR);

--9.некоррелированного запроса;
--	книги, начальная цена которых > 100000
SELECT * FROM BOOK 
	WHERE BOOK.ISBN IN (SELECT ISBN FROM BOOK_STORAGES WHERE PRICE > 100000)
	ORDER BY TITLE
	GROUP BY TITLE;

--10.коррелированного запроса;
SELECT ID_BILL, BILL_DATE FROM BILL B
	WHERE B.ID_OPER = '1' AND ID_BILL IN (SELECT ID_BILL
						FROM BILL
						NATURAL JOIN TYPE_OPERATION
						WHERE ID_OPER = B.ID_OPER);

--11.функции NULLIF;
SELECT COUNT (NULLIF(PUBLISHER, 'ANDOR')) AS GOOD_BOOKS 
	FROM BOOK;

--12.функции NVL2;
SELECT ISBN, NVL2(NULLIF(PUBLISHER, 'ANDOR'), PUBLISHER || ' IS GOOD PUBLISHER', PUBLISHER || ' IS BAD PUBLISHER') 
	FROM BOOK;  

--13.TOP-N анализа();
SELECT * FROM (SELECT *
				FROM BOOK
				ORDER BY TITLE ASC)
	WHERE ROWNUM <= 5;

--14. функции ROLLUP();
SELECT ISBN, COUNT(ISBN) AS ALL_BOOKS
	FROM BOOK_STORAGES 
	GROUP BY ROLLUP(ISBN)
    ORDER BY ISBN;

--15.Составьте запрос на использование оператора MERGE языка 
--	 манипулирования данными.

CREATE TABLE NEW_BOOK(ISBN VARCHAR2(20) PRIMARY KEY,
					  PUBLISHER VARCHAR2(20),
					  TITLE VARCHAR2(100) NOT NULL);
COMMIT;

INSERT INTO NEW_BOOK VALUES('0-11-5005-6755', 'PITER', 'VOYNA I MIR. UTOPIA');
INSERT INTO NEW_BOOK VALUES('1-94-2115-5065', 'ANDOR', 'BATMAN AND SUPER COMPANY');
INSERT INTO NEW_BOOK VALUES('5-13-2636-7428', 'FABRIKA', 'PROSTO KNIGA');
INSERT INTO NEW_BOOK VALUES('3-54-1134-4799', 'ABC', 'ABC. HISTORY. PART 6');
					  

MERGE INTO BOOK B
	USING(SELECT * 
		FROM NEW_BOOK) NB
		ON(B.ISBN = NB.ISBN)
	WHEN NOT MATCHED
		THEN INSERT VALUES(NB.ISBN, NB.PUBLISHER, NB.TITLE);
						  
SELECT * FROM BOOK;
	
