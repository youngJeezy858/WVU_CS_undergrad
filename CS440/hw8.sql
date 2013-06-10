v/*
	Kyle Frank (kfrank)
	CS440
	Assignment 8
	April 5, 2013

For this assignment, you will use the script “dramaqueens.sql” to create tables
and populate the database (present in /cloudproject/2013springcs440).  Please 
study the script to get a complete understanding of the tables and their 
relationships.  Please note that the database includes a number of WVU students, 
their CRN, and their current grade in school.  There are also Friend and Likes 
tables.  Friends are mutual, so that if (123, 456) is in the Friend table, so is 
(456, 123).   Likes is not necessarily mutual, as the penalty of love is that it 
may not be reciprocated.

1. Create a PLSQL function called Likers that, receiving a CRN as a parameter, 
will return a varying array of the student names of all students that like the 
student represented by the parameter.  Note that you will be responsible for 
creating an appropriate varying array for this purpose.  If no one likes the 
student, the function should return null.
*/

create or replace type likeArray is VARRAY(20) of varchar2(20)
/
create or replace function Likers (CRN_in in number)
return likeArray is
	l_varray likeArray := likeArray();
	cursor c_CRN is select name from WVU where CRN in 
	(select CRN2 from Likes where CRN_in=CRN);
begin
	for x in c_CRN loop
		l_varray(l_varray.count +1) := x.name;
	end loop;
	return l_varray;
end;
/

/*
2. Create a PLSQL procedure called Hermitify received a CRN as a parameter and 
removes all Friend/Likes references to that individual.
*/

create or replace procedure Hermitify (CRN_in in number)
is
begin
	delete from Friend where CRN_in=CRN1 or CRN_in=CRN2;
	delete from Likes where CRN_in=CRN1 or CRN_in=CRN2;
end;
/

/*
3. Create a trigger so that new students like all students in their grade.
*/

create or replace package stu_CRN as
	type a_CRN is table of number index by binary_integer;
	new_rows a_CRN;
	empty a_CRN;
end;
/

create or replace trigger new_stu_likes
for insert on WVU
COMPOUND TRIGGER
cursor c_CRN is select CRN from WVU;
BEFORE EACH ROW IS
begin
	stu_CRN.new_rows := stu_CRN.empty;
end before each row;

AFTER EACH ROW IS
begin
	stu_CRN.new_rows(stu_CRN.new_rows.count+1) := :new.CRN;
end after each row;

AFTER STATEMENT IS
begin
for i in 1 .. stu_CRN.new_rows.count loop
	for x in c_CRN loop
		if stu_CRN.new_rows(i) != x.CRN then
			insert into Likes values (stu_CRN.new_rows(i), x.CRN);
		end if;
	end loop;
end loop;
end after statement;
end;
/

/*
4. Create a trigger so that new students who either have a null grade or no grade 
specified are automatically listed as Freshmen.
*/

create or replace trigger new_stu_grade
before insert on WVU
for each row
begin
	if :new.grade is NULL then
		:new.grade := 'FR';
	end if;
end;
/

/*
5. Create a trigger so that symmetry is maintained in the Friend table (so if A 
is a friend of B, B must also be a friend of A).
*/

create or replace package recurse_flag as
	rec number :=1;
end;
/

create or replace trigger friend_symmetry
for insert or delete or update on Friend
COMPOUND TRIGGER
	is_present number;
	cursor c_friend is select CRN1 from friend where
	:new.CRN2=CRN1 and :new.CRN1=CRN2;
before each row is
begin
	stu_crn.new_rows := stu_crn.empty;
	if INSERTING or UPDATING then
		open c_friend;
		fetch c_friend into is_present;
		if c_friend%notfound and recurse_flag.rec=1 then
			recurse_flag.rec :=0;
			insert into Friend values (:new.CRN2, :new.CRN1);
		end if;
		recurse_flag.rec := 1;
	end if;
end before each row;

after each row is
begin
	stu_crn.new_rows(1) := :new.Crn1;
	stu_crn.new_rows(2) := :new.Crn2;
end after each row;

after statement is
begin
	if DELETING and recurse_flag.rec=1 then
                recurse_flag.rec :=0;
                delete from Friend where CRN1=stu_crn.new_rows(2) and CRN2=stu_crn.new_rows(1);
                recurse_flag.rec :=1;
	end if;
end after statement;
end;
/

/*
6. Create a trigger so that if a student is advanced one year (say from Freshman 
to Sophomore) then so are all of his friends.
*/

create or replace trigger friend_advance
for update of grade on wvu
COMPOUND TRIGGER
	cursor c_friend is select CRN2, grade from Friend join WVU on WVU.CRN=Friend.CRN1
	where WVU.CRN=:new.CRN;
after statement is
begin
	if recurse_flag.rec=1 then
		recurse_flag.rec := 0;
		for c in c_friend loop
			dbms_output.put_line('fuuuuuck');
			update WVU set grade=(select grade from year where position=((select position from year where grade=c.grade)+1)) where c.crn2=crn;
		end loop;
	end if;
	recurse_flag.rec := 1;
end after statement;
end;
/

/*
7. Create a trigger so that if a student is advanced to graduate student, the student 
is automatically deleted from the database.
*/

create or replace trigger delete_grad
for update of grade on WVU
COMPOUND TRIGGER
	stu_grade char(2);
before each row is
begin
	stu_CRN.new_rows := stu_CRN.empty;
end before each row;

after each row is
begin
	if :new.grade='GR' then
		stu_CRN.new_rows(stu_CRN.new_rows.count+1) := :new.CRN;
	end if;
end after each row;

After statement is
begin
	for i in 1 .. stu_CRN.new_rows.count loop
		Hermitify(stu_CRN.new_rows(i));
		delete from WVU where CRN=stu_CRN.new_rows(i);
	end loop;
end after statement;
end;
/

/*
8. Write a trigger to enforce the following behavior: If A liked B but is updated 
to A liking C instead, and B and C were friends, make B and C no longer friends.
*/

create or replace trigger you_bitch
before update of CRN2 on Likes
for each row
begin	
	delete Friend where CRN1=:old.CRN2 and CRN2=:new.CRN2 or CRN1=:new.CRN2 and CRN2=:old.CRN2;
end;
/

/*
Submission should include your myID and all queries along with evidence that they 
compiled. All functions, procedures, and triggers should be installed in your database 
and functioning for testing.  Be sure that the original data is present in all tables. 
Also, be sure your triggers all work together!
*/