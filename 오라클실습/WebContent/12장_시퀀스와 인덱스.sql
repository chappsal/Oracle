--<북스 12장-시퀀스와 인덱스>
--1. 시퀀스 생성
--※ 시퀀스 : 테이블 내의 유일한 숫자를 자동 생성
--오라클에서는 데이터가 중복된 값을 가질 수 있으나
--'개체 무결성'을 위해 항상 유일한 값을 갖도록 하는 '기본키'를 두고 있음
--시퀀스는 기본키가 유일한 값을 반드시 갖도록 자동 생성하여 사용자가 직접 생성하는 부담감을 줄임

create sequence 시퀀스명
[start with 시작숫자] --시작 숫자의 디폴트 값은 증가할 때 minvalue, 감소할 때 maxvalue
[increment by 증감숫자] --증감 숫자가 양수면 증가, 음수면 감소 (기본 값 : 1)
                             
[minvalue 최소값 | nominvalue] --nominvalue(기본값) : 증가일 때 1, 감소일 때 -10의 26승까지
                             --minvalue : 최소값 설정, 시작 숫자와 작거나 같아야 하고 maxvalue보다 작아야 함
                             
[maxvalue 최대값 | nomaxvalue] --nomaxvalue(기본값) : 증가일 때 10의 27까지, 감소일때 -1까지
                             --maxvalue 최대값 : 최대값 설정, 시작 숫자와 같거나 커야하고 minvalue보다 커야 함
                             
[cycle | nocycle(기본값)]   	 --cycle  	: 최대값까지 증가 후 최소값부터 다시 시작
						  	 --nocycle  : 최대값까지 증가 후 그 다음 시퀀스를 발급 받으려면 에러 발생

[cache n | nocache] 	 	 --cache n  : 메모리상에 시퀀스 값을 미리 할당 기본값은 20
                         	 --nocache  : 메모리상에 시퀀스 값을 미리 할당하지 않음(관리X)

[order | noorder(기본값)]	  	 --order    : 병렬 서버를 사용할 경우 요청 순서에 따라 정확하게 시퀀스를 생성하기를 원할 때 order로 지정
						  	 --			    단일 서버일 경우 이 옵션과 관계 없이 정확히 요청 순서에 따라 시퀀스가 생성

-------------------------------------------------------------------------
--sequence1

create sequence sample_test;

select sequence_name, min_value, max_value, increment_by, cycle_flag
from user_sequences
where sequences_name in upper('sample_test');

--sequence2

create sequence sample_seq
start with 10
increment by 3 
maxvalue 20
cycle --10 13 16 19 -> 1 4 7 10 13 16 19 -> 
nocache;


select sequence_name, min_value, max_value, increment_by, cycle_flag
from user_sequences
where sequences_name in upper('sample_seq');

--sequence3

create sequence sample_seq2
start with 10
increment by 3;


select sequence_name, min_value, max_value, increment_by, cycle_flag, cache_size
from user_sequences --   -1		1E+28=10E+27  	  3			   N 		20
where sequence_name in upper('sample_seq2');


select sample_seq.nextval, sample_seq.currval from dual;
select sample_seq.nextval, sample_seq.currval from dual;
select sample_seq.nextval, sample_seq.currval from dual;
select sample_seq.nextval, sample_seq.currval from dual;
select sample_seq.nextval, sample_seq.currval from dual;
select sample_seq.nextval, sample_seq.currval from dual;





--1.1 NEXTVAL -> CURRVAL (★★사용 순서 주의)
--NEXTVAL : 다음 값 (★새로운 값 생성) 다음에
--CURRVAL : 시퀀스의 현재 값 알아냄

--<currval,nextval 사용할 수 있는 경우>
--서브쿼리가 아닌 select문
--insert문의 values절
--update문의 set절

--<currval,nextval 사용할 수 없는 경우>
--view의 select문
--distinct 키워드가 있는 select문
--group by, having, order by 절이 있는 select문
--select, delete, update의 서브쿼리
--create table, alter table 명령의 default값



select sample_seq2.nextval from dual;  --10
select sample_seq2.currval from dual;  --실패: 정의되지 않음

select sample_seq2.nextval, sample_seq2.currval from dual; --13 13 순서 관계 없이 실행됨
select sample_seq2.currval, sample_seq2.nextval from dual; --16 16
--sample_seq2.nextval 다음 값 생성 -> sample_seq2.currval 현재 값 알아냄




