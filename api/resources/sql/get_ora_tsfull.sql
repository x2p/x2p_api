-- Get a list of all tablespaces nearly full.
connect / as sysdba

set serveroutput on
set pagesize 1000
set linesize 255
set feedback off

prompt
prompt Tablespaces nearing 0% free
prompt ***************************
select a.tablespace_name, b.size_kb, a.free_kb, trunc((a.free_kb/b.size_kb) * 100) "FREE_%" from (select tablespace_name, trunc(sum(bytes)/1024) free_kb from dba_free_space group by tablespace_name) a, (select tablespace_name, trunc(sum(bytes)/1024) size_kb from dba_data_files group by tablespace_name) b where a.tablespace_name = b.tablespace_name and round((a.free_kb/b.size_kb) * 100,2) < 10
/

prompt
set feedback on
set pagesize 18

exit
