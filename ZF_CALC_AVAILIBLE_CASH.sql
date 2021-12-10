create or replace function ZF_CALC_AVAILIBLE_CASH
(
  pVERSION number,
  pORGRN number,
  pKVR number,
  pKOSGU number,
  pFOTYPE number,
  pKBK number,
  pPERIOD number default 1
) return number is

  nESUM_OUTC    number;
  nESUM_REST    number;
  nREDACTION    number;
  nREDNUMB      number;
  nITEMROW      number;
  nAVAILIBLE_REST number;

  nOUT        number;
  nZKP_REQV   number;
  nZKP_NOREQV number;

  type EXP_REC IS RECORD (
            OUTCOME      number(19, 2),
            ZKPSUM_REQUISITS     number(19, 2), /*закупки с указанными реквизитами: поставщик/№договора/дата заключения */
            ZKPSUM_NO_REQUISITS     number(19, 2) /*закупки без указанных реквизитов: поставщик/№договора/дата заключения */
            );
  type T_EXP is table of EXP_REC index by PLS_INTEGER;

  AA_EXP          T_EXP;

begin
    for rec in
    (
     select nvl(EA.PARENT_ROW,EA.PRN) PARENT_ROW, EA.ORGRN, O.CODE SHORT_NAME, O.ORGTYPE,
            E.FOTYPE2, L.NAME FOTYPENAME,
            nvl(KBK.NKBK_RN,KBK2.NKBK_RN) KBKRN, nvl(KBK.SCODE,KBK2.SCODE) KBKCODE,
            KVR.RN KVRRN, KVR.CODE KVRCODE,
            K.RN KOSGURN, K.CODE KOSGUCODE,
            0 PAYSUM, 0 ZKPSUM_REQUISITS, 0 ZKPSUM_NO_REQUISITS
       from Z_EXPALL EA, Z_EXPMAT E, Z_KOSGU K, Z_EXPKVR_ALL KVR, Z_LOV L, Z_SERVLINKS SL, ZV_KBKALL KBK, Z_FUNDS_KBK FK, ZV_KBKALL KBK2, Z_ORGREG O
      where EA.EXP_ARTICLE = E.RN
        and E.KOSGURN = K.RN
       -- and E.KOSGURN   != 172
        and E.EXPKVR = KVR.RN
        and E.FOTYPE2 = L.NUM(+)
        and PART(+) = 'FOTYPE2'
        and EA.SERVRN = SL.SERVRN (+)
        and EA.ORGRN = SL.ORGRN (+)
        and SL.SERVKBK = KBK.NKBK_RN (+)

        and EA.FUNDKBK = FK.RN (+)
        and FK.KBK_RN = KBK2.NKBK_RN (+)

        and EA.VERSION = pVersion
        and EA.ORGRN = pORGRN
        and EA.ORGRN = O.RN
        and E.EXPKVR = pKVR
         and E.KOSGURN = pKOSGU
         and E.FOTYPE2 = pFOTYPE
         and nvl(SL.SERVKBK,FK.KBK_RN) = pKBK

        and KVR.CODE in ('242', '243', '244', '247')
        and (nvl(SERVSUM, 0) + nvl(MSUM ,0) + nvl(RESTSUM, 0)) != 0
        and (KBK.NKBK_RN is not null or KBK2.NKBK_RN is not null)
        and O.ORGTYPE != 2

        union all
    select EA.RN PARENT_ROW, EA.ORGRN, O.CODE SHORT_NAME, O.ORGTYPE,
            10 FOTYPE2, 'Бюджетная смета' FOTYPENAME,
            KBK.NKBK_RN KBK, SFULLKBKCODE KBKCODE,
            KVR.RN KVRRN, KVR.CODE KVRCODE,
            K.RN KOSGURN, K.CODE KOSGUCODE,
            0 PAYSUM, 0 ZKPSUM_REQUISITS, 0 ZKPSUM_NO_REQUISITS
       from Z_SMETA_DISTR EA, Z_KOSGU K, Z_EXPKVR KVR, ZV_KBKALL KBK, Z_ORGREG O
      where EA.KBK = KBK.NKBK_RN
        and EA.KOSGU_RN = K.RN
        and EA.KVR = KVR.RN
        --and EA.KOSGU_RN   != 172
        and EA.PRN is not null
        and EA.VERSION = pVersion
        and EA.ORGRN = pORGRN
        and EA.ORGRN = O.RN
        and EA.KVR = pKVR
        and EA.KOSGU_RN = pKOSGU
        and KVR.CODE in ('242', '243', '244', '247')
        and nvl(SUMMA, 0) != 0
        and O.ORGTYPE = 2

        union all

        select null PARENT_ROW,  P.ORGRN, O.CODE SHORT_NAME, O.ORGTYPE,
               ZS.FOTYPE2, L.NAME FOTYPENAME,
               KBK.NKBK_RN KBKRN, KBK.SCODE KBKCODE,
               KVR.RN KVRRN, KVR.CODE KVRCODE,
               K.RN KOSGURN, K.CODE KOSGUCODE,
               0 PAYSUM,
               case when P.AGRDATE is not null or P.AGRNUMB is not null or P.VENDOR_ALL_RN is not null then case pPERIOD
                                                                                                            when 1 then nvl(ZSP.SUMMA, 0)
                                                                                                            when 2 then nvl(ZSP.SUMMA2, 0)
                                                                                                            when 3 then nvl(ZSP.SUMMA3, 0) end else 0 end ZKPSUM_REQUISITS, --,nvl(ZSP.SUMMA, 0) else 0 end ZKPSUM_REQUISITS,
               case when P.AGRDATE is null and P.AGRNUMB is null and P.VENDOR_ALL_RN is null then case pPERIOD
                                                                                                            when 1 then nvl(ZSP.SUMMA, 0)
                                                                                                            when 2 then nvl(ZSP.SUMMA2, 0)
                                                                                                            when 3 then nvl(ZSP.SUMMA3, 0) end else 0 end ZKPSUM_NO_REQUISITS
          from Z_ZKP P, Z_ZKP_SPEC ZS, Z_ZKP_SPECPRICE ZSP, Z_KOSGU K, Z_EXPKVR_ALL KVR, Z_LOV L, ZV_KBKALL KBK, Z_ORGREG O
         where P.RN = ZS.ZKP_RN
           and P.RN = ZSP.ZKP_RN
           and ZSP.ZKP_SPEC_RN = ZS.RN
           and ZS.KVR_RN = KVR.RN(+)
           and ZS.KOSGU_RN = K.RN(+)
           and ZS.FOTYPE2 = L.NUM(+)
           and L.PART(+) = 'FOTYPE2'
           --and ZS.KOSGU_RN != 172
           and ZS.KBK_RN = KBK.NKBK_RN
           and P.VERSION = pVersion
           and P.ORGRN   = pORGRN
           and P.ORGRN = O.RN
           and nvl(P.EXIST_SIGN, 0) != 1
           and ZF_REESTR_STATUS_GET(P.VERSION,  P.RN, 'ZKP_REESTR') = 5
           and ((pKVR is null) or (ZS.KVR_RN = pKVR) or (ZS.KVR_RN is null))
           and ((pKOSGU is null) or (ZS.KOSGU_RN = pKOSGU) or (ZS.KOSGU_RN is null))
           and ((pFOTYPE is null) or (ZS.FOTYPE2 = pFOTYPE) or (ZS.FOTYPE2 is null))
           and ((pKBK is null) or (ZS.KBK_RN = pKBK) or (ZS.KBK_RN is null))
           --and ZKP_STATUS in (2, 3)
           and nvl(ZSP.SUMMA, 0) != 0
         order by SHORT_NAME, FOTYPE2, KBKCODE, KVRCODE, KOSGUCODE

    )
    loop
        if rec.PARENT_ROW is not null and rec.ORGTYPE != 2 then
            if pORGRN is not null then
                nREDACTION := ZF_GET_PFHDVERS_LAST (pVERSION, rec.ORGRN, 5);
                begin
                select NUMB into nREDNUMB from Z_PFHD_VERSIONS where RN = nREDACTION;
                exception when others then
                    nREDNUMB:= null;
                end;
            end if;

            begin
                select ESUM
                  into nESUM_OUTC
                  from (
                        select  case pPERIOD
                                     when 2 then EX.PLANSUM1
                                     when 3 then EX.PLANSUM2
                                     when 1 then EX.ESUM end ESUM
                          from Z_EXP_HISTORY EX, Z_PFHD_VERSIONS PV
                         where EX.ORGRN = rec.ORGRN
                           and EX.PFHD_VERSION_RN = PV.RN
                           and PV.NUMB <= nREDNUMB
                           and EX.PARENT_ROW = rec.PARENT_ROW
                           and ETYPE = 'PLAN'
                         order by num desc
                        )
                where ROWNUM = 1;
            exception when others then
                nESUM_OUTC := null;
            end;
            begin
                select ESUM
                  into nESUM_REST
                  from (
                        select  case pPERIOD
                               when 2 then EX.PLANSUM1
                               when 3 then EX.PLANSUM2
                               when 1 then EX.ESUM end ESUM
                          from Z_EXP_HISTORY EX, Z_PFHD_VERSIONS PV
                         where EX.ORGRN = rec.ORGRN
                           and EX.PFHD_VERSION_RN = PV.RN
                           and PV.NUMB <= nREDNUMB
                           and EX.PARENT_ROW = rec.PARENT_ROW
                           and ETYPE = 'REST'
                         order by num desc
                        )
                where ROWNUM = 1;
            exception when others then
                nESUM_REST := null;
            end;
        elsif rec.PARENT_ROW is not null and rec.ORGTYPE = 2 then
            if pORGRN is not null then
                nREDACTION := ZF_GET_REDACTION_LAST (pVERSION, rec.ORGRN, 'SMETA', 5);
                begin
                select NUMB into nREDNUMB from Z_REP_REESTR where RN = nREDACTION;
                exception when others then
                    nREDNUMB:= null;
                end;
            end if;

            begin
                nESUM_REST := null;

                select ESUM
                  into nESUM_OUTC
                  from (
                        select EX.ESUM
                          from Z_SMETA_HISTORY EX, Z_REP_REESTR PV
                         where EX.ORGRN = rec.ORGRN
                           and EX.REP_VERSION_RN = PV.RN
                           and PV.NUMB <= nREDNUMB
                           and EX.PARENT_ROW = rec.PARENT_ROW
                         order by num desc
                        )
                where ROWNUM = 1;
            exception when others then
                nESUM_OUTC := null;
            end;
        else
            nESUM_OUTC := null;
            nESUM_REST := null;
        end if;

        if (nvl(nESUM_OUTC,0) + nvl(nESUM_REST,0)) != 0 or nvl(rec.ZKPSUM_REQUISITS,0) != 0 or nvl(rec.ZKPSUM_NO_REQUISITS,0) != 0 then
            nITEMROW := AA_EXP.COUNT + 1;

            AA_EXP(nITEMROW).OUTCOME  := nvl(nESUM_OUTC,0) + nvl(nESUM_REST,0);
            AA_EXP(nITEMROW).ZKPSUM_REQUISITS := nvl(rec.ZKPSUM_REQUISITS,0);
            AA_EXP(nITEMROW).ZKPSUM_NO_REQUISITS := nvl(rec.ZKPSUM_NO_REQUISITS,0);
        end if;
    end loop;

--htp.p('CNT = '||AA_EXP.COUNT);
    if AA_EXP.COUNT >0 then
        for I in AA_EXP.FIRST..AA_EXP.LAST
        loop
        nOUT := nvl(nOUT, 0) + nvl(AA_EXP(I).OUTCOME, 0);
        nZKP_REQV   := nvl(nZKP_REQV, 0) + nvl(AA_EXP(I).ZKPSUM_REQUISITS, 0);
        nZKP_NOREQV := nvl(nZKP_NOREQV , 0) + nvl(AA_EXP(I).ZKPSUM_NO_REQUISITS, 0);
            nAVAILIBLE_REST := nvl(nAVAILIBLE_REST, 0) + nvl(AA_EXP(I).OUTCOME, 0) -  nvl(AA_EXP(I).ZKPSUM_REQUISITS, 0) - nvl(AA_EXP(I).ZKPSUM_NO_REQUISITS, 0);
        end loop;
    end if;
--htp.p('nOUT = '||nOUT ||', nZKP_REQV = '||nZKP_REQV ||', nZKP_NOREQV ='||nZKP_NOREQV);
    return nAVAILIBLE_REST;
end;    ​
