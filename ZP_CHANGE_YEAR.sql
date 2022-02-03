create or replace procedure  ZP_CHANGE_YEAR_PROC(
    pPROC      varchar2,
    pPREV_YEAR varchar2,
    pNEW_YEAR  varchar2,
    pOUTMESS   out varchar2,
    pPREVPROC  varchar2 default null
)
as
DATA_BODY   CLOB;
nSTART      number;
nFINISH     number;
nFINISH1    number;
nFINISH2    number;
nFINISH3    number;
vPROC_NAME  varchar2(4000);
vPREV_PROC  varchar2(4000);
vNEW_TEXT   varchar2(4000);

vMESSAGE    varchar2(4000);

-- Процедура по проверки на существования процедур внутри изначальной процедуры
function CHECK_PROC_STATUS(p_proc in varchar2)
    return number
as
    p_res number;
    vSTAT varchar2(100);
begin
    begin
            select STATUS
            into vSTAT
            from USER_OBJECTS
            where OBJECT_NAME = p_proc;
    exception when others then
        vSTAT := null;
    end;

    if vSTAT = 'VALID' then
        p_res := 1;
    else p_res := 0;
    end if;

    return (p_res);
end;

-- Основное тело процедуры
begin

    vPREV_PROC := nvl(pPREVPROC, pPROC); -- Проверка на итерацию
    htp.p(vPREV_PROC|| '  ' || pPROC);
    DATA_BODY := 'create or replace ' ;

    for rec in (
        select LINE, TEXT
            from ALL_SOURCE
        where NAME = pPROC
        order by line asc
    )
    loop dbms_output.put_line('Д''Артаньян');

        vNEW_TEXT := rec.TEXT;

        -- if (rec.TEXT like '%ZP_REP%'||pPREV_YEAR||'%' and rec.TEXT not like '%'||vPREV_PROC||'%') then zp_exception(0, rec.TEXT); end if;

        if rec.LINE != 1 and (rec.TEXT like '%'||vPREV_PROC||'%' or rec.TEXT like '%ZP_%'||pPREV_YEAR||'%') then

            -- Выделение названия процедуры
            nSTART := instr(rec.TEXT, 'ZP_');

            -- После процедуры или пробел, или (, или '
            nFINISH1 := instr(rec.TEXT, ' ', nSTART + 1);
            nFINISH2 := instr(rec.TEXT, '(', nSTART + 1);
            nFINISH3 := instr(rec.TEXT, '''', nSTART + 1);

            if nFINISH1 = 0 then nFINISH1 := 10000; end if;
            if nFINISH2 = 0 then nFINISH2 := 10000; end if;
            if nFINISH3 = 0 then nFINISH3 := 10000; end if;

            nFINISH := least(nFINISH1, nFINISH2, nFINISH3);

            if nFINISH = 10000 then zp_exception(0, 'cvnbncv'); end if;

            vPROC_NAME := trim(substr(rec.TEXT, nSTART, nFINISH - nSTART));

            -- Проверка ее статуса, в случае ее отсутствия создаем и компилируем
            if CHECK_PROC_STATUS(replace(vPROC_NAME, pPREV_YEAR, pNEW_YEAR)) = 0 and vPROC_NAME != pPROC and (vPROC_NAME != pPREVPROC or pPREVPROC is null) then
                ZP_CHANGE_YEAR_PROC(vPROC_NAME, pPREV_YEAR, pNEW_YEAR, vMESSAGE, vPREV_PROC);
                vNEW_TEXT := replace(rec.TEXT, pPREV_YEAR, pNEW_YEAR);
                vMESSAGE := vMESSAGE || chr(10) || replace(vPROC_NAME, pPREV_YEAR, pNEW_YEAR) || ' создана на на основе ' || vPROC_NAME;
            else
                vNEW_TEXT := replace(vNEW_TEXT, pPREV_YEAR, pNEW_YEAR);
            end if;
        elsif rec.LINE = 1 then
            vNEW_TEXT := replace(rec.TEXT, pPREV_YEAR, pNEW_YEAR);
        end if;

        vNEW_TEXT := replace(vNEW_TEXT, pPREV_YEAR, pNEW_YEAR);

        DATA_BODY := DATA_BODY || vNEW_TEXT;

    end loop;

    begin
        execute immediate DATA_BODY;
    exception when others then
        zp_exception(0, 'Ошибка при создании ' ||nvl(pPROC, pPREVPROC || 'пред')||' ; '|| SUBSTR(SQLERRM, 1, 200)||DATA_BODY||vPROC_NAME);
    end;

    pOUTMESS := vMESSAGE;
end;
