--<북스 13장-사용자 권한과 테이블 스페이스>
--[테이블스페이스]--------------------------------------------------------------------
--오라클에서는 Data file이라는 물리적 파일 형태로 저장하고
--이러한 Data file이 하나 이상 모여서 Tablesapce라는 논리적인 공간을 형성함

/* 물리적 단위 			   논리적 단위
 * 					 DATABASE
 * 						|
 * datafile			TABLESPACE : 데이터 저장 단위 중 가장 상위에 있는 단위
 * (*.dbf)				|
 * 					 segment : 1개의 segment 여러 개의 extent로 구성  ex)table, 트리거 등
 * 						|
 * 					 extent  : 1개의 extent는 여러 개의 DB block으로 구성
 * 						|		extent는 반드시 메모리에 연속된 공간을 잡아야 함(단편화가 많으면 조각 모음으로 단편화 해결)
 * 					DB block : 메모리나 디스크에서 I/O(Input/Output) 할 수 있는 최소 단위			
 * 
 * 
 * 
 */

--※ 트리거 : 데이터의 입력, 추가, 삭제 등의 이벤트가 발생할 때마다 자동으로 수행되는 사용자 정의 프로시저


-- [ 테이블스페이스 관련 Dictionary ] 
/*
    .DBA_TABLESPACES : 모든 테이블스페이스의 저장정보 및 상태정보를 갖고 있는 Dictionary
    .DBA_DATA_FILES  : 테이블스페이스의 파일정보
    .DBA_FREE_SPACE  : 테이블스페이스의 사용공간에 관한 정보
    .DBA_FREE_SPACE_COALESCED : 테이블스페이스가 수용할 수 있는 extent의 정보
*/


--[Tablespace의 종류]
--첫 째, contents로 구분하면 3가지 유형
select tablespace_name, contents
from dba_tablespaceS;--모든 테이블스페이스의 저장 정보 및 상태 정보
--1. Permanent Tablespace
--2. Undo Tablespace
--3. Temporary Tablespace 로 구성.

--둘 째, 크게 2가지 유형으로 구분하면
--즉, 오라클 DB는 크게 2가지 유형의 Tablespace로 구성
--1. 'SYSTEM' 테이블스페이스(필수, 기본) : 
--    DB설치시 자동으로 기본적으로 가지고 있는 테이블 스페이스로,
--    별도로 테이블 스페이스를 지정하지 않고 테이블, 트리거, 프로시저 등을 생성했다면
--    이 시스템 테이블 스페이스에 저장되었던 것
--    ex) Data Dictionary 정보, 프로시저, 트리거, 패키지,
--    System Rollback segment 포함
--    사용자 데이터 포함 가능(예)오라클 설치하면 기본으로 저장되어 있는 emp나 dept테이블(이 테이블들은 사용자들이 사용가능함) 
--    
--    ※ rollback segment란? rollback시commit하기 전 상태로 돌리는데 그 돌리기 위한 상태를 저장하고 있는 세그먼트
          
--    DB운영에 필요한 기본 정보를 담고 있는 Data Dictionary Table이 저장되는 공간으로
--    DB에서 가장 중요한 Tablespace
--    중요한 데이터가 담겨져 있는 만큼 문제가 생길 경우 자동으로 데이터베이스를 종료될 수 있으므로
--    일반 사용자들의 객체들을 저장하지 않는 것을 권장함.
--    (혹여나 사용자들의 객체에 문제가 생겨 데이터베이스가 종료되거나 
--     완벽한 복구가 불가능한 상황이 발생할 수 있기 때문에...)

--2. 'NON-SYSTEM' 테이블스페이스
--   보다 융통성있게 DB를 관리할 수 있다.
--   ex) rollback segment,
--	 	 Temporary Segment,
--   	 Application Data Segment,
--   	 Index Segment,
--   	 User Data Segment 포함

--   	 ※ Temporary세그먼트란?
--        :order by를 해서 데이터를 가져오기 위해선 임시로 정렬할 데이터를 가지고 있을 공간이 필요하고
--         그 곳에서 정렬한 뒤 데이터를 가져오는데 이 공간을 가리킨다.

select default_tablespace --'system'
from user_users;

--1. <테이블 스페이스 생성> --------------------------------------------------------


creata tablespace [테이블스페이스명]
datafile '파일경로'
size 초기 데이터 파일 크기 설정 (M)
AUTOextend on next 10M --초기 크기 공간을 모두 사용하는 경우 자동으로 파일 크기가 커지는 기능
					   --K(킬로 바이트), M(메가 바이트) 두 단위 사용 가능
