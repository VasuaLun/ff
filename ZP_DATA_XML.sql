create or replace procedure ZP_DATA_XML
(
  nIDENT         number,
  nRN_ORG        number,
  nRESULT        out number,
  sRESULT_MSG    out varchar2
)
as
  pJURPERS       number;
  pVERSION       number(17):= v('P1_VERSION') ;--;
  nROWCNT        pls_integer;
  pORGRN         number;
  nADDEDCOUNT    number;
  nREDACTIONS     number;


  nERROR         pls_integer;
  sERR_MSG       varchar2(4000);
  sErrText       varchar2(4000):= null;
  sSERVCODE         varchar2(4000);
  nCURPFHD       number;
  nCURGZBLANK     number;
  sSHORT_NAME    Z_ORGREG.SHORT_NAME%type;
  nPFHDSTATUS    number;
  nGZBLANKSTATUS number;
  nPFHDRN        number;
  nEXPORTSIGN    number;

  nCNT       number := null;
  nSERVCNT       number;
  nSERVRN        number;
  nQINDRN        number;
  nLINKRN        number;
  nQIND_RN       number;
  nHIST_RN       number;
  nHIST_VALUE    number;
  dDATE          date;
  nNUMB          number;
  nPREVINN       number := null;

begin
    begin
        select nvl(J.REDACTIONS, V.REDACTIONS)
          into nREDACTIONS
          from Z_JURPERS J, Z_VERSIONS V
         where V.JUR_PERS = J.RN
           and V.RN       = pVERSION;
    exception when others then
        nREDACTIONS := null;
    end;

     select count(*)
      into nROWCNT
      from (select *
              from XML_EXP3
             where IDENT = nIDENT);

    if pVERSION is null then
        ZP_EXCEPTION (0, 'Не задана версия.');
    end if;

    -- Бежим по буферной таблице
    for rec in
    (
     select *
       from Z_XML_PARSDATE
      where IDENT = nIDENT
      order by RN
    )
    loop

        -- Провека ГРБС
        if rec.Sv7 is null then
            sERR_MSG  := 'Отсутствует ГРБС ';
            nERROR := nvl(nERROR,0) + 1;
        end if;

        if sERR_MSG is null then -- Не найден ГРБС
            begin
                select RN
                  into pJURPERS
                  from Z_JURPERS
                 where INN = TRIM(rec.Sv7);
            exception when others then
                sERR_MSG  := 'Не найден ГРБС по ИНН: ' || rec.Sv7;
                nERROR := nvl(nERROR,0) + 1;
                pORGRN := null;
                sSHORT_NAME := null;
            end;
        end if;

        if rec.Sv11 is null then
            sERR_MSG  := 'Отсутствует ИНН ';
            nERROR := nvl(nERROR,0) + 1;
        end if;

        if sERR_MSG is null then -- Не найдена организация
            begin
                select RN, SHORT_NAME
                  into pORGRN, sSHORT_NAME
                  from Z_ORGREG
                 where version  = pVERSION
                   and (INN      = TRIM(rec.Sv11) or OMS_CODE = TRIM(rec.Sv11))
                   and CLOSED_SIGN  = 0;
            exception when others then
                sERR_MSG  := 'Не найдена организация по ИНН: ' || rec.Sv11;
                nERROR := nvl(nERROR,0) + 1;
                pORGRN := null;
                sSHORT_NAME := null;
            end;
        end if;

        -- Sv25 - УНРЗ
        if sERR_MSG is null and trim(rec.Sv25) is null
        and trim(rec.Sv20) is null
        then
            sERR_MSG  := 'Не задано УНРЗ и наименование услуги';
            nERROR := nvl(nERROR,0) + 1;
        end if;

        -- Sv26 - наименование показателя
        if sERR_MSG is null and trim(rec.Sv26) is null then
            sERR_MSG  := 'Не указано наименование показателя';
            nERROR := nvl(nERROR,0) + 1;
        end if;

        

        if sERR_MSG is null  then
            begin
            if to_number(nvl(trim(rec.QPLAN4), 0)) < 0 then
                sERR_MSG  := 'Показатель "План 4 квартал" не может быть отрицательным';
                nERROR := nvl(nERROR,0) + 1;
            end if;
            exception when others then
            sERR_MSG  := 'Показатель "План 4 квартал" имеет некорректный формат: '||rec.QPLAN4;
            nERROR := nvl(nERROR,0) + 1;
            end;
        end if;

        if sERR_MSG is null and trim(rec.YPLAN1) is null
           and trim(rec.YPLAN2) is null  and trim(rec.YPLAN3) is null
           and trim(rec.YPLAN4) is null  and trim(rec.YPLAN5) is null
           and trim(rec.QPLAN1) is null  and trim(rec.QPLAN2) is null
           and trim(rec.QPLAN3) is null  and trim(rec.QPLAN4) is null
           and trim(rec.QFACT1) is null  and trim(rec.QFACT2) is null
           and trim(rec.QFACT3) is null  and trim(rec.QFACT4) is null
           and trim(rec.VARCOUNT) is null and trim(rec.YPLAN3_CALC) is null
           then
            sERR_MSG  := 'Не задан ни один показатель';
            nERROR := nvl(nERROR,0) + 1;
        end if;

