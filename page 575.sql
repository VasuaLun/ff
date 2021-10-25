--101; 575; Z_ZKP
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;
 pORGRN	       number         := nvl(:P1_ORGRN,:P7_ORGFILTER);
 count_rows    number(17) := 0;

 pSTATUS      number          := :P575_STATUS;
 pVENDORRN    number          := :P575_VENDOR_RN;
 pALLORGRN    number		  := null; --:P575_ALLORGRN;
 CURR_NUM_ORG  number;

 CURR_NUM number;
 nFLAG		number := 0;
 nOUTCOME 	number(19,2) := 0;
 nPAYSUM 	number(19,2) := 0;
 nALL_ZKP   number(19,2) := 0;
 nALL_REST	number(19,2):= 0;
 nDIFF_REST_ZKP number(19,2):= 0;
 nNOT_PAID_ZKP	number(19,2):= 0;
 sFMT		varchar2(26) := '999G999G999G999G999G990D00';
 nPREVFO	number:= null;
 nPREVKBK	number:= null;
 nPREVORGRN number:= null;
 NPREVKVR	number:= null;
 nINCOME 	number;
 nZKPSUM_REQUISITS number;
 nZKPSUM_NO_REQUISITS number;


 sEXPFKR       varchar2(4000);
 sPROG         varchar2(4000);
 sSUBPROG      varchar2(4000);
 sMEANING      varchar2(4000);

 sKBK_SFKR     varchar2(4000);
 sKBK_PROG     varchar2(4000);
 sKBK_SUBPROG  varchar2(4000);
 sKBK_MEANING  varchar2(4000);

 sColor        varchar2(100);
 sMSG	       varchar2(250);
 nESUM_INC     number;
 nESUM_OUTC    number;
 nESUM_REST    number;
 nREDACTION    number;
 nREDNUMB      number;

 pKVR		   number        := :P575_KVR;
 pKOSGU  	   number        := :P575_KOSGU;
 pFOTYPE       number        := :P575_FOTYPE;
 pKBK		   number        := :P575_KBK;
 pPERIOD       number        := :P575_PERIOD;
 nITEMROW      number ;

 AA_EXP  		COLLECT_TYPES.T_EXP;
 AA_INC  		COLLECT_TYPES.T_EXP;
 AA_EXP_SUM 	COLLECT_TYPES.T_EXP;
 AA_FO_SUM 		COLLECT_TYPES.T_EXP;
 AA_FO_KBK_SUM 	COLLECT_TYPES.T_EXP;
