--이름이 SCOTT인 사원의 정보 출력
select * from employee
where ename='SCOTT'; --where 조건 '문자'

SELECT * FROM EMPLOYEE
WHERE ENAME='scott'; --문자값은 대소문자 구분함 -> 결과 없음

SELECT * FROM EMPLOYEE
WHERE ENAME='SCOTT'; --결과 나옴


--'1981년 1월 1일 이전에 입사'한 사원만 출력

select * from employee
where hiredate < '1981/01/01'; --오직 숫자만 있는 것이 아니라 문자도 함께 있으면 문자로 취급 -> 따옴표


--논리연산자
--10번 부서 소속 사원 중 직급이 MANAGER인 사원 검색

select * from employee
where dno=10 and job='MANAGER';


--10번 부서 소속이거나 직급이 MANAGER인 사원 검색

select * from employee
where dno=10 or job='MANAGER';


--10번 부서에 소속된 사원만 제외

select * from employee
where not dno=10;  --java에서 !


select * from employee
where dno!=10; --같지않다, 다르다 != (오라클은 <> ^= 도 가능)


--급여가 1000~1500 사이의 사원 출력

select * from employee
where salary >= 1000 and salary <= 1500;


select * from employee
where salary between 1000 and 1500; -- between A and B 


--급여가 1000미만이거나 1500초과인 사원 검색

select * from employee
where salary < 1000 or salary > 1500;


select * from employee
where salary not between 1000 and 1500;


--'1982년'에 입사한 사원 정보 출력

select * from employee
where hiredate >= '1982-01-01' and hiredate <= '1982-12-31'; 

select * from employee
where hiredate between '1982-01-01' and '1982-12-31'; --between

select * from employee
where hiredate between '1982/01/01' and '1982/12/31'; --년/월/일

select * from employee
where hiredate between '82-01-01' and '82-12-31'; --년도 앞 두자리 빼기


-- 커미션이 300이거나 500이거나 1400인 사원 정보 출력(=검색)

select * from employee
where commission=300 or commission=500 or commission=1400;

select * from employee
where commission in(300,500,1400); --in()


--커미션이 300, 500, 1400이 모두 아닌 사원 정보 출력

select * from employee
where not (commission=300 or commission=500 or commission=1400);

select * from employee
where commission!=300 and commission!=500 and commission!=1400;

select * from employee
where commission not in(300,500,1400);


--------------------------------------------------------------------------

-- 와일드 카드 : % _


-- 이름이 'F로 시작'하는 사원 정보 출력

SELECT * from employee
where ename LIKE 'F%';  
-- % : 문자가 없거나 하나 이상의 문자가 어떤 값이 와도 상관 없음. ex) 'F', 'FA', 'FSEE'


-- 이름에 'M이 포함'된 사원 정보 출력

SELECT * from employee
where ename LIKE '%M%';   -- ex) 'EM', 'MTSE' 'M'


-- 이름이 'M으로 끝나는' 사원 정보 출력

SELECT * from employee
where ename LIKE '%M';   


-- 이름의 두번째 글자가 A인 사원 검색

select * from EMPLOYEE
where ename like '_A%';   -- _ : 하나의 문자가 어떤 값이 와도 상관 없다.


-- 이름의 세번째 글자가 A인 사원 검색

select * from EMPLOYEE
where ename like '__A%'; 


-- 이름에 A가 포함 되지 않는 사원 검색

select * from EMPLOYEE
where ename NOT like '%A%';


-----------------------------------------


-- commission 받지 못한 사원 검색

select * from employee  -- 자바에서 = 는 대입 연산자, SQL에서는 '같다' 라는 뜻의 비교 연산자
where commission = null; -- null은 비교 연산자로 비교 불가하므로 결과가 나오지 않음

select * from employee
where commission IS null; 


-- commission 받는 사원 검색

select * from employee
where commission IS not null; 


-----------------------------------------

--정렬 : ASC 오름차순(생략가능), DESC 내림차순

--급여가 가장 적은 순부터 표시

select * from employee
ORDER BY salary ASC; 


--급여가 적은 순부터 표시(이 때, 급여가 같으면 commission이 많은 순부터 출력)

select * from employee
ORDER BY salary ASC, commission DESC; 


--급여가 적은 순부터 표시(이 때, 급여가 같으면 commission이 많은 순부터, commission이 같으면 이름을 알파벳 순으로 출력)

select * from employee
order by salary ASC, commission DESC, ename ASC;  -- 조건 순서 지키기
-- order by salary, commission DESC, ename; => ASC 생략 가능  
order by 6 ASC, 7 DESC, 2 ASC;  -- 이름 대신 index번호로 표시 가능 (INDEX번호 : SQL-1부터 시작, JAVA-0부터 시작)
-- order by 6, 7 DESC, 2;  => asc 생략 가능

-- 입사일이 빠른 순으로 표시

