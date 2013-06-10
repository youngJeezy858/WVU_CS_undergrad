sqlplus>@hw2.sql
sqlplus>
sqlplus>/*	Kyle Frank
sqlplus>	CS 440
sqlplus>	Assignment 2
sqlplus>	January 28, 2013
sqlplus>*/
sqlplus>
sqlplus>set echo on
sqlplus>
sqlplus>Begin
  2    FOR c IN
  3    (SELECT c.owner, c.table_name, c.constraint_name
  4  	FROM user_constraints c, user_tables t
  5  	WHERE c.table_name = t.table_name
  6  	AND c.status = 'ENABLED'
  7  	ORDER BY c.constraint_type DESC)
  8    LOOP
  9  	 dbms_utility.exec_ddl_statement('alter table "' || c.owner || '"."' || c.table_name || '" drop constraint ' || c.constraint_name);
 10    END LOOP;
 11  
 12  	For i in (select i.index_name from user_indexes i)
 13  	   loop
 14  	    dbms_utility.exec_ddl_statement('drop index "' || i.index_name || '"');
 15  	  end loop;
 16  End;
 17  /

PL/SQL procedure successfully completed.

sqlplus>
sqlplus>--	Problem 1a
sqlplus>
sqlplus>ALTER TABLE dept
  2  	     add constraint dept_pk primary key (deptno)
  3  			     deferrable initially immediate
  4  ;

Table altered.

sqlplus>
sqlplus>--	Problem 1b
sqlplus>
sqlplus>ALTER TABLE dept
  2  	     modify(
  3  		     dname constraint dname_uq unique
  4  					     deferrable initially immediate
  5  		     constraint dname_nn not null
  6  					     deferrable initially immediate);

Table altered.

sqlplus>
sqlplus>--	Problem 2
sqlplus>
sqlplus>alter table emp
  2  	     modify (
  3  -- 	     a
  4  		     deptno constraint dept_pk primary key
  5  					     deferrable initially immediate,
  6  -- 	     b
  7  		     ename constraint ename_uq unique deferrable initially immediate
  8  			  constraint ename_nn not null deferrable initially immediate,
  9  -- 	     c
 10  		      mgr constraint mgr_fk references emp(empno)
 11  					     deferrable initially immediate,
 12  -- 	     d
 13  		     deptno constraint deptno_fk references dept(deptno) deferrable
 14  							     initially immediate,
 15  -- 	     e
 16  		     sal constraint sal_chk check (sal between 500 and 10000)
 17  						     deferrable initially immediate
 18  );
		deptno constraint deptno_fk references dept(deptno) deferrable
		*
ERROR at line 13:
ORA-00957: duplicate column name


sqlplus>
sqlplus>--	Problem 3
sqlplus>
sqlplus>alter table s
  2  	     modify (
  3  -- 	     a
  4  		     s# constraint s#_pk primary key
  5  					     deferrable initially immediate,
  6  -- 	     b
  7  		     sname constraint sname_uq unique deferrable initially immediate
  8  			  constraint sname_nn not null deferrable initially immediate
  9  );

Table altered.

sqlplus>
sqlplus>--	Problem 4
sqlplus>
sqlplus>alter table p
  2  	     modify(
  3  -- 	     a
  4  		     p# constraint p#_pk primary key
  5  					     deferrable initially immediate,
  6  -- 	     b
  7  		     pname constraint pname_uq unique deferrable initially immediate
  8  			  constraint pname_nn not null deferrable initially immediate
  9  );

Table altered.

sqlplus>
sqlplus>--	Problem 5
sqlplus>
sqlplus>--		a
sqlplus>alter table sp
  2  	     add constraint sp_pk primary key (p#, s#);

Table altered.

sqlplus>alter table sp
  2  	     modify(
  3  -- 	     b
  4  		     qty constraint qty_check check (qty >= 0) deferrable initially
  5  								     immediate,
  6  -- 	     c
  7  		     s# constraint s#_fk references s(s#) deferrable initially
  8  								     immediate,
  9  		     p# constraint p#_fk references p(p#) deferrable initially
 10  								     immediate
 11  );

Table altered.

sqlplus>
sqlplus>--	Problem 6
sqlplus>
sqlplus>create index emp_deptno on emp(deptno);

Index created.

sqlplus>
sqlplus>--	Problem 7
sqlplus>
sqlplus>
sqlplus>
sqlplus>--	Problem 8
sqlplus>
sqlplus>select index_name,
  2  	     table_name
  3  from user_indexes
  4  ;
INDEX_NAME                     TABLE_NAME
------------------------------ ------------------------------
SP_PK                          SP
S#_PK                          S
SNAME_UQ                       S
PNAME_UQ                       P
P#_PK                          P
EMP_DEPTNO                     EMP
DEPT_PK                        DEPT
DNAME_UQ                       DEPT

8 rows selected.

sqlplus>
sqlplus>--	Problem 9
sqlplus>
sqlplus>select constraint_name,
  2  	     table_name
  3  from user_constraints
  4  ;
CONSTRAINT_NAME                TABLE_NAME
------------------------------ ------------------------------
QTY_CHECK                      SP
SNAME_NN                       S
PNAME_NN                       P
DNAME_NN                       DEPT
S#_FK                          SP
P#_FK                          SP
DEPT_PK                        DEPT
DNAME_UQ                       DEPT
S#_PK                          S
SNAME_UQ                       S
P#_PK                          P
PNAME_UQ                       P
CONSTRAINT_NAME                TABLE_NAME
------------------------------ ------------------------------
SP_PK                          SP

13 rows selected.

sqlplus>exit