--------------------------------------------------------------------------------------------------------------
        if nvl(nREDACTIONS, 0) = 1 then
            if rec.INN!= nPREVINN or nPREVINN is null then
                if sERR_MSG is null then
                    nCURGZBLANK := ZF_GET_REDACTION_LAST (pVERSION, pORGRN, 'GZBLANK');
                    if nvl(nCURGZBLANK,0) = 0 then
                        sERR_MSG  := 'Не найдена текущая редакция "Бланк ГЗ". Учреждение: ' || sSHORT_NAME;
                        nERROR := nvl(nERROR,0) + 1;
                    end if;
                end if;

                if sERR_MSG is null then
                    nCURPFHD := ZF_GET_PFHDVERS_LAST (pVERSION, pORGRN);
                    if nvl(nCURPFHD,0) = 0 then
                        sERR_MSG  := 'Не найдена текущая редакция "ПФХД". Учреждение: ' || sSHORT_NAME;
                        nERROR := nvl(nERROR,0) + 1;
                    end if;
                end if;


                if sERR_MSG is null then -- Проверка статуса текущей редакции. Учреждение

                    nGZBLANKSTATUS := ZF_GET_REDACTION_STATUS_LAST (pVERSION, pORGRN, 'GZBLANK');

                    if nGZBLANKSTATUS not in (0,3) then
                        sERR_MSG := 'Редакция "Бланк ГЗ" находится в статусе - '|| ZF_GET_REDACTION_STATUS_NAME (nGZBLANKSTATUS) || '. Изменение данных невозможно. Учреждение: ' || sSHORT_NAME || '.';
                        nERROR := nvl(nERROR,0) + 1;
                    end if;


                    /*nPFHDSTATUS := ZF_GET_PFHDVERS_STATUS_LAST (pVERSION, pORGRN);

                    begin
                        select EXPORT_SIGN
                          into nEXPORTSIGN
                          from Z_PFHD_VERSIONS
                         where RN = nCURPFHD;
                    exception when others then
                        null;
                    end;

                    if nPFHDSTATUS not in (0,3) then
                        if sERR_MSG is not null then
                            sERR_MSG := sERR_MSG||' Редакция "ПФХД" находится в статусе - '|| ZF_GET_REDACTION_STATUS_NAME (nPFHDSTATUS) || '. Признак "Экспортирован" - ' || case nEXPORTSIGN when 1 then 'Да' else 'Нет' end ||'. Изменение данных невозможно. Учреждение: ' || sSHORT_NAME || '.';

                        else
                            sERR_MSG := 'Редакция "ПФХД" находится в статусе - '|| ZF_GET_REDACTION_STATUS_NAME (nPFHDSTATUS) || '. Признак "Экспортирован" - ' || case nEXPORTSIGN when 1 then 'Да' else 'Нет' end ||'. Изменение данных невозможно. Учреждение: ' || sSHORT_NAME || '.';
                            nERROR := nvl(nERROR,0) + 1;
                        end if;
                    end if; */
                end if;
                nPREVINN := rec.Sv7;
            end if;
        end if;

        --------------------------------------------------------------------------------------------------------------

        if sERR_MSG is null then

            if trim(rec.Sv25) is not null then
                begin
                    select count(*) into nSERVCNT
                      from Z_SERVREG
                     where VERSION = pVERSION
                       and UNIQREGNUM_FULL = trim(rec.Sv25);
                exception when others then
                    null;
                end;

                if nvl(nSERVCNT, 0) = 0 then
                    sERR_MSG := 'Не найдена услуга с УНРЗ '||trim(rec.Sv25)|| '.';
                    nERROR := nvl(nERROR,0) + 1;
                end if;
            end if;

            if sERR_MSG is null and trim(rec.Sv20) is not null then
                begin
                    select count(*) into nSERVCNT
                      from Z_SERVREG
                     where VERSION = pVERSION
                       and lower(trim(CODE)) = lower(trim(rec.Sv20));
                exception when others then
                    null;
                end;

                if nvl(nSERVCNT, 0) = 0 then
                    sERR_MSG := 'Не найдена услуга с кратким наименованием: '||trim(rec.Sv20)|| '.';
                    nERROR := nvl(nERROR,0) + 1;
                end if;
            end if;

            /*
            if sERR_MSG is null and trim(rec.SERVNAME) is not null then
                begin
                    select count(*) into nSERVCNT
                      from Z_SERVREG
                     where VERSION = pVERSION
                       and lower(trim(NAME)) = lower(trim(rec.SERVNAME));
                exception when others then
                    null;
                end;

                if nvl(nSERVCNT, 0) = 0 then
                    sERR_MSG := 'Не найдена услуга с полным наименованием: '||trim(rec.SERVNAME)|| '.';
                    nERROR := nvl(nERROR,0) + 1;
                end if;
            end if;
            */

            for qSERV in (select RN SERVRN, CODE SERVCODE
                  from Z_SERVREG
                 where VERSION = pVERSION
                   and (trim(rec.Sv25) is null or UNIQREGNUM_FULL = trim(rec.Sv25))
                   and (trim(rec.Sv20) is null or lower(trim(NAME)) = lower(trim(rec.Sv20)))
                )
            loop
                begin
                    select RN into nLINKRN
                      from Z_SERVLINKS
                     where VERSION = pVERSION
                       and ORGRN = pORGRN
                       and SERVRN = qSERV.SERVRN;
                exception when others then
                    nLINKRN := null;
                    sERR_MSG := 'Не найдена связка учреждение/услуга. Учреждение: '||sSHORT_NAME||'; Услуга: '||qSERV.SERVCODE|| '.';
                    nERROR := nvl(nERROR,0) + 1;
                end;

                if nLINKRN is not null then
                    if sERR_MSG is null and trim(rec.QINDNAME) is not null then
                        begin
                            select RN into nQINDRN
                              from Z_QINDLIST
                             where VERSION = pVERSION
                               and (lower(trim(CODE)) = lower(trim(rec.QINDNAME))
                                 or lower(trim(NAME)) = lower(trim(rec.QINDNAME)));
                        exception when others then
                            nQINDRN := null;
                        end;

                        if nQINDRN is null then
                            sERR_MSG := 'Не найден показатель с наименованием: '||trim(rec.QINDNAME)|| '.';
                            nERROR := nvl(nERROR,0) + 1;
                        end if;
                    end if;

                    if nQINDRN is not null then
                        begin
                        select RN
                          into nQIND_RN
                          from Z_QINDVALS
                         where JUR_PERS = pJURPERS
                           and VERSION  = pVERSION
                           and QIND  = nQINDRN
                           and PRN  = nLINKRN;
                        exception when others then
                            nQIND_RN := null;
                            sERR_MSG := 'Не удалось внести показатель, т.к. не найдена соответствующая строка. Учреждение: '||sSHORT_NAME||'; Услуга: '||qSERV.SERVCODE||'; Показатель: '||rec.QINDNAME;
                            nERROR := nvl(nERROR,0) + 1;
                        end;
                    end if;

                    --    вносим все переданные значения
                    if  sERR_MSG is null then
                        if trim(rec.YPLAN1) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'YPLAN1', rec.YPLAN1, sERR_MSG );
                        end if;

                        if sERR_MSG is null and trim(rec.YPLAN2) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'YPLAN2', rec.YPLAN2, sERR_MSG );
                        end if;

                        if sERR_MSG is null and trim(rec.QFACT1) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'QFACT1', rec.QFACT1, sERR_MSG );
                        end if;

                        if sERR_MSG is null and trim(rec.QFACT2) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'QFACT2', rec.QFACT2, sERR_MSG );
                        end if;

                        if sERR_MSG is null and trim(rec.QFACT3) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'QFACT3', rec.QFACT3, sERR_MSG );
                        end if;

                        if sERR_MSG is null and trim(rec.QFACT4) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'QFACT4', rec.QFACT4, sERR_MSG );
                        end if;

                        if sERR_MSG is null and trim(rec.YPLAN3_CALC) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'YPLAN3_CALC', rec.YPLAN3_CALC, sERR_MSG );
                        end if;

                        if nvl(nREDACTIONS, 0) = 1 then

                            if sERR_MSG is null then
                                if trim(rec.YPLAN3) is not null then
                                    begin
                                        QIND_HISTORY_CHECK(pJURPERS, pVERSION, pORGRN, 'YPLAN3',  nQIND_RN, nCURGZBLANK, nHIST_RN, nHIST_VALUE);

                                        if nHIST_RN is not null and nHIST_VALUE != trim(rec.YPLAN3) then
                                            update Z_QIND_HISTORY set ESUM = trim(rec.YPLAN3), NOTES = nvl(trim(rec.NOTES), 'Автоматическая загрузка')  where RN = nHIST_RN;
                                        elsif nHIST_RN is null then
                                            ZP_QIND_HISTORY_ADD ( pJURPERS, pVERSION, pORGRN , 'YPLAN3',  nQIND_RN, nCURGZBLANK, nvl(trim(rec.NOTES), 'Автоматическая загрузка'), trim(rec.YPLAN3), sErrText);
                                            sERR_MSG := sERR_MSG|| case when sErrText is not null then chr(10)||sErrText else '' end;
                                        end if;
                                    exception when others then
                                    sERR_MSG := sERR_MSG||chr(10)||'Не удалось обновить поле "Отчетный год" значением '||rec.YPLAN3||'. - '||sqlerrm;
                                    end;
                                end if;

                                if trim(rec.YPLAN4) is not null then
                                    begin
                                        QIND_HISTORY_CHECK(pJURPERS, pVERSION, pORGRN, 'YPLAN4',  nQIND_RN, nCURGZBLANK, nHIST_RN, nHIST_VALUE);

                                        if nHIST_RN is not null and nHIST_VALUE != trim(rec.YPLAN4) then
                                            update Z_QIND_HISTORY set ESUM = trim(rec.YPLAN4), NOTES = nvl(trim(rec.NOTES), 'Автоматическая загрузка')  where RN = nHIST_RN;
                                        elsif nHIST_RN is null then
                                            ZP_QIND_HISTORY_ADD ( pJURPERS, pVERSION, pORGRN , 'YPLAN4',  nQIND_RN, nCURGZBLANK, nvl(trim(rec.NOTES), 'Автоматическая загрузка'), trim(rec.YPLAN4), sErrText);
                                            sERR_MSG := sERR_MSG|| case when sErrText is not null then chr(10)||sErrText else '' end;
                                        end if;
                                    exception when others then
                                    sERR_MSG := sERR_MSG||chr(10)||'Не удалось обновить поле "Отчетный год" значением '||rec.YPLAN4||'. - '||sqlerrm;
                                    end;
                                end if;

                                if trim(rec.YPLAN5) is not null then
                                    begin
                                        QIND_HISTORY_CHECK(pJURPERS, pVERSION, pORGRN, 'YPLAN5',  nQIND_RN, nCURGZBLANK, nHIST_RN, nHIST_VALUE);

                                        if nHIST_RN is not null and nHIST_VALUE != trim(rec.YPLAN5) then
                                            update Z_QIND_HISTORY set ESUM = trim(rec.YPLAN5), NOTES = nvl(trim(rec.NOTES), 'Автоматическая загрузка')  where RN = nHIST_RN;
                                        elsif nHIST_RN is null then
                                            ZP_QIND_HISTORY_ADD ( pJURPERS, pVERSION, pORGRN , 'YPLAN5',  nQIND_RN, nCURGZBLANK, nvl(trim(rec.NOTES), 'Автоматическая загрузка'), trim(rec.YPLAN5), sErrText);
                                            sERR_MSG := sERR_MSG|| case when sErrText is not null then chr(10)||sErrText else '' end;
                                        end if;
                                    exception when others then
                                    sERR_MSG := sERR_MSG||chr(10)||'Не удалось обновить поле "Отчетный год" значением '||rec.YPLAN5||'. - '||sqlerrm;
                                    end;
                                end if;

                                if trim(rec.QPLAN1) is not null then
                                    begin
                                    QIND_HISTORY_CHECK(pJURPERS, pVERSION, pORGRN, 'QPLAN1',  nQIND_RN, nCURGZBLANK, nHIST_RN, nHIST_VALUE);

                                    if nHIST_RN is not null and nHIST_VALUE != trim(rec.QPLAN1) then
                                        update Z_QIND_HISTORY set ESUM = trim(rec.QPLAN1), NOTES = nvl(trim(rec.NOTES), 'Автоматическая загрузка')  where RN = nHIST_RN;
                                    elsif nHIST_RN is null then
                                        ZP_QIND_HISTORY_ADD ( pJURPERS, pVERSION, pORGRN , 'QPLAN1',  nQIND_RN, nCURGZBLANK,  nvl(trim(rec.NOTES), 'Автоматическая загрузка'), trim(rec.QPLAN1), sErrText);
                                        sERR_MSG := sERR_MSG|| case when sErrText is not null then chr(10)||sErrText else '' end;
                                    end if;
                                    exception when others then
                                    sERR_MSG := sERR_MSG||chr(10)||'Не удалось обновить поле "План 1 квартал" значением '||rec.QPLAN1||'. - '||sqlerrm;
                                    end;
                                end if;

                                if trim(rec.QPLAN2) is not null then
                                    begin
                                    QIND_HISTORY_CHECK(pJURPERS, pVERSION, pORGRN, 'QPLAN2',  nQIND_RN, nCURGZBLANK, nHIST_RN, nHIST_VALUE);

                                    if nHIST_RN is not null and nHIST_VALUE != trim(rec.QPLAN2) then
                                        update Z_QIND_HISTORY set ESUM = trim(rec.QPLAN2), NOTES = nvl(trim(rec.NOTES), 'Автоматическая загрузка')  where RN = nHIST_RN;
                                    elsif nHIST_RN is null then
                                        ZP_QIND_HISTORY_ADD ( pJURPERS, pVERSION, pORGRN , 'QPLAN2',  nQIND_RN, nCURGZBLANK,  nvl(trim(rec.NOTES), 'Автоматическая загрузка'), trim(rec.QPLAN2), sErrText);
                                        sERR_MSG := sERR_MSG|| case when sErrText is not null then chr(10)||sErrText else '' end;
                                    end if;
                                    exception when others then
                                    sERR_MSG := sERR_MSG||chr(10)||'Не удалось обновить поле "План 2 квартал" значением '||rec.QPLAN2||'. - '||sqlerrm;
                                    end;
                                end if;

                                if trim(rec.QPLAN3) is not null then
                                    begin
                                    QIND_HISTORY_CHECK(pJURPERS, pVERSION, pORGRN, 'QPLAN3',  nQIND_RN, nCURGZBLANK, nHIST_RN, nHIST_VALUE);

                                    if nHIST_RN is not null and nHIST_VALUE != trim(rec.QPLAN3) then
                                        update Z_QIND_HISTORY set ESUM = trim(rec.QPLAN3), NOTES = nvl(trim(rec.NOTES), 'Автоматическая загрузка')  where RN = nHIST_RN;
                                    elsif nHIST_RN is null then
                                        ZP_QIND_HISTORY_ADD ( pJURPERS, pVERSION, pORGRN , 'QPLAN3',  nQIND_RN, nCURGZBLANK,  nvl(trim(rec.NOTES), 'Автоматическая загрузка'), trim(rec.QPLAN3), sErrText);
                                        sERR_MSG := sERR_MSG|| case when sErrText is not null then chr(10)||sErrText else '' end;
                                    end if;
                                    exception when others then
                                    sERR_MSG := sERR_MSG||chr(10)||'Не удалось обновить поле "План 3 квартал" значением '||rec.QPLAN3||'. - '||sqlerrm;
                                    end;
                                end if;

                                if trim(rec.QPLAN4) is not null then
                                    begin
                                    QIND_HISTORY_CHECK(pJURPERS, pVERSION, pORGRN, 'QPLAN4',  nQIND_RN, nCURGZBLANK, nHIST_RN, nHIST_VALUE);

                                    if nHIST_RN is not null and nHIST_VALUE != trim(rec.QPLAN4) then
                                        update Z_QIND_HISTORY set ESUM = trim(rec.QPLAN4), NOTES = nvl(trim(rec.NOTES), 'Автоматическая загрузка') where RN = nHIST_RN;
                                    elsif nHIST_RN is null then
                                        ZP_QIND_HISTORY_ADD ( pJURPERS, pVERSION, pORGRN , 'QPLAN4',  nQIND_RN, nCURGZBLANK,  nvl(trim(rec.NOTES), 'Автоматическая загрузка'), trim(rec.QPLAN4), sErrText);
                                        sERR_MSG := sERR_MSG|| case when sErrText is not null then chr(10)||sErrText else '' end;
                                    end if;
                                    exception when others then
                                    sERR_MSG := sERR_MSG||chr(10)||'Не удалось обновить поле "План 4 квартал" значением '||rec.QPLAN4||'. - '||sqlerrm;
                                    end;
                                end if;
                            end if;
                        else
                            if sERR_MSG is null and trim(rec.YPLAN3) is not null then
                                P_UPD_QIND_FIELD(nQIND_RN, 'YPLAN3', rec.YPLAN3, sERR_MSG );
                            end if;

                            if sERR_MSG is null and trim(rec.YPLAN4) is not null then
                                P_UPD_QIND_FIELD(nQIND_RN, 'YPLAN4', rec.YPLAN4, sERR_MSG );
                            end if;

                            if sERR_MSG is null and trim(rec.YPLAN5) is not null then
                                P_UPD_QIND_FIELD(nQIND_RN, 'YPLAN5', rec.YPLAN5, sERR_MSG );
                            end if;

                            if sERR_MSG is null and trim(rec.QPLAN1) is not null then
                                P_UPD_QIND_FIELD(nQIND_RN, 'QPLAN1', rec.QPLAN1, sERR_MSG );
                            end if;
                            if sERR_MSG is null and trim(rec.QPLAN2) is not null then
                                P_UPD_QIND_FIELD(nQIND_RN, 'QPLAN2', rec.QPLAN2, sERR_MSG );
                            end if;
                            if sERR_MSG is null and trim(rec.QPLAN3) is not null then
                                P_UPD_QIND_FIELD(nQIND_RN, 'QPLAN3', rec.QPLAN3, sERR_MSG );
                            end if;
                            if sERR_MSG is null and trim(rec.QPLAN4) is not null then
                                P_UPD_QIND_FIELD(nQIND_RN, 'QPLAN4', rec.QPLAN4, sERR_MSG );
                            end if;

                        end if;

                        if sERR_MSG is null and trim(rec.VARCOUNT) is not null then
                            P_UPD_QIND_FIELD(nQIND_RN, 'VARCOUNT', rec.VARCOUNT, sERR_MSG );
                        end if;
                    end if;
                end if;
            end loop;


            if sERR_MSG is null then
                nADDEDCOUNT := nvl(nADDEDCOUNT,0) + 1;
            else
                nERROR := nvl(nERROR,0) + 1;
            end if;
        end if;


        if sERR_MSG is not null then
            APXA.AP_XLSLOGERR_BASE_INSERT
            (
            nPRN => nLOG,
            nERROR_TYPE => 1,
            sERROR_MSG => sERR_MSG
            );

            sERR_MSG := null;
        end if; -- Отсутствуют изменения по строке

    end loop;
    nRESULT := 0;
    sRESULT_MSG := 'Всего обработано строк файла: '|| nvl(nROWCNT,0)||'. Добавлено строк нормативов: ' || nvl(nADDEDCOUNT,0) ||'. Ошибок: ' || nvl(nERROR,0) ||'. ';

end;
​
