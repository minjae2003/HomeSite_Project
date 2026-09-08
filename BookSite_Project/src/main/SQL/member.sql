create table member(

id varchar(20) primary key,

passwd varchar(20) not null,

name varchar(20) not null,

reg_date datetime not null

);

 

insert into member

     values ('aaa', 'aaa', 'aname', now());

 

insert into member

     values ('bbb', 'bbb', 'bname', now());

     

insert into member

     values ('ccc', 'ccc', 'cname', now());

     

insert into member

     values ('ddd', 'ddd', 'dname', now());     

 

select * from member;

 