select * from employee
order by hiredate;


--------------------------------------------------------------------------------------------

-- 혼자 해보기 (65~72p)


-- 1. 덧셈 연산자를 이용하여 모든 사원에 대해서 $300의 급여 인상을 계산한 후 사원의 이름, 급여, 인상된 급여를 출력하시오.

select ename, salary, salary+300 from employee;

select ename, salary, salary+300 as "300이 인상된 급여" 
from employee;



-- 2. 사원의 이름,급여,연간 총수입을 총 수입이 많은 것부터 작은 순으로 출력
-- 연간 총수입=월급*12+상여금100

select ename, salary, salary*12+100 from employee
order by salary*12+100 DESC;

select ename, salary, salary*12+100 as "연간 총 수입" 
from employee
order by "연간 총 수입" DESC;



-- 3. 급여가 2000을 넘는 사원의 이름과 급여를 급여가 많은 것부터 작은 순으로 출력

--안됨
--select salary>2000 from employee
--order by ename, salary desc;

select ename, salary
from employee
where salary > 2000
order by salary desc;
-- 조건 where



-- 4. 사원번호가 7788인 사원의 이름과 부서번호를 출력

select eno, ename, dno 
from employee
where eno=7788;



-- 5. 급여가 2000에서 3000 사이에 포함되지 않는 사원의 이름과 급여 출력

select ename, salary 
from employee
where salary < 2000 or salary > 3000;


where salary not between 2000 and 3000;

where not (2000 <= salary and salary <= 3000)
-- 주의! 여러가지가 있을 때 우선순위 not -> and -> or
-- 우선순위를 바꾸는 방법은 ()사용



-- 5-2. 급여가 2000에서 3000 사이에 포함되는 사원의 이름과 급여 출력

select ename, salary 
from employee
where salary > 2000 and salary < 3000;


where salary between 2000 and 3000;

where not (2000 > salary or salary > 3000)



-- 6. 1981년 2월 20일부터 1981년 5월 1일 사이에 입사한 사원의 이름, 담당업무,입사일 출력
-- 오라클의 기본 날짜 형식은 'YY/MM/DD'

select ename, jop, hiredate 
from employee
where '1981/02/20'< hiredate and hiredate < '1981/05/01';


where hiredate between '1981/02/20' AND '1981/05/01';

where '81/02/20' <= hiredate AND hiredate <= '1981-05-01';



-- 7. 부서번호가 20 및 30에 속한 사원의 이름과 부서번호를 출력하되 
-- 이름을 기준으로 영문자순으로 출력

select ename, dno 
from employee
where dno in(20,30)  -- dno=20 or dno=30
order by ename;



-- 8. 사원의 급여가 2000에서 3000사이에 포함되고 부서번호가 20 또는 30인 사원의 이름,  
-- 급여와 부서번호를 출력하되, 이름순(오름차순)으로 출력

select ename, salary, dno 
from employee
where salary between 2000 and 3000 and dno in(20,30)
order by ename;

where salary between 2000 and 3000 and dno=20 or dno=30 -- 우선순위 not -> and -> or 오류 발생



-- 9. 1981년도에 입사한 사원의 이름과 입사일 출력(like연산자와 와일드카드(% _) 사용) 

--안됨
select ename, hiredate 
from employee
where hiredate like '1981%'; X --이유: 오라클의 기본날짜 형식이 'YY/MM/DD'이기 때문에


where hiredate like '81%';


--to_char(수, 날짜, '형식')
select ename, hiredate
from employee
where to_char(hiredate, 'yyyy') like '1981';  --'1981%'도 가능

where to_char(hiredate, 'yyyy-mm-dd') like '1981%'; --% 빼면 출력x 



-- 10. 관리자(=상사)가 없는 사원의 이름과 담당업무

select ename, job 
from employee
where MANAGER is null;



-- 11. '커미션을 받을 수 있는 자격'이 되는 사원의 이름, 급여, 커미션을 출력하되
-- 급여 및 커미션을 기준으로 내림차순 정렬

select ename, salary, commission 
from employee
where commission is not null
order by salary desc, commission desc; 



-- 12. 이름의 세번째 문자가 R인 사원의 이름 표시

select ename 
from employee
where ename like '__R%';



-- 13. 이름에 A와 E를 모두 포함하고 있는 사원이름 표시

select ename 
from employee
where ename like '%A%' and ename like '%E';



-- 14. '담당 업무가 사무원(CLERK) 또는 영업사원(SALESMAN)'이면서 
-- '급여가 1600,950 또는 1300이 아닌' 사원이름, 담당업무, 급여 출력

select ename, job, salary 
from employee
where job in ('CLERK','SALESMAN') AND salary not in (1600,950,1300);



-- 15. '커미션이 500이상'인 사원이름과 급여, 커미션 출력

select ename, salary, commission 
from employee
where commission >= 500;