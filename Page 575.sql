declare
 pJURPERS      number := :P1_JURPERS;
 pVERSION      number := :P1_VERSION;
 pORGRN	       number := nvl(:P1_ORGRN,:P7_ORGFILTER);
 pKVR		   number := :P575_KVR;
 pKOSGU  	   number := :P575_KOSGU;
 pFOTYPE       number := :P575_FOTYPE;
 pKBK		   number := :P575_KBK;
 pPERIOD       number := 3;

 --------------------------
 nARRPASTE             number;
 nFOTYPEMARK           number;

 nKBKMARK              number;
 nKBKCOUNT             number;

 nKVRMARK              number;
 nKVRCOUNT             number;

 nKOSGUMARK            number;
 nKOSGUCOUNT           number;

 nOUTSUM               number;
 nPAYSUM               number;
 nZKPSUM_REQUISITS     number;
 nZKPSUM_NO_REQUISITS  number;
 nINCSUM               number;
 -----------------
 sFOTYPE2      varchar2(4000);
 sKBK          varchar2(4000);
 sKVR          varchar2(4000);
 sKOSGU        varchar2(4000);
 sINCOME       varchar2(4000);
 sOUTCOME      varchar2(4000);
 sPAYSUM       varchar2(4000);
 sNOTPAID      varchar2(4000);
 sZKPREQ       varchar2(4000);
 sZKPNOREQ     varchar2(4000);
 sREST         varchar2(4000);

 --------------------------
 type t_exp is record(
  TYPESTR             varchar2(200),
  FOTYPE2             number,
  FOTYPENAME          varchar2(200),
  KBKRN               number,
  KVRRN               number,
  KVRCODE             varchar2(200),
  KOSGURN             number,
  KOSGUCODE           varchar2(200),
  OUTSUM              number,
  PAYSUM              number,
  ZKPSUM_REQUISITS    number,
  ZKPSUM_NO_REQUISITS number,
  INCSUM              number
 );

 type t_exp_arr is table of t_exp index by pls_integer;
 EXPARR t_exp_arr;

 type t_exp1_arr is table of t_exp index by pls_integer;
 TEMPKBK t_exp1_arr;

 type t_exp2_arr is table of t_exp index by pls_integer;
 TEMPKVR t_exp2_arr;

 type t_exp3_arr is table of t_exp index by pls_integer;
 TEMPKOSGU t_exp3_arr;

