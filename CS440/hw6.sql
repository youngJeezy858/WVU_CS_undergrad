/*
	Kyle Frank
	CS440
	Assignment 6
	March 4, 2013
*/

set serveroutput on format wrapped size 1000000;
set line 140;

CREATE OR REPLACE PROCEDURE center (text in out varchar2)
IS
	spaces number;
	space_string varchar2(70);
BEGIN
	spaces := (140 - length(text)) / 2;
	space_string := '';
	FOR x in 2..spaces LOOP
		space_string := space_string || ' ';
	end LOOP;
	text := space_string || text || space_string;
END center;
/

CREATE OR REPLACE PROCEDURE Salary_Report
IS
	temp_line varchar2(140);
	temp_dept varchar2(20);
	temp_ename varchar2(20);
	temp_sal number(7,2);
	temp_date date;
BEGIN
	temp_line := to_char(sysdate, 'Day, FMMonth DD, YYYY');
	center(temp_line);
	dbms_output.put_line(temp_line);
	dbms_output.put_line(' ');
	temp_line := 'Regal Lager';
	center(temp_line);
	dbms_output.put_line(temp_line);
	dbms_output.put_line(' ');
	temp_line := 'More than a Great Brew - a Palindrome';
	center(temp_line);
	dbms_output.put_line(htf.italic(temp_line));
	dbms_output.put_line(' ');
	dbms_output.put_line(' ');
	temp_line := 'Departmental Salary Report';
        center(temp_line);
        dbms_output.put_line(temp_line);
        dbms_output.put_line(' ');

	FOR d_no in (select deptno from dept) LOOP
		select dname into temp_dept from dept where dept.deptno = d_no.deptno;
		temp_line := 'Department: ' || temp_dept;
        	center(temp_line);
        	dbms_output.put_line(temp_line);
     		
		FOR e_no in (select empno from emp where deptno = d_no.deptno) LOOP
			select ename into temp_ename from emp where empno = e_no.empno;
			select sal into temp_sal from emp where empno = e_no.empno;
			temp_line := temp_ename || ' ' || to_char(temp_sal, '$99,999.99');
			center(temp_line);
			dbms_output.put_line(temp_line);
		end LOOP;
		
		select sum(sal) into temp_sal from emp where deptno = d_no.deptno;
		temp_line := 'Total ' || temp_dept || ' salary: ' || to_char(temp_sal, '$99,999.99');
		center(temp_line);
		dbms_output.put_line(temp_line);
		select avg(sal) into temp_sal from emp where deptno = d_no.deptno;
		temp_line := 'Average ' || temp_dept || ' salary: ' || to_char(temp_sal, '$99,999.99');
		center(temp_line);
                dbms_output.put_line(temp_line);
		dbms_output.put_line(' ');		
	end LOOP;

	dbms_output.put_line(' ');
	dbms_output.put_line(' ');
	dbms_output.put_line(' ');
	temp_line := 'Company Salaries:';
        center(temp_line);
        dbms_output.put_line(temp_line);
	select sum(sal) into temp_sal from emp;
	temp_line := 'Total Regal Lager Salaries: ' || to_char(temp_sal, '$99,999.99');
        center(temp_line);
	dbms_output.put_line(temp_line);
	select avg(sal) into temp_sal from emp;
        temp_line := 'Average Regal Lager Salaries: ' || to_char(temp_sal, '$99,999.99');
        center(temp_line);
	dbms_output.put_line(temp_line);
	dbms_output.put_line(' ');
	temp_line := 'End of Report';
        center(temp_line);
	dbms_output.put_line(temp_line);
END Salary_Report;
/