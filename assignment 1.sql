create database Assignment1_MarkManagement;
use assignment1_markmanagement;


create table Student
(
    RN     int primary key,
    Name   nvarchar(50) not null,
    Age    int,
    Gender bit
);

create table subject
(
    sID   int primary key,
    sName nvarchar(50)
);

create table StudentSubject
(
    RN   int  not null,
    sID  int  not null,
    Mark int  not null
        check ( Mark between 0 and 10),
    Date date not null,
    primary key (RN, sID)
);

alter table StudentSubject
    add foreign key (RN) references Student (RN);

-- 2
insert into Student(RN, Name)
values (1, 'Mỹ Linh'),
       (2, 'Đàm Vĩnh Hưng'),
       (3, 'Kim Tủ Long'),
       (4, 'Tài Linh'),
       (5, 'Mỹ Lệ'),
       (6, 'Ngọc Oanh');

insert into subject(sID, sName)
values (1, 'SQL'),
       (2, 'LGC'),
       (3, 'HTML'),
       (4, 'CF');

insert into StudentSubject(rn, sid, mark, date)
values (1, 1, 8, '2005-7-28'),
       (2, 2, 3, '2005-7-29'),
       (3, 3, 9, '2005-7-31'),
       (4, 1, 5, '2005-7-30'),
       (5, 4, 10, '2005-7-19'),
       (6, 1, 9, '2005-7-25');

-- 3
update student
set Gender = 0
where Name in ('Mỹ Linh', 'Tài Linh', 'Mỹ Lệ');

update student
set Gender = 1
where Name = 'Kim Tủ Long';

-- 4
insert into subject
values (5, 'Core Java'),
       (6, 'VB.Net');

-- 5
select *
from subject
where sID not in (select sID from studentsubject group by sID);

-- 6
select sName, max(Mark) as Max_Mark
from subject
         left join studentsubject s on subject.sID = s.sID
group by sName;

-- 7
select *
from (select sName, count(sName) as count
      from subject
               join studentsubject using (sID)
      group by sName) as result
where result.count > 1;

-- 8
drop view StudentInfo;

create view StudentInfo as
select Student.RN,
       s.sID,
       Name,
       Age,
       Gender,
       sName,
       Mark,
       Date
from Student
         inner join studentsubject s on Student.RN = s.RN
         inner join subject s2 on s.sID = s2.sID;

alter table student
    modify column Age varchar(10);

alter table student
    modify column Gender varchar(10);

update StudentInfo
set Age = 'Unknown'
where Age is null;

update StudentInfo
set Gender = 'Male'
where Gender = '1';

update StudentInfo
set Gender = 'Female'
where Gender = '0';

update StudentInfo
set Gender = 'Unknown'
where Gender is null;

-- 9
create unique index idx on studentsubject (RN, sID);

-- 10
drop trigger CasUpdate;

delimiter //
create trigger CasUpdate
    after update
    on subject
    for each row
begin
    update studentsubject
    set sID = NEW.sID
    where sID not in (select sID from subject);
end;
//
delimiter //;

select *
from subject;

select *
from studentsubject;

update subject
set sID = 8
where sName = 'SQL';

-- 11.

delimiter //
create trigger casDel
    after delete
    on student
    for each row
begin
    delete
    from studentsubject
    where RN not in (select RN from student);
end //
delimiter ;

call showAllStudent();
call showAllStudentSubject();

-- 12
delimiter //
create procedure procedureTest(in tenHocVien varchar(50), diem int)
begin
    if (tenHocVien != '*') then
        if (diem > (select max(Mark)
                    from studentsubject
                             join student s on StudentSubject.RN = s.RN
                    where Name = tenHocVien)) then
            delete from student where Name = tenHocVien;
        end if;
    else
        truncate table student;
    end if;
end //
delimiter ;

-- 13
select *
from StudentInfo
order by Name;

-- 14
create table top3
(
    `Rank` int primary key auto_increment,
    RN     int,
    Name   varchar(50),
    Mark   int,
    sName  varchar(50),
    Date   date default (curdate())
);

-- 15
delimiter //
create trigger tgTop3
    after update
    on studentsubject
    for each row
begin
    truncate table top3;
    insert into top3 (RN, Name, Mark, sName)
    select RN, Name, Mark, sName
    from StudentInfo
    order by Mark desc
    limit 3;
end //
delimiter ;

-- 16

select *
from (
         select *, avg(Mark) as avgMark
         from StudentInfo
         where Name not in (select Name from StudentInfo where Mark <= 5)
         group by Name
     ) as resultTable
where resultTable.avgMark >= 8
;

-- 17
select *
from (
         select *, avg(Mark) as avgMark
         from StudentInfo
         group by Name
     ) as resultTable
where resultTable.avgMark >= 5
   or (resultTable.avgMark >= 5
    and resultTable.Name in (select Name
                             from (
                                      select *
                                      from StudentInfo
                                      where Name in (
                                          select Name
                                          from (select Name, count(*) as dem
                                                from StudentInfo
                                                where Mark <= 5
                                                group by Name) as resultTable1
                                          where resultTable1.dem <= 1)) as resultTable2
                             where resultTable2.Mark > 3));

-- 18
drop procedure procedureTest;

delimiter //
create procedure procedureTest(in tenHocVien varchar(50), diem int)
begin
    if (tenHocVien != '*') then
        if (diem > (select max(Mark)
                    from studentsubject
                             join student s on StudentSubject.RN = s.RN
                    where Name = tenHocVien)) then
            delete from student where Name = tenHocVien;
        end if;
    else
        delete from student where Name not in (Select Name from top3);
    end if;
end //
delimiter ;