-- Displays I/O info on all database sessions.
connect / as sysdba

set linesize 500
set pagesize 1000
column username format A15

select NVL(s.username, '(oracle)') as username, s.osuser, s.sid, s.serial#, si.block_gets, si.consistent_gets, si.physical_reads, si.block_changes, si.consistent_changes from v$session s, v$sess_io si where s.sid = si.sid order by s.username, s.osuser;

set pagesize 14

exit
