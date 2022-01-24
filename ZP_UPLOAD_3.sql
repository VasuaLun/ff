create or replace procedure ZP_XML_PARSING3
(
    nRN   in number   default 3,
    nRETURN out number
)
as
sPASS varchar2(200);
pRN number;
nCOUNT number;

begin
    sPASS := nvl(sPASS, '/stateTask640r');

    delete from Z_XML_PARSDATE where IDENT = nRN;

    for req in
    (
        SELECT
        xt.id, xt.createDateTime, xt.positionId, xt.changeDate, xt.placregNum, xt.placfullName, xt.placinn, xt.plackpp, xt.initregNum, xt.initfullName, xt.initinn, xt.initkpp, xt.versionNumber, xt.reportYear, xt.financialYear, xt.nextFinancialYear,
        xt.planFirstYear, xt.planLastYear, xtp.code, xtp.name, xtp.typeserv, xtp.ordinalNumber, xtc.catcode, xtc.catname, xtq.regNum, xtq.name1, xtq.code1, xtq.symbol1, xtq.reportYear1, xtq.currentYear1, xtq.nextYear1, xtq.planFirstYear1,
        xtq.planLastYear1, xtv.regNum1, xtv.name2, xtv.code2, xtv.symbol2, xtv.reportYear2, xtv.currentYear, xtv.nextYear2, xtv.planFirstYear2, xtv.planLastYear2, xti.regNum2
        FROM   Test_xml x,
                XMLTABLE(xmlnamespaces(default 'http://bus.gov.ru/external/1',
                'http://bus.gov.ru/types/1' as "t"), '/stateTask640r'
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

                    XMLTABLE(xmlnamespaces(default 'http://bus.gov.ru/external/1',
                    'http://bus.gov.ru/types/1' as "t"), '/service'
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

                         XMLTABLE(xmlnamespaces(default 'http://bus.gov.ru/external/1',
                         'http://bus.gov.ru/types/1' as "t"), '/category'
                           PASSING xtp.category
                           COLUMNS
                               catcode       varchar2(300) path '/category/code',
                               catname       varchar2(300) path '/category/name'
                         ) xtc,

                         XMLTABLE(xmlnamespaces(default 'http://bus.gov.ru/external/1',
                         'http://bus.gov.ru/types/1' as "t"), '/qualityIndex'
                           PASSING xtp.qualityIndex
                           COLUMNS
                               regNum         varchar2(300) path '/qualityIndex/index/regNum',
                               name1          varchar2(300) path '/qualityIndex/index/name',
                               code1          varchar2(300) path '/qualityIndex/index/unit/code',
                               symbol1        varchar2(300) path '/qualityIndex/index/unit/symbol',
                               reportYear1    varchar2(300) path '/qualityIndex/valueYear/reportYear',
                               currentYear1   varchar2(300) path '/qualityIndex/valueYear/currentYear',
                               nextYear1      varchar2(300) path '/qualityIndex/valueYear/nextYear',
                               planFirstYear1 varchar2(300) path '/qualityIndex/valueYear/planFirstYear',
                               planLastYear1  varchar2(300) path '/qualityIndex/valueYear/planLastYear'
                         ) xtq,

                         XMLTABLE(xmlnamespaces(default 'http://bus.gov.ru/external/1',
                         'http://bus.gov.ru/types/1' as "t"), '/volumeIndex'
                           PASSING xtp.volumeIndex
                           COLUMNS
                               regNum1        varchar2(300) path '/volumeIndex/index/regNum',
                               name2          varchar2(300) path '/volumeIndex/index/name',
                               code2          varchar2(300) path '/volumeIndex/index/unit/code',
                               symbol2        varchar2(300) path '/volumeIndex/index/unit/symbol',
                               reportYear2    varchar2(300) path '/volumeIndex/valueYear/reportYear',
                               currentYear    varchar2(300) path '/volumeIndex/valueYear/currentYear',
                               nextYear2      varchar2(300) path '/volumeIndex/valueYear/nextYear',
                               planFirstYear2 varchar2(300) path '/volumeIndex/valueYear/planFirstYear',
                               planLastYear2  varchar2(300) path '/volumeIndex/valueYear/planLastYear'
                         ) xtv,

                         XMLTABLE(xmlnamespaces(default 'http://bus.gov.ru/external/1',
                         'http://bus.gov.ru/types/1' as "t"), '/indexes'
                           PASSING xtp.servindexes
                           COLUMNS
                               regNum2       varchar2(300) path '/indexes/regNum'
                         ) xti
        where x.prn = nRN
    )
    loop
        pRN := gen_id();
        insert into Z_XML_PARSDATE(IDENT,
                             RN,
                             sv1,
                             sv2,
                             sv3,
                             sv4,
                             sv5,
                             sv6,
                             sv7,
                             sv8,
                             sv9,
                             sv10,
                             sv11,
                             sv12,
                             sv13,
                             sv14,
                             sv15,
                             sv16,
                             sv17,
                             sv18,
                             sv19,
                             sv20,
                             sv21,
                             sv22,
                             sv23,
                             sv24,
                             sv25,
                             sv26,
                             sv27,
                             sv28,
                             sv29,
                             sv30,
                             sv31,
                             sv32,
                             sv33,
                             sv34,
                             sv35,
                             sv36,
                             sv37,
                             sv38,
                             sv39,
                             sv40,
                             sv41,
                             sv42,
                             sv43)
        values(nRN,
               pRN,
               req.id,
               req.createDateTime,
               req.positionId,
               req.changeDate,
               req.placregNum,
               req.placfullName,
               req.placinn,
               req.plackpp,
               req.initregNum,
               req.initfullName,
               req.initinn,
               req.initkpp,
               req.versionNumber,
               req.reportYear,
               req.financialYear,
               req.nextFinancialYear,
               req.planFirstYear,
               req.planLastYear,
               req.code,
               req.name,
               req.typeserv,
               req.ordinalNumber,
               req.catcode,
               req.catname,
               req.regNum,
               req.name1,
               req.code1,
               req.symbol1,
               req.reportYear1,
               req.currentYear1,
               req.nextYear1,
               req.planFirstYear1,
               req.planLastYear1,
               req.regNum1,
               req.name2,
               req.code2,
               req.symbol2,
               req.reportYear2,
               req.currentYear,
               req.nextYear2,
               req.planFirstYear2,
               req.planLastYear2,
               req.regNum2);
        nCOUNT := nvl(nCOUNT, 0) + 1;
    end loop;

    if nvl(nCOUNT, 0) = 0 then
        update TBL_ATTACH_FILE set STATUS = 1 where ATTACH_ID = nRN;
    else
        update TBL_ATTACH_FILE set STATUS = 2 where ATTACH_ID = nRN;
    end if;

    nRETURN := nvl(nCOUNT, 0);
end;​
