create or replace procedure  ZP_CHANGE_YEAR_LIB(
    pPRN          number,
    pOLD_YEAR     varchar2,
    pNEW_YEAR     varchar2,
    pVDKCOPY      number,
    pVERCOPY      number,
    pPARAMCOPY    number,
    pPROCRN       number default null,
    sOUTMSG   out varchar2
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

-----------------------------------

    sMESS         varchar2(4000);

begin
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
        sOUTMSG := sOUTMSG || ' создана библиотека отчетов vREP_NOTE' || chr(10);
    end if;

    -- Создание копий процедур отчетов
    for rec in(
        select *
        from Z_RPT_LIB_DETAIL
        where PRN = pPRN
            and ((pPROCRN is null) or (pPROCRN = RN))
    )
    loop
        sOUTMSG := sOUTMSG || rec.PROC_NAME ||' скопирована' || chr(10);
        nMARK := null;
        nRNPROC := null;
        nMARKRN := null;

        -- Проверка существования процедуры
        begin
            select RN
            into nRNPROC
            from Z_RPT_LIB_DETAIL
            where PROC_NAME = replace(rec.PROC_NAME, to_char(pOLD_YEAR), to_char(pNEW_YEAR))
            and rec.JURPERS = JURPERS and rec.PRN = rec.PRN;
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
                    and JUR_PERS = rec.JURPERS;
            exception when others then
                nVERSION := NULL;
                sOUTMSG := sOUTMSG||'отсутствует версия у ГРБС'||rec.JURPERS;
                nMARK := 1;
            end;
        else nVERSION := NULL;
        end if;

        if nMARK = 1 then -- заменить на null после теста
            -- Копирование парамаетров
            if pPARAMCOPY is null then
                vPARAMS := null;
            else vPARAMS := rec.PARAMS;
                sOUTMSG := sOUTMSG || rec.PROC_NAME ||' параметры скопирована';
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
                       rec.JURPERS,
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
                        where JURPERS = VDK.JURPERS
                        and VDK_RN = VDK.VDK_RN
                        and LIBDET_RN = nRNPROC
                        and EXPR = VDK.EXPR;
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
                               VDK.JURPERS,
                               VDK.USE_SIGN,
                               VDK.VDK_RN,
                               nRNPROC,
                               VDK.NAME,
                               'копирование',
                               VDK.ERRTEXT,
                               VDK.EXPR);
                        commit;
                    end if;
                end loop;
            end if;
        end if;
    end loop;
    -- zp_exception(0, sOUTMSG);
end;



​
