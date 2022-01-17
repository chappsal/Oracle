--<북스-10장_데이터 무결성과 제약조건>

create table [schema:소유자 이름(=사용자 계정)] table명( --schema: 스키마
컬럼명1 데이터 타입(길이) [not null | null | unique | default 표현 | check(체크조건)]
[[[constraint 제약조건명(테이블명_컬럼명_pk)] | primary key | [constraint 제약조건명(테이블명_컬럼명_fk)] | [foreign key]]  references 참조테이블명], --[]는 모두 옵션
컬럼명2...,
컬럼명n...,

테이블 레벨 제약조건
);


--1. 제약조건
--데이터 무결성 제약조건 : 테이블에 유호하지 않은(부적절한) 데이터가 입력되는 것을 방지하기 위해
--테이블 생성할 때 각 컬럼에 대해 정의하는 여러 규칙

--<제약조건(5가지)>----------------------------------------------------------------------
--1. not null

--2. unique : 중복 허용x -> 유일, 고유한 값 -> 고유 키(암시적 index 자동 생성)
--			  ★★null은 unique 제약 조건에 위반되지 않으므로 'null값을 허용'


--3. primary key(기본키,pk) : not null + unique => null값 불가, 고유키(암시적 index 자동 생성)

--4. foreign key(외래키,참조키,fk) : 참조되는 테이블에 컬럼 값이 반드시 존재
--								 ex) 사원테이블(자식) dno(fk) -> 부서테이블(부모) dno(pk or unique)
--								  ※참조 무결성 : 테이블 사이의 주종 관계를 설정하기 위한 제약 조건 
-- 어느 테이블의 데이터가 먼저 정의되어야 하는가? 부모 -> 자식 

--5. check() : '저장 가능한 데이터 범위나 조건 지정'하여 (ex) check(salary > 0)
--				=> 설정된 값 이외의 값이 들어오면 오류
-------------------------------------------------------------------------------------
--default는 제약조건 x
--default 정의 : 아무런 값을 입력하지 않았을 때 default값이 입력됨

--제약조건 : 컬럼레벨 : 하나의 컬럼에 대해 모든 제약 조건을 정의
--		    테이블레벨 : not null 제외한 나머지 제약 조건을 정의

--<제약 조건 이름 직접 지정할 때 형식>
--constraint 제약조건이름
--constraint 테이블명_컬럼명_제약조건유형(pk,fk,uk)
--제약 조건 이름을 지정하지 않으면 자동 생성됨

create table customer2(
id varchar2(20) unique,
pwd varchar2(20) not null,
name varchar2(20) not null,
phone varchar2(30),
address varchar2(100)
);

drop table customer2;


create table customer2(
id varchar2(20) constraint customer2_id_u unique,
pwd varchar2(20) constraint customer2_pwd_nn not null,
name varchar2(20) constraint customer2_name_nn not null,
phone varchar2(30),
address varchar2(100)
);


create table customer2(
id varchar2(20) constraint customer2_id_pk primary key, 
pwd varchar2(20) constraint customer2_pwd_nn not null,
name varchar2(20) constraint customer2_name_nn not null,
phone varchar2(30),
address varchar2(100)
);

-------------------------------------------------------------------여기까지 컬럼레벨
--테이블레벨

create table customer2(
id varchar2(20), 
pwd varchar2(20) constraint customer2_pwd_nn not null,
name varchar2(20) constraint customer2_name_nn not null,
phone varchar2(30),
address varchar2(100),

constraint customer2_id_pk primary key(id)--테이블 레벨
--constraint customer2_id_pk primary key(id,name)--기본키가 2개 이상일 때 테이블 레벨 사용 (name은 같은 이름이 있을 수 있어서 pk하는 경우는 드물다)
);



--테이블 제약 조건 조회
select table_name, constraint_name, constraint_type --c(not null), u(unique), p(primary key), r(reference)
from user_constraints
where table_name in ('CUSTOMER2');

--where table_name in upper('CUSTOMER2');
--where lower(table_name) in ('CUSTOMER2');
--where table_name like 'CUSTOMER2';

--1.1 not null 제약조건 : 컬럼 레벨로만 정의
insert into customer2 values(null, null, null, '010-1111-1111', '대구 달서구');

