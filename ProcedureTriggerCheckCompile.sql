create or replace procedure DV_TESTTRIGG_CHECK_COMPILE
as
cLINE       clob;
vOldTEXT    varchar2(4000) := 'ZF_CHECKPRIV2'; -- название изменяемой процедуры
nCountSec   number := 0; -- счетчик успешных триггеров
nCountUn    number := 0; -- счетчик нескомпилированных триггеров
nCOUNT      number := 0; -- общий счетчик (для проверки)


begin
    for rec in (
        select TRIGGER_NAME NAME, DESCRIPTION, TRIGGER_BODY BODY from ALL_TRIGGERS
    )
    loop
        cLINE := to_clob(rec.BODY);
        if instr(cLINE, vOldTEXT) > 0 then
            nCOUNT := nCOUNT + 1;
            begin
                execute immediate 'alter trigger '||rec.NAME||' compile';
                dbms_output.put_line('Триггер '||rec.NAME||' скомпилирован');
                nCountSec := nCountSec + 1;
            exception when others then
                dbms_output.put_line('Триггер '||rec.NAME||' не скомпилирован');
                execute immediate 'alter trigger '||rec.NAME||' compile';
                nCountUN := nCountUN + 1;
            end;
        end if;
    end loop;

    dbms_output.put_line('Итого  '||nCOUNT||chr(10)||'    скомпилировано ---------- '||nCountSec||' триггеров'||chr(10)||'    не скомпилировано ------- '||nCountUN||' триггеров');
end;
