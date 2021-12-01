/*
26p~
'데이터베이스 사용자'는 '오라클 계정'과 같은 의미
<오라클에서 제공하는 사용자 계정>
1.sys : 시스템 유지, 관리, 생성 '모든 권한'. 오라클시스템 '총관리자'. sysdba권한
2.system : 생성된 DB운영, 관리. '관리자'계정. sysoper권한
3.hr : 처음 오라클 사용하는 사용자를 위해 실습위한 '교육용 계정'
*/

--3.2 데이터베이스 구축하기
--(1). 데이터베이스 생성
--(2). 사원정보와 사원이 소속된 부서 정보와 급여 정보 저장할 테이블 생성

--테이블 삭제
drop table employee; -- 자식테이블
drop table department; -- 부모테이블 
drop table salgrade;

--부서 정보--------------------------------------------------------------

--먼저, 부서정보 테이블을 만든다.(사원정보 테이블에서 참조하고 있으면)
create table department(
dno number(2) primary key,--부서번호를 기본키(=primary key:중복X, unique유일한)로.(Mysql : int)
dname varchar2(14),--부서명:가변크기(Mysql : varchar)
loc varchar2(13)--지역명
);

--부서정보 테이블에 데이터를 추가한다.
insert into department values(10,'ACCOUNTING','NEW YORK');
insert into department values(20,'RESEARCH','DALLAS');
insert into department values(30,'SALES','CHICAGO');
insert into department values(40,'OPERATIONS','BOSTON');

--부서정보 테이블 조회(모든 것:*)
select * from department;



--사원 정보-------------------------------------------------------------
--사원정보 테이블을 만든다.
create table employee(
eno number(4) primary key,--사원번호(기본키=PK:중복x,유일)
ename varchar2(10),--사원명
job varchar2(9),--업무명
manager number(4),--해당 사원의 상사번호
hiredate date,--입사일
salary number(7,2),--급여(실수:소수점을 포함한 전체 자리수, 소수점 이하 자리)
commission number(7,2),--커미션
dno number(2) references department--부서번호(외래키=참조키=FK)
-- department 테이블에서는 dno 가 반드시 기본키로 존재해야 한다.
);


--INSERT INTO EMPLOYEE VALUES
--(7000,'KIM','CLERK', 7902,'1980-12-17',800,NULL,20);

--INSERT INTO EMPLOYEE VALUES
--(7001,'LEE','CLERK', 7902,'1980/12/17',800,NULL,20);



INSERT INTO EMPLOYEE VALUES
(7369,'SMITH','CLERK', 7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7499,'ALLEN','SALESMAN', 7698,to_date('20-2-1981', 'dd-mm-yyyy'),1600,300,30);
INSERT INTO EMPLOYEE VALUES
(7521,'WARD','SALESMAN',  7698,to_date('22-2-1981', 'dd-mm-yyyy'),1250,500,30);
INSERT INTO EMPLOYEE VALUES
(7566,'JONES','MANAGER',  7839,to_date('2-4-1981',  'dd-mm-yyyy'),2975,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981', 'dd-mm-yyyy'),1250,1400,30);
INSERT INTO EMPLOYEE VALUES
(7698,'BLAKE','MANAGER',  7839,to_date('1-5-1981',  'dd-mm-yyyy'),2850,NULL,30);
INSERT INTO EMPLOYEE VALUES
(7782,'CLARK','MANAGER',  7839,to_date('9-6-1981',  'dd-mm-yyyy'),2450,NULL,10);
INSERT INTO EMPLOYEE VALUES
(7788,'SCOTT','ANALYST',  7566,to_date('13-07-1987', 'dd-mm-yyyy'),3000,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7839,'KING','PRESIDENT', NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO EMPLOYEE VALUES
(7844,'TURNER','SALESMAN',7698,to_date('8-9-1981',  'dd-mm-yyyy'),1500,0,30);
INSERT INTO EMPLOYEE VALUES
(7876,'ADAMS','CLERK',    7788,to_date('13-07-1987', 'dd-mm-yyyy'),1100,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7900,'JAMES','CLERK',    7698,to_date('3-12-1981', 'dd-mm-yyyy'),950,NULL,30);
INSERT INTO EMPLOYEE VALUES
(7902,'FORD','ANALYST',   7566,to_date('3-12-1981', 'dd-mm-yyyy'),3000,NULL,20);
INSERT INTO EMPLOYEE VALUES
(7934,'MILLER','CLERK',   7782,to_date('23-1-1982', 'dd-mm-yyyy'),1300,NULL,10);


--사원정보 테이블 조회
SELECT * FROM EMPLOYEE;



--급여 정보---------------------------------------------------------------------------------
--급여정보 테이블을 만든다.
create table salgrade(
grade number,--급여 등급
losal number ,--급여 하한값
hisal number--급여 상한값
);



--데이터 추가
insert into salgrade values(1, 700, 1200);
insert into salgrade values(2, 1201, 1400);
insert into salgrade values(3, 1401, 2000);
insert into salgrade values(4, 2001, 3000);
insert into salgrade values(5, 3001, 9999);
--insert into salgrade values(6, 100, null);



--조회(*모든 것)
select * from salgrade;



select ename, salary, salary*12
from employee
where ename='SMITH'; --where로 원하는 것만 조회
-- sql = 같다 (자바에서 같다 ==)



/*
 * 산술 연산에 null을 사용하는 경우에는 특별한 주의가 필요함
 * null은 '미확정', '알 수 없는 값'의 의미 이므로 '연산,할당,비교가 불가능
 */


--커미션을 더한 연봉 구하기

select ename, salary, commission, salary*12+commission
from employee; 
--null은 연산이 안 되는 문제 발생, commission이 null이면 결과도 null 



--Nvl()함수 사용하여 위의 문제 해결

--NVL(값,0) : 값이 null이면 0으로 변경 , null이 아니면 원래 값을 사용 (자주 씀)

select ename, salary, commission, salary*12+NVL(commission, 0)
from employee;



/* 별칭
 * 1. 컬럼명 별칭
 * 2. 컬럼명 as 별칭
 * 3. 컬렴명 as "별 칭"
 * 
 * 별칭에 공백, 특수문자 추가, 대소문자를 구분하려면 큰 따옴표로 묶어줘야 함 
 * */


select ename 사원이름, salary as "급 여", commission as "Cms", salary*12+NVL(commission, 0) as "연봉+커미션"
from employee;


--distinct:중복된 데이터를 한번만 표시
select distinct dno--부서번호
from employee;


/* dual : 가상 테이블, 결과값을 1개만 표시하고 싶을 때 사용
 * */

--sysdate:컴퓨터로부터 오늘 날짜 (주의! 괄호 없음)
select sysdate from employee; --14행이면 14행 출력
select sysdate from dual; --오늘 날짜 한 번만 출력