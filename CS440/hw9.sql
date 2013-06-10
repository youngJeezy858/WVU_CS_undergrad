D/*
Whatsamatta University has heavily modified their schema, and their database is open for your 
inspection under user wu.  Tables in the schema include DEPARTMENTS, CLASSES, AND 
STUDENTS.  Using the tables in the wu schema, create a script to create the following 
structure in your database:

1.	Create an object, classes_ty that contains attributes CRN varchar2(5), 
	Department varchar2(8), and CourseTitle varchar2(25).
*/

set serveroutput on;
set echo on;
drop table classes_ot;
drop table student_plus;
drop type classes_ref_ty;
drop type classes_ty;

Create or replace type classes_ty as object (
	CRN 		varchar2(5),
	Department	varchar2(8),
	CourseTitle	varchar2(25)
)
/

/*
2.	Create an object table, classes_ot with a single attribute of 
	type classes_ty.  Define appropriate constraints for this table.
*/

create table classes_ot of classes_ty;

/*
3.	Populate classes_ot, using sql or pl/sql, with all the information in the wu.classes table.
*/

insert into classes_ot select * from wu.classes;

/*
4.	Create a nested table type classes_ref_ty which contains REFS to the classes_ot table.
*/

create or replace type classes_ref_ty as table of ref classes_ty
/

/*
5.	Create a table student_plus, along with appropriate constraints, that contains the 
	following attributes: student# varchar2(11), student_name varchar2(10), major varchar2(8), 
	advisor varchar2(10), and enrolled classes_ref_ty.   
*/

create table student_plus (
       student#		varchar2(11),
       student_name	varchar2(10),
       major		varchar2(8),
       advisor		varchar2(10),
       enrolled		classes_ref_ty,	
       constraint student#_PK primary key(student#)
)		
nested table enrolled store as classes_ref_ty_tab;

/*
6.	Populate student_plus, using sql or pl/sql, directly from (and only from) the 
	wu.students and classes_ot tables.
*/

begin
	insert into student_plus select student_id, name, 
	dept, advisor, classes_ref_ty() from wu.students;
	for k in (select student_id from wu.students) loop
		insert into table(select enrolled from student_plus where student#=k.student_id)
		select ref(c) from classes_ot c where CRN in 
		(select * from table (select classes from wu.students where student_id=k.student_id));
	end loop; 
end;
/

/*
Since you did such a great job with this conversion, you are asked to administer the new database.  
Using ONLY Tables Student_Plus and Classes_OT, perform the following operations with SQL and/or PL/SQL:

7.	List the names of all students who are enrolled in classes with CRN 45673 or CRN 34228.
*/

select distinct student_name from student_plus, table(enrolled) where deref(column_value).crn in ('45673', '34228'); 

/* 
8.	List the course titles of all courses in which student Sherman is enrolled.
*/

select CourseTitle from classes_ot, table(select enrolled from student_plus where upper(student_name)='SHERMAN') 
		where deref(column_value).crn=crn;

/*
9.	List the names of students who are advised by VanScoy.
*/

select student_name from student_plus where upper(advisor)='VANSCOY';

/*
10.	List the number of students who are enrolled in Linear Algebra.
*/

select count(distinct student#) from student_plus, table(enrolled) 
	where upper(deref(column_value).CourseTitle)='LINEAR ALGEBRA';

/*
11.	Modify student Adams major to PHYSICS.
*/

update student_plus set major='PHYSICS' where upper(student_name)='ADAMS';

/*
12.	Write a procedure, AddClass, that is passed a student number and a CRN. 
	The procedure adds the class to the student's classes.
*/

create or replace procedure AddClass(stu_no in varchar2, crn_in in varchar2)
IS
BEGIN
	insert into table(select enrolled from student_plus where student#=stu_no)
	select ref(c) from classes_ot c where CRN=crn_in;
END;
/

/*
13.	Use procedure AddClass to add CRN 31245 to Hood's list of classes.
*/

declare
	hood	varchar2(20);
begin
	select student# into hood from student_plus where upper(student_name)='HOOD';
	AddClass(hood, 31245);
end;
/

/* 
14.	List the CRNs for Hood's classes.
*/

select deref(column_value).CRN from table(select enrolled from student_plus where upper(student_name)='HOOD');

/*
15.	Write a procedure, DeleteClass, that is passed a student number and a CRN. 
	The procedure deletes the specified class from the student's list of classes. 
	If the student is not enrolled in that class, raise the error code 20200 and the message 
	'Student not enrolled in that class'.
*/

create or replace procedure DeleteClass(stu_no in varchar2, crn_in in varchar2)
IS
	cursor c_crn is select deref(column_value).crn x from
                                table(select enrolled from student_plus where student#=stu_no);
BEGIN
	for cur in c_crn loop
		if cur.x = crn_in then
			delete from table(select enrolled from student_plus where student#=stu_no)
			 where deref(column_value).crn=crn_in;
			return;
		end if;
	end loop;
	raise_application_error(-20200, 'Student not enrolled in that class');
END;
/

/*
16.	Remove CRN 34129 from Sherman's list of classes
*/

declare
	sherman		varchar2(20);
begin
	select student# into sherman from student_plus where upper(student_name)='SHERMAN';
	DeleteClass(sherman, 34129);
end;
/

/*.
17.	List the CRNs for Sherman's classes.
*/

select deref(column_value).CRN from table(select enrolled from student_plus where upper(student_name)='SHERMAN');

/*
18.	List the names of students who are not enrolled in any classes.
*/

select student_name from student_plus a where 
	(select count(deref(column_value).crn) from 
	table(select enrolled from student_plus where a.student#=student#)) = 0;

/*
Set server output & echo on, and run your script to do all 18 steps. Spool your output to a file, and submit a printed copy of the output file.
*/