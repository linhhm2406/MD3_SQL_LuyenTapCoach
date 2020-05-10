create database assignment3_productManagement;
use assignment3_productManagement;

create table Customers
(
    CustomerID int primary key,
    Name       nvarchar(50) unique
);
insert into Customers
values (1, 'John Nguyen'),
       (2, 'Bin Laden'),
       (3, 'Bill Clinton'),
       (4, 'Thomas Hardy'),
       (5, 'Ana Tran'),
       (6, 'Bob Car');

create table Orders
(
    OrderID       int primary key,
    CustomerID    int,
    ProductName   nvarchar(50),
    DateProcessed datetime check (DateProcessed between '1970-01-01' and '2015-01-1')
);

alter table Orders
    add foreign key (CustomerID) references Customers (Customerid);

insert into Orders
values (1, 2, 'Nuclear Bomb', '2002-12-01'),
       (2, 3, 'Missile', '2000-03-02'),
       (3, 2, 'Jet-1080', '2004-08-03'),
       (4, 1, 'Beers', '2001-05-12'),
       (5, 4, 'Asian Food', '2002-10-04'),
       (6, 6, 'Wine', '2002-03-08'),
       (7, 5, 'Milk', '2002-05-02');

-- 2  Create a new table called “Processed Orders” and populate the new table with the data
-- selecting from Orders table Where DateProcessed is earlier than '2002-10-05'.

create table ProcessOrders
(
    OrderID       int primary key,
    CustomerID    int,
    ProductName   nvarchar(50),
    DateProcessed datetime check (DateProcessed between '1970-01-01' and '2015-01-1')
);
insert into ProcessOrders(orderid, customerid, productname, dateprocessed)
select *
from Orders
where DateProcessed < '2002-10-05';

alter table processorders
    add foreign key (CustomerID) references customers (customerid);

delimiter //
create procedure showCustomers()
begin
    select * from customers;
end //
delimiter ;

delimiter //
create procedure showOrders()
begin
    select * from orders;
end //
delimiter ;

delimiter //
create procedure showProcessedOrder()
begin
    select * from processorders;
end //
delimiter ;

# 3 Create a view named vw_All_Orders that merges the two data set from Orders and
# ProcessedOrders into one data set. Show all the orders in 2 tables.
create view vw_All_Orders as
select OrderID, orders.CustomerID, Name, ProductName, DateProcessed
from Orders
         join Customers C on Orders.CustomerID = C.CustomerID;

delimiter //
create procedure showViewAllOrder()
begin
    select * from vw_All_Orders;
end //
delimiter ;

# 4.Create a view named vw_Customer_Order that shows all the orders with the following
# colums: OrderID,CustomerName,ProductName,DateProcessed,Status
# Business rules:
# If CustomerName is a null value “New Customer” is returned
# If DateProcessed is later than current date return “Pending”, if DateProcessed is
# ealier return “History” in Status colum.
# Tips:
# a. Using Case When ...Then statement in the view
# b. Using Getdate() function to get the current date time

call showViewAllOrder();

select OrderID,
       (case
            when Name is null or Name = '' then
                'New Customer'
            else Name
           end) as Name
        ,
       ProductName,
       DateProcessed,
       (case
            when DateProcessed > current_date then
                'Pending'
            else 'History'
           end) as Status
from vw_All_Orders;

# 5.Create a stored procedure named sp_Order_by_Date that accepts a date and returns all
# the orders processed on that date.
delimiter //
create procedure sp_Order_by_Date(in inputDate datetime)
begin
    select OrderID, Name as CustomerName, ProductName, DateProcessed
    from vw_All_Orders
    where DateProcessed = inputDate;
end //
delimiter ;

# 6. Create a DELETE trigger named trg_Delete_Order_Audit to audit the deletion of Orders
# table.
# Tips: Create an audit table “aud_Orders” with the same colums as in the Orders table and
# 1 more colum AuditDateTime (which will record the date time of deletion).

create table aud_Orders
(
    OrderID       int primary key,
    CustomerID    int,
    ProductName   nvarchar(50),
    DateProcessed datetime check (DateProcessed between '1970-01-01' and '2015-01-1'),
    AuditDateTime datetime default (curdate())
);
drop trigger trg_Delete_Order_Audit;

delimiter //
create trigger trg_Delete_Order_Audit
    before delete
    on orders
    for each row
begin
    insert into aud_Orders (orderid, customerid, productname, dateprocessed)
    select * from orders
        where OrderID = OLD.OrderID;
end //
delimiter ;