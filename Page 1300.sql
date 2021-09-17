--101; 1300;
declare
 pJURPERS      number        := :P1_JURPERS;
 pVERSION      number        := :P1_VERSION;

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
    ----------------------------------------------------

    ----------------------------------------------------

    apex_javascript.add_library (
    p_name                  => 'jquery.inputmask.bundle',
    p_directory             => '/i/');

    htp.p(
    '<style>
        ::-webkit-scrollbar {
          width: 17px;
        }

        /* Track */
        ::-webkit-scrollbar-track {
          -webkit-box-shadow: inset 0 0 12px rgba(0,0,0,0.3);
          -webkit-border-radius: 12px;
          border-radius: 12px;
        }

        /* Handle */
        ::-webkit-scrollbar-thumb {
          -webkit-border-radius: 10px;
          border-radius: 12px; border-left: 2px solid #eee; border-right: 2px solid #eee;
          background: #dbe8f8;
          -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.5);

        }
        ::-webkit-scrollbar-thumb:window-inactive {
          background: rgba(255,0,0,0.4);
        }
         .report_standard tbody tr:hover td {
             background-color: #dbe8f8 !important; color: #000;
                  cursor: pointer; font-weight:bolder;
            }
        .report_standard  thead > tr {width: 100%; }
        .report_standard  tbody > tr {width: 100%; display: block}
        .report_standard > tbody {
            display: block; height: 300px; overflow-x: hidden;  overflow-y: scroll;
          }

        .sub_td {padding:0;margin:0; border:none;}

        .sub_region {
          width:100%;
        }
        .sub_region  {

        }

        .report_standard thead {
          display: block; width:100%
        }
        .report_standard{
          border: 1px solid grey;
        }

        .report_standard th, td{
          text-align:left;
          vertical-align: middle;
        }
        .report_standard th{
          text-align:center;
          line-height: 1.5em;
          vertical-align: middle;
        }
        .report_standard th {
          color:#222;
          font: bold 12px "Helvetica Neue",Helvetica,Arial,sans-serif;
          text-shadow: 0 1px 0 rgba(255, 255, 255, 0.5);
          padding: 5px 4px;
           /* background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 50% #e1e1e1 repeat-x;*/
          background: #e0e0e0;
          border-bottom: 1px solid #9fa0a0;
          border-left:1px solid #9fa0a0;
        }
        .report_standard td{
          padding: 5px 4px;
          border-bottom: 1px solid #9fa0a0;
          border-left:1px solid #9fa0a0;
          background-color: #f2f2f2;
        }
        .textarea {resize: vertical;text-align:left !important; }
        .in_txtr {width:95%; border: 1px solid #ccc;text-align:right;}
        .in_txtl {width:95%; border: 1px solid #ccc;text-align:left;}
        .in_txt2 {width:70%; border: 1px solid #ccc;text-align:right;}
        .group {font-weight:bold; background-color:#d4d9f5 !important}
        '||case when not bUSER_MANAGER then '.show{display:none;}' end||'
		'||case when not bUSER_SUPPORT then '.show2{display:none;}' end||'

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}

        .th1{width: 30px;text-align:center; border-left: 0px !important}    .c1 {width: 30px; word-wrap: break-word; text-align:center; border-left: 0px !important}
		.th2{width: 100%;text-align:center;}   .c2 {width: 100%; word-wrap: break-word; text-align:left;}
		.th3{width: 100px;text-align:center;}   .c3 {width: 100px; word-wrap: break-word; text-align:right;}
        .th4{width: 100px;text-align:center;}   .c4 {width: 100px; word-wrap: break-word; text-align:right;}
        .th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:right;}
		.th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:right;}
		.th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:right;}
        .th6{width: 100px;text-align:center;}   .c6 {width: 100px; word-wrap: break-word; text-align:right;}
        .th7{width: 100px;text-align:center;}   .c7 {width: 100px; word-wrap: break-word; text-align:right;}
        .th8{width: 100px;text-align:center;}   .c8 {width: 100px; word-wrap: break-word; text-align:right;}
        .th9{width: 100px;text-align:center;}   .c9 {width: 100px; word-wrap: break-word; text-align:right;}
		.th10{width: 80px;text-align:center;}  .c10 {width: 80px; word-wrap: break-word; text-align:right;}
		.th11{width: 80px;text-align:center;}  .c11 {width: 80px; word-wrap: break-word; text-align:right;}
		.th12{width: 30px;text-align:center;}  .c12 {width: 30px; word-wrap: break-word; text-align:center;}

        .pagination {text-align: right;
          border-left: 1px solid grey;
          border-right: 1px solid grey;
          border-bottom: 1px solid grey;
          margin: 0px;

          padding: 5px;
          background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 100% #e1e1e1 repeat-x;cursor:move;
        }
        .pagination li {display: inline; margin-left:5px; font-size: 12px; padding: 2px; cursor:default; }
        .selected_row{padding: 4px 4px;
          border-bottom: 1px solid #9fa0a0;
          background-color: #FAFF82;
        }
    </style>');


    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1"  rowspan="2"><div class="th1">Тип</div></th>
		 <th class="header th2"  rowspan="2"><div class="th2">Учреждение</div></th>
		 <th colspan="3"><div>Затраты</div></th>
		 <th colspan="3"><div>Контингент</div></th>
		 <th class="header th9"  rowspan="2"><div class="th9">Расч.норматив на 1 обуч.</div></th>
		 <th class="header th10" rowspan="2"><div class="th10">Кол-во обуч. на 1 препод.</div></th>
		 <th class="header th11" rowspan="2"><div class="th11">Доля педаг.раб.%</div></th>
		 <th class="header th12" rowspan="2"><div class="th12">Инд</div></th>

         <th class="header" rowspan="2"><div style="width:8px"></div></th>
        </tr>

        <tr>
         <th class="header th3" ><div class="th3">Лимит</div></th>
		 <th class="header th4" ><div class="th4">План</div></th>
		 <th class="header th5" ><div class="th5">Расхождение</div></th>
		 <th class="header th6" ><div class="th6">Лимит</div></th>
		 <th class="header th7" ><div class="th7">План</div></th>
		 <th class="header th8" ><div class="th8">Расхождение</div></th>
        </tr>


      </thead>
    <tbody id="fullall" >');


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

		sORGNAME    := '<td class="c2"><div class="c2"><a href="f?p=101:56:'||v('APP_SESSION')||'::NO::P56_RN:'||rec.ORGRN||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">'||rec.ORGNAME||'</span></a></div></td>';

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
		  and S.SERVSIGN = SS.RN and ss.numb in (1,2) -- группы услуг (школа, детсад)
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


		sEXP_LIMIT    := '<td class="c3"><div class="c3">'||to_char(nPLANLIMSUM,'999G999G999G999G990D00')||'</div></td>';
		sEXP_PLAN     := '<td class="c4"><div class="c4">'||to_char(nPLANOUTSUM,'999G999G999G999G990D00')||'</div></td>';

		nEXP_DIFF		:= nvl(nPLANOUTSUM,0) - nvl(nPLANLIMSUM,0);
		if nEXP_DIFF != 0 then sCOLOR := 'red'; else sCOLOR := 'black'; end if;

		sEXP_DIFF     := '<td class="c5"><div class="c5" style="color:'||sCOLOR||'">'||to_char(nEXP_DIFF,'999G999G999G999G990D00')||'</div></td>';
		sIND_LIMIT    := '<td class="c6"><div class="c6">'||to_char(nIND_CACL,'999G999G999G999G990D00')||'</div></td>';
		sIND_PLAN     := '<td class="c7"><div class="c7">'||to_char(nIND_VAL,'999G999G999G999G990D00')||'</div></td>';

		nIND_DIFF		:= nvl(nIND_VAL,0) - nvl(nIND_CACL,0);
		if nIND_DIFF != 0 then sCOLOR := 'red'; else sCOLOR := 'black'; end if;

		sIND_DIFF     := '<td class="c8"><div class="c8" style="color:'||sCOLOR||'">'||to_char(nIND_DIFF,'999G999G999G999G990D00')||'</div></td>';
		sNORMAIV      := '<td class="c9"><div class="c9"><b>'||to_char(nNORMAIV,'999G999G999G999G990D00')||'</b></div></td>';
		sSTUDY     	  := '<td class="c10"><div class="c10">'||to_char(nPOST_FACT,'999G999G999G999G990D00')||'</div></td>';
		sTEACHER      := '<td class="c11"><div class="c11">'||to_char(nTEACHER,'999G999G999G999G990D00')||'</div></td>';

		if nvl(nPLANLIMSUM,0) > 0 then
			nEXP_DIFF_PERC	:= abs(nEXP_DIFF)/nPLANLIMSUM * 100;
		else
			nEXP_DIFF_PERC := -1;
		end if;

		if nIND_CACL > 0 then
			nIND_DIFF_PERC	:= abs(nIND_DIFF)/nIND_CACL * 100;
		else
			nIND_DIFF_PERC := -1;
		end if;


		if nIND_DIFF_PERC = -1 or nEXP_DIFF_PERC = -1 then
			sBALL := '<img src="/i/fndwarnb.gif" title="Данные не заполнены" style="width:16px;"/>';
		elsif nIND_DIFF_PERC <= 10 and nEXP_DIFF_PERC <= 10 then
			sBALL := '<img src="/i/green.png" title="Расхождение не превышает 10% по ЗАТРАТАМ (лимит) и КОНТИНГЕНТУ(лимит)" style="width:16px;"/>';
		elsif nIND_DIFF_PERC <= 20 and nEXP_DIFF_PERC <= 20 then
			sBALL := '<img src="/i/yellow.png" title="Расхождение от 10 до 20% по ЗАТРАТАМ (лимит) или Контингенту (лимит)" style="width:16px;"/>';
		else
			sBALL := '<img src="/i/red.png" title="Расхождение свыше 20% по ЗАТРАТАМ (лимит) или КОНТИНГЕНТУ(лимит)" style="width:16px;"/>';
		end if;


		sBALL    	  := '<td class="c12"><div class="c12">'||sBALL||'</div></td>';

		htp.p('
			<tr>
				'||sORGTYPE||'
				'||sORGNAME||'
				'||sEXP_LIMIT||'
				'||sEXP_PLAN||'
				'||sEXP_DIFF||'
				'||sIND_LIMIT||'
				'||sIND_PLAN||'
				'||sIND_DIFF||'
				'||sNORMAIV||'
				'||sSTUDY||'
				'||sTEACHER||'
				'||sBALL||'
			</tr>');
	END LOOP;


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
