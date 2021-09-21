--101; 1300;
declare
 pJURPERS      number        := :P1_JURPERS;
 pVERSION      number        := :P1_VERSION;
 pSORT         number        := :P1300_SORT;

 pUSER         varchar2(100) := :APP_USER;
 pROLE         number        := ZGET_ROLE;
 bUSER_SUPPORT boolean       := ZF_USER_SUPPORT (pUSER);
 nUSER_SUPPORT number(1)	 := 0;
 bUSER_MANAGER boolean       := :APP_USER = 'MANAGER';

 -----------------------------------------------
 sORGTYPE      varchar2(4000);
 sORGNAME      varchar2(4000);
 sDISTRICT     varchar2(4000);
 sORGKIND      varchar2(4000);
 --
 sEXP_LIMIT     varchar2(4000);
 sEXP_PLAN     	varchar2(4000);
 sEXP_DIFF     	varchar2(4000);
 nEXP_DIFF		number(19,2);
 sIND_LIMIT     varchar2(4000);
 sIND_PLAN     	varchar2(4000);
 sIND_DIFF     	varchar2(4000);
 nIND_DIFF		number(19,2);

 nEXP_DIFF_PERC number(19,2);
 nIND_DIFF_PERC number(19,2);

 sCOLOR			varchar2(100);
 sNORMAIV     	varchar2(4000);
 sSTUDY     	varchar2(4000);
 sTEACHER     	varchar2(4000);
 sBALL    		varchar2(4000);
 sSOLV    		varchar2(4000);
 sNORMAIV1     	varchar2(4000);


 nIND_VAL		number(19,2);
 nIND_CACL		number(19,2);

 nPLANLIMSUM	number(19,2);
 nPLANSUM		number(19,2);
 nPLANOUTSUM    number(19,2);
 nPOST_FACT		number(19,2);
 nNORMAIV		number(19,2);
 --
 nFOTALL		number(19,2);
 nFOT1			number(19,2);
 nTEACHER		number(19,2);
 -----------------------------------------------
 nCOUNTROWS    number;
 NITEMCOL	   number;
 sNEW_ORGGROUP varchar2(300) := ' ';
 dLAST_LOGIN	date;
 SLAST_LOGIN   varchar2(300);
 nUSER_ACTIVE	number;
 sUSER_ACTIVE	varchar2(300);
--
 type CEXPGR is record
 (
   ORGRN   number,
   KVR     number,
   KOSGU   number,
   DOPKOSGU varchar2(20),
   FOTYPE2 number,
   EXPMAT  number,
   KBK_RN  number,
   PLANSUM number
 );

 type TEXPGR  is table of CEXPGR index by pls_integer;
 REXPGR       TEXPGR;



