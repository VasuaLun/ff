create or replace procedure DV_TESTTRIGG_CHECK_COMPILE
as
cLINE       clob;
vNewTEXT    varchar2(4000) := 'ZF_CHECKPRIV3();';
nCOUNT      number := 0;


begin
    for rec in (
        select TRIGGER_NAME NAME, DESCRIPTION, TRIGGER_BODY BODY from ALL_TRIGGERS
    )
    loop
        cLINE := to_clob(rec.BODY);

        if instr(cLINE, vNewTEXT) > 0 then
            if 
            nCOUNT := nCOUNT + 1; -- счетчик скомпиленных триггеров
        end if;
    end loop;

    dbms_output.put_line(nCOUNT); -- вывод количества проверенных триггеров
end;
