--101; 1400; Анализ учреждений
declare
 pJURPERS      number        := :P1_JURPERS;
 pVERSION      number        := :P1_VERSION;
 pSORT         number        := :P1400_SORT;

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
 nFOT_KOEFF		number(19,2);
 sFOT_CALC		varchar2(4000);
 nFOT_CALC		number(19,2);

 nEXP_DIFF_PERC number(19,2);
 nIND_DIFF_PERC number(19,2);
 nPOST_COUNT	number(19,2);

 sCOLOR_FOT     varchar2(100);
 sSOLV_FOT  	varchar2(500);
 sSOLV_FOT1		varchar2(4000);


 sCOLOR			varchar2(100);
 sNORMAIV     	varchar2(4000);
 sSTUDY     	varchar2(4000);
 sTEACHER     	varchar2(4000);
 sBALL    		varchar2(4000);
 sSOLV    		varchar2(4000);
 sSOLV1    		varchar2(4000);
 sTEACHER_TITLE    	varchar2(4000);


 sNORMAIV1     	varchar2(4000);
 sFOT			varchar2(4000);
 nFOT_AVG		number(19,2);
 nFOT_PERC		number(19,2);


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

 nOKLAD_PAY		number(19,2);
 nCOMPENS_PAY	number(19,2);
 nSTIMUL_PAY	number(19,2);

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
   PLANSUM number,
   RESTSUM number
 );

 type TEXPGR  is table of CEXPGR index by pls_integer;
 REXPGR       TEXPGR;



begin
	if bUSER_SUPPORT then nUSER_SUPPORT := 1; end if;

    -- Инициализация
    ----------------------------------------------------

    ----------------------------------------------------

    apex_javascript.add_library (
    p_name                  => 'jquery.inputmask.bundle',
    p_directory             => '/i/');

--<th class="header th111" rowspan="2"><div class="th111">Средняя зп,%</div></th>

