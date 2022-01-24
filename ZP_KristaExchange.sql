create or replace procedure ZP_EXCHANGE_XML
(
 pJURPERS   number,
 pVERSION   number,
 pORGRN     number,
 pREDACTION number,
 pFILENAME varchar
)
as

    F1             UTL_FILE.FILE_TYPE;
    sDIRECTORY     varchar2(100):= 'XML_FILES';
    nNUMB          number;

    nCURSUM        number;
    nCURSUM1       number;
    nCURSUM2       number;
    nCURSUM3       number;
    nPURSUMMA      number;

    nPFHDRN        number;
    sKVSR          number;
    nPFHDCOUNT     number;

    dVERS_DATE     date;
    nNEXTPERIOD    Z_VERSIONS.NEXT_PERIOD%type;

    function T
    return varchar2 as
    begin
      return chr(009);
    end;
    procedure prnt(p_file in UTL_FILE.FILE_TYPE, pString in varchar2)
    as

    begin
       UTL_FILE.PUT_LINE(p_file,pString);
    end;

    procedure GET_OUTCOME (pREDACTION number, pTYPE number)
    is
    begin
        for QPARTICLE in
        (
        select O.EXTERNALID, O.LACC_PNO LACC_CS, KVR.CODE KVRCODE, F.CODE FUNDCODE, O.ORGTYPE
          from Z_EXPCOMMON EC, Z_FUNDS F, Z_ORGREG O, Z_EXPMAT E, Z_EXPKVR_ALL KVR
         where EC.JUR_PERS    = pJURPERS
           and EC.VERSION     = pVERSION
           and EC.ORGRN       = pORGRN

           and EC.FUND        = F.RN
           and EC.ORGRN       = O.RN
           and EC.EXPMAT      = E.RN
           and E.EXPKVR       = KVR.RN
           and E.FOTYPE2      = 5
        )
        loop
            ZP_GETSUM_GISREB_EXP(pPFHDVERS    => pREDACTION,
                                  pTYPE       => pTYPE,

                                  pEXSUB      => nCURSUM,
                                  pEXSUB1     => nCURSUM1,
                                  pEXSUB2     => nCURSUM2,
                                  pEXSUB3     => nCURSUM3);

            if (nvl(nCURSUM,0) != 0 or nvl(nCURSUM1,0) != 0 or nvl(nCURSUM2,0) != 0 or nvl(nCURSUM3,0) != 0) then
                prnt(F1,'<R>');
                    prnt(F1,'<V Name="ID">'||GEN_ID||'</V>');
                    prnt(F1,'<V Name="RecordIndex">'||QPARTICLE.EXTERNALID||'</V>');
                    prnt(F1,'<V Name="FacialAcc">'||null||'</V>');
                    prnt(F1,'<V Name="FacialCode">'||null||'</V>');
                    prnt(F1,'<V Name="FacialCodeEx">'||QPARTICLE.LACC_CS||'</V>');
                    prnt(F1,'<V Name="ClsType">'||0||'</V>');

                    prnt(F1,'<V Name="Note">'||null||'</V>');
                    prnt(F1,'<V Name="KVSR">'||sKVSR||'</V>');
                    prnt(F1,'<V Name="KCSR">0000000000</V>');
                    prnt(F1,'<V Name="KVR">'||QPARTICLE.KVRCODE||'</V>');

                    prnt(F1,'<V Name="SubsidyCls">'||QPARTICLE.FUNDCODE||'</V>');
                    prnt(F1,'<V Name="InvestObject">0000000000.0000000000</V>');
                    prnt(F1,'<V Name="KD">00000000000000000000</V>');
                    prnt(F1,'<V Name="IFS">00000000000000000000</V>');
                    prnt(F1,'<V Name="MeansType">'||case QPARTICLE.ORGTYPE when 0 then '03.09.02'
                                                                      when 1 then '03.10.02' end||'</V>');
                    prnt(F1,'<V Name="SummaYear1">'||nvl(nCURSUM,0)||'</V>');
                    prnt(F1,'<V Name="SummaYear2">'||nvl(nCURSUM1,0)||'</V>');
                    prnt(F1,'<V Name="SummaYear3">'||nvl(nCURSUM2,0)||'</V>');
                    prnt(F1,'<V Name="SUMMAOTHERYEARS">'||nvl(nCURSUM3,0)||'</V>');
                prnt(F1,'</R>');
            end if;
        end loop;
    end;


    procedure GET_INCOME (pREDACTION number, pTYPE number)
    is
    begin
        for QPARTICLE in
        (
        select O.EXTERNALID, O.LACC_PNO LACC_CS, F.CODE FUNDCODE, O.ORGTYPE
          from Z_ORG_BUDGDETAIL EC, Z_FUNDS F, Z_ORGREG O
         where EC.JUR_PERS    = pJURPERS
           and EC.VERSION     = pVERSION
           and EC.PRN         = pORGRN
           and EC.FUND        = F.RN
           and EC.PRN         = O.RN
        )
        loop
            ZP_GETSUM_GISREB_INC(pPFHDVERS    => pREDACTION,
                                  pTYPE       => pTYPE,

                                  pEXSUB      => nCURSUM,
                                  pEXSUB1     => nCURSUM1,
                                  pEXSUB2     => nCURSUM2,
                                  pEXSUB3     => nCURSUM3);

            if (nvl(nCURSUM,0) != 0 or nvl(nCURSUM1,0) != 0 or nvl(nCURSUM2,0) != 0 or nvl(nCURSUM3,0) != 0) then
                prnt(F1,'<R>');
                    prnt(F1,'<V Name="ID">'||GEN_ID||'</V>');
                    prnt(F1,'<V Name="RecordIndex">'||QPARTICLE.EXTERNALID||'</V>');
                    prnt(F1,'<V Name="FacialAcc">'||null||'</V>');
                    prnt(F1,'<V Name="FacialCode">'||null||'</V>');
                    prnt(F1,'<V Name="FacialCodeEx">'||QPARTICLE.LACC_CS||'</V>');
                    prnt(F1,'<V Name="ClsType">'||case pTYPE when 1 then '2' else '1' end||'</V>');
                    prnt(F1,'<V Name="Note">'||null||'</V>');

                    if pTYPE = 1 then
                        prnt(F1,'<V Name="KD">01400000000000000150</V>');
                    elsif pTYPE = 2 then
                        prnt(F1,'<V Name="SubsidyCls">'||QPARTICLE.FUNDCODE||'</V>');
                    end if;

                    prnt(F1,'<V Name="InvestObject">0000000000.0000000000</V>');

                    if pTYPE = 2 then
                        prnt(F1,'<V Name="IFS">01400000000000000510</V>');
                    end if;

                    prnt(F1,'<V Name="MeansType">'||case QPARTICLE.ORGTYPE when 0 then '03.09.02'
                                                                      when 1 then '03.10.02' end||'</V>');

                    if pTYPE = 1 then
                        prnt(F1,'<V Name="SubsidyCls">'||QPARTICLE.FUNDCODE||'</V>');
                    end if;

                    prnt(F1,'<V Name="SummaYear1">'||nvl(nCURSUM,0)||'</V>');
                    prnt(F1,'<V Name="SummaYear2">'||nvl(nCURSUM1,0)||'</V>');
                    prnt(F1,'<V Name="SummaYear3">'||nvl(nCURSUM2,0)||'</V>');
                    prnt(F1,'<V Name="SUMMAOTHERYEARS">'||nvl(nCURSUM3,0)||'</V>');
                prnt(F1,'</R>');
            end if;
        end loop;
    end;
