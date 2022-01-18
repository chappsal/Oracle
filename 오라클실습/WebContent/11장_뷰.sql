--<북스 11장-뷰>
--1. 뷰? 하나 이상의 테이블이나 다른 뷰를 이용하여 생성되는 '가상테이블'
--즉, 실질적으로 데이터를 저장하지 않고 데이터 사전에 뷰를 정의할 때 기술한 '쿼리문만 저장'

--뷰를 정의하기 위해 사용된 테이블 : 기본 테이블
--뷰는 별도의 기억 공간이 존재하지 않기 때문에 뷰에 대한 수정 결과는
--뷰를 정의한 기본 테이블에 적용

--반대로 기본 테이블의 데이터가 변경되면 뷰에 반영

--뷰를 정의한 기본 테이블의 '무결성 제약조건'또한 상속
--뷰의 정의 조회 : user_viewS 데이터 사전 

--뷰는 복잡한 쿼리를 단순화 시킬 수 있음
--뷰는 사용자에게 필요한 정보만 접근하도록 접근 제한할 수 있음


--1.1 뷰 생성
--※ 대괄호[]의 항목은 필요하지 않을 경우 생략 가능
create [or replace] [force | noforce(기본값)]
view 뷰이름 [(컬럼명, 컬럼명1...)] : 기본 테이블의 컬럼명과 다르게 지정할 경우 사용함, ※순서와 개수를 맞춰야 함
as 서브쿼리
[with check option [constraint 제약조건명]]
[with read only]; ==select문만 가능 DML(=데이터 조작어:변경) 불가

----or replace : 해당 구문을 사용하면 뷰를 수정할 때 drop 없이 수정 가능

--FORCE : 뷰를 생성할 때 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않아도 생성 가능
--		     즉, 기본 테이블의 존재 유무에 상관없이 뷰 생성

--NOFORCE : 뷰를 생성할 때 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않으면 생성 불가
--			반드시 기본 테이블이 존재할 경우에만 뷰 생성

--with check option : where절의 조건에 해당하는 데이터만  사장, 변경이 가능

--with read only : select문만 가능, DML(=데이터 조작어:변경 - insert update delete) 불가

--컬럼명을 명시하지 않으면 기본 테이블의 컬럼명을 상속
--<컬럼명 반드시 명시해야 하는 경우>
--[1] 컬럼이 산술식, 함수, 상수에서 파생된 경우
--[2] join 때문에 둘 이상의 컬럼이 같은 이름을 갖는 경우
--[3] 뷰의 컬럼이 파생된 컬럼과 다른 이름을 갖는 경우




--1.2 뷰의종류
--[1]. 단순 뷰 : 하나의 기본 테이블로 생성한 뷰
--			  DML 명령문의 처리 결과는 기본 테이블에 반영
--			    단순 뷰는 단일 테이블에 필요한 컬럼을 나열한 것으로
--			  join, 함수, group by, union 등을 사용하지 않음
--			    단순 뷰는 select + insert, update, delete 자유롭게 사용 가능

--[2] 복합 뷰  : 두 개 이상의 기본 테이블로 상성한 뷰
--			 distinct, 그룹함수, group by, rownum 포함 할 수 없다
--			   복합 뷰는 join, 함수, union 등을 사용하여 뷰를 생성
--			   함수 등을 사용할 경우 '컬럼 별칭' 사용 필수 (ex. as hiredate)
--			   복합 뷰는 select는, 사용 가능하지만 insert, update, delete는 상황에 따라서 가능하지 않을 수도 있다.



--<실습위해 새로운 테이블 2개 생성>
create table emp11
as
select * from employee;

create table dept11
as
select * from department;
--테이블 구조와 데이터만 복사(★단, 제약조건은 복사 안 됨)


--[1] 단순 뷰 (예)
create view v_emp_job(사원번호, 사원명, 부서번호, 담당업무)
as
select eno, ename, dno, job
from emp11
where job like 'SALESMAN';


select * from v_emp_job;


create view v_emp_job2 --서브쿼리(기본테이블)의 컬럼명이 그대로 복사
as
select eno, ename, dno, job
from emp11
where job like 'SALESMAN';


select * from v_emp_job2;


create view v_emp_job2 
as
select eno, ename, dno, job
from emp11
where job like 'MANAGER'; --실패: 같은 이름의 뷰가 존재하므로


--OR REPLACE : 이미 존재하는 뷰는 내용을 새롭게 변경하여 재 생성
--		 	       존재하지 않는 뷰는 뷰를 새롭게 생성

--따라서, create OR REPLACE view 를 사용하여 융통성있게 뷰 생성하는 것을 권장
create OR REPLACE view v_emp_job2 
as
select eno, ename, dno, job
from emp11
where job like 'MANAGER';

select * from v_emp_job2;

--[2] 복합 뷰 (예)
create OR REPLACE view v_emp_dept_complex
as 
select *
from emp11 natural join dept11
order by dno asc;

select * from v_emp_dept_complex;

----양쪽 테이블에 조건에 맞지 않는 row 모두 추가
create OR REPLACE view v_emp_dept_complex
as 
select *
from emp11 full outer join dept11 
using(dno) --중복제거
order by dno asc;

select * from v_emp_dept_complex;



--1.3 뷰의 필요성
--뷰를 사용하는 이유는 '보안'과 '사용의 편의성' 때문
--[1] 보안 : 전체 데이터가 아닌 일부만 접근하도록 뷰를 정의하면
--		       일반 사용자에게 해당 뷰만 접근 가능하도록 허용하여
--		       중요한 데이터가 외부에 공개되는 것을 막을 수 있음

--(ex) 사원 테이블의 급여나 커미션은 개인적인 정보이므로 다른 사원들의 접근 제한

--즉, 뷰는 복잡한 쿼리를 단순화 시킬 수 있다
--   뷰는 사용자에게 필요한 정보만 접근하도록 접근 제한할 수 있다

--(ex) 사원 테이블에서 '급여와 커미션을 제외'한 나머지 컬럼으로 구성된 뷰 생성
select * from emp11;

create OR REPLACE view v_emp_sample
as
select eno, ename, job, manager, hiredate, dno 
from emp11;

select * from v_emp_sample;


--[2] 사용의 편리성 : 정보 접근을 편리하게 하기 위해 뷰를 통해
--				  사용자에게 필요한 정보만 선택적으로 제공
--사원이 속한 부서에 대한 정보를 함께 보려면 사원 테이블과 부서 테이블을 조인해야 함
--하지만 이를 뷰로 정의해두면 뷰를 마치 테이블처럼 사용하여 원하는 정보를 얻을 수 있음

create OR REPLACE view v_emp_dept_complex2
as
select eno, ename, dno, dname, loc --선택적으로
from emp11 natural join dept11
order by dno asc;

select * from v_emp_dept_complex2;
--뷰를 통해 복잡한 조인문을 사용하지 않고 정보를 쉽게 얻을 수 있음