--1.2 시퀀스를 기본 키에 접목하기
--부서 테이블의 기본 키인 부서 번호는 바드시 유일한 값을 가져와 함
--유일한 값을 자동 생성해주는 시퀀스를 통해 순차적으로 증가하는 컬럼 값 자동 생성

--실습위해 dept12 테이블 생성
create table dept12
as
select * from department
where 0=1;
--테이블 구조만 복사(단, 제약 조건은 복사 안 됨. dno는 기본 키 아님)


--dno에 제약조건 추가
alter table dept12
add primary key(dno); 


select * from dept12;


--기본 키에 접목시킬 시퀀스 생성
create sequence dno_seq
start with 10
increment by 10; --nocycle이 기본값


insert into dept12 values(dno_seq.nextval,'ACCOUNTING','NEW YORK'); --10
insert into dept12 values(dno_seq.nextval,'RESEARCH','DALLAS'); --20
insert into dept12 values(dno_seq.nextval,'SALES','CHICAGO'); --30
insert into dept12 values(dno_seq.nextval,'OPERATIONS','BOSTON'); --40

select * from dept12;


--2. 시퀀스 수정 및 제거 

--<수정 불가>
-- start with 시작숫자 
-- 이미 사용 중인 시퀀스의 시작 값을 변경할 수 없으므로, 시작 번호를 바꾸려면 이전 시퀀스 drop 삭제 후 생성

--<수정 시 주의>
-- 증가 : 최소 값이 현재 들어있는 값보다 높을 수 없다.
-- 감소 : 최대 값이 현재 들어있는 값보다 낮을 수 없다. 
--ex) 최대값 9999 시작하여 10씩 감소 -> 최대값 5000으로 변경 X : 이미 insert한 값 중 5000이 넘는 것들은 무효화 되기 때문




alter sequence 시퀀스명 --시퀀스도 DDL(데이터 정의어)이므로 alter문으로 수정 가능
--[start with 시작숫자] --수정 불가, create에서만 사용
[increment by 증감숫자] --증감 숫자가 양수면 증가, 음수면 감소 (기본 값 : 1)
                             
[minvalue 최소값 | nominvalue] --nominvalue(기본값) : 증가일 때 1, 감소일 때 -10의 26승까지
                             --minvalue : 최소값 설정, 시작 숫자와 작거나 같아야 하고 maxvalue보다 작아야 함
                             
[maxvalue 최대값 | nomaxvalue] --nomaxvalue(기본값) : 증가일 때 10의 27까지, 감소일때 -1까지
                             --maxvalue 최대값 : 최대값 설정, 시작 숫자와 같거나 커야하고 minvalue보다 커야 함
                             
[cycle | nocycle(기본값)]   	 --cycle  	: 최대값까지 증가 후 최소값부터 다시 시작
						  	 --nocycle  : 최대값까지 증가 후 그 다음 시퀀스를 발급 받으려면 에러 발생

[cache n | nocache] 	 	 --cache n  : 메모리상에 시퀀스 값을 미리 할당 기본값은 20
                         	 --nocache  : 메모리상에 시퀀스 값을 미리 할당하지 않음(관리X)

[order | noorder(기본값)]	  	 --order    : 병렬 서버를 사용할 경우 요청 순서에 따라 정확하게 시퀀스를 생성하기를 원할 때 order로 지정
						  	 --			    단일 서버일 경우 이 옵션과 관계 없이 정확히 요청 순서에 따라 시퀀스가 생성




select sequence_name, min_value, max_value, increment_by, cycle_flag, cache_size
from user_sequences --   -1		1E+28=10E+27  	  3			   N 		20
where sequence_name in upper('dno_seq');


--최대값을 50으로 수정
alter sequence dno_seq
maxvalue 50;

--최대값 확인
select sequence_name, min_value, max_value, increment_by, cycle_flag, cache_size
from user_sequences --   1		    50  	     10			   N 		20
where sequence_name in upper('dno_seq');


insert into dept12 values(dno_seq.nextval,'COMPUTING','SEOUL'); --50
insert into dept12 values(dno_seq.nextval,'COMPUTING','DAEGU'); --실패

select * from dept12;

--시퀀스 제거
drop sequence dno_seq;
insert into dept12 values(60,'COMPUTING','DAEGU'); 


------------------------------------------------------------------------------------------------

