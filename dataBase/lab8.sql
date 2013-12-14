--Laboratory 7
--1.Добавьте в таблицу SALARY столбец TAX (налог) для вычисления 
--ежемесячного подоходного налога на зарплату по прогрессивной шкале. 
--Налог вычисляется по следующему правилу: 
--	налог равен 9% от начисленной  в месяце зарплаты, если суммарная 
--		зарплата с начала года до конца рассматриваемого месяца не 
--		превышает 20 000;
--	налог равен 12% от начисленной  в месяце зарплаты, если суммарная
--		зарплата с начала года до конца рассматриваемого месяца 
--		больше 20 000, но не превышает 30 000;
--	налог равен 15% от начисленной  в месяце зарплаты, если суммарная 
--		зарплата с начала года до конца рассматриваемого месяца  
--		больше 30 000.
ALTER TABLE salary add(tax NUMBER(15));

--2.Составьте программу вычисления налога и вставки её в таблицу SALARY:
--a) с помощью простого цикла (loop) с курсором и оператора if;
DECLARE
	CURSOR add_tax IS 
		SELECT * FROM salary FOR UPDATE OF salary.tax; 
	CURSOR get_sum_salvalue	[cur_month, cur_year] IS 
		SUM(SELECT salvalue FROM salary 
				WHERE salary.month = cur_month
				AND salary.year = cur_year);  
	zap add_tax%ROWTYPE;
	sum_salvalue salary.salvalue%TYPE;
	tax salary.tax%TYPE;
BEGIN
	OPEN add_tax;
	LOOP
		FETCH add_tax INTO zap;
		OPEN get_sum_salvalue(zap.month, zap.year);
		FETCH get_sum_salvalue INTO sum_salvalue;
		CLOSE get_sum_salvalue;
		EXIT WHEN add_tax%NOTFOUND;
		IF sum_salvalue <= 20000
			THEN tax = 9;
		ELSIF sum_salvalue > 20000 AND sum_salvalue <= 30000
			THEN tax = 12;
		ELSE tax = 15;
		END IF;
		UPDATE salary SET salary.tax = tax
			WHERE CURRENT OF add_tax;
	END LOOP;
	CLOSE add_tax;
	COMMIT;
END;

--b)с помощью простого цикла (loop) с курсором и оператора case;
DECLARE
	CURSOR add_tax IS 
		SELECT * FROM salary FOR UPDATE OF salary.tax; 
	CURSOR get_sum_salvalue	[cur_month, cur_year] IS 
		SUM(SELECT salvalue FROM salary 
				WHERE salary.month = cur_month
				AND salary.year = cur_year);  
	zap add_tax%ROWTYPE;
	sum_salvalue salary.salvalue%TYPE;
	tax salary.tax%TYPE;
BEGIN
	OPEN add_tax;
	LOOP
		FETCH add_tax INTO zap;
		OPEN get_sum_salvalue(zap.month, zap.year);
		FETCH get_sum_salvalue INTO sum_salvalue;
		CLOSE get_sum_salvalue;
		EXIT WHEN add_tax%NOTFOUND;
		CASE
			WHEN sum_salvalue <= 20000 THEN tax = 9;
			WHEN sum_salvalue > 20000 AND sum_salvalue <= 30000 THEN tax = 12;
			ELSE tax = 15;
		END;
		UPDATE salary SET salary.tax = tax
			WHERE CURRENT OF add_tax;
	END LOOP;
	CLOSE add_tax;
	CLOSE get_sum_salvalue;
	COMMIT;
END;		

--c)с помощью курсорного цикла FOR;
DECLARE
	CURSOR add_tax IS 
		SELECT * FROM salary FOR UPDATE OF salary.tax; 
	CURSOR get_sum_salvalue	[cur_month, cur_year] IS 
		SUM(SELECT salvalue FROM salary 
				WHERE salary.month = cur_month
				AND salary.year = cur_year);  
	zap add_tax%ROWTYPE;
	sum_salvalue salary.salvalue%TYPE;
	tax salary.tax%TYPE;
BEGIN
	FOR zap IN add_tax LOOP
		OPEN get_sum_salvalue(zap.month, zap.year);
		FETCH get_sum_salvalue INTO sum_salvalue;
		EXIT WHEN add_tax%NOTFOUND;
		CASE
			WHEN sum_salvalue <= 20000 THEN tax = 9;
			WHEN sum_salvalue > 20000 AND sum_salvalue <= 30000 
				THEN tax = 12;
			ELSE tax = 15;
		END;
		UPDATE salary SET salary.tax = tax
			WHERE CURRENT OF add_tax;
		CLOSE get_sum_salvalue;
	END LOOP;
	COMMIT;
END; 

--d)с помощью курсора с параметром, передавая номер сотрудника, 
--	для которого необходимо посчитать налог. 
DECLARE 
	CURSOR add_tax_num [num_emp] IS
		SELECT * FROM salary WHERE salary.empno = num_emp
		FOR UPDATE OF salary.tax;
	CURSOR get_sum_salvalue	[cur_month, cur_year] IS 
	SUM(SELECT salvalue FROM salary 
			WHERE salary.month = cur_month
			AND salary.year = cur_year);
	zap add_tax_num%ROWTYPE;
	sum_salvalue salary.salvalue%TYPE;
	tax salary.tax%TYPE;
BEGIN
	OPEN add_tax_num(10); 
	LOOP
		OPEN get_sum_salvalue(zap.month, zap.year);
		FETCH get_sum_salvalue INTO sum_salvalue;
		EXIT WHEN add_tax%NOTFOUND;
		CASE
			WHEN sum_salvalue <= 20000 THEN tax = 9;
			WHEN sum_salvalue > 20000 AND sum_salvalue <= 30000 
				THEN tax = 12;
			ELSE tax = 15;
		END;
		UPDATE salary SET salary.tax = tax
			WHERE CURRENT OF add_tax;
		CLOSE get_sum_salvalue;
	END LOOP;
	CLOSE add_tax_num;
	COMMIT;
END;  