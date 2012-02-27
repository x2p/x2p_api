-- Displays several performance indicators and comments on the value.
connect / as sysdba

set serveroutput on
set linesize 1000
set feedback off

select * from v$database;

prompt

declare v_value number;

function format(p_value in number)
	return varchar2 IS
begin
	return lpad(to_char(round(p_value,2),'990.00') || '%',8,' ') || ' ';
end;

begin
-- ------------------------------
-- - Dictionary Cache Hit Ratio -
-- ------------------------------
select (1 - (sum(getmisses)/(sum(gets) + sum(getmisses)))) * 100 into v_value from v$rowcache;

DBMS_Output.Put('Dictionary Cache Hit Ratio       : ' || Format(v_value));
if v_value < 90 then
	DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 90%');
else
	DBMS_Output.Put_Line('Value Acceptable.');
end if;

-- -------------------------
-- Library Cache Hit Ratio -
-- -------------------------
select (1 - (sum(reloads)/(sum(pins) + sum(reloads)))) * 100 into v_value from v$librarycache;

DBMS_Output.Put('Library Cache Hit Ratio       : ' || Format(v_value));
if v_value < 99 then
        DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 99%');
else
        DBMS_Output.Put_Line('Value Acceptable.');
end if;

-- ---------------------------------
-- DB Block Buffer Cache Hit Ratio -
-- ---------------------------------

select (1 - (phys.value / (db.value + cons.value))) * 100 into v_value from v$sysstat phys, v$sysstat db, v$sysstat cons where phys.name = 'physical reads' and db.name = 'db block gets' and cons.name = 'consistent gets';

DBMS_Output.Put('DB Block Buffer Cache Hit Ratio       : ' || Format(v_value));
if v_value < 89 then
        DBMS_Output.Put_Line('Increase DB_BLOCK_BUFFERS parameter to bring value above 89%');
else
        DBMS_Output.Put_Line('Value Acceptable.');
end if;

-- -----------------
-- Latch Hit Ratio -
-- -----------------
select (1 - (sum(misses)/sum(gets))) * 100 into v_value from v$latch;

DBMS_Output.Put('Latch Hit Ratio       : ' || Format(v_value));
if v_value < 98 then
        DBMS_Output.Put_Line('Increase number of latches to bring value above 98%');
else
        DBMS_Output.Put_Line('Value Acceptable.');
end if;

-- -----------------
-- Disk Sort Ratio -
-- -----------------

select (disk.value/mem.value) * 100 into v_value from v$sysstat disk, v$sysstat mem where disk.name = 'sorts (disk)' and mem.name = 'sorts (memory)';

DBMS_Output.Put('Disk Sort Ratio       : ' || Format(v_value));
if v_value > 5 then
        DBMS_Output.Put_Line('Increase SORT_AREA_SIZE parameter to bring value above 89%');
else
        DBMS_Output.Put_Line('Value Acceptable.');
end if;

-- -------------------------
-- Rollback Segement Waits -
-- -------------------------

select (sum(waits) / sum (gets)) * 100 into v_value from v$rollstat;

DBMS_Output.Put('Rollback Segment Waits       : ' || Format(v_value));
if v_value > 5 then
        DBMS_Output.Put_Line('Increase Number of Rollback Segments to bring value above 89%');
else
        DBMS_Output.Put_Line('Value Acceptable.');
end if;

-- ---------------------
-- Dispatcher Workload -
-- ---------------------

select NVL((sum(busy) / (sum(busy) + sum(idle))) * 100,0) into v_value from v$dispatcher;

DBMS_Output.Put('Dispatcher Workload       : ' || Format(v_value));
if v_value > 50 then
        DBMS_Output.Put_Line('Increase MTS_DISPATCHERS to bring value above 89%');
else
        DBMS_Output.Put_Line('Value Acceptable.');
end if;

end;
/

prompt 
set feedback on

exit
