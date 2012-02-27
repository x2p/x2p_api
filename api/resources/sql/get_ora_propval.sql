-- Get all database property values
connect / as sysdba

set linesize 200
column property_value format A50

select property_name, property_value from database_properties order by property_name; 

exit
