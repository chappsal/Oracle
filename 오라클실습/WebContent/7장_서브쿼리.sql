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
										
				
				
--2)다중 행 서브쿼리 : 내부 서브 쿼리문의 결과가 행 '1개 이상'
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
-- 결국 salary > 800의 범위가 나머지 범위를 다 포함함


--[문제] 직급이 SALESMAN이 아니면서 
--급여가 임의의 SALESMAN 보다 낮은 사원의 정보(사원이름, 직급, 급여) 출력
--    (임의의=각각)

--[1]. 직급 SALESMAN 급여 구하기
select distinct salary --중복된 값 제외
from employee
where job = 'SALESMAN'; 

--[2]. 
select ename, job, salary
from employee
where job != 'SALESMAN' and salary < any (select distinct salary
											from employee
											where job = 'SALESMAN'); 
-- salary < any (1300, 1250, 1500)의 서브 쿼리 결과 중 '최대값'보다 작다

--위 결과 검증
--[1]. SALESMAN 직급의 최대 급여 구하기
select max(salary)
from employee
where job='SALESMAN';

--[2].
select ename, job, salary
from employee
where job != 'SALESMAN' and salary < (select distinct max(salary)
										from employee
										where job = 'SALESMAN'); 
-- job ^= 'SALESMAN'
-- job <> 'SALESMAN'
-- job not loke 'SALESMAN'

------------------------------------------------------------------------
										
										
--3) ALL 연산자 : 서브 쿼리에서 반환되는 모든 값과 비교										
--정리 : A조건  and B조건   -여러 조건을 동시에 만족
--where salary > ALL(결과1, 결과2 ...) 쿼리 결과 중 '최대값'보다 크다
--where salary < ALL(결과1, 결과2 ...) 쿼리 결과 중 '최소값'보다 작다
			
										
										
--[문제] 직급이 SALESMAN이 아니면서 
--급여가 모든 SALESMAN 보다 낮은 사원의 정보(사원이름, 직급, 급여) 출력
--    (모든=모두 동시에 만족)

--[1]. 직급 SALESMAN 급여 구하기
select distinct salary --중복된 값 제외
from employee
where job = 'SALESMAN'; 

--[2]. 
select ename, job, salary
from employee
where job != 'SALESMAN' and salary < all (select distinct salary
											from employee
											where job = 'SALESMAN'); 
-- salary < all (1300, 1250, 1500)의 서브 쿼리 결과 중 '최소값'보다 작다

--위 결과 검증
--[1]. SALESMAN 직급의 최소 급여 구하기
select min(salary)
from employee
where job='SALESMAN';

--[2].
select ename, job, salary
from employee
where job != 'SALESMAN' and salary < (select distinct min(salary)
										from employee
										where job = 'SALESMAN'); 							

										
-------------------------------------------------------------------------
--4) EXISTS 연산자 : EXISTS=존재하다.
select
from
where EXISTS (서브쿼리);
--서브 쿼리에서 구해진 데이터가 1개라도 존재하면 true => 메인 쿼리 실행
-- 					 1개라도 존재하지 않으면 false => 메인 쿼리 실행x			

select
from
where NOT EXISTS (서브쿼리);
--서브 쿼리에서 구해진 데이터가 1개도 존재하지 않으면 true => 메인 쿼리 실행
-- 					 1개라도 존재하면 false => 메인 쿼리 실행x
										
							
--[문제-1] 사원 테이블에서 직업이 'PRESIDENT'가 있으면 모든 사원 이름을 출력, 없으면 출력 안 함
--★문제의 뜻 : 조건을 만족하는 사원이 있으면 메인 쿼리 실행하여 결과 출력

--[1] 사원 테이블에서 직업이 'PRESIDENT'인 사람의 사원 번호
select eno, job --7839
from employee
where job='PRESIDENT';

--[2] 
select ename
from employee
where EXISTS (select eno
				from employee
				where job='PRESIDENT');										
								
--위 문제를 테스트하기 위해 직업이 'PRESIDENT'인 사원 삭제 => [2]실행하면 결과 없음(오류x)
delete
from employee
where job='PRESIDENT';
			
--다시 되돌리기 위해 직업이 'PRESIDENT'인 사원 추가



--[위 문제에 job='SALESMAN' 추가함]
--조건을 AND 연결 : 두 조건이 모두 참이면 참
select ename
from employee
where job='SALESMAN' AND EXISTS (select eno
								 from employee
								 where job='PRESIDENT'); --4명 and 14명 => 4명							

--조건을  OR 연결 : 두 조건 중 하나만 참이면 참
select ename
from employee
where job='SALESMAN' OR EXISTS (select eno
								 from employee
								 where job='PRESIDENT'); --4명  or 14명 => 14명										