--1.2 unique 제약조건 : 유일한 값만 허용 (단, null허용)

--1.3 primary key 제약조건

--1.4 foreign key (fk=참조키=외래키) 제약조건
--사원 테이블의 부서번호는 언제나 부서 테이블에서 참조 가능 : 참조 무결성

select * from department; --부모

--삽입(자식에서)
insert into employee(eno, ename, dno) values(8000, '홍길동', 50);
--부서번호 50 입력하면
--'참조 무결성 위배, 부모키를 발견하지 못했다'는 오류 메세지

--이유 : 사원 테이블에서 사원의 정보를 새롭게 추가할 경우
--     사원 테이블의 부서번호는 부서 테이블의 저장된 부서 번호 중 하나와 일치
--     or null 만 입력 가능 (단, null 허용하면)

--삽입 방법-1
insert into employee(eno, ename, dno) --참조하는 자식
values(8000, '홍길동', ''); -- ''(null) 단, dno가 null 허용하면

--삽입 방법-2 : 제약 조건을 삭제하지 않고 일시적으로 '비활성화' -> 데이터 처리 -> 다시 '활성화'
--user_constraints 데이터 사전을 이용하여 constraint_name과 type과 status 조회
select constraint_name, constraint_type, status --p(기본키) r(참조키) enabled(활성화된 상태)
from user_constraints
where table_name in ('EMPLOYEE');

--[1] 제약조건 '비활성화'
alter table employee
disable constraint SYS_C007012; --constraint_type이 R인 것의 이름


--[2] 자식에서 삽입
insert into employee(eno, ename, dno) values(9000, '홍길동', 50);
--values(8000, '홍길동', 50) --이미 8000은 그전에 삽입한 상태


--[3] 다시 활성화 : 오류 발생
alter table employee
enable constraint SYS_C007012; 
--오류 : cannot validate (SYSTEM.SYS_C007012) - parent keys not found 


--다시 활성화시키기 위해 eno가 9000인 row 삭제 => 다시 활성화
delete employee
where eno = 9000;


--삽입 방법-2 정리 : 제약조건 잠시 비활성화시켜 원하는 데이터를 삽입하더라도 다시 제약조건 활성화시키면 오류 발생하여
--				삽입한 데이터를 삭제해야 함

--★★★삭제(부모에서)-부서 테이블에서 삭제할 때
drop table department;
--unique/primary keys in table referenced by foreign keys
--자식만 employee에서 참조하는 상황에서는 삭제 안 됨

----1. 부모 테이블 생성 : 실습위해 department 복사하여 department2 테이블 생성
create table department2
as
select * from department; --★주의 : 제약조건 복사 불가

select * from department2;

----제약조건 확인 시 결과 없음
select constraint_name, constraint_type, status
from user_constraints
where lower(table_name) in ('department2');

----primary key 제약조건 추가 (단, 제약조건명 직접 만들어 추가) : 제약조건 복사 불가하므로
alter table department2
add constraint department2_dno_pk primary key(dno);

----2. 자식 테이블 생성
create table emp_second(
eno number(4) constraint emp_second_eno_pk primary key,
ename varchar2(10),
job varchar2(9),
salary number(7,2) default 1000 check(salary > 0),
dno number(2), --constraint emp_second_dno_fk foreign key references department2 on delete cascade --(FK=참조키=외래키)컬럼레벨

--'테이블 레벨'에서만 가능 : ON DELETE 옵션
constraint emp_second_dno_fk foreign key(dno) references department2(dno)
on delete cascade
);


