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

--equi join (=등가조인=동일조인) : 동일한 이름과 유형(=데이터 타입)을 가진 컬럼으로 조인
--			    			단, [방법1: ~where]과  [방법 2: join~on]은 데이터 타입만 같아도 조인 됨



--[방법 1. , ~where]
--동일한 이름과 데이터 유형을 가진 컬럼으로 조인 + "임의의 조건을 지정"하거나 "조인할 컬럼을 지정"할 때 where절을 사용
--조인결과는 중복된 컬럼 제거x => 따라서 테이블에 '별칭 사용'해서 어느 테이블의 컬럼인지 구분해야 함

select 컬럼명 1, 컬럼명 2... -- 중복되는 컬럼은 반드시 '별칭.컬럼명' ex) e.dno
from 테이블 1, 테이블 2 --별칭 사용
where ★조인조건 (주의 : 테이블의 별칭 사용)
and   ★검색조건
--★문제점 : 원하지 않는 결과가 나올 수 있다 (이유? and -> or의 우선 순위 때문에)
--★문제점 해결법 : AND 검색조건 에서 괄호()를 사용해 우선 순위 변경
--예) 부서번호로 조인한 후 부서번호가 10이거나 40인 정보 조회
--where e.dno=d.dno AND d.dno=10 OR d.dno=40; --문제 발생
--where e.dno=d.dno AND (d.dno=10 OR d.dno=40); --★해결법: 괄호()로 우선 순위 변경

--★★★[장점] 이 방법은 outer join하기가 편리
select *
from employee e, department d
where e.dno(+)=d.dno; --두 테이블에서 같은 dno끼리 조인(부서 테이블의 40은 표시 안 됨. 따라서 (+) 붙여 outer join한다)

select *
from employee e RIGHT OUTER JOIN department d --오른쪽 부서 테이블의 40도 표시
ON e.dno=d.dno;

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


----------------------------------------------------------[방법 1]과 [방법 2]는 문법적 특징이 동일
----------------------------------------------------------				  의 조인 결과 : 중복된 컬럼 제거 x => 테이블에 별칭 붙임
----------------------------------------------------------   	                    ★ 데이터 타입만 같아도 join 가능 (ex) a.id=b.id2
-----[테스트 위해 간단하게 테이블 생성하여 4가지 방법 비교]--------------------------------------------------------------
drop table A;
drop table B;

create table A(
id number(2) primary key, --아이디
name varchar2(20), --이름
addr varchar2(100) --주소
);

insert into A values(10,'유재훈','대구 달서구');
insert into A values(20,'노석찬','대구 북구');


