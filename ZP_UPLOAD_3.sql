create or replace procedure ZP_XML_PARSING3
(
    nRN   in number   default 3,
    nRETURN out number
)
as
sPASS varchar2(200);
nIDENT number;
nCOUNT number;

begin
    sPASS := nvl(sPASS, '/stateTask640r');

    delete from XML_EXP2 where PRN = nRN;

    for req in
    (
        SELECT
            xt.id, xt.createDateTime, xt.positionId, xt.changeDate, xt.placregNum, xt.placfullName, xt.placinn, xt.plackpp, xt.initregNum, xt.initfullName, xt.initinn,
            xt.initkpp, xt.versionNumber, xt.reportYear, xt.financialYear,  xt.nextFinancialYear, xt.planFirstYear, xt.planLastYear,
            xtp.code, xtp.name, xtp.typeserv, xtp.ordinalNumber, xtc.catcode, xtc.catname,
            xtq.regNum, xtq.name, xtq.code, xtq.symbol, xtq.reportYear, xtq.currentYear, xtq.nextYear, xtq.planFirstYear, xtq.planLastYear,
            xtv.regNum, xtv.name, xtv.code, xtv.symbol, xtv.reportYear, xtv.currentYear, xtv.nextYear, xtv.planFirstYear, xtv.planLastYear, xti.regNum
        FROM   Test_xml x,
               XMLTABLE(sPASS
                 PASSING x.xml_data
                 COLUMNS
                     id             varchar2(300) PATH '/stateTask640r/header/id',
                     createDateTime varchar2(300) path '/stateTask640r/header/createDateTime',
                     positionId     varchar2(300) path '/stateTask640r/body/position/positionId',
                     changeDate     varchar2(300) path '/stateTask640r/body/position/changeDate',
                     placregNum     varchar2(300) path '/stateTask640r/body/position/placer/regNum',
                     placfullName   varchar2(300) path '/stateTask640r/body/position/placer/fullName',
                     placinn        varchar2(300) path '/stateTask640r/body/position/placer/inn',
                     plackpp        varchar2(300) path '/stateTask640r/body/position/placer/kpp',
                     initregNum     varchar2(300) path '/stateTask640r/body/position/initiator/regNum',
                     initfullName   varchar2(300) path '/stateTask640r/body/position/initiator/fullName',
                     initinn        varchar2(300) path '/stateTask640r/body/position/initiator/inn',
                     initkpp        varchar2(300) path '/stateTask640r/body/position/initiator/kpp',
                     versionNumber  varchar2(300) path '/stateTask640r/body/position/versionNumber',
                     reportYear     varchar2(300) path '/stateTask640r/body/position/reportYear',
                     financialYear  varchar2(300) path '/stateTask640r/body/position/financialYear',
                     nextFinancialYear varchar2(300) path '/stateTask640r/body/position/nextFinancialYear',
                     planFirstYear varchar2(300) path '/stateTask640r/body/position/planFirstYear',
                     planLastYear  varchar2(300) path '/stateTask640r/body/position/planLastYear',
                     service xmltype path '/stateTask640r/body/position/service'
                 ) xt,

                     XMLTABLE('/service'
                       PASSING xt.service
                       COLUMNS
                           code          varchar2(300) path '/service/code',
                           name          varchar2(300) path '/service/name',
                           typeserv      varchar2(300) path '/service/type',
                           ordinalNumber varchar2(300) path '/service/ordinalNumber',
                           category      xmltype path '/service/category',
                           qualityIndex  xmltype path '/service/qualityIndex',
                           volumeIndex   xmltype path '/service/volumeIndex',
                           servindexes   xmltype path '/service/indexes'
                     ) xtp,

                         XMLTABLE('/qualityIndex'
                           PASSING xtp.category
                           COLUMNS
                               catcode       varchar2(300) path '/category/code',
                               catname       varchar2(300) path '/category/name'
                         ) xtc,

                         XMLTABLE('/qualityIndex'
                           PASSING xtp.qualityIndex
                           COLUMNS
                               regNum        varchar2(300) path '/qualityIndex/index/regNum',
                               name          varchar2(300) path '/qualityIndex/index/name',
                               code          varchar2(300) path '/qualityIndex/index/unit/code',
                               symbol        varchar2(300) path '/qualityIndex/index/unit/symbol',
                               reportYear    varchar2(300) path '/qualityIndex/valueYear/reportYear',
                               currentYear   varchar2(300) path '/qualityIndex/valueYear/currentYear',
                               nextYear      varchar2(300) path '/qualityIndex/valueYear/nextYear',
                               planFirstYear varchar2(300) path '/qualityIndex/valueYear/planFirstYear',
                               planLastYear  varchar2(300) path '/qualityIndex/valueYear/planLastYear'
                         ) xtq,

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
                         ) xti,
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
