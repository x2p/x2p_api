-- Displays memory allocations for the current database process.
connect / as sysdba

set linesize 200
column username format A20
column module format A20

select NVL(a.username,'(oracle)') as username, a.module, a.program, trunc(b.value/1024) as memory_kb from v$session a, v$sesstat b, v$statname c where a.sid = b.sid and b.statistic# = c.statistic# and c.name = 'session pga memory' and a.program is not null order by b.value desc;

exit