begin
    /*if pALLORGRN = 1  then pORGRN:= null; */
	if pALLORGRN is null and pORGRN is not null then
		nREDACTION := ZF_GET_PFHDVERS_LAST (pVERSION, pORGRN, 5);
		begin
		select NUMB into nREDNUMB from Z_PFHD_VERSIONS where RN = nREDACTION;
		exception when others then
			nREDNUMB:= null;
		end;
	end if;

	ZP_CREATE_INC_COLLECTION( pJURPERS, pVERSION, pORGRN, pKOSGU, pFOTYPE, pKBK, AA_INC);

    for rec in
    (
     select nvl(EA.PARENT_ROW,EA.PRN) PARENT_ROW, EA.ORGRN, O.CODE SHORT_NAME,
            E.FOTYPE2, L.NAME FOTYPENAME,
            nvl(KBK.NKBK_RN,KBK2.NKBK_RN) KBKRN, nvl(KBK.SCODE,KBK2.SCODE) KBKCODE,
            KVR.RN KVRRN, KVR.CODE KVRCODE,
            K.RN KOSGURN, K.CODE KOSGUCODE,
            0 PAYSUM, 0 ZKPSUM_REQUISITS, 0 ZKPSUM_NO_REQUISITS
       from Z_EXPALL EA, Z_EXPMAT E, Z_KOSGU K, Z_EXPKVR_ALL KVR, Z_LOV L, Z_SERVLINKS SL, ZV_KBKALL KBK, Z_FUNDS_KBK FK, ZV_KBKALL KBK2, Z_ORGREG O
      where EA.EXP_ARTICLE = E.RN
        and E.KOSGURN = K.RN
		--and E.KOSGURN   != 172
        and E.EXPKVR = KVR.RN
        and E.FOTYPE2 = L.NUM(+)
        and PART(+) = 'FOTYPE2'
        and EA.SERVRN = SL.SERVRN (+)
        and EA.ORGRN = SL.ORGRN (+)
        and SL.SERVKBK = KBK.NKBK_RN (+)

        and EA.FUNDKBK = FK.RN (+)
        and FK.KBK_RN = KBK2.NKBK_RN (+)

        and EA.VERSION = pVersion
        and (EA.ORGRN = pORGRN or pORGRN is null)
        and EA.ORGRN = O.RN
        and ((pKVR is null) or (E.EXPKVR = pKVR))
 	    and ((pKOSGU is null) or (E.KOSGURN = pKOSGU))
 	    and ((pFOTYPE is null) or (E.FOTYPE2 = pFOTYPE))
 	    and ((pKBK is null) or (nvl(SL.SERVKBK,FK.KBK_RN) = pKBK))

        and KVR.CODE in ('242', '243', '244', '247')
        and (nvl(SERVSUM, 0) + nvl(MSUM ,0) + nvl(RESTSUM, 0)) != 0
        and (KBK.NKBK_RN is not null or KBK2.NKBK_RN is not null)

        union all

        select null PARENT_ROW, P.ORGRN, O.CODE SHORT_NAME,
               P.FOTYPE2, L.NAME FOTYPENAME,
               KBK.NKBK_RN KBKRN, KBK.SCODE KBKCODE,
               KVR.RN KVRRN, KVR.CODE KVRCODE,
               K.RN KOSGURN, K.CODE KOSGUCODE,
               case pPERIOD when 3 then nvl(P.SUMMA, 0) else 0 end PAYSUM,
               0 ZKPSUM_REQUISITS, 0 ZKPSUM_NO_REQUISITS
    	  from Z_PAY P, Z_KOSGU K, Z_EXPKVR_ALL KVR, Z_LOV L, ZV_KBKALL KBK, Z_ORGREG O, Z_ZKP_SPEC_LINKS ZSL
    	 where P.KVR = KVR.RN
    	   and P.KOSGU = K.RN(+)
		   --and P.KOSGU != 172
    	   and P.FOTYPE2 = L.NUM(+)
    	   and PART(+) = 'FOTYPE2'
    	   and P.KBK_RN = KBK.NKBK_RN
    	   and P.VERSION = pVersion
    	   and (P.ORGRN   = pORGRN or pORGRN is null)
		   and P.ORGRN = O.RN
		   and P.RN = ZSL.PAY_RN
		   and P.STATUS != 2
    	   and ((pKVR is null) or (P.KVR = pKVR) or (P.KVR is null))
    	   and ((pKOSGU is null) or (P.KOSGU = pKOSGU) or (P.KOSGU is null))
    	   and ((pFOTYPE is null) or (P.FOTYPE2 = pFOTYPE and nvl(PAY_MARK, 0) = 0) or (P.FOTYPE2 is null))
    	   and ((pKBK is null) or (P.KBK_RN = pKBK) or (P.KBK_RN is null))
    	   and KVR.CODE in ('242', '243', '244', '247')
		   and ZP_PAY_REESTR_STATUS_GET(P.VERSION, P.PAY_REESTR_RN) = 5
    	   and nvl(P.SUMMA, 0) != 0

        union all

        select null PARENT_ROW,  P.ORGRN, O.CODE SHORT_NAME,
               ZS.FOTYPE2, L.NAME FOTYPENAME,
               KBK.NKBK_RN KBKRN, KBK.SCODE KBKCODE,
               KVR.RN KVRRN, KVR.CODE KVRCODE,
               K.RN KOSGURN, K.CODE KOSGUCODE,
               0 PAYSUM,
			   case when P.AGRDATE is not null or P.AGRNUMB is not null or P.VENDOR_ALL_RN is not null then
                                                                                                        case pPERIOD
                                                                                                            when 3 then nvl(ZSP.SUMMA, 0)
                                                                                                            when 4 then nvl(ZSP.SUMMA2, 0)
                                                                                                            when 5 then nvl(ZSP.SUMMA3, 0) end else 0 end ZKPSUM_REQUISITS,

			   case when P.AGRDATE is null and P.AGRNUMB is null and P.VENDOR_ALL_RN is null then
                                                                                                        case pPERIOD
                                                                                                            when 3 then nvl(ZSP.SUMMA, 0)
                                                                                                            when 4 then nvl(ZSP.SUMMA2, 0)
                                                                                                            when 5 then nvl(ZSP.SUMMA3, 0) end else 0 end ZKPSUM_NO_REQUISITS

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
           and (P.ORGRN   = pORGRN or pORGRN is null)
		   and P.ORGRN = O.RN
		   and nvl(P.EXIST_SIGN, 0) != 1
		   and ZF_REESTR_STATUS_GET(P.VERSION,  P.RN, 'ZKP_REESTR') = 5
           and ((pKVR is null) or (ZS.KBK_RN = pKVR) or (ZS.KBK_RN is null))
           and ((pKOSGU is null) or (ZS.KOSGU_RN = pKOSGU) or (ZS.KOSGU_RN is null))
           and ((pFOTYPE is null) or (ZS.FOTYPE2 = pFOTYPE) or (ZS.FOTYPE2 is null))
           and ((pKBK is null) or (ZS.KBK_RN = pKBK) or (ZS.KBK_RN is null))
           --and ZKP_STATUS in (2, 3)
           and nvl(ZSP.SUMMA, 0) != 0
         order by SHORT_NAME, FOTYPE2, KBKCODE, KVRCODE, KOSGUCODE

    )
    loop

        if rec.PARENT_ROW is not null then
			if pORGRN is null then
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
                        select case pPERIOD
                                     when 4 then EX.PLANSUM1
                                     when 5 then EX.PLANSUM2
                                     when 3 then EX.ESUM end ESUM
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
                  select case pPERIOD
                                  when 4 then EX.PLANSUM1
                                  when 5 then EX.PLANSUM2
                                  when 3 then EX.ESUM end ESUM
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
        else
            nESUM_OUTC := null;
			nESUM_REST := null;
        end if;

		if (nvl(nESUM_OUTC,0) + nvl(nESUM_REST,0)) != 0 or nvl(rec.PAYSUM,0) != 0 or nvl(rec.ZKPSUM_REQUISITS,0) != 0 or nvl(rec.ZKPSUM_NO_REQUISITS,0) != 0 then
			nITEMROW := AA_EXP.COUNT + 1;
			AA_EXP(nITEMROW).ORGRN := case when pALLORGRN is null and pORGRN is null then 0 else rec.ORGRN end;
			AA_EXP(nITEMROW).ORGNAME := rec.SHORT_NAME;
			AA_EXP(nITEMROW).FOTYPE2 := rec.FOTYPE2;
			AA_EXP(nITEMROW).FOTYPENAME := rec.FOTYPENAME;

			AA_EXP(nITEMROW).KBKRN := rec.KBKRN;
			AA_EXP(nITEMROW).KBKCODE := rec.KBKCODE;
			AA_EXP(nITEMROW).EXPKVR := rec.KVRRN;
			AA_EXP(nITEMROW).KVRCODE := rec.KVRCODE;
			AA_EXP(nITEMROW).KOSGURN := rec.KOSGURN;
			AA_EXP(nITEMROW).KOSGUCODE := rec.KOSGUCODE;


