create table members(
     id varchar(50) not null primary key,
     passwd varchar(20) not null,
     name varchar(30) not null,
     reg_date datetime not null
)
COLLATE='utf8_general_ci'; 

INSERT INTO members
VALUES ('kingdora@gragon.com', '1234', '김개동', NOW());

INSERT INTO members
VALUES ('hongkd@aaa.com', '1111', '홍길동', NOW());

insert into members

     values ('aaa', 'aaa', 'aname', now());

 

insert into members

     values ('bbb', 'bbb', 'bname', now());

     

insert into members

     values ('ccc', 'ccc', 'cname', now());

     

insert into members

     values ('ddd', 'ddd', 'dname', now());     

 

select * from members;
