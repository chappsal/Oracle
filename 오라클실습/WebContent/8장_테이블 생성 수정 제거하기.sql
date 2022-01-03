--북스-8장-테이블 생성 수정 제거하기
--데이터 정의어(DDL= Data Definition Language)
--1.CREATE : DB 객체 생성
--2.ALTER  :       변경
--3.DROP   :       삭제
--4.RENAME :       이름 변경
--5.TRUNCATE : 데이터 및 저장 공간 삭제

/*
 * ★★ DELETE (DML:데이터 조작어), TRUNCATE, DROP(DDL:데이터 정의어) 명령어의 차이점
 * (DELETE, TRUNCATE, TRUNCATE 명령어는 모두 삭제하는 명령어이지만  중요한 차이점이 있다.)
 * 
 * 
 * 1. DELETE 명령어 : 데이터는 지워지지만 테이블 용량은 줄어들지 않는다.
 * 				        원하는 데이터만 삭제 가능.
 * 				        삭제 후 잘못 삭제한 것은 되돌릴 수 있다 (=rollback)
 * 
 * 2. TRUNCATE 명령어 : 용량이 줄어들고, index등도 모두 삭제된다.
 * 					   테이블은 삭제하지 않고 데이터만 삭제.
 * 					   한꺼번에 다 지워야 한다.
 * 					   삭제 후 절대 되돌릴 수 없다.
 * 
 * 3. DROP 명령어 : 테이블 전체를 삭제(테이블 공간, 객체를 삭제) 
 * 				   삭제 후 절대 되돌릴 수 없다.
 */

--1. 테이블 구조를 만드는 create table문 (교재 206p)
--테이블 생성하기 위해서는 테이블명 정의, 테이블을 구성하는 컬럼의 데이터 타입과 무결성 제약 조건 정의

--<테이블명 및 컬럼명 정의 규칙>
--문자(영어 대소문자)로 시작, 30자 이내
--문자(영어 대소문자), 숫자 0~9, 특수문자(_ $ #)만 사용 가능
--대소문자 구별 없음, 소문자로 저장하려면 ''로 묶어준다
--동일 사용자의 다른 객체의 이름과 중복 x  ex) system이 만든 테이블명들은 다 달라야 함

--<서브 쿼리를 이용하여 다른 테이블로부터 복사하여 테이블 생성 방법>

--	서브 쿼리문으로 부서 테이블의 구조와 데이터 복사 => 새로운 테이블 생성
--	create table 테이블 명(컬럼명 명시 o) : 지정한 컬럼 수와 데이터 타입이 서브 쿼리문의 검색된 컬럼과 일치
--	create table 테이블 명(컬럼명 명시 x) : 서브 쿼리의 컬럼 명이 그대로 복사

--	[무결성 제약 조건] : ★★ not null 조건만 복사,
--	 			       기본키(=PK), 외래키(=FK)와 같은 무결성 제약 조건은 복사 x
--				       디폴트 옵션에서 정의한 값은 복사 가능

--	서브 쿼리의 출력 결과가 테이블의 초기 데이터로 삽입 됨














--ex) create table 테이블명(컬럼명 명시 o)

--[문제] 서브 쿼리문으로 부서 테이블의 구조와 데이터 복사하기(★☆ '제약조건'은 복사 안 됨-not null 조건만 복사)
select dno --컬럼수 1개
from department;

create table dept1(dept_id) --컬럼수 1개(★☆ '제약조건'은 복사 안 됨-not null 조건만 복사) / 테이블명(컬럼명)
AS
select dno --컬럼수 1개
from department;

select *
from dept1;



--ex) create table 테이블명(컬럼명 명시 x)

--[문제] 20번 부서 소속 사원의 정보를 포함한 dept20 테이블 생성
--[1] 20번 부서 소속 사원 정보 조회
select eno, ename, salary*12 연봉
from employee
where dno=20;


--[2] ★★서브 쿼리문 속 '산술식(계산식)'에 별칭 지정 필수
create table dept2
AS
select eno, ename, salary*12 연봉 --별칭 필수
from employee
where dno=20;


select *
from dept2;


create table dept2_err 
AS
select eno, ename, salary*12 --별칭 없으면 오류
from employee
where dno=20;


--<서브 쿼리의 데이터는 복사하지 않고 테이블 구조만 복사>
--서브 쿼리의 where절을 항상 거짓이 되는 조건 지정 : 조건에 맞는 데이터가 없어서 데이터 복사 안 됨
--대표적인 조건 : WHERE 0=1;

