-- Displays information about all jobs currently running.
connect / as sysdba

set linesize 500
set pagesize 1000
set verify off

select a.job "Job", a.sid, a.failures "Failures", substr(to_char(a.last_date,'DD-Mon-YYYY HH24:MI:SS'),1,20) "Last Date", substr(to_char(a.this_date,'DD-Mon-YYYY HH24:MI:SS'),1,20) "This Date" from dba_jobs_running a;

set pagesize 14
set verify on

exit