--<th class="header th111" rowspan="2"><div class="th111">Расчетный ФОТ, тыс.руб</div></th>
-- При onclick на заголовок меняется значения параметра pSORT (P1400_SORT), в зависимости от этого параметра происходит сортировка коллекции
    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1"  rowspan="2"><div class="th1">Тип</div></th>
         <th class="header th2"  rowspan="2"><div class="th2"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 1 then ''|| -1 ||'' when pSORT = -1 then ''|| 0 ||'' else ''|| 1 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Учреждение'
         ||case when pSORT = 1 then ' v' end || case when pSORT = -1 then ' ^' end||'</span></a></div></td>
		 <th colspan="3"><div>Затраты</div></th>
		 <th colspan="3"><div>Контингент</div></th>
         <th class="header th9"  rowspan="2"><div class="th9"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 8 then ''|| -8 ||'' when pSORT = -8 then ''|| 0 ||'' else ''|| 8 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Расч. норматив на 1 обуч.'
         ||case when pSORT = 8 then ' v' end || case when pSORT = -8 then ' ^' end||'</span></a></div></td>
         <th class="header th10"  rowspan="2"><div class="th10"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 9 then ''|| -9 ||'' when pSORT = -9 then ''|| 0 ||'' else ''|| 9 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Кол-во обуч. на 1 препод.'
         ||case when pSORT = 9 then ' v' end || case when pSORT = -9 then ' ^' end||'</span></a></div></td>
         <th class="header th11"  rowspan="2"><div class="th11"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 10 then ''|| -10 ||'' when pSORT = -10 then ''|| 0 ||'' else ''|| 10 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Доля педаг. работн.%'
         ||case when pSORT = 10 then ' v' end || case when pSORT = -10 then ' ^' end||'</span></a></div></td>
         <th class="header th111"  rowspan="2"><div class="th111"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 11 then ''|| -11 ||'' when pSORT = -11 then ''|| 0 ||'' else ''|| 11 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Средняя зп,%'
         ||case when pSORT = 11 then ' v' end || case when pSORT = -11 then ' ^' end||'</span></a></div></td>

		 <th class="header th12" rowspan="2"><div class="th12">Инд</div></th>
		 <th class="header th13" rowspan="2"><div class="th13">Решение</div></th>
         <th class="header" rowspan="2"><div style="width:8px"></div></th>

        </tr>

        <tr>
        <th class="header th3"><div class="th3"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 2 then ''|| -2 ||'' when pSORT = -2 then ''|| 0 ||'' else ''|| 2 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Лимит'
        ||case when pSORT = 2 then ' v' end || case when pSORT = -2 then ' ^' end||'</span></a></div></td>
        <th class="header th4"><div class="th4"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 3 then ''|| -3 ||'' when pSORT = -3 then ''|| 0 ||'' else ''|| 3 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">План'
        ||case when pSORT = 3 then ' v' end || case when pSORT = -3 then ' ^' end||'</span></a></div></td>
        <th class="header th5"><div class="th5"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 4 then ''|| -4 ||'' when pSORT = -4 then ''|| 0 ||'' else ''|| 4 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Расхождение'
        ||case when pSORT = 4 then ' v' end || case when pSORT = -4 then ' ^' end||'</span></a></div></td>
        <th class="header th6"><div class="th6"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 5 then ''|| -5 ||'' when pSORT = -5 then ''|| 0 ||'' else ''|| 5 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Лимит'
        ||case when pSORT = 5 then ' v' end || case when pSORT = -5 then ' ^' end||'</span></a></div></td>
        <th class="header th7"><div class="th7"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 6 then ''|| -6 ||'' when pSORT = -6 then ''|| 0 ||'' else ''|| 6 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">План'
        ||case when pSORT = 6 then ' v' end || case when pSORT = -6 then ' ^' end||'</span></a></div></td>
        <th class="header th8"><div class="th8"><a href="f?p=101:1400:'||v('APP_SESSION')||'::NO::P1400_SORT:'||case when pSORT = 7 then ''|| -7 ||'' when pSORT = -7 then ''|| 0 ||'' else ''|| 7 ||'' end||'"><span style="font-weight: bold; color:black" onclick="openLoader();">Расхожд'
        ||case when pSORT = 7 then ' v' end || case when pSORT = -7 then ' ^' end||'</span></a></div></td>
        </tr>

