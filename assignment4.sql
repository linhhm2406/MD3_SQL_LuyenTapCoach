create database assignment4_bookStore;
use assignment4_bookStore;

create table Students
(
    studentID int primary key,
    Name      VarChar(50),
    Age       tinyint,
    Gender    bit
);

insert into Students
values (1, 'Nguyen Thi Huyen', 19, 0),
       (2, 'Mai Thanh Minh', 33, 1),
       (3, 'Dao Thien Hai', 26, 1),
       (4, 'Trinh Chan Tran', 24, 0),
       (5, 'Diem Diem Quynh', 30, Null);

create table Books
(
    BookID    int primary key,
    Name      Varchar(50) not null,
    TotalPage int,
    Type      Varchar(10),
    Quantity  int
);

insert into Books
values (1, 'Word', 50, Null, 10),
       (2, 'Excel', 60, Null, 20),
       (3, 'Access', 71, Null, 7),
       (4, 'LGC', 42, Null, 1),
       (5, 'HTML', 71, Null, 2);

create table Borrows
(
    BorrowID   int primary key,
    StudentID  int,
    BookID     int,
    BorrowDate datetime
);

alter table Borrows
    add foreign key (StudentID) references Students (studentID),
    add foreign key (BookID) references Books (BookID);

insert into Borrows
values (1, 1, 1, '2004-10-29'),
       (2, 4, 4, '2004-10-26');

create table DropOuts
(
    DrpID     int primary key auto_increment,
    StudentID int,
    Date      datetime
);

alter table DropOuts
    add foreign key (StudentID) references Students (studentID);

-- View all
create view viewAll as
select BorrowID,
       Borrows.StudentID,
       s.Name as StudentName,
       Age,
       Gender,
       b.BookID,
       b.Name as BookName,
       TotalPage,
       Type,
       Quantity,
       BorrowDate
from Borrows
         join students s on Borrows.StudentID = s.studentID
         join Books B on Borrows.BookID = B.BookID;

# 2 Display the Books that have TotalPage more than 50, this list must order by
# TotalPage and then Name as following:
select BookID, Name, TotalPage, Type, Quantity
from Books
where TotalPage > 50;

# 3.Insert appropriate data to Borrows to represent following information:
# a. One Access book was borrowed by Trinh Chan Tran on 10/30/04.
# b. One HTML book was borrowed by Mai Thanh Minh on 10/31/04
# c. 2 Word books were borrowed by Trinh Chan Tran on today (Hint: use
# GetDate())

insert into borrows
values (3, 4, 3, '2004-10-30'),
       (4, 2, 5, '2004-10-31'),
       (5, 4, 1, curdate()),
       (6, 4, 1, curdate());

# 4.Display book names were borrowed and borrower name as following:
select StudentName, BookName
from viewAll;

# 5.Display all student names and total books were borrowed by them as following
select resultTable.StudentName,
       (IF(resultTable.BorrowID is null, 0, resultTable.BorrowID)) as SoLuong
from (select Name as StudentName, BorrowID
      from borrows
               right join students s on Borrows.StudentID = s.studentID
      group by Name) as resultTable
order by SoLuong;

#6. Display name of the students that are null in gender column.
select Name
from students
where Gender is Null;

#7.Display Name of the best borrowed book (the book that its total borrower is
# highest) and total borrower of this book as following
select BookName, count(BookName) as TotalBorrower
from viewAll
group by BookName
order by TotalBorrower desc
limit 1;

#8. Display number of total available books on BookStore
# (Hint: Total available=Total Books – Total Borrowed Books)
select *
from viewAll;

set @TotalBook = (SELECT sum(Quantity)
                  from viewAll);
set @TotalBorrowedBook = (select count(*)
                          from borrows);

select round(@TotalBook, 0)                        as 'Total in Store',
       round(@TotalBorrowedBook, 0)                as 'Total Borrowed',
       round((@TotalBook - @TotalBorrowedBook), 0) as 'Total Avaiable';

# 9. Create a view named ‘vwBookList’ that list all information of Books table as following:

create view vwBookList as
select Name as BookName,
       TotalPage,
       case
           when TotalPage > 70 then 'Thick'
           when TotalPage > 49 then 'Normal'
                    else 'Thin'
           end,
       Quantity
from books;


# 10.Modify the view named ‘vwBookList‘ such that you can create an index on it.
drop view vwBookList;

create view vwBookList as
select BookID,Name as BookName,
       TotalPage,
       case
           when TotalPage > 70 then 'Thick'
           when TotalPage > 49 then 'Normal'
           else 'Thin'
           end,
       Quantity
from books;

# 11. Create an index named ‘indBookName’ on the [Book Name] and Type column of the ‘vwBookList’ view.
alter table books
add index indBookName (BookID,Type);

#12 .Create an Insert Trigger named ‘tgNoInsertBook’ on the Borrows table. This
# trigger must check data inserting, if number of borrower greater than book’
# quantity it will be rollback and display a message “Out of stock”

