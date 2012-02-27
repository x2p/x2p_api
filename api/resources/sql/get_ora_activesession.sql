-- Displays info on all active database sessions.
connect / as sysdba

set linesize 500
set pagesize 1000
column username format A15
column machine format A25
column logon_time format A20

select NVL(s.username, '(oracle)') as username, s.osuser, s.sid, s.serial#, p.spid, s.lockwait, s.status, s.module, s.machine, s.program, to_char(s.logon_Time, 'DD-MON-YYYY HH24:MI:SS') as logon_time from v$session s, v$process p where s.paddr = p.addr and s.status = 'ACTIVE' order by s.username, s.osuser;

set pagesize 14

exit