--[NOT EXISTS]																				
--조건을 AND 연결 : 두 조건이 모두 참이면 참
select ename
from employee
where job='SALESMAN' AND NOT EXISTS (select eno
								 	from employee
								 	where job='PRESIDENT'); --4명 and 0명 => 0명								

--조건을  OR 연결 : 두 조건 중 하나만 참이면 참
select ename
from employee
where job='SALESMAN' OR NOT EXISTS (select eno
								 	from employee
								 	where job='PRESIDENT'); --4명  or 0명 => 4명									
					
								 	
--[사원 테이블과 부서 테이블 모두 포함되는 것이 아닌 (한쪽에만 포함되는) 부서 번호, 부서 이름 조회] [과제 1] => dno 40출력

								 	
--방법 1 : exists 사용
--[1]		 
select dno, dname
from department d
where EXISTS (select 1 --dno대신 1 사용 가능
			  from employee e
			  where d.dno = e.dno);	
--[2]		  
select dno, dname
from department d
where not EXISTS (select dno --10 20 30
			  	  from employee --별칭 사용 안 해도 됨
			 	  where d.dno = dno);	
										
			 	  
--방법 2 : join 방법 1 사용
--[1]
select distinct e.dno, dname
from employee e, department d
where e.dno = d.dno; --10 20 30

--[2]
select distinct d.dno, dname --e.dno로 하면 10 20 30만 출력
from employee e, department d
where e.dno(+) = d.dno; --10 20 30 + 40까지 표시
			 	  
--[3]
select distinct d.dno, dname
from employee e, department d
whee e.dno(+) = d.dno and dno not in (select distinct dno
										from employee);
--[3-2]			 	  
select distinct d.dno, dname
from employee e, department d
whee e.dno(+) = d.dno and dno != all (select distinct dno
										from employee);
			 	  
--방법 3 : minus 이용
--[1]
select dno, dname
from department; -- 10 20 30 40

--[2]
select distinct e.dno, dname
from employee e, department d
where e.dno = d.dno; -- 10 20 30

--[3] {10 20 30 40} -{10 20 30} = {40}
select dno, dname
from department

minus

select distinct e.dno, dname
from employee e, department d
where e.dno = d.dno;
			 	  
			 	  
						 
--[문제-2] 사원 테이블에서 직업이 'PRESIDENT'가 없으면 모든 사원 이름을 출력, 있으면 출력 안 함
--★문제의 뜻 : 조건을 만족하는 사원이 있으면 메인 쿼리 실행하여 결과 출력

--[1] 사원 테이블에서 직업이 'PRESIDENT'인 사람의 사원 번호
select eno, job --7839
from employee
where job='PRESIDENT';

--[2] 
select ename
from employee
where not EXISTS (select eno
				  from employee
				  where job='PRESIDENT');										
								
										
										
										
--<7장.서브쿼리-혼자해보기>----------------------------------------------------------------------------------------

				  
--1.사원번호가 7788인 사원과 '담당업무가 같은' 사원을 표시(사원이름과 담당업무)

--[1]
select job
from employee
where eno=7788;

--[2]	
select ename, job
from employee
where job=(select job    -- = 대신 in , any, all 사용 가능
			from employee
			where eno=7788);
							  			  
		
				  
--2.사원번호가 7499인 사원보다 급여가 많은 사원을 표시(사원이름과 담당업무)

--[1]
select salary --1600
from employee
where eno=7499;
--[2]
select ename, job
from employee
where salary > (select salary
				from employee
				where eno=7499);
							
		
			
--3.최소급여를 받는 사원의 이름, 담당 업무 및 급여 표시(그룹함수 사용)

--[1]
select min(salary) --800
from employee;
--[2]
select ename, job, salary
from employee
where salary = (select min(salary)
				from employee);

			

--4.'직급별' 평균 급여가 가장 적은 담당 업무를 찾아 '직급(job)'과 '평균 급여' 표시
--단, 평균의 최소급여는 반올림하여 소수 1째 자리까지 표시

--[1]
select avg(salary), round(avg(salary),1) 
from employee;
--[2]

--사원 전체의 평균 급여 최소값 
select min(avg(salary))
from employee;
--오류: avg(salary) 출력 값은 1개이기 때문에 min max 값을 구하는 것은 모호함


--★★그룹함수 최대 2회까지 중첩 가능				
--round는 그룸함수 x
select round(min(avg(salary)),1) 
from employee
group by job;

--[2] 최종
select job, avg(salary), round(avg(salary),1)
from employee
group by job
having round(avg(salary),1) = (select round(min(avg(salary)),1)
								from employee
								group by job);



--5.각 부서의 최소 급여를 받는 사원의 이름, 급여, 부서 번호 표시

--[1]
select min(salary),dno
from employee
group by dno;
--[2]
select ename, salary, dno
from employee
where (salary,dno) in (select min(salary),dno
						from employee
						group by dno);




