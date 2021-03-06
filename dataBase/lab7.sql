--Laboratory 7
--1.Лоточная торговля книгами
--	Триггер должен препятствовать удалению продавца, если остаток книг, 
--	числящийся за этим продавцом, не пуст.
--	СПРОСИТЬ ПРО MUTATING!
CREATE OR REPLACE TRIGGER CHECK_DELETE_SELLER 
	BEFORE DELETE ON SELLER FOR EACH ROW 
DECLARE 
	KOL INTEGER;
BEGIN
	SELECT SUM(AMOUNT) INTO KOL FROM BOOK_STORAGES 
			WHERE ADDRESS = (SELECT ADDRESS FROM SELLER WHERE ID_SELLER = :OLD.ID_SELLER));	
	IF KOL > 0 THEN RAISE_APPLICATION_ERROR(-20212, 'SELLER HAS BOOKS!');
	END IF;
END CHECK_DELETE_SELLER;

DELETE FROM SELLER WHERE ID_SELLER = 1;

-- Мой триггер
CREATE OR REPLACE TRIGGER CHECK_INSERT_BOOK
	BEFORE INSERT ON BOOK FOR EACH ROW 
DECLARE 
    KOL INTEGER;   
BEGIN
    SELECT COUNT(*) INTO KOL FROM BOOK WHERE TITLE = :NEW.TITLE;
	IF KOL > 0 THEN RAISE_APPLICATION_ERROR(-20212, 'BOOK EXISTS ALREADY');
	END IF;
END CHECK_INSERT_BOOK;


INSERT INTO BOOK(ISBN, PUBLISHER, TITLE) VALUES('3-54-1154-4713', 'ABC', 'ABC. HISTORY. PART 2');


INSERT INTO BOOK(ISBN, PUBLISHER, TITLE) VALUES('3-54-1054-4722', 'ABC', 'ABC. HISTORY. PART 4');