create or replace procedure ZP_GETSUM_EXP
(
 pORGRN       number,
 pPFHDVERS    number,

 pFKR         number,
 pPARTICLE    number,
 pFUND        number,
 pNATPROJECT  number,

 pEXSUB       out number,
 pEXSUB1      out number,
 pEXSUB2      out number,
 pEXSUB3      out number

)
is
    sKOSGU        varchar2(100);
    nPLANSUM      number := 0;
    nPLANSUM1     number := 0;
    nPLANSUM2     number := 0;
    nPLANSUM3     number := 0;

    nRESTSUM      number := 0;
    nRESTSUM1     number := 0;
    nRESTSUM2     number := 0;
    nRESTSUM3     number := 0;

    nPREVPLANSUM  number := 0;
    nPREVPLANSUM1 number := 0;
    nPREVPLANSUM2 number := 0;
    nPREVPLANSUM3 number := 0;

    nPREVRESTSUM  number := 0;
    nPREVRESTSUM1 number := 0;
    nPREVRESTSUM2 number := 0;
    nPREVRESTSUM3 number := 0;

    nNUMB         number;
    nPREVNUMB     number;
begin

    select NUMB
      into nNUMB
      from Z_PFHD_VERSIONS
     where RN = pPFHDVERS;

    nPLANSUM      := 0;
    nRESTSUM      := 0;
    nPREVPLANSUM  := 0;
    nPREVRESTSUM  := 0;

    begin
        select replace(CODE, '0', '') into  sKOSGU from Z_KOSGU where RN = QPRT.KOSGU;
    exception when others then null;
    end;

    for rec in
    (select nvl(E.PARENT_ROW, E.PRN) PRN, ET.EXPDIR, E.VNEBUDG_SIGN
       from Z_EXPCOMMON E, Z_EXPMAT ET, Z_KOSGU K, Z_FUNDS_KBK FKBK, Z_KBK KBK
      where E.ORGRN = pOrgRn
        and E.EXP_ARTICLE = ET.RN
        and ET.KOSGURN = K.RN
        and E.FUNDKBK = FKBK.RN (+)
        and FKBK.KBK_RN = KBK.RN (+)
        and (QPRT.KVR is null or ET.EXPKVR = QPRT.KVR)
        and (QPRT.FOTYPE2 is null or ET.FOTYPE2 = QPRT.FOTYPE2)
        and ((pFKR is null) or (KBK.FKR = pFKR))
        and ((pPARTICLE is null) or (KBK.PARTICLE = pPARTICLE))
        and ((pFUND is null) or (FKBK.PRN = pFUND))
        and ((pNATPROJECT is null) or (nvl(KBK.NAT_PROJECT,0) = pNATPROJECT))
        and exists (select H.RN from Z_EXP_HISTORY H where ((H.PARENT_ROW = E.PRN and ET.EXPTYPE != 4) or (H.PARENT_ROW = E.PARENT_ROW and ET.EXPTYPE = 4)) and H.PFHD_VERSION_RN = pPFHDVERS)
        and (
           (QPRT.KOSGU is null)
         or
          (
           ((QPRT.KOSGU is null and ET.KOSGURN is null) or (((ET.KOSGURN = QPRT.KOSGU and QPRT.KOSGU is not null) and (QPRT.KOSGUADD is not null and ET.KOSGU in (SELECT regexp_substr(str, '[^;]+', 1, level) str
           FROM (SELECT QPRT.KOSGUADD str FROM dual) t
           CONNECT BY instr(str, ';', 1, level - 1) > 0) or QPRT.KOSGUADD is null) and (QPRT.ADDEMPTY is null) and (QPRT.KOSGU is not null)) or (QPRT.KOSGU is not null and QPRT.ADDEMPTY = 1 and K.CODE like sKOSGU||'%')))
          )
      )
      group by nvl(E.PARENT_ROW, E.PRN), ET.EXPDIR, E.VNEBUDG_SIGN
    )
    loop
        nPLANSUM      := 0;
        nPLANSUM1     := 0;
        nPLANSUM2     := 0;
        nPLANSUM3     := 0;

        nPREVPLANSUM  := 0;
        nPREVPLANSUM1 := 0;
        nPREVPLANSUM2 := 0;
        nPREVPLANSUM3 := 0;

        nRESTSUM      := 0;
        nRESTSUM1     := 0;
        nRESTSUM2     := 0;
        nRESTSUM3     := 0;

        nPREVRESTSUM  := 0;
        nPREVRESTSUM1 := 0;
        nPREVRESTSUM2 := 0;
        nPREVRESTSUM3 := 0;
        begin
            select nvl(ESUM,0), nvl(PLANSUM1,0), nvl(PLANSUM2,0), nvl(PLANSUM3,0)
              into nPLANSUM, nPLANSUM1, nPLANSUM2, nPLANSUM3
              from (
            select *
              from Z_EXP_HISTORY
             where ORGRN           = pORGRN
               and PARENT_ROW      = rec.PRN
               and PFHD_VERSION_RN in (select RN from Z_PFHD_VERSIONS where ORGRN = pORGRN and NUMB <= nNUMB)
               and ETYPE           = 'PLAN'
               order by NUM desc
                )
              where ROWNUM = 1;
        exception when others then
            nPLANSUM  := null;
            nPLANSUM1 := null;
            nPLANSUM2 := null;
            nPLANSUM3 := null;
        end;

        if nNUMB > 1 then
            begin
                select nvl(ESUM,0), nvl(PLANSUM1,0), nvl(PLANSUM2,0), nvl(PLANSUM3,0)
                  into nPREVPLANSUM, nPREVPLANSUM1, nPREVPLANSUM2, nPREVPLANSUM3
                  from (
                select *
                  from Z_EXP_HISTORY
                 where ORGRN           = pORGRN
                   and PARENT_ROW      = rec.PRN
                   and PFHD_VERSION_RN in (select RN from Z_PFHD_VERSIONS where ORGRN = pORGRN and NUMB < nNUMB)
                   and ETYPE           = 'PLAN'
                   order by NUM desc
                    )
                  where ROWNUM = 1;
            exception when others then
                nPREVPLANSUM  := null;
                nPREVPLANSUM1 := null;
                nPREVPLANSUM2 := null;
                nPREVPLANSUM3 := null;
            end;
        end if;

        begin
            select nvl(ESUM,0), nvl(PLANSUM1,0), nvl(PLANSUM2,0), nvl(PLANSUM3,0)
              into nRESTSUM, nRESTSUM1, nRESTSUM2, nRESTSUM3
              from (
            select *
              from Z_EXP_HISTORY
             where ORGRN           = pORGRN
               and PARENT_ROW      = rec.PRN
               and PFHD_VERSION_RN in (select RN from Z_PFHD_VERSIONS where ORGRN = pORGRN and NUMB <= nNUMB)
               and ETYPE           = 'REST'
               order by NUM desc
                )
              where ROWNUM = 1;
        exception when others then
            nRESTSUM  := null;
            nRESTSUM1 := null;
            nRESTSUM2 := null;
            nRESTSUM3 := null;
        end;

        if nNUMB > 1 then
            begin
                select nvl(ESUM,0), nvl(PLANSUM1,0), nvl(PLANSUM2,0), nvl(PLANSUM3,0)
                  into nPREVRESTSUM, nPREVRESTSUM1, nPREVRESTSUM2, nPREVRESTSUM3
                  from (
                select *
                  from Z_EXP_HISTORY
                 where ORGRN           = pORGRN
                   and PARENT_ROW      = rec.PRN
                   and PFHD_VERSION_RN in (select RN from Z_PFHD_VERSIONS where ORGRN = pORGRN and NUMB < nNUMB)
                   and ETYPE           = 'REST'
                   order by NUM desc
                    )
                  where ROWNUM = 1;
            exception when others then
                nPREVRESTSUM  := null;
                nPREVRESTSUM1 := null;
                nPREVRESTSUM2 := null;
                nPREVRESTSUM3 := null;
            end;
        end if;

         if rec.EXPDIR in (1,3) and rec.VNEBUDG_SIGN = 0 then

            pEXSUB  := nvl(pEXSUB,0) + case when nNUMB = 1 then nvl(nPLANSUM,0) + nvl(nRESTSUM,0) else (nvl(nPLANSUM,0)-nvl(nPREVPLANSUM,0)) + (nvl(nRESTSUM,0) - nvl(nPREVRESTSUM,0)) end;
            pEXSUB1 := nvl(pEXSUB1,0) + case when nNUMB = 1 then nvl(nPLANSUM1,0) + nvl(nRESTSUM1,0) else (nvl(nPLANSUM1,0)-nvl(nPREVPLANSUM1,0)) + (nvl(nRESTSUM1,0) - nvl(nPREVRESTSUM1,0)) end;
            pEXSUB2 := nvl(pEXSUB2,0) + case when nNUMB = 1 then nvl(nPLANSUM2,0) + nvl(nRESTSUM2,0) else (nvl(nPLANSUM2,0)-nvl(nPREVPLANSUM2,0)) + (nvl(nRESTSUM2,0) - nvl(nPREVRESTSUM2,0)) end;
            pEXSUB3 := nvl(pEXSUB3,0) + case when nNUMB = 1 then nvl(nPLANSUM3,0) + nvl(nRESTSUM3,0) else (nvl(nPLANSUM3,0)-nvl(nPREVPLANSUM3,0)) + (nvl(nRESTSUM3,0) - nvl(nPREVRESTSUM3,0)) end;

         end if;
    end loop;
end;​
