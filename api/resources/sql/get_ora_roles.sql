-- Get a list of all roles and privleges.
connect / as sysdba

set serveroutput on
set verify off

select a.granted_role "Role", a.admin_option "Adm" from user_role_privs a;
select a.privilege "Privilege", a.admin_option "Adm" from user_sys_privs a;

set verify on

exit
