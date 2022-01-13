/****************************************************************** 

  참조: 오라클 실행 순서
http://myjamong.tistory.com/172

from -> where -> group by -> having -> select -> order by

따라서 where절에서 별칭 인식 못 함 (즉 where + 별칭 사용 불가)

단, 아래는 가능 
select *
from (select salary as "급여" from 사원테이블)
where "급여" > 100;

********************************************************************/


--<북스-5장>그룹 함수: '하나 이상의 행을 그룹으로 묶어 연산'하여 종합, 평균 등 결과를 구함
-- ★★주의: count(*)함수를 제외한 모든 그룹함수들은 null값을 무시 , conut()괄호안에 다른게 들어가면 null값 무시

-- 사원들의 급여 총액, 평균액, 최고액, 최저액 출력
select 
sum(salary), 
avg(salary), 
-- trunc(avg(salary)), --정수 
max(salary), 
min(salary)
from employee;
--전체 사원 테이블이 대상이면 group by 사용 안 함 ( 전체가 하나의 그룹이므로)

--max(), min()함수는 숫자 데이터 이외에 다른 '모든 데이터 유형'에 사용 가능

--최근에 입사한 사원과 가장 오래전에 입사한 사원의 입사일을 출력
select max(hiredate) as "최근 사원", 
min(hiredate) as "오래전  사원" --별칭이 너무 길어도 오류 발생
from employee;


--1.1 그룹함수와 null값(145p)
--사원들의 커미션 총액 출력
select sum(commission) as "커미션 총액"
from employee;
--null값과 연산한 결과는 모두 null이 나오지만 
--★count(*)함수를 제외한 모든 그룹 함수들은 null값을 무시


--1.2 행 개수를 구하는 count함수
--count(* | 컬럼명 | distinct 컬럼명 | (all) 컬럼명) : 행 개수


--전체 사원 수
select count(*) as "전체 사원 수"
from employee;


--커미션을 받는 사원 수
--[방법 1]
select count(*) as "커미션 받는 사원 수"
from employee
where commission is not null;


--[방법 2] count(컬럼명) : null제외
select count(commission) as "커미션 받는 사원 수"
from employee;


--직업(job)이 어떤 종류?
select job
from employee; --중복된 값 나옴

select distinct job --distinct: 중복 제외
from employee;


--직업의 개수 : all
select count(job), count(all job) as "all한 직업 수"
from employee; --14 14

select count(commission), count(all commission) as "all한 커미션 수", count(*)
from employee; --4 4 14

--직업의 개수 : distinct(중복 제외)
select count(job), count(distinct job) as "중복 제외한 직업 수"
from employee; --14 5


--★★★★★★1-3.그룹함수와 단순컬럼★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

select ename, MAX(salary) -- 1:다 => 오류
from EMPLOYEE; 
--오류: 그룹함수의 결과값은 1개인데, 그룹함수를 적용하지 않은 컬럼은 결과가 여러 개 나올 수 있으므로 매칭 안 됨 


--2. 데이터 그룹: group by-특정 컬럼을 기준으로 그룹별로 나눠야 할 경우 사용
--★group by절 뒤에 별칭 사용 불가. 반드시 컬럼명만 작성

--소속 부서별로 평균 급여를 부서 번호와 함께 출력(부서번호를 기준으로 오름차순 정렬)
select round(avg(salary)) as "평균 급여", dno
from employee
group by dno
order by dno;

select round(avg(salary)) --부서번호가 없으면 결과 무의미 
from employee
group by dno;

--오류: group by절에 명시하지 않은 컬럼을 select절에 사용하면 오류 발생(개수가 달라 매치 불가능)
select dno, ename, round(avg(salary)) 
from employee
group by dno, ename;
 
select dno, job, count(*), sum(salary),a avg(salary)
from employee
group by dno, job
order by dno, job;
--group by절은 부서번호를 기준으로 그룹화한 다음
--해당 부서 번호 그룹 내에서 직업을 기준으로 다시 그룹화


--3. 그룹 결과 제한: having절 (152p) 
--그룹 함수의 결과 중 having절 다음에 지정한 조건에 true인 그룹으로 결과 제한

--'부서별 급여총액이 10000이상'인 부서의 부서번호와 부서별 급여총액 구하기(부서번호로 오름차순 정렬)
select dno, sum(salary)
from employee
-- where sum(salary) >= 10000 --오류: 그룹함수의 조건은 having절에 
group by dno  
HAVING sum(salary) >= 9000 --그룹에 조건
order by 1;


