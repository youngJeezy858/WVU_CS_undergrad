/*
	Kyle Frank
	CS440
	Assignment 4
	February 11, 2013
*/

--1. Find the names of all companies who are collaborators with a company that has a ceo named
--Gabriel.

SELECT name FROM Company join Collaborators on ID = C1
WHERE C2 IN
(SELECT ID FROM Company WHERE upper(ceo) = 'GABRIEL');

--2. For each company that supplies to a company two or more levels of complexity lower than their
--own, list the name and fields of both the supplier and the purchaser.

SELECT name, field, (Select name FROM Company WHERE ID = Purchaser) "pName",  (Select field FROM Company WHERE ID = Purchaser) "pField"
FROM Company join Suppliers on ID = Supplier 
join Complexity using (field)
WHERE rank-2 >= (select rank from Company join Complexity using (field) where ID = Purchaser);

--3. For each pair of companies that collaborate, list the names of both companies and both of their
--respective fields. List each pair only once with the pair alphabetical by name. Also the list
--should be alphabetized by the first name and then by the second.

SELECT a.name, a.field, b.name, b.field FROM Company a
join Collaborators on a.ID = C1 join Company b on b.ID = C2 
WHERE a.name < b.name ORDER BY a.name, b.name;

--4. Find all companies who do not appear in the Suppliers table (as a company who supplies or
--purchases) and return their names and fields. Sort by field, then by name within each field.

SELECT name, field FROM Company
minus SELECT name, field FROM Company join Suppliers on ID = Supplier
minus SELECT name, field FROM Company join Suppliers on ID = Purchaser ORDER BY field, name;
 
--5. For every situation where company A supplies company B, but we have no information about
--whom B supplies (that is, B does not appear as an Supplier in the Supplies table), return A and
--B's names and fields.

SELECT a.name, a.field, b.name, b.field FROM Company a
join Suppliers ON a.ID = Supplier join Company b ON b.ID = Purchaser
WHERE b.ID NOT IN (SELECT Supplier from Suppliers);

--6. Find names and fields of companies who only collaborate with companies in the same field.
--Return the result sorted by field, then by name within each field.

SELECT aname, afield, bname, bfield FROM (
SELECT c.name as aname, c.field as afield, d.name as bname, d.field as bfield FROM Company c
join Collaborators ON c.ID = C1 JOIN Company d ON d.ID = C2
WHERE c.field = d.field AND c.name < d.name
MINUS
SELECT a.name, a.field, b.name, b.field FROM Company a
join Collaborators ON a.ID = C1 join Company b ON b.ID = C2
WHERE a.field != b.field AND a.name < b.name 
) ORDER BY afield, aname, bname;

--7. For each company A who supplies a company B where the two do not collaborate, find if they
--have a collaborator C in common (who can introduce them!). For all such trios, return the name
--of A, B, and C.

SELECT a.name, b.name, (SELECT name FROM Company WHERE ID =c.C1)
FROM Company a join Suppliers ON a.ID = Supplier
join Company b ON b.ID = Purchaser join Collaborators c on c.C2 = a.ID
WHERE a.ID NOT IN (SELECT C1 FROM Collaborators WHERE C2 = b.ID) AND
b.ID IN (SELECT C1 FROM Collaborators WHERE C2 = c.C1);

--8. Find the difference between the number of companies in the holler and the number of different
--ceo names.
 
SELECT count(ID)-count(distinct ceo) "diff" FROM Company;
 
--9. Find the name and field of all companies who are buy from more than one supplier.

SELECT name, field FROM Company 
WHERE (SELECT count(Purchaser) FROM Suppliers WHERE Purchaser = ID) > 1;

--10. Find the name and field of the company(s) with the most collaborators.

SELECT name, field FROM Company
WHERE (SELECT count(C1) FROM Collaborators WHERE ID = C1 GROUP BY C1) =
(SELECT max(count(C1)) FROM Collaborators GROUP BY C1);