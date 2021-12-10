create or replace procedure ZP_REESTR2021_REPORT
(
 pFILE        out BLOB,
 pREDACTION   number
)
as
 pJURPERS      number;
 pVERSION      number;
 pORGRN        number;
 pFILIAL       number;
 --
 dREP_DATE    date;
 sREESTR_NUMB varchar2(50) := null;
 nErr         number(1) := 0;
 sRES         varchar2(50);
 nHIST_RN     number(17);
 nSTATUS_RN   number(17);
 nSTATUS      number(17);
 nREP_NUMB    number(17);
 sREPTYPE     varchar2(50);
 nTIMEZONE      number(17);

 sHASH_ORIG   varchar2(64);
 sHASH        varchar2(64);
 nCOUNT       number(17);

 bFILE        blob;
 sFILENAME    varchar2(50);
 nSENDEMAIL   number(17) := 0;
 sREPCODE     varchar2(100);
 sSOGLNUMB    Z_REP_REESTR.SOGLNUMB%type;
 dSOGLDATE    Z_REP_REESTR.SOGLDATE%type;
 sERROR       varchar2(4000);
 sPROCNAME    Z_REPLIST.PROCNAME%type;
 sQLTEXT      varchar2(4000);
Begin
    ----------------------------------------------------
    if sERROR is null then
        begin
            select T.JUR_PERS, T.VERSION, T.ORGRN, T.FILIAL,
                   t.REP_DATE, t.NUMB,  t.UNIQ_NUMB, t.RPT_HASH_ORIG, t.RPT_DOCDATA, t.REPTYPE
              into pJURPERS, pVERSION, pORGRN, pFILIAL,
                   dREP_DATE, nREP_NUMB, sREESTR_NUMB, sHASH_ORIG, bFILE, sREPTYPE
              from Z_REP_REESTR t
             where t.RN = pREDACTION;
        exception when OTHERS then
            sERROR := 'Редакция отчета/электронного документа не найдена.';
            dREP_DATE    := null;
            nREP_NUMB    := null;
            sREESTR_NUMB := null;
            sHASH_ORIG   := null;
            bFILE        := null;
            sREPTYPE     := null;
        end;
    end if;

    if sERROR is null then
        begin
            select nvl(TIMEZONE, 0)
              into nTIMEZONE
              from Z_JURPERS
             where RN = pJURPERS;
        exception when OTHERS then
            sERROR := 'Не удалось определить настройку TIMEZONE для учредителя';
            nTIMEZONE    := null;
        end;
    end if;


    -- Инициализация
    if sERROR is null then
        begin
            nSTATUS := ZP_REP_REESTR_STATUS_GET(p_VERSION => pVERSION,
                                               p_REP_RN   => pREDACTION);
        exception when OTHERS then
            sERROR := 'Не удалось определить статус редакции.';
            nSTATUS := null;
        end;
    end if;

    if sERROR is null then
        begin
            select distinct PROCNAME
              into sPROCNAME
              from Z_REPLIST
             where JUR_PERS = pJURPERS
               and VERSION  = pVERSION
               and REPTYPE  = sREPTYPE;
        exception when others then
            sERROR    := 'Не удалось определить процедуру согласования';
            sPROCNAME := null;
        end;

        if sPROCNAME is null then
            sERROR    := 'Не удалось определить процедуру согласования';
        end if;
    end if;

    /* -- 11:23 25.11.2021 PARKHAEV
    if sERROR is null then
        begin
            select NOTE
              into sFILENAME
              from Z_LOV
             where PART = 'REPTYPE'
               and NAME = sREPTYPE;
        exception when others then
            sERROR    := 'Не удалось определить наименование файла';
            sFILENAME := null;
        end;
    */

    if sERROR is null then
        begin
            select NAME
              into sFILENAME
              from Z_REPLIST
             where VERSION = pVERSION
               and REPTYPE = sREPTYPE;
        exception when others then
            sERROR    := 'Не доступен этот тип отчета в данной версии';
            sFILENAME := null;
        end;

        if sFILENAME is null then
            sERROR    := 'Не доступен этот тип отчета в данной версии';
        end if;
    end if;
    ----------------------------------------------------

    if sERROR is null and pJURPERS != 349188018 then
        select count(*)
          into nCOUNT
          from Z_REP_REESTR
         where VERSION = pVersion
           and ORGRN   = pOrgRn
           and REPTYPE in (select REPTYPE
                             from Z_REPLIST
                            where VERSION  = pVersion
                              and nvl(USERADD_SIGN, 0) = 1)
           and NUMB    > nREP_NUMB
           and REPTYPE = sREPTYPE;


        if (nCOUNT > 0) then
            sERROR := 'Утверждение редакции и добавление ЭЦП допустимо только для текущей(последней) редакции электронного документа.';
        end if;
    end if;

    if sERROR is null then
        if (nSTATUS = 4) and (sREESTR_NUMB is null) then -- если это первидное утверждение и формирование (не ЭЦП)

            if sERROR is null then
                begin
                    select RN
                      into nSTATUS_RN
                      from Z_STATUS
                     where PERIOD = pREDACTION
                       and PART = 'REP_REESTR'
                       and version = pVersion;
                exception when others then
                    nSTATUS_RN := null;
                    sERROR := 'Не удалось найти запись статуса.';
                end;
            end if;

            if sERROR is null then
                begin
                    select max(RN)
                      into nHIST_RN
                      from Z_STATUS_HIST
                     where PRN = nSTATUS_RN;
                exception when others then
                    sERROR := 'Не удалось найти запись истории изменений.';
                    nHIST_RN := null;
                end;
            end if;

            if sERROR is null then
                begin
                    update Z_STATUS
                       set EXP_PLAN = 5
                     where PERIOD = pREDACTION
                       and PART='REP_REESTR'
                       and version = pVersion;
                exception when others then
                    sERROR := 'Не удалось обновить запись статуса (5).';
                end;
            end if;

            nSENDEMAIL := 1;
        end if;
    end if;

    if sERROR is null then
        if sREESTR_NUMB is null then
            begin
            sREESTR_NUMB := ZF_REP_REESTR_GENUNIQ(p_VERSION  => pVersion,
                                                  p_REP_RN   => pREDACTION,
                                                  p_APP_USER => v('APP_USER'));
            exception when others then
                sERROR := 'Не удалось создать код отчета.';
            end;
        end if;
    end if;

    if sERROR is null then
        if ZP_PFHD_VERS_CHECK_VDK( p_JURPERS  => pJURPERS,
                                   p_PROCNAME => sPROCNAME) = 0 then

            if sERROR is null then
                begin
                    SQLTEXT := 'begin ' || sPROCNAME || '( :1 ,:2, :3, :4); end;';
                    EXECUTE IMMEDIATE SQLTEXT USING OUT pFILE, pREDACTION, sREESTR_NUMB, v('APP_USER');
                exception when others then
                    sERROR := 'Ошибка. Не удалось сформировать отчет.' || sqlerrm;
                end;
            end if;

            if sERROR is null then
                begin
                    SQLTEXT := 'begin ZP_REP_VDK_CHECK ( :1 ,:2, :3, :4, :5, :6,:7); end;';
                    EXECUTE IMMEDIATE SQLTEXT USING pJURPERS, pVERSION, pORGRN, pREDACTION, sPROCNAME, v('APP_USER'), OUT sRES;
                exception when others then
                    sERROR := 'Не удалось сформировать протокол. ' || SQLERRM;
                end;
            end if;
            --if v('APP_USER') = 'DEPOSCO' then
            --ZP_EXCEPTION (0, sPROCNAME || ' - ' || pJURPERS || ' - ' || pVERSION || ' - ' || pORGRN || ' - ' || pREDACTION || ' - ' || sPROCNAME);
            --    ZP_EXCEPTION (0, sRES);
            --end if;
        else
            sERROR := 'Для формируемого/подписываемого отчета имеются не актуальные проверки ВДК. Обратитесь в службу поддержки.';
        end if;
    end if;

    if sERROR is null then
        if nvl(sRES,0) != 1 then -- нет критических ошибок

            if sERROR is null then
                if sHASH_ORIG is null then
                    begin
                        sHASH_ORIG := dbms_crypto.hash(pFILE, dbms_crypto.hash_md5);
                    exception when others then
                        sERROR := 'Не удалось сформировать оригинальный хэш отчета.';
                    end;
                end if;
            end if;

            if sERROR is null then
                begin
                    sHASH := dbms_crypto.hash(pFILE, dbms_crypto.hash_md5);
                exception when others then
                    sERROR := 'Не удалось сформировать хэш отчета.';
                end;
            end if;

            if sERROR is null then
                begin
                    update Z_REP_REESTR
                       set UNIQ_NUMB       = sREESTR_NUMB,
                           RPT_DOCDATA     = pFILE,
                           RPT_HASH_ORIG   = sHASH_ORIG,   -- хэш оригинально файла (без подписей)
                           RPT_HASH        = sHASH,   -- хэш файла с подписями
                           RPT_FILENAME    = sFILENAME||' ( от "'||to_char(dREP_DATE,'dd.mm.yyyy')||'" ).xlsx',
                           RPT_MIMETYPE    = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           RPT_LASTUPDATE  = trunc(sysdate + nTIMEZONE/24),
                           ERR_SIGN        = nvl(sRES,0)
                   where RN                = to_number(pREDACTION);
                exception when others then
                    sERROR := 'Не удалось обновить запись редакции отчета.';
                end;
            end if;

            begin
                insert into APXA.A_REPORT_STAT (RN, schema_name, procedure_name, exec_count, last_date)
                                        values (APXA.gen_id, 'APXWS', sPROCNAME, 1, systimestamp);
            exception when others then
               begin
                   update APXA.A_REPORT_STAT
                     set exec_count = exec_count + 1, last_date = systimestamp
                   where schema_name = 'APXWS'
                     and procedure_name = sPROCNAME;
               end;
            end;

            if sERROR is null then
                if nSENDEMAIL = 1 then
                    if sERROR is null then
                        begin
                            sREPCODE := ZF_REP_REESTR_GETNAME(p_REPCODE => sREPTYPE);
                        exception when others then
                            sERROR := 'Не удалось сформировать код для отправки e-mail.';
                        end;
                    end if;

                    if sERROR is null then
                        begin
                            P_SEND_STATUS_BY_EMAIL(pORG_RN     => pOrgRn,
                                                   pDOC_CODE   => sREPCODE,
                                                   pNEW_STATUS => 'Утвержден');
                        exception when others then
                            sERROR := 'Не удалось отправить e-mail.';
                        end;
                    end if;
                end if;
            end if;
        else
            if sERROR is null then
                begin
                    update Z_REP_REESTR
                       set UNIQ_NUMB       = null,
                           RPT_DOCDATA     = pFILE,
                           RPT_HASH_ORIG   = null,
                           RPT_HASH        = null,
                           RPT_FILENAME    = 'Протокол ошибок от '||to_char(sysdate + nTIMEZONE/24,'dd.mm.yy HH24:MI')||'.xlsx',
                           RPT_MIMETYPE    = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           RPT_LASTUPDATE  = trunc(sysdate + nTIMEZONE/24),
                           ERR_SIGN        = sRES
                     where RN              = to_number(pREDACTION);
                exception when others then
                    sERROR := 'Не удалось обновить запись редакции отчета (протокол).';
                end;
            end if;

            if sERROR is null then
                begin
                    update Z_STATUS
                       set EXP_PLAN = 3
                     where PERIOD  = pREDACTION
                       and PART    = 'REP_REESTR'
                       and version = pVERSION;
                exception when others then
                    sERROR := 'Не удалось обновить запись статуса (3).';
                end;
            end if;

            --update Z_REP_REESTR set ERR_SIGN = 2 where RN = to_number(pRN);

            if sERROR is null then
                if nvl(nHIST_RN,0) > 0 then
                    begin
                        delete
                          from Z_STATUS_HIST
                         where PRN = nSTATUS_RN
                           and RN  > nHIST_RN;
                    exception when others then
                        sERROR := 'Не удалось удалить запись статуса.';
                    end;
                end if;
            end if;

            if sERROR is null then
                begin
                    delete
                      from Z_ESIGN
                     where VERSION = pVERSION
                       and ORGRN   = pORGRN
                       and DOC_RN  = pREDACTION
                       and PART    = 'REP_REESTR';
                exception when others then
                    sERROR := 'Не удалось удалить запись электронной подписи.';
                end;
            end if;
        end if;
    end if;
    if sERROR is not null then
        ZP_EXCEPTION (0, sERROR);
    end if;
end;
