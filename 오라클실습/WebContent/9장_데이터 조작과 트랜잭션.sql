--북스 9장-데이터 조작과 트랜잭션
--데이터 조작어(DML : Data Manipulation Language)
--1. INSERT : 데이터 입력
--2. UPDATE : 데이터 수정
--3. DELETE : 데이터 삭제
--위 작업 후 반드시 commit;(영구적으로 데이터 저장)

-------------------------------------------------------------------------------------------

--1. INSERT : 테이블에 내용 추가
--문자(char, varchar2)와 날짜(date)는 ''를 사용


--실습위해 기존의 부서테이블의 구조만 복사 (제약조건 복사 안 됨. not null 제약조건만 복사 됨)
create table dept_copy --dno(PK아님 => 같은 dno 여러개 추가 가능)
as
select *
from department --dno(PK = not null + unique)
where 0=1; --조건이 무조건 거짓 => 구조만 복사

--RUN SQL... 창 열어
desc dept_copy; --데이터 구조 확인
insert into dept_copy values(10, 'accounting', '뉴욕');
insert into dept_copy (dno, loc, dname) --3
				values(20, '달라스', 'research'); --3
				
				
commit; --이클립스에서는 자동 commit되어 명령어 실행 안 됨
		--RUN SQL... 또는 SQL Developer에서 실행


--1.1 NULL값을 갖는 ROW(행) 삽입
--문자나 날짜 타입은 null 대신 ''사용 가능
--제약조건이 복사되지 않음. 아래 3개 다 같은 형식임
insert into dept_copy (dno, dname) values(30, 'sales'); --제약조건이 복사되지 않음. null값을 허용하여 loc에 null 저장됨 	
--default '대구' 지정되어 있으면 loc에 '대구; 입력 됨
insert into dept_copy values(40, 'operations', null); 	
insert into dept_copy values(50, 'compution', ''); 	
--commit; 영구적으로 데이터 저장

select * from dept_copy;


--[실습위해 기본 사원테이블 구조만 복사] (제약조건 복사 안 됨. not null 제약조건만 복사 됨)
create table emp_copy
as
select eno, ename, job, hiredate, dno
from employee
where 0=1;

select * from emp_copy;

insert into emp_copy values(7000, '캔디', 'manager', '2021/12/20', 10);
--날짜 기본 형식 : 'YY/MM/DD'
insert into emp_copy values(7010, '톰', 'manager', to_date('2021,06,01','YYYY,MM,DD'), 20);
--sysdate : 시스템으로부터 현재 날짜 데이터를 반환하는 함수(주의: ()없음)
insert into emp_copy values(7020, '제리', 'salesman', sysdate, 30);



--1.2 다른 테이블에서 데이터 복사하기
--INSERT INTO + 다른 테이블의 서브쿼리 결과 데이터 복사
--단, 컬럼수 = 컬럼수


--[실습위해 기본 사원테이블 구조만 복사] (제약조건 복사 안 됨. not null 제약조건만 복사 됨)
drop table dept_copy; --기존 dept_copy 삭제 후


create table dept_copy --테이블 생성
as
select *
from department 
where 0=1;

select * from dept_copy;


--ex) 서브쿼리로 다중 행 입력하기
insert into dept_copy --컬럼수와
select * from department; --컬럼수가 같아야 함 (데이터 타입도)

---------------------------------------------------------------------------

--2. UPDATE : 테이블의 내용 수정
--where절 생략 : 테이블의 모든 행 수정됨

update dept_copy
set dname='programming'
where dno=10;


select * from dept_copy;


--컬럼 값 여러 개를 한 번에 수정하기
update dept_copy
set dname='accounting', loc='서울'
where dno=10;


--update문의 set절에서 서브쿼리를 기술하면 서브쿼리를 수행한 결과로 내용이 변경됨
--즉, 다른 테이블에 저장된 데이터로 해당 컬럼 값 변경 가능

--ex) 10번 부서의 지역명을 20번 부서의 지역으로 변경

--[1] 20번 부서 지역명 구하기
select loc
from dept_copy
where dno=20; --'DALLAS'

--[2]
update dept_copy
set loc=(select loc
 	 	 from dept_copy
	 	 where dno=20)
where dno=10;

select * from dept_copy;


--ex) 10번 부서의 '부서명과 지역명'을 30번 부서의 '부서명과 지역명'으로 변경


--[1] 30번 부서의 '부서명과 지역명'
select dname, loc
from dept_copy
where dno=30;

----------------------

select dname from dept_copy where dno=30;
select loc from dept_copy where dno=30;


--[2]
update dept_copy
set (dname, loc)=(select dname, loc
					from dept_copy
					where dno=30)
where dno=10;
---------------------
update dept_copy
set dname=(select loc from dept_copy where dno=30), 
	loc=(select loc from dept_copy	where dno=30)
where dno=10;

-------------------------------------------------------------------------------------

--3. DELETE : 테이블의 내용 삭제
--where절 생략 : 모든 행 삭제
--commit 전에 되돌릴 수 있음

delete from dept_copy --from 생략 가능
where dno=10;

delete from dept_copy; --모든 행 삭제

select * from dept_copy;


--실습위해 사원 테이블의 구조와 데이터 복사 => 새 테이블 생성 (제약조건 복사 안 됨)

drop table emp_copy;

create table emp_copy
as
select *
from employee;

select * from emp_copy;


--ex) emp_copy 테이블에서 '영업부'(=SALES)에 근무하는 사원 모두 삭제 [과제]

select * from department;

select dno
from department
where dname = 'SALES';

delete from emp_copy
where dno=(select dno
			from department
			where dname = 'SALES')


