create or replace procedure ZP_XML_PARSING
(
    nRN   in number   default 3,
    nRETURN out number
)
as
sPASS varchar2(200);
nIDENT number;
nCOUNT number;

begin
    -- Начальный путь в данные xml файла
    sPASS := nvl(sPASS, '/factCostRamzes');

    delete from XML_EXP1 where XMLDOCRN = nRN;

    for req in
    (
        SELECT
           xt.content, xt.position, xt.financialYear, xt.fullName, xt.inn, xtp.*
        FROM   Test_xml x,
               -- Парсинг заголовочных данных
               XMLTABLE(sPASS
                 PASSING x.xml_data
                 COLUMNS
                     content       VARCHAR2(100) PATH '/factCostRamzes/header/createDateTime',
                     position      varchar2(100) path '/factCostRamzes/position/versionNumber',
                     financialYear varchar2(100) path '/factCostRamzes/position/financialYear',
                     fullName      varchar2(100) path '/factCostRamzes/position/institution/fullName',
                     inn           varchar2(100) path '/factCostRamzes/position/institution/inn',
                     factCost xmltype path '/factCostRamzes/position/factCost'
                 ) xt,
                 -- Парсинг основных данных файла
                 XMLTABLE('/factCost'
                   PASSING xt.factCost
                   COLUMNS
                       TypeFO varchar2(100) path '/factCost/costItem/TypeFO',
                       Rz     varchar2(100) path '/factCost/costItem/Rz',
                       Pr     varchar2(100) path '/factCost/costItem/Pr',
                       CSR    varchar2(100) path '/factCost/costItem/CSR',
                       KVR    varchar2(100) path '/factCost/costItem/KVR',
                       KOSGU  varchar2(100) path '/factCost/costItem/KOSGU',
                       fact3  varchar2(100) path '/factCost/sumFactCost/fact3',
                       fact6  varchar2(100) path '/factCost/sumFactCost/fact6',
                       fact9  varchar2(100) path '/factCost/sumFactCost/fact9',
                       fact12 varchar2(100) path '/factCost/sumFactCost/fact12'
                 ) xtp
        where x.prn = nRN
    )
    loop
        -- Заносим данные в таблицу (пока что временную)
        nIDENT := gen_id();
        insert into XML_EXP1(VERSION,
                             INN,
                             FOTYPE2,
                             PRECODE,
                             PARTCODE,
                             CODE,
                             KVR,
                             KOSGU,
                             SUMM1,
                             SUMM2,
                             SUMM3,
                             SUMM4,
                             IDENT,
                             XMLDOCRN)
        values(req.financialYear,
               req.inn,
               req.TypeFO,
               req.Rz,
               req.Pr,
               req.CSR,
               req.KVR,
               req.KOSGU,
               req.fact3,
               req.fact6,
               req.fact9,
               req.fact12,
               nIDENT,
               nRN);
        nCOUNT := nvl(nCOUNT, 0) + 1;
    end loop;
    nRETURN := nvl(nCOUNT, 0);
end;