--[문제] 부서 테이블의 구조만 복사하여 dept3 테이블 생성

create table dept3
AS
select *
from department
WHERE 0=1; --거짓 조건

select *
from dept3; --구조만 복사되고 데이터는 복사되지 않았음

--테이블 구조 확인 명령어
DESC dept3; --이클립스에서는 실행 안 됨 => RUN SQL Command Line에서 가능 // conn system 1234 입력 => desc dept3;

--------------------------------------------------------------------------------------

--2. 테이블 구조를 변경하는 ALTER TABLE문
--2.1 컬럼 추가 : 추가된 컬럼은 마지막 위치에 생성(즉, 원하는 위치에 지정할 수 없음.)

--[문제] 사원 테이블 dept2에 날짜 타입을 가진 birth 컬럼 추가
alter table dept2
ADD birth date;
--이 테이블에 기존에 추가한 데이터(=행)이 있으면 추가한 컬럼(birth)의 컬럼 값은 null로 자동 입력됨


--[문제] 사원 테이블 dept2에
alter table dept2
ADD email varchar2(50) DEFAULT 'test@test.com' not null;
--이 테이블에 기존에 추가한 데이터(=행)이 있으면 추가한 컬럼(email)의 컬럼 값은 DEFAULT로 자동 입력됨


select * 
from dept2;

--2.2 컬럼 변경
--기존 컬럼에 데이터가 없는 경우 : 컬럼 타입이나 크기 변경 자유
--			       있는 경우 : 타입 변경은 char와 varchar2만 허용하고
--					        변경할 컬럼의 크기가 저장된 데이터의 크기보다 같거나 클 경우에만 변경 가능함
--					        숫자 타입은 폭 또는 전체 자릿수를 늘릴 수 있음   ex) number : 정수 실수 아무거나 가능 
--														  number(전체자릿수,나타낼 소수 자리)
--														  number(7) : (7,0) 7자리 정수(일의 자리까지 표시, 소수 첫째자리에서 반올림)  
--														  number(5,2) : 실수 / 3자리 정수, 소수점 아래 2자리

--[문제] 테이블 dept2에서 사원 이름의 컬럼 크기 변경
alter table dept2
MODIFY ename varchar2(30); --컬럼 크기 10에서 30으로 변경 가능(가변길이)

desc dept2; --변경된 크기 확인

alter table dept2
MODIFY ename char(30); --타입 변경 (varchar2 => char)

alter table dept2
MODIFY ename char(10); -- 컬럼 크기 30에서 10으로 변경 => 오류 : 크기 작게 변경 불가

alter table dept2
MODIFY ename number(30); --오류 : 타입 변경은 char <-> varchar2만 가능
--char -> number로 변경하는 경우 : 해당 컬럼의 값을 모두 지우면 변경 가능

alter table dept2
MODIFY ename varchar2(40);


--[문제] 테이블 dept2에서 사원 이름 컬럼명 변경(ename -> ename2)
alter table dept2
RENAME column ename TO ename2;


--[문제] 테이블 dept2에서 컬럼 기본 값 지정
--변경 안 됨 : ename2에 데이터가 null로 입력된 상태이므로 컬럼 변경 안 됨 
alter table dept2
MODIFY ename2 varchar2(40) DEFAULT 'AA' not null;

--해결 : 구조는 두고 데이터만 삭제 후 다시 기본값 지정
truncate table dept2;

select * from dept2;

alter table dept2
MODIFY ename2 varchar2(40) DEFAULT '기본' not null;

-------------------------------------------------------------------------------

--★★DROP, SET unused : 둘 다 실행한 후 되돌릴 수 없음. 그러나 다시 같은 이름의 컬럼 생성 가능
--2.3 컬럼 제거 : 2개 이상 컬럼이 존재한 테이블에서만 컬럼 삭제 가능

--[문제] 테이블 dept2에서 사원 이름 제거
alter table dept2
DROP column ename;

--그러나 다시 같은 이름의 컬럼 생성 가능
--ex)
alter table dept2
ADD ename varchar2(20);

select *
from dept2;



