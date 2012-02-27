-- Get a list of all sp parameters.
connect / as sysdba

set linesize 500
column name format A30
column value format A60
column displayvalue format A60

select sp.sid, sp.name, sp.value, sp.display_value from v$spparameter sp order by sp.name, sp.sid;

exit
