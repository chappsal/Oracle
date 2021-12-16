--북스 6장 테이블 조인하기
--1. 조인
--1.1. 카디시안 곱 : cross join - 조인 조건이  없다.
select * from employee; -- 컬럼수(열): 8, 행수: 14
select * from department; -- 컬럼수: 3, 행수: 4

select * -- 11개 컬럼, 56개 전체 행 수
from employee, department; 
-- 조인 결과: 컬럼 수 (11) = 사원 테이블의 컬럼 수(8) + 부서 테이블의 컬럼 수(3)
--			행 수 (56) = 사원 테이블의 행 수 (14) x 부서 테이블의 행 수   (4)
--					= 사원 테이블의 사원 1명 당    x 부서 테이블의 행 수 (4) 

select eno -- eno의 컬럼만, 56개 전체 행 수
from employee, department;


select * -- 11개 컬럼, eno가 7369인 것만
from employee, department
where eno = 7369; --()조인 조건 아님검)색 조건


--1.2 조인의 유형
--오라클 8i이전 조인 : equi 조인(=등가 조인), non-equi 조인(=비동가 조인 ), outer 조인(왼쪽, 오른쪽), self 조인
--오라클 8i이후 조인 : corss 조인, natural 조인(=자연 조인), join~using
--오라클 9i부터 ANSI 표준 SQL 조인 : 현재 대부분의 상용 데이터베이스 시스템에서 사용,
-- 							  다른 DBMS와 호환이 가능하기 때문에 ANSI 표준 조인에 대해서 확실히 학습하자.


-------------아래 4가지 비교---------------------------------------------------------------
--[문제] '사원번호가 7788'인 사원이 소속된 '사원번호, 사원이름, 소속부서이름' 열기

--equi join : 동일한 이름과 유형(=데이터 타입)을 가진 컬럼으로 조인
--			    단, [방법1: ~where]과  [방법 2: join~on]은 데이터 타입만 같아도 조인 됨



--[방법 1. , ~where]
--조인결과는 중복된 컬럼 제거x => 따라서 테이블에 '별칭 사용'해서 어느 테이블의 컬럼인지 구분해야 함

select 컬럼명 1, 컬럼명 2... -- 중복되는 컬럼은 반드시 '별칭.컬럼명' ex) e.dno
from 테이블 1, 테이블 2 --별칭 사용
where ★조인조건 (주의 : 테이블의 별칭 사용)
and   ★검색조건
--★문제점 : 원하지 않는 결과가 나올 수 있다 (이유? and -> or의 우선 순위 때문에)
--★문제점 해결법 : AND 검색조건 에서 괄호()를 사용해 우선 순위 변경
--예)
--where e.dno=d.dno AND d.dno=10 OR d.dno=40; --문제 발생
--where e.dno=d.dno AND (d.dno=10 OR d.dno=40); --★해결법: 괄호()로 우선 순위 변경


--문제해결
select eno, ename, e.dno, dname --별칭 사용 : 두 테이블 모두 존재하므로 구분위해
from employee e, department d
where e.dno=d.dno
and eno=7788;



--[방법 2. , join~on]
--동일한 이름과 데이터 유형을 가진 컬럼으로 조인 + '임의의 조건을 지정'하거나 조인할 컬럼을 지정할 때 ON절 사용
--조인결과는 중복된 컬럼 제거x (오직 natural join만 제거) => 따라서 테이블에 '별칭 사용'해서 어느 테이블의 컬럼인지 구분해야 함

select 컬럼명 1, 컬럼명 2... -- 중복되는 컬럼은 반드시 '별칭.컬럼명' ex) e.dno
from 테이블 1 JOIN 테이블 2 --별칭 사용
ON    ★조인조건 (주의 : 테이블의 별칭 사용)
where ★검색조건
--[방법 1]에서 나타난 문제가 발생하지 않으므로 검색 조건에서 괄호 사용하지 않아도 됨


--[문제해결]
select eno, ename, e.dno, dname --별칭 사용 : 두 테이블 모두 존재하므로 구분위해
from employee e JOIN department d
ON e.dno=d.dnow
WHERE eno=7788;


----------------------------------------------------------[방법 1]과 [방법 2]의 조인 결과 : 중복된 컬럼 제거 x
----------------------------------------------------------   	                    ★ 데이터 타입만 같아도 join 가능 (ex) a.id=b.id2

create table A(
id number(2) primary key,
name varchar2(20),
addr varchar2(100)
);

insert into A values(10,'유재훈','대구 달서구');
insert into A values(20,'노석찬','대구 북구');


create table B(
id2 number(2) primary key,
tel varchar2(20)
);


insert into B values(10,'010-1111-1111');
insert into B values(30,'010-3333-3333');


select *
from A, B;

--방법 1
select *
from A a, B b
where a.id=b.id2; --데이터 타입만 같아도 조인 됨 ('같은 아이디라는 의미'이므로 조인)

--방법 2
select *
from A a JOIN B b
ON a.id=b.id2; --데이터 타입만 같아도 조인 됨 ('같은 아이디라는 의미'이므로 조인)


----------------------------------------------------------[방법 3]과 [방법 4] : 컬럼명이 다르면 join 안 됨
--[방법 3 : natural join]
--조인 결과는 중복된 컬럼 제거
--"자동으로" 동일한 이름과 데이터 유형을 가진 컬럼으로 조인 (★ 단, 1개만 있을 때 사용하는 것을 권장)
--★동일한 이름과 데이터 유형을 가진 컬럼이 2개 이상 있어도 자동으로 조인 되나 문제 발생할 수 있음
-- => 문제 발생 이유? ex. employee의 dno와  department의 dno : 동일한 이름(dno)과 데이터 유형(number(2)) 
-- 													(★두 테이블에서 dno는  부서번호로 의미도 같다.

--				만약, employee의 manager_id (각 사원의 '상사'를 의미하는 번호) 와
--					department의 manager_id (그 부서의 '부장'을 의미하는 번호) 가 있다고 가정했을 때
--					둘 다 동일한 이름과 데이터 유형을 가졌지만 manager_id의 의미가 다르다면 원하지 않는 결과가 나올 수 있음




select 컬럼명 1, 컬럼명 2... 
from 테이블 1 NATURAL JOIN 테이블 2 --별칭 사용 안 함 (권장)
--★조인 조건 필요 없음
where ★검색조건


--[문제해결]
select eno, ename, e.dno, dname --dno는 중복 제거했으므로  e.dno, d.dno 별칭 사용 => 오류
from employee e NATURAL JOIN department d --별칭 사용으로 오류 발생 안 함
WHERE eno=7788;


select eno, ename, dno, dname 
from employee NATURAL JOIN department
WHERE eno=7788;



--[방법 4 : join ~ using]
--조인 결과는 중복된 컬럼 제거
--동일한 이름과 유형을 가진 컬럼으로 조인 (★조인시 1개 이상 사용 가능)


select 컬럼명 1, 컬럼명 2... 
from 테이블 1 JOIN 테이블 2 --별칭 사용 안 함 (권장)
USING(★조인조건) --USING(동일한 컬럼명1, 동일한 컬럼명2)
where ★검색조건


--[문제해결]
select eno, ename, d.dno, dname --별칭 사용하면 오류 발생
from employee e JOIN department d
USING(dno)
WHERE eno=7788;

select eno, ename, dno, dname --별칭 사용하면 오류 발생
from employee e JOIN department d
USING(dno)
WHERE eno=7788;