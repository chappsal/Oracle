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
--			   복합 뷰는 join, 함수, group by, union 등을 사용하여 뷰를 생성
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





--1.4 뷰의 처리과정

select view_name, text
from user_views;

--user_views 데이터 사전에 사용자가 생성한 '모든 뷰에 대한 정의' 저장
--뷰는 select문에 이름을 붙인 것

--[1] 뷰에 질의를 하면 오라클 서버는 user_views에서 뷰를 찾아 서브 쿼리문 실행
--[2] '서브 쿼리문'은 기본 테이블을 통해 실행된다

--뷰는 select문으로 기본 테이블을 조회하고
--DML(insert, update, delete)문으로 기본 테이블 변경 가능
--(단, 그룹 함수를 가상 컬럼으로 갖는 뷰는 DML 사용 불가)

select * from emp11; --기본테이블(★제약조건 복사 안 된 상황)
select * from v_emp_job; --기본 테이블 emp11 

insert into v_emp_job values(8000, '홍길동', 30, 'SALESMAN'); 
--★주의 : 뷰 정의에 포함되지 않은 컬럼 중에 '기본 테이블의 컬럼이 not null 제약조건이 지정되어 있는 경우
--insert 사용 불가


--insert 확인
select * from emp11; --기본테이블(★제약조건은 복사 안 된 상황이라 '중복된 eno 8000이 추가됨')

insert into v_emp_job values(9000, '이길동', 30, 'MANAGER'); --성공했으나 
select * from v_emp_job; --뷰 조회에는 존재하지 않음
--이유: 서브 쿼리문의 where절 job이 'SALESMAN'으로 뷰를 생성했기 때문

select * from emp11; --기본 테이블에는 존재함



--1.5 다양한 뷰
--함수 사용하여 뷰 생성 가능
--★주의 : 그룹 함수는 물리적인 컬럼이 존재하지 않고 결과를 가상 컬럼처럼 사용
--		가상 컬럼은 기본 테이블에서 컬럼명을 상속 받을 수 없기 때문에 반드시 '별칭 사용'
create OR replace view v_emp_salary
as
select dno, sum(salary), avg(salary) --실패 : must name this expression with a column alias
from emp11
group by dno;


create OR replace view v_emp_salary
as
select dno, sum(salary) as "sal_sum", avg(salary) as "sal_avg" --오류 해결 : 별칭 사용 
from emp11
group by dno;


select * from v_emp_salary;


--ex) 그룹 함수를 가상 컬럼으로 갖는 뷰는 DML 사용 불가
insert into v_emp_salary values(50, 2000, 200); --실패


/*
 * < 단순 뷰에서 DML 명령어 사용이 불가능한 경우 >
 * 1. 뷰 정의에 포함되지 않은 컬럼 중에 기본 테이블의 컬럼이 not null 제약조건이 지정되어 있는 경우 insert문 사용 불가
 * 		why? 뷰에 대한 insert문은 기본 테이블의 뷰 정의에 포함되지 않은 컬럼에 null 값을 입력하는 형태가 되기 때문
 * 
 * 2. salary*12와 같이 산술 표현식으로 정의된 가상 컬럼이 뷰에 정의되면 insert나 update가 불가능하다
 * 3. distinct를 포함한 경우에도		 DML 명령 사용이 불가능
 * 4. 그룹 함수나 group by절을 포함한 경우   DML 명령 사용이 불가능
 */


--1.6 뷰 제거
--뷰를 제거한다는 것은 user_views 데이터 사전에서 뷰의 정의 제거
drop view v_emp_salary;

select view_name, text
from user_views
where view_name in ('V_EMP_SALARY'); --결과 없음



--2. 다양한 뷰 옵션

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

--with check option : where절의 조건에 해당하는 데이터만  저장(insert), 변경(update)이 가능

--with read only : select문만 가능, DML(=데이터 조작어:변경 - insert update delete) 불가


--2.1 or replace

--2.2 FORCE
--FORCE 옵션을 사용하면 쿼리문의 테이블, 컬럼, 함수 등이 존재하지 않을 경우(즉, 기본 테이블이 존재x) 
--오류 발생 없이 뷰는 생성되지만 invalid 상태이기 때문에 뷰는 동작하지 않음 
--(즉, user_views 데이터 사전에는 등록되어 있지만 기본테이블이 존재하지 않으므로 실행 안 됨)
--오류가 없으면 정상적으로 뷰가 생성됨

create or replace view v_emp_notable
as
select eno, ename, dno, job
from emp_notable --기본 테이블 (기본값 noforce) 존재x => 오류 해결하려면 force 추가
where job like 'MANAGER';

create or replace force view v_emp_notable
as
select eno, ename, dno, job
from emp_notable 
where job like 'MANAGER';


select view_name, text
from user_views
--where view_name in ('V_EMP_NOTABLE');
where view_name = ('V_EMP_NOTABLE');

select * from v_emp_notable; --실패



--2.3 with check option
--해당 뷰를 통해서 볼 수 있는 범위 내에서만 insert 또는 update 가능

--ex) 담당 업무가 manager인 사원들을 조회하는 뷰 생성
create or replace view v_emp_job_nochk
as
select eno, ename, dno, job
from emp11
where job like 'MANAGER';

select * from v_emp_job_nochk;

insert into v_emp_job_nochk values(9100, '이순신', 30, 'SALESMAN');
select * from v_emp_job_nochk; --뷰에는 없지만
select * from emp11; --기본테이블에는 추가됨 =====> 혼돈 발생
--따라서 미연에 방지하기 위해
--with check option 사용하여 기본 테이블에도 추가될 수 없도록 방지
--즉, with check option으로 뷰를 생성할 때 조건 제시에 사용된 컬럼 값을 변경하지 못하도록 함

create or replace view v_emp_job_chk
as
select eno, ename, dno, job
from emp11
where job like 'MANAGER' with check option;

insert into v_emp_job_chk values(9500, '김유신', 30, 'SALESMAN'); --실패 : 추가 안 됨
--with check option : 조건 제시를 위해 사용한 컬럼 값이 아닌 값에 대해서는 뷰를 통해서 추가/변경하지 못하도록 막음

insert into v_emp_job_chk values(9500, '김유신', 30, 'MANAGER'); --성공 : 추가 됨

--확인해보기
select * from v_emp_job_chk; --뷰에 추가됨
select * from emp11; --기본테이블에도 추가됨




--2.4 with read only : select문만 가능, DML(=데이터 조작어:변경 - insert update delete) 불가

create or replace view v_emp_job_readonly 
as
select eno, ename, dno, job
from emp11
where job like 'MANAGER' with check option;

select * from  v_emp_job_readonly; --조회 가능

insert into v_emp_job_readonly values(9700, '강감찬', 30, 'MANAGER'); --실패 





--혼자해보기----------------------------------------------------------------------------------------------

--1.20번 부서에 소속된 사원의 사원번호,이름,부서번호를 출력하는 select문을
--뷰로 정의(v_em_dno)

create view v_em_dno
as
select eno, ename, dno
from emp11
where dno = 20;


--2.이미 생성된 v_em_dno 뷰에 급여 역시 출력되도록 수정

create or replace view v_em_dno
as
select eno, ename, dno, salary
from emp11
where dno = 20;


--3.뷰 제거

drop view v_em_dno;