--2.4 set unused : 시스템의 요구가 적을 때 컬럼을 제거할 수 있도록 하나 이상의 컬럼을 unused로 표시
--실제로 제거되지는 않음
--데이터가 존재하는 경우에는 삭제된 것처럼 처리되기 때문에 select절로 조회가 불가능함
--describe문으로도 표시되지 않음    ex) desc 테이블명; : 테이블 구조 확인
--사용하는 이유 : 1. 사용자에게 보이지 않게 하기 위해
--			 2. unused로 미사용 상태로 표시한 후 나중에 한꺼번에 drop으로 제거하기 위해
--				운영 중에 컬럼을 삭제하는 것은 시간이 오래 걸릴 수 있어서 unused로 표시해두고 한꺼번에 drop으로 제거

--[문제] 테이블 dept2에서 '연봉'을 unused 상태로 만들기
alter table dept2
SET unused("연봉");

--[문제] unused로 표시된 모든 컬럼을 한꺼번에 제거
alter table dept2
DROP unused columns; --s:복수

--그러나 다시 같은 이름의 컬럼 생성 가능
--ex2)
alter table dept2
ADD salary number(20);

select *
from dept2;



--[오라클 11g 이하 - 컬럼의 순서를 바꾸려면]
--'기존 테이블 삭제 후 재 생성'해야 함
--대부분 컬럼 순서 변경이 꼭 필요한 경우에만 작업을 하고 그 외에는 마지막에 컬럼을 추가한다.

--[1] 변경할 컬럼 순서로 조회 후 테이블 생성
create table dept2_copy
AS
select eno, ename, salary, birth
from dept2;


--[2] 기존 테이블 삭제
DROP table dept2;


--[3] 기존 테이블 이름으로 변경 (dept2_copy => dept2)
RENAME dept2_copy TO dept2;

select *
from dept2;

--[4] 마지막: 제약조건 다시 생성해야 함

-----------------------------------------------------------------------------------------------

--3. 테이블명 변경 : rename 기존이름 to 새이름;
rename dept2 to emp2;


--4. 테이블 구조 제거 : drop  table 테이블명;

--★★ [department 테이블 제거방법 1]
--삭제할 테이블의 기본키(PK), 고유키(유일한 값을 가지는 키, 모두 다 다른 값을 가짐)를 다른 테이블에서 참조하고 있는 경우에는 삭제 불가능 
--그래서 '참조하는 테이블(자식 테이블)' 먼저 제거 후 부모 테이블 제거

drop table employee; --자식 테이블 먼저 제거
drop table department;


--★★ [department 테이블 제거방법 2]
--사원 테이블의 '참조키 제약조건까지 함께 제거' (참조키 제약조건 : 참조하는 상황을 제거)
drop table department cascade constraints; --s : 제약조건'들'

--종속관계 확인
select table_name, constraint_name, constraint_type -- 테이블 이름, 제약조건 이름, 타입 --P:PK기본키 , R:참조키
from user_constraints
--table_name : 대문자 -> 소문자 변경하여 찾음 (아래 두 방법중 택 1)
where lower(table_name) in ('employee','department');
--where table_name in ('EMPLOYEE', 'DEPARTMENT');


--5. 테이블의 모든 데이터만 제거 : truncate table
--테이블 구조는 유지, 테이블에 생성된 제약 조건과 연관된 인덱스 , 뷰, 동이어는 유지됨
select *  from emp2; 
insert into emp2 values(1, 'kim', 2500, '2022-01-03', default);
select *  from emp2; --조회 후

truncate table emp2; --데이터만 제거
select *  from emp2; 


--6. 데이터 사전 : 사용자와 DB 자원을 효율적으로 관리하기 위해 다양한 정보를 저장하는 시스템 테이블 집합
--사용자가 테이블을 생성하거나 사용자를 변경하는 등의 작업을 할 때
--DB 서버에 의해 자동 갱신되눈 테이블
--사용자가 직접 수정, 삭제 불가 => '읽기 전용 뷰'로 사용자에게 정보 제공


--6.1 USER_데이터 사전 : USER_로시작~S(복수)로 끝남
--사용자와 가장 밀접하게 관련된 뷰로  자신이 생성한 테이블, 뷰, 인덱스, 동의어 등의 객체나 해당 사용자에게 권한 정보 제공
--ex. USER_tables로 사용자가 소유한 '테이블'에 대한 정보 조회
select *
from USER_tables; --사용자(system)가 소유한 '테이블' 정보


select sequence_name, min_value, max_value, inncrement by, cycle_flag 
from USER_sequences; --사용자가 소유한 '시퀀스' 정보 (292p)


select index_name
from user_indexs; --사용자가 소유한 'index' 정보

