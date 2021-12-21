--북스-7장-서브쿼리

--[문제]'SCOTT'보다 급여를 많이 받는 사원 조회
--[1] 우선 'SCOTT'의 급여를 알아야 함
select ename, salary
from EMPLOYEE
where ename='SCOTT'; --3000

--[2] 해당 급여 3000보다 급여가 많은 사원 검색
select ename, salary
from employee
where salary > 3000;

--[2] 메인쿼리 - [1] 서브쿼리
select ename, salary
from employee
where salary > (select ename, salary
				from EMPLOYEE
				where ename='SCOTT'; --3000);
				--서브쿼리에서 실행한 결과 (3000)가 메인쿼리에 전달되어 최종 결과 출력
	
--서브쿼리의 종류

--1)단일 행 서브쿼리 : 내부 서브 쿼리문의 결과가 행 '1개'
--				 단일행 비교연산자(>,=,<=),   IN연산자
--				ex. salary > 3000     salary = 3000 (= salary IN(3000))
										
				
				
--2)다중 행 서브쿼리 : 내부 서브 쿼리문의 결과가 행 '여러 개'
--				 다중행 비교연산자 (IN, any, some, all, exists)				
--				ex. IN(1000,2000,3000) 


				
--1. 단일 행 서브쿼리
--[문제] 'SCOTT'과 동일한 부서에서 근무하는 사원 이름, 부서번호 조회

--[1] 우선 'SCOTT'의  부서 알기
select dno
from employee 
where ename='SCOTT';
				
--[2] 해당 부서 번호와 같은 사원 이름, 부서 번호 조회
select ename, dno
from employee
where dno = (select dno
 			 from EMPLOYEE
 			 where ename='SCOTT'); --서브쿼리 결과 1개
 				
select ename, dno
from employee
where dno IN (select dno
 			  from EMPLOYEE
 			  where ename='SCOTT'); --서브쿼리 결과 여러개라도 가능
				
--위 결과에는 scott도 함께 조회 됨 => 제외시키기

select ename, dno
from employee
where dno = (select dno
 			 from EMPLOYEE
 			 where ename='SCOTT'); --서브쿼리 결과 1개
and ename != 'SCOTT'; --조건 추가

--위 sql문이 이렇게 실행됨
select ename, dno
from employee
where dno = 20
and ename != 'SCOTT'; --조건 추가
				