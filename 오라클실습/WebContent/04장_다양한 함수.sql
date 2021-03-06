--<북스-4장.다양한 함수>

/*******<문자함수>**************************/

--1. 대소문자 변환함수

select 'Apple',
upper('Apple'),--대문자로 변환
lower('Apple'),--소문자로 변환
initcap('aPPLE')--첫글자만 대문자, 나머지는 소문자로 변환
from dual;

--대소문자 변환함수 어떻게 활용되는지 살펴보기
--'scott' 사원의 사번, 이름, 부서번호 출력

SELECT eno, ename, dno 
FROM EMPLOYEE
WHERE lower(ENAME)='scott';
--비교대상인 사원이름을 모두 소문자로 변환하여 비교

select ename, lower(ename)
from employee;

SELECT eno, ename, dno 
FROM EMPLOYEE
WHERE initcap(ENAME)='Scott';



--2. 문자길이를 반환하는 함수 ---------------------------------------------------

--영문, 수, 특수문자 (1byte) 또는 한글의 길이 구하기

--length(): 문자 수

select length('Apple'), length('사과')
from dual; -- 5 2 출력

--lengthB(): 한글 2byte-'인코딩 방식'에 따라 달라짐(UTF-8:한글 1글자가 '3byte')
select lengthB('Apple'), lengthB('사과')
from dual; -- 5 6 출력 , 5바이트 6바이트




--3. 문자 조작 함수 ------------------------------------------------------


-- concat(매개변수가 2개만): '두 문자열'을 하나의 문자열로 연결(=결합)
-- ★★ 반드시 2 문자열만 연결 가능
-- 매개변수 = 인수 = 인자 = argument


select 'Apple', '사과',
concat('Apple', '사과') AS "함수 사용", --자바에서는 "Apple".concat("사과")
'Apple' || ' 사과' || ' 맛있어' AS " || 사용" --자바에서는 "Apple" + "사과" + "맛있어"
from dual;


-- substr(기존문자열, 시작 index, 추출할 개수) : 문자열의 일부만 추출하여 부분 문자열
-- 시작 index : 음수이면 문자열의 마지막을 기준으로 거슬러 올라옴 
-- 인덱스(index) : 1 2 3 ....(자바 index : 0 1 2...)

select substr('apple mania',7,5), -- mania
substr('apple mania',-11,5)       -- apple
from dual;



-- 문제 1)

-- 방법 1.
-- '이름이 N으로 끝나는' 사원 정보 표시
-- 방법 1. like 연산자와 와일드 카드 이용

select * from employee
where ename like '%N';


-- 방법 2. substr() 이용

select * from employee 
where substr(ename, -1, 1)='N';


select ename, substr(ename, -1, 1)
from employee
where substr(ename, -1, 1)='N';




-- 문제 2) 87년도에 입사한 사원 정보 검색

select * from employee
where substr(hiredate, -8, 2)=87; -- ★오라클: 날짜 기본 형식 YY/MM/DD


where substr(hiredate, 1, 2)=87;



-- to_char(수나 날짜,'형식'): 수나 날짜를 문자로 형변환 함

select *
from employee
where substr(to_char(hiredate,'yyyy'),1,4)='1987';




-- 문제 3) 급여가 50으로 끝나는 사원의 이름과 급여 출력

select ename, salary from employee
where substr(salary, -2, 2)=50; -- 끝에서 2번째부터 시작해서 2개 문자로 부분문자열 생성, substr()은 문자함수


select ename, salary from employee
where substr(to_char(salary),-2,2)='50'; 


select ename, salary from employee
where salary like '%50'; --salary는 실수 number(7,2)타입이지만 '문자로 자동형변환' 되어 비교





-- substr B(기존문자열, 시작 index, 추출 할 바이트 수) ----------------------------------------------------


select substr('사과매니아', 1,2) --사과

substrB('사과매니아', 1,3), --'사' , 1부터 시작해서 3바이트를 추출
substrB('사과매니아', 4,3), --'과' , 4부터 시작해서 3바이트를 추출
substrb('사과매니아',1,6) --'사과' , 1부터 시작해서 6바이트를 추출
from dual