-------------------------------
			AA_EXP(nITEMROW).OUTCOME  := nvl(nESUM_OUTC,0) + nvl(nESUM_REST,0);

/*
1. nESUM_OUTC - ESUM из Z_EXP_HISTORY // ETYPE = 'PLAN'
2. nESUM_REST - ESUM из Z_EXP_HISTORY // ETYPE = 'REST'
*/

-------------------------------


			AA_EXP(nITEMROW).PAYSUM   := nvl(rec.PAYSUM,0);
			AA_EXP(nITEMROW).ZKPSUM_REQUISITS := nvl(rec.ZKPSUM_REQUISITS,0);
			AA_EXP(nITEMROW).ZKPSUM_NO_REQUISITS := nvl(rec.ZKPSUM_NO_REQUISITS,0);
		end if;
    end loop;

		/*вычислим общие суммы по затратам в разрезе КВР, КОСГУ, вид ФО*/
	 if AA_EXP.COUNT >0 then
		for I in AA_EXP.FIRST..AA_EXP.LAST
		loop
			CURR_NUM := AA_EXP_SUM.FIRST;
			loop
			exit when CURR_NUM is null;
				if AA_EXP_SUM(CURR_NUM).ORGRN = AA_EXP(I).ORGRN and AA_EXP_SUM(CURR_NUM).KBKRN = AA_EXP(I).KBKRN and AA_EXP_SUM(CURR_NUM).EXPKVR = AA_EXP(I).EXPKVR and AA_EXP_SUM(CURR_NUM).KOSGURN = AA_EXP(I).KOSGURN and AA_EXP_SUM(CURR_NUM).FOTYPE2 = AA_EXP(I).FOTYPE2 then
					AA_EXP_SUM(CURR_NUM).OUTCOME := nvl(AA_EXP_SUM(CURR_NUM).OUTCOME, 0) + nvl(AA_EXP(I).OUTCOME, 0);
					AA_EXP_SUM(CURR_NUM).PAYSUM := nvl(AA_EXP_SUM(CURR_NUM).PAYSUM, 0) + nvl(AA_EXP(I).PAYSUM, 0);
					AA_EXP_SUM(CURR_NUM).ZKPSUM_REQUISITS := nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_REQUISITS, 0) + nvl(AA_EXP(I).ZKPSUM_REQUISITS, 0);
					AA_EXP_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS := nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS, 0) + nvl(AA_EXP(I).ZKPSUM_NO_REQUISITS, 0);
					nFLAG := 1;
					exit;
				end if;
			CURR_NUM := AA_EXP_SUM.NEXT(CURR_NUM);
			end loop;

			if nFLAG = 0 then
				CURR_NUM := AA_EXP_SUM.COUNT + 1;
				AA_EXP_SUM(CURR_NUM).ORGRN := AA_EXP(I).ORGRN;
				AA_EXP_SUM(CURR_NUM).ORGNAME := AA_EXP(I).ORGNAME;
				AA_EXP_SUM(CURR_NUM).KBKRN := AA_EXP(I).KBKRN;
				AA_EXP_SUM(CURR_NUM).KBKCODE := AA_EXP(I).KBKCODE;
				AA_EXP_SUM(CURR_NUM).EXPKVR := AA_EXP(I).EXPKVR;
				AA_EXP_SUM(CURR_NUM).KVRCODE := AA_EXP(I).KVRCODE;
				AA_EXP_SUM(CURR_NUM).KOSGURN := AA_EXP(I).KOSGURN;
				AA_EXP_SUM(CURR_NUM).KOSGUCODE := AA_EXP(I).KOSGUCODE;
				AA_EXP_SUM(CURR_NUM).FOTYPE2 := AA_EXP(I).FOTYPE2;
				AA_EXP_SUM(CURR_NUM).FOTYPENAME := AA_EXP(I).FOTYPENAME;
				AA_EXP_SUM(CURR_NUM).OUTCOME := AA_EXP(I).OUTCOME;
				AA_EXP_SUM(CURR_NUM).PAYSUM := AA_EXP(I).PAYSUM;
				AA_EXP_SUM(CURR_NUM).ZKPSUM_REQUISITS := AA_EXP(I).ZKPSUM_REQUISITS;
				AA_EXP_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS := AA_EXP(I).ZKPSUM_NO_REQUISITS;

			else
				nFLAG := 0;
			end if;
		end loop;
	 end if;

	 AA_EXP.delete;

	  if AA_EXP_SUM.COUNT >0 then
		for I in AA_EXP_SUM.FIRST..AA_EXP_SUM.LAST
		loop
			CURR_NUM := AA_FO_KBK_SUM.FIRST;
			loop
			exit when CURR_NUM is null;
				if AA_FO_KBK_SUM(CURR_NUM).ORGRN = AA_EXP_SUM(I).ORGRN and AA_FO_KBK_SUM(CURR_NUM).KBKRN = AA_EXP_SUM(I).KBKRN and AA_FO_KBK_SUM(CURR_NUM).FOTYPE2 = AA_EXP_SUM(I).FOTYPE2 and AA_FO_KBK_SUM(CURR_NUM).EXPKVR = AA_EXP_SUM(I).EXPKVR then
					AA_FO_KBK_SUM(CURR_NUM).OUTCOME := nvl(AA_FO_KBK_SUM(CURR_NUM).OUTCOME, 0) + nvl(AA_EXP_SUM(I).OUTCOME, 0);
					AA_FO_KBK_SUM(CURR_NUM).PAYSUM := nvl(AA_FO_KBK_SUM(CURR_NUM).PAYSUM, 0) + nvl(AA_EXP_SUM(I).PAYSUM, 0);
					AA_FO_KBK_SUM(CURR_NUM).ZKPSUM_REQUISITS := nvl(AA_FO_KBK_SUM(CURR_NUM).ZKPSUM_REQUISITS, 0) + nvl(AA_EXP_SUM(I).ZKPSUM_REQUISITS, 0);
					AA_FO_KBK_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS := nvl(AA_FO_KBK_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS, 0) + nvl(AA_EXP_SUM(I).ZKPSUM_NO_REQUISITS, 0);
					nFLAG := 1;
					exit;
				end if;
			CURR_NUM := AA_FO_KBK_SUM.NEXT(CURR_NUM);
			end loop;

			if nFLAG = 0 then
				CURR_NUM := AA_FO_KBK_SUM.COUNT + 1;
				AA_FO_KBK_SUM(CURR_NUM).ORGRN := AA_EXP_SUM(I).ORGRN;
				AA_FO_KBK_SUM(CURR_NUM).KBKRN := AA_EXP_SUM(I).KBKRN;
				AA_FO_KBK_SUM(CURR_NUM).KBKCODE := AA_EXP_SUM(I).KBKCODE;
				AA_FO_KBK_SUM(CURR_NUM).EXPKVR := AA_EXP_SUM(I).EXPKVR;
				AA_FO_KBK_SUM(CURR_NUM).KVRCODE := AA_EXP_SUM(I).KVRCODE;
				AA_FO_KBK_SUM(CURR_NUM).FOTYPE2 := AA_EXP_SUM(I).FOTYPE2;
				AA_FO_KBK_SUM(CURR_NUM).FOTYPENAME := AA_EXP_SUM(I).FOTYPENAME;
				AA_FO_KBK_SUM(CURR_NUM).OUTCOME := AA_EXP_SUM(I).OUTCOME;
				AA_FO_KBK_SUM(CURR_NUM).PAYSUM := AA_EXP_SUM(I).PAYSUM;
				AA_FO_KBK_SUM(CURR_NUM).ZKPSUM_REQUISITS := AA_EXP_SUM(I).ZKPSUM_REQUISITS;
				AA_FO_KBK_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS := AA_EXP_SUM(I).ZKPSUM_NO_REQUISITS;

			else
				nFLAG := 0;
			end if;
		end loop;
	 end if;

    ZP_PRINT_HEADER(pALLORGRN);

	if AA_EXP_SUM.COUNT >0 then
		CURR_NUM := AA_EXP_SUM.FIRST;
		loop
		exit when CURR_NUM is null;
			if nPREVORGRN != AA_EXP_SUM(CURR_NUM).ORGRN or nPREVORGRN is null then

				AA_FO_SUM.delete;
				nINCOME := null;
				nOUTCOME := null;
				nPAYSUM := null;
				nZKPSUM_REQUISITS := null;
				nZKPSUM_NO_REQUISITS := null;
				nPREVFO := null;

				nPREVORGRN := AA_EXP_SUM(CURR_NUM).ORGRN;

				CURR_NUM_ORG := AA_FO_KBK_SUM.FIRST;
				loop
					exit when CURR_NUM_ORG is null;

					if AA_FO_KBK_SUM(CURR_NUM_ORG).ORGRN = nPREVORGRN then
						nOUTCOME := nvl(nOUTCOME, 0) + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).OUTCOME, 0);
						nPAYSUM := nvl(nPAYSUM, 0) + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).PAYSUM, 0);
						nZKPSUM_REQUISITS := nvl(nZKPSUM_REQUISITS, 0) + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).ZKPSUM_REQUISITS, 0);
						nZKPSUM_NO_REQUISITS := nvl(nZKPSUM_NO_REQUISITS, 0) + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).ZKPSUM_NO_REQUISITS, 0);

						if  AA_FO_SUM.EXISTS(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2) then
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).OUTCOME := AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).OUTCOME + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).OUTCOME, 0);
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).PAYSUM := AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).PAYSUM + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).PAYSUM, 0);
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).ZKPSUM_REQUISITS := AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).ZKPSUM_REQUISITS + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).ZKPSUM_REQUISITS, 0);
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).ZKPSUM_NO_REQUISITS := AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).ZKPSUM_NO_REQUISITS + nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).ZKPSUM_NO_REQUISITS, 0);
						else
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).OUTCOME := nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).OUTCOME, 0);
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).PAYSUM := nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).PAYSUM, 0);
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).ZKPSUM_REQUISITS := nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).ZKPSUM_REQUISITS, 0);
							AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).ZKPSUM_NO_REQUISITS := nvl(AA_FO_KBK_SUM(CURR_NUM_ORG).ZKPSUM_NO_REQUISITS, 0);

							if AA_INC.COUNT > 0 then
							for I in 1..AA_INC.COUNT
							loop
								if AA_INC(I).ORGRN = nPREVORGRN then
									if AA_INC(I).FOTYPE2 = AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2 then
										nINCOME := nvl(nINCOME, 0) + nvl(AA_INC(I).INCOME, 0);
										AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).INCOME := nvl(AA_FO_SUM(AA_FO_KBK_SUM(CURR_NUM_ORG).FOTYPE2).INCOME, 0) + nvl(AA_INC(I).INCOME, 0);
									end if;
								end if;
							end loop;
							end if;
						end if;
					end if;

					CURR_NUM_ORG := AA_FO_KBK_SUM.NEXT(CURR_NUM_ORG);
				end loop;

				if pALLORGRN = 1 then
					nDIFF_REST_ZKP := nvl(nOUTCOME, 0) - nvl(nZKPSUM_REQUISITS, 0) - nvl(nZKPSUM_NO_REQUISITS, 0);
					nNOT_PAID_ZKP := nvl(nZKPSUM_REQUISITS, 0) - nvl(nPAYSUM, 0);
					htp.p( '<tr>
							 <td class="c0 first group1"><div class="c0">'||AA_EXP_SUM(CURR_NUM).ORGNAME ||'</div></td>
							 <td class="c1 first group1"><div class="c1"></div></td>
							 <td class="c2 group1 hide_cell" ><div class="c2"></div></td>
							 <td class="c3 group1" ><div class="c3"></div></td>
							 <td class="c4 group1" ><div class="c4"></div></td>
							 <td class="c5 group1" ><div class="c5">'||to_char(nvl(nINCOME, 0) ,sFMT)||'</div></td>
							 <td class="c6 group1" ><div class="c6">'||to_char(nvl(nOUTCOME, 0) ,sFMT)||'</div></td>
							 <td class="c10 group1" ><div class="c10">'||to_char(nvl(nPAYSUM, 0),sFMT)||'</div></td>

							 <td class="c11 group1" ><div class="c11">'||to_char(nNOT_PAID_ZKP ,sFMT)||'</div></td>
							 <td class="c12 group1" ><div class="c12">'||to_char(nvl(nZKPSUM_REQUISITS, 0) ,sFMT)||'</div></td>
							 <td class="c8 group1" ><div class="c8">'||to_char(nvl(nZKPSUM_NO_REQUISITS, 0) ,sFMT)||'</div></td>
							 <td class="c9 group1 '||case when nDIFF_REST_ZKP < 0 then 'red' else null end||'" ><div class="c9">'||to_char(nDIFF_REST_ZKP ,sFMT)||'</div></td>
							</tr>');
				end if;
			end if;

			if nPREVFO != AA_EXP_SUM(CURR_NUM).FOTYPE2 or nPREVFO is null then
				nPREVFO := AA_EXP_SUM(CURR_NUM).FOTYPE2;
				nPREVKBK := null;
				nPREVKVR := null;

				nDIFF_REST_ZKP := nvl(AA_FO_SUM(nPREVFO).OUTCOME,0) - nvl(AA_FO_SUM(nPREVFO).ZKPSUM_REQUISITS,0) - nvl(AA_FO_SUM(nPREVFO).ZKPSUM_NO_REQUISITS,0);
				nNOT_PAID_ZKP := nvl(AA_FO_SUM(nPREVFO).ZKPSUM_REQUISITS,0) - nvl(AA_FO_SUM(nPREVFO).PAYSUM,0);
				htp.p( '<tr>
						 <td class="c0 first group2 '||case when pALLORGRN is null then 'hide_cell' else null end||'"><div class="c0">'||AA_EXP_SUM(CURR_NUM).ORGNAME ||'</div></td>
						 <td class="c1 first group2"><div class="c1">'||case when AA_EXP_SUM(CURR_NUM).FOTYPENAME = '-' then 'Не задано' else AA_EXP_SUM(CURR_NUM).FOTYPENAME end||'</div></td>
						 <td class="c2 group2 '||case when pALLORGRN = 1 then 'hide_cell' else null end||'" ><div class="c2"></div></td>
						 <td class="c3 group2" ><div class="c3"></div></td>
						 <td class="c4 group2" ><div class="c4"></div></td>
						 <td class="c5 group2" ><div class="c5">'||to_char(nvl(AA_FO_SUM(nPREVFO).INCOME, 0) ,sFMT)||'</div></td>
						 <td class="c6 group2" ><div class="c6">'||to_char(nvl(AA_FO_SUM(nPREVFO).OUTCOME, 0) ,sFMT)||'</div></td>
						 <td class="c10 group2" ><div class="c10">'||to_char(nvl(AA_FO_SUM(nPREVFO).PAYSUM, 0),sFMT)||'</div></td>

						 <td class="c11 group2" ><div class="c11">'||to_char(nNOT_PAID_ZKP ,sFMT)||'</div></td>
						 <td class="c12 group2" ><div class="c12">'||to_char(nvl(AA_FO_SUM(nPREVFO).ZKPSUM_REQUISITS, 0) ,sFMT)||'</div></td>
						 <td class="c8 group2" ><div class="c8">'||to_char(nvl(AA_FO_SUM(nPREVFO).ZKPSUM_NO_REQUISITS, 0) ,sFMT)||'</div></td>
						 <td class="c9 group2 '||case when nDIFF_REST_ZKP < 0 then 'red' else null end||'" ><div class="c9">'||to_char(nDIFF_REST_ZKP ,sFMT)||'</div></td>
						</tr>');
			end if;

			if pALLORGRN is null and (nPREVKBK != AA_EXP_SUM(CURR_NUM).KBKRN or nPREVKBK is null) then
				nPREVKBK := AA_EXP_SUM(CURR_NUM).KBKRN;
				nINCOME := null;
				nOUTCOME := null;
				nPAYSUM := null;
				nZKPSUM_REQUISITS := null;
				nZKPSUM_NO_REQUISITS := null;
				nPREVKVR := null;

				if AA_INC.COUNT > 0 then
					nINCOME	:= null;

					for I in 1..AA_INC.COUNT
					loop
						if AA_INC(I).ORGRN = AA_EXP_SUM(CURR_NUM).ORGRN and AA_INC(I).FOTYPE2 = AA_EXP_SUM(CURR_NUM).FOTYPE2 and AA_INC(I).KBKRN = nPREVKBK then
							nINCOME := nvl(nINCOME, 0) + nvl(AA_INC(I).INCOME, 0);
						end if;
					end loop;
				end if;

				if AA_FO_KBK_SUM.COUNT > 0 then
					for I in 1..AA_FO_KBK_SUM.COUNT
					loop
						if AA_FO_KBK_SUM(I).ORGRN = AA_EXP_SUM(CURR_NUM).ORGRN and AA_FO_KBK_SUM(I).FOTYPE2 = AA_EXP_SUM(CURR_NUM).FOTYPE2 and AA_FO_KBK_SUM(I).KBKRN = nPREVKBK then
							nOUTCOME := nvl(nOUTCOME, 0) + nvl(AA_FO_KBK_SUM(I).OUTCOME, 0);
							nPAYSUM := nvl(nPAYSUM, 0) + nvl(AA_FO_KBK_SUM(I).PAYSUM, 0);
							nZKPSUM_REQUISITS := nvl(nZKPSUM_REQUISITS, 0) + nvl(AA_FO_KBK_SUM(I).ZKPSUM_REQUISITS, 0);
							nZKPSUM_NO_REQUISITS := nvl(nZKPSUM_NO_REQUISITS, 0) + nvl(AA_FO_KBK_SUM(I).ZKPSUM_NO_REQUISITS, 0);
						end if;
					end loop;

					nDIFF_REST_ZKP := nvl(nOUTCOME,0) - nvl(nZKPSUM_REQUISITS,0) - nvl(nZKPSUM_NO_REQUISITS,0);
					nNOT_PAID_ZKP := nvl(nZKPSUM_REQUISITS,0) - nvl(nPAYSUM,0);

					htp.p( '<tr>
					 <td class="c0 first group3 hide_cell"><div class="c0">'||AA_EXP_SUM(CURR_NUM).ORGNAME ||'</div></td>
					 <td class="c1 first group3"><div class="c1">'||case when AA_EXP_SUM(CURR_NUM).FOTYPENAME = '-' then 'Не задано' else AA_EXP_SUM(CURR_NUM).FOTYPENAME end||'</div></td>
					 <td class="c2 group3" ><div class="c2"><a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':575:'||:APP_SESSION||'::::P575_ALLORGRN,P575_KBK,P575_KOSGU:1,'||nPREVKBK)||'">'||AA_EXP_SUM(CURR_NUM).KBKCODE||'</a></div></td>
					 <td class="c3 group3" ><div class="c3"></div></td>
					 <td class="c4 group3" ><div class="c4"></div></td>
					 <td class="c5 group3" ><div class="c5">'||to_char(nvl(nINCOME, 0) ,sFMT)||'</div></td>
					 <td class="c6 group3" ><div class="c6">'||to_char(nvl(nOUTCOME,0) ,sFMT)||'</div></td>
					 <td class="c10 group3" ><div class="c10">'||to_char(nvl(nPAYSUM,0),sFMT)||'</div></td>

					 <td class="c11 group3" ><div class="c11">'||to_char(nNOT_PAID_ZKP ,sFMT)||'</div></td>
					 <td class="c12 group3" ><div class="c12">'||to_char(nvl(nZKPSUM_REQUISITS,0) ,sFMT)||'</div></td>
					 <td class="c8 group3" ><div class="c8">'||to_char(nvl(nZKPSUM_NO_REQUISITS,0) ,sFMT)||'</div></td>
					 <td class="c9 group3 '||case when nDIFF_REST_ZKP < 0 then 'red' else null end||'" ><div class="c9">'||to_char(nDIFF_REST_ZKP ,sFMT)||'</div></td>
					</tr>');
				end if;
			end if;

			if nPREVKVR != AA_EXP_SUM(CURR_NUM).EXPKVR or nPREVKVR is null then
				nPREVKVR := AA_EXP_SUM(CURR_NUM).EXPKVR;

				if AA_FO_KBK_SUM.COUNT > 0 then
					for I in 1..AA_FO_KBK_SUM.COUNT
					loop
						if AA_FO_KBK_SUM(I).ORGRN = AA_EXP_SUM(CURR_NUM).ORGRN and AA_FO_KBK_SUM(I).FOTYPE2 = AA_EXP_SUM(CURR_NUM).FOTYPE2 and AA_FO_KBK_SUM(I).KBKRN = AA_EXP_SUM(CURR_NUM).KBKRN and AA_FO_KBK_SUM(I).EXPKVR = nPREVKVR then

							nDIFF_REST_ZKP := nvl(AA_FO_KBK_SUM(I).OUTCOME,0) - nvl(AA_FO_KBK_SUM(I).ZKPSUM_REQUISITS,0) - nvl(AA_FO_KBK_SUM(I).ZKPSUM_NO_REQUISITS,0);
							nNOT_PAID_ZKP := nvl(AA_FO_KBK_SUM(I).ZKPSUM_REQUISITS,0) - nvl(AA_FO_KBK_SUM(I).PAYSUM,0);

							htp.p( '<tr>
							 <td class="c0 first group4 '||case when pALLORGRN is null then 'hide_cell' else null end||'"><div class="c0">'||AA_EXP_SUM(CURR_NUM).ORGNAME ||'</div></td>
							 <td class="c1 first group4"><div class="c1">'||case when AA_EXP_SUM(CURR_NUM).FOTYPENAME = '-' then 'Не задано' else AA_EXP_SUM(CURR_NUM).FOTYPENAME end||'</div></td>
							 <td class="c2 group4 '||case when pALLORGRN = 1 then 'hide_cell' else null end||'" ><div class="c2"><a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':575:'||:APP_SESSION||'::::P575_ALLORGRN,P575_KBK,P575_KOSGU:1,'||nPREVKBK)||'">'||AA_EXP_SUM(CURR_NUM).KBKCODE||'</a></div></td>
							 <td class="c3 group4" ><div class="c3">'||AA_EXP_SUM(CURR_NUM).KVRCODE||'</div></td>
							 <td class="c4 group4" ><div class="c4"></div></td>
							 <td class="c5 group4" ><div class="c5"></div></td>
							 <td class="c6 group4" ><div class="c6">'||to_char(nvl(AA_FO_KBK_SUM(I).OUTCOME,0) ,sFMT)||'</div></td>
							 <td class="c10 group4" ><div class="c10">'||to_char(nvl(AA_FO_KBK_SUM(I).PAYSUM,0),sFMT)||'</div></td>

							 <td class="c11 group4" ><div class="c11">'||to_char(nNOT_PAID_ZKP ,sFMT)||'</div></td>
							 <td class="c12 group4" ><div class="c12">'||to_char(nvl(AA_FO_KBK_SUM(I).ZKPSUM_REQUISITS,0) ,sFMT)||'</div></td>
							 <td class="c8 group4" ><div class="c8">'||to_char(nvl(AA_FO_KBK_SUM(I).ZKPSUM_NO_REQUISITS,0) ,sFMT)||'</div></td>
							 <td class="c9 group4 '||case when nDIFF_REST_ZKP < 0 then 'red' else null end||'" ><div class="c9">'||to_char(nDIFF_REST_ZKP ,sFMT)||'</div></td>
							</tr>');
						    EXIT;
						end if;
					end loop;
				end if;
			end if;

			begin
				select SFKR, substr(KBK.SPARTICLE, 0, 2), replace(substr(KBK.SPARTICLE, 0, 4), ' ', '.') SUBPROG, trim(substr(KBK.SPARTICLE, 5))
				  into sKBK_SFKR, sKBK_PROG, sKBK_SUBPROG ,sKBK_MEANING
				  from ZV_KBKALL KBK
				 where NKBK_RN = AA_EXP_SUM(CURR_NUM).KBKRN;

				select EXPFKR.NAME, EXPROGRAM.NAME PR, EXPROGRAM_SUB.NAME, EXPDIR.NAME
				  into sEXPFKR, sPROG, sSUBPROG, sMEANING
				  from Z_EXPFKR EXPFKR, Z_EXPROGRAM EXPROGRAM, Z_EXPROGRAM EXPROGRAM_SUB, Z_EXPDIR EXPDIR
				 where EXPFKR.NUMB = sKBK_SFKR
				   and EXPROGRAM.VERSION = pVERSION
				   and EXPROGRAM.CODE = sKBK_PROG
				   and EXPROGRAM_SUB.VERSION = pVERSION
				   and EXPROGRAM_SUB.CODE = sKBK_SUBPROG
				   and EXPDIR.VERSION = pVERSION
				   and EXPDIR.CODE = sKBK_MEANING;
			exception when others then
				sEXPFKR := null;
				sPROG := null;
				sSUBPROG := null;
				sMEANING := null;
			end;

			nDIFF_REST_ZKP := nvl(AA_EXP_SUM(CURR_NUM).OUTCOME, 0) - nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_REQUISITS, 0) - nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS, 0);
			nNOT_PAID_ZKP := nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_REQUISITS, 0) - nvl(AA_EXP_SUM(CURR_NUM).PAYSUM, 0);
			count_rows := count_rows+1;

			htp.p('<tr>
				<td class="c0 first '||case when pALLORGRN is null then 'hide_cell' else null end||'"><div class="c0">'||AA_EXP_SUM(CURR_NUM).ORGNAME ||'</div></td>
				<td class="c1 " ><div class="c1">'||AA_EXP_SUM(CURR_NUM).FOTYPENAME ||'</div></td>
				<td class="c2 '||case when pALLORGRN = 1 then 'hide_cell' else null end||'" ><div class="c2" title="РзПр: '||sEXPFKR ||chr(10)||'Программа: '||sPROG  ||chr(10)||'Подпрограмма: '|| sSUBPROG ||chr(10)||'Направление: '||sMEANING ||'"><a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':575:'||:APP_SESSION||'::::P575_ALLORGRN,P575_KBK,P575_KOSGU:1,'||nPREVKBK)||'">'||AA_EXP_SUM(CURR_NUM).KBKCODE||'</a></div></td>
				<td class="c3 " ><div class="c3">'||AA_EXP_SUM(CURR_NUM).KVRCODE ||'</div></td>
				<td class="c4 " ><div class="c4">'||case when pALLORGRN is null then '<a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':575:'||:APP_SESSION||'::::P575_ALLORGRN,P575_KBK,P575_KOSGU:1,'||nPREVKBK||','||AA_EXP_SUM(CURR_NUM).KOSGURN)||'">'||AA_EXP_SUM(CURR_NUM).KOSGUCODE||'</a>' else AA_EXP_SUM(CURR_NUM).KOSGUCODE end ||'</div></td>
				<td class="c5 " ><div class="c5"></div></td>
				<td class="c6 " ><div class="c6">'||to_char(nvl(AA_EXP_SUM(CURR_NUM).OUTCOME, 0),sFMT)||'</div></td>
				<td class="c10 " ><div class="c10">'||to_char(nvl(AA_EXP_SUM(CURR_NUM).PAYSUM, 0),sFMT)||'</div></td>

        <td class="c11 " ><div class="c11">'||to_char(nNOT_PAID_ZKP, sFMT)||'</div></td>
        <td class="c12 " ><div class="c12">'||case when pALLORGRN is null then '<a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':638:'||:APP_SESSION||'::::P638_TYPE,P638_KBK,P638_KOSGU,P638_KVR,P638_FOTYPE2,P638_PERIOD:1,        '||AA_EXP_SUM(CURR_NUM).KBKRN||','||AA_EXP_SUM(CURR_NUM).KOSGURN||','||AA_EXP_SUM(CURR_NUM).EXPKVR||','||AA_EXP_SUM(CURR_NUM).FOTYPE2)||','||pPERIOD||'">'||to_char(nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_REQUISITS, 0), sFMT)||'</a>' else to_char(nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_REQUISITS, 0), sFMT) end ||'</div></td>

        <td class="c8 " ><div class="c8">'||case when pALLORGRN is null then '<a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':638:'||:APP_SESSION||'::::P638_TYPE,P638_KBK,P638_KOSGU,P638_KVR,P638_FOTYPE2,P638_PERIOD:2,'||AA_EXP_SUM(CURR_NUM).KBKRN||','||AA_EXP_SUM(CURR_NUM).KOSGURN||','||AA_EXP_SUM(CURR_NUM).EXPKVR||','||AA_EXP_SUM(CURR_NUM).FOTYPE2)||','||pPERIOD||'">'||to_char(nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS, 0), sFMT)||'</a>' else to_char(nvl(AA_EXP_SUM(CURR_NUM).ZKPSUM_NO_REQUISITS, 0), sFMT) end ||'</div></td>

				<td class="c9 last" ><div class="c9 '||case when nDIFF_REST_ZKP < 0 then 'red' else null end||'">'||to_char(nDIFF_REST_ZKP, sFMT)||'</div></td>

			 </tr>');
			CURR_NUM := AA_EXP_SUM.NEXT(CURR_NUM);
		end loop;
	end if;

    ZP_PRINT_FOOTER(sColor, sMSG, count_rows);

end;