--manager를 제외하고 급여총액이 5000이상인 직급별 수와 급여총액 구하기(급여총액을 기준으로 내림차순 정렬)

--[1]. 직급별 급여총액 구하기
select job, count(*), sum(salary) 
from employee
group by job;

--[2]. manager 제외
--방법 1
select job, count(*), sum(salary) 
from employee
where job != 'MANAGER'
group by job;

--방법2
select job, count(*), sum(salary) 
from employee
where job not like 'MANAGER'
group by job;

--[3]. 급여총액이 5000이상
select job, count(*), sum(salary) as "급여 총액"
from employee
where job != 'MANAGER'
group by job
having sum(salary) >= 5000
--order by sum(salary) desc;
--order by 3 desc;
order by "급여 총액" desc; --별칭으로도 정렬 가능



--★★그룹함수는 2번까지 중첩해서 사용 가능
--직급별 급여 평균의 최고값을 출력

--[1] 직급별 급여 평균 구하기
select dno, avg(salary)
from employee
group by dno;

--[2] 직급별 급여 평균의 최고값을 출력
select dno, MAX(avg(salary))
from employee
group by dno;
--오류 발생(이유: dno 4개 , max(avg(salary)) 1개이므로 매칭 불가 

--오류 해결
select MAX(avg(salary))
from employee
group by dno;

--★★dno 같이 출력하고 싶다면 서브쿼리 사용

--[1] 부서별 평균 구하기
select dno, avg(salary)
from employee
group by dno;

--[2] '부서별 평균이 급여평균의 최고값과 같은 것' 구하기
select dno, avg(salary)
from employee
group by dno
having avg(salary) = (select MAX(avg(salary))
  					 from employee
					 group by dno);
--서브쿼리


					 select dno, avg(salary)
from employee
group by dno
having avg(salary) in (select MAX(avg(salary))
  					 from employee
					 group by dno);



select ename, slasy, commission
from employee
--아래 sql문으로 해결못함
select ename, saalary, commissinon




--<5장 그룹함수-혼자해보기>---------------------------------------------

/*
 * 1.모든 사원의 급여 최고액, 최저액, 총액 및 평균 급여를 출력하시오
 * 컬럼의 별칭은 결과 화면과 동일하게 저장하고 평균에 대해서는 정수로 반올림하시오
 */

select job,
max(salary) as "최고액", 
min(salary) as "최저액", 
sum(salary) as "총액", 
round(avg(salary)) as "평균급여"
from employee;



/*
 * 2. 각 담당 업무 유형별로 급여 최고액, 최저액, 총액 및 평균액을 출력하시오
 * 컬럼의 별칭은 결과 화면과 동일하게 저장하고 평균에 대해서는 정수로 반올림하시오
 */

select job, -- 추가하여 결과가 무의미해지지 않도록 함
max(salary) as "최고액", 
min(salary) as "최저액", 
sum(salary) as "총액", 
round(avg(salary)) as "평균급여"
from employee
group by job;


/*
 * 3. count(*)함수를 이용하여 담당 업무가 동일한 사원 수를 출력하시오
 */

select job, count(job)
from employee
group by job;



/*
 * 4.관리자(=MANAGER)수(count())를 나열하시오. 
 * 컬럼의 별칭은 결과 화면과 동일하게 지정하시오.
 */


--count(컬럼명) : 수  세기(null 제외)
select count(manager) as "관리자 수"
from employee;


--'MANAGER'의 수?
select job, count(*) as "관리자 수"
from employee
where job='MANAGER'
group by job;



/*
 * 5.급여 최고액, 급여 최저액의 차액을 출력하시오. 
 * 컴럼의 별칭은 결과 화면과 동일하게 지정하시오. 
 */

select max(salary) as "최고액" , 
min(salary) as "최저액", 
max(salary)-min(salary) as "차액"
from employee;


/*
 * 6.직급별 사원의 최저 급여를 출력하시오. 
 * '관리자를 알 수 없는 사원' 및 '최저 급여가 2000 미만'인 그룹은 '제외'시키고 
 * 결과를 급여에 대한 내림차순으로 정렬하여 출력하시오. 
 */


--[1]
select job, min(salary) "최저 급여"
from employee
group by job;


--[2] 방법 1
--'관리자를 알 수 없는 사원'제외 => where 
--'최저 급여가 2000 미만'인 그룹 제외 => having
select job, min(salary) "최저 급여"
from employee
where manager is not null
group by job
having min(salary)>=2000 --그룹함수의 조건:having
order by 2 desc;

--[2] 방법2
select job, min(salary) "최저 급여"
from employee
where manager is not null
group by job
having NOT min(salary)<2000 --그룹함수의 조건:having
order by 2 desc; -- 2 = "최저 급여" = min(salary) 모두 작성 가능




/*
 * 7.각 부서에 대해 부서번호, 사원수, 부서 내의 모든 사원의 평균 급여를 출력하시오. 
 * 컴럼의 별칭은 결과 화면과 동일하게 지정하고 평균 급여는 소수점 둘째 자리로 반올림하시오. 
 */

select dno, count(eno) "각 부서의 사원 수",
round(avg(salary), 2) as "평균 급여",
from employee
group by dno;


--7번 문제에 추가(★단, 테이블을 조회하기 전에 salary의 null 여부를 모른 상태에서 조회한다면)
-- avg: null을 제외하고 연산(=NULL값 급여를 받는 사원을 제외하고 연산) 
-- BUT, NULL값 급여를 받는 사원도 포함해 연산하려면? => null 처리함수로 값 변경
select dno, count(eno) as "각 부서의 사원 수",
round(avg(nvl(salary,0)), 2) as "평균 급여"
from employee
group by dno;


--추가
--커미션을 받는 사원들만의 커미션 평균 , 전체 사원의 커미션 평균 구하기
select avg(commission) as "커미션 받는 사원 평균" , 
avg(nvl(commission,0)) as "전체 평균"
from employee;




/*
 * 8.각 부서에 대해 부서번호 이름, 지역명, 사원수, 부서내의 모든 사원의 평균 급여를 출력하시오. 
 * 컴럼의 별칭은 결과 화면과 동일하게 지정하고 평균 급여는 정수로 반올림하시오.
 */

select dno,
decode(dno, 10,'ACCOUNTING',
			20,'RESEARCH',
			30,'SALES',
			40,'OPERATIONS') as "부서이름",
decode(dno, 10,'NEW YORK',
			20,'DALLAS',
			30,'CHICAGO',
			40,'BOSTON') as "지역명",
sum(salary) as "부서별 급여 총액",
count(*) as "부서별 사원수", 
round(avg((salary))) as "부서별 평균급여-1", --null 급여받는 사원 제외
round(avg(nvl(salary,0))) as "부서별 평균급여-2" --null 급여받는 사원 포함
from employee
group by dno
order by 1;


--join 이용한 방법 1: ,~where (잘 안 씀)
select d.dno, dname as "부서 이름", loc as "지역명",
sum(salary) as "부서별 급여 총액",
count(*) as "부서별 사원수", 
round(avg((salary))) as "부서별 평균급여-1", --null 급여받는 사원 제외
round(avg(nvl(salary,0))) as "부서별 평균급여-2" --null 급여받는 사원 포함
from employee e , department d -- 구분 위해 별칭 사용, 중복 o
where e.dno=d.dno --조인 조건
group by d.dno, dname, loc -- group으로 만든 것들을 select에도 추가해야 함 
order by 1;

--join 이용한 방법 2: join~on
select d.dno, dname as "부서 이름", loc as "지역명",
sum(salary) as "부서별 급여 총액",
count(*) as "부서별 사원수", 
round(avg((salary))) as "부서별 평균급여-1", 
round(avg(nvl(salary,0))) as "부서별 평균급여-2" 
from employee e , department d -- 구분 위해 별칭 사용, 중복 o
ON e.dno=d.dno --조인 조건
group by d.dno, dname, loc 
order by 1;


--join 이용한 방법3: natural join은 중복컬럼 제거(dno 1개 제외)
select d.dno, dname as "부서 이름", loc as "지역명",
sum(salary) as "부서별 급여 총액",
count(*) as "부서별 사원수", 
round(avg((salary))) as "부서별 평균급여-1", 
round(avg(nvl(salary,0))) as "부서별 평균급여-2" 
from employee natural join department --별칭 필요 없음, 중복 없어서 (사용해도 오류x)
group by d.dno, dname, loc 
order by 1;


/*
 * 9.업무를 표시한 다음 해당 업무에 대해 부서번호별 급여 및 부서 10, 20, 30의 급여 총액을 각각 출력하시오.
 * 각 컬럼에 별칭은 각각 job, 부서 10, 부서 20, 부서 30, 총액으로 지정하시오.
 */
select job, dno,
decode(dno, 10, sum(salary), 0) as "부서 10",
decode(dno, 20, sum(salary)) as "부서 20",
decode(dno, 30, sum(salary)) as "부서 30",
sum(salary) as "총액"
from employee
group by job,dno
order by dno;