begin
	if bUSER_SUPPORT then nUSER_SUPPORT := 1; end if;

    -- Инициализация
    --------------------------------------------
    for rec in
    (
    select EA.ORGRN, E.EXPKVR, E.KOSGURN, upper(trim(E.KOSGU)) DOPKOSGU, E.FOTYPE2, E.RN EXPMAT, SL.SERVKBK KBK_RN,
           sum(nvl(EA.SERVSUM,0) + nvl(EA.MSUM,0) ) PSUM
      from Z_EXPALL EA, Z_EXPMAT E, Z_SERVLINKS SL
     where EA.EXP_ARTICLE  = E.RN
       and EA.JUR_PERS = pJURPERS
       and EA.VERSION  = pVERSION
	   and SL.VERSION = EA.VERSION
	   and SL.ORGRN = EA.ORGRN
	   and SL.SERVRN = EA.SERVRN
       and SL.FICTIV_SERV is null  -- !!! +++
       and (nvl(EA.SERVSUM,0) > 0 or nvl(EA.MSUM,0) > 0)
     group by EA.ORGRN, E.EXPKVR, E.KOSGURN, E.FOTYPE2, E.RN, SL.SERVKBK, upper(trim(E.KOSGU))
    )LOOP
        nITEMCOL := nvl(nITEMCOL,0) + 1;
		REXPGR(nITEMCOL).ORGRN    := rec.ORGRN;
        REXPGR(nITEMCOL).KVR      := rec.EXPKVR;
        REXPGR(nITEMCOL).KOSGU    := rec.KOSGURN;
		REXPGR(nITEMCOL).DOPKOSGU := rec.DOPKOSGU;
        REXPGR(nITEMCOL).FOTYPE2 := rec.FOTYPE2;
        REXPGR(nITEMCOL).EXPMAT  := rec.EXPMAT;
		REXPGR(nITEMCOL).KBK_RN  := rec.KBK_RN;
        REXPGR(nITEMCOL).PLANSUM := rec.PSUM;
    END LOOP;

    -- создание коллекции
    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('DATANAL');

	-- ОСНОВНОЙ ЦИКЛ по учреждениям
	for rec in
	(
	 select O.A_ORGRN, O.RN ORGRN, substr(L.NAME,1,1) ORGTYPE, nvl(O.SHORT_NAME,O.CODE) ORGNAME, D.CODE DISTRICT, OK.CODE ORGKIND, FL.RN MAIN_FL, G.CODE ORGROUP
	   from Z_ORGREG O, Z_LOV L, Z_DISTRICT D, Z_ORGKIND OK, Z_ORGFL FL,  Z_ORGROUP G
	  where O.ORGTYPE = L.NUM (+)
		and L.PART (+) = 'ORGTYPE'
		and O.ORGTYPE in (0,1)
		and (O.ORGTYPE  = :P1300_ORGTYPE or :P1300_ORGTYPE is null)
		and O.DISTRICT = D.RN(+)
		and O.ORGKIND = OK.RN (+)
	    and O.JUR_PERS = pJURPERS
	    and O.VERSION  = pVERSION
		and O.CLOSED_SIGN = 0
		and (O.FAKE_SIGN is null)
		and O.RN = FL.ORGRN and FL.CODE = 'ОСНОВНОЙ'
		and O.PRN = G.RN(+)
		and (O.PRN = :P1300_ORGROUP or :P1300_ORGROUP is null)
		--and nvl(O.PRN, 0) = nvl(:P2_ORGROUP, nvl(O.PRN, 0))
		--and O.ORGTYPE = nvl(:P2_ORGTYPE, O.ORGTYPE)
		--and nvl(O.ORGKIND, 0) = nvl(:P2_ORGKIND, nvl(O.ORGKIND, 0))
		--and ((Upper(O.OMS_CODE) like '%'||Upper(:P2_SEARCH)||'%') or (Upper(O.SHORT_NAME) like '%'||Upper(:P2_SEARCH)||'%') or (Upper(O.INN) like '%'||Upper(:P2_SEARCH)||'%') or (Upper(O.NAME) like '%'||Upper(:P2_SEARCH)||'%') or (Upper(O.NUMB) like '%'||Upper(:P2_SEARCH)||'%') or (Upper(O.CODE) like '%'||Upper(:P2_SEARCH)||'%') or (Upper(O.AGRNUMB) like '%'||Upper(:P2_SEARCH)||'%') or (Upper(O.EXTERNALID) like '%'||Upper(:P2_SEARCH)||'%'))

	  order by  O.ORDERNUMB, nvl(O.SHORT_NAME,O.CODE)
	)LOOP


		nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

		sORGTYPE    := '<td class="c1"><div class="c1"><span style="font-weight: bold; white-space: nowrap;color:#800000; padding-left: 5px;">'||rec.ORGTYPE||'</span></div></td>';

		sORGNAME    := '<td class="c2"><div class="c2">'||rec.ORGNAME||'</div></td>';

	-- Показатели объема
		select sum(iv.YPLAN3), sum(iv.YPLAN3_CALC) into nIND_VAL, nIND_CACL
		from z_servlinks sl,
			 z_qindvals iv,
			 Z_QINDLIST QL,
			 Z_SERVREG S,
			 Z_SERVSIGN SS,
			 Z_SERVIND SI
		where sl.orgrn = rec.ORGRN
		  and sl.servrn = s.rn
		  and iv.prn = sl.rn
		  and iv.qind = ql.rn
		  and S.SERVSIGN = SS.RN and ss.numb in (1,2) -- !!!группы услуг (школа, детсад)
		  and (S.SERVSIGN = :P1300_SERVGROUP or :P1300_SERVGROUP is null)
		  --and ql.numb = '001'
		  --
		  and SI.QIND = QL.RN and SI.PRN = S.RN
		  and QL.QINDSIGN = 2;

	-- Лимиты по группам контроля

		select sum(CL.PSUM)
		 into nPLANLIMSUM
		  from Z_CTRLGR C, Z_CTRLGR_LIMITS CL
		 where C.RN = CL.PRN
           and C.JUR_PERS = pJURPERS
		   and C.VERSION  = pVERSION
		   and CL.ORGRN   = rec.ORGRN
		   and (C.RN = :P1300_CTRLGROUP or :P1300_CTRLGROUP is null)
           and C.ARC_SIGN is null;

		--	Затраты по группам контроля
		nPLANOUTSUM := 0;
		if  REXPGR.COUNT > 0 then
			for gr in
			(
			select CL.KVR, CL.KOSGU, CL.DOPKOSGU, CL.FOTYPE2, CL.EXPMAT, C.KBK_RN
			  from Z_CTRLGR C, Z_CTRLGR_DETAIL CL
			 where C.RN       = CL.PRN
			   and C.JUR_PERS = pJURPERS
			   and C.VERSION  = pVERSION
			   and C.ARC_SIGN is null
			   and (C.RN = :P1300_CTRLGROUP or :P1300_CTRLGROUP is null)
			 group by CL.KVR, CL.KOSGU, CL.DOPKOSGU, CL.FOTYPE2, CL.EXPMAT, C.KBK_RN
			)LOOP
				for I in REXPGR.first..REXPGR.last
				LOOP
					if (
					   ((REXPGR(I).KVR = gr.KVR and gr.KVR is not null) or (gr.KVR is null))
					   and ((REXPGR(I).KOSGU = gr.KOSGU and gr.KOSGU is not null) or (gr.KOSGU is null))
					   and ((REXPGR(I).DOPKOSGU = gr.DOPKOSGU and gr.DOPKOSGU is not null) or (gr.DOPKOSGU is null))
					   and ((REXPGR(I).FOTYPE2 = gr.FOTYPE2 and gr.FOTYPE2 is not null) or (gr.FOTYPE2 is null))
					   and ((REXPGR(I).EXPMAT = gr.EXPMAT and gr.EXPMAT is not null) or (gr.EXPMAT is null))
					   and ((REXPGR(I).KBK_RN = gr.KBK_RN and gr.KBK_RN is not null and REXPGR(I).KBK_RN is not null) or (gr.KBK_RN is null))
					   and (REXPGR(I).ORGRN = rec.ORGRN )
				   ) then
						nPLANOUTSUM := nvl(nPLANOUTSUM,0) + nvl(REXPGR(I).PLANSUM,0);
					end if;
				END LOOP;
			END LOOP;
		end if;

		-- POST_GROUP = ("указные") - UNUMB = 6 !!!!
		-- 349848958
		select sum(POST_FACT) into nPOST_FACT from x_fot where version = pVERSION and  ORGRN = rec.ORGRN and POST_GROUP in (select rn from X_JLOV where  part ='POST_GROUP' and UNUMB = 6 and version = pVERSION);

		if nIND_VAL > 0 then
			nNORMAIV := nPLANOUTSUM / nIND_VAL;
		else
			nNORMAIV := 0;
		end if;

		-- расчет суммм по группам затат ОТ1 и ОТ2
		select sum(e.SERVSUM) into nFOTALL from z_expall e, z_expmat m, Z_EXPGROUP g  where e.ORGRN = rec.ORGRN and e.EXP_ARTICLE = m.RN and m.EXPGROUP = g.RN and g.code in ('ОТ1','ОТ2');
		select sum(e.SERVSUM) into nFOT1 from z_expall e, z_expmat m, Z_EXPGROUP g  where e.ORGRN = rec.ORGRN and e.EXP_ARTICLE = m.RN and m.EXPGROUP = g.RN and g.code = 'ОТ1';

		if nFOTALL > 0 then
			nTEACHER := nFOT1 / nFOTALL * 100;
		else
			nTEACHER := 0;
		end if;


		sEXP_LIMIT    := '<td class="c3"><div class="c3"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.ORGRN||');')||'">'||to_char(nPLANLIMSUM,'999G999G999G999G990D00')||'</a></div></td>';
		sEXP_PLAN     := '<td class="c4"><div class="c4"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.ORGRN||');')||'">'||to_char(nPLANOUTSUM,'999G999G999G999G990D00')||'</a></div></td>';

		nEXP_DIFF		:= nvl(nPLANOUTSUM,0) - nvl(nPLANLIMSUM,0);
		if nEXP_DIFF != 0 then sCOLOR := 'red'; else sCOLOR := 'black'; end if;

		sEXP_DIFF     := '<td class="c5"><div class="c5" style="color:'||sCOLOR||'">'||to_char(nEXP_DIFF,'999G999G999G999G990D00')||'</div></td>';
		sIND_LIMIT    := '<td class="c6"><div class="c6"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nIND_CACL,'999G999G999G999G990D00')||'</a></div></td>';
		sIND_PLAN     := '<td class="c7"><div class="c7"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nIND_VAL,'999G999G999G999G990D00')||'</a></div></td>';

		--<a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nSERVPLAN,sNFMT)||'</a>

		nIND_DIFF		:= nvl(nIND_VAL,0) - nvl(nIND_CACL,0);
		if nIND_DIFF != 0 then sCOLOR := 'red'; else sCOLOR := 'black'; end if;

		-- +++
		if nPOST_FACT > 0 then
			nPOST_FACT := nIND_VAL/nPOST_FACT;
		else
			nPOST_FACT := 0;
		end if;

		sIND_DIFF     := '<td class="c8"><div class="c8" style="color:'||sCOLOR||'">'||to_char(nIND_DIFF,'999G999G999G999G990D00')||'</div></td>';
		sNORMAIV      := '<td class="c9"><div class="c9"><b>'||to_char(nNORMAIV,'999G999G999G999G990D00')||'</b></div></td>';
		sSTUDY     	  := '<td class="c10"><div class="c10">'||to_char(nPOST_FACT,'999G999G999G999G990D00')||'</div></td>';
		sTEACHER      := '<td class="c11"><div class="c11">'||to_char(nTEACHER,'999G999G999G999G990D00')||'</div></td>';

		if nvl(nPLANLIMSUM,0) > 0 then
			nEXP_DIFF_PERC	:= nEXP_DIFF/nPLANLIMSUM * 100;
		else
			nEXP_DIFF_PERC := null;
		end if;

		if nIND_CACL > 0 then
			nIND_DIFF_PERC	:= nIND_DIFF/nIND_CACL * 100;
		else
			nIND_DIFF_PERC := null;
		end if;

		if nIND_DIFF_PERC is null or nEXP_DIFF_PERC is null then
			sSOLV	:= '';
			sBALL := '<img src="/i/fndwarnb.gif" title="Данные не заполнены" style="width:16px;"/>';
		elsif abs(nIND_DIFF_PERC) <= 5 and abs(nEXP_DIFF_PERC) <= 5 then
			sSOLV	:= 'Решений не требуется';
			sBALL := '<img src="/i/green.png" style="width:16px;"/>';
		elsif abs(nIND_DIFF_PERC) <= 5 and abs(nEXP_DIFF_PERC) > 5 then
			sSOLV	:= 'Необходимо уточнение субвенции';
			sBALL := '<img src="/i/yellow.png"  style="width:16px;"/>';

		elsif nIND_DIFF_PERC < -5 and abs(nEXP_DIFF_PERC) <= 5 then
			sSOLV	:= 'Средства доведены не в полном объеме. Необходимо связаться с адм. мун.обр.';
			sBALL := '<img src="/i/red.png" style="width:16px;"/>';
		elsif nIND_DIFF_PERC > 5 and abs(nEXP_DIFF_PERC) <= 5 then
			sSOLV	:= 'Средства доведены до организации в объеме, превыш. субвенцию. Необходима корр-ка ПФХД.';
			sBALL := '<img src="/i/red.png" style="width:16px;"/>';
		elsif abs(nIND_DIFF_PERC) > 5 and abs(nEXP_DIFF_PERC) > 5 then
			sSOLV	:= 'Необходимо уточнение субвенции';
			sBALL := '<img src="/i/yellow.png" style="width:16px;"/>';
		end if;

		sBALL    	  := '<td class="c12"><div class="c12">'||sBALL||'</div></td>';
		sSOLV		  := '<td class="c13"><div class="c13">'||sSOLV||'</div></td>';

        -- Заполнение коллекции
        APEX_COLLECTION.ADD_MEMBER(
            p_collection_name => 'DATANAL',
            p_c001            => rec.ORGTYPE,
            p_c002            => to_char(rec.ORGRN),
            p_c003            => rec.ORGNAME,
            p_c004            => to_char(nPOST_FACT),
            p_c005            => to_char(nEXP_DIFF),
            p_c006            => to_char(nIND_DIFF),
            p_c007            => to_char(nNORMAIV),
            p_c008            => sORGTYPE,
            p_c009            => sORGNAME,
            p_c010            => sEXP_LIMIT,
            p_c011            => sEXP_PLAN,
            p_c012            => sEXP_DIFF,
            p_c013            => sIND_LIMIT,
            p_c014            => sIND_PLAN,
            p_c015            => sIND_DIFF,
            p_c016            => sNORMAIV,
            p_c017            => sSTUDY,
            p_c018            => sTEACHER,
            p_c019            => sBALL,
            p_c020            => sSOLV,
            p_c021            => to_char(nTEACHER),
            p_n001            => nPLANLIMSUM,
            p_n002            => nPLANOUTSUM,
            p_n003            => nIND_CACL,
            p_n004            => nIND_VAL);

	END LOOP;

end;