--index(대상문자열, 찾을 문자, 시작index,몇 번째 발견 : 대상문자열 내에 찾고자 하는 해당 문자열이 어느 '위치(=index번호)'에 존재-----------------------------------------

-- '시작 index, '몇번째 발견' 생략하면 모두 1로 간주

-- ex) instr(대상문자열, 찾을 문자) => instr(대상문자열, 찾을 문자, 1, 1)
-- 찾는 문자가 없으면 0을 결과로 돌려줌 (자바에서는 -1)
-- 자바에서는 "행복,사랑".indexOf("사랑")==3

select instr('apple','p'), instr('apple','p',1,1) -- 2 2
             instrB('apple','p'),instrB('apple','p',1,1), --2 2
instr('apple','p',1,2)--3('apple'내에서  1부터 시작해서 두 번째 발견하는 'p'를 찾아 index번호)
from dual; 


select instr('apple','p',2,2)
from dual; --3


select instr('apple','p',3,1)
from dual; --3


select instr('apple','p',3,2)
from dual; --0:찾는 문자가 없다.(자바에서는 찾는 문자열이 없으면 -1)


select instr('apple','pl',1,1)
from dual; --3


   
-- 영어는 무조건 1글자에 1byte, 그러나 인코딩방식에 따라 달라짐
-- '바나나'에서 '나'문자가 1부터 시작해서 `1번째 발견되는 '나'를 찾아 위치값(index)=?
select instr('바나나','나'), instr('바나나','나',1,1), -- 2 2
instrB('바나나','나'), instrB('바나나','나',1,1)       -- 4 4
from dual;


-- '바나나'에서 '나'문자가 2부터 시작해서 `2번째 발견되는 '나'를 찾아 위치값(index)=?

select instr('바나나','나',2,2), -- 3
       instrB('바나나','나',2,2) -- 7
from dual;



-- 이름의 세번째 글자가 'R'인 사원의 정보를 검색

-- 방법 1
select * from employee
where ename like '__R%';


-- 방법 2
select * from employee
where substr(ename,3,1)='R';


-- 방법 3
select * from employee
where instr(ename,'R',3,1)=3;



--LPAD(left padding) : '컬럼'이나 대상문자열을 명시된 자릿수에서 오른쪽에 나타내고 남은 왼쪽은 특정 기호로 채움 -----------------------------

-- 10자리를 마련 후 salary는 오른쪽, 남은 왼쪽 자리를 '*'로 채움
select salary,LPAD(salary,10,'*') 
from employee;

-- 10자리를 마련 후 salary는 왼쪽, 남은 오른쪽 자리를 '*'로 채움
select salary,RPAD(salary,10,'*') 
from employee;






--LTRIM('   문자열') : 문자열의 '왼쪽' 공백 제거 ----------------------------------------------------------------------------
--RTRIM('문자열   ') : 문자열의 '오른쪽' 공백 제거
--TRIM('  문자열  ') : 문자열의 '양쪽' 공백 제거

select '  사과매니아  ' || '입니다.',
LTRIM('  사과매니아  ') || '입니다.',
RTRIM('  사과매니아  ') || '입니다.',
TRIM('  사과매니아  ') || '입니다.'
from dual;



--TRIM('특정문자 1개' from 컬럼이나 '대상문자열')
--컬럼이나 '대상문자열'에서 특정문자가 '첫번째 글자'이거나 '마지막 글자'이면 잘라내고
--남은 문자열만 결과로 반환(return)

select TRIM('사과' from '사과매니아')
from dual; -- 오류: trim set should have only one character

select TRIM('사' from '사과매니아')
from dual; --'과매니아'

select TRIM('아' from '사과매니아')
from dual; --'사과매니'

select TRIM('과' from '사과매니아')
from dual; --'과'가 처음,마지막에 없음 -> 잘라내지 못 함 -> '사과매니아'


--북스 114p
/*******<숫자함수>**************************/
--  -2(백의자리)  -1(십의자리)  0(일의자리) . 1 2 3
--


-- 1. round(대상, 화면에 표시되는 자릿수) : 반올림
--단, 자릿수 생략하면 0으로 간주