select view_name
from user_views --사용자가 소유한 '뷰' 정보

--테이블의 제약  조건 보려면 'USER_constraints' 데이터 사전 사용함
select table_name. constraint_name, constraint_type
from user_constrains
where table_name IN ('EMPLOYEE'); -- ★★주의: 1.반드시 대문자
--where lower(table_name) in ('employee') --2. LOWER()함수 사용하여 소문자로 변경




-- 객체 : 테이블, 시퀀스, 인덱스, 뷰 등
--6.2 . ALL_데이터 사전
--전체 사용자와 관련된 뷰, 사용자가 접근할 수 있는 모든 객체 정보 조회
--owner : 조회 중인 객체가 누구의 소유인지 확인


--ex. ALL_tables로 테이블에 대한 정보 조회

-- 사용자  : system 일 때 - 500레코드 (레코드:한줄), SYS와 SYSTEM만 : 사용자(HR:교육용) 제외된 상태로 결과가 나옴
--	    :   hr 	  일 때 - 78레코드 (사용자 hr과 다른 사용자를 포함한 결과 나옴)

select owner, table_name 
from ALL_tables; 
--where owner in ('SYSTEM') or table_name in ('EMPLOYEE', 'DEPARTMENT');
--where table_name in ('EMPLOYEE', 'DEPARTMENT');


--where절에 owner in ('HR') 추가하여 조회하면 사용자(HR)에 대한 결과가 나옴 
select owner, table_name 
from ALL_tables
where owner in ('HR');




--6.3. DBA_데이터 사전 : 시스템 관리와 관련된 뷰, DBA나 시스템 권한을 가진 사용자만 접근 가능
--현재 접속한 사용자가 hr(교육용 계정)이라면 'DBA_데이터 사전'을 조회할 권한 없음
--DBA 권한 가진 system 계정으로 접속해야 테스트 가능


--ex) DBA_tables로 테이블에 대한 정보 조회
-- 사용자  : system 일 때 - 500레코드 (레코드:한줄), SYS와 SYSTEM만 : 사용자(HR:교육용) 제외된 상태로 결과가 나옴
--					   ALL_tables로 조회한 정보와 같은 결과
--	    :   hr 	  일 때 - 실패(table or view does not exist) : DBA 권한 없어서

select owner, table_name 
from DBA_tables; 


select owner, table_name 
from DBA_tables
where owner in ('HR');

----------------------------------------------------------------------------------------------


/* [RUN SQL CommanLine에서 HR로 접속하는 방법]
	
	1. RUN SQL...창 열기
	conn hr/hr 
	=>실패 : account is lock (=계정 비활성화)

 	2. 계정을 활성화시키기 위해 관리자 계정 접속
 	conn system/1234
 	alter user hr identified by hr account unlock;
 	
 	3. 다시 hr로 접속
 	conn hr/hr

*/


--[혼자해보기]-------------------------------------------------------------------------------------


--1. 다음 표에 명시된 대로 DEPT 테이블을 생성하시오


create table dept (
		dno number(2),
		dname varchar2(14),
		loc varchar2(13));


--2. 다음 표에 명시된 대로 EMP 테이블을 생성하시오

		
create table emp(
		eno number(4),
		ename varchar2(10),
		dno number(2));
		
		
--3. 긴 이름을 저장할 수 있도록 EMP 테이블을 수정하시오 (ENAME 칼럼의 크기)

	
alter table emp
modify ename varchar2(25);
		
		
		
--4. EMPLOYEE 테이블을 복사해서 EMPLOYEE2란 이름의 테이블을 생성하되 사원번호, 이름, 급여, 부서번호 칼럼만 복사하고 
-- 새로 생성된 테이블의 칼럼명은 각각 EMP_ID, NAME, SAL, DEPT_ID로 지정하시오


create table employee2(emp_id, name, sal, dept_id)
as
select eno, ename, salary, dno
from employee
where 0=1;




--5. EMP 테이블을 삭제하시오


drop table emp;



--6. EMPLOYEE2란 테이블을 EMP로 변경하시오


rename employee2 to emp;




--7. DEPT 테이블에서 DNAME 칼럼을 제거하시오


alter table dept
drop column dname;




--8. DEPT 테이블에서 LOC 칼럼을 UNUSED로 표시하시오


alter table dept
set unused (loc);





--9. UNUSED 칼럼을 모두 제거하시오.


alter table dept
drop unused cloumns;