create table B(
id2 number(2) primary key, --아이디
tel varchar2(20) --연락처
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

--방법 3
select *
from A NATURAL JOIN B ; --별칭 사용x
--결과: id와 id2는 이름이 다르므로 cross join결과와 같다


select * from A,B --cross join
select * from A join b --오류 발생(join~반드시 on + 조인조건)

--방법 4
select *
from A join B
using(id); -- 오류발생 : using(같은 컬럼명) id와 id2는 이름이 달라서 조인 안 됨





--테스트 위해
--B2 테이블 생성

create table B2(
id number(2) primary key, --아이디(A와 B2의 아이디가 같다)
tel varchar2(20)
);


insert into B2 values(10,'010-1111-1111');
insert into B2 values(30,'010-3333-3333');


--C 테이블 생성
drop table C;

create table C(
id number(2) primary key,--아이디(A와 B2,C의 아이디가 같다)
gender char(1) --M 또는 F ('남' '여'는 추가 안 됨. why? 1 바이트 보다 커서)
);

insert into C values(10, 'M');
insert into C values(20, 'M');
insert into C values(30, 'F');
insert into C values(40, 'F');


--C2 테이블 생성
create table C2(
tel varchar2(20) not null, --연락처(B2와 같다) , not null=null 값을 허용하지 않음
hobby varchar2(20) --취미
);

insert into C2 values('010-1111-1111', '');
insert into C2 values('010-2222-2222', '축구');
insert into C2 values('010-3333-3333', '영화감상');




--[문제] 3개의 테이블 조인


--방법 1
--나머지 모두 표시하는 방법 2 (=방법1)

--방법 2
--나머지 모두 표시하는 방법 1 : outer join 사용 (=방법2)

--방법 3
select *
from A NATURAL JOIN B2 NATURAL JOIN C; --별칭 사용x
--세 테이블 모두 id가 있으므로 id로 조인
--먼저 A와 B2가 id로 조인 -> 조인된 결과 테이블의 id와 C의 id로 조인


--[문제] id, 이름, 주소, 연락처, 취미 구하기

--방법 3으로 구하는 법
select id, name, addr, tel, hobby
from A natural join B2 natural join C2;
--A와 B2 테이블은 id로 조인 => 결과 테이블과 C2테이블과 tel로 조인 됨


--[문제] id, 이름, 주소, 연락처, 취미 구하기
--위 문제의 결과에 추가로 나머지 모두 표시하는 방법-1 : outer join 사용 [방법-2]
--[1]
select a.id, name, addr, tel
from A a join B2 b2 
on a.id=b2.id;

--[2] 위 결과와 같다.
SELECT id, name, addr, c2.tel, hobby --tel 반드시 별칭 사용
FROM (select a.id, name, addr, tel
	  from A a join B2 b2 
	  on a.id=b2.id) ab2 JOIN C2  c2
ON ab2.tel=c2.tel;

--[3] outer join 이용하여 표시되지 않은 부분도 다 표시하기
--------------------------------------------------
select a.id, b2.id, name, addr, tel --a.id(10 20), b2.id(10 30)의 결과가 다르다.
from A a FULL OUTER JOIN B2 b2 --두 테이블에 표시되지 않은 부분 다 표시됨 
on a.id=b2.id; --★★중복제거안함


select ab2.id, name, addr, c2.tel, hobby --오류발생:ab2.id는 a.id, b.id 2개 중 어느 것인지 구분이 안 됨
from (select a.id, b2.id, name, addr, tel
	  from A a FULL OUTER JOIN B2 b2 --두 테이블에 표시되지 않은 부분 다 표시됨 
	  on a.id=b2.id) ab2 FULL OUTER	JOIN C2 c2
ON ab2.tel=c2.tel;


--방법 4
select *
from A join B
using(id); -- 오류발생 : using(같은 컬럼명) id와 id2는 이름이 달라서 조인 안 됨

--[1]
select id, name, addr, tel
from A join B2 --join using : ★중복 제거하므로 별칭 필요 x
using(id);  
--[2] 위 결과와 같다.
select id, name, addr, tel, hobby --tel 별칭 사용 불가
from (select id, name, addr, tel --id 별칭 사용 불가
	  from A join B2 --join using : 중복 제거 => 별칭 필요 x
      using(id)) join C2
USING(tel);

----위 문제의 결과에 추가로 나머지 모두 표시하는 방법 2 : [방법 4] outer join 이용
--[3]
select id, name, addr, tel --id(10 20 30)
from A FULL OUTER JOIN B2 : 중복 제거 => 별칭 필요 x
using(id); --★★중복 제거하므로 하나의 id 컬럼 값으로 합쳐짐

select id, name, addr, tel, hobby
from (select id, name, addr, tel
   	  from A FULL OUTER JOIN B2 --★★중복제거하므로 별칭 필요없음
	  using(id)) FULL OUTER JOIN C2
USING(tel);



--위 결과에서 'id가 없는 사람 제외'하여 출력
select id, name, addr, tel, hobby
from (select id, name, addr, tel
	 from A FULL OUTER JOIN B2 --★★중복제거하므로 별칭 필요없음
	 USING(id)) FULL OUTER JOIN C2
USING(tel)
WHERE id is not null;



----위 문제의 결과에 추가로 나머지 모두 표시하는 방법 3 : , where => 결과 도출 못 함(이유? (+)를 양쪽에 사용할 수 없다) (=방법1)
--[1]
select a.id, name, addr, tel
from A a , B2 b2 
where a.id=b2.id;

--[2] 위 결과와 같다.
SELECT id, name, addr, c2.tel, hobby --tel 반드시 별칭 사용
FROM (select a.id, name, addr, tel
	  from A a , B2 b2 
	  where a.id=b2.id) ab2 , C2 c2
where ab2.tel=c2.tel;

--[3] (+) 이용하여 표시되지 않은 부분도 다 표시하기 -> 안 됨
select a.id, b2.id, name, addr, tel--a.id(10 20), b.id(10)
from A a , B2 b2
where b2.id(+)=a.id; --더하기가 없는 테이블의 모든 부분 표시

select a.id, b2.id, name, addr, tel--a.id(10 20), b.id(10)
from A a , B2 b2 
where b2.id=a.id(+); --더하기가 없는 쪽 테이블의 모든 부분 표시

select a.id, b2.id, name, addr, tel --오류
from A a , B2 b2 
where a.id(+)=b2.id(+); --★★★주의 : 양쪽 안 됨(오류) => 따라서, full outer join~on 또는 using으로 해결해야 함

select id, name, addr, c2.tel, hobby --ab2.id 오류발생(ab2에 id가 2개이므로)
from(select a.id, b2.id, name, addr, tel --a.id(10), b2.id(10 30)
	from A a, B2 B2	
	where a.id(+)=b2.id) ab2, c2 c2
where ab2.tel(+)=c2.tel;


--[문제 수정] : 아이디(id)가 존재하는 고객만 모두 표시 => (+)이용하여 문제 해결 못 함 -> full outer join~on 또는 using으로 해결해야 함
select a.id, b.id, name, addr, tel
from A a ,B2 b2 --★★★주의 : 양쪽 안 됨(오류)
where a.id(+)=b2.id(+)) -- 10 20(A) 10 30(B2)



