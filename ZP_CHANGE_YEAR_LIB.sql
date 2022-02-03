create or replace procedure  ZP_CHANGE_YEAR_LIB(
    pPRN          number,
    pOLD_YEAR     varchar2,
    pNEW_YEAR     varchar2,
    pVDKCOPY      number,
    pVERCOPY      number,
    pPARAMCOPY    number,
    pPROCRN       varchar2 default null,
    pJURPERS      number   default null,
    sOUTMSG   out number
)
as
    vREP_NOTE     varchar2(4000);
    vPROC_NAME    varchar2(4000);
    nJURPERS      number;
    nCATEGORY     number;
    vPAGE_NUM     varchar2(4000);
    vREP_CODE     varchar2(200);
    nTYPE         number;
    nNUMB         number;
    vDEV_COMM     varchar2(4000);
    nKIND         number;
    nROLE         number;
    nSUPPORT_SIGN number;
    nORDERNUMB    number;
    nSTATUS       number;
    vPARAMS       varchar2(4000);
    nHIDDEN       number;

-----------------------------------

    nVERSION      number;
    nNUMB_PROC    varchar2(4000);
    nMARK         number;
    nMARKRN       number;

-----------------------------------

    nRNREP        number;
    nRNPROC       number;
    nRNVDK        number;

    nIDENT        number;

-----------------------------------

    sMESS         varchar2(4000);

procedure INSERT_LOG(p_log in varchar2, p_ident in number)
as
begin
    insert into Z_CHANGE_YEAR_LOG(IDENT, LOGSTRING) values(p_ident, p_log);
end;

