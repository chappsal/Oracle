--<북스-10장_데이터 무결성과 제약조건>

create table [schema:소유자 이름(=사용자 계정)] table명( --schema: 스키마
컬럼명1 데이터 타입(길이) [not null | null | unique | default 표현 | check(체크조건)]
[[constraint 제약조건명(테이블명_컬럼명_pk) | primary key | constraint 제약조건명(테이블명_컬럼명_fk)] foreign key references 참조테이블명], --[]는 모두 옵션
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



