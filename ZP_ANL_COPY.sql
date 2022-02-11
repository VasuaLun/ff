create or replace procedure  ZP_ANL_COPY(
    pPROC      varchar2 default null
)
as
    vPROC      varchar2(4000) := nvl(pPROC, 'ZP_GET_ORGROUP_BY_RN');
    vFIELD     varchar2(4000);
    vTAB_NAME  varchar2(4000);
    vPROC_NAME varchar2(4000);

    nSTART     number;
    nFINISH    number;
    nMARK      number;

    nCOMMIT    number;

    nONELINES  number;
    nONELINEF  number;
    nDOTS      number;
    nDOTF      number;
begin

    for rec in (
        select LINE, TEXT
            from ALL_SOURCE
        where NAME = vPROC
        order by LINE asc
    )
    loop
        if rec.TEXT like '%/*%' then nCOMMIT := 1; end if;
        if rec.TEXT like '%*/%' then nCOMMIT := null; end if;

        if nCOMMIT is null then
            if rec.LINE != 1 and (rec.TEXT like '%ZP_%BY_RN%' or rec.TEXT like '%ZP_%_ADD%') then
                nSTART  := null;
                nFINISH := null;

                nSTART := instr(rec.TEXT, 'ZP_');
                nFINISH := instr(rec.TEXT, '(', nSTART + 1);

                if nFINISH = 0 then zp_exception(0, 'финал 0'); end if; -- тест

                vPROC_NAME := trim(substr(rec.TEXT, nSTART, nFINISH - nSTART));

                htp.p(vPROC_NAME);
            end if;

            if nMARK = 1 then

                if rec.TEXT like '%)%' then
                    nMARK := null;
                    vFIELD := trim(replace(rec.TEXT, ')'));
                else
                    vFIELD := trim(replace(rec.TEXT, ','));
                end if;

                htp.p(vFIELD);

            elsif rec.TEXT like '%insert%' then
                nSTART  := null;
                nFINISH := null;

                nMARK := 1;
                nSTART := instr(rec.TEXT, 'Z_');
                if nSTART = 0 then
                    nSTART := instr(rec.TEXT, 'X_');
                    if nSTART = 0 then
                        nSTART := instr(rec.TEXT, 'A_');
                    end if;
                end if;
                nFINISH := instr(rec.TEXT, '(', nSTART + 1);

                vTAB_NAME := trim(substr(rec.TEXT, nSTART, nFINISH - nSTART));

                htp.p(vTAB_NAME);

                nONELINES := instr(rec.TEXT, ')');

                if nONELINES > 0 then
                    nDOTF := 1;
                    nONELINEF := instr(rec.TEXT, '(');
                    while nDOTF != nONELINEF
                    loop
                        nDOTS := instr(rec.TEXT, ',', nDOTF);
                        nDOTF := instr(rec.TEXT, ',', nDOTS + 1);
                        -- zp_exception(0, nONELINES||'  '||nDOTS||' '||nDOTF||' '||rec.TEXT);
                        if nDOTF = 0 then
                            nDOTF := nONELINEF;
                        end if;
                        vTAB_NAME := trim(substr(rec.TEXT, nDOTS + 1, nDOTF - nDOTS - 1));
                        htp.p(vTAB_NAME);
                    end loop;
                    nMARK := null;
                end if;
            end if;
        end if;
    end loop;
end;
