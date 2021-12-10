--101; 477; Z_ORG_BUDGDETAIL
declare
 pJURPERS      number        := :P1_JURPERS;
 pVERSION      number        := :P1_VERSION;
 pORGRN	       number        := nvl(:P1_ORGRN,:P7_ORGFILTER);
 pORGFL        number        := nvl(:P1_ORGFL,:P0_FILIAL);

 pUSER         varchar2(100) := :APP_USER;
 pEXPDIRTYPE   number        := :P477_EXPDIRTYPE;
 pPERIOD       number        := nvl(:P477_PERIOD,3);
 pKBK          number        := nvl(:P477_KBK, 0);
 pROLE         number        := ZGET_ROLE;
 pFILSIGN      number        := ZF_CHECK_FILIAL_SIGN (:P1_VERSION);
 -----------------------------------------------
 sSUMMA        varchar2(4000);
 sSUMMA_FACT   varchar2(4000);
 sEXCEPTSIGN   varchar2(4000);
 sREADSIGN     varchar2(4000);
 sDELROW       varchar2(4000);
 sCODE         varchar2(4000);
 sINCOMECODE   varchar2(4000);
 sKOSGUCODE    varchar2(4000);
 sKBKSCODE     varchar2(4000);
 sFUNDCODE     varchar2(4000);
 sNAME         varchar2(4000);
 -----------------------------------------------
 sSTRSAVEBTN   varchar2(4000);
 sSTRBACK      varchar2(4000);
 sSTRNAMESTR   varchar2(4000);
 sADDEXP       varchar2(4000);
 sPERIOD       varchar2(4000);
 sADDROW	   varchar2(4000);
 sKBK          varchar2(4000);
 -----------------------------------------------
 sBTN          varchar2(4000);
 nHISTCOUNT    number;
 nCOUNTROWS    number;
 nREDACTIONS   number;
 nREDSTATUS    number;
 nREDEXSTATUS  number;
 nPARTSTATUS   number;
 nGENPARTSTATUS number;
 sDISABLEDTEXT varchar2(100) := '';
 sADMINSIGN	   varchar2(100) := '';
 sDISABLEDSUM  varchar2(100) := '';
 sDISABLEDFACT varchar2(100) := '';
 nTOTAL        number;
 nREADONLY_FL  number;
 nTOTAL_FACT   number;
 nGORIZONT     Z_VERSIONS.GORIZONT%type;
 sPERNAME      varchar2(100);
 nNEXTPERIOD   Z_VERSIONS.NEXT_PERIOD%type;
 -----------------------------------------------
 nGENOCUNT     number;