--3. 인덱스 : DB 테이블에 대한 검색 속도를 향상시켜주는 자료 구조
--			특정 컬럼에 인덱스를 생성하면 해당 컬럼의 데이터들을 정렬하여 별도의 메모리 공간에 데이터의 물리적 주소와 함께 저장됨

				index					table 
			Data	Location		Location Data
			김		1				1		 김
쿼리실행->		김		3				2		 이
			김		1000			3		 김
			이		2				4	 	 박
			박		4				...
									1000	 김

--		       사용자의 필요에 의해서 직접 생성할 수도 있지만
--		       데이터 무결성을 확인하기 위해서 수시로 데이터를 검색하는 용도로 사용되는 기본키나 유일키(unique)는 인덱스 자동 생성
-- user_indexES 또는 user_idn_columns (컬럼 이름까지 검색 가능) 데이터 사전에서 index 객체 확인 가능

-- index 생성 : create index 인덱스명 on 테이블명 (컬럼1, 컬럼2, 컬럼3....);
-- index 삭제 : drop index 인덱스명;

									
/*
<index 생성 전략>

생성된 인덱스를 가장 효율적으로 사용하려면 데이터의 분포도는 최대한으로 
그리고 조건절에 호출 빈도는 자주 사용되는 컬럼을 index로 생성하는 것이 좋다.
인덱스는 특정 컬럼을 기준으로 생성하고 기준이 된 컬럼으로 '정렬된 index 테이블'이 생성됨
이 기준 컬럼은 최대한 중복이 되지 않는 값이 좋다.
가장 최선은 pk로 인덱스를 생성하는 것.

1. 조건 절에 자주 등장하는 컬럼
2. 항상 =으로 비교되는 컬럼
3. 중복되는 데이터가 최소한인 컬럼
4. order by절에서 자주 사용되는 컬럼
5. 조인 조건으로 자주 사용되는 컬럼																											
*/									
			
									
									
									
--두 테이블에 자동으로 생성된 index 보기
select index_name, table_name, column_name
from user_idn_columns
where table_name in ('EMPLOYEE', 'DEPARTMENT');

--사용자가 직접 index 생성
create index idx_employee_ename
on employee(ename);

--확인
select index_name, table_name, column_name
from user_idn_columns
where table_name in ('EMPLOYEE');

--하나의 테이블에 index가 많으면 DB 성능에 좋지 않은 영향을 미칠 수 있다 -> index 제거
drop index idx_employee_ename;

--확인
select index_name, table_name, column_name
from user_idn_columns
where table_name in ('EMPLOYEE');


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--교재 299p
--인덱스 내부 구조는 B-Tree(Balanced Tree = 균형트리)으로 구성되어 있음
--컬럼에 인덱스를 설정하면 이를 B-Tree도 생성되어야 하기 때문에
--인덱스 생성하기 위한 시간, 추가 공간이 필요

--인덱스 생성 후에 새로운 행을 추가하거나 삭제할 경우
--인덱스로 사용된 컬럼 값도 함께 변경 -> 내부 구조(B-Tree)도 함께 변경
--오라클 서버가 이 작업을 자동으로 발생하므로 인덱스가 있는 경우의 DML 작업이 훨씬 무거워짐
--계획성 없이 너무 많은 인덱스를 지정하면 오히려 성능을 저하시킬 수 있다

--최대 3개의 자식을 갖는 B-Tree에서 3을 찾는다면 
--				4(root=뿌리)노드
--		2				6
--	1		3		5		7


--300p 표 정리
-- <인덱스 사용해야 하는 경우>
--테이블의 행 수 많을 때
--where문에 해당 컬럼이 많이 사용될 때
--검색 결과가 전체 데이터의 2~4% 정도일 때
--join에 자주 사용되는 컬럼이나 null을 포함하는 컬럼이 많을 때

-- <인덱스 사용하지 말아야 하는 경우>
--테이블의 행 수 적을 때
--where문에 해당 컬럼이 많이 사용되지 않을 때
--검색 결과가 전체 데이터의 10~15% 이상일 때
--테이블에 DML작업이 많은 경우, 즉 입력 수정 삭제 등이 자주 일어날 때

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--★ 교재 이외 내용
--ex) 인덱스 사용해야 하는 경우
create table emp12
as
select *
from employee; --제약조건 복사 x

select distinct ename 
from emp12
where dno=10;