select 98.7654,
round(98.7654),   -- 99
round(98.7654,0), -- 99 출력 / 일의 자리까지 표시. 소수 첫째 자리에서 반올림하여
round(98.7654,2), -- 98.77 출력 / 소수 둘째 자리까지 표시. 소수 셋째 자리에서 반올림하여
round(98.7654,-1) -- 100 출력 / 십의 자리까지 표시. 일의 자리에서 반올림하여
from dual;


-- 2. trunc(대상, 화면에 표시되는 자릿수) : '화면에 표시되는 자릿수'까지 남기고 나머지 버림
-- 단, 자릿수 생각하면 0으로 간주

select 98.7654,
trunc(98.7654),   -- 98
trunc(98.7654,0), -- 98 
trunc(98.7654,2), -- 98.76 
trunc(98.7654,-1) -- 90 
from dual;


-- 3. mod(수1,수2) : 수1을 수2로 나눈 나머지

select MOD(10,3) -- 1
from dual;


-- 사원이름, 급여, 급여를 500으로 나눈 나머지 출력

select ename, salary, MOD(salary,500)
from employee;




--북스 117p
/*******<날짜함수>**************************/

-- 1. sysdate : 시스템으로부터 오늘의 날짜와 시간을 반환

select sysdate from dual;



-- date + 수 = 날짜에서 수만큼 '이후 날짜'
-- date - 수 = 날짜에서 수만큼 '이전 날짜'
-- date - date = 일수
-- date + 수/24 = 날짜 + 시간


select sysdate-1 as 어제,
sysdate 오늘,
sysdate+1 as "내 일"
from dual;


--사원들의 현재까지 근무일 수(단, 실수이면 반올림하여 일의 자리까지 표시)

select sysdate - hiredate as "근무일 수", -- 날짜에 시간이 포함되어 있기 때문에 실수가 나옴
round(sysdate - hiredate,0) as "근무일 수 반올림"  
from employee;



--입사일에서 '월을 기준'으로 잘라내려면(월까지 표시,나머지 버림)

select hiredate,
trunc(hiredate,'Month') --월(01)과 일(01)을 초기화
from employee;


select sysdate, 
trunc(sysdate), --시간 잘라냄
trunc(sysdate,'dd'), --시간 잘라냄(윗줄과 동일한 결과)
trunc(sysdate,'hh24'), --분,초 잘라냄
trunc(sysdate,'mi'), --초 잘라냄
trunc(sysdate, 'Year'), --월(01)과 일(01)을 초기화
trunc(sysdate, 'Month'), --일(01)을 초기화
trunc(sysdate, 'Day') --요일(해당 날짜에서 지난 일요일로) 초기화, 며칠인지 알 수 있음
from dual;  


select sysdate,
trunc(sysdate, 'Day')
from dual; -- dual로 하면 결과 한 줄만 나옴


-- 2. monthS_between(날짜1, 날짜2) : 날짜1과 날짜2 사이의 개월 수 구하기 : (날짜1-날짜2)

select ename, sysdate, hiredate,
months_between(sysdate, hiredate), TRUNC(months_between(sysdate, hiredate)), 
months_between(hiredate, sysdate), TRUNC(months_between(hiredate, sysdate))
from employee;



-- 3. add_monthS(날짜, 더할 개월 수) : 특정 개월 수를 더한 날짜

select ename, hiredate, 
add_monthS(hiredate, 3), add_monthS(hiredate, -3)
from employee;


-- 4. next_day(날짜, '수요일') : 해당 날짜를 기준으로 최초로 도래하는 요일에 해당하는 날짜 반환

select sysdate, 
next_day('2021-10-26', '수요일'),
next_day(sysdate, 4) --일요일(1), 월요일(2).....토요일(7) , 요일 대신 숫자로 기입 가능
from dual;


-- 5. last_day(날짜) : 해당 날짜가 속한 달의 마지막 날 반환
-- 2월에 사용하면 효과적 => 마지막 날이 28 or 29  

select sysdate, last_day(sysdate) 
from dual;

select ename, hiredate, last_day(hiredate)
from employee;



-- 6. 날짜 또는 시간 차이 계산 방법

