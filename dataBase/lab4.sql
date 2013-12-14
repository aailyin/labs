--Laboratory 4
--1.Поднимите нижнюю границу минимальной заработной платы в таблице job до 1000$.
UPDATE job SET minsalary = 1000 WHERE minsalary = (SELECT MIN(minsalary) FROM job);

--2.Поднимите минимальную зарплату в таблице job на 10% для всех специальностей, кроме финансового директора.
UPDATE job SET minsalary = 1.1*minsalary  WHERE jobname != 'FINANCIAL DIRECTOR';

--3.Поднимите минимальную зарплату в таблице job на 10% для клерков и на 20% для финансового директора (одним оператором).
UPDATE job SET minsalary = minsalary * (CASE WHEN jobname = 'CLERK' THEN 1.1 ELSE 1.2 END)
		WHERE jobname IN ('FINANCIAL DIRECTOR', 'CLERK');

--4.Установите минимальную зарплату финансового директора равной 90% от зарплаты исполнительного директора.
UPDATE job SET minsalary = 0.9*(SELECT minsalary FROM job WHERE jobname = 'EXECUTIVE DIRECTOR') 
		WHERE jobname = 'FINANCIAL DIRECTOR';

--5.Приведите в таблице emp имена служащих, начинающиеся на букву ‘J’, к нижнему регистру.
UPDATE emp SET empname = LCASE(empname) WHERE empname LIKE 'J%';

--6.Измените в таблице emp имена служащих, состоящие из двух слов, так, чтобы оба слова в имени начинались 
--  с заглавной буквы, а продолжались прописными. 
UPDATE emp SET empname = INITCAP(empname) WHERE INSTR(empname, ' ') != 0; 

--7.Приведите в таблице emp имена служащих к верхнему регистру.
UPDATE emp SET empname = UCASE(empname);

--8.Исправьте даты рождения в таблице emp, в которых год приходится на первый век нашей эры по следующему 
--	правилу: даты до 03 года 
--  включительно относятся к 21-му веку, а с 04 по 99 год - к 20-му веку.
--  Это делать не нужно!:)

--9.Перенесите отдел исследований (RESEARCH) в тот же город, в котором расположен отдел продаж (SALES).
UPDATE dept SET deptaddr = (SELECT deptaddr FROM dept WHERE deptname = 'SALES') WHERE deptname = 'RESEARCH';

--10.Добавьте нового сотрудника в таблицу emp. Его имя и фамилия должны совпадать с Вашими, записанными латинскими буквами 
--   согласно паспорту, дата рождения также совпадает с Вашей.
INSERT INTO emp VALUES('8080', 'ANTON-ALIAKSEI ILYIN', to_date('30.03.1992', 'dd.mm.yyyy'));  

--11.Определите нового сотрудника (см. предыдущее задание) на работу в бухгалтерию (отдел ACCOUNTING) начиная с текущей даты.
INSERT INTO career VALUES (1004, 8000, 10, SYSDATE, NULL);
INSERT INTO career VALUES (1004, 8001, 10, SYSDATE, NULL);

--12.Удалите все записи из таблицы TMP_emp. Добавьте в нее информацию о сотрудниках, которые работают 
--   клерками в настоящий момент.
DELETE FROM tmp_emp; 
INSERT INTO tmp_emp SELECT empno, empname, birthdate FROM emp 
		WHERE emp.empno = (SELECT empno FROM career C 
				JOIN job J ON C.jobno = J.jobno 
				WHERE jobname = 'CLERCK' 
				AND startdate IS NOT NULL
				AND enddate IS NULL);
 

--13.Добавьте в таблицу TMP_emp информацию о тех сотрудниках, которые уже не работают на предприятии, а в период 
--   работы занимали только одну должность.
INSERT INTO TMP_emp
    SELECT * FROM emp E
    WHERE E.empno IN (SELECT empno
                        FROM career C
                        WHERE enddate IS NOT NULL
                                        AND enddate < current_date
                                        having COUNT(SELECT empno FROM career K
                                        WHERE C.empno = K.empno)=1);

--14.Выполните тот же запрос для тех сотрудников, которые никогда не приступали к работе на предприятии.
INSERT INTO tmp_emp SELECT empno, empname, birthdate FROM career JOIN emp USING(empno) WHERE startdate IS NULL;

--15.Удалите все записи из таблицы tmp_job и добавьте в нее информацию по тем специальностям, которые не 
--   используются в настоящий момент на предприятии.
DELETE FROM tmp_job;
INSERT INTO tmp_job VALUES(SELECT * FROM job J WHERE NOT EXISTS (SELECT * FROM career C WHERE C.jobno = J.jobno));

--16.Начислите зарплату в размере 120% минимального должностного оклада всем сотрудникам, работающим на предприятии. 
--   Зарплату начислять по должности, занимаемой сотрудником в настоящий момент и отнести ее на прошлый месяц 
--   относительно текущей даты.
INSERT INTO salary SELECT empno, EXTRACT(month FROM add_months(SYSDATE, -1)), 
		EXTRACT(year FROM add_months(sysdate, -1)), 1.2 * minsalary FROM career 
		NATURAL JOIN emp 
		NATURAL JOIN job 
		WHERE enddate IS NULL;

--17.Удалите данные о зарплате за прошлый год.
DELETE FROM salary WHERE YEAR = EXTRACT(YEAR FROM SYSDATE)-1;

--18.Удалите информацию о карьере сотрудников, которые в настоящий момент уже не работают на предприятии, 
--   но когда-то работали.
DELETE FROM career WHERE enddate <= SYSDATE AND enddate IS NOT NULL;

--19.Удалите информацию о начисленной зарплате сотрудников, которые в настоящий момент уже не работают на предприятии 
--   (можно использовать результаты работы предыдущего запроса)
DELETE FROM salary WHERE empno = (SELECT empno FROM career
                        WHERE enddate IS NOT NULL
                        AND enddate <= SYSDATE);

--20.Удалите записи из таблицы emp для тех сотрудников, которые никогда не приступали к работе на предприятии.
DELETE FROM emp E1 WHERE E1.empno = (SELECT empno FROM career WHERE career.startdate IS NULL);