begin
    begin
        select NEXT_PERIOD
          into nNEXTPERIOD
          from Z_VERSIONS
         where RN = pVERSION;
    exception when others then
        ZP_EXCEPTION (0, 'Не задан очередной год для версии. Обратитеть к администратору');
    end;

    begin
        select GLAVA_CODE
          into sKVSR
          from Z_JURPERS
         where RN = pJURPERS;
    exception when others then
        ZP_EXCEPTION (0, 'Не задан код главы. Обратитеcь к администратору');
    end;

    if sKVSR is null then
        ZP_EXCEPTION (0, 'Не задан код главы. Обратитеcь к администратору');
    end if;

    F1 := UTL_FILE.FOPEN(sDIRECTORY, ''||nvl(pFILENAME, 'GISREB_EXPORT')||'.xml','w',32767);
    prnt(F1,'<?xml version="1.0" encoding="windows-1251"?>');
    prnt(F1,'<KristaExchange>');
    prnt(F1,'<DocumentsList Code="0204" Name="Сведения о целевых субсидиях">');
    prnt(F1,'<Caption>');

    for QORG in
    (
    select O.INN, O.KPP, O.NAME SORGNAME, O.EXTERNALID,
           O.LACC LACC_GZ, O.LACC_PNO LACC_CS, O.LACC_PDD, O.LACC_OMS,
           O.RN ORGRN, O.ORGTYPE ORGTYPE
      from Z_ORGREG O
     where O.JUR_PERS = pJurPers
       and O.VERSION = pVersion
       and O.CLOSE_DATE is null
       and ((pOrgRn is null) or (RN = pOrgRn))
    )
    loop
        if QORG.EXTERNALID is null then
            ZP_EXCEPTION (0, 'В реквизитах учреждения не заполнено поле - ID  '||pOrgRn);
        end if;

        if QORG.LACC_CS is null then
            ZP_EXCEPTION (0, 'В реквизитах учреждения не заполнено поле - Лицевой счет ЦС');
        end if;

        begin
              select PFHD_RN, RR.NUMB, RR.REP_DATE
                into nPFHDRN, nNUMB, dVERS_DATE
                from Z_REP_REESTR RR, Z_STATUS S
            where RR.JUR_PERS   = pJurPers
                and RR.VERSION  = pVersion
                and S.PERIOD    = RR.RN
                and RR.RN       = pREDACTION
                and S.EXP_PLAN  = 5
                and ZF_REDACTION_SIGNS (pREDACTION) = 3;
        exception when others then
            ZP_EXCEPTION (0, 'Редакция "Сведений о ЦС" не утверждена и не подписана с двух сторон.');
        end;

        begin
            select COUNT(*)
              into nPFHDCOUNT
              from Z_PFHD_VERSIONS PV, Z_STATUS S
             where PV.JUR_PERS = pJurPers
               and PV.VERSION  = pVersion
               and s.period    = PV.RN
               and S.EXP_PLAN  = 5
               and PV.RN       = nPFHDRN
               and ZF_PFHD_SIGNS (pREDACTION) = 2;
        exception when others then
            ZP_EXCEPTION (0, 'Редакция "ПФХД" не утверждена и не подписана с двух сторон.');
        end;

        if nPFHDCOUNT = 1 and nPFHDRN is not null then
            ZP_EXCEPTION (0, 'Статус радакции не позволяет выгрузить документ.');
        end if;

        prnt(F1,'<R>');

            prnt(F1,'<V Name="ID">'||QORG.EXTERNALID||'</V>');
            prnt(F1,'<V Name="OrgINN">'||QORG.INN||'</V>');
            prnt(F1,'<V Name="OrgKPP">'||QORG.KPP||'</V>');
            prnt(F1,'<V Name="OrgName">'||QORG.SORGNAME||'</V>');
            prnt(F1,'<V Name="Variant">'||0||'</V>');

            prnt(F1,'<V Name="FacialAccCls">'||null||'</V>');
            prnt(F1,'<V Name="FacialCodeEx">'||QORG.LACC_GZ||'</V>');

            prnt(F1,'<V Name="PlanDocType">'||case when nNUMB = 1 then 100 else 200 end||'</V>');

            prnt(F1,'<V Name="Number">'||null||'</V>');

            prnt(F1,'<V Name="InputDate">'||to_char(dVERS_DATE, 'dd.mm.yyyy')||'</V>');

            prnt(F1,'<V Name="AcceptDate">'||to_char(dVERS_DATE, 'dd.mm.yyyy')||'</V>');

            prnt(F1,'<V Name="Note">'||null||'</V>');

        prnt(F1,'</R>');
        prnt(F1,'</Caption>');

        prnt(F1,'<Detail00>');

        GET_OUTCOME (nPFHDRN, 1);
        GET_OUTCOME (nPFHDRN, 2);

        GET_INCOME (nPFHDRN, 1);
        GET_INCOME (nPFHDRN, 2);
    end loop;

    prnt(F1,'</Detail00>');

    prnt(F1,'</DocumentsList>');
    prnt(F1,'</KristaExchange>');
    UTL_FILE.FCLOSE(F1);
    begin
        UTL_FILE.FCLOSE_ALL;
    end;
end;
​