MAXSIZE 250M		   --데이터 파일이 최대로 커질 수 있는 크기 지정(기본값:unlimited 무제한)
uniform size 1M; 	   --extend 1개의 크기


--(1)
create tablespace test_data
datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data01.dbf' 
size 10M
default storage(initial 2M 		 --최초 extend 크기 
				next 1M    		 --다 차면 1M 생성
				minextents 1 	 --생성할 extent 최소 개수
				maxextents 121   --생성할 extent 최대 개수
				pctincrease 50); --기본값, 다음에 할당할 extent의 수치를 %로 나타냄
				
--pctincrease 50%으로 지정하면 처음은 1M(=1024K), 두번째부터는 next 1M의 절반인 512K, 그 다음은 512K의 절반.. 할당
--dafault storage 생략시 '기본값으로 지정된 값'으로 설정됨

--(2) tablespace 조회하기
select tablespace_name status, segment_space_management
from dba_tablespaces; --모든 테이블 스페이스의 storage 정보 및 상태 정보




--2. <테이블 스페이스 변경> --------------------------------------------------------

--test_data 테이블 스페이스에 datafile 1개 더 추가
alter tablespace test_data
add datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data02.dbf' 
size 10M;
--10M + 10M => 총 20M
--즉, 물리적으로 2개의 데이터 파일로 구성된 하나의 테이블 스페이스가 생성됨




--3. <테이블 스페이스의 data file 크기 조절> --------------------------------------------------------

--3-1. 자동으로 크기 조절
alter tablespace test_data
add datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data03.dbf' 
size 10M
autoextend on next 1M
maxsize 250M;
--test_data03.dbf의 크기인 10M를 초과하면 자동으로 1M씩 늘어나 최대 250M까지 커짐
--★ 주의 : maxsize 250M -> 기본값 unlimited(무제한)으로 변경하면 문제 발생 가능성
--		ex. 리눅스에서는 파일 1개를 핸드링할 수 있는 사이즈가 2G로 한정
--			따라서, data file이 2G를 넘으면 오류 발생. 가급적 maxsize 지정


--3-2. 수동으로 크기 조절(★★ 주의 : alter database)
alter database 
datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data02.dbf' 
resize 20M; --10M -> 20M로 크기 변경
--하나의 테이블 스페이스(test_data)=총 40M인 3개의 물리적 datafile로 구성됨



--4. <data file 용량 조회> -----------------------------------------------------------------


select tablespac_name, bytes/1024/1024MB, file_name, autoextensible as "auto"
from dba_data_files; --file_name : 파일경로

--테이블스페이스의 수집 가능한 extend에 대한 통계 정보 조회
select tablespace_name, total_extends, extens_coalesced, percent_extents_coalesced
from dba_free_space_coalesced; --테이블스페이스가 수용할 수 있는 extent 정보
--total_extens : 사용가능한 extent 수
--extens_coalesced : 수집된 사용가능한 extent 수
--percent_extents_coalesced : 그 비율은 몇 %?




--5. <테이블 스페이스 단편화된 공간 수집 : 즉, 디스크 조각모음> --------------------------------------------

alter tablespace 테이블스페이스명 coalesce;
alter tablespace test_data coalesce;



--6. <테이블스페이스 제거하기> -------------------------------------------------------------------

--형식
drop tablespace 테이블스페이스명; --테이블스페이스 내에 객체가 존재하면 삭제 불가
[including contents]; --<옵션 1> 해결법 : 모든 내용(=객체) 포함하여 삭제
					  --그러나, 탐색기에서 확인해보면 물리적 data file은 삭제 안 됨
[including contents and datafiles] --<옵션 2> 해결법 : 물리적 data file까지 함께 삭제
[cascade contraints] --<옵션 3> 제약조건까지 함께 삭제

--먼저, 테이블 하나 생성(test_data 테이블스페이스에 )
create table test3(
a char(1))
tablespace test_data;


drop tablespace test_data; --실패: tablespace not empty, use including contents option


--해결법 <옵션 1>
drop tablespace test_data
including contents;
--성공. 탐색기에서 확인해보면 물리적 data file은 삭제가 안 됨
--따라서 직접 삭제해줘야 함


--해결법 <옵션 2>
drop tablespace test_data
including contents and datafiles;


--해결법 <옵션 3>
--그런데 'A테이블스페이스의 사원 테이블(dno:FK)'이 'B테이블스페이스의 부서 테이블(dno:PK)'를 참조하는 상황에서
--B테이블스페이스를 위 방법(옵션 2)처럼 삭제한다면 '참조 무결성'에 위배되므로 오류 발생
drop tablespace B
including contents and datafiles
cascade contraints; --제약조건까지 삭제하여 해결 가능


