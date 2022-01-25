--<북스 13장-사용자 권한과 테이블 스페이스>
--교재 308p
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
--	그러나 unlimited tablespace 사용시 문제 발생 가능성 (default tablespaced)
--...

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

/*

SQL> conn system/1234
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
SQL> create table sampletb1(no number);
create table sampletb1(no number)
*
ERROR at line 1:
ORA-01950: no privileges on tablespace 'SYSTEM'

*/


--1. 실패 해결 방법-1 : 처음부터 unlimited tablespace 권한을 준다 
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

select username, tablespace_name, max_bytes
from dba_ts_quotas --quota가 설정된 user만 표시
where username in ('USER01');