-----[테스트 위해 간단하게 테이블 생성하여 4가지 방법 비교]--------------------------------------------------------------

----------------------------------------------------------[방법 3] : 컬럼명이 다르면 cross join 결과가 나옴 
----------------------------------------------------------[방법 4] : 컬럼명이 다르면 join 안 됨(오류 발생)

--[방법 3 : natural join]
--조인 결과는 중복된 컬럼 제거
--"자동으로" 동일한 이름과 데이터 유형을 가진 컬럼으로 조인 (★ 단, 1개만 있을 때 사용하는 것을 권장)
--동일한 이름과 데이터 유형을 가진 컬럼이 없으면 CROSS JOIN 됨
--★★ 자동으로 조인 되나 문제 발생할 수 있음
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


select eno, ename, dno, dname --dno만 별칭 사용안됨
from employee e NATURAL JOIN department d
WHERE eno=7788;

select eno, ename, dno, dname 
from employee  NATURAL JOIN department 
WHERE eno=7788;



--[방법 4 : join ~ using(반드시 '동일한 컬럼명'만 가능)] ★다르면 오류 발생
--조인 결과는 중복된 컬럼 제거 -> 제거한 결과에 full outer join~using(동일한 컬럼명)하면 하나의 컬럼으로 합쳐짐
--동일한 이름과 유형을 가진 컬럼으로 조인 (★조인시 1개 이상 사용할 때 편리:가독성이 좋아서)


select 컬럼명 1, 컬럼명 2... 
from 테이블 1 JOIN 테이블 2 --별칭 사용 안 함 (권장)
USING(★조인조건) --USING(동일한 컬럼명1, 동일한 컬럼명2)
where ★검색조건


--[문제해결]
select eno, ename, d.dno, dname --별칭 사용하면 오류 발생
from employee e JOIN department d
USING(dno)
WHERE eno=7788;

select eno, ename, dno, dname --dno:별칭 사용하면 오류 발생하여 별칭 제거
from employee e JOIN department d
USING(dno)
WHERE eno=7788;

--★★만약 manager가 department에 있다고 가정 후 아래 결과 유추
select eno, e.manager_id, dno, d.manager --별칭 사용하여 반드시 구분 
from employee e JOIN department d --manager_id를 출력하려면 반드시 별칭 사용
USING(dno) -- dno만 중복 제거(★manager는 중복 제거 안 됨)
WHERE eno=7788;


--여러 테이블 간 조인할 경우 natural join과 join ~ using을 이용한 조인 모두 사용 가능하나
--가독성이 좋은 join ~ using을 이용하는 방법을 권한다.



----------------------------------------------------------[방법 3] : 컬럼명이 다르면 cross join 결과가 나옴 
----------------------------------------------------------[방법 4] : 컬럼명이 다르면 join 안 됨(오류 발생)


