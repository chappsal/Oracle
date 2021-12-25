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
				


--[문제] 회사 전체에서 최소 급여를 받는 사원의 이름, 담당업무(job), 급여 조회

--[1] 최소 급여 구하기
select min(salary)
from employee;
				
--[2] 구한 최소급여(800)를 받는  사원의 이름, 담당업무(job), 급여 조회
select ename, job, salary
from employee
where salary = (select min(salary)
				from employee); --서브쿼리 결과 1개 : 단일 서브쿼리
--where salary = 800;
				
				
select ename, job, salary
from employee
where salary in(select min(salary)
				from employee);
--where salary in(800);
				

				
				
--2.다중 행 서브쿼리
--1. in 연산자 : 메인쿼리의 비교 조건에서 서브쿼리의 출력 결과와 '하나라도 일치하면'
--				메인쿼리의 where절이 true

--★단일 또는 다중 행 서브쿼리 둘 다 사용 가능
				
--[문제] ★★★부서별 최소 급여를 받는 사원의 부서번호, 사원번호, 이름, 최소 급여 조회
--[방법 1]
--[1] 부서별 최소 급여 구하기
select min(salary)
from employee
group by dno; --최종결과라면 무의미함 
		

--[2] 부서별 최소 급여를 받는 사원의 부서번호, 사원번호, 이름, 최소 급여 조회
select dno, eno, ename, salary
from employee
where (dno,salary) in (select min(salary) --in(1300,800,950)
						from employee
						group by dno)
order by 1;

--[방법 2]
--[1] 부서별 최소 급여 구하기
select dno, min(salary)
from employee
group by dno --(10,1300)(20,800),(30,950)

--[2-1] 서브쿼리 이용 
--★★★부서별 최소 급여를 받는 사원의 부서번호, 사원번호, 이름, 최소 급여 조회
select dno, eno, ename, salary
from employee
where (dno,salary) in (select dno, min(salary) --in( (10,1300)(20,800),(30,950) )
						from employee
						group by dno)
order by 1;
				
				
--[2-2] join 방법 1 이용
select d1.dno, eno, ename, salary
from employee e1, (select dno, min(salary)
					from employee
					group by dno) e2
where e1.dno = e2.dno 
and salary = min(salary)
order by e1.dno;
				
				
--[2-3] 조인 방법 2 이용 
select d1.dno, eno, ename, salary
from employee e1 join (select dno, min(salary as "minSalary")
						from employee
						group by dno) e2
on e1.dno, e2.dno
where salary ="minsalary"
order by e1.dno
				

--[2-4] 조인 방법 3 이용 : dno로 자연 조인 => 조인 조건 필요 x, 중복 제거=> 별칭 x
select dno, eno, ename, salary
from employee natural join (select dno, min(salary) as "minSalary"
							from employee 
							group by dno)
where salary = "minSalary"
order by dno;
				
------------------------------------------------------------------------------
--[위 문제 방법 1 쿼리에서 min(salary) 출력하려면]
select dno, eno, ename, salary, min(salary) --그룹함수 출력 하려면
from employee
where salary in (select min(salary) --in(1300,800,950)
		 		 from employee
				 group by dno)
group by dno, eno, ename, salary --group by절 뒤에 반드시 출력할 컬럼 나열(그룹함수 제외)
order by 1;


select dno, eno, ename, salary, min(salary) --그룹함수 출력 하려면
from employee
where salary in (1300,800,950)
group by dno, eno, ename, salary --group by절 뒤에 반드시 출력할 컬럼 나열(그룹함수 제외)
order by 1;


select dno, min(salary) -- 14:1
from employee; --오류: 전체 사원 테이블이 대상이면 group by 사용 안 함 (전체가 하나의 그룹이므로)





--[위 문제 방법 1 쿼리를 도출하기 위해 단계적으로 실행]

select min(salary) -- 전체 사원 테이블이 1그룹 => 1:1
from employee; 

select dno, min(salary) -- 3:3
from employee
group by dno; 

select dno, eno, ename, salary, min(salary) 
from employee
group by dno, eno, ename, salary
order by 1; 

select dno, eno, ename, salary, min(salary) -- 3:3
from employee
where salary in (1300, 800, 950)
group by dno, eno, ename, salary
order by 1; 


select dno, eno, ename, salary, min(salary) -- 3:3
from employee
where salary in (select min(salary) --in (1300, 800, 950)
				from employee
				group by dno)
group by dno, eno, ename, salary
order by 1; 
---------------------------------------------------------------------------------------------------
--2) ANY연산자 : 서브 쿼리가 변환하는 각각의 값과 비교
--where 컬럼명   = any(서브쿼리의 결과 1, 결과2...) => 결과들 중 아무거나와 같다
--where 컬럼명  in any(서브쿼리의 결과 1, 결과2...) => 결과들 중 아무거나와 같다

--정리 : A조건  or B조건 
--where 컬럼명  < any(서브쿼리의 결과 1, 결과2...) => 결과들 중 최대값보다 작다 
--where 컬럼명  > any(서브쿼리의 결과 1, 결과2...) => 결과들 중 최소값보다 크다



--[문제] ★★★부서별 최소 급여를 받는 사원의 부서번호, 사원번호, 이름, 최소 급여 조회
--[2-5] any 이용
--[1] 부서별 최소 급여 구하기
select dno, min(salary)
from employee
group by dno; 
		

--[2] 부서별 최소 급여를 받는 사원의 부서번호, 사원번호, 이름, 최소 급여 조회
select dno, eno, ename, salary
from employee
where (dno,salary) = any (select dno, min(salary) --in(1300,800,950)
						from employee
						group by dno)
order by 1;


--정리 : where (dno, salary) = any((10,1300), (20,800), (30,950))
--	   where (dno, salary)    in((10,1300), (20,800), (30,950))
--		서브쿼리의 결과 중 아무거나와 같은 것


--정리 : where salary != any(1300, 800, 950)
--	   where salary <> any(1300, 800, 950)
--	   where salary ^= any(1300, 800, 950)

--	   where salary not in(1300, 800, 950)
--	       서브쿼리의 결과 중 어느 것도 아니다

--정리 : where salary < any(1300, 800, 950) 서브쿼리의 결과 중 '최대값(1300)'보다 작다
--	   where salary > any(1300, 800, 950) 서브쿼리의 결과 중 '최소값(800)'보다 크다

--(ex.1)
select eno, ename, salary
from employee
where salary < any (1300,800,950)
order by 1;

--(ex.2)
select eno, ename, salary
from employee
where salary > any (1300,800,950)
order by 1;