begin
    -- создание коллекции
    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('LIM_ZKP');

    for rec in
    (
     select 1 TYPESTR,
	        E.FOTYPE2, L.NAME FOTYPENAME,
            EA.KBK_RN KBKRN,
            KVR.RN KVRRN, KVR.CODE KVRCODE,
            K.RN KOSGURN, K.CODE KOSGUCODE,
			sum(ZP_GET_EXP_HIST_ACCEPT (pPARENT => nvl(EA.PARENT_ROW,EA.PRN), pVERSION => EA.VERSION, pORGRN => EA.ORGRN, pPERIOD =>3)) OUTSUM,
			null PAYSUM,
		    null ZKPSUM_REQUISITS,
		    null ZKPSUM_NO_REQUISITS,
			null INCSUM
       from Z_EXPALL EA, Z_LOV L, Z_EXPMAT E, Z_EXPKVR_ALL KVR, Z_KOSGU K
      where EA.JUR_PERS = pJURPERS
	    and EA.VERSION  = pVERSION

		and (EA.ORGRN   = pORGRN or pORGRN is null)
        and ((pKVR is null) or (E.EXPKVR = pKVR))
 	    and ((pKOSGU is null) or (E.KOSGURN = pKOSGU))
 	    and ((pFOTYPE is null) or (E.FOTYPE2 = pFOTYPE))
 	    and ((pKBK is null) or (EA.KBK_RN = pKBK))

        and KVR.CODE in ('242', '243', '244', '247')
        and (nvl(EA.SERVSUM, 0) + nvl(EA.MSUM ,0) + nvl(EA.RESTSUM, 0)) != 0

        and E.FOTYPE2 = L.NUM(+)
        and PART(+) = 'FOTYPE2'
	    and EA.EXP_ARTICLE = E.RN
		and E.EXPKVR = KVR.RN
        and E.KOSGURN = K.RN
        and E.FOTYPE2 = 2
      group by E.FOTYPE2, L.NAME,
               EA.KBK_RN,
               KVR.RN , KVR.CODE,
               K.RN , K.CODE

	union all
	select 2 TYPESTR,
	       P.FOTYPE2, L.NAME FOTYPENAME,
           P.KBK_RN KBKRN,
           KVR.RN KVRRN, KVR.CODE KVRCODE,
           K.RN KOSGURN, K.CODE KOSGUCODE,
           null OUTSUM,
		   sum(P.SUMMA) PAYSUM,
		   null ZKPSUM_REQUISITS,
		   null ZKPSUM_NO_REQUISITS,
		   null INCSUM
       from Z_PAY P, Z_KOSGU K, Z_EXPKVR_ALL KVR, Z_LOV L, Z_ZKP_SPEC_LINKS ZSL
      where P.JUR_PERS = pJURPERS
	    and P.VERSION  = pVERSION

		and (P.ORGRN   = pORGRN or pORGRN is null)
    	and ((pKVR is null) or (P.KVR = pKVR) or (P.KVR is null))
    	and ((pKOSGU is null) or (P.KOSGU = pKOSGU) or (P.KOSGU is null))
		and ((pFOTYPE is null) or (P.FOTYPE2 = pFOTYPE and nvl(PAY_MARK, 0) = 0) or (P.FOTYPE2 is null))
		and ((pKBK is null) or (P.KBK_RN = pKBK) or (P.KBK_RN is null))

		and P.KOSGU = K.RN(+)
	    and P.KVR = KVR.RN
    	and P.FOTYPE2 = L.NUM(+)
		and P.RN = ZSL.PAY_RN
    	and PART(+) = 'FOTYPE2'
		and P.STATUS != 2

    	and KVR.CODE in ('242', '243', '244', '247')
		and ZP_PAY_REESTR_STATUS_GET(P.VERSION, P.PAY_REESTR_RN) = 5
    	and nvl(P.SUMMA, 0) != 0
		and P.FOTYPE2 = 2
      group by P.FOTYPE2, L.NAME,
               P.KBK_RN,
               KVR.RN, KVR.CODE,
               K.RN, K.CODE


	union all
	select 3 TYPESTR,
	       ZS.FOTYPE2, L.NAME FOTYPENAME,
           ZS.KBK_RN KBKRN,
           KVR.RN KVRRN, KVR.CODE KVRCODE,
           K.RN KOSGURN, K.CODE KOSGUCODE,
		   null OUTSUM,
		   null PAYSUM,
		   sum(case when P.AGRDATE is not null
				 or P.AGRNUMB is not null
				 or P.VENDOR_ALL_RN is not null then case pPERIOD when 3 then nvl(ZSP.SUMMA, 0)
																  when 4 then nvl(ZSP.SUMMA2, 0)
																  when 5 then nvl(ZSP.SUMMA3, 0) end else 0 end) ZKPSUM_REQUISITS,

			sum(case when P.AGRDATE is null
				 and P.AGRNUMB is null
				 and P.VENDOR_ALL_RN is null then case pPERIOD when 3 then nvl(ZSP.SUMMA, 0)
															   when 4 then nvl(ZSP.SUMMA2, 0)
															   when 5 then nvl(ZSP.SUMMA3, 0) end else 0 end) ZKPSUM_NO_REQUISITS,
		   null INCSUM
      from Z_ZKP P, Z_ZKP_SPEC ZS, Z_ZKP_SPECPRICE ZSP, Z_KOSGU K, Z_EXPKVR_ALL KVR, Z_LOV L
     where P.JUR_PERS = pJURPERS
	   and P.VERSION  = pVERSION

	   and (P.ORGRN   = pORGRN or pORGRN is null)
       and ((pKVR is null) or (ZS.KBK_RN = pKVR) or (ZS.KBK_RN is null))
       and ((pKOSGU is null) or (ZS.KOSGU_RN = pKOSGU) or (ZS.KOSGU_RN is null))
       and ((pFOTYPE is null) or (ZS.FOTYPE2 = pFOTYPE) or (ZS.FOTYPE2 is null))
       and ((pKBK is null) or (ZS.KBK_RN = pKBK) or (ZS.KBK_RN is null))

	   and P.RN = ZS.ZKP_RN
       and ZSP.ZKP_SPEC_RN = ZS.RN
       and ZS.KVR_RN = KVR.RN(+)
       and ZS.KOSGU_RN = K.RN(+)
       and ZS.FOTYPE2 = L.NUM(+)
       and L.PART(+) = 'FOTYPE2'

	   and nvl(P.EXIST_SIGN, 0) != 1
	   and ZF_REESTR_STATUS_GET(P.VERSION,  P.RN, 'ZKP_REESTR') = 5
       and nvl(ZSP.SUMMA, 0) != 0
	   and ZS.FOTYPE2 = 2
	 group by ZS.FOTYPE2, L.NAME,
              ZS.KBK_RN,
              KVR.RN, KVR.CODE,
              K.RN, K.CODE

	union all

	select 4 TYPESTR,
	       D.FOTYPE2, L.NAME FOTYPENAME,
		   D.KBK KBKRN,
		   null KVRRN, null KVRCODE,
           null KOSGURN, null KOSGUCODE,
		   null OUTSUM,
		   null PAYSUM,
		   null ZKPSUM_REQUISITS,
		   null ZKPSUM_NO_REQUISITS,
		   sum(ZP_GET_INC_HIST_ACCEPT (pPARENT => D.RN, pVERSION => D.VERSION, pORGRN => D.PRN, pFOTYPE2 => D.FOTYPE2, pPERIOD =>3)) INCSUM
	  from Z_ORG_BUDGDETAIL D, Z_LOV L
	 where D.JUR_PERS = pJURPERS
	   and D.VERSION  = pVERSION

	   and (D.PRN  = pORGRN or pORGRN is null)
	   and ((pFOTYPE is null) or (D.FOTYPE2 = pFOTYPE))
	   and ((pKBK is null) or (D.KBK = pKBK))

       and D.FOTYPE2 = L.NUM(+)
       and L.PART(+) = 'FOTYPE2'

	   and nvl(D.TOTAL_SIGN,0) = 0
	   and D.FOTYPE2 = 2
	 group by D.FOTYPE2, L.NAME,
			  D.KBK


    union all

	select 4 TYPESTR,
	       D.FOTYPE2, L.NAME FOTYPENAME,
		   (select NKBK_RN from ZV_KBKALL where NVERSION = pVERSION and SCODE = '0000.00 0 0000.000') KBKRN,
		   null KVRRN, null KVRCODE,
           null KOSGURN, null KOSGUCODE,
		   null OUTSUM,
		   null PAYSUM,
		   null ZKPSUM_REQUISITS,
		   null ZKPSUM_NO_REQUISITS,
		   sum(ZP_GET_INC_HIST_ACCEPT (pPARENT => D.RN, pVERSION => D.VERSION, pORGRN => D.PRN, pFOTYPE2 => D.FOTYPE2, pPERIOD =>3)) INCSUM
	  from Z_ORG_VBDETAIL D, Z_LOV L
	 where D.JUR_PERS = pJURPERS
	   and D.VERSION  = pVERSION

	   and (D.PRN  = pORGRN or pORGRN is null)
	   and ((pFOTYPE is null) or (D.FOTYPE2 = pFOTYPE))

       and D.FOTYPE2 = L.NUM(+)
       and L.PART(+) = 'FOTYPE2'

	   and nvl(D.TOTAL_SIGN,0) = 0
	   and D.FOTYPE2 = 2
	 group by D.FOTYPE2, L.NAME
     order by FOTYPE2, FOTYPENAME, KBKRN, KVRRN, KOSGURN
	)
	loop

        nARRPASTE := nvl(nARRPASTE, 0) + 1;

        EXPARR(nARRPASTE).TYPESTR              := rec.TYPESTR;
        EXPARR(nARRPASTE).FOTYPE2              := rec.FOTYPE2;
        EXPARR(nARRPASTE).FOTYPENAME           := rec.FOTYPENAME;
        EXPARR(nARRPASTE).KBKRN                := rec.KBKRN;
        EXPARR(nARRPASTE).KVRRN                := rec.KVRRN;
        EXPARR(nARRPASTE).KVRCODE              := rec.KVRCODE;
        EXPARR(nARRPASTE).KOSGURN              := rec.KOSGURN;
        EXPARR(nARRPASTE).KOSGUCODE            := rec.KOSGUCODE;
        EXPARR(nARRPASTE).OUTSUM               := rec.OUTSUM;
        EXPARR(nARRPASTE).PAYSUM               := rec.PAYSUM;
        EXPARR(nARRPASTE).ZKPSUM_REQUISITS     := rec.ZKPSUM_REQUISITS;
        EXPARR(nARRPASTE).ZKPSUM_NO_REQUISITS  := rec.ZKPSUM_NO_REQUISITS;
        EXPARR(nARRPASTE).INCSUM               := rec.INCSUM;

	end loop;

	htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1" rowspan="2" ><div class="th1">Вид ФО</div></th>
         <th class="header th2 " rowspan="2"><div class="th2">КБК</div></th>
         <th class="header th3" rowspan="2"><div class="th3">КВР</div></th>
         <th class="header th4" rowspan="2"><div class="th4">КОСГУ</div></th>
         <th class="header th5" rowspan="2"><div class="th5">Лимиты, руб.</div></th>

         <th class="header th6" rowspan="2"><div class="th6">Плановые затраты, руб.</div></th>
         <th class="header th7" colspan="3"><div class="th7">Контракты</div></th>

         <th class="header th8" rowspan="2"><div class="th8">Контракты, планируемые к заключению, руб.</div></th>
         <th class="header th9" rowspan="2"><div class="th9">Остаток,руб</div></th>
         <th class="header" rowspan="2"><div style="width:8px"></div></th>
         </tr>
         <tr>
         <th class="header th10"><div class="th10">Оплаченные, руб.</div></th>
         <th class="header th11"><div class="th11">Неоплаченные, руб.</div></th>
         <th class="header th12"><div class="th12">Всего, руб.</div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    for STARTARR in EXPARR.FIRST..EXPARR.COUNT
    loop
        if nvl(nFOTYPEMARK, 0) != EXPARR(STARTARR).FOTYPE2 then
            nFOTYPEMARK := EXPARR(STARTARR).FOTYPE2;
            nOUTSUM              := 0;
            nPAYSUM              := 0;
            nZKPSUM_REQUISITS    := 0;
            nZKPSUM_NO_REQUISITS := 0;
            nINCSUM              := 0;

            TEMPKBK.delete;
            TEMPKVR.delete;
            nKBKCOUNT := 0;
            nKVRCOUNT := 0;
            nKOSGUCOUNT := 0;

            for QFOT in EXPARR.FIRST..EXPARR.COUNT
            loop
                if EXPARR(QFOT).FOTYPE2 = nFOTYPEMARK then
                    nOUTSUM              := nvl(nOUTSUM, 0) + nvl(EXPARR(QFOT).OUTSUM, 0);
                    nPAYSUM              := nvl(nPAYSUM, 0) + nvl(EXPARR(QFOT).PAYSUM, 0);
                    nZKPSUM_REQUISITS    := nvl(nZKPSUM_REQUISITS, 0) + nvl(EXPARR(QFOT).ZKPSUM_REQUISITS, 0);
                    nZKPSUM_NO_REQUISITS := nvl(nZKPSUM_NO_REQUISITS, 0) + nvl(EXPARR(QFOT).ZKPSUM_NO_REQUISITS, 0);
                    nINCSUM              := nvl(nINCSUM, 0) + nvl(EXPARR(QFOT).INCSUM, 0);

                    for QKBK in EXPARR.FIRST..EXPARR.COUNT
                    loop
                        if EXPARR(QKBK).FOTYPE2 = nFOTYPEMARK then
                            if nvl(nKBKMARK, 0) != nvl(EXPARR(QKBK).KBKRN, 0) then
                                nKBKCOUNT := nKBKCOUNT + 1;
                                nKBKMARK := EXPARR(QKBK).KBKRN;
                                TEMPKBK(nKBKCOUNT).KBKRN  := nKBKMARK;
                                TEMPKBK(nKBKCOUNT).OUTSUM := nvl(EXPARR(QKBK).OUTSUM, 0);
                                TEMPKBK(nKBKCOUNT).PAYSUM := nvl(EXPARR(QKBK).PAYSUM, 0);
                                TEMPKBK(nKBKCOUNT).ZKPSUM_REQUISITS := nvl(EXPARR(QKBK).ZKPSUM_REQUISITS, 0);
                                TEMPKBK(nKBKCOUNT).ZKPSUM_NO_REQUISITS := nvl(EXPARR(QKBK).ZKPSUM_NO_REQUISITS, 0);
                                TEMPKBK(nKBKCOUNT).INCSUM := nvl(EXPARR(QKBK).INCSUM, 0);

                                for QKVR in EXPARR.FIRST..EXPARR.COUNT
                                loop
                                    if ((EXPARR(QKVR).FOTYPE2 = nFOTYPEMARK) and (EXPARR(QKVR).KBKRN = nKBKMARK) and (EXPARR(QKVR).TYPESTR != 4)) then
                                        if EXPARR(QKVR).KVRRN != nvl(nKVRMARK, 0) then
                                            nKVRMARK := EXPARR(QKVR).KVRRN;
                                            nKVRCOUNT := nKVRCOUNT + 1;
                                            TEMPKVR(nKVRCOUNT).KBKRN  := nKBKMARK;
                                            TEMPKVR(nKVRCOUNT).KVRRN  := nKVRMARK;
                                            TEMPKVR(nKVRCOUNT).KVRCODE  := EXPARR(QKVR).KVRCODE;
                                            TEMPKVR(nKVRCOUNT).OUTSUM := nvl(EXPARR(QKVR).OUTSUM, 0);
                                            TEMPKVR(nKVRCOUNT).PAYSUM := nvl(EXPARR(QKVR).PAYSUM, 0);
                                            TEMPKVR(nKVRCOUNT).ZKPSUM_REQUISITS := nvl(EXPARR(QKVR).ZKPSUM_REQUISITS, 0);
                                            TEMPKVR(nKVRCOUNT).ZKPSUM_NO_REQUISITS := nvl(EXPARR(QKVR).ZKPSUM_NO_REQUISITS, 0);
                                            TEMPKVR(nKVRCOUNT).INCSUM := nvl(EXPARR(QKVR).INCSUM, 0);

                                            for QKOSGU in EXPARR.FIRST..EXPARR.COUNT
                                            loop
                                                if ((EXPARR(QKOSGU).FOTYPE2 = nFOTYPEMARK) and (EXPARR(QKOSGU).KBKRN = nKBKMARK) and (EXPARR(QKOSGU).TYPESTR != 4) and (EXPARR(QKOSGU).KVRRN = nKVRMARK)) then
                                                    if EXPARR(QKOSGU).KOSGURN != nvl(nKOSGUMARK, 0) then
                                                        nKOSGUMARK := EXPARR(QKOSGU).KOSGURN;
                                                        nKOSGUCOUNT := nKOSGUCOUNT + 1;
                                                        TEMPKOSGU(nKOSGUCOUNT).KBKRN     := nKBKMARK;
                                                        TEMPKOSGU(nKOSGUCOUNT).KVRRN     := nKVRMARK;
                                                        TEMPKOSGU(nKOSGUCOUNT).KOSGURN   := nKOSGUMARK;
                                                        TEMPKOSGU(nKOSGUCOUNT).KOSGUCODE := EXPARR(QKOSGU).KOSGUCODE;
                                                        TEMPKOSGU(nKOSGUCOUNT).OUTSUM    := nvl(EXPARR(QKOSGU).OUTSUM, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).PAYSUM    := nvl(EXPARR(QKOSGU).PAYSUM, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).ZKPSUM_REQUISITS    := nvl(EXPARR(QKOSGU).ZKPSUM_REQUISITS, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).ZKPSUM_NO_REQUISITS := nvl(EXPARR(QKOSGU).ZKPSUM_NO_REQUISITS, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).INCSUM    := nvl(EXPARR(QKOSGU).INCSUM, 0);
                                                    else
                                                        TEMPKOSGU(nKOSGUCOUNT).KBKRN     := nKBKMARK;
                                                        TEMPKOSGU(nKOSGUCOUNT).KVRRN     := nKVRMARK;
                                                        TEMPKOSGU(nKOSGUCOUNT).KOSGURN   := nKOSGUMARK;
                                                        TEMPKOSGU(nKOSGUCOUNT).KOSGUCODE := EXPARR(QKOSGU).KOSGUCODE;
                                                        TEMPKOSGU(nKOSGUCOUNT).OUTSUM    := nvl(EXPARR(QKOSGU).OUTSUM, 0) + nvl(TEMPKOSGU(nKOSGUCOUNT).OUTSUM, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).PAYSUM    := nvl(EXPARR(QKOSGU).PAYSUM, 0) + nvl(TEMPKOSGU(nKOSGUCOUNT).PAYSUM, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).ZKPSUM_REQUISITS    := nvl(EXPARR(QKOSGU).ZKPSUM_REQUISITS, 0) + nvl(TEMPKOSGU(nKOSGUCOUNT).ZKPSUM_REQUISITS, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).ZKPSUM_NO_REQUISITS := nvl(EXPARR(QKOSGU).ZKPSUM_NO_REQUISITS, 0) + nvl(TEMPKOSGU(nKOSGUCOUNT).ZKPSUM_NO_REQUISITS, 0);
                                                        TEMPKOSGU(nKOSGUCOUNT).INCSUM    := nvl(EXPARR(QKOSGU).INCSUM, 0) + nvl(TEMPKOSGU(nKOSGUCOUNT).INCSUM, 0);
                                                    end if;
                                                end if;
                                            end loop;
                                        else
                                            TEMPKVR(nKVRCOUNT).KBKRN  := nKBKMARK;
                                            TEMPKVR(nKVRCOUNT).KVRRN  := nKVRMARK;
                                            TEMPKVR(nKVRCOUNT).KVRCODE  := EXPARR(QKVR).KVRCODE;
                                            TEMPKVR(nKVRCOUNT).OUTSUM := nvl(TEMPKVR(nKVRCOUNT).OUTSUM, 0) + nvl(EXPARR(QKVR).OUTSUM, 0);
                                            TEMPKVR(nKVRCOUNT).PAYSUM := nvl(TEMPKVR(nKVRCOUNT).PAYSUM, 0) + nvl(EXPARR(QKVR).PAYSUM, 0);
                                            TEMPKVR(nKVRCOUNT).ZKPSUM_REQUISITS := nvl(TEMPKVR(nKVRCOUNT).ZKPSUM_REQUISITS, 0) + nvl(EXPARR(QKVR).ZKPSUM_REQUISITS, 0);
                                            TEMPKVR(nKVRCOUNT).ZKPSUM_NO_REQUISITS := nvl(TEMPKVR(nKVRCOUNT).ZKPSUM_NO_REQUISITS, 0) + nvl(EXPARR(QKVR).ZKPSUM_NO_REQUISITS, 0);
                                            TEMPKVR(nKVRCOUNT).INCSUM := nvl(TEMPKVR(nKVRCOUNT).INCSUM, 0) + nvl(EXPARR(QKVR).INCSUM, 0);
                                        end if;
                                    end if;
                                end loop;
                            else
                                TEMPKBK(nKBKCOUNT).KBKRN  := nKBKMARK;
                                TEMPKBK(nKBKCOUNT).OUTSUM := nvl(TEMPKBK(nKBKCOUNT).OUTSUM, 0) + nvl(EXPARR(QKBK).OUTSUM, 0);
                                TEMPKBK(nKBKCOUNT).PAYSUM := nvl(TEMPKBK(nKBKCOUNT).PAYSUM, 0) + nvl(EXPARR(QKBK).PAYSUM, 0);
                                TEMPKBK(nKBKCOUNT).ZKPSUM_REQUISITS := nvl(TEMPKBK(nKBKCOUNT).ZKPSUM_REQUISITS, 0) + nvl(EXPARR(QKBK).ZKPSUM_REQUISITS, 0);
                                TEMPKBK(nKBKCOUNT).ZKPSUM_NO_REQUISITS := nvl(TEMPKBK(nKBKCOUNT).ZKPSUM_NO_REQUISITS, 0) + nvl(EXPARR(QKBK).ZKPSUM_NO_REQUISITS, 0);
                                TEMPKBK(nKBKCOUNT).INCSUM := nvl(TEMPKBK(nKBKCOUNT).INCSUM, 0) + nvl(EXPARR(QKBK).INCSUM, 0);
                            end if;
                        end if;
                    end loop;
                end if;
            end loop;

            sFOTYPE2  := '<td class="c1 first group2"><div class="c1">'||EXPARR(STARTARR).FOTYPENAME||'</div></td>';
    		sKBK      := '<td class="c2 first group2"><div class="c2"></div></td>';
    		sKVR      := '<td class="c3 first group2"><div class="c3"></div></td>';
    		sKOSGU    := '<td class="c4 first group2"><div class="c4"></div></td>';

    		sINCOME   := '<td class="c5 first group2"><div class="c5">'||LTRIM(to_char(nvl(nINCSUM, 0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    		sOUTCOME  := '<td class="c6 first group2"><div class="c6">'||LTRIM(to_char(nvl(nOUTSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    		sPAYSUM   := '<td class="c10 first group2"><div class="c10">'||LTRIM(to_char(nvl(nPAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    		sNOTPAID  := '<td class="c11 first group2"><div class="c11">'||LTRIM(to_char(nvl(nZKPSUM_REQUISITS,0) - nvl(nPAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    		sZKPREQ   := '<td class="c12 first group2"><div class="c12">'||LTRIM(to_char(nvl(nZKPSUM_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    		sZKPNOREQ := '<td class="c8 first group2"><div class="c8">'||LTRIM(to_char(nvl(nZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    		sREST     := '<td class="c9 first group2"><div class="c9">'||LTRIM(to_char(nvl(nOUTSUM,0)-nvl(nZKPSUM_REQUISITS,0)-nvl(nZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';

            htp.p('
                <tr>
                    '||sFOTYPE2||'
                    '||sKBK||'
                    '||sKVR||'
                    '||sKOSGU||'
                    '||sINCOME||'
                    '||sOUTCOME||'
                    '||sPAYSUM||'
                    '||sNOTPAID||'
                    '||sZKPREQ||'
                    '||sZKPNOREQ||'
                    '||sREST||'
                </tr>');

            for OUTKBK in TEMPKBK.FIRST..TEMPKBK.COUNT
            loop
                sFOTYPE2  := '<td class="c1 first group3"><div class="c1">'||EXPARR(STARTARR).FOTYPENAME||'</div></td>';
    			sKBK      := '<td class="c2 first group3"><div class="c2">'||ZF_GET_KBK(TEMPKBK(OUTKBK).KBKRN)||'</div></td>';
    			sKVR      := '<td class="c3 first group3"><div class="c3"></div></td>';
    			sKOSGU    := '<td class="c4 first group3"><div class="c4"></div></td>';

    			sINCOME   := '<td class="c5 first group3"><div class="c5">'||LTRIM(to_char(nvl(TEMPKBK(OUTKBK).INCSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    			sOUTCOME  := '<td class="c6 first group3"><div class="c6">'||LTRIM(to_char(nvl(TEMPKBK(OUTKBK).OUTSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    			sPAYSUM   := '<td class="c10 first group3"><div class="c10">'||LTRIM(to_char(nvl(TEMPKBK(OUTKBK).PAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    			sNOTPAID  := '<td class="c11 first group3"><div class="c11">'||LTRIM(to_char(nvl(TEMPKBK(OUTKBK).ZKPSUM_REQUISITS,0) - nvl(TEMPKBK(OUTKBK).PAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    			sZKPREQ   := '<td class="c12 first group3"><div class="c12">'||LTRIM(to_char(nvl(TEMPKBK(OUTKBK).ZKPSUM_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    			sZKPNOREQ := '<td class="c8 first group3"><div class="c8">'||LTRIM(to_char(nvl(TEMPKBK(OUTKBK).ZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    			sREST     := '<td class="c9 first group3"><div class="c9">'||LTRIM(to_char(nvl(TEMPKBK(OUTKBK).OUTSUM,0)-nvl(TEMPKBK(OUTKBK).ZKPSUM_REQUISITS,0)-nvl(TEMPKBK(OUTKBK).ZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';

                htp.p('
                    <tr>
                        '||sFOTYPE2||'
                        '||sKBK||'
                        '||sKVR||'
                        '||sKOSGU||'
                        '||sINCOME||'
                        '||sOUTCOME||'
                        '||sPAYSUM||'
                        '||sNOTPAID||'
                        '||sZKPREQ||'
                        '||sZKPNOREQ||'
                        '||sREST||'
                    </tr>');
                for OUTKVR in TEMPKVR.FIRST..TEMPKVR.COUNT
                loop
                    if TEMPKVR(OUTKVR).KBKRN = TEMPKBK(OUTKBK).KBKRN then
                        sFOTYPE2  := '<td class="c1 first group4"><div class="c1">'||EXPARR(STARTARR).FOTYPENAME||'</div></td>';
                        sKBK      := '<td class="c2 first group4"><div class="c2">'||ZF_GET_KBK(TEMPKBK(OUTKBK).KBKRN)||'</div></td>';
                        sKVR      := '<td class="c3 first group4"><div class="c3">'||TEMPKVR(OUTKVR).KVRCODE||'</div></td>';
                        sKOSGU    := '<td class="c4 first group4"><div class="c4"></div></td>';

                        sINCOME   := '<td class="c5 first group4"><div class="c5">-</div></td>';
                        sOUTCOME  := '<td class="c6 first group4"><div class="c6">'||LTRIM(to_char(nvl(TEMPKVR(OUTKVR).OUTSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
                        sPAYSUM   := '<td class="c10 first group4"><div class="c10">'||LTRIM(to_char(nvl(TEMPKVR(OUTKVR).PAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
                        sNOTPAID  := '<td class="c11 first group4"><div class="c11">'||LTRIM(to_char(nvl(TEMPKVR(OUTKVR).ZKPSUM_REQUISITS,0) - nvl(TEMPKVR(OUTKVR).PAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
                        sZKPREQ   := '<td class="c12 first group4"><div class="c12">'||LTRIM(to_char(nvl(TEMPKVR(OUTKVR).ZKPSUM_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
                        sZKPNOREQ := '<td class="c8 first group4"><div class="c8">'||LTRIM(to_char(nvl(TEMPKVR(OUTKVR).ZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
                        sREST     := '<td class="c9 first group4"><div class="c9">'||LTRIM(to_char(nvl(TEMPKVR(OUTKVR).OUTSUM,0)-nvl(TEMPKVR(OUTKVR).ZKPSUM_REQUISITS,0)-nvl(TEMPKVR(OUTKVR).ZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';

                        htp.p('
                            <tr>
                                '||sFOTYPE2||'
                                '||sKBK||'
                                '||sKVR||'
                                '||sKOSGU||'
                                '||sINCOME||'
                                '||sOUTCOME||'
                                '||sPAYSUM||'
                                '||sNOTPAID||'
                                '||sZKPREQ||'
                                '||sZKPNOREQ||'
                                '||sREST||'
                            </tr>');
                    end if;
                    for OUTKOSGU in TEMPKOSGU.FIRST..TEMPKOSGU.COUNT
                    loop
                        if TEMPKOSGU(OUTKOSGU).KVRRN = TEMPKVR(OUTKVR).KVRRN then
                            sFOTYPE2  := '<td class="c1"><div class="c1">'||EXPARR(STARTARR).FOTYPENAME||'</div></td>';
            				sKBK      := '<td class="c2"><div class="c2">'||ZF_GET_KBK(TEMPKBK(OUTKBK).KBKRN)||'</div></td>';
            				sKVR      := '<td class="c3"><div class="c3">'||TEMPKVR(OUTKVR).KVRCODE||'</div></td>';
            				sKOSGU    := '<td class="c4"><div class="c4"></div></td>';

            				sINCOME   := '<td class="c5"><div class="c5">-</div></td>';
            				sOUTCOME  := '<td class="c6"><div class="c6">'||LTRIM(to_char(nvl(TEMPKOSGU(OUTKOSGU).OUTSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
            				sPAYSUM   := '<td class="c10"><div class="c10">'||LTRIM(to_char(nvl(TEMPKOSGU(OUTKOSGU).PAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
            				sNOTPAID  := '<td class="c11"><div class="c11">'||LTRIM(to_char(nvl(TEMPKOSGU(OUTKOSGU).ZKPSUM_REQUISITS,0) - nvl(TEMPKOSGU(OUTKOSGU).PAYSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
            				sZKPREQ   := '<td class="c12"><div class="c12">'||LTRIM(to_char(nvl(TEMPKOSGU(OUTKOSGU).ZKPSUM_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
            				sZKPNOREQ := '<td class="c8"><div class="c8">'||LTRIM(to_char(nvl(TEMPKOSGU(OUTKOSGU).ZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
            				sREST     := '<td class="c9"><div class="c9">'||LTRIM(to_char(nvl(TEMPKOSGU(OUTKOSGU).OUTSUM,0)-nvl(TEMPKOSGU(OUTKOSGU).ZKPSUM_REQUISITS,0)-nvl(TEMPKOSGU(OUTKOSGU).ZKPSUM_NO_REQUISITS,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';

                            htp.p('
                                <tr>
                                    '||sFOTYPE2||'
                                    '||sKBK||'
                                    '||sKVR||'
                                    '||sKOSGU||'
                                    '||sINCOME||'
                                    '||sOUTCOME||'
                                    '||sPAYSUM||'
                                    '||sNOTPAID||'
                                    '||sZKPREQ||'
                                    '||sZKPNOREQ||'
                                    '||sREST||'
                                </tr>');
                        end if;
                    end loop;
                end loop;
            end loop;
        end if;
    end loop;
    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;'||1||'">'||1||' Всего записей: <b>'||1||'</b></li>');
    htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
    htp.p('<li style="float:left; " id="save_shtat"></li>');
    htp.p('<li style="clear:both"></li></ul>');
end;