begin
    begin
        select nvl(max(IDENT), 0) + 1
        into nIDENT
        from Z_CHANGE_YEAR_LOG;
    exception when others then
        nIDENT := 1;
    end;

    sOUTMSG := nIDENT;

    -- Создание копии отчета
    begin
        select replace(REP_NOTE, pOLD_YEAR, pNEW_YEAR),
               PROC_NAME,
               CATEGORY,
               JURPERS,
               PAGE_NUM,
               replace(REP_CODE, pOLD_YEAR, pNEW_YEAR),
               TYPE,
               DEV_COMM,
               KIND,
               ROLE,
               SUPPORT_SIGN,
               ORDERNUMB,
               STATUS,
               PARAMS,
               HIDDEN
        into vREP_NOTE,
             vPROC_NAME,
             nCATEGORY,
             nJURPERS,
             vPAGE_NUM,
             vREP_CODE,
             nTYPE,
             vDEV_COMM,
             nKIND,
             nROLE,
             nSUPPORT_SIGN,
             nORDERNUMB,
             nSTATUS,
             vPARAMS,
             nHIDDEN
        from Z_RPT_LIB
        where numb = pPRN;
    exception when others then
        vREP_NOTE     := null;
        vPROC_NAME    := null;
        nCATEGORY     := null;
        nJURPERS      := null;
        vPAGE_NUM     := null;
        vREP_CODE     := null;
        nTYPE         := null;
        vDEV_COMM     := null;
        nKIND         := null;
        nROLE         := null;
        nSUPPORT_SIGN := null;
        nORDERNUMB    := null;
        nSTATUS       := null;
        vPARAMS       := null;
        nHIDDEN       := null;
    end;

    begin
        select NUMB
        into nNUMB
        from Z_RPT_LIB
        where REP_NOTE = vREP_NOTE;
    exception when others then
        nNUMB := null;
    end;

    if nNUMB is null then

        if pPARAMCOPY is null then
            vPARAMS := null;
        end if;


        nRNREP := gen_id();
        nNUMB  := gen_id();

        insert into Z_RPT_LIB(RN,
                              PROC_NAME,
                              REP_NOTE,
                              CATEGORY,
                              JURPERS,
                              PAGE_NUM,
                              REP_CODE,
                              TYPE,
                              NUMB,
                              DEV_COMM,
                              KIND,
                              ROLE,
                              SUPPORT_SIGN,
                              ORDERNUMB,
                              STATUS,
                              PARAMS,
                              HIDDEN)
        values(nRNREP,
               vPROC_NAME,
               vREP_NOTE,
               nCATEGORY,
               nJURPERS,
               vPAGE_NUM,
               vREP_CODE,
               nTYPE,
               nNUMB,
               vDEV_COMM,
               nKIND,
               nROLE,
               nSUPPORT_SIGN,
               nORDERNUMB,
               nSTATUS,
               vPARAMS,
               nHIDDEN);
        commit;
        INSERT_LOG('Создана библиотека отчетов '||vREP_NOTE, nIDENT);
    else
        INSERT_LOG('Библиотека отчетов уже существует ' || vREP_NOTE, nIDENT);
    end if;

    -- Создание копий процедур отчетов
    for rec in(
        select D.*, J.NAME
        from Z_RPT_LIB_DETAIL D, Z_JURPERS J
        where PRN = pPRN
            and ((pPROCRN is null) or (PROC_NAME = pPROCRN and (pJURPERS is null or pJURPERS = JURPERS)))
            and D.JURPERS = J.RN (+)
    )
    loop
        nJURPERS := nvl(pJURPERS, rec.JURPERS);

        INSERT_LOG('Процедура '||rec.PROC_NAME, nIDENT);

        -- sOUTMSG := sOUTMSG || 'Процедура '||rec.PROC_NAME;

        nRNPROC := null;
        nMARKRN := null;

        -- Проверка существования процедуры
        begin
            select RN
            into nRNPROC
            from Z_RPT_LIB_DETAIL
            where PROC_NAME = replace(rec.PROC_NAME, to_char(pOLD_YEAR), to_char(pNEW_YEAR))
            and nJURPERS = JURPERS and rec.PRN = rec.PRN;
            INSERT_LOG(' существует ', nIDENT);
            -- sOUTMSG := sOUTMSG||' существует' || chr(10);
        exception when others then
            nMARKRN := 1;
        end;

        if nRNPROC is null then
            ZP_CHANGE_YEAR_PROC(
                pPROC      => rec.PROC_NAME,
                pPREV_YEAR => to_char(pOLD_YEAR),
                pNEW_YEAR  => to_char(pNEW_YEAR),
                pOUTMESS   => sMESS,
                pPREVPROC  => null
            );
            nRNPROC := gen_id();
        end if;

        if pVERCOPY is not null then
            begin
                select RN
                into nVERSION
                from Z_VERSIONS
                where NEXT_PERIOD = pNEW_YEAR
                    and JUR_PERS = nJURPERS;
            exception when others then
                nVERSION := rec.VERSION;
                INSERT_LOG('отсутствует версия у ГРБС '||nJURPERS||' добавлена в существующую', nIDENT);
            end;
        else nVERSION := NULL;
        end if;

        -- Копирование парамаетров
        if pPARAMCOPY is null then
            vPARAMS := null;
        else vPARAMS := rec.PARAMS;
        end if;

        if nMARKRN = 1 then
            nNUMB_PROC := '#'||to_char(gen_id());
            insert into Z_RPT_LIB_DETAIL(RN,
                                         JURPERS,
                                         PROC_NAME,
                                         PRN,
                                         NUMB,
                                         STATUS,
                                         ROLE,
                                         VDKRN,
                                         VERSION,
                                         PARAMS,
                                         HIDDEN)
            values(nRNPROC,
                   nJURPERS,
                   replace(rec.PROC_NAME, pOLD_YEAR, pNEW_YEAR),
                   nNUMB,
                   nNUMB_PROC,
                   rec.STATUS,
                   rec.ROLE,
                   rec.VDKRN,
                   rec.VERSION,
                   vPARAMS,
                   rec.HIDDEN);
            commit;

            INSERT_LOG(' скопирована', nIDENT);
            -- sOUTMSG := sOUTMSG || ' скопирована' || chr(10);

            if pPARAMCOPY is not null then
                INSERT_LOG(' параметры скопированы', nIDENT);
                -- sOUTMSG := sOUTMSG ||' параметры скопированы'|| chr(10);
            end if;

        elsif pPARAMCOPY is not null then
            update Z_RPT_LIB_DETAIL
            set PARAMS = vPARAMS where rn = nRNPROC;

            INSERT_LOG(' параметры заменены', nIDENT);
            -- sOUTMSG := sOUTMSG ||' параметры заменены'|| chr(10);
        end if;

        -- Копирование VDK
        if pVDKCOPY is not null then
            for VDK in(
                select *
                from Z_RPT_LIB_VDK_LINKS
                where LIBDET_RN = rec.RN
            )
            loop
                -- Проверка существования подключенных VDK
                begin
                    select RN
                        into nRNVDK
                    from Z_RPT_LIB_VDK_LINKS
                    where JURPERS = nJURPERS
                    and VDK_RN = VDK.VDK_RN
                    and LIBDET_RN = nRNPROC
                    and (EXPR = VDK.EXPR or (EXPR is null and VDK.EXPR is null));
                exception when others then
                    nRNVDK := null;
                end;

                if nRNVDK is null then
                    nRNVDK := gen_id();
                    insert into Z_RPT_LIB_VDK_LINKS(RN,
                                                    JURPERS,
                                                    USE_SIGN,
                                                    VDK_RN,
                                                    LIBDET_RN,
                                                    NAME,
                                                    CHJUST,
                                                    ERRTEXT,
                                                    EXPR)
                    values(nRNVDK,
                           nJURPERS,
                           VDK.USE_SIGN,
                           VDK.VDK_RN,
                           nRNPROC,
                           VDK.NAME,
                           'копирование',
                           VDK.ERRTEXT,
                           VDK.EXPR);
                    commit;
                    INSERT_LOG(' ВДК скопированы', nIDENT);
                end if;
            end loop;
        end if;
    end loop;
end;
​
