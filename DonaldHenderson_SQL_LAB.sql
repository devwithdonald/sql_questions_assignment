-- 2.0 SQL Queries
-- 2.1 SELECT
-- 	Select all records from the Employee table.
select * from employee;

-- 	Select all records from the Employee table where last name is King.
select * from employee
where lastname = 'King';

--	Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee
where firstname = 'Andrew'
and reportsto is null;

-- 2.2 ORDER BY
--	Select all albums in Album table and sort result set in descending order by title.
select * from album
order by title desc;

--  Select first name from Customer and sort result set in ascending order by city
select firstname from customer
order by city asc;

-- 2.3 INSERT INTO
--	Insert two new records into Genre table
insert into genre (genreid, name)
values 
	(26,'Future House'),
	(27,'Disco');

--	Insert two new records into Employee table
insert into employee(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
values
	(9, 'jones', 'mike', 'intern', 6, '1988-04-08 00:00:00', '2003-03-14 00:00:00', '434 north 4 street', 'Jacksonville', 'FL', 'America', '23452', '+1 (432) 489-4294', '+1 (432) 489-4294', 'jonesmikes@gmail.com'),
	(10, 'berry', 'steve', 'intern', 6, '1990-05-03 00:00:00', '2003-03-14 00:00:00', '3567 stevens st', 'Tampa', 'FL', 'America', '57743', '+1 (554) 665-4654', '+1 (554) 665-4654', 'thebarrinator@gmail.com');

-- Insert two new records into Customer table
insert into customer(customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid)
values	
	(60, 'rodry', 'hector', null, '29 twenty nine street', 'victorville', 'CA','United States', '380', '393-489-3849', null, 'ohhhec@gmail.com', 4),
	(61, 'kit', 'doug', null, '394 bud street',	'los angeles', 'CA', 'United States' ,'122', '843-483-3848', null, 'dougitup@hotmail.com', 5);

-- 2.4 UPDATE
--	Update Aaron Mitchell in Customer table to Robert Walter
update customer
set firstname = 'Robert', lastname = 'Walter'
where firstname = 'Aaron' AND lastname = 'Mitchell';

--	Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
update artist
set name = 'CCR'
where name = 'Creedence Clearwater Revival';

-- 2.5 LIKE
--	Select all invoices with a billing address like “T%”
select * from invoice
where billingaddress like 'T%';

-- 2.6 BETWEEN
--	Select all invoices that have a total between 15 and 50
select * from invoice
where total between 15 and 30;

--	Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee
where hiredate between '2003-06-01' and '2004-03-01';

-- 2.7 DELETE
--	Delete a record in Customer table where the name is Robert Walter.
delete from invoiceline
where invoiceid = 290;

delete from invoiceline
where invoiceid = 50;

delete from invoiceline
where invoiceid = 268;

delete from invoiceline
where invoiceid = 342;

delete from invoiceline
where invoiceid = 116;

delete from invoiceline
where invoiceid = 245;

delete from invoiceline
where invoiceid = 61;

delete from invoice 
where customerid = 32;

delete from customer
where firstname = 'Robert' and lastname = 'Walter';

-- 3.0 SQL FUNCTIONS
-- 3.1 System Defined Functions
--	Create a function that returns the current time. 
select now();

--	ceate a function that returns the length of a mediatype from the mediatype table
select length(name) from mediatype
where mediatypeid = 5;

-- 3.2 System Defined Aggregate Functions
--	Create a function that returns the average total of all invoices
select avg(total) as "Average Total of All Invoices" from invoice;

--	Create a function that returns the most expensive track
select  max(unitprice) as "Most Expensive Track" from track;

-- 3.3 User Defined Scalar Functions
-- 	Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION avg_invoice_function()
 RETURNS TABLE(invoice_id integer, unitprice_average numeric)
 LANGUAGE plpgsql
AS $function$
begin
		return query select invoiceid, avg(unitprice)
		from invoiceline
		group by invoiceid
		order by invoiceid asc;
end; 
$function$
;

-- 3.4 User Defined Table Valued Functions
--	Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION bornafter1968()
 RETURNS TABLE(first_name varchar, last_name varchar, birth_date timestamp)
 LANGUAGE plpgsql
AS $function$
begin
	return query select 
	  firstname, lastname, birthdate
	from 
	  employee
	where 
	  birthdate > '1968-01-01 00:00:00';
end; $function$
;

-- 4.0 Stored Procedures
-- 4.1 Basic Stored Procedures
--	Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION get_names_proc(INOUT curs refcursor)
 LANGUAGE plpgsql
AS $function$
begin
	open curs for select firstname, lastname
	from employee;
end; $function$
;

-- 4.2 Store Procedue Input Parameters
--	Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION update_employee_proc(integer, varchar, varchar, varchar, integer, timestamp, timestamp, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
	update employee
	set lastname = $2, firstname = $3, title = $4, reportsto = $5, birthdate = $6, hiredate = $7, address = $8, city = $9, state = $10, country = $11, postalcode = $12, phone = $13, fax = $14, email = $15
	where employeeid = $1;
end; $function$
;

--	Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION get_manager_proc(IN emp_id integer, OUT manager_name varchar)
 LANGUAGE plpgsql
AS $function$
begin
    select firstname || ' ' || lastname into manager_name from employee where employeeid = 
	    (select reportsto from employee where employeeid = $1);
end; $function$
;


-- 4.3 Stored Procedure Output Parameters
--	Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION get_name_and_company_proc(IN cust_id integer, OUT cust_name varchar, OUT cust_company varchar)
 LANGUAGE plpgsql
AS $function$
begin
	select firstname || ' ' || lastname, company into cust_name, cust_company
	from customer
	where customerId = $1;
end;
$function$
;



-- 5.0 Transactions 
-- 	Create a transaction that given a invoiceId will delete that invoice
alter table invoiceline drop constraint fk_invoicelineinvoiceid;

CREATE OR REPLACE FUNCTION delete_invoice(integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
	delete from invoice
	where invoiceid = $1;
end;
$function$
;

--	Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION insert_employee_proc(integer, varchar, varchar, varchar, integer, timestamp, timestamp, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
	insert into employee(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
	values
		($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15);
	commit; 
end; $function$
;

-- 6.0 Triggers
-- 6.1 AFTER/FOR
--	Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE OR REPLACE FUNCTION delete_after_employee()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	if (TG_OP = 'DELETE') then
		insert into employee(employeeid,lastname,firstname)
			values((select nextval('employee_id_sequence'), 'last','first'));
	end if;
	return new;
end; $function$
;

create trigger after_employee_insert 
after insert on employee 
for each row 
execute procedure insert_into_employee();

--	Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE OR REPLACE FUNCTION update_after_album()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	if (TG_OP = 'INSERT') then
		update album
		set title = 'new'
		where albumid = new.albumid;
	end if;
	return new;
end; $function$
;

ccreate trigger after_update 
after update on album 
for each row 
execute procedure update_after_album();

--	Create an after delete trigger on the customer table that fires after a row is deleted from the table.
create sequence customer_postal_sequence start 70;

create or replace function delete_after_customer()
returns trigger as $$
begin
	if (TG_OP = 'DELETE') then
		update customer
		set postalcode = (select nextval('customer_postal_sequence'))
		where customerid = 6;
	end if;
	return new;
end; $$ language plpgsql;


create trigger after_delete 
	after delete on customer
	for each row
	execute procedure delete_after_customer();

-- 7.0 JOINS
-- 7.1 INNER
--	Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
select 
	cust.firstname firstname,
	cust.lastname lastname,
	inv.invoiceid invoiceid
from 
	customer cust
inner join invoice inv on cust.customerid = inv.invoiceid;

--7.2 OUTER
--	Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
select 
	cust.customerid customerid,
	cust.firstname firstname,
	cust.lastname lastname,
	inv.invoiceid invoiceid,
	inv.total total
from 
	customer cust
full outer join invoice inv on cust.customerid = inv.invoiceid;

-- 7.3 RIGHT
--	Create a right join that joins album and artist specifying artist name and title.
select 
	art.name artist_name,
	alb.title title
from 
	artist art
right join album alb on art.artistid = alb.artistid;

-- 7.4 CROSS
--	Create a cross join that joins album and artist and sorts by artist name in ascending order.
select *
from album
cross join artist
order by artist.name asc;

-- 7.5 SELF
--	Perform a self-join on the employee table, joining on the reportsto column.
select 
	e.firstname || ' ' || e.lastname employee,
	m.firstname || ' ' || m.lastname manager
from
	employee e 
inner join employee m on m.employeeid = e.reportsto;
