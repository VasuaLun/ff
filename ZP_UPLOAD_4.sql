create or replace procedure ZP_XML_PARSING3
(
    nRN   in number   default 368566534,
    nRETURN out number
)
as
sPASS varchar2(200);
nIDENT number;
nCOUNT number;

begin
    sPASS := nvl(sPASS, '//*/EPGU_SvcListDepReg/EPGU_SvcListDepReg_ITEM');

    delete from XML_EXP2 where PRN = nRN;

    for req in
    (
        SELECT
        xt.isActual1, xt.regrnumber, xt.RegrNumber_1To42, xt.EffectiveFrom, xt.EffectiveBefore, xt.shortname, xt.inn, xt.regreasoncode, xt.SvcRegrNumber, xt.SvcKind_Code, xt.Belong210FL, xt.NcsrlyBelong210FL,
        xt.ActDomnCode,  xt.Name_Code, xt.BPGUEffFrom, xt.BPGUEffBefore, xt.isactual, xt.Name_Name, xt.name, xt.SvcKind_Name, xt.ActDomnName, xt.ServiceTermsName1, xt.SvcTerms1CodeVal, xt.SvcTermsName1Val,
        xt.ServiceContentsName1, xt.ServiceContentsName2, xt.SvcCnts1CodeVal, xt.SvcCnts2CodeVal, xt.SvcCntsName1Val, xt.SvcCntsName2Val, xt.paid_code, xt.paid_name, xt.isregional
        FROM   Test_xml x,
               XMLTABLE(sPASS
                 PASSING x.xml_data
                 COLUMNS
                     isActual1             varchar2(300) PATH '/EPGU_SvcListDepReg_ITEM/isActual',
                     regrnumber            varchar2(300) path '/EPGU_SvcListDepReg_ITEM/regrnumber',
                     RegrNumber_1To42      varchar2(300) path '/EPGU_SvcListDepReg_ITEM/RegrNumber_1To42',
                     EffectiveFrom         varchar2(300) path '/EPGU_SvcListDepReg_ITEM/EffectiveFrom',
                     EffectiveBefore       varchar2(300) path '/EPGU_SvcListDepReg_ITEM/EffectiveBefore',
                     shortname             varchar2(300) path '/EPGU_SvcListDepReg_ITEM/shortname',
                     inn                   varchar2(300) path '/EPGU_SvcListDepReg_ITEM/inn',
                     regreasoncode         varchar2(300) path '/EPGU_SvcListDepReg_ITEM/regreasoncode',
                     SvcRegrNumber         varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcRegrNumber',
                     SvcKind_Code          varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcKind_Code',
                     Belong210FL           varchar2(300) path '/EPGU_SvcListDepReg_ITEM/Belong210FL',
                     NcsrlyBelong210FL     varchar2(300) path '/EPGU_SvcListDepReg_ITEM/NcsrlyBelong210FL',
                     ActDomnCode           varchar2(300) path '/EPGU_SvcListDepReg_ITEM/ActDomnCode',
                     Name_Code             varchar2(300) path '/EPGU_SvcListDepReg_ITEM/Name_Code',
                     BPGUEffFrom           varchar2(300) path '/EPGU_SvcListDepReg_ITEM/BPGUEffFrom',
                     BPGUEffBefore         varchar2(300) path '/EPGU_SvcListDepReg_ITEM/BPGUEffBefore',
                     isactual              varchar2(300) path '/EPGU_SvcListDepReg_ITEM/isactual',
                     Name_Name             varchar2(300) path '/EPGU_SvcListDepReg_ITEM/Name_Name',
                     name                  varchar2(300) path '/EPGU_SvcListDepReg_ITEM/name',
                     SvcKind_Name          varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcKind_Name',
                     ActDomnName           varchar2(300) path '/EPGU_SvcListDepReg_ITEM/ActDomnName',
                     ServiceTermsName1     varchar2(300) path '/EPGU_SvcListDepReg_ITEM/ServiceTermsName1',
                     SvcTerms1CodeVal      varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcTerms1CodeVal',
                     SvcTermsName1Val      varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcTermsName1Val',
                     ServiceContentsName1  varchar2(300) path '/EPGU_SvcListDepReg_ITEM/ServiceContentsName1',
                     ServiceContentsName2  varchar2(300) path '/EPGU_SvcListDepReg_ITEM/ServiceContentsName2',
                     SvcCnts1CodeVal       varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcCnts1CodeVal',
                     SvcCnts2CodeVal       varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcCnts2CodeVal',
                     SvcCntsName1Val       varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcCntsName1Val',
                     SvcCntsName2Val       varchar2(300) path '/EPGU_SvcListDepReg_ITEM/SvcCntsName2Val',
                     paid_code             varchar2(300) path '/EPGU_SvcListDepReg_ITEM/paid_code',
                     paid_name             varchar2(300) path '/EPGU_SvcListDepReg_ITEM/paid_name',
                     isregional            varchar2(300) path '/EPGU_SvcListDepReg_ITEM/isregional',
                     depregistry_conscat   xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_conscat/depregistry_conscat_ITEM',
                     depregistry_okved     xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_okved',
                     depregistry_okpd      xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_okpd',
                     depregistry_vind      xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_vind',
                     depregistry_qind      xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_qind',
                     depregistry_la        xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_la',
                     depregistry_ppokind   xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_ppokind',
                     depregistry_insttype  xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_insttype',
                     depreginsttninfo      xmltype path       '/EPGU_SvcListDepReg_ITEM/depreginsttninfo',
                     depregistry_paid      xmltype path       '/EPGU_SvcListDepReg_ITEM/depregistry_paid'
                 ) xt,

                     XMLTABLE('/depregistry_conscat'
                       PASSING xt.depregistry_conscat
                       COLUMNS
                           CsmCtgy_Code varchar2(300) path '/depregistry_conscat_ITEM/CsmCtgy_Code',
                           CsmCtgy_Name varchar2(300) path '/depregistry_conscat_ITEM/CsmCtgy_Name'
                     ) xdc,

                         XMLTABLE('/depregistry_conscat_ITEM'
                           PASSING xtp.depregistry_conscat_ITEM
                           COLUMNS
                               CsmCtgy_Code varchar2(300) path '/depregistry_conscat_ITEM/CsmCtgy_Code',
                               CsmCtgy_Name varchar2(300) path '/depregistry_conscat_ITEM/CsmCtgy_Name'
                         ) xdcI,

                     XMLTABLE('/depregistry_okved'
                       PASSING xtp.depregistry_okved
                       COLUMNS
                            depregistry_okved_ITEM xmltype path '/depregistry_okved/depregistry_okved_ITEM'
                     ) xt,

                         XMLTABLE('/volumeIndex'
                           PASSING xtp.volumeIndex
                           COLUMNS
                               regNum        varchar2(300) path '/volumeIndex/index/regNum',
                               name          varchar2(300) path '/volumeIndex/index/name',
                               code          varchar2(300) path '/volumeIndex/index/unit/code',
                               symbol        varchar2(300) path '/volumeIndex/index/unit/symbol',
                               reportYear    varchar2(300) path '/volumeIndex/valueYear/reportYear',
                               currentYear   varchar2(300) path '/volumeIndex/valueYear/currentYear',
                               nextYear      varchar2(300) path '/volumeIndex/valueYear/nextYear',
                               planFirstYear varchar2(300) path '/volumeIndex/valueYear/planFirstYear',
                               planLastYear  varchar2(300) path '/volumeIndex/valueYear/planLastYear'
                         ) xtv,

                         XMLTABLE('/indexes'
                           PASSING xtp.servindexes
                           COLUMNS
                               regNum        varchar2(300) path '/indexes/regNum'
                         ) xti
        where x.prn = nRN
    )
    loop
        nIDENT := gen_id();
        insert into XML_EXP2(CREATEDATE,
                            POSITION,
                            FINANCIALYEAR,
                            FULLNAME,
                            INN,
                            FIRSTYEAR,
                            LASTYEAR,
                            LAW,
                            CONTENT,
                            SUPPLIER,
                            INNSUPPLIER,
                            CONTRACTNUMBER,
                            CONCLUSIONDATE,
                            EXPIRATIONDATE,
                            REESTRNUMBER,
                            SCHEDULENUMBER,
                            PUBLICATIONDATE,
                            IDENTIFICATIONCODE,
                            METHODSUPPLIER,
                            KOSGU,
                            KVR,
                            TYPEFO,
                            SECTIONSUBSECTION,
                            CSR,
                            KBKKVR,
                            TYPEBS,
                            OBJECTS,
                            FINNUMBER,
                            FINPRICE,
                            FIRSTNUMBER,
                            FIRSTPRICE,
                            LASTNUMBER,
                            LASTPRICE,
                            AUTNUMBER,
                            AUTPRICE,
                            IDENT,
                            PRN)
        values(req.createDate,
                req.position,
                req.financialYear,
                req.fullName,
                req.inn,
                req.firstYear,
                req.lastYear,
                req.law,
                req.content,
                req.supplier,
                req.innSupplier,
                req.contractNumber,
                req.conclusionDate,
                req.expirationDate,
                req.reestrNumber,
                req.scheduleNumber,
                req.publicationDate,
                req.identificationCode,
                req.methodSupplier,
                req.KOSGU,
                req.KVR,
                req.TypeFO,
                req.Sectionsubsection,
                req.CSR,
                req.KBKKVR,
                req.TypeBS,
                req.objects,
                req.finnumber,
                req.finprice,
                req.firstnumber,
                req.firstprice,
                req.lastnumber,
                req.lastprice,
                req.autnumber,
                req.autprice,
                nIDENT,
                nRN);
        nCOUNT := nvl(nCOUNT, 0) + 1;
    end loop;

    nRETURN := nvl(nCOUNT, 0);
end;
​