<!-- -->
      </thead>
    <tbody id="fullall" >');


    -- Инициализация
    --------------------------------------------
    for rec in
    (
    select EA.ORGRN, E.EXPKVR, E.KOSGURN, upper(trim(E.KOSGU)) DOPKOSGU, E.FOTYPE2, E.RN EXPMAT, SL.SERVKBK KBK_RN,
           sum(nvl(EA.SERVSUM,0) + nvl(EA.MSUM,0) ) PSUM,
		   sum(nvl(EA.RESTSUM,0)) RESTSUM
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
	union all
	select EA.ORGRN, E.EXPKVR, E.KOSGURN, upper(trim(E.KOSGU)) DOPKOSGU, E.FOTYPE2, E.RN EXPMAT, FK.KBK_RN,
           sum(nvl(EA.ESUM,0)) PSUM,
           sum(nvl(EA.RESTSUM,0)) RESTSUM
      from Z_EXPCOMMON EA, Z_EXPMAT E, Z_FUNDS_KBK FK
     where EA.EXPMAT  = E.RN
       and EA.JUR_PERS = pJURPERS
       and EA.VERSION  = pVERSION
	   and EA.VERSION = FK.VERSION
	   and EA.FUNDKBK = FK.RN
       and (nvl(EA.ESUM,0) > 0 or nvl(EA.RESTSUM,0) > 0 or
			nvl(EA.FSUM1, 0)> 0 or nvl(FSUM2,0)> 0 or
			nvl(FSUM3,0) > 0 or nvl(FSUM4,0) >0)
     group by EA.ORGRN, E.EXPKVR, E.KOSGURN, E.FOTYPE2, E.RN, FK.KBK_RN,	upper(trim(E.KOSGU))
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
		REXPGR(nITEMCOL).RESTSUM := rec.RESTSUM;
    END LOOP;

    -- создание коллекции
    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('DATANAL');

	-- ОСНОВНОЙ ЦИКЛ по учреждениям
	for rec in
	(
	 select O.A_ORGRN, O.RN ORGRN, substr(L.NAME,1,1) ORGTYPE, nvl(O.SHORT_NAME,O.CODE) ORGNAME, D.CODE DISTRICT, OK.CODE ORGKIND, FL.RN MAIN_FL, G.CODE sORGROUP, G.NUMB nORGROUP, O.MAIN_STAFF, O.FMAIN_STAFF, O.MAIN_STAFF_NORM, O.DNORMATIV,
          O.ADM_STAFF_NORM
	   from Z_ORGREG O, Z_LOV L, Z_DISTRICT D, Z_ORGKIND OK, Z_ORGFL FL,  Z_ORGROUP G
	  where O.ORGTYPE = L.NUM (+)
		and L.PART (+) = 'ORGTYPE'
		and O.ORGTYPE in (0,1)
		and (O.ORGTYPE  = :P1400_ORGTYPE or :P1400_ORGTYPE is null)
		and O.DISTRICT = D.RN(+)
		and O.ORGKIND = OK.RN (+)
	    and O.JUR_PERS = pJURPERS
	    and O.VERSION  = pVERSION
		and O.CLOSED_SIGN = 0
		and (O.FAKE_SIGN is null)
		and O.RN = FL.ORGRN and FL.CODE = 'ОСНОВНОЙ'
		and O.PRN = G.RN(+)
		and (O.PRN = :P1400_ORGROUP or :P1400_ORGROUP is null)
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
		  and (S.SERVSIGN = :P1400_SERVGROUP or :P1400_SERVGROUP is null)
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
		   and (C.RN = :P1400_CTRLGROUP or :P1400_CTRLGROUP is null)
           and C.ARC_SIGN is null;

		--	Затраты по группам контроля
		nPLANOUTSUM := 0;
		if  REXPGR.COUNT > 0 then
			for gr in
			(
			select CL.KVR, CL.KOSGU, CL.DOPKOSGU, CL.FOTYPE2, CL.EXPMAT, C.KBK_RN, CL.TYPESUM
			  from Z_CTRLGR C, Z_CTRLGR_DETAIL CL
			 where C.RN       = CL.PRN
			   and C.JUR_PERS = pJURPERS
			   and C.VERSION  = pVERSION
			   and C.ARC_SIGN is null
			   and (C.RN = :P1400_CTRLGROUP or :P1400_CTRLGROUP is null)
			 group by CL.KVR, CL.KOSGU, CL.DOPKOSGU, CL.FOTYPE2, CL.EXPMAT, C.KBK_RN, CL.TYPESUM
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
                       if gr.TYPESUM is null or gr.TYPESUM = 1 then nPLANOUTSUM := nvl(nPLANOUTSUM,0) + nvl(REXPGR(I).PLANSUM,0); end if;
                       if gr.TYPESUM is null or gr.TYPESUM = 2 then nPLANOUTSUM := nvl(nPLANOUTSUM,0) + nvl(REXPGR(I).RESTSUM,0);end if;
					end if;
				END LOOP;
			END LOOP;
		end if;

		sCOLOR := 'black';
		sSOLV  := '';
		-- POST_GROUP = ("указные") - UNUMB = 6 !!!!
		-- 349848958
		select sum(POST_FACT), count(*) into nPOST_FACT, nPOST_COUNT from x_fot where version = pVERSION and  ORGRN = rec.ORGRN and POST_GROUP in (select rn from X_JLOV where  part ='POST_GROUP' and UNUMB = 6 and version = pVERSION);

		-- Расчет средней зп
		--FOTYPE2  = 4   --субсидия ГЗ
		/*
		select avg(OKLAD_PAY), avg(COMPENS_PAY), avg(STIMUL_PAY) into nOKLAD_PAY, nCOMPENS_PAY, nSTIMUL_PAY from x_fot_detail where prn in	(select RN from x_fot where version = pVERSION and  ORGRN = rec.ORGRN and POST_GROUP in (select rn from X_JLOV where  part ='POST_GROUP' and UNUMB = 6 and version = pVERSION));
		*/

		select sum(OKLAD_PAY) + sum(COMPENS_PAY) + sum(STIMUL_PAY) into nFOT_AVG from x_fot_detail where prn in (select RN from x_fot where version = pVERSION and  ORGRN = rec.ORGRN and POST_GROUP in (select rn from X_JLOV where  part ='POST_GROUP' and UNUMB = 6 and version = pVERSION));

		--nFOT_AVG := nOKLAD_PAY + nCOMPENS_PAY + nSTIMUL_PAY;
		nFOT_AVG := nFOT_AVG /nPOST_COUNT;
		--nFOT_AVG := nFOT_AVG /rec.MAIN_STAFF_NORM;



		if nvl(rec.nORGROUP,0) = 1 then -- школы
			if rec.FMAIN_STAFF > 0 then
				if nvl(rec.DNORMATIV,0) != 0 then
					nFOT_KOEFF := rec.DNORMATIV;
				else
					nFOT_KOEFF := 1.5;
				end if;
				nFOT_PERC := nFOT_AVG*nFOT_KOEFF/rec.FMAIN_STAFF*100;
			else
				nFOT_PERC := 0;
			end if;
		elsif nvl(rec.nORGROUP,0) = 2 then -- детсады
			if rec.FMAIN_STAFF > 0 then
				if nvl(rec.DNORMATIV,0) != 0 then
					nFOT_KOEFF := rec.DNORMATIV;
				else
					nFOT_KOEFF := 1.2;
				end if;

				nFOT_PERC := nFOT_AVG*nFOT_KOEFF/rec.FMAIN_STAFF*100;
			else
				nFOT_PERC := 0;
			end if;
		end if;

		sCOLOR_FOT := 'black';
		sSOLV_FOT1 := '';
/*		if nFOT_PERC < 99 then sCOLOR_FOT := 'red'; sSOLV_FOT1 := '"Уровень СЗП ниже прошлого года. Требуется корректировка ФОТ"'; end if;
		--sSOLV_FOT := 'Средняя зп: '||nFOT_AVG||' Коэфф совм: '||nFOT_KOEFF||' по ДК: '||rec.FMAIN_STAFF;
		--(Коэфф совм: '||nFOT_KOEFF||')
		sSOLV_FOT := 'Уровень СЗП (текущий): '||nFOT_AVG*nFOT_KOEFF||';  Уровень СЗП (прошлый год): '||rec.FMAIN_STAFF||'; ССЧ (текущий): '|| rec.ADM_STAFF_NORM  ||'; ССЧ (прошлого года): '||rec.MAIN_STAFF_NORM;
*/
		--x_fot_detail


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

/*
		sEXP_LIMIT    := '<td class="c3"><div class="c3"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.ORGRN||');')||'">'||to_char(nPLANLIMSUM,'999G999G999G999G990D00')||'</a></div></td>';
		sEXP_PLAN     := '<td class="c4"><div class="c4"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.ORGRN||');')||'">'||to_char(nPLANOUTSUM,'999G999G999G999G990D00')||'</a></div></td>';
*/

		nEXP_DIFF		:= nvl(nPLANOUTSUM,0) - nvl(nPLANLIMSUM,0);
		if nEXP_DIFF = 0 then
			if ZF_ANALIZ_CHECKDIFF( rec.ORGRN,  pVERSION,  pJURPERS) then -- есть расхождения внутри
				sCOLOR := 'red';
			else
				sCOLOR := 'green';
			end if;
		else
			sCOLOR := 'red';
		end if;

		--if nEXP_DIFF != 0 then sCOLOR := 'red'; else sCOLOR := 'black'; end if;

/*
		sEXP_DIFF     := '<td class="c5"><div class="c5" style="color:'||sCOLOR||'"><b>'||to_char(nEXP_DIFF,'999G999G999G999G990D00')||'</b></div></td>';
		sIND_LIMIT    := '<td class="c6"><div class="c6"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nIND_CACL,'999G999G999G999G990D00')||'</a></div></td>';
		sIND_PLAN     := '<td class="c7"><div class="c7"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nIND_VAL,'999G999G999G999G990D00')||'</a></div></td>';
*/
		--<a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nSERVPLAN,sNFMT)||'</a>

		nIND_DIFF		:= nvl(nIND_VAL,0) - nvl(nIND_CACL,0);
		if nIND_DIFF != 0 then sCOLOR := 'red'; else sCOLOR := 'black'; end if;

		-- +++
		if nPOST_FACT > 0 then
			nPOST_FACT := nIND_VAL/nPOST_FACT;
		else
			nPOST_FACT := 0;
		end if;

/*
		sIND_DIFF     := '<td class="c8"><div class="c8" style="color:'||sCOLOR||'">'||to_char(nIND_DIFF,'999G999G999G999G990D00')||'</div></td>';
		sNORMAIV      := '<td class="c9"><div class="c9"><b>'||to_char(nNORMAIV,'999G999G999G999G990D00')||'</b></div></td>';
		sSTUDY     	  := '<td class="c10"><div class="c10">'||to_char(nPOST_FACT,'999G999G999G999G990D00')||'</div></td>';
*/


		-- !!! +++
		--if nTEACHER
		sCOLOR	:= 'black';
		sSOLV1	:= '';
		--MAIN_STAFF
		if nvl(rec.nORGROUP,0) = 1 then -- школы
			if nTEACHER < rec.MAIN_STAFF*0.97 then -- 3%
				sCOLOR 	:= 'red';
				sSOLV1	:= 'Низкая доля ФОТ пед. работников. Необходимо сократить расходы на прочий персонал.';
				sTEACHER_TITLE := 'Расчетное: '||nTEACHER||' по ДК: '||rec.MAIN_STAFF;

			end if;
		elsif nvl(rec.nORGROUP,0) = 2 then -- детсады
			if nTEACHER < rec.MAIN_STAFF*0.97 then
				sCOLOR	:= 'red';
				sSOLV1	:= 'Низкая доля ФОТ пед. работников. Необходимо сократить расходы на прочий персонал.';
				sTEACHER_TITLE := 'Расчетное: '||nTEACHER||' по ДК: '||rec.MAIN_STAFF;
			end if;
		elsif nvl(rec.nORGROUP,0) not in (1,2) then-- не определен
			sCOLOR	:= 'yellow';
			sSOLV1	:= 'Категория учреждения неопределена.';
		else
			sCOLOR	:= 'black';
			sSOLV1	:= '';
		end if;

/*
		sTEACHER      := '<td class="c11"><div class="c11" style="color:'||sCOLOR||'" title="'||sTEACHER_TITLE||'" >'||to_char(nTEACHER,'999G999G999G999G990D00')||'</div></td>';
		sFOT		:=  '<td class="c111"><div class="c111" style="color:'||sCOLOR_FOT||'" title="'||sSOLV_FOT||'" >'||to_char(nFOT_PERC,'999G999G999G999G990D00')||'</div></td>';
*/

		--
		nFOT_CALC	:= rec.FMAIN_STAFF * rec.MAIN_STAFF_NORM /1000;

		sFOT_CALC		:=  '<td class="c111"><div class="c111" >'||to_char(nFOT_CALC,'999G999G999G999G990D00')||'</div></td>';

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



		/*

6. Затраты и контингент выше более чем на 5%.
"Необходимо уточнение субвенции".

7. Затраты и контингент ниже более чем на 5%.
"Необходимо уточнение субвенции".

8. Контингент в организации менее 100 человек, норматив на 1 ребенка более 850 тыс. руб.
"Завышенные расходы организации. Необходимо рассмотреть возможность объединения в комплекс".

---- Новые
+1. Затраты (+-0,5%) и контингент равны.
«пустое поле».

+2. Затраты (+-0,5%) и контингент ниже плана.
«Уточнение субвенции (экономия)».

+3. Затраты (+-0,5%) и контингент выше плана.
«Уточнение субвенции (доп. потребность)».

+4. Контингент без изменений, затраты ниже на 0,5%.
«Средства доведены не в полном объеме (уточнить ситуацию)»

+5. Контингент без изменений, затраты выше на 0,5%.
«Средства доведены в большем объеме. Требуется уточнение ПФХД».
		*/

        if nFOT_PERC < 99 then sCOLOR_FOT := 'red'; sSOLV_FOT1 := '"Уровень СЗП ниже прошлого года. Требуется корректировка ФОТ"'; end if;
        sSOLV_FOT := 'Уровень СЗП (текущий): '||nFOT_AVG*nFOT_KOEFF||';  Уровень СЗП (прошлый год): '||rec.FMAIN_STAFF||'; ССЧ (текущий): '|| rec.ADM_STAFF_NORM  ||'; ССЧ (прошлого года): '||rec.MAIN_STAFF_NORM;

        sEXP_LIMIT    := '<td class="c3"><div class="c3"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.ORGRN||');')||'">'||to_char(nPLANLIMSUM,'999G999G999G999G990D00')||'</a></div></td>';
        sEXP_PLAN     := '<td class="c4"><div class="c4"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.ORGRN||');')||'">'||to_char(nPLANOUTSUM,'999G999G999G999G990D00')||'</a></div></td>';
        sEXP_DIFF     := '<td class="c5"><div class="c5" style="color:'||sCOLOR||'"><b>'||to_char(nEXP_DIFF,'999G999G999G999G990D00')||'</b></div></td>';

        sIND_LIMIT    := '<td class="c6"><div class="c6"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nIND_CACL,'999G999G999G999G990D00')||'</a></div></td>';
        sIND_PLAN     := '<td class="c7"><div class="c7"><a style="text-decoration: underline;font-weight:bold;color:blue;" href="'||APEX_UTIL.PREPARE_URL('javascript:modalWin1('||rec.ORGRN||');')||'">'||to_char(nIND_VAL,'999G999G999G999G990D00')||'</a></div></td>';
        sIND_DIFF     := '<td class="c8"><div class="c8" style="color:'||sCOLOR||'">'||to_char(nIND_DIFF,'999G999G999G999G990D00')||'</div></td>';

        sNORMAIV      := '<td class="c9"><div class="c9"><b>'||to_char(nNORMAIV,'999G999G999G999G990D00')||'</b></div></td>';
        sSTUDY     	  := '<td class="c10"><div class="c10">'||to_char(nPOST_FACT,'999G999G999G999G990D00')||'</div></td>';

		sTEACHER      := '<td class="c11"><div class="c11" style="color:'||sCOLOR||'" title="'||sTEACHER_TITLE||'" >'||to_char(nTEACHER,'999G999G999G999G990D00')||'</div></td>';
		sFOT		:=  '<td class="c111"><div class="c111" style="color:'||sCOLOR_FOT||'" title="'||sSOLV_FOT||'" >'||to_char(nFOT_PERC,'999G999G999G999G990D00')||'</div></td>';

		sBALL :='';
		sSOLV :=null;



		if nIND_DIFF_PERC is null or nEXP_DIFF_PERC is null then
			sSOLV	:= null;
			sBALL := '<img src="/i/fndwarnb.gif" title="Данные не заполнены" style="width:16px;"/>';
		elsif nIND_VAL <= 100 and nPLANOUTSUM > 850000 then  -- 8
			sSOLV	:= 'Завышенные расходы организации. Необходимо рассмотреть возможность объединения в комплекс';
			sBALL := '<img src="/i/yellow.png" title="Контингент в организации менее 100 человек, норматив на 1 ребенка более 850 тыс. руб."   style="width:16px;"/>';

		elsif abs(nIND_DIFF_PERC) = 0 and abs(nEXP_DIFF_PERC) < 0.5 then   -- 1
			sSOLV	:= '';
			sBALL := '<img src="/i/green.png" title="Затраты в пределах(+-0,5%) и контингент равны ." style="width:16px;"/>';

		elsif abs(nIND_DIFF_PERC) = 0 and nEXP_DIFF_PERC < -0.5 then -- 4
			sSOLV	:= '«Средства доведены не в полном объеме (уточнить ситуацию)»';
			sBALL := '<img src="/i/red.png"  title="Контингент без изменений, затраты ниже более чем на 0,5%." style="width:16px;"/>';

		elsif abs(nIND_DIFF_PERC) = 0 and nEXP_DIFF_PERC > 0.5 then --  5
			sSOLV	:= '«Средства доведены в большем объеме. Требуется уточнение ПФХД»';
			sBALL := '<img src="/i/red.png"  title="Контингент без изменений, затраты выше более чем на 0,5%." style="width:16px;"/>';

		elsif nIND_DIFF_PERC < 0 and abs(nEXP_DIFF_PERC) <= 0.5 then -- 2
			sSOLV	:= '«Уточнение субвенции (экономия)»';
			sBALL := '<img src="/i/yellow.png" title="Затраты в пределах (+-0,5%) , контингент ниже" style="width:16px;"/>';

		elsif nIND_DIFF_PERC > 0 and abs(nEXP_DIFF_PERC) <= 0.5 then  -- 3
			sSOLV	:= '«Уточнение субвенции (доп. потребность)»';
			sBALL := '<img src="/i/yellow.png" title="Затраты в пределах(+-0,5%), контингент выше." style="width:16px;"/>';

		elsif abs(nIND_DIFF_PERC) > 0 and abs(nEXP_DIFF_PERC) > 0.5 then  -- 6, 7
			sSOLV	:= 'Необходимо уточнение субвенции';
			sBALL := '<img src="/i/yellow.png" title="Затраты выше(или ниже) более чем на 0,5%, контингент не равен. " style="width:16px;"/>';
		end if;


		sBALL    	  := '<td class="c12"><div class="c12">'||sBALL||'</div></td>';


		if sSOLV is null then
			sSOLV := sSOLV1;
		else
			sSOLV := sSOLV||';'||sSOLV1;
		end if;

		if sSOLV is null then
			sSOLV := sSOLV_FOT1;
		else
			sSOLV := sSOLV||';'||sSOLV_FOT1;
		end if;

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
			p_c022            => sFOT,
			p_c023            => sFOT_CALC,
            p_n001            => nPLANLIMSUM,
            p_n002            => nPLANOUTSUM,
            p_n003            => nIND_CACL,
            p_n004            => nIND_VAL,
            p_n005            => nFOT_CALC
            );

	END LOOP;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for rec in
    (
        select c001, to_number(c002) as ORGRN, c003, to_number(c004) as POST_FACT, to_number(c005) as EXP_DIFF, to_number(c006) as IND_DIFF, to_number(c007) as NORMAIV, n001, n002, n003, n004, c008, c009, c010, c011, c012, c013, c014, c015, c016, c017, c018, c019, c020, to_number(c021) as TRACHER, c022, c023, n005
        from APEX_collections where collection_name = 'DATANAL'
        order by
        case when pSORT = 1  then c003     end asc,
        case when pSORT = -1 then c003     end desc,
        case when pSORT = 2  then n001     end asc,
        case when pSORT = -2 then n001     end desc,
        case when pSORT = 3  then n002     end asc,
        case when pSORT = -3 then n001     end desc,
        case when pSORT = 4  then EXP_DIFF end asc,
        case when pSORT = -4 then EXP_DIFF end desc,
        case when pSORT = 5  then n003     end asc,
        case when pSORT = -5 then n003     end desc,
        case when pSORT = 6  then n004     end asc,
        case when pSORT = -6 then n004     end desc,
        case when pSORT = 7  then IND_DIFF end asc,
        case when pSORT = -7 then IND_DIFF end desc,
        case when pSORT = 8  then NORMAIV  end asc,
        case when pSORT = -8 then NORMAIV  end desc,
        case when pSORT = 9  then POST_FACT  end asc,
        case when pSORT = -9 then POST_FACT  end desc,
        case when pSORT = 10  then TRACHER  end asc,
        case when pSORT = -10 then TRACHER  end desc,
        case when pSORT = 11  then n005  end asc,
        case when pSORT = -11 then n005  end desc,
        case when pSORT = 0 then c001 end
    )LOOP

        htp.p('
            <tr>
                '||rec.c008||'
                '||rec.c009||'
                '||rec.c010||'
                '||rec.c011||'
                '||rec.c012||'
                '||rec.c013||'
                '||rec.c014||'
                '||rec.c015||'
                '||rec.c016||'
                '||rec.c017||'
                '||rec.c018||'
				'||rec.c022||'
				'||''/*rec.c023*/||'
                '||rec.c019||'
                '||rec.c020||'
            </tr>');

    END LOOP;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;">Всего записей: <b>'||nCOUNTROWS||'</b></li>');
    htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
    htp.p('<li style="float:left; " id="save_shtat"></li>');
    htp.p('<li style="clear:both"></li></ul>');
    htp.p(
    '<script>

        $(function(){
          table_body=$("#fullall");


          if (window.screen.height<=1024) {
          table_body.height("260px");
          $(".report_standard").css("width","100%");
          } else {
          table_body.height("700px");
          $(".report_standard").css("width","100%");
          }
            $(".pagination").mousedown(startDrag);


            function startDrag(e){
                staticOffset = table_body.height() - e.pageY;
                table_body.css("opacity", 0.25);
                $(document).mousemove(performDrag).mouseup(endDrag);
                return false;
              }

              function performDrag(e){
                table_body.height(Math.max(150, staticOffset + e.pageY) + "px");
                return false;
              }

              function endDrag(e){
                $(document).unbind("mousemove", performDrag).unbind("mouseup", endDrag);
                table_body.css("opacity", 1);
              }
        });



           $(document).ready(function() {
        $(".myCell").on("mouseover", function() {
            $(this).closest("td").addClass("highlight");
            $(this).closest("th").addClass("highlight");
            $(this).closest("table").find(".myCell:nth-child(" + ($(this).index() + 1) + ")").addClass("highlight");
        });
        $(".myCell").on("mouseout", function() {
            $(this).closest("td").removeClass("highlight");
            $(this).closest("th").removeClass("highlight");
            $(this).closest("table").find(".myCell:nth-child(" + ($(this).index() + 1) + ")").removeClass("highlight");
        });
        });

		function selecter(obj,rownum)
		{
		$("#fix").find("tr").removeClass("selected");
		$("#fix").find("tr[row="+rownum+"]").addClass("selected");
		$("#fix tr").removeClass("selected");
		$(obj).parent("div").parent("td").parent("tr").addClass("selected");
		}
    </script>');
end;
