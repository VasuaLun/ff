create or replace procedure ZP_XML_PARSING5
(
    nRN   in number   default 368566534,
    nRETURN out number
)
as
sPASS varchar2(200);
pRN number;
nCOUNT number;
nCOLUMN number;

sTest varchar2(4000);

begin
    sPASS := nvl(sPASS, '//*/ReportData');

    delete from Z_XML_PARSDATE where IDENT = nRN;

    for req in
    (
        SELECT
        xfd.CN, xfd.N, xfd.S, xfd.FDT
        FROM   Test_xml x,
               XMLTABLE(sPASS
                 PASSING x.xml_data
                 COLUMNS
                     FD     xmltype path       '/ReportData/FDL/FD'
                 ) xt,

                 XMLTABLE('/FD'
                   PASSING xt.FD
                   COLUMNS
                       CN varchar2(300) path '/FD/CN',
                       N   varchar2(300) path '/FD/N',
                       S   varchar2(300) path '/FD/S',
                       FDT varchar2(300) path '/FD/FDT'
                 ) xfd
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
                             sv5)
         values(nRN,
                pRN,
                'FD',
                req.CN,
                req.N,
                req.S,
                req.FDT);
        nCOUNT := nvl(nCOUNT, 0) + 1;
    end loop;

    for req in
    (
        SELECT
        xr.at1, xr.at2
        FROM   Test_xml x,
               XMLTABLE(sPASS
                 PASSING x.xml_data
                 COLUMNS
                     R xmltype path '/ReportData/RL/R'
                 ) xt,

                 XMLTABLE('/R/V'
                   PASSING xt.R
                   COLUMNS
                       at1  varchar2(300) path '@N',
                       at2  varchar2(300) path '/V'
                 ) xr
        where x.prn = nRN
    )
    loop
        if req.at1 = 'Бюджет' then
            pRN := gen_id();
            nCOLUMN := 2;
            insert into Z_XML_PARSDATE(IDENT, RN, sv1, sv2) values(nRN, pRN, 'R', req.at2);
        else
            nCOLUMN := nCOLUMN + 1;

            EXECUTE IMMEDIATE 'UPDATE Z_XML_PARSDATE set sv'||nCOLUMN||' = :1 where RN = :2' USING req.at2, pRN;
            -- zp_exception(0, sTest);
        end if;
        nCOUNT := nvl(nCOUNT, 0) + 1;
    end loop;

    if nvl(nCOUNT, 0) = 0 then
        update TBL_ATTACH_FILE set STATUS = 1, PARS_PROC = 'ZP_XML_PARSING5' where ATTACH_ID = nRN;
    else
        update TBL_ATTACH_FILE set STATUS = 2, PARS_PROC = 'ZP_XML_PARSING5' where ATTACH_ID = nRN;
    end if;

    nRETURN := nvl(nCOUNT, 0);
end;​
