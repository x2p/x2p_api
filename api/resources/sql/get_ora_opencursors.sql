-- Get a list of all cursors currently open.
connect / as sysdba

set linesize 200

select a.user_name, a.sid, a.sql_text from v$open_cursor a order by 1,2;

exit