--교재 308p--------------------------------------------------------------------

--1. 사용권한
--오라클 보안 정책 : 2가지 (시스템 보안 -> 시스템 권한, 데이터 보안 -> 객체 권한) (모든 데이터는 객체. 뷰, 테이블...)
--[1] 시스템 보안 : DB에 접근 권한을 설정. 사용자 계정과 암호 입력해서 인증 받아야 함
--[2] 데이터 보안 : 사용자가 생성한 객체에 대한 소유권을 가지고 있기 때문에
--				데이터를 조회하거나 조작할 수 있지만 다른 사용자는 객체의 소유자로부터 접근 권한을 받아야 사용 가능

--권한 : 시스템을 관리하는 '시스템 권한', 객체를 사용할 수 있도록 관리하는 '객체 권한'

--308p 표-시스템 권한 : 'DBA 권한을 가진 사용자'가 시스템 권한 부여

--1. create session : DB 접속(=연결) 권한
--2. create table 	: 테이블 생성 권한
--3. unlimited tablespace : 테이블 스페이스에 블록을 할당할 수 있도록 해주는 권한
--	  그러나 unlimited tablespace 사용시 문제 발생 가능성 (default tablespace인 'SYSTEM'의 중요 데이터 보안상 문제 발생 가능성)
--	  그래서 default tablespace를 다른 테이블 스페이스(USERS)로 변경하고
--	 quota절로 사용할 용량을 할당해준다 (이 때, unlimited로 할당해도 무방)

--4. create sequence  : 시퀀스 생성 권한
--5. create view 	  : 뷰 생성 권한
--6. select any table : 권한을 받은 자가 어느 테이블, 뷰라도 검색 가능
--이 외에도 100여개 이상의 시스템 권한 존재
--DBA는 사용자를 생성할 때마다 적절한 시스템 권한 부여


--<시스템 권한>--------------------------------------------------------------------
--소유한 객체의 사용 권한 관리 명령어 : DCL(GRANT, REVOKE)

/*

시스템 권한 형식 : 반드시 'DBA 권한'을 가진 사용자만 권한 부여 가능
GRANT 'create session' TO 사용자 | 롤(role) | public(모든 사용자) [with ADMIN option]

*/


--<실습 시작>
--'DBA 권한'을 가진 system으로 접속하여 사용자의 이름, 암호 지정하여 사용자 생성



SQL> conn system/1234 --접속
Connected.
SQL> create user user01 identified by 1234;

User created.

SQL> conn user01/1234
ERROR:
ORA-01045: user USER01 lacks CREATE SESSION privilege; logon denied


Warning: You are no longer connected to ORACLE.
SQL> conn system/1234
Connected.

SQL> grant create session, create table to user01;
Grant succeeded.

SQL> conn user01/1234
Connected.
SQL> create table sampletb1(no number); --테이블 생성 실패

*
ERROR at line 1:
ORA-01950: no privileges on tablespace 'SYSTEM'




--1. 실패 해결 방법-1 : 처음부터 unlimited tablespace 권한을 준다 (권장 x)
SQL> conn system/1234
Connected.
SQL> grant unlimited tablespace to user01;
Grant succeeded.
--default_tablespace인 'SYSTEM' 영역을 무제한 사용
--그러나, 권한 부여시 문제 발생할 수 있음('SYSTEM' 테이블 스페이스의 중요한 데이터의 보안상 문제)

--'user01'의  default_tablespace 확인
select username, default_tablespace
from dba_users
where username in upper('user01'); --default_tablespace : SYSTEM


--2. 실패 해결 방법-2 : SYSTEM 테이블 스페이스의 중요한 데이터의 보안상 default_tablespace 변경
alter user user01
default tablespace users -- user : 사용자 데이터가 들어갈 테이블 스페이스 
quota 5M on users;

alter user user01
default tablespace users
quota unlimited on users; -- unlimited : 용량을 제한하지 않고 사용 가능 (-1로 표시됨)

alter user user01
default tablespace test_data
quota 2M on test_data;
--quota unlimited on test_data;

select username, tablespace_name, max_bytes
from dba_ts_quotas --quota가 설정된 user만 표시
where username in ('USER01');

--------------------------------------------------------------------------------------
--<안전한 user 생성 방법> 					※ 롤 참조(321p 표)
--보통 user를 생성하고
--grant connect, resource to 사용자명;   
--를 습관적으로 권한을 주는데 resource 롤을 주면 'unlimited tablespace'까지 주기에
--'SYSTEM' 테이블 스페이스를 무제한으로 사용 가능하게 되어
--'보안'혹은 관리상에 문제가 될 소지를 가지고 있다

