-- Displays the amount of IO for each datafile.
connect / as sysdba

set pagesize 1000
set linesize 300

select substr(d.name,1,50) "File Name", f.phyblkrd "Blocks Read", f.phyblkwrt "Blocks Writen", f.phyblkrd + f.phyblkwrt "Total I/O" from v$filestat f, v$datafile d where d.file# = f.file# order by f.phyblkrd + f.phyblkwrt desc;

set pagesize 18

exit
