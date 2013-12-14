--Laboratory 5
--1.Создайте представление, содержащее данные о сотрудниках пенсионного возраста.
CREATE OR REPLACE VIEW old_emp AS SELECT empname, birthdate, deptname, startdate, jobname
	FROM career 
	JOIN emp USING(empno)
	JOIN job USING(jobno)
	JOIN dept USING(deptno)
	WHERE (EXTRACT(year FROM SYSDATE) - EXTRACT(year FROM birthdate)) >= 60;
	
--2.Создайте представление, содержащее данные об уволенных сотрудниках: имя сотрудника, 
--	дата увольнения, отдел, должность.	
CREATE OR REPLACE VIEW delete_emp AS SELECT empname, enddate, deptname, jobname
	FROM career
	JOIN emp USING(empno)
	JOIN job USING(jobno)
	JOIN dept USING(deptno)
	WHERE enddate IS NOT NULL;
	
--3.Создайте представление, содержащее имя сотрудника, должность, занимаемую сотрудником
--  в данный момент, суммарную заработную плату сотрудника за третий квартал 2010 года. 
--  Первый столбец назвать Sotrudnik, второй – Dolzhnost, третий – Itogo_3_kv.
CREATE OR REPLACE VIEW itogo_emp(Sotrudnik, Dolzhnost, Itogo_3_kv) 
	AS SELECT DISTINCT E.empname, J.jobname, SAL.summa
		FROM salary S, career C, emp E, job J
			(SELECT empname, SUM(CASE WHEN (salary.year = 2010 AND salary.month IN (7, 8, 9)) THEN salvalue ELSE 0 END) AS summa
				FROM salary, emp WHERE emp.empno = salary.empno
				GROUP BY empname) SAL
			WHERE J.jobno = C.jobno AND E.empno = C.empno 
			AND E.empno = S.empno 
			AND SAL.empname = E.empname
			AND C.enddate IS NULL;
		
--4.На основе представления из задания 2 и таблицы SALARY создайте представление, 
--  содержащее данные об уволенных сотрудниках, которым зарплата начислялась 
--  более 2 раз. В созданном представлении месяц начисления зарплаты и сумма зарплаты 
--  вывести в одном столбце, в качестве разделителя использовать запятую.	
CREATE VIEW dim_salary(empname, enddate, deptname, jobname, sum_of_month) AS
    SELECT D.empname, D.enddate, D.deptno, D.jobname, S.month || ', ' || S.salvalue AS sum_of_month
    FROM delete_emp D NATURAL JOIN salary S
    WHERE S.empno IN (SELECT empno
                        FROM delete_emp NATURAL JOIN salary
                        GROUP BY empno
                        HAVING COUNT(salvalue) > 2);

	