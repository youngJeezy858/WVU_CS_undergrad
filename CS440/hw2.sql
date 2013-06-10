
/* 	Kyle Frank
	CS 440
	Assignment 2
	January 28, 2013
*/

set echo on

Begin
  FOR c IN
  (SELECT c.owner, c.table_name, c.constraint_name
   FROM user_constraints c, user_tables t
   WHERE c.table_name = t.table_name
   AND c.status = 'ENABLED'
   ORDER BY c.constraint_type DESC)
  LOOP
    dbms_utility.exec_ddl_statement('alter table "' || c.owner || '"."' || c.table_name || '" drop constraint ' || c.constraint_name);
  END LOOP;

   For i in (select i.index_name from user_indexes i)
      loop
       dbms_utility.exec_ddl_statement('drop index "' || i.index_name || '"');
     end loop;
End;
/

--	Problem 1a

ALTER TABLE dept
	add constraint dept_pk primary key (deptno) 
			deferrable initially immediate
;

--	Problem 1b


ALTER TABLE dept
	modify(
		dname constraint dname_uq unique 
					deferrable initially immediate 
		constraint dname_nn not null 
					deferrable initially immediate);

--	Problem 2

alter table emp
	modify (
--		a
		deptno constraint dept_pk primary key
					deferrable initially immediate,
--		b
		ename constraint ename_uq unique deferrable initially immediate
		     constraint ename_nn not null deferrable initially immediate,
--		c
		 mgr constraint mgr_fk references emp(empno) 
					deferrable initially immediate,
--		d
		deptno constraint deptno_fk references dept(deptno) deferrable
							initially immediate,
--		e
		sal constraint sal_chk check (sal between 500 and 10000)
						deferrable initially immediate
);

--	Problem 3

alter table s
	modify (
--		a
		s# constraint s#_pk primary key 
					deferrable initially immediate,
--		b
		sname constraint sname_uq unique deferrable initially immediate
		     constraint sname_nn not null deferrable initially immediate
);

--	Problem 4
 
alter table p
	modify(
--		a
		p# constraint p#_pk primary key
					deferrable initially immediate,
--		b
		pname constraint pname_uq unique deferrable initially immediate
		     constraint pname_nn not null deferrable initially immediate
);

--	Problem 5

--		a
alter table sp
	add constraint sp_pk primary key (p#, s#);
alter table sp
	modify(
--		b
		qty constraint qty_check check (qty >= 0) deferrable initially 
								immediate,
--		c
		s# constraint s#_fk references s(s#) deferrable initially 
								immediate,
		p# constraint p#_fk references p(p#) deferrable initially
								immediate
);

--	Problem 6

create index emp_deptno on emp(deptno);

--	Problem 7

select add_months(hiredate, -12) from emp where hiredate > sysdate;

--	Problem 8

select index_name,
	table_name
from user_indexes
;

--	Problem 9

select constraint_name,
	table_name
from user_constraints
;