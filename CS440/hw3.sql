
/*
	Kyle Frank
	CS 440
	Assignment 3
	February 4, 2013
*/

set echo on

-- Problem 1

UPDATE emp
SET mgr = (select empno from emp where ename = 'TURNER')
WHERE ename = 'SCOTT';
rollback;

-- Problem 2

INSERT into dept (deptno, dname, loc)
VALUES (55, 'PR', 'Wheeling');
UPDATE emp
SET deptno = 55
WHERE deptno = (select deptno from  dept where dname = 'RESEARCH');
rollback;

-- Problem 3 

SELECT ename from emp minus
SELECT ename
FROM emp
WHERE mgr = (select mgr from emp where ename = 'MARTIN');
 
-- Problem 4

SELECT sname, pname from s
LEFT JOIN sp using (s#)
LEFT JOIN p using (p#)
ORDER BY sname, pname;
    
-- Problem 5

SELECT distinct pname
FROM sp natural join p
WHERE pname != 'stapler'
	and s# in (select s# from sp natural join p where pname = 'stapler');

-- Problem 6

SELECT pname
FROM p minus
SELECT pname from p join sp using (p#) join s using (s#)
WHERE upper(s.city) = 'BONN';
  
-- Problem 7

SELECT sname FROM s
WHERE 3 <= (select count(distinct city)
		from sp natural join p where s# = s.s#);
  
-- Problem 8

SELECT dname, avg(sal) from dept
LEFT JOIN emp using (deptno) group by dname;

-- Problem 9

SELECT dname from dept
WHERE deptno not in (SELECT deptno from emp);
 
-- Problem 10

SELECT b.dname, a.ename, a.sal from emp a join dept b on a.deptno = b.deptno
WHERE a.sal = (select max(sal) from emp where deptno = b.deptno);