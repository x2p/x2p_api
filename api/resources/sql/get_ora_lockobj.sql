-- Displays a list of all locked objects.
connect / as sysdba

set linesize 500
set pagesize 1000
set verify off
column owner format A20
column username format A20
column object_owner format A20
column object_name format A30
column locked_mode format A15 

select b.session_id as sid, NVL(b.oracle_username, '(oracle)') as username, a.owner as object_owner, a.object_name, decode(b.locked_mode, 0 ,'None', 1, 'Null (NULL)', 2, 'Row-S (SS)', 3, 'Row-X (XX)', 4, 'Share (S)', 5, 'S/Row-X (SSX)', 6, 'Exclusive (X)', b.locked_mode) locked_mode, b.os_user_name from dba_objects a, v$locked_object b where a.object_id = b.object_id order by 1, 2, 3, 4; 

set pagesize 14
set verify on

exit
