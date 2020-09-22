SET AUTOCOMMIT ON；
delete from testzhangwei WHERE ID=1;
SELECT * FROM testzhangwei;
SELECT * FROM testLock;
drop table testzhangwei;
commit;

-- 触发器
create or replace trigger test_tigger_1 after insert
on testzhangwei
for each row
begin
 INSERT INTO testLock VALUES(111,'test111');
end;

create or replace trigger test_tigger_2 after insert
on testzhangwei
for each row
begin
 INSERT INTO testLock VALUES(112,'test112');
end;
drop trigger test_tigger_1;
drop trigger test_tigger_2;
commit;


---3)死锁查看：
select s.username,l.object_id,l.object_name, l.session_id,s.serial#, s.lockwait,s.status,s.machine,s.program 
from v$session s,v$locked_object l where s.sid = l.session_id;

SELECT s.username,l.object_id, o.object_name, l.session_id, s.serial#, s.lockwait,s.status,s.machine,s.program 
from v$session s, v$locked_object l, dba_objects o 
where s.sid = l.session_id and o.object_id = l.object_id;


SELECT sid, serial#, username, osuser FROM v$session where sid = 199;
--- 杀锁
alter system kill session '135,10128';  

--失效包查询
SELECT 'ALTER ' ||
       decode(object_type, 'PACKAGE BODY', 'PACKAGE', object_type) || ' ' ||
       object_name || decode(object_type,
                             'PACKAGE BODY',
                             ' COMPILE BODY ; ',
                             'PACKAGE',
                             ' COMPILE SPECIFICATION ; ',
                             ' COMPILE; ') AS c
  FROM user_objects
 WHERE status <> 'VALID'
   AND object_type IN ('FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE',
        'TRIGGER', 'VIEW')
 ORDER BY object_type DESC;
 


select sql_text from v$sql 
where hash_value in   (
select sql_hash_value 
from v$session 
where sid in  (
select session_id 
from v$locked_object)
);  

-- --规范  
-- 创建包头
create or replace package pack_test1 is
  -- 定义过程1
  procedure p_test1(p_1 in varchar2);
  -- 定义函数1
  function f_test1(p_1 in varchar2) return varchar2;
end pack_test1; 
     
      
--主体  
-- 创建包体(名字必须和包头一样)
create or replace package body pack_test1 is
  -- 包全局变量1
  v_param1 varchar(20) := 'default';
  -- 实现过程1
  procedure p_test1(p_1 in varchar2) is 
  begin     
    dbms_output.put_line('p_1的值为：'|| p_1);
    dbms_output.put_line('全局变量的值为：'||v_param1);
    -- 改变全局变量
    v_param1 := p_1;
    dbms_output.put_line('改变后的全局变量值为：'||v_param1);    
  end;
  -- 实现函数1
  function f_test1(p_1 in varchar2) return varchar2 is 
    v_rt varchar2(50);
  begin 
    dbms_output.put_line('获取的全局变量值为：'||v_param1);  
    v_rt := v_param1||'-'||p_1;   
    dbms_output.put_line('返回值为：'||v_rt);    
    return v_rt;
  end f_test1;   
end pack_test1;
      

create or replace package pack_zw_1 is
  -- 定义过程1
  procedure p_zw_1(p_1 in varchar2);
  -- 定义函数1
  function f_zw_1(p_1 in varchar2) return varchar2;
end pack_zw_1;  
--主体  
-- 创建包体(名字必须和包头一样)
create or replace package body pack_zw_1 is
  -- 包全局变量1
  v_param1 varchar(20) := 'default';
  -- 实现过程1
  procedure p_test1(p_1 in varchar2) is 
  begin     
    dbms_output.put_line('p_1的值为：'|| p_1);
    dbms_output.put_line('全局变量的值为：'||v_param1);
    -- 改变全局变量
    v_param1 := p_1;
    dbms_output.put_line('改变后的全局变量值为：'||v_param1);    
  end;
  -- 实现函数1
  function f_test1(p_1 in varchar2) return varchar2 is 
    v_rt varchar2(50);
  begin 
    dbms_output.put_line('获取的全局变量值为：'||v_param1);  
    v_rt := v_param1||'-'||p_1;   
    dbms_output.put_line('返回值为：'||v_rt);    
    return v_rt;
  end f_test1;   
end pack_zw_1;
      
--调用包，这个仅测试用  
-- 调用过程
call pack_test1.p_test1('参数1');

-- 调用函数
select pack_test1.f_test1('参数2') from dual;

select text
from all_source
where owner = 'OPS_DEV'
and type = 'PACKAGE BODY'
and name = 'PACK_TEST1'
order by line


-- 创建函数
create or replace function test_zhangwei_fun1(zw1 in number)
return number
is
result1 number:=3;
begin
  return zw1 + result1;
end;
drop function test_zhangwei_fun1;
drop function test_zhangwei_fun2;
select test_zhangwei_fun1(2) from dual;
select test_zhangwei_fun2(2) from dual;

--- plsql
set serveroutput on size 100
declare
 --定义变量（可选）
  v_id number;
  v_test varchar2(20);
 begin
  --执行部分
  select id,test into v_id,v_test from testzhangwei where id=2;
  dbms_output.put_line('查询到的用户ID为:'||v_id);
  --异常处理（可选）
 exception
  when no_data_found then
    dbms_output.put_line('查询不到制定的用户');
 commit;   
 end;

select SYS_CONTEXT('USERENV', 'SESSION_USER') SCHEMA_NAME,
       spid SPID,
       to_number(substrb(dbms_session.unique_session_id, 1, 4), 'xxxx') SID,
       to_number(substrb(dbms_session.unique_session_id, 5, 4), 'xxxx') SERIAL#,
       to_number(substrb(dbms_session.unique_session_id, 9, 4), 'xxxx') INST_ID
  from v$process
 where addr in
       (select paddr
          from v$session
         where sid = to_number(substrb(dbms_session.unique_session_id, 1, 4),
                               'xxxx'));
