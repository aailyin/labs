--Laboratory 4
--1.Поднимите нижнюю границу минимальной заработной платы в таблице JOB до 1000$.
UPDATE JOB SET MINSALARY = 1000 WHERE MINSALARY = (SELECT MIN(MINSALARY) FROM JOB);

--2.Поднимите минимальную зарплату в таблице JOB на 10% для всех специальностей, кроме финансового директора.
UPDATE job SET minsalary = 1.1*minsalary  WHERE jobname != 'FINANCIAL DIRECTOR';

--3.Поднимите минимальную зарплату в таблице JOB на 10% для клерков и на 20% для финансового директора (одним оператором).
UPDATE JOB SET MINSALARY = MINSALARY * (WHEN JOBNAME = 'CLERK' THEN 1.1 ELSE 1.2 END)
		WHERE JOBNAME IN ('FINANCIAL DIRECTOR', 'CLERK');

--4.Установите минимальную зарплату финансового директора равной 90% от зарплаты исполнительного директора.
UPDATE job SET minsalary = 0.9*(SELECT minsalary FROM job WHERE jobname = 'EXECUTIVE DIRECTOR') 
		WHERE jobname = 'FINANCIAL DIRECTOR';

--5.Приведите в таблице EMP имена служащих, начинающиеся на букву ‘J’, к нижнему регистру.
UPDATE EMP SET EMPNAME = LCASE(EMPNAME) WHERE EMPNAME LIKE 'J%';

--6.Измените в таблице EMP имена служащих, состоящие из двух слов, так, чтобы оба слова в имени начинались 
--  с заглавной буквы, а продолжались прописными. 
UPDATE emp SET empname = INITCAP(empname) WHERE INSTR(empname, ' ') != 0; 

--7.Приведите в таблице EMP имена служащих к верхнему регистру.
UPDATE EMP SET EMPNAME = UCASE(EMPNAME)

--8.Исправьте даты рождения в таблице EMP, в которых год приходится на первый век нашей эры по следующему 
--	правилу: даты до 03 года 
--  включительно относятся к 21-му веку, а с 04 по 99 год - к 20-му веку.
--  Эту хрень делать не нужно!:)

--9.Перенесите отдел исследований (RESEARCH) в тот же город, в котором расположен отдел продаж (SALES).
UPDATE DEPT SET DEPTADDR = (SELECT DEPTADDR FROM DEPT WHERE DEPTNAME = 'SALES') WHERE DEPTNAME = 'RESEARCH';

--10.Добавьте нового сотрудника в таблицу EMP. Его имя и фамилия должны совпадать с Вашими, записанными латинскими буквами 
--   согласно паспорту, дата рождения также совпадает с Вашей.
INSERT INTO emp VALUES('8080', 'ANTON-ALIAKSEI ILYIN', to_date('30.03.1992', 'dd.mm.yyyy'));  

--11.Определите нового сотрудника (см. предыдущее задание) на работу в бухгалтерию (отдел ACCOUNTING) начиная с текущей даты.


--12.Удалите все записи из таблицы TMP_EMP. Добавьте в нее информацию о сотрудниках, которые работают 
--   клерками в настоящий момент.
DELETE FROM tmp_emp; 
INSERT INTO tmp_emp SELECT empno, empname, birthdate FROM emp 
		WHERE emp.empno = (SELECT empno FROM career C 
										JOIN job J ON C.jobno = J.jobno 
										WHERE jobname = 'CLERCK' 
										AND enddate IS NULL);
 

--13.Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые уже не работают на предприятии, а в период 
--   работы занимали только одну должность.


--14.Выполните тот же запрос для тех сотрудников, которые никогда не приступали к работе на предприятии.
INSERT INTO tmp_emp SELECT empno, empname, birthdate FROM career JOIN emp USING(empno) WHERE startdate IS NULL;

--15.Удалите все записи из таблицы TMP_JOB и добавьте в нее информацию по тем специальностям, которые не 
--   используются в настоящий момент на предприятии.
DELETE FROM TMP_JOB;
INSERT INTO TMP_JOB VALUES(SELECT * FROM JOB WHERE JOBNO NOT IN (SELECT JOBNO FROM EMP));

--16.Начислите зарплату в размере 120% минимального должностного оклада всем сотрудникам, работающим на предприятии. 
--   Зарплату начислять по должности, занимаемой сотрудником в настоящий момент и отнести ее на прошлый месяц 
--   относительно текущей даты.
INSERT INTO salary SELECT empno, EXTRACT(month from add_months(sysdate, -1)), 
		EXTRACT(year from add_months(sysdate, -1)), 1.2 * minsalary FROM CAREER 
		NATURAL JOIN EMP 
		NATURAL JOIN JOB 
		WHERE ENDDATE IS NULL;

--17.Удалите данные о зарплате за прошлый год.
DELETE FROM SALARY WHERE YEAR = 2012;

--18.Удалите информацию о карьере сотрудников, которые в настоящий момент уже не работают на предприятии, 
--   но когда-то работали.
DELETE FROM career WHERE enddate <= SYSDATE AND enddate IS NOT NULL;

--19.Удалите информацию о начисленной зарплате сотрудников, которые в настоящий момент уже не работают на предприятии 
--   (можно использовать результаты работы предыдущего запроса)
DELETE FROM SALARY WHERE EMPNO IN (SELECT EMPNO FROM TMP_EMP);

--20.Удалите записи из таблицы EMP для тех сотрудников, которые никогда не приступали к работе на предприятии.
DELETE FROM emp E1 WHERE E1.empno = (SELECT empno FROM career WHERE career.startdate IS NULL);