/*

== ON DELETE 뒤에 ==
1. no action (기본값) : 부모 테이블 값이 자식 테이블에서 참조하고 있으면 부모 삭제 불가
      ※ restrict(MY SQL에서 기본 값, no action과 같은 의미로 사용 )

      ※ 오라클에서의 restrict는 no action과 약간의 차이가 있음

2. cascade : 참조되는 '부모테이블의 값이 삭제'되면 연쇄적으로 '자식 테이블이 참조하는 값 역시 삭제'
			 ex) 부서 테이블의 부서번호 40 삭제할 때 사원 테이블의 부서번호 40도 삭제됨

3. set null : 부모 테이블의 값이 삭제되면 해당 참조하는 자식 테이블의 값들은 null값으로 설정 
			  (단, null 허용한 경우) 
			  ex) 부서 테이블의 부서번호 40 삭제할 때 사원 테이블의 부서번호가 null로 변경
																		
4. set default : 자식의 관련 튜플을 미리 설정한 값으로 변경
				 ex) 부서 테이블의 부서번호 40 삭제할 때 사원 테이블의 부서번호를 default 값으로 변경
				  이 제약조건이 실행하려면 모든 참조키 열에 기본 정의가 있어야 함
				  컬럼이 null을 허용하고 명시적 기본 값이 설정되어 있지 않은 경우 null은 해당 열의 암시적 기본 값이 된다
			

 */

insert into emp_second values(1, '김', '영업', null, 30);
insert into emp_second values(2, '이', '조사', 2000, 20);
insert into emp_second values(3, '박', '운영', 3000, 40);
insert into emp_second values(4, '조', '상담', 3000, 20);


--1.6 DEFAULT 정의
--default 값 넣는 2가지 방법
insert into emp_second(eno, ename, job,dno) values(5, '김', '영업', 30); --salary:default 1000
insert into emp_secon values(6, '이', default, 30); --salary:default 1000

select * from emp_second;
select * from department2;

--부모에서 dno=20 삭제하면 자식에서 참조하는 행도 삭제됨
--이유? ON DELETE CASCADE
delete department2 where dno=20;

delete department where dno=20; --실패 이유? 자식에서 참조하고 있으면 부모의 행 삭제 불가


--테이블 전체(구조+데이터) 제거 : 실패? 현재 사원 테이블의 참조 키로 참조하고 있으므로 테이블 아예 삭제 안 됨
drop table department2;


--테이블 데이터만 삭제(구조는 남김)
truncate table department2; --불가: rollback 불가
delete from department2; --★★성공: rollback 가능


select * from department2; --부모에서 모든 데이터 다 삭제하면
select * from emp_second; --자식에서도 모든 데이터 다 삭제 됨


--1.5 check 제약 조건 : 값의 범위, 조건 지정
--currval, nextval, rownum 사용 불가
--sysdate, user와 같은 함수 사용 불가


--[test위해] 
--[1] emp_second drop => department2 drop
drop table emp_second;
drop table department2;
--[2] department2 생성 => emp_second 생성
create table department2
as
select * from department; --★주의: 제약조건 복사 불가


alter table department2
add constraint department2_dno_pk primary key(dno); 


--[2-2] emp_second 생성
create table emp_second(
eno number(4) constraint emp_second_eno_pk primary key,
ename varchar2(10),
job varchar2(9),
salary number(7,2) default 1000 check(salary > 0),
dno number(2),
constraint emp_second_dno_fk foreign key(dno) references department2(dno)
on delete cascade
);


--check(salary > 0)
insert into emp_second values(4, '조', '상담', -3000, 30);
--오류: check constraint (SYSTEM>SYS_C007058) violated

insert into emp_second values(4, '조', '상담', 3000, 30); --성공

------------------------------------------------------------------------------------


--2.제약 조건 변경하기
--2.1 제약 조건 추가 : alter table 테이블명 + add constraint 제약조건명 + 제약조건
--단, null 무결성 제약 조건은 alter table 테이블명 + add~로 추가하지 못 함
--					  alter table 테이블명 + modify로 null 상태로 변경 가능
--   default 정의할 때도    alter table 테이블명 + modify로



--[test위해]
--drop table dept_copy;
--drop table employee;

create table dept_copy
as
select * from department; --제약조건 복사 x

create table emp_copy
as
select * from employee; --제약조건 복사 x


select table_name, constraint_name
from user_constraints
where table_name in ('DEPARTMENT', 'EMPLOYEE', 'DEPT_COPY', 'EMP_COPY');



--ex.기본키 제약조건 추가하기
alter table emp_copy
add constraint emp_copy_eno_pk primary key(eno);

alter table dept_copy
add constraint dept_copy_dno_pk primary key(dno);