------------------------------<4가지 정리 끝>-----------------------------------------------------------------


--3. non-equi join=비등가조인 : 조인조건에서 '=(같다)연산자 이외'의 연산자를 사용할 때
--							ex. != > < <= >= between~and


--[문제] 사원별로 '사원이름, 급여, 급여 등급'출력

--[1] 급여 등급 테이블 출력
select * from salgrade;
select * from employee;

--[2] 사원별로 '사원이름, 급여, 급여 등급'출력

-- 사원 이름, 급여 : 사원 테이블
-- 급여 등급 : 급여 정보 테이블
select ename, salary, grade
from employee join salgrade --별칭 사용 안 함(이유: 중복되는 컬럼 없음)
on salary between losal and hisal; --비등가 조인 조건


--[문제] 사원별로 '사원이름, 급여, 급여 등급'출력 + [조건 추가] 급여가  1000 미만이거나 2000 초과하는 사람만 출력
--[방법 2] 사용
select ename, salary, grade
from employee join salgrade --별칭 사용 안 함(이유: 중복되는 컬럼 없음)
on losal <= salary and salary <= hisal
where salary < 1000 or salary > 2000; --검색 조건 추가


--[방법 1] 사용 : 정확한 결과 출력 x (why? and , or 함께 있으면 and 우선 실행 됨) 
-- => 해결 : 괄호 사용하여 우선 순위 변경
select ename, salary, grade
from employee, salgrade
where losal <= salary and salary <= hisal
and salary < 1000 or salary > 2000;

-- 위 문제 해결
select ename, salary, grade
from employee, salgrade
where losal <= salary and salary <= hisal
and (salary < 1000 or salary > 2000);


--[문제] 3개의 테이블 조인하기
--'사원 이름, 소속된 부서 번호, 소속된 부서명, 급여, 등급' 조회

--사원 이름, 급여, 소속된 부서 번호 : 사원 테이블
--소속된 부서명, 소속된 부서 번호 : 부서 테이블
--등급 : 급여 정보 테이블

--사원 테이블과 부서 테이블의 공통 칼럼 : dno(부서 번호)

--[1] 사원 테이블과 부서 테이블은 '등가 조인' => 같은 칼럼이 있어서
--[방법-1] 사용
select ename, e.dno, dname, salary
from employee e, department d
where e.dno=d.dno;

--[방법-2] 사용
select ename, e.dno, dname, salary
from employee e join department d
on e.dno=d.dno;


--[2] 등가 조인한 결과 테이블과 급여 정보 테이블은 '비등가 조인' => 같은 칼럼이 없어서
select ename, dno, dname, salary, grade --별칭 사용x
from salgrade join (select ename, e.dno, dname, salary
					from employee e join department d
					on e.dno=d.dno)
on salary between losal and hisal; --비등가 조인

---------------------------------------------------------------------------------비등가 조인 끝


--4. self join : 하나의 테이블에 있는 컬럼끼리 연결해야 하는 조인이 필요한 경우
select * from employee;

--[문제] 사원 이름과 직속 상관 이름 조회
select *
from employee e join employee m --반드시 별칭 사용
on e.manager = m.eno --'KING'은 직속 상관이 없으므로(null) 등가 조인에서 제외
order by 1;

select e.ename as "사원 이름", m.ename as "직속 상관 이름"
from employee e join employee m --반드시 별칭 사용
on e.manager = m.eno --'KING'은 직속 상관이 없으므로(null) 등가 조인에서 제외
order by 1;

select e.ename || '의 직속 상관은 ' || m.ename 
from employee e join employee m --반드시 별칭 사용
on e.manager = m.eno --'KING'은 직속 상관이 없으므로(null) 등가 조인에서 제외
order by 1;


--'SCOTT' 사원의 '매니저 이름'(=직속 상관) 검색
select e.ename || '의 직속 상관은 ' || m.ename
from employee e join employee m
on e.manager = m.eno
where e.ename = 'SCOTT';


select e.ename || '의 직속 상관은 ' || m.ename
from employee e join employee m
on e.manager = m.eno
where LOWER(e.ename) = 'scott';
--e.ename의 값을 모두 소문자로 변경 후 'scott'과 같은 것 찾기

-------------------------------------------------------------------------------------------