--6.'담당 업무가 분석가(ANALYST)인 사원보다 급여가 적으면서 업무가 분석가가 아닌' 
--사원들을 표시(사원번호, 이름, 담당 업무, 급여)

--[1]		
select min(salary) --3000
from employee
where job='ANALYST';
--[2]
select eno, ename, job, salary
from employee
where job != 'ANALYST' and salary < (select min(salary) 
									 from employee
									 where job='ANALYST');

--[2-2]
select eno, ename, job, salary
from employee
where salary < any (select min(salary) 
				 	from employee
				 	where job='ANALYST')
	and job != 'ANALYST';		
									 
						
--★★7.부하직원이 없는 사원이름 표시(먼저 '문제 8. 부하직원이 있는 사원이름 표시'부터 풀기)

select ename
from employee
where eno not in ( select distinct manager
					from employee
					where manager is not null);
									 
									 
									 
									 
--★★8.부하직원이 있는 사원이름 표시



--[1]
select manager
from employee;
--[2]
select ename
from employee
where eno in (select manager
			  from employee);
					 
									 
									 
									 
--9.BLAKE와 동일한 부서에 속한 사원이름과 입사일을 표시(단,BLAKE는 제외)

--[1]
select dno --30
from employee
where ename='BLAKE';
--[2]			  
select ename, hiredate
from employee
where ename!='BLAKE' and dno=(select dno    -- = 대신 in 사용 권장, 이름이 같은 사람이 또 있을 경우 대비
							  from employee
							  where ename='BLAKE');
			  
			  

--10.급여가 평균 급여보다 많은 사원들의 사원번호와 이름 표시(결과는 급여에 대해 오름차순 정렬)

--[1]
select avg(salary) --2073.xx
from employee;
--[2]						
select eno, ename, salary
from employee
where salary > (select avg(salary)	
				from employee)
order by salary;
							  
							  
							  
							  
							  
--11.이름에 K가 포함된 사원과 같은 부서에서 일하는 사원의 사원번호와 이름 표시

--[1]
select ename, dno
from employee
where ename like '%K%';
--[2]
select eno, ename
from employee
where dno in (select dno
			  from employee
			  where ename like '%K%');



--12.부서위치가 DALLAS인 사원이름과 부서번호 및 담당 업무 표시

--[1]
select *
from department
where loc = 'DALLAS'		
--[2]
select ename, dno, job
from employee
where dno in (select dno
			  from department
			  where loc = 'DALLAS');
			  
--[12번 변경 문제] 부서 위치가 DALLAS인 사원이름과 부서번호 , 담당 업무, 부서위치 표시  - 과제 1

select dno
from department
where loc = 'DALLAS';  

select ename, d.dno, job, loc
from employee e, department d
where e.dno=d.dno
and d.dno in (select dno
				from department
				where loc = 'DALLAS');
			  

--13.KING에게 보고하는 사원이름과 급여 표시

--[1]
select eno --7839
from employee
where ename = 'KING';	  
--[2]		  
select ename, salary
from employee
where manager = (select eno
				 from employee
				 where ename = 'KING');
			  
			  
			  
--14.RESEARCH 부서의 사원에 대한 부서번호, 사원이름, 담당 업무 표시

--방법 1
select dno, ename, job
from employee
where dno=20;
				 
--방법 2		
--[1]	 
select dno  --20
from department
where dname='RESEARCH';
--[2]	 
select dno, ename, job
from employee
where dno=(select dno  --20
			from department
			where dname='RESEARCH');



				 
--15.평균 급여보다 많은 급여를 받고 이름에 M이 포함된 사원과 같은 부서에서 근무하는 
--사원번호,이름,급여 표시

		
--[1] 평균 급여
select avg(salary)
from employee;

--[2] 이름에 M이 포함된 사원과 같은 부서번호
select distinct dno
from employee
where ename like '%M%';

--[3]
select eno, ename, salary, dno
from employee
where salary > (select avg(salary)
				from employee)
and dno in (select distinct dno
			from employee
			where ename like '%M%');

--[4] ★주의 : 이름에 M이 포함된 사원은 제외
select eno, ename,salary,dno
from employee
where salary > (select avg(salary)
				from employee)
and dno in (select distinct dno
			from employee
			where ename like '%M%')
and ename not like '%M%';




--16.평균 급여가 가장 적은 업무와 그 평균급여 표시

--[1] 업무별 평균 급여
select avg(salary), job
from employee
group by job;
--[2]

	
			
			
			
			
--17.담당 업무가 MANAGER인 사원이 소속된 부서와 동일한 부서의 사원이름 표시			

select ename
from employee
where dno in(select dno
 			 from employee
			 where job='MANAGER')
and job != 'MANAGER'