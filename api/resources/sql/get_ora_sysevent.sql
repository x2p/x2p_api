-- Displays info on all system events.
connect / as sysdba

set linesize 200

select event, total_waits, total_timeouts, time_waited, average_wait, time_waited_micro from v$system_event order by event;

exit
