create or replace procedure ZP_BUSGOV2021_BLANKGZF
(
 pJURPERS   number,
 pVERSION   number,
 pORGRN     number,
 pREDACTION number,
 pFILENAME  varchar,
 pFILIAL    number default null
)
as
    F1                UTL_FILE.FILE_TYPE;
    sDIRECTORY        varchar2(100):= 'XML_FILES';

    nNEXTPERIOD       Z_VERSIONS.NEXT_PERIOD%type;

    nNUMB             Z_PFHD_VERSIONS.NUMB%type;
    dVERS_DATE        Z_PFHD_VERSIONS.VERS_DATE%type;
    sSOGLNUMB         Z_REP_REESTR.SOGLNUMB%type;

    nACCEPTRED        number;
    sEXEREPTYPE       Z_REP_REESTR.REPTYPE%type;
    dREPVERS_DATE     date;
    nEXENUMB          Z_REP_REESTR.NUMB%type;
    sREPNAME          Z_REPLIST_DETAIL.NAME%type;
    nFILSIGN          Z_JURPERS.ORGFILALS_SIGN%type;

    sJURNAME          Z_JURPERS.NAME%type;
    sJURINN           Z_JURPERS.INN%type;
    sJURKPP           Z_JURPERS.KPP%type;
    sJURBUSGOV        Z_JURPERS.UBP_CODE%type;
    sGLAVACODE        Z_JURPERS.GLAVA_CODE%type;
    sPERSPOSITION      Z_JURPERS.PERSPOSITION%type;

    sORGNAME          Z_ORGREG.NAME%type;
    sORGINN           Z_ORGREG.INN%type;
    sORGKPP           Z_ORGREG.KPP%type;
    sORGBUSGOV        Z_ORGREG.UBP_CODE%type;
    nORGTYPE          Z_ORGREG.ORGTYPE%type;

    sDIRECTOR         Z_ORGREG.DIRECTOR%type;
    sORGPERSPOSITION  Z_ORGREG.PERSPOSITION%type;

    sLASTNAME         Z_JURPERS.LASTNAME%type;
    sFIRSTNAME        Z_JURPERS.FIRSTNAME%type;
    sMIDDLENAME       Z_JURPERS.MIDDLENAME%type;
    sFINDIRECTOR      Z_JURPERS.FINDIRECTOR%type;

    nPARTNUMB         number;
    nQINDCOUNT        number;
    nBLANKREDRN       number;
    nBLANKREDLASTRN   number;
    sGUID             varchar2(100) := lower(REGEXP_REPLACE(SYS_GUID(), '(.{8})(.{4})(.{4})(.{4})(.{12})', '\1-\2-\3-\4-\5'));

    function T
    return varchar2 as
    begin
      return chr(009);
    end;
    procedure prnt(p_file in UTL_FILE.FILE_TYPE, pString in varchar2)
    as
    begin
       UTL_FILE.PUT_LINE_NCHAR(p_file,pString);
    end;
    function get_guid
    return varchar2 as
        l_res varchar2(4000 char);
    begin
        select upper(regexp_replace(
                to_char(
                    DBMS_RANDOM.value(0, power(2, 128)-1),
                    'FM0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),
                '([a-f0-9]{8})([a-f0-9]{4})([a-f0-9]{4})([a-f0-9]{4})([a-f0-9]{12})',
                '\1-\2-\3-\4-\5'))
        into l_res
        from DUAL;
    return l_res;
    end;
begin

    -- Инициализация
    ---------------------------------------
    --- ГРБС (founderAuthority)
    begin
        select FULLNAME, INN, KPP, UBP_CODE, ORGFILALS_SIGN, GLAVA_CODE, PERSPOSITION, FINDIRECTOR
          into sJURNAME, sJURINN, sJURKPP, sJURBUSGOV, nFILSIGN, sGLAVACODE, sPERSPOSITION, sFINDIRECTOR
          from Z_JURPERS
         where RN = pJURPERS;
    exception when others then
        nFILSIGN      := null;
        sJURNAME      := null;
        sJURINN       := null;
        sJURKPP       := null;
        sJURBUSGOV    := null;
        sGLAVACODE    := null;
        sPERSPOSITION := null;
        sFINDIRECTOR  := null;
    end;

    if sJURBUSGOV is null then
        ZP_EXCEPTION (0, 'Не задан код по Сводному реестру (реквизиты учредителя) (regNum)');
    end if;

    if sJURBUSGOV is not null and length(sJURBUSGOV) != 8 then
        ZP_EXCEPTION (0, 'Код по Сводному реестру (реквизиты учредителя) должен состоять из 8 символов (regNum)');
    end if;

    if sJURNAME is null then
        ZP_EXCEPTION (0, 'Не задано наименование учредителя (fullName)');
    end if;

    if sJURINN is null then
        ZP_EXCEPTION (0, 'Не задан ИНН учредителя (inn)');
    end if;

    if sJURKPP is null then
        ZP_EXCEPTION (0, 'Не задан КПП учредителя (kpp)');
    end if;

    if sGLAVACODE is null then
        ZP_EXCEPTION (0, 'Не задан код главы учредителя (glavaCode)');
    end if;

    nBLANKREDRN     := ZF_GET_BLANK_REDACTION(pJURPERS   => pJURPERS,
                                              pVERSION   => pVERSION,
                                              pORGRN     => pORGRN,
                                              pREDACTION => pREDACTION);

    nBLANKREDLASTRN := ZF_GET_REDACTION_LAST (pVERSION => pVERSION,
                                              pORGRN   => pORGRN,
                                              pPART    => 'GZBLANK');

    ---------------------------------------
    begin
        select NAME, INN, KPP, UBP_CODE, ORGTYPE, DIRECTOR, PERSPOSITION
          into sORGNAME, sORGINN, sORGKPP, sORGBUSGOV, nORGTYPE, sDIRECTOR, sORGPERSPOSITION
          from Z_ORGREG
         where RN = pORGRN;
    exception when others then
        sORGNAME    := null;
        sORGINN     := null;
        sORGKPP     := null;
        nORGTYPE    := null;
        sDIRECTOR   := null;
        sORGPERSPOSITION := null;
    end;

    if nvl(nFILSIGN,0) = 1 then
        begin
            select NAME, INN, KPP, UBP
              into sORGNAME, sORGINN, sORGKPP, sORGBUSGOV
              from Z_ORGFL
             where RN = pFILIAL;
        exception when others then
            sORGNAME    := null;
            sORGINN     := null;
            sORGKPP     := null;
            sORGBUSGOV  := null;
        end;
    end if;

    ---------------------------------------
    if sORGBUSGOV is null then
        ZP_EXCEPTION (0, 'Не задан код по Сводному реестру (реквизиты учреждения) (regNum)');
    end if;

    if sORGBUSGOV is not null and length(sORGBUSGOV) != 8 then
        ZP_EXCEPTION (0, 'Код по Сводному реестру (реквизиты учреждения) должен состоять из 8 символов (regNum)');
    end if;

    if sORGNAME is null then
        ZP_EXCEPTION (0, 'Не задано наименование учреждения (fullName)');
    end if;

    if sORGINN is null then
        ZP_EXCEPTION (0, 'Не задан ИНН учреждения (inn)');
    end if;

    if sORGKPP is null then
        ZP_EXCEPTION (0, 'Не задан КПП учреждения (kpp)');
    end if;

    if nORGTYPE is null then
        ZP_EXCEPTION (0, 'Не задан - тип организации');
    end if;


    ---------------------------------------
    begin
        select NUMB, REP_DATE, SOGLNUMB
          into nNUMB, dVERS_DATE, sSOGLNUMB
          from Z_REP_REESTR
         where RN = nBLANKREDLASTRN;
    exception when others then
        nNUMB      := null;
        dVERS_DATE := null;
        sSOGLNUMB  := null;
    end;

    begin
        select NUMB, REP_DATE, REPTYPE
          into nEXENUMB, dREPVERS_DATE, sEXEREPTYPE
          from Z_REP_REESTR
         where RN = pREDACTION;
    exception when others then
        dREPVERS_DATE := null;
        nEXENUMB      := null;
        sEXEREPTYPE   := null;
    end;

    begin
        select NAME
          into sREPNAME
          from Z_REPLIST_DETAIL
         where REPTYPE   = sEXEREPTYPE
           and ORDERNUMB = nEXENUMB
           and VERSION = pVERSION;
    exception when others then
        sREPNAME := null;
    end;


    if nNUMB is null then
        ZP_EXCEPTION (0, 'Не удалось найти номер редакции (versionNumber)');
    end if;

    if dVERS_DATE is null then
        ZP_EXCEPTION (0, 'Не удалось найти дату редакции (date)');
    end if;

    if sSOGLNUMB is null then
        ZP_EXCEPTION (0, 'Не заполнен номер документа (soglnumb)');
    end if;

    ---------------------------------------
    begin
        select NEXT_PERIOD
          into nNEXTPERIOD
          from Z_VERSIONS
         where RN in (select VERSION
                        from Z_ORGREG
                       where RN = pORGRN);
    exception when others then
        nNEXTPERIOD := null;
    end;

    if nNEXTPERIOD is null then
        ZP_EXCEPTION (0, 'Не удалось найти год версии (Year)');
    end if;

    ---------------------------------------
    select COUNT(*)
      into nACCEPTRED
      from Z_REP_REESTR PV, Z_STATUS S
     where PV.JUR_PERS = pJURPERS
       and PV.VERSION  = pVERSION
       and s.period    = PV.RN
       and S.EXP_PLAN  = 5
       and PV.RN       = pREDACTION
       and PV.ORGRN    = pORGRN;

    if nvl(nACCEPTRED,0) = 0 then
        ZP_EXCEPTION (0, 'Статус текущей редакции не позволяет выгрузить документ');
    end if;

    begin
        select LASTNAME, FIRSTNAME, MIDDLENAME
          into sLASTNAME, sFIRSTNAME, sMIDDLENAME
          from Z_JURPERS
         where RN = pJURPERS;
    exception when others then
        ZP_EXCEPTION (0, 'Не заполнено ФИО подписывающего лица для выгрузок во внешние системы.');
    end;
    ---------------------------------------

    F1 := UTL_FILE.fopen_nchar(sDIRECTORY, ''||pFILENAME||'.xml','w',32767);
    prnt(F1,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    prnt(F1,'<ns2:stateTask640r xsi:schemaLocation="http://bus.gov.ru/External/1 http://bus.gov.ru/public/schema/TFF-1.7.8.23/External.xsd" xmlns="http://bus.gov.ru/types/1" xmlns:ns2="http://bus.gov.ru/external/1" xmlns:ns4="http://bus.gov.ru/types/2" xmlns:ns3="http://bus.gov.ru/types/3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">');

        prnt(F1,'<header>');
            prnt(F1,'<id>'||lower(get_guid)||'</id>');
            prnt(F1,'<createDateTime>'||to_char(systimestamp, 'YYYY-MM-DD"T"HH:MI:SS.FF3TZH:TZM') ||'</createDateTime>');
        prnt(F1,'</header>');
        prnt(F1,'<ns2:body>');
            prnt(F1,'<ns2:position>');
                prnt(F1,'<positionId>'||lower(get_guid)||'</positionId>');
                prnt(F1,'<changeDate>'||to_char(systimestamp, 'YYYY-MM-DD"T"HH:MI:SS.FF3TZH:TZM') ||'</changeDate>');

                -----------------------------------------
                prnt(F1,'<placer>');
                    prnt(F1,'<regNum>'||replace(replace(sORGBUSGOV,chr(10),' '),chr(13),' ')||'</regNum>');
                    prnt(F1,'<fullName>'||replace(replace(replace(sORGNAME,'"','&quot;'),chr(10),' '),chr(13),' ')||'</fullName>');
                    prnt(F1,'<inn>'||replace(replace(sORGINN,chr(10),' '),chr(13),' ')||'</inn>');
                    prnt(F1,'<kpp>'||replace(replace(sORGKPP,chr(10),' '),chr(13),' ')||'</kpp>');
                prnt(F1,'</placer>');

                prnt(F1,'<initiator>');
                    prnt(F1,'<regNum>'||replace(replace(sORGBUSGOV,chr(10),' '),chr(13),' ')||'</regNum>');
                    prnt(F1,'<fullName>'||replace(replace(replace(sORGNAME,'"','&quot;'),chr(10),' '),chr(13),' ')||'</fullName>');
                    prnt(F1,'<inn>'||replace(replace(sORGINN,chr(10),' '),chr(13),' ')||'</inn>');
                    prnt(F1,'<kpp>'||replace(replace(sORGKPP,chr(10),' '),chr(13),' ')||'</kpp>');
                prnt(F1,'</initiator>');

                ------------------------------------------
                prnt(F1,'<versionNumber>'||nNUMB||'</versionNumber>');

                prnt(F1,'<reportYear>'||(nNEXTPERIOD-2)||'</reportYear>');
                prnt(F1,'<financialYear>'||(nNEXTPERIOD-1)||'</financialYear>');
                prnt(F1,'<nextFinancialYear>'||nNEXTPERIOD||'</nextFinancialYear>');
                prnt(F1,'<planFirstYear>'||(nNEXTPERIOD + 1)||'</planFirstYear>');
                prnt(F1,'<planLastYear>'||(nNEXTPERIOD + 2)||'</planLastYear>');

                for rec in
                (select SR.NSERVRN,
                        SR.NSERVPRN,
                        SR.SSERVNAME,
                        SR.SUNIQREGNUM_FULL SUNIQREGNUM,
                        SR.SCONSGROUP_CODE,
                        SR.SCONSGROUP_NAME,
                        SR.sSP_CONT1_NAME,
                        SR.sSP_CONT2_NAME,
                        SR.sSP_CONT3_NAME,
                        SR.sSP_COND1_NAME,
                        SR.sSP_COND2_NAME,
                        SL.NACCEPT_NORM,
                        SL.NCORRCOEF,
                        SR.NPARENT_SIGN,
                        SR.NSP_VARCOUNT,
                        SR.NSP_VARPROP,
                        O.OKVED,
                        SR.SREGNUM,
                        OG.CODE OGCODE,
                        SL.NWORKSERV,
                        SL.NLINKS
                   from ZV_SERVLINKS SL,
                        ZV_SERVREG SR,
                        Z_ORGREG O,
                        Z_ORGROUP OG
                  where SL.NSERVRN = SR.NSERVRN
                    and SL.NVERSION = pVersion
                    and SL.nORGRN = O.RN
                    and O.RN = pORGRN
                    and O.PRN = OG.RN (+)
                    and SL.NWORKSERV in (1,3)
                    and SR.SUNIQREGNUM_FULL is not null
                    and SL.NFICTIV_SERV is null
                    and SR.NPARENT_SIGN is null
                   -- and SR.NSERVRN = 343880744
                    and ZF_GET_REDACTION_INDSUM (pJURPERS   => pJURPERS,
                                                 pVERSION   => pVERSION,

                                                 pORGRN     => pORGRN,
                                                 pSERVRN    => SR.NSERVRN,
                                                 pQINDRN    => null,

                                                 pREDACTION => nBLANKREDRN,
                                                 pTYPESUM   => 'YPLAN3',
                                                 pTYPEPLAN  => null,
                                                 pGROWUP    => null) > 0
              order by SL.NWORKSERV, SR.NORDERNUMB, SR.SREGNUM, SR.SSERVCODE
                )
                loop
                    nPARTNUMB := nvl(nPARTNUMB,0) + 1;
                    -- Услуга (работа)
                    prnt(F1,'<service>');
                        --prnt(F1,'<code>'|| rec.SUNIQREGNUM ||'</code>'); -- Код услуги (работы) Обязательно для заполнения для учреждений, формирующих сведения на основании перечня услуг (работ)
                        prnt(F1,'<name>'||replace(rec.SSERVNAME,'"','&quot;')||'</name>'); -- Наименование услуги (работы)
                        prnt(F1,'<type>'||case rec.NWORKSERV when 1 then 'S' when 3 then 'W' end ||'</type>'); -- Признак услуги или работы
                        --prnt(F1,'<uniqueNumber>'||rec.SUNIQREGNUM||'</uniqueNumber>'); -- Номер (код) по утвержденному перечню услуг (работ)
                        prnt(F1,'<ordinalNumber>'||nPARTNUMB||'</ordinalNumber>'); -- Порядковый номер раздела


                        -- Категория потребителей
                        if rec.SCONSGROUP_NAME is not null then
                            prnt(F1,'<category>');
                                --prnt(F1,'<code>'||rec.SCONSGROUP_CODE||'</code>'); -- Код категории
                                prnt(F1,'<name>'||replace(rec.SCONSGROUP_NAME,'"','&quot;')||'</name>'); -- Наименование категории
                            prnt(F1,'</category>');
                        else
                            ZP_EXCEPTION (0, 'Отсутствует привязка "Категории потребителей" к услуге / работ.');
                        end if;

                        -- renderEnactment -- Нормативно правовой акт, регулирующий порядок оказания государственной (муниципальной) услуги    Множественный элемент   Не заполняется в случае работы
                        for QNPA in
                        (
                        select S.RN, N.ACTKIND, N.ACTAUTHOR, N.ACTNAME_CLOB, N.ACTDATE, N.ACTNUM
                          from Z_SERVNPA S, Z_NPA N
                         where S.NPA_RN = N.RN(+)
                           and S.PRN = rec.NSERVRN
                           and N.PART = '5.1'
                         order by lpad(N.ORDERNUM,10,' ')
                        )
                        loop

                            if QNPA.ACTKIND is null or  QNPA.ACTAUTHOR is null or QNPA.ACTDATE is null or QNPA.ACTNUM is null or QNPA.ACTNAME_CLOB is null  then
                                ZP_EXCEPTION (0, 'Не заданы один или несколько параметров НПА, обратитесь в службу поддержки веб-сервиса.');
                            end if;
                            prnt(F1,'<renderEnactment>');

                                prnt(F1,'<type>'|| QNPA.ACTKIND ||'</type>');
                                prnt(F1,'<author>');
                                    prnt(F1,'<fullName>'|| QNPA.ACTAUTHOR ||'</fullName>');
                                prnt(F1,'</author>');

                                prnt(F1,'<date>'|| to_char (QNPA.ACTDATE, 'yyyy-mm-dd')||'+03:00' ||'</date>');
                                prnt(F1,'<number>'|| QNPA.ACTNUM ||'</number>');
                                prnt(F1,'<name>'|| replace(QNPA.ACTNAME_CLOB,'"','&quot;') ||'</name>');
                                --ZP_EXCEPTION (0, 'Проверьте корректность настройки словаря НПА (отсутствуют обязательные реквизиты.)');
                            prnt(F1,'</renderEnactment>');
                        end loop;

                        for QINFO in
                        (
                        select N.NAME, N.INDSOST, N.REFRESH
                          from Z_SERVORDINFO S, Z_ORDERINFO N
                         where S.ORDINFO_RN = N.RN(+)
                           and S.PRN = rec.NSERVRN
                         order by lpad(N.ORDERNUM,10,' ')
                        )
                        loop
                            prnt(F1,'<informingProcedure>');
                                prnt(F1,'<method>'|| replace(QINFO.NAME,'"','&quot;')||'</method>');
                                prnt(F1,'<content>'|| replace(QINFO.INDSOST,'"','&quot;') ||'</content>');
                                prnt(F1,'<rate>'|| replace(QINFO.REFRESH,'"','&quot;') ||'</rate>');
                            prnt(F1,'</informingProcedure>');
                        end loop;

                        select COUNT(*)
                          into nQINDCOUNT
                          from Z_QINDVALS QV, Z_SERVLINKS SL, Z_QINDLIST QL
                         where QV.PRN      = SL.RN
                           and QV.QIND     = QL.RN
                           and QL.QINDSIGN = 1
                           and SL.RN       = rec.NLINKS
                           and (nvl(YPLAN1,0) > 0 or nvl(YPLAN2,0) > 0 or nvl(YPLAN3,0) > 0 or nvl(YPLAN4,0) > 0 or nvl(YPLAN5,0) > 0);

                        if nQINDCOUNT > 0 /*and rec.NWORKSERV = 1*/ then

                            for QQIND in
                            (
                            select nvl(QL.EXTERNAL_NAME, QL.NAME) QLNAME, D.OKEI, D.CODE,
                                   QV.YPLAN1, QV.YPLAN2, QV.YPLAN3, QV.YPLAN4, QV.YPLAN5, QV.VARCOUNT,
                                   case nEXENUMB when 1 then QV.QFACT1
                                                 when 2 then case when QL.QINDKIND = 1 then QV.QFACT2 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) end
                                                 when 3 then case when QL.QINDKIND = 1 then QV.QFACT3 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) + nvl(QV.QFACT3,0) end
                                                 when 4 then case when QL.QINDKIND = 1 then QV.QFACT4 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) + nvl(QV.QFACT3,0) + + nvl(QV.QFACT4,0) end
                                                 when 5 then case when QL.QINDKIND = 1 then QV.QFACT4 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) + nvl(QV.QFACT3,0) + + nvl(QV.QFACT4,0) end  end QFACT
                              from Z_QINDVALS QV, Z_SERVLINKS SL, Z_QINDLIST QL, Z_DICMUNTS D
                              where QV.PRN      = SL.RN
                                and QV.QIND     = QL.RN
                                and QL.QINDSIGN = 1
                                and SL.RN       = rec.NLINKS
                                and QL.MEASURE  = D.RN
                                and (nvl(QV.YPLAN1,0) > 0 or nvl(QV.YPLAN2,0) > 0 or nvl(QV.YPLAN3,0) > 0 or nvl(QV.YPLAN4,0) > 0 or nvl(QV.YPLAN5,0) > 0)
                            )
                            loop
                                -- Показатель качества
                                prnt(F1,'<qualityIndex>');
                                    -- Показатель
                                    prnt(F1,'<index>');
                                        prnt(F1,'<regNum>'|| rec.SUNIQREGNUM ||'</regNum>');
                                        prnt(F1,'<name>'|| replace(QQIND.QLNAME,'"','&quot;')  ||'</name>'); -- Наименование

                                        -- Единица измерения
                                        prnt(F1,'<unit>');
                                            prnt(F1,'<code>'|| QQIND.OKEI ||'</code>');  -- Код в справочнике единиц измерения
                                            prnt(F1,'<symbol>'|| QQIND.CODE ||'</symbol>'); -- Буквенный код
                                        prnt(F1,'</unit>');

                                        --prnt(F1,'<info>'||null||'</info>'); -- Дополнительная информация
                                    prnt(F1,'</index>');
                                    prnt(F1,'<deviation>'||nvl(QQIND.VARCOUNT, 0) ||'</deviation>');
                                    -- Значение показателя на год
                                    prnt(F1,'<valueYear>');
                                        --prnt(F1,'<reportYear>'|| nvl(replace(nvl(QQIND.YPLAN1,0), ',', '.'),0) ||'</reportYear>'); -- Отчетный
                                        --prnt(F1,'<currentYear>'|| nvl(replace(nvl(QQIND.YPLAN2,0), ',', '.'),0) ||'</currentYear>'); -- Текущий
                                        prnt(F1,'<nextYear>'|| nvl(replace(nvl(QQIND.YPLAN3,0), ',', '.'),0) ||'</nextYear>'); -- Очередной
                                        prnt(F1,'<planFirstYear>'|| nvl(replace(nvl(QQIND.YPLAN4,0), ',', '.'),0) ||'</planFirstYear>'); -- Первый плановый
                                        prnt(F1,'<planLastYear>'|| nvl(replace(nvl(QQIND.YPLAN5,0), ',', '.'),0) ||'</planLastYear>'); -- Второй плановый

                                        --prnt(F1,'<source>'|| null ||'</source>'); -- Источник информации

                                    prnt(F1,'</valueYear>');


                                    -- Фактические значения показателей
                                    prnt(F1,'<valueActual>');
                                        prnt(F1,'<reportGUID>'|| sGUID ||'</reportGUID>'); -- Фактическое значение
                                        prnt(F1,'<actualValue>'|| nvl(replace(nvl(QQIND.QFACT,0), ',', '.'),0) ||'</actualValue>'); -- Фактическое значение
                                    prnt(F1,'</valueActual>');
                                prnt(F1,'</qualityIndex>');
                            end loop;
                        end if;

                        select COUNT(*)
                          into nQINDCOUNT
                          from Z_QINDVALS QV, Z_SERVLINKS SL, Z_QINDLIST QL
                         where QV.PRN      = SL.RN
                           and QV.QIND     = QL.RN
                           and QL.QINDSIGN = 2
                           and SL.RN       = rec.NLINKS
                           and (nvl(YPLAN1,0) > 0 or nvl(YPLAN2,0) > 0 or nvl(YPLAN3,0) > 0 or nvl(YPLAN4,0) > 0 or nvl(YPLAN5,0) > 0);

                        if nQINDCOUNT > 1 then
                            ZP_EXCEPTION (0, 'Услуга - ' || rec.SSERVNAME || ' имеет более одного показателя объема.');
                        elsif nQINDCOUNT = 0 then
                            ZP_EXCEPTION (0, 'Услуга - ' || rec.SSERVNAME || ' не имеет показателей объема.');
                        end if;

                        if nQINDCOUNT = 1 then
                            for QQIND in
                            (
                            select nvl(QL.EXTERNAL_NAME, QL.NAME) QLNAME, D.OKEI, D.CODE,
                                   QV.YPLAN1, QV.YPLAN2, QV.YPLAN3, QV.YPLAN4, QV.YPLAN5, QV.VARCOUNT,
                                   case nEXENUMB when 1 then QV.QFACT1
                                                 when 2 then case when QL.QINDKIND = 1 then QV.QFACT2 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) end
                                                 when 3 then case when QL.QINDKIND = 1 then QV.QFACT3 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) + nvl(QV.QFACT3,0) end
                                                 when 4 then case when QL.QINDKIND = 1 then QV.QFACT4 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) + nvl(QV.QFACT3,0) + + nvl(QV.QFACT4,0) end
                                                 when 5 then case when QL.QINDKIND = 1 then QV.QFACT4 else nvl(QV.QFACT1,0) + nvl(QV.QFACT2,0) + nvl(QV.QFACT3,0) + + nvl(QV.QFACT4,0) end  end QFACT
                              from Z_QINDVALS QV, Z_SERVLINKS SL, Z_QINDLIST QL, Z_DICMUNTS D
                              where QV.PRN      = SL.RN
                                and QV.QIND     = QL.RN
                                and QL.QINDSIGN = 2
                                and SL.RN       = rec.NLINKS
                                and QL.MEASURE  = D.RN
                                and (nvl(QV.YPLAN1,0) > 0 or nvl(QV.YPLAN2,0) > 0 or nvl(QV.YPLAN3,0) > 0 or nvl(QV.YPLAN4,0) > 0 or nvl(QV.YPLAN5,0) > 0)
                            )
                            loop
                                -- Показатель объёма
                                prnt(F1,'<volumeIndex>');
                                    -- Показатель
                                    prnt(F1,'<index>');
                                        prnt(F1,'<regNum>'|| rec.SUNIQREGNUM ||'</regNum>');
                                        prnt(F1,'<name>'|| replace(QQIND.QLNAME,'"','&quot;')  ||'</name>'); -- Наименование

                                        -- Единица измерения
                                        prnt(F1,'<unit>');
                                            prnt(F1,'<code>'|| QQIND.OKEI ||'</code>');  -- Код в справочнике единиц измерения
                                            prnt(F1,'<symbol>'|| QQIND.CODE ||'</symbol>'); -- Буквенный код
                                        prnt(F1,'</unit>');

                                        --prnt(F1,'<info>'||null||'</info>'); -- Дополнительная информация

                                    prnt(F1,'</index>');
                                    prnt(F1,'<deviation>'||nvl(QQIND.VARCOUNT, 0) ||'</deviation>');
                                    -- Значение показателя на год
                                    prnt(F1,'<valueYear>');
                                        --prnt(F1,'<reportYear>'|| nvl(replace(nvl(QQIND.YPLAN1,0), ',', '.'),0) ||'</reportYear>'); -- Отчетный
                                        --prnt(F1,'<currentYear>'|| nvl(replace(nvl(QQIND.YPLAN2,0), ',', '.'),0) ||'</currentYear>'); -- Текущий
                                        prnt(F1,'<nextYear>'|| nvl(replace(nvl(QQIND.YPLAN3,0), ',', '.'),0) ||'</nextYear>'); -- Очередной
                                        prnt(F1,'<planFirstYear>'|| nvl(replace(nvl(QQIND.YPLAN4,0), ',', '.'),0) ||'</planFirstYear>'); -- Первый плановый
                                        prnt(F1,'<planLastYear>'|| nvl(replace(nvl(QQIND.YPLAN5,0), ',', '.'),0) ||'</planLastYear>'); -- Второй плановый

                                        --prnt(F1,'<source>'|| null ||'</source>'); -- Источник информации

                                    prnt(F1,'</valueYear>');

                                    if QQIND.QFACT > 0 then
                                        prnt(F1,'<valueActual>');
                                            prnt(F1,'<reportGUID>'|| sGUID ||'</reportGUID>'); -- Фактическое значение
                                            prnt(F1,'<actualValue>'|| nvl(replace(nvl(QQIND.QFACT,0), ',', '.'),0) ||'</actualValue>'); -- Фактическое значение
                                        prnt(F1,'</valueActual>');
                                    end if;
                                prnt(F1,'</volumeIndex>');
                            end loop;

                        end if;

                        /*
                        -- Сведения о ценах (тарифах) на услугу
                        prnt(F1,'<payment>');

                            prnt(F1,'<averagePrice>'|| null ||'</averagePrice>'); -- Средневзвешенная цена за единицу услуги (руб.)
                            --limitPrice
                            prnt(F1,'<limitPrice>');
                                prnt(F1,'<name>'|| null ||'</name>'); -- Наименование услуги
                                prnt(F1,'<price>'|| null ||'</price>'); -- Цена (тариф), единица измерения
                            prnt(F1,'</limitPrice>');

                        -- Сведения о нормативных правовых актах, устанавливающих цены (тарифы) на услугу либо порядок их установления
                            prnt(F1,'<priceEnactment>');
                                prnt(F1,'<type>'|| null ||'</type>'); -- Вид нормативного правового акта
                                prnt(F1,'<name>'|| null ||'</name>'); -- Наименование нормативного правового акта
                                prnt(F1,'<number>'|| null ||'</number>'); -- Номер нормативного правового акта
                                prnt(F1,'<date>'|| null ||'</date>');  -- Дата нормативного правового акта
                                prnt(F1,'<author>');  -- Орган, утвердивший нормативный правовой акт
                                    prnt(F1,'<regNum>'|| null ||'</regNum>'); -- Реестровый номер организации в перечне ГМУ
                                    prnt(F1,'<fullName>'|| null ||'</fullName>'); -- Полное наименование организации
                                prnt(F1,'<author>');
                            prnt(F1,'</priceEnactment>');

                        prnt(F1,'</payment>');*/



                        /*
                        -- Требования к отчетности об исполнении государственного (муниципального) задания
                        prnt(F1,'<reportRequirements>');
                            prnt(F1,'<earlyTermination>'|| null ||'</earlyTermination>'); -- Основание для досрочного прекращения государственного (муниципального) задания
                            prnt(F1,'<deliveryTerm>'|| null ||'</deliveryTerm>'); -- Сроки предоставления отчетов об исполнении государственного (муниципального) задания
                            prnt(F1,'<otherRequirement>'|| null ||'</otherRequirement>'); -- Иное требование к отчетности об исполнении
                            prnt(F1,'<otherInfo>'|| null ||'</otherInfo>');
                        prnt(F1,'</reportRequirements>'); */

                        prnt(F1,'<indexes>');
                            prnt(F1,'<regNum>'|| rec.SUNIQREGNUM ||'</regNum>');
                            prnt(F1,'<contentIndex>'|| nvl(replace(rec.sSP_COND1_NAME,'"','&quot;'), 'О') ||'</contentIndex>');
                            prnt(F1,'<conditionIndex>'|| nvl(replace(rec.sSP_CONT1_NAME,'"','&quot;'), 'О') ||'</conditionIndex>');
                        prnt(F1,'</indexes>');
                    prnt(F1,'</service>');
                end loop;

                for rec in (select *
                              from Z_REASONCANCEL
                             where VERSION = pVersion
                             order by ORDERNUMB)
                loop
                    prnt(F1,'<earlyTermination>'|| rec.REASON ||'</earlyTermination>');
                end loop;
            prnt(F1,'<otherInfo>-</otherInfo>');
            prnt(F1,'<reportRequirements>');
            prnt(F1,'<periodicityTerm>ежеквартально</periodicityTerm>');
            prnt(F1,'<deliveryTerm> для отчетов за I квартал, полугодие и 9 месяцев (предварительный за год); не позднее 1 февраля очередного финансового года для отчета за год (итогового)</deliveryTerm>');
            prnt(F1,'</reportRequirements>');

            for rec in
                (select distinct N.NAME, N.PERIOD, N.RESPON_NUMB, N.RESPON, N.ORDERNUM
                   from ZV_SERVLINKS SL,
                        ZV_SERVREG SR,
                        Z_ORGREG O,
                        Z_ORGROUP OG,
                        Z_SERVORDCONTROL S, Z_ORDERCONTROL N
                  where SL.NSERVRN = SR.NSERVRN
                    and SL.NVERSION = pVersion
                    and SL.nORGRN = O.RN
                    and O.RN = pORGRN
                    and O.PRN = OG.RN (+)
                    and SL.NWORKSERV in (1,3)
                    and SR.SUNIQREGNUM_FULL is not null
                    and SL.NFICTIV_SERV is null
                    and SR.NPARENT_SIGN is null
                    and S.ORDCTRL_RN = N.RN(+)
                    and S.PRN = SR.NSERVRN
                    and ZF_GET_REDACTION_INDSUM (pJURPERS   => pJURPERS,
                                                 pVERSION   => pVERSION,

                                                 pORGRN     => pORGRN,
                                                 pSERVRN    => SR.NSERVRN,
                                                 pQINDRN    => null,

                                                 pREDACTION => nBLANKREDRN,
                                                 pTYPESUM   => 'YPLAN3',
                                                 pTYPEPLAN  => null,
                                                 pGROWUP    => null) > 0
                 order by lpad(N.ORDERNUM,10,' ')
                )
                loop
                        --if QCONTR.NAME is null or QCONTR.PERIOD is null or QCONTR.RESPON_NUMB is null or QCONTR.RESPON is null then
                        --    ZP_EXCEPTION (0, 'Не заполнено одно из полей порядка контроля.');
                        --end if;

                        prnt(F1,'<supervisionProcedure>');
                            prnt(F1,'<form>'|| replace(rec.NAME,'"','&quot;')||'</form>');
                            prnt(F1,'<rate>'|| rec.PERIOD ||'</rate>');
                            prnt(F1,'<supervisor>');
                                --prnt(F1,'<regNum>'|| rec.RESPON_NUMB ||'</regNum>'); -- Реестровый номер организации в перечне ГМУ                     ### Корректировка 17.02.21 - Юра сказал не выводить тег regNum
                                prnt(F1,'<fullName>'|| rec.RESPON ||'</fullName>'); -- Полное наименование организации
                            prnt(F1,'</supervisor>');
                        prnt(F1,'</supervisionProcedure>');
                end loop;

            prnt(F1,'<reports>');
                prnt(F1,'<reportGUID>'||sGUID||'</reportGUID>');
                prnt(F1,'<periodInfo>'||sREPNAME||'</periodInfo>');

                --ФИО эко службы 1
                --Должность 1
                prnt(F1,'<head>');
                    prnt(F1,'<name>'||sFINDIRECTOR||'</name>');
                    prnt(F1,'<position>'||sPERSPOSITION||'</position>');
                prnt(F1,'</head>');
                prnt(F1,'<date>'||to_char (dREPVERS_DATE, 'yyyy-mm-dd')||'+03:00' ||'</date>');
            prnt(F1,'</reports>');

            prnt(F1,'<statementDate>'|| to_char (dVERS_DATE, 'yyyy-mm-dd')||'+03:00' ||'</statementDate>');
            prnt(F1,'<number>'||sSOGLNUMB||'</number>');

            if sFIRSTNAME is null and sLASTNAME is null and sMIDDLENAME is null and sPERSPOSITION is null then
                ZP_EXCEPTION (0, 'Не заданы ФИО и/или должность уполномоченного лица от Учредителя, обратитесь в службу поддержки веб-сервиса');
            end if;

            prnt(F1,'<approverFirstName>'||sFIRSTNAME||'</approverFirstName>');
            prnt(F1,'<approverLastName>'||sLASTNAME||'</approverLastName>');
            prnt(F1,'<approverMiddleName>'||sMIDDLENAME||'</approverMiddleName>');
            prnt(F1,'<approverPosition>'||sPERSPOSITION ||'</approverPosition>');
            prnt(F1,'</ns2:position>');
        prnt(F1,'</ns2:body>');
    prnt(F1,'</ns2:stateTask640r>');
    UTL_FILE.FCLOSE(F1);
  begin
    UTL_FILE.FCLOSE_ALL;
  end;
end;
​