--쿼리문의 조건이
--1. 테이블 전체 행의 수 : 10000건
--2. 위 쿼리문이 전체 쿼리문 중 95% 사용됨
--3. 쿼리문의 결과로 구해지는 행 : 200건 정도라면 dno 컬럼은 인덱스를 사용하는 것이 효율적
--						  검색 결과가 전체 데이터의 2~4% 정도이므로 인덱스가 있어야 빠른 검색이 가능하기 때문

--인덱스가 생성된 후에 새로운 행이 추가 삭제 수정 작업이 잦으면
--node의 갱신이 주기적으로 일어나 '단편화' 현상 발생
--단편화? 삭제된 레코드의 인덱스 값 자리가 비게 되는 현상
-- 		=> 검색 성능 저하
--따라서
alter index idx_employee_ename rebuild; --index 다시 생성하여 
--기존의 단편화가 많은 index를 버리는 작업을 해야만 빠른 효율을 낼 수 있다

--<테이블에서 컬럼의 데이터가 입력, 수정, 삭제될 경우 해당 컬럼에 의해 생성된 인덱스에 대해서 재구성해야 하는 이유>

--1. 인덱스를 구성하는 B*트리에서는 인덱스 키에 의해 일정한 정렬 순서를 유지.
--	  새로운 노드가 추가되면, 이 노드에 의해 인덱스 정렬 순서를 재구성해야 인덱스 키의 정렬 순서를 유지 가능
--2. 단편화 현상을 해결하여 검색 성능 향상 위해

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--4. 인덱스 종류 (301p)

--4.1 고유/비 고유 인덱스
--고유 인덱스    : 기본키(unique + not null)나 유일키처럼 유일한 값을 갖는 컬럼에 생성된 인덱스
--			 unique 있으면 (ex) 부서 테이블의 부서 번호

--비고유 인덱스 : 중복된 데이터를 갖는 컬럼에 생성된 인덱스
--			 unique 없으면 (ex) 부서 테이블의 부서명이나 지역명

create unique index 인덱스명
on 테이블명(컬럼명);


--고유 인덱스 지정
create unique index idx_dept_dno
on dept12(dno); 
--실패: 위에서 기본키 제약조건 추가하면서 자동 index 생성됨
--such column list already indexed


--자동 생성된 dno의 index를 찾아서 제거
--방법 1 : 실패 - 자동 생성된 dno의 index를 찾아서 제거하는 방법
select index_name, table_name, column_name
from user_ind_columns
where table_name in('DEPT12');

drop index SYS_C007077; --제약조건명 이름과 같음


--방법 2 : 성공 - dno:기본키 제약조건 제거 gn -> 다시 dno에 고유 인덱스 지정하는 방법
--dno : 기본키 제약조건 제거
select table_name, constraint_name, constraint_type
from user_constraints
where table_name in ('DEPT12');

alter table dept12
drop constraint SYS_C007077 cascade;

--dno에 고유 인덱스 지정하기 - 성공
create unique index idx_dept_dno
on dept12(dno);

create unique index idx_dept_loc
on dept12(loc);

---------------------------지금까지 생성한 인덱스는 '단순 인덱스' (한 개의 컬럼으로 구성한 인덱스)

--4.2 결합 인덱스 : 두 개 이상의 컬럼으로 구성한 인덱스
create index idx_dept_complex
on dept12(dname,loc);


--idx_dept_complex 인덱스를 이용하여 검색 속도를 높이는데 사용되는 예
select *
from dept12
where dname=' ' and loc=' ';
--그런데 위 쿼리가 거의 사용되지 않는다면 오히려 성능 저하 발생


select *
from dept12
where dname=' ';
--dname에 index가 없으면
--dnama과 loc를 결합하여 생성한 idx_dept_complex 인덱스를 사용하여 검색


--따라서 전체 테이블 검색보다 더 효율적

--4.3 함수 기반 인덱스 : 수식이나 함수를 적용하여 만든 인덱스
create index idx_emp12_salary12
on emp12(salary * 12)= 수식이므로 컬럼명이 없어서 가상 컬럼 생성됨


select table_name, constraint_name, constraint_type
from user_constraints
where table_name in ('EMP12');



--혼자해보기-------------------------------------

--1. 사원 테이블의 사원 번호가 자동으로 생성되도록 시퀀스를생성
--2. EMP001테이블을 생성(사원번호 number(4) 기본키, 사원이름 varchar2(10, 가입일)
--사원번호롤 시퀀스로부터 발급

--3. EMP001 테이블의 모든 얼럼을 ㅋ인덱스로 설정하되 인덱스 이름을 IDX_EMP01_ENAME로 지정

