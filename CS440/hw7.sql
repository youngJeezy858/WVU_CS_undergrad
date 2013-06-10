/*
	Kyle Frank
	CS 440
	Assignment 7
	March 15, 2013
*/

/*
1.	We wish that commissions provided to employees (by updates or insertions into the emp table) are also entered into 
	the bonus table.  The employee information is added to Bonus, unless it already is present, at which time only the 
	commission column is updated.  However, the company has a peculiar rule that commissions granted outside of working 
	hours (8AM to 5PM) are NOT reflected in the Bonus table.  Write a trigger to implement this policy.
*/

create or replace trigger update_comm
after update or insert of comm on emp
for each row
declare
	cur_time number;
	emp_in_bonus number;
begin
	emp_in_bonus := 0;
	select to_number(to_char(sysdate, 'HH24.mi')) into cur_time from dual;
	select count(ename) into emp_in_bonus from bonus where :new.ename = bonus.ename;
	if cur_time < 8 OR cur_time > 17 then
		dbms_output.put_line('Commision not added to bonus: not currently business hours.');
	elsif emp_in_bonus = 0 then
		insert into bonus values (:new.ename, :new.job, :new.sal, :new.comm);
	else
		update bonus set comm = :new.comm where ename = :new.ename;
	end if;
end;
/

/*
2.	In an effort to reduce long-term debt, our company has decided to cap salary increases. Any salary increase 
	over the cap is to be regarded as a commission and hence the company does not incur additional long-term salary commitment.

	The salary caps are based on job classification; the caps are:

		Analyst		$4,000	
		Clerk			$1,500
		Manager		$3,500
		Salesman		$2,000

	There is no cap for the president.

	The first business rule to be instituted is that any salary modification that exceeds the cap, 
	the difference between the new salary and the cap is to be regarded as a commission and added to the current commission.

	A second business rule that will be instituted will prevent the circumvention of the salary cap. 
	Employees may not change jobs and thereby obtain a new position with a higher salary than allowed at 
	their previous position (we’re a tough 	company!)  This only applies when the employee's new job is different than 
	their old job AND their new salary exceeds  what they could have made at their old job.

	Write a single trigger that will accomplish these two business rules. One method for creating user-defined 
	errors is to call the procedure raise_application_error with parameters: error_number and message where error 
	numbers in the range from –20000 to –20999 are reserved for user defined errors. For example:

		raise_application_error(-20101, 'Salary is missing'); 

	If an attempt to change jobs is encountered, cause the error with error number 
	–20100 to occur with error message ‘Job modification not permitted.’  (NOTE: RAISING AN EXCEPTION AND HANDLING AN 
	EXCEPTION ARE NOT THE SAME.  YOUR TRIGGER SHOULD RAISE AN EXCEPTION ONLY.)
*/

create or replace trigger sal_cap
before update of sal, job on emp
for each row
declare
	job  varchar2(9);
	sal_lim  number;
	add_comm  number;
begin
	job := upper(:old.job);
	if job = 'ANALYST' then
		sal_lim := 4000;
	elsif job = 'CLERK' then
		sal_lim := 1500;
	elsif job = 'MANAGER' then
		sal_lim := 3500;
	elsif job = 'SALESMAN' then
		sal_lim := 2000;
	else
		sal_lim := 0;
	end if;

	if job != upper(:new.job) and :new.sal > sal_lim then
		raise_application_error(-20100, 'Job modification not permitted.');
	elsif sal_lim != 0 and :new.sal > sal_lim then
		add_comm := :new.sal - sal_lim;
		:new.sal := sal_lim;
		:new.comm := add_comm;
	end if;
end;
/

/*
3.	Write a before row trigger on the p table that implements the business rule that if a part's weight in an insert 
	or update exceeds 10 units, the color of the part must be RED to flag it as a "heavy" item.  This should only be 
	applied to changes and additions: this does NOT apply to parts and weights currently in the database.

4.	Write an after row trigger on the p table that implements the business rule that if a part's weight in an insert 
	or update is less than 8 units, the color of the part must be BLUE to flag it as a "light" item. This should only
	 be applied to changes 	and additions: this does NOT apply to parts and weights currently in the database.
*/

create or replace package weight_pkg as
	type ridArray is table of char(2) index by binary_integer;
	new_rows ridArray;
	empty ridArray;
end;
/ 

create or replace trigger p_weight
for update or insert of weight on p
COMPOUND TRIGGER
	t_weight number;
BEFORE EACH ROW IS
begin
	weight_pkg.new_rows := weight_pkg.empty;
	if :new.weight > 10 then
		:new.color := 'red';
	end if;
end before each row;

AFTER EACH ROW IS
begin
	weight_pkg.new_rows(weight_pkg.new_rows.count+1) := :new.p#;	
end after each row;

AFTER STATEMENT IS
begin
	for i in 1 .. weight_pkg.new_rows.count loop
                select weight into t_weight from p where p# = weight_pkg.new_rows(i);
                if t_weight < 8 then
                        update p set color = 'blue' where p# = weight_pkg.new_rows(i);
                end if;
        end loop;
end after statement;
end;
/
	