--5. outer join
--equi join(등가 조인)의 조인 조건에서 기술한 컬럼에 대해 두 테이블 중  어느 한쪽 컬럼이라도
--null이 저장되어 있으면 '='의 비교 결과가 거짓이 된다
--그래서 null값을 가진 행은 조인 결과로 얻어지지 않음

select e.ename || '의 직속 상관은 ' || m.ename
from employee e join employee m --반드시 별칭 사용
on e.manager = m.eno; --조인 조건('KING'은 직속 상관이 없으므로(null) 등가 조인에서 제외 => 결과 x)

select e.ename || '의 직속 상관은 ' || m.ename
from employee e join employee m 
on e.manager = m.eno -- 조인 조건 : null은 비교 연산자(= > !=)로 비교 불가
where e.ename = 'KING'; --오류는 없지만 검색 결과가 없음
--사원 이름이 'KING' 검색


select e.ename || '의 직속 상관은 ' || m.ename
from employee e join employee m
on e.manager = m.eno
where m.ename = 'KING'; --오류는 없지만 검색 결과가 없음
--직속 상관 이름이 'KING' 검색 => 3명 출력


--위 방법으로는 null값 표현 불가. 아래 방법으로 해결
--[방법 -1] null값도 표현하기 위한 해결 방법 : 조인 조건에서 null값을 출력하는 곳에 (+) 붙임
--주의 : (+)도 한쪽만 사용 가능(left or rifht) , full 안 됨
select e.ename || '의 직속 상관은 ' || nvl(m.ename, '없다.')
from employee e , employee m --반드시 별칭 사용
where e.manager=m.eno(+);



--[방법 -2] null값도 표현하기 위한 해결 방법 : (lefr/right/full) outer join 
select e.ename || '의 직속 상관은 ' || nvl(m.ename, '없다.')
from employee e left outer join employee m --반드시 별칭 사용
on e.manager=m.eno;



--<6장. 테이블 조인하기-혼자해보기>------------------------------------------------------------------------------


/*
 * 1.EQUI 조인을 사용하여 SCOTT 사원의 부서번호와 부서이름을 출력하시오.
 */






/*
 * 2.(INNER) JOIN과 ON 연산자를 사용하여 사원이름과 함께 그 사원이 소속된 부서이름과 지역명을 
 * 출력하시오.
 */

/*
 * 3.(INNER) JOIN과 USING 연산자를 사용하여 10번 부서에 속하는 모든 담당 업무의 고유 목록
 * (한 번씩만 표시)을 부서의 지역명을 포함하여 출력하시오.
 */

/*
 * 4.NATURAL JOIN을 사용하여 커미션을 받는 모든 사원의 이름, 부서이름, 지역명을 출력하시오.
 */

/*
 * 5.EQUI 조인과 WildCard를 사용하여 이름에 A가 포함된 모든 사원의 이름과 부서이름을 출력하시오.
 */

/*
 * 6.NATURAL JOIN을 사용하여 NEW YORK에 근무하는 모든 사원의 이름, 업무, 부서번호, 부서이름을 
 * 출력하시오.
 */

/*
 * 7.SELF JOIN을 사용하여 사원의 이름 및 사원번호를 관리자 이름 및 관리자 번호와 함께 출력하시오.
 */

/*
 * 8.'7번 문제'+ OUTER JOIN, SELF JOIN을 사용하여 '관리자가 없는 사원'을 포함하여 사원번호를
 * 기준으로 내림차순 정렬하여 출력하시오.
 */

/*
 * 9.SELF JOIN을 사용하여 지정한 사원의 이름('SCOTT'), 부서번호, 지정한 사원과 동일한 부서에서 
 * 근무하는 사원이름을 출력하시오.
 * 단, 각 열의 별칭은 이름, 부서번호, 동료로 하시오.
 */

/*
 * 10.SELF JOIN을 사용하여 WARD 사원보다 늦게 입사한 사원의 이름과 입사일을 출력하시오.
 * (입사일을 기준으로 오름차순 정렬)
 */

/*
 * 11.SELF JOIN을 사용하여 관리자보다 먼저 입사한 모든 사원의 이름 및 입사일을 
 * 관리자 이름 및 입사일과 함께 출력하시오.(사원의 입사일을 기준으로 정렬)
 */








