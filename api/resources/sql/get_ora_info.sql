-- SQL script to get general information about oracle database
connect / as sysdba

set pagesize 1000
set linesize 100
set feedback off

select * from v$instance;
select * from v$version;
select * from v$sga;
select * from v$controlfile;
select substr(d.name,1,60) "Datafile", NVL(d.status,'UNKNOWN') "Status", d.enabled "Enabled", LPad(To_Char(Round(d.bytes/1024000,2),'99999900'),10,' ') "Size (M)" from v$datafile d order by 1;
select * from v$logfile;

prompt
set pagesize 14
set feedback on

exit