-- 날짜 차이 : 종료일자(YYYY-MM-DD)-시작일자(YYYY-MM-DD)
-- 시간 차이 : (종료일시(YYYY-MM-DD HH:MI:SS)-시작일시(YYYY-MM-DD HH:MI:SS))*24
-- 분 차이 :  (종료일시(YYYY-MM-DD HH:MI:SS)-시작일시(YYYY-MM-DD HH:MI:SS))*24*60
-- 초 차이 :  (죵료일시(YYYY-MM-DD HH:MI:SS)-시작일시(YYYY-MM-DD HH:MI:SS))*24*60



-- ★ '종료 일자-시작 일자' 빼면 차이 값이 '일 기준'의 수치 값으로 변환 된다.
select '20211129'-'20211127' --number로 자동형변환되어 연산됨 / 20211129-20211127
from dual; --2


-- 날짜 차이 계산

select to_date('2021-11-29'-'2021-11-27') --숫자만 있지 않고 -도 있어서 자동형변환x , 오류 발생
from dual;



--to_date('수','형식') : '문자'->'날짜'로 변환
select to_date(20011129, 'YYYY-MM-DD') from dual;



--to_date('문자','형식') : '문자'->'날짜'로 변환
-- ex) 1800-1-1 =>, 2021-11-26 => 1000일 지남, 2021-11-27 => 998일 지남

select to_date('2021-11-29','YYYY-MM-DD')-to_date('2021-11-27',''YYYY-MM-DD'') 
from dual;


-- 시간 차이 계산

select (to_date('15:00','HH24:MI')-to_date('13:00','HH24:MI'))*24
from dual; -- 2시간


select (to_date('2021-11-29 15:00','YYYY-MM-DD HH24:MI')-to_date('2021-11-29 13:00','YYYY-MM-DD HH24:MI'))*24
from dual; --2시간


select (to_date('2021-11-30 15:00','YYYY-MM-DD HH24:MI')-to_date('2021-11-29 13:00','YYYY-MM-DD HH24:MI'))*24
from dual; --25.999...시간


select (to_date('15:00:58','HH24:MI:SS')-to_date('13:00:40','HH24:MI:SS'))*24
from dual; -- 2.005시간

-- 시간에 초가 존재하면 소수점이 발생하므로 round 함수로 소수점을 처리할 수 있다

-- 반올림하여 소수 둘째 자리까지 표시

select ROUND( (to_date('15:00:58','HH24:MI:SS')-to_date('13:00:40','HH24:MI:SS'))*24 , 2 )
from dual; -- 2.005시간 => 2.01시간


-- 분 차이 계산

select ROUND( (to_date('15:00:58','HH24:MI:SS')-to_date('13:00:40','HH24:MI:SS'))*24 *60 , 2 )
from dual; -- 2.005시간 => 2.01시간


-- 초 차이 계산

select ROUND( (to_date('15:00:58','HH24:MI:SS')-to_date('13:00:40','HH24:MI:SS'))*24 *60 , 2 )
from dual; -- 120분*60 => 7218초




--북스 124p
/*******<형변환함수>**************************/
/*


      to_char() =>             <= to_char()
[수]                   [문자]                    [날짜]
     <= to_number()             to_date() =>
     --------------- to_date() ----------->


1. to_char(수나 '날짜', 형식) : 수나 '날짜'를 문자로 변환

<'날짜'와 관련된 형식>
YYYY : 연도 4자리 , YY : 연도 2자리
MM   : 월 2자리 수로 (예) 1월=>01 , MON(month의mon) : 월을 '알파벳'
DD   : 일 2자리 수로 (예) 2일=>02 , D : 사용안함
DAY  : 요일 표현    (예) 월요일   , DY : 요일을 약어로 표현 (예) 월


<'시간'와 관련된 형식>
AM/PM     : 오전AM, 오후PM 시각 표시
A.M./P.M. : 오전A.M, 오후P.M 시각 표시
=>위 4가지 다 같은 결과 (오전, 오후)
HH/HH12   : 시간(1~12시로 표현)
HH24      : 24시간으로 표현(0~23)
MI        : 분
SS        : 초

*/

select ename, hiredate,
to_char(hiredate, 'YY-MM'),
to_char(hiredate, 'YYYY/MM/DD DAY DY')
from employee;


