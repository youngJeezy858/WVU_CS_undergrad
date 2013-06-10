/*
	Kyle Frank
	CS440
	Assignment 5
	February 15, 2013
*/

--1.	a)  List part names of all parts supplied by suppliers s1, s2, or s4.

SELECT distinct pname from p join sp using (p#)
WHERE s# = 's1' OR s# = 's2' OR s# = 's4';

--	b)  List part names of all parts supplied by all three (s1, s2, and s4).

SELECT pname from p join sp a using (p#) join sp b using (p#) join sp c using (p#)
WHERE a.s# = 's1' AND b.s# = 's2' AND c.s# = 's4';

--2.	List supplier names of suppliers who do not supply every red part.

SELECT sname FROM s
MINUS
SELECT a.sname FROM s a join sp b on a.s#=b.s# join sp c on c.s#=a.s#
WHERE (SELECT distinct color FROM p WHERE b.p# = p#)='red' 
AND (SELECT distinct color FROM p WHERE c.p# = p#) = 'red' 
AND c.p# != b.p#;

--3.	List supplier names of suppliers who don’t supply part p5 but who do supply part p4.

SELECT sname FROM s join sp using (s#)
WHERE p# = 'p4'
MINUS
SELECT sname FROM s join sp using (s#)
WHERE p# = 'p5';

--4.	List supplier names of suppliers who supply the second highest quantity (for a single part).

WITH T AS
(SELECT s#, DENSE_RANK() OVER (ORDER BY qty DESC) as rank FROM sp WHERE qty is not null)
SELECT sname FROM s JOIN T using (s#) WHERE rank = 2;

--5.	List supplier names of suppliers who do supply at least 2 distinct parts but do not supply part p3.

SELECT sname FROM s a 
WHERE (SELECT count(p#) FROM sp WHERE a.s# = s#) >= 2 
MINUS
SELECT sname FROM sp join s using (s#) WHERE p# = 'p3';

--6.	For suppliers that supply at least 3 parts, list the supplier name and the top 3 
--	(by qty) parts name, in order of highest to lowest quantity (so each row will have the name of a supplier and three parts). 

WITH T AS
(SELECT sname, pname, qty, RANK() OVER (partition by sname ORDER BY qty DESC) as rank FROM s join sp using (s#) join p using (p#) order by s#, qty desc)
SELECT a.sname, b.pname, c.pname, d.pname
FROM (select sname from s natural join sp group by sname having count(*) >= 3) a
join T b on a.sname = b.sname and b.rank=1
join T c on a.sname = c.sname and c.rank=2
join T d on a.sname = d.sname and d.rank=3;

--7.	List supplier names with minimum quantity supplied if that supplier supplies 
--	at least one part whose qty exceeds the maximum quantity of part p2.

SELECT distinct sname, (SELECT min(qty) FROM sp c WHERE c.s#=b.s#) "MIN_QTY" FROM sp a join s b on a.s#=b.s#
WHERE qty > (SELECT max(qty) FROM sp WHERE p# = 'p2');

--8.	List the names of all suppliers, the names of parts they supply, the quantity 
--	supplied, the max quantity that the supplier supplies of any part and the maximum  quantity of that part supplied by any supplier. 

SELECT sname, pname, qty, 
max(qty) over (partition by sname) "maxSName",
max(qty) over (partition by pname) "maxPName"
FROM sp b join s c ON b.s#=c.s# join p d ON b.p#=d.p#;

--9.	List the names of all supervisors of the employee Adams and the supervisors’ 
--	level above Adams.  Do not list any analyst if one should be a supervisor of Adams.

SELECT ename, level-1 "level" from emp
where lower(ename)!='adams' and lower(job)!='analyst'
start with lower(ename)='adams' connect by prior mgr=empno;

--10.	List the company management hierarchy with employee name, supervisor name, 
--	employee’s level below the president; do not print any employee who is a clerk. Indent each subsequent 
--	employee 3 spaces as the list moves down the company hierarchy.

col name format a20;
SELECT lpad(' ', 3*(level-1))||ename name,
(select ename from emp where empno=x.mgr) mgr, level-1 "level"
from emp x where lower(job)!='clerk'
start with mgr is null connect by prior empno=mgr;