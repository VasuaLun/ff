create or replace procedure ZP_XML_PARSING2
(
    nRN   in number   default 3,
    nRETURN out number
)
as
sPASS varchar2(200);
nIDENT number;
nCOUNT number;

begin
    sPASS := nvl(sPASS, '/calculatePurchaseRamzes');

    delete from XML_EXP2 where PRN = nRN;

    for req in
    (
        SELECT
           xt.createDate, xt.position, xt.financialYear, xt.fullName, xt.inn, xt.firstYear, xt.lastYear,
           xtp.law, xtp.content, xtp.supplier, xtp.innSupplier, xtp.contractNumber, xtp.conclusionDate,
           xtp.expirationDate, xtp.reestrNumber, xtp.scheduleNumber, xtp.publicationDate, xtp.identificationCode,
           xtp.methodSupplier, xtv.KOSGU, xtv.KVR, xtv.TypeFO, xtv.Sectionsubsection, xtv.CSR, xtv.KBKKVR, xtv.TypeBS,
           xtv.objects, xtv.finnumber, xtv.finprice, xtv.firstnumber, xtv.firstprice, xtv.lastnumber, xtv.lastprice,
           xtv.autnumber, xtv.autprice

        FROM   Test_xml x,
               XMLTABLE(sPASS
                 PASSING x.xml_data
                 COLUMNS
                     createDate    varchar2(300) PATH '/calculatePurchaseRamzes/header/createDateTime',
                     position      varchar2(300) path '/calculatePurchaseRamzes/position/versionNumber',
                     financialYear varchar2(300) path '/calculatePurchaseRamzes/position/financialYear',
                     firstYear     varchar2(300) path '/calculatePurchaseRamzes/position/firstYear',
                     lastYear      varchar2(300) path '/calculatePurchaseRamzes/position/lastYear',
                     fullName      varchar2(300) path '/calculatePurchaseRamzes/position/institution/fullName',
                     inn           varchar2(300) path '/calculatePurchaseRamzes/position/institution/inn',
                     purchase xmltype path '/calculatePurchaseRamzes/position/purchase'
                 ) xt,

                 XMLTABLE('/purchase'
                   PASSING xt.purchase
                   COLUMNS
                       law      varchar2(300) path '/purchase/generalInformation/law',
                       content  varchar2(300) path '/purchase/generalInformation/content',
                       supplier varchar2(300) path '/purchase/generalInformation/contractInformation/supplier',
                       innSupplier varchar2(300) path '/purchase/generalInformation/contractInformation/innSupplier',
                       contractNumber varchar2(300) path '/purchase/generalInformation/contractInformation/contractNumber',
                       conclusionDate varchar2(300) path '/purchase/generalInformation/contractInformation/conclusionDate',
                       expirationDate varchar2(300) path '/purchase/generalInformation/contractInformation/expirationDate',
                       reestrNumber  varchar2(300) path '/purchase/generalInformation/purchaseInformation/reestrNumber',
                       scheduleNumber  varchar2(300) path '/purchase/generalInformation/purchaseInformation/scheduleNumber',
                       publicationDate varchar2(300) path '/purchase/generalInformation/purchaseInformation/publicationDate',
                       identificationCode varchar2(300) path '/purchase/generalInformation/purchaseInformation/identificationCode',
                       methodSupplier varchar2(300) path '/purchase/generalInformation/purchaseInformation/methodSupplier',
                       purchaseValue xmltype path '/purchase/purchaseValue'
                 ) xtp,

                 XMLTABLE('/purchaseValue'
                   PASSING xtp.purchaseValue
                   COLUMNS
                       KOSGU       varchar2(300) path '/purchaseValue/KOSGU',
                       KVR         varchar2(300) path '/purchaseValue/KVR',
                       TypeFO      varchar2(300) path '/purchaseValue/TypeFO',
                       Sectionsubsection varchar2(300) path '/purchaseValue/KBK/Sectionsubsection',
                       CSR         varchar2(300) path '/purchaseValue/KBK/CSR',
                       KBKKVR      varchar2(300) path '/purchaseValue/KBK/KVR',
                       TypeBS      varchar2(300) path '/purchaseValue/KBK/TypeBS',
                       objects     varchar2(300) path '/purchaseValue/object',
                       finnumber   varchar2(300) path '/purchaseValue/financialYear/number',
                       finprice    varchar2(300) path '/purchaseValue/financialYear/price',
                       firstnumber varchar2(300) path '/purchaseValue/firstYear/number',
                       firstprice  varchar2(300) path '/purchaseValue/firstYear/price',
                       lastnumber  varchar2(300) path '/purchaseValue/lastYear/number',
                       lastprice   varchar2(300) path '/purchaseValue/lastYear/price',
                       autnumber  varchar2(300) path '/purchaseValue/autPlanYear/number',
                       autprice   varchar2(300) path '/purchaseValue/autPlanYear/price'
                 ) xtv
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