--추가된 제약조건 확인
select table_name, constraint_name
from user_constraints
where table_name in ('DEPARTMENT', 'EMPLOYEE', 'DEPT_COPY', 'EMP_COPY');



--(ex2) 외래키=참조키 제약조건 추가하기
alter table emp_copy
add constraint emp_copy_dno_fk foreign key(dno) references dept_copy(dno);
--on delete cascade | on delete set null; 필요시 추가 가능

--추가된 제약조건 확인
select table_name, constraint_name
from user_constraints
where table_name in ('DEPT_COPY', 'EMP_COPY');



--(ex3) not null 제약조건 추가하기
alter table emp_copy
modify ename constraint emp_copy_ename_nn not null;



--(ex4) default 정의 추가하기 (★★constraint 제약조건명 입력하면 오류)
alter table emp_copy
modify salary default 500; 


--추가된 제약조건 확인
select table_name, constraint_name
from user_constraints
where table_name in ('DEPT_COPY', 'EMP_COPY'); --default 정의는 결과에 없음(제약조건이 아니므로)


--(ex5) check 제약조건 추가하기
alter table emp_copy
add constraint emp_copy_salary_check check(salary>1000);
--실패: 이미 1000보다 작은 급여가 있으므로 조건에 위배


alter table emp_copy
add constraint emp_copy_salary_check check(500<=salary and salary<10000);

alter table dept_copy
add constraint dept_copy_dno_check ckeck(dno in(10,20,30,40,50)); --반드시 dno는 5가지 중 하나만 insert가능




--2.2 제약 조건 제거
--외래키 제약조건에 지정되어 있는 부모 테이블의 기본키 제약조건을 제거하려면
--테이블의 참조 무결성 제약조건을 먼저 제가한 후 제거하거나
--cacade 옵션 사용 : 제거하려는 컬럼을 참조하는 참조 무결성 제약조건도 함께 제거
alter talble dept_copy --부모
drop primary key; --실패 : 자식 테이블에서 참조하고 있으므로


alter talble dept_copy 
drop primary key cascade; --참조하는 자식 테이블의 '참조 무결성 제약조건'도 함께 제거됨

--삭제된 제약조건 확인 : 둘 다 삭제됨
select table_name, constraint_name
from user_constraints
where table_name in ('DEPT_COPY', 'EMP_COPY');

--ex) not null 제약조건 제거
alter table emp_copy
drop constraint emp_copy_ename_nn;

--삭제된 제약조건 확인
---------------------------------------------------------------------------------------

--3. 제약조건 활성화 및 비활성화
--alter table 테이블명 + disable constraint 제약조건명 [cascade]
--제약 조건을 삭제하지 않고 일시적으로 비활성화
--※ 위 내용 참조하기




--혼자해보기--------------------------------------------------------------------------------

--1. employee 테이블의 구조를 복사하여 emp_sample이란 이름의 테이블을 만드시오. 
--사원 테이블의 사원번호 칼럼에 테이블 레벨로 primary key 제약 조건을 지정하되 제약 조건 이름은 my_emp_pk로 지정하시오

create table emp_sample
as 
select * from employee
where 0=1;

alter table emp_sample
add constraint my_emp_pk primary key(eno);


--2. 부서 테이블의 부서번호 칼럼에 테이블 레벨로 primary key 제약 조건을 지정하되 제약 조건 이름은 my_dept_pk로 지정하시오

create table dept_sample
as
select * from department
where 0=1;

alter table department
add constraint my_dept_pk primary key(dno);


--3. 사원 테이블의 부서번호 칼럼에 존재하지 않는 부서의 사원이 배정되지 않도록 외래 키 제약 조건을 지정하되 제약 조건 이름은 my_emp_dept_fk로 지정하시오

alter table dept_sample
add constraint my_emp_dept_fk foreign key references department;
--오류 발생 안 한 이유 : 자식 테이블에 데이터 없음(자식에서 부모를 참조하는 데이터가 없음)
--반드시 부모의 데이터를 먼저 insert => 자식의 참조하는 데이터 insert


--4. 사원 테이블의 커미션 칼럼에 0보다 큰 값만을 입력할 수 있도록 제약 조건을 지정하시오

alter table emp_sample
add constraint emp_sample_commission_ch check(commission > 0);





