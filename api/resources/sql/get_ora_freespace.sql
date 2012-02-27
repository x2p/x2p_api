-- Get space usage for each datafiles
connect / as sysdba

set serveroutput on
set pagesize 1000
set linesize 255
set feedback off

select substr(df.tablespace_name,1,20) "Tablespace Name", substr(df.file_name,1,40) "File Name", round(df.bytes/1024/1024,2) "Size (M)", round(e.used_bytes/1024/1024,2) "Used (M)", round(f.free_bytes/1024/1024,2) "Free (M)", Rpad(' '|| Rpad('X',round(e.used_bytes*10/df.bytes,0), 'X'),11,'-') "% Used" from DBA_DATA_FILES DF, (select file_id, sum(Decode(bytes,NULL,0,bytes)) used_bytes from dba_extents group by file_id) E, (select Max(bytes) free_bytes, file_id from dba_free_space group by file_id) f where e.file_id (+) = df.file_id and df.file_id = f.file_id (+) order by df.tablespace_name, df.file_name;

prompt
set feedback on
set pagesize 18 

exit
