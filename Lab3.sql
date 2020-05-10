create database LAB3_StudentTest character set utf8 collate utf8_general_ci;
use LAB3_StudentTest;

create table Class
(
    ClassID   int primary key not null auto_increment,
    ClassName nvarchar(100)   not null,
    StartDate datetime        not null default current_timestamp,
    Status    bit
);

-- alter table class
-- modify column StartDate datetime default current_timestamp;

create table Student
(
    StudentID   int primary key not null,
    StudentName nvarchar(30)    not null,
    Address     nvarchar(50),
    Phone       varchar(20),
    Status      bit,
    ClassID     int             not null
);

alter table Student
    add foreign key (ClassID) references Class (ClassID);

create table Subject
(
    SubID   int primary key not null auto_increment,
    SubName nvarchar(30)    not null,
    Credit  tinyint         not null default 1 check ( Credit >= 1 ),
    Status  bit                      default 1
);

create table Mark
(
    MarkID    int not null primary key auto_increment,
    SubID     int not null,
    StudentID int not null,
    Mark      float   default 0 check ( Mark between 0 and 100),
    ExamTimes tinyint default 1
);

alter table mark
    add unique (SubID,StudentID);

alter table Mark
    add foreign key (StudentID) references Student (StudentID),
    add foreign key (SubID) references Subject (SubID);

insert into class (classid, classname, startdate, status)
values (1, 'A1', '2008-12-20', 1),
       (2, 'A2', '2008-12-22', 1),
       (3, 'B3', curdate(), 0);

insert into Student (studentid, studentname, address, phone, status, classid)
values (1, 'Hung', 'Ha Noi', '0912113113', 1, 1),
       (2, 'Hoa', 'Hai Phong', '', 1, 1),
       (3, 'Manh', 'HCM', '0123123123', 0, 2);

insert into subject(subid, subname, credit)
values (1, 'CF', 5),
       (2, 'C', 6),
       (3, 'HDJ', 5),
       (4, 'RDBMS', 10);

insert into mark(markid, subid, studentid, Mark, ExamTimes)
values (1, 1, 1, 8, 1),
       (2, 1, 2, 10, 2),
       (3, 2, 1, 12, 1);

select *
from mark;
select *
from class;
select *
from student;
select *
from subject;

alter table class
    modify column StartDate datetime default now();

select current_timestamp;

update class
set StartDate = DATE_FORMAT(StartDate, '%d-%m-%Y');

select DATE_FORMAT(StartDate, '%d/%m/%Y')
from class;

update student
set ClassID = 2
where StudentName = 'Hung';

update student
set Phone = 'No phone'
where Phone = '' or Phone is null;

update class
set ClassName = concat('New ', ClassName)
where Status = 0;

update class
set ClassName = replace(ClassName, 'New ', 'Old ')
where Status = 1 and ClassName like 'New%';

update class
set Status = 0
where ClassID not in (select ClassID from student);

update subject
set Status = 0
where SubID not in (select SubID from mark);

-- 6.Hien thi thong tin
select *
from student
where StudentName like 'h%';

alter table student
    drop foreign key student_ibfk_1;

select *
from (select month(StartDate) as month
      from class) as resultTable
where resultTable.month >= 12;

select max(Credit)
from subject;

select *
from subject
where Credit = (select max(Credit) from subject);

select *
from subject
where Credit between 3 and 5;

select Student.ClassID, ClassName, StudentName, Address
from student, class
where Student.ClassID = Class.ClassID;

select *
from subject
where SubID not in (select SubID from mark);

select *
from subject
where SubID =
      (select SubID from mark
       where Mark =
             (select max(Mark) from mark));


select Student.StudentID, studentName, avg(Mark)
from Student
         left join mark m on Student.StudentID = m.StudentID
group by StudentID;

select Student.StudentID, studentName, avg(Mark) as avgMark
from Student
         left join mark m on Student.StudentID = m.StudentID
group by StudentID
order by avgMark DESC;

select * from
    (select Student.StudentID, studentName, avg(Mark) as avgMark
     from Student
              left join mark m on Student.StudentID = m.StudentID
     group by StudentID) as resultTable
where resultTable.avgMark >=10;


select Student.StudentID, StudentName, Mark
from student
         left join mark m on Student.StudentID = m.StudentID
         left join subject s on m.SubID = s.SubID
order by Mark desc , StudentName;

-- 7.
rename table subjecttest to mark;