-- Displays a list of all the system parameters.
connect / as sysdba

set linesize 500
column name value A30
column value format A60

select sp.name, sp.type, sp.value, sp.isses_modifiable, sp.issys_modifiable, sp.isinstance_modifiable  from v$system_parameter sp order by sp.name;

exit
