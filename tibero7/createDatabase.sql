create database "tibero" 
user sys identified by tibero 
maxinstances 8 
maxdatafiles 100 
character set MSWIN949 
national character set UTF16 
logfile 
    group 1 'log001.log' size 50M, 
    group 2 'log002.log' size 50M, 
    group 3 'log003.log' size 50M 
maxloggroups 255 
maxlogmembers 8 
noarchivelog 
    datafile 'system001.dtf' size 100M autoextend on next 10M maxsize unlimited 
    default temporary tablespace TEMP 
    tempfile 'temp001.dtf' size 100M autoextend on next 10M maxsize unlimited 
    extent management local autoallocate 
    undo tablespace UNDO 
    datafile 'undo001.dtf' size 200M autoextend on next 10M maxsize unlimited 
    extent management local autoallocate
    SYSSUB
    datafile 'syssub001.dtf' size 10M autoextend on next 10M maxsize unlimited
    default tablespace USR
    datafile 'usr001.dtf' size 100M autoextend on next 10M maxsize unlimited
    extent management local autoallocate;

EXIT;