--[1] USER 생성
create user user02 identified by 1234;

--[2] 권한 부여
grant connect, resource to user02;

--[3] 'unlimited tablespace' 권한 회수 (권한을 준 DBA만 회수 가능)
revoke unlimited tablespace from user02;

--[4] user2의 default tablespace 변경 , quota절로 영역 할당
alter user user02
default tablespace users 
quota 10M on users;
--quota unlimited on users;


--'user02'의 default)tablespace 확인
select username, default_tablespace
from dba_users
where lower(username) in ('user02');


select username, tablespace_name, max_bytes --아래 쿼리문 실행 후 확인하면 max_bytes : -1 (=무제한)
from dba_ts_quotas --quota가 설정된 user만 표시
where lower(username) in ('user02');


alter user user02
quota unlimited on users;


--[with admin option]------------------------------------------------------------------------

/*
 * [with admin option] 옵션
 * 1. 권한을 받은 자 (=GRANTEE 그란티)가 시스템 권한 또는 롤을 다른 사용자 또는 또 다른 롤에게 부여할 수 있도록 해줌
 * 2. with admin option으로 주어진 권한은 계층적이지 않음(=평등하다)
 * 		즉, b_user가 a_user의 권한을 revoke(박탈)할 수 있음. 평등하기 때문에
 * 3. revoke시에는 with admin option 명시하지 않아도 됨
 * 4. with admin option으로 grant한 권한은 revoke시 cascade되지 않는다
 * 
 */


--<실습 1>

--1. DBA 권한을 가진 system으로 접속해 a_user 생성 후, DB접속 권한(with admin option) 부여
--		=> a_user는 다른 유저에게 권한 부여 가능
conn system/1234
create user a_user identified by 1234;
grant create session to a_user with admin option;

-- b_user 생성
create user b_user identified by 1234;


--2. a_user로 접속하여 b_user에게  DB접속 권한(with admin option) 부여
--		=> b_user는 다른 유저에게 권한 부여 가능
conn a_user/1234
grant create session to b_user with admin option;


--3. b_user로 접속하여 a_user의  DB접속 권한 회수 
conn b_user/1234
revoke create session from a_user;

--4. a_user로 접속하려면
conn a_user/1234 --실패


---------------------------------------------------------------------------

--2. 롤 (role) 321p : 다양한 권한을 효과적으로 관리할 수 있도록 관련된 권한끼리 묶어 놓은 것
--여러 사용자에게 보다 간편하게 권한을 부여할 수 있도록 함
--grant connect, resource, dba to system;
--※ DBA 롤 : 시스템 자원을 무제한적으로 사용, 시스템 관리에 필요한 모든 권한
--※ CONNECT 롤 : Oracle 9i까지 - 롤에 부여된 권한 8가지, Oracle 10g 부터는 'create session'권한만 가지고 있음
--※ RESOURCE 롤 : 객체(테이블, 뷰 등)을 생성할 수 있도록 하기 위해 '시스템 권한'을 그룹화

---------------------------------------------------------------------------
---------------------------------------------------------------------------

--소유한 객체의 사용 권한 관리를 위한 명령어 : DCL(GRANT, REVOKE)
--<객체 권한 부여> (312p) : 'DB 관리자나 객체 소유자'가 다른 사용자에게 권한을 부여할 수 있다

/*

객체 권한 형식 : 반드시 'DBA 권한'을 가진 사용자만 권한 부여 가능
GRANT 'select | insert | update | delete.. ON 객체 ' TO 사용자 | public(=모든 사용자) [with GRANT option]
ex) GRANT ALL on 객체  to 사용자 (all:모든 객체 권한)

*/

--1. select on 테이블명
--조회 권한
connect system/1234
alter user user01 identified by 1234; 
grant create session to user01; --접속 권한 (시스템 권한)

conn user01/1234 --접속 성공

select * from employees; --user01의 employees 조회 => 실패, 테이블 없음

select * from hr.employees; --(hr:교육용 계정) / 실패 : user01은 객체를 조회할 권한이 없기 때문, hr로부터 받지 않음 

conn hr/1234 --접속시 

/*
--1. lock이면 
system/1234
alter user hr account unlock; --잠김 해제

--2. 비밀번호가 틀렸으면 (invalid username/password; logon denied)
alter user hr identified by 1234; --비밀번호 변경
*/
conn hr/1234 --다시 접속 성공 => user01에게 '테이블 조회 권환' 부여
grant select on employees to user01;

conn user01/1234 --다시 접속
select * from hr.employees; --조회 성공