begin

    if pORGRN is null then
        zp_exception(0,'Учреждение не выбрано. Выберите или закрепите учреждение.');
    end if;

    -- Права доступа
    ----------------------------------------------------
    select COUNT(*) into nGENOCUNT from Z_USERS where LOGIN = pUSER and nvl(CHEF_DEP_SIGN,0) = 1;

	if pEXPDIRTYPE != 12 then
		nREDSTATUS := ZF_GET_PFHDVERS_STATUS_LAST (pVERSION, pORGRN);
		nREDEXSTATUS := 0;
	elsif pEXPDIRTYPE = 12 then
		nREDSTATUS   := ZF_GET_REDACTION_STATUS_LAST (pVERSION, pORGRN, 'SMETA');
		nREDEXSTATUS := ZF_GET_REDACTION_STATUS_LAST (pVERSION, pORGRN, 'SMETAEXE');
	end if;

	begin
        select nvl(J.REDACTIONS, V.REDACTIONS)
          into nREDACTIONS
          from Z_JURPERS J, Z_VERSIONS V
         where V.JUR_PERS = J.RN
           and V.RN       = pVERSION;
    exception when others then
        nREDACTIONS := null;
    end;

    begin
		select NEXT_PERIOD
		  into nNEXTPERIOD
		  from Z_VERSIONS
		 where RN = pVERSION;
	exception when others then
		nNEXTPERIOD := null;
	end;

	-- 0 - OK, !=0 - возвращает текущий статус, 9 - закрыт филиал, "-1" - не найден статус раздела
	nPARTSTATUS := ZF_GET_PART_CHECK_MODIFY2(pJURPERS, pVERSION, pORGRN, case pEXPDIRTYPE when 5 then 'INCOME_PO1'
                                                                                   when 0 then 'INCOME_GZ4'
                                                                                   when 4 then 'INCOME_IC5'
                                                                                   when 11 then 'INCOME_CAP6'
                                                                                   when 12 then 'INCOME_BS10' end, null, :P1_ORGFL);


	nGENPARTSTATUS := ZF_GET_PART_STATUS(pJURPERS, pVERSION, pORGRN, case pEXPDIRTYPE when 5 then 'INCOME_PO1'
                                                                                   when 0 then 'INCOME_GZ4'
                                                                                   when 4 then 'INCOME_IC5'
                                                                                   when 11 then 'INCOME_CAP6'
                                                                                   when 12 then 'INCOME_BS10' end, null);

    --htp.p(nREDSTATUS || '-' || nREDACTIONS || '-'|| nREDEXSTATUS ||'-' || nPARTSTATUS ||'-'|| nGENPARTSTATUS);
	--htp.p('>>'||nREDSTATUS||'#'||nREDEXSTATUS||'#'||nPARTSTATUS);
    if (
            ((nREDSTATUS in (0,3) or nvl(nREDACTIONS, 0) = 0 ))
        and ((nREDEXSTATUS in (0,3) or nvl(nREDACTIONS, 0) = 0))
        and (nPARTSTATUS = 0)
        --and (nvl(nREDACTIONS, 0) = 1 or nGENPARTSTATUS in (1, 3, 4) and ZGET_ROLE in (0, 1))

      ) then
        sDISABLEDTEXT    := '';
        sDISABLEDSUM     := '';
    else
        sDISABLEDTEXT    := 'disabled';
        sDISABLEDSUM     := 'disabled';
    end if;

	if nvl(nREDACTIONS, 0) = 1 then
		sDISABLEDSUM := 'disabled';
	end if;

	if ((ZGET_ROLE in (0,1)) or ZF_USER_SUPPORT(v('APP_USER'))) and (nPARTSTATUS = 0) then
		sADMINSIGN := '';
	else
		sADMINSIGN := 'disabled';
	end if;



    begin
        select GORIZONT
          into nGORIZONT
          from Z_VERSIONS
         where RN = pVERSION;
    exception when others then
        null;
    end;

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
        '||case nNEXTPERIOD when 2020 then '.show{display:none;}' end||'

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}

        .th1{width: 95px;text-align:center; border-left: 0px !important}    .c1 {width: 95px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 65px;text-align:center;}    .c2 {width: 65px; word-wrap: break-word; text-align:center;}
		.th2_1{width: 70px;text-align:center;}    .c2_1 {width: 70px; word-wrap: break-word; text-align:center;}
		.th3{width: 160px;text-align:center;}   .c3 {width: 160px; word-wrap: break-word; text-align:center;}
		.th4{width: 100px;text-align:center;}   .c4 {width: 100px; word-wrap: break-word; text-align:center;}
        .th5{width: 100%;text-align:center;}    .c5 {width: 100%; word-wrap: break-word; text-align:left;}
        .th6{width: 200px;text-align:center;}   .c6 {width: 200px; word-wrap: break-word; text-align:right;}
        .th7{width: 120px;text-align:center;}   .c7 {width: 120px; word-wrap: break-word; text-align:right;}
        .th8{width: 40px;text-align:center;}    .c8 {width: 40px; word-wrap: break-word; text-align:center;}
        .th9{width: 40px;text-align:center;}    .c9 {width: 40px; word-wrap: break-word; text-align:center;}
        .th10{width: 20px;text-align:center;}   .c10 {width: 20px; word-wrap: break-word; text-align:center;}

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

    sPERIOD := '<select onchange="apex.submit({request:this.value,set:{''P477_PERIOD'':this.value}});" style="float:right; margin-right:5px">';

  	for rec in
      (select NAME, NUM
         from Z_LOV
        where part = 'VERS_YEAR'
          and ((nGORIZONT = 1 and NUM in (3,4,5,6)) or (nGORIZONT = 2))
        order by NUM)
  	loop
  		sPERIOD := sPERIOD||'<option value="'||rec.NUM||'" '||case when pPERIOD = rec.NUM then 'selected="selected"' end||'>'||rec.NAME||'</option>';
        if pPERIOD = rec.NUM then sPERNAME := rec.NAME; end if;
  	end loop;

  	sPERIOD := sPERIOD||'</select>';

    sKBK := '<select onchange="apex.submit({request:this.value,set:{''P477_KBK'':this.value}});" style="float:right; margin-right:5px">';


  	for rec in
       (select distinct KBK.SFULLKBKCODE, KBK.NKBK_RN KBKRN
        from Z_ORG_BUDGDETAIL D, ZV_KBKALL KBK
        where D.JUR_PERS = pJURPERS
            and D.VERSION  = pVERSION
            and D.PRN      = pORGRN
            and D.KBK      = KBK.NKBK_RN (+)
            and D.RTYPE    = pEXPDIRTYPE
        union
        select '<Все>', 0 from dual
        )
  	loop
  		sKBK := sKBK||'<option value="'||rec.KBKRN||'" '||case when pKBK = rec.KBKRN then 'selected="selected"' end||'>'||rec.SFULLKBKCODE||'</option>';
  	end loop;
    -- sKBK := sKBK||'<option value="'||rec.KBKRN||'" '||case when sKBK = rec.KBKRN then 'selected="selected"' end||'>'||rec.KBKRN||'</option>';
  	sKBK := sKBK||'</select>';


    sSTRBACK    := '<span class="btn" style="float:right; margin-right:5px" onclick="location.href='''||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':427:'||:APP_SESSION)||'''">Назад</span>';
    sSTRSAVEBTN := '<span class="btn btn-primary"  style="float:right;margin-right:5px" onclick="apex.submit({showWait:true});">Сохранить</span>';
    sSTRNAMESTR  := '<div style="font-weight: bold;font-size: 14px;padding: 5px 3px;border-bottom: 1px solid #ccc;margin-bottom: 5px;">Детализация доходов (бюджет)</div>';

	if  sDISABLEDTEXT is null and (nNEXTPERIOD >= 2020) then
		sADDROW  := '<span class="btn btn-primary" style="float:right" onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin();')||'''">Добавить строку</span>';
	else
		sADDROW  := '<span class="btn btn-primary" style="float:right" onclick="javascript:apex.confirm(''Статус раздела или редакции ПФХД не позволяет изменять текущие данные по доходам. Обратитесь к Администратору.'');">Добавить строку</span>';
	end if;

	if  sDISABLEDTEXT is null and (nNEXTPERIOD < 2020) then
		sADDEXP  := '<span class="btn btn-primary" style="float:right; margin-right:5px" onclick="javascript:apex.submit(''rADD'');">Добавить строку</span>';
	else
		sADDEXP  := '';
	end if;


    htp.p(
    '<div style="background: whitesmoke;padding: 10px;border: 1px solid #ccc;"><div>
        '||sSTRSAVEBTN||'
        '||sSTRBACK||'
		'||sADDEXP||'
		'||sADDROW||'
		'||sPERIOD||'
        '||sKBK||'
        '||sSTRNAMESTR ||'
    </div>');

    -- Диалоговые окна
	htp.p('<div id="detorg" title="Доходы"></div>');

    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1 myCell" style="border-left:0px" ><div class="th1">Код строки</div></th>
         <th class="header th2" ><div class="th2">Код дохода</div></th>'||
		  case when pEXPDIRTYPE = 4 then '<th class="header th2_1" ><div class="th2_1">КОСГУ</div></th>' end ||'
		 <th class="header th3" ><div class="th3">'||case when pEXPDIRTYPE = 12 then 'РзПр.КЦСР.КВР' else 'КБК' end ||'</div></th>
		 <th class="header th4" ><div class="th4">'||case when pEXPDIRTYPE = 12 then 'Аналитический код' else 'Код ЦС' end ||'</div></th>
         <th class="header th5" ><div class="th5">Наименование вида дохода</div></th>
         <th class="header th6" ><div class="th6">'||sPERNAME||'<br>(руб)</br></div></th>
		 <th class="header th7" ><div class="th7">ФАКТ<br>(руб)</br></div></th>
         <th class="header th8 show" ><div class="th8">Искл.</div></th>
         <th class="header th10" ><div class="th10"></div></th>
         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

	begin
		select case pPERIOD when 1 then sum(D.PLANSUM_02)
                            when 2 then sum(D.PLANSUM_01)
                            when 3 then sum(D.SUMMA)

				            when 4 then sum(D.PLANSUM1)
            				when 5 then sum(D.PLANSUM2)
            				when 6 then sum(D.PLANSUM3) end,
				sum(FACTSUM)
		  into nTOTAL, nTOTAL_FACT
		  from Z_ORG_BUDGDETAIL D, Z_INCOME I
		 where D.VERSION            = pVERSION
		   and D.PRN                = pORGRN
		   and ((pORGFL is null) or (D.FILIAL = pORGFL))
		   and D.RTYPE              = pEXPDIRTYPE
		   and D.INCOME             = I.RN (+)
		   and nvl(I.EXCEPT_SIGN,0) = 0
           and (D.KBK = pKBK or pKBK = 0)
		   and nvl(TOTAL_SIGN,0)    = 0;
    exception when others then
		nTOTAL := null;
		nTOTAL_FACT := null;
	end;

    sCODE         := '<td class="c1 group"><div class="c1"></div></td>';
    sINCOMECODE   := '<td class="c2 group"><div class="c2"></div></td>';

	if pEXPDIRTYPE = 4 then
		sKOSGUCODE    := '<td class="c2_1 group"><div class="c2_1"></div></td>';
	else
		sKOSGUCODE := '';
	end if;

    sKBKSCODE     := '<td class="c3 group"><div class="c3"></div></td>';
    sFUNDCODE     := '<td class="c4 group"><div class="c4"></div></td>';
    sNAME         := '<td class="c5 group"><div style="text-align:right" class="c5"><b>ИТОГО:</></div></td>';
    sSUMMA        := '<td class="c6 group"><div class="c6"><b>'||LTRIM(to_char(nvl(nTOTAL,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
	sSUMMA_FACT   := '<td class="c7 group"><div style="text-align:right" class="c7"><b>'||LTRIM(to_char(nvl(nTOTAL_FACT,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
    sEXCEPTSIGN   := '<td class="c8 group show"><div class="c8"><b>'||null||'</></div></td>';
    sDELROW       := '<td class="c10 group"><div class="c10"><b>'||null||'</></div></td>';

    htp.p('
        <tr>
            '||sCODE||'
            '||sINCOMECODE||'
			'||sKOSGUCODE||'
            '||sKBKSCODE||'
            '||sFUNDCODE||'
            '||sNAME||'
            '||sSUMMA||'
			'||sSUMMA_FACT||'
            '||sEXCEPTSIGN||'
            '||sDELROW||'
        </tr>');

    if ((pFILSIGN = 1 and pORGFL is not null) or (pFILSIGN  = 0)) then
        for rec in
        (
         select D.RN, I.RN INCOMERN,
                nvl(CP.NUMB, D.CODE) STRCODE,
                D.RTYPE,
                nvl(K1.CODE, D.INCOME_CODE) INCOME_CODE,
                nvl(I.NAME, D.NAME) STRNAME,
                D.EXCEPT_SIGN, D.READ_SIGN,
    			case pPERIOD when 1 then D.PLANSUM_02
                             when 2 then D.PLANSUM_01
    			             when 3 then D.SUMMA
    			             when 4 then D.PLANSUM1
                			 when 5 then D.PLANSUM2
            				 when 6 then D.PLANSUM3
    			end "SUMMA",
    			D.FACTSUM,
                KBK.SFULLKBKCODE,
                F.CODE FUNDCODE,
                K2.CODE KOSGOCODE,
                F.NOTES FUNDNOTES,
                K2.NAME KOSGUNAME
           from Z_ORG_BUDGDETAIL D, Z_INCOME I, Z_CODESTR_PFHD CP, Z_KOSGU K1, ZV_KBKALL KBK, Z_FUNDS F, Z_KOSGU K2
          where D.JUR_PERS = pJURPERS
    	    and D.VERSION  = pVERSION
            and D.PRN      = pORGRN
    		and ((pORGFL is null) or (D.FILIAL = pORGFL))
            and D.RTYPE    = pEXPDIRTYPE
            and D.INCOME   = I.RN (+)
            and I.CODEPFHD = CP.RN (+)
            and I.KOSGU    = K1.RN (+)
            and D.KOSGU    = K2.RN (+)
            and D.KBK      = KBK.NKBK_RN (+)
            and D.FUND     = F.RN (+)
            and (D.KBK = pKBK or pKBK = 0)
            and nvl(D.TOTAL_SIGN,0) = 0
          order by nvl(D.TOTAL_SIGN,0) desc, lpad(D.CODE,10), lpad(D.INCOME_CODE,10), D.TOTAL_SIGN desc, D.RN
        )
        loop
            nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;
            sBTN  := 'btn';

    		if (nvl(rec.READ_SIGN,0) = 1) then
    			sDISABLEDFACT	 := '';
    		else
    			sDISABLEDFACT    := 'disabled';
    		end if;

            select count(*) into nHISTCOUNT from Z_BUDGDETAIL_HISTORY where PARENT_ROW = rec.RN;
            if nvl(nHISTCOUNT,0) > 0 then sBTN := 'btn btn-primary'; end if;

            if (rec.INCOMERN is not null) then
                sCODE  := '<td class="c1"><div class="c1">'||rec.STRCODE||'</></div></td>';
            else
                sCODE       := '<td class="c1">
                               <div class="c1"><input '|| /*sDISABLEDTEXT **GALA** */ ''||'  type="text" value="'||rec.STRCODE||'" class="in_txtr"
                                     onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''CODE'', this);"/>
                               </div>
                               </td>';
            end if;

            if (rec.INCOMERN is not null)  then
                sINCOMECODE := '<td class="c2"><div class="c2">'||rec.INCOME_CODE||'</></div></td>';
            else
                sINCOMECODE := '<td class="c2">
                              <div class="c2"><input '|| /*sDISABLEDTEXT **GALA** */ '' ||'  type="text" value="'||rec.INCOME_CODE||'" class="in_txtr"
                                    onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''INCOME_CODE'', this);"/>
                              </div>
                              </td>';
            end if;

			if pEXPDIRTYPE = 4 then
				sKOSGUCODE    := '<td class="c2_1"><div class="c2_1">'||rec.KOSGOCODE ||'</div></td>';
			end if;

            sKBKSCODE  := '<td class="c3"><div class="c3">'||rec.SFULLKBKCODE ||'</></div></td>';
            sFUNDCODE  := '<td class="c4"><div class="c4" title="'||case when pEXPDIRTYPE = 12 then rec.KOSGUNAME else rec.FUNDNOTES end||'">'||case when pEXPDIRTYPE = 12 then rec.KOSGOCODE else rec.FUNDCODE end||'</></div></td>';

            if (rec.INCOMERN is not null) then
                sNAME      := '<td class="c5"><div class="c5">'||rec.STRNAME||'</></div></td>';
            else
                sNAME      := '<td class="c5">
                               <div class="c5"><input '|| /*sDISABLEDTEXT **GALA** */ '' ||' placeholder="Введите наименование" type="text" value="'||rec.STRNAME||'" class="in_txtl"
                                     onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''NAME'', this);"/>
                               </div>
                               </td>';
            end if;

            sSUMMA     := '<td class="c6">
                           <div class="c6"><input '|| sDISABLEDSUM ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.SUMMA,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                 onfocus="validate(this,''0'') ;selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, '''||case pPERIOD when 1 then 'MPLAN_02' when 2 then 'MPLAN_01' when 3 then 'NEXTPERIOD' when 4 then 'PLAN1' when 5 then 'PLAN2' when 6 then 'PLAN3' end ||''', this);"/>'
                                 || case when nvl(nREDACTIONS, 0) = 1 then '<span class="'||sBTN||'" style="float:right"   onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.RN||','||rec.RTYPE||');')||'''">+</span>' end ||
                           '</div>
                           </td>';

            sSUMMA_FACT := '<td class="c7">
                           <div class="c7"><input '|| sDISABLEDFACT ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.FACTSUM,'999G999G999G999G999G990D00'),' ')||'" class="in_txtr decimal"
                                 onfocus="validate(this,''0'') ;selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''FACTSUM'', this);"/></div>
                           </td>';

            sEXCEPTSIGN  := '<td class="c8 show">
                            <div class="c8"> <input type="checkbox" '||sADMINSIGN ||' value="'||nvl(rec.EXCEPT_SIGN,0)||'"
                                 onclick="saveExceptSign(this,'||rec.RN||')" '|| case when nvl(rec.EXCEPT_SIGN,0) = 1 then 'checked' end ||'/><div id="ind'||rec.rn||'" style="float:right;width:16px;">
                            </div>
                            </td>';


            if sDISABLEDTEXT is null and nvl(nHISTCOUNT,0) = 0 then
                sDELROW := '<td class="c10">
                            <div class="c10"><a href= "f?p=&APP_ID.:477:'||:app_session||':rDEL:NO::P477_DELRN:'||rec.RN||'" style="font-weight: bold; text-align:right; color:#0000ff">
                                <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                            </div>
                            </td>';
            elsif nvl(nHISTCOUNT,0) != 0 then
                sDELROW := '<td class="c10">
                            <div class="c10"><a href= "'||APEX_UTIL.PREPARE_URL('javascript:apex.confirm(''Строка доходов имеет историю изменений. Необходимо предварительно удалить всю историю изменений по строке.'');')||'">
                                <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                            </div>
                            </td>';

			elsif sDISABLEDTEXT is not null then
                sDELROW := '<td class="c10">
                            <div class="c10"><a href= "'||APEX_UTIL.PREPARE_URL('javascript:apex.confirm(''Статус раздела или редакции ПФХД не позволяет изменять текущие данные по доходам. Обратитесь к Администратору.'');')||'">
                                <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                            </div>
                            </td>';

			else
                sDELROW := '<td class="c10"><div class="c10"></div></td>';
            end if;


            htp.p('
                <tr>
                    '||sCODE||'
                    '||sINCOMECODE||'
					'||sKOSGUCODE||'
                    '||sKBKSCODE||'
                    '||sFUNDCODE||'
                    '||sNAME||'
                    '||sSUMMA||'
    				'||sSUMMA_FACT||'
                    '||sEXCEPTSIGN||'
                    '||sDELROW||'
                </tr>');
        end loop;

    elsif (pFILSIGN = 1 and pORGFL is null) then

        for rec in
        (
         select nvl(CP.NUMB, D.CODE) STRCODE,
                nvl(K1.CODE, D.INCOME_CODE) INCOME_CODE,
                D.RTYPE,
                nvl(I.NAME, D.NAME) STRNAME,
                case pPERIOD when 1 then sum(D.PLANSUM_01)
                             when 2 then sum(D.PLANSUM_02)
                             when 3 then sum(D.SUMMA)
                             when 4 then sum(D.PLANSUM1)
                             when 5 then sum(D.PLANSUM2)
            				 when 6 then sum(D.PLANSUM3)
                end "SUMMA",
                sum(D.FACTSUM) FACTSUM,
                KBK.SFULLKBKCODE,
                F.CODE FUNDCODE,
                K2.CODE KOSGOCODE,
                I.RN INCOME,
                D.KBK
           from Z_ORG_BUDGDETAIL D, Z_INCOME I, Z_CODESTR_PFHD CP, Z_KOSGU K1, ZV_KBKALL KBK, Z_FUNDS F, Z_KOSGU K2
          where D.JUR_PERS = pJURPERS
            and D.VERSION  = pVERSION
            and D.PRN      = pORGRN
            and ((pORGFL is null) or (D.FILIAL = pORGFL))
            and D.RTYPE    = pEXPDIRTYPE
            and D.INCOME   = I.RN (+)
            and I.CODEPFHD = CP.RN (+)
            and I.KOSGU    = K1.RN (+)
            and D.KOSGU    = K2.RN (+)
            and D.KBK      = KBK.NKBK_RN (+)
            and D.FUND     = F.RN (+)
            and nvl(D.TOTAL_SIGN,0) = 0
            and (D.KBK = pKBK or pKBK = 0)
          group by nvl(CP.NUMB, D.CODE),
				   nvl(K1.CODE, D.INCOME_CODE),
				   D.RTYPE,
				   nvl(I.NAME, D.NAME),
				   KBK.SFULLKBKCODE,
				   F.CODE,
				   K2.CODE,
				   I.RN,
				   D.KBK
          order by nvl(CP.NUMB, D.CODE), nvl(K1.CODE, D.INCOME_CODE)
        )
        loop
            nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

            sCODE       := '<td class="c1"><div class="c1">'||rec.STRCODE||'</></div></td>';
            sINCOMECODE := '<td class="c2"><div class="c2">'||rec.INCOME_CODE||'</></div></td>';

			if pEXPDIRTYPE = 4 then
				sKOSGUCODE    := '<td class="c2_1 group"><div class="c2_1">'||rec.KOSGOCODE ||'</div></td>';
			end if;

            sKBKSCODE   := '<td class="c3"><div class="c3">'||rec.SFULLKBKCODE ||'</></div></td>';
            sFUNDCODE   := '<td class="c4"><div class="c4">'||case when pEXPDIRTYPE = 12 then rec.KOSGOCODE else rec.FUNDCODE end||'</></div></td>';
            sNAME       := '<td class="c5"><div class="c5">'||rec.STRNAME||'</></div></td>';

            sSUMMA      := '<td class="c6"><div class="c6"><span class="link_code" onclick="ShowDialog2(''detorg'','||pORGRN||','||rec.INCOME ||','||nvl(rec.KBK,0)||','||rec.RTYPE||');">'||LTRIM(to_char(rec.SUMMA,'999G999G999G999G999G990D00'),' ')||'</span></></div></td>';

            sSUMMA_FACT := '<td class="c7"><div class="c7">'||LTRIM(to_char(nvl(rec.FACTSUM,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
            sEXCEPTSIGN := '<td class="c8 show"><div class="c8"></></div></td>';
            sDELROW     := '<td class="c10"><div class="c10"></div></td>';

            htp.p('
                <tr>
                    '||sCODE||'
                    '||sINCOMECODE||'
					'||sKOSGUCODE||'
                    '||sKBKSCODE||'
                    '||sFUNDCODE||'
                    '||sNAME||'
                    '||sSUMMA||'
                    '||sSUMMA_FACT||'
                    '||sEXCEPTSIGN||'
                    '||sDELROW||'
                </tr>');
        end loop;
    end if;

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;">Всего записей: <b>'||nCOUNTROWS||'</b></li>');
    htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
    htp.p('<li style="float:left; " id="save_shtat"></li>');
    htp.p('<li style="clear:both"></li></ul>');
end;
