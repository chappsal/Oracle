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


--manager를 제외하고 급여총액이 5000이상인 직급별 수와 급여총액 구하기

--[1]. 직급별 급여총액 구하기
select job, sum(salary) 
from employee
group by job;

--[2]. manager 제외
--방법 1
select job, sum(salary) 
from employee
where job != 'MANAGER'
group by job;

--방법2
select job, sum(salary) 
from employee
where job not like 'MANAGER'
group by job;

--[3]. 급여총액이 5000이상
select job, sum(salary) 
from employee
where job != 'MANAGER'
group by job
having sum(salary) >= 5000;