select 
to_char(sysdate,'YYYY/MM/DD DAY DY, HH'), --사용X(오전 오후가 없음)
to_char(sysdate,'YYYY/MM/DD DAY DY, PM HH'), --HH12는 반드시 AM/PM 표기
to_char(sysdate,'YYYY-MM-DD DAY DY, A.M. HH'),
to_char(sysdate,'YYYY/MM/DD DAY DY, AM HH24:MI:SS') --HH24는 AM/PM 생략 
from dual;

/*
<숫자와 관련된 형식>
 
 0 : 자릿수를 나타내며 자릿수가 맞지 않을 경우 '0'으로 채움
 9 : 자릿수를 나타내며 자릿수가 맞지 않아도 '채우지 않음'
 L : 각 지역별 통화 기호를 앞에 표시 (달러는 직접 $ 붙여야 함)
 . : 소수점
 , : 천 단위 자리 표시
 
 
 */

select ename, salary,
to_char(salary,'L000,000'),
to_char(salary,'L999,999'),
to_char(salary,'L999,999.00'),
to_char(salary,'L999,999.99')
from employee;

select 123.4, to_char(123.4, 'L000,000.00'), to_char(123.4, 'L999,999.99')
from dual;

--10진수 10 -> 16진수 (HEX헥사)A = 문자'A'(16진수 '0'~9 ABCDEF)
select to_char(10,'X'), --10진수 10을 16진수 1자리로 된 문자로 변환 => 'A'
to_char(225, 'XX') --`0진수 225를 16진수 2자리로 된 문자로 변환 => 'FF' / 'X'로 하면 '##' => 0자릿수가 부족하다는 뜻 

--문자나 16진수문자(0~9,a_f) => 10진수로 변환
select to_number('A','X'), --16진수'A' => 수로 변환 10
to_number('FF','XX') --16진수 FF => 수로 변환 255
from dual;


/*
 * 대부분 사용하는 to_number('10진수 형태의 문자')의 용도는
 * 단순히 '10진수 형태의 문자'를 숫자로 변환하는데 사용됨
 * 
 * */

select to_number('0123'), to_number('12.34')
from dual;

/*
 * java에서는 int num1 = Integer.parseInt("0123"); // 0123
 *          int num2 = Integer.parseInt("가나");  // 예외 객체 -> 프로그램이 종료
 *
 *          double num3 = Double.parseDouble("12.34"); // 12.34 , 값이 들어감(주소x)
 *          double num4 = Double.parseDouble("ab");    // 예외 객체 -> 프로그램이 종료
 */

-- 2. to_date(수나 '문자', '형식') : 수나 '문자'를 날짜형으로 변환

select ename, hiredate
from employee
where hiredate=19810220; --데이터 타입이 맞지 않아 검색 불가능(오류)


--그래서 to_date()함수 이용하여 수를 날짜로 형변환하여 해결
select ename, hiredate
from employee
where hiredate = to_date(19810220,'YYMMDD'); 
-- 결과 나옴 1982-02-20 시 분 초


select ename, hiredate
from employee
where hiredate = to_date(810220,'YYMMDD'); -- 결과 없음, hiredate 형식과 맞지 않음(1900년도 !=2081이므로 같은 연도 x)
 

select 810220,
to_date(810220,'yymmdd'), -- 2081-02-20 시:분:초 (년도에서 앞 2자리 생략하면 자동으로 20붙음)
to_date('810220','yy/mm/dd'), -- 2081-02-20 시:분:초
to_date('81/02/20','yy-mm-dd'), -- 2081-02-20 시:분:초
to_date('81/02/20','yy$mm$dd'), -- 2081-02-20 시:분:초
to_date(19810220,'yymmdd'), --1981-02-20 시:분:초
to_date('19810220','yymmdd'), --1981-02-20 시:분:초

to_date(19810220,'yyyymmdd') --평상시 사용
to_date('19810220','yyyymmdd') --평상시 사용

--to_date(1981/02/20,'yyyy-mm-dd'),--★★주의 :오류
to_date('1981-02-20','yyyy/mm/dd')--평상시 사용
from dual;--to_date()의 결과는 '년-월-일 시:분:초'로 변환됨.



--3. to_number('10진수 문자', '형식'): 문자를 수로 변환


select 123,
to_number('123'), --123
to_number('12.3'), --12.3
to_number('10,100','99999'), --10100 수로 변환
to_number('10,100','99,999'), --10100
from dual; --to_number('10,100'): 오류 발생

select 100000-50000
from dual; -- 결과 50000

select 100,000-50,000
from dual; 

select '100000'-'50000'
from dual; -- 결과 50000(이유: '10진수 문자'이므로 수로 자동형변환되어 연산)

select '100000'-50000
from dual; -- 결과 50000

select '100,000'-'50,000'
from dual; --오류(이유: '10진수 문자'가 아닌 콤마가 있어서 수로 자동형변환이 안 됨) 

select to_number('100,000','999,999')-to_number('50,000','99,999')
from dual; -- 결과 50000(천단위 구분 쉼표 생략해도 수로 변환 됨)

select '100000'-to_number('50000')
from dual; -- 결과 50000 / to_number() 사용할 필요 없음(자동형변환 됨)

select nullif('A','A'), nullif('a','b')
from dual;


--4. coalesce(인수, 인수, 인수....)

/*
 * 사원테이블에서 커미션이 null이 아니면 커미션을 출력,
 * 커미션이 null이고 급여가 null이 아니면 급여를 출력,
 * 커미션과 급여 모두 null이면 0 출력
 */

select ename, salary, commission,
coalesce(commission,salary,0)
from employee;

/*
 * java에서는 
 * if(commission != null) commission출력
 * else if(salary != null) salary출력
 * else 0 출력
 * 
 */
-- 부서이름을 오름차순 정렬하여 출력 [방법1] : decode함수 사용

/* 5. decode() : switch~case문과 같음 ★☆ 많이 사용
 * switch(dno){
 * case 10: 'ACCOUNTING'출력; break;
 * case 20: 'RESEARCH'출력; break; 
 * case 30: 'SALES'출력; break;
 * case 40: 'OPERATIONS'출력; break;
 * default: '기본'출력
 * 
 */

--5. decode() : switch~case문과 같음 ★☆ 많이 사용
-- decode()로 부서이름 출력
select ename, dno,
DECODE(dno,10,'ACCOUNTING',
		   20,'RESEARCH',
		   30,'SALES',
		   40,'OPERATIONS',
		   '기본') as dname
from employee
order by dno asc;


-- 부서이름을 오름차순 정렬하여 출력 [방법2]
--6. case~end : 자바에서 if~else if~else문과 비슷
--주의 case~end 사이에는 콤마 없음
--decode()함수에서 사용하지 못 하는 비교연산자 중 =를 제외한 나머지 비교연산자를 사용 가능(>= , < 등)

select ename,dno,
case when dno=10 then 'ACCOUNTING'
	 when dno=20 then 'RESEARCH'
	 when dno=30 then 'SALES'
	 when dno=40 then 'OPERATIONS'
	 else '기본'
END AS ename
from employee
order by dno;



-- 부서이름을 오름차순 정렬하여 출력 [방법3] 두 테이블을 하나의 테이브로 join
select ename, dno, dname
from empolyee natural join department--둘다 dno
order by dno asc;

--------------------------------------------------------------------------------------------
--<4장 다양한 함수-혼자해보기>


--1. substr 함수를 이용하여 사원들의 입사년도,입사한 달만 출력

select ename,substr(hiredate,1,5) as "입사 년도/월"
from employee;


--풀이
select hiredate,substr(hiredate,1,2)년도, substr(hiredate,4,2) 달
from employee;


select hiredate,
substr(to_char(hiredate,'yyyy-mm-dd'),1,4) 년도,
substr(hiredate,4,2) 달
from employee;



--2. substr을 사용하여 4월에 입사한 사원 출력

select ename,hiredate
from employee
where substr(hiredate,5,1)=4;


--풀이
select *
from employee
where substr(hiredate,4,2)='04';
where substr(to_char(hiredate,'yyyy-mm-dd'),6,2)='04';



--3. mod를 사용하여 사원번호가 짝수인 사람 출력

select ename,eno as 사원번호
from employee
where MOD(eno,2)=0;



--4. 입사일을 연도 2자리 yy, 월은 숫자 mon으로 표시하고 요일은 약어 dy로 지정하여 출력

select ename, to_char(hiredate,'yy/mm/dd dy')
from employee;




--5. 올해 며칠이 지났는지 출력. 
--현재날짜에서 올해 1/1일을 뺀 결과를 출력하고 
--to_date함수를 사용하여 데이터형을 일치시키시오






--풀이
select sysdate-'2021/01/01'
from dual -- 오류: 데이터 형이 일치하지 않음(날짜형식-문자형식)

select sysdate-TO_DATE('2021/01/01','YYYY/MM/DD')
from dual; 

select trunc(sysdate-TO_DATE('2021/01/01','YYYY/MM/DD'))
from dual; -- 정수로 표시



--6. 사원들의 상관 사번을 출력하되 상관이 없는 사람에 대해서는 null대신 0으로 출력


select eno, ename, nvl(manager,0) as 상관사번
from employee;



--7. decode로 직급에 따라 급여를 인상하도록 하시오. 직급이 anaiyst인 사원은 200. SALESMAN은 180 MANAGER는 150 CLERK은 100인상


select ename,job,salary,
decode(job, 'ANALYST',salary+200,
			'SALESMAN',salary+180,
			'MANAGER',salary+150,
			'CLERK',salary+100) as "인상된 급여"
from employee
order by salary;




------------------------------------------------------------------

--[교재에 없는 내용]

/*
 * 자동 형변환
 */

select '100'+200
from dual; -- 문자 '100' => 수 100으로 자동형변환되어 연산

-- 문자 연결
select concat('100', 200), -- 수 100 => 문자 '200'으로 자동형변환 // '100200'
100 || 200 || 300 || 400 -- 모두 문자로 자동형변환 '00' || '200'
from dual;

select ename
from employee
where eno='7369'; -- 'eno는 number'이므로 비교하려면 같은 타입으로 맞춰야 함. 문자 '7369' => 정수로 자동형변환 후 비교


select ename
from employee
where eno=CAST('7369' as number(4));
-- 많이 사용되지는 않지만, cast함수를 사용하면 타입이 맞지 않아 발생하는 오류를 방지할 수 있다


/*
 * cast() : 데이터 형식 변환 함수 
 *          데이터 형식을 실시간으로 변환하는데 사용됨
 *          자동형변환이 되지 않을 때 사용
 */

select avg(salary) as "평균 월급"
from employee; -- 결과가 실수. 2074.2142....


-- 1.1 실수로 나온 결과를 전체 6자리 중 소수점 이하 2자리까지 표현(셋째자리에서 반올림)
-- ★주의 : 소수점을 포함하는 숫자 타입 변환 시, 기존의 자릿수보다 작은 자릿수로 cast하게 되면 (강제 형 변환하게 되면)
-- round()반올림 되어 처리 됨

select CAST(avg(salary) as number(6,2)) as "평균 월급" 
from employee; --2073.21

select ROUND(avg(salary),2) as "평균 월급" 
from employee;


-- 데이터 형식을 실시간으로 변환하는데 사용됨

select CAST (ename as CHAR(20)),
	   length(ename),
	   length(CAST (ename as CHAR(20)))
from employee;


-- run sql commandline에서 employee 테이블 구조 확인해보니 
desc employee;
-- 결과: ename의 데이터 형식은 변하지 않음


-- 1.2 실수로 나온 결과를 '정수로 보기 위해서'
-- 아래 2개는 결과가 다름

select CAST(avg(salary) as number(6)) as "평균 월급" -- 정수 6자리로 출력하지만 반올림도 된다
from employee; -- 만약 2073.7142..... => 2074

select TRUNC(avg(salary)) as "평균 월급" 
from employee; -- 만약 자바에서 (int)2073.8142.....=>2073 -- 반올림x 그냥 잘라버림



-- 테스트: 사원번호 7369의 급여를 800으로 수정

update employee -- update 테이블 명 (주의: update에는 from 없음) 
set salary=800 -- set 컬럼명=변경할 값
where eno=7369; -- where 조건;

select *
from employee;



-- 2. 다양한 구분자를 날짜 형식으로 변경 가능 (예) 날짜: '2021-05-21' , '2021/05/21'

select CAST('2021$05$21' AS DATE) from dual; -- 원래 자동형변환 되지만 안 될 때 CAST 사용
select CAST('2021%05%21' AS DATE) from dual; 
select CAST('2021#05#21' AS DATE) from dual; 
select CAST('2021@05@21' AS DATE) from dual; 


-- 3. 쿼리의 결과를 보기 좋도록 처리할 때

select nvl(salary,0) + nvl(commission,0) as "총 합"
from employee;


select CAST(nvl(salary,0) as char(7)) || '+' || CAST(nvl(commission,0) AS CHAR(7)) || '=' as "월급+커미션",
nvl(salary,0) + nvl(commission,0) as "총 합"
from employee;




--북스 130p
/*******<일반함수>**************************/
/*
 * null은 연산, 비교 불가
 * 
 * ★★ null 처리하는 함수들 
 *
 * 1. nvl(값1, 값2) : 값1이 null이 아니면 값1, null이면 값2를 반환
 *    주의: 값1과 값2는 반드시 데이터 타입이 일치
 *    ex) nvl(hiredate, '2021/05/21') : 둘 다 date 타입으로 일치
 *        nvl(jop, 'MANAGER') : 둘 다 문자 타입으로 일치
 * 
 * 2. NVL2(값1, 값2, 값3) : 
 *        (값1, 값1이 null이 아니면 출력, 값1이 null이면 출력) 
 * 
 * 3. NULLif(값1, 값2) : 두 값이 같으면 null, 다르면 '첫번째 값1'을 반환
 * 
 * */

select ename, salary, commission,
salary*12 + nvl(commission, 0) as "연봉",
salary*12 + nvl2(commission, commission, 0) as "연봉",
nvl2(commission, salary*12+commission, salary*12) as "연봉",
salary*12 + nvl2(commission, 1000, 0) as "커미션null아닌사원+1000",
salary*12 + nvl(nullif(commission, null),0)
from employee;


-- ★★ rank() : 순위 구하기
-- 연봉 상위 3개 조회 - rank() 함수 사용  
-- 만약 급여가 같다면 커미션이 높은 순으로 조회, 커미션이 같다면 사원명을 알파벳 순으로 조회


-- 방법 1 : 해결 안 됨
select ename, salary, commission
from employee
where rownum <=3                       -- 조건에 맞는 결과를 조회 후
order by salary desc, commission desc; -- 정렬 

-- 방법 2 : 해결
select ename, salary, commission,
RANK() OVER(order by salary desc) as "급여 순위-1",       -- 급여 순위 1 2 2 4 
DENSE_RANK() OVER(order by salary desc) as "급여 순위-2", -- 급여 순위 1 2 2 3 
RANK() OVER(order by salary desc, commission desc, ename asc) as "급여 순위-3"        -- 급여 순위 1 2 3 4 / 순위가 중복되지 않도록 함
from employee;


-- 부서그룹별 순위 구하기 : partition by + 그룹 컬럼명
select dno, ename, salary, commission,
rank() over(partition by dno order by salary desc, commission desc, ename asc) as "부서별 그룹 순위" -- 순위 중복 x
from employee;


-- 부서그륩별 최소값, 최대값 구하기
select max(salary), min(salary) -- 각 1개의 결과만 나옴 
from employee;
 

-- 이렇게 하면 각각이 그룹이 됨 
select dno, ename, salary, 
MIN(salary)  -- 그룹함수
MAX(salary) 
from EMPLOYEE
group by dno, ename, salary; -- 그룹 : 부서 사원명 급여
 
 
-- 해결
select dno,  -- ename, salary 넣으면 안 됨 
MIN(salary) as "부서별 최소 급여", -- 그룹함수
MAX(salary) as "부서별 최대 급여"
from EMPLOYEE
group by dno; --부서별 그룹으로 (각 부서는 1개씩만 출력되므로 다른 것들도 1개씩만 출력되어야 함)
order by dno;
-- 위 방법은  ename, salary 출력할 수 없음 (1:n  => 1:1이어야 출력)               
 
 
-- 해결
select dno, ename, salary,
MIN(salary) keep(DENSE_RANK FIRST order by salary asc) OVER(partition by dno) as "부서별 최소 급여",
MAX(salary) keep(DENSE_RANK LAST order by salary asc) OVER(partition by dno) as "부서별 최대 급여"
from employee;  

