-- 2.0 SQL Queries
-- 2.1 SELECT
select * from employee;

select * from employee
where lastname = 'King';

select * from employee
where firstname = 'Andrew'
and reportsto is null;

-- 2.2 ORDER BY
select * from album
order by title desc;

select firstname from customer
order by city asc;

-- 2.3 INSERT INTO
insert into genre (genreid, name)
values 
	(26,'Future House'),
	(27,'Disco');

insert into employee(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
values
	(9, 'jones', 'mike', 'intern', 6, '1988-04-08 00:00:00', '2003-03-14 00:00:00', '434 north 4 street', 'Jacksonville', 'FL', 'America', '23452', '+1 (432) 489-4294', '+1 (432) 489-4294', 'jonesmikes@gmail.com'),
	(10, 'berry', 'steve', 'intern', 6, '1990-05-03 00:00:00', '2003-03-14 00:00:00', '3567 stevens st', 'Tampa', 'FL', 'America', '57743', '+1 (554) 665-4654', '+1 (554) 665-4654', 'thebarrinator@gmail.com');

insert into customer(customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid)
values	
	(60, 'rodry', 'hector', null, '29 twenty nine street', 'victorville', 'CA','United States', '380', '393-489-3849', null, 'ohhhec@gmail.com', 4),
	(61, 'kit', 'doug', null, '394 bud street',	'los angeles', 'CA', 'United States' ,'122', '843-483-3848', null, 'dougitup@hotmail.com', 5);

-- 2.4 UPDATE
update customer
set firstname = 'Robert', lastname = 'Walter'
where firstname = 'Aaron' AND lastname = 'Mitchell';

update artist
set name = 'CCR'
where name = 'Creedence Clearwater Revival';

-- 2.5 LIKE
select * from invoice
where billingaddress like 'T%';

-- 2.6 BETWEEN
select * from invoice
where total between 15 and 30;

select * from employee
where hiredate between '2003-06-01' and '2004-03-01';

-- 2.7 DELETE
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
select now();

select length(name) from mediatype
where mediatypeid = 5;

-- 3.2 System Defined Aggregate Functions
select avg(total) as "Average Total of All Invoices" from invoice;

select  max(unitprice) as "Most Expensive Track" from track;

-- 3.3 User Defined Scalar Functions
create function avg_invoice() 
returns numeric as $average$
declare 
	average numeric;
begin
	select avg(unitprice) into average from invoiceline;
	return average;
end; 
$average$ language plpgsql;

-- 3.4 User Defined Table Valued Functiuons
create function bornafter1968()
returns table(
	first_name varchar,
	last_name varchar, 
	birth_date timestamp
)
as $$
begin
	return query select 
	  firstname, lastname, birthdate
	from 
	  employee
	where 
	  birthdate > '1968-01-01 00:00:00';
end; $$
language plpgsql;

-- 4.0 Stored Procedures
-- 4.1 Basic Stored Procedures
create function get_names()
returns table(
	first_name varchar,
	last_name varchar
)
language plpgsql
as $$
begin
	return query select firstname, lastname
	from employee;
end;
$$;

-- 4.2 Store Procedue Input Parameters
create function update_employee(int, varchar, varchar, varchar, int, timestamp, timestamp, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar)
returns void
language plpgsql
as $$
begin
	update employee
	set lastname = $2, firstname = $3, title = $4, reportsto = $5, birthdate = $6, hiredate = $7, address = $8, city = $9, state = $10, country = $11, postalcode = $12, phone = $13, fax = $14, email = $15
	where employeeid = $1;
end;
$$;

create function get_manager(int)
returns table (
	first_name varchar,
	last_name varchar
)
language plpgsql
as $$
begin
    return query select firstname, lastname from employee where employeeid = 
	    (select reportsto from employee where employeeid = $1);
end;
$$;


-- 4.3 Stored Procedure Output Parameters
create function get_name_and_company()
returns table (
	first_name varchar,
	last_name varchar,
	company_name varchar
)
as $$
begin
	return query select firstname, lastname, company
	from customer;
end;
$$ language plpgsql;

-- 5.0 Transactions (need first)


create function insert_employee(int, varchar, varchar, varchar, int, timestamp, timestamp, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar)
returns void
language plpgsql
as $$
begin
	insert into employee(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
	values
		($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15);
end;
$$;


-- 6.0 Triggers
-- 6.1 AFTER/FOR





-- 7.0 JOINS
-- 7.1 INNER
select 
	cust.firstname firstname,
	cust.lastname lastname,
	inv.invoiceid invoiceid
from 
	customer cust
inner join invoice inv on cust.customerid = inv.invoiceid;

--7.2 OUTER
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
select 
	art.name artist_name,
	alb.title title
from 
	artist art
right join album alb on art.artistid = alb.artistid;

-- 7.4 CROSS
select *
from album
cross join artist
order by artist.name asc;

-- 7.5 SELF
select 
	e.firstname || ' ' || e.lastname employee,
	m.firstname || ' ' || m.lastname manager
from
	employee e 
inner join employee m on m.employeeid = e.reportsto;
