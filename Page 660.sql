    -- 101; 660; Z_PURCHASES
    declare
      pJURPERS      number        := :P1_JURPERS;
      pVERSION      number        := :P1_VERSION;
      pORGRN	    number        := nvl(:P1_ORGRN,:P7_ORGFILTER);
      pORGFL        number        := nvl(:P1_ORGFL,:P0_FILIAL);

      pUSER         varchar2(100) := :APP_USER;
      pROLE         number        := ZGET_ROLE;
      pFILSIGN      number        := ZF_CHECK_FILIAL_SIGN (:P1_VERSION);
      -----------------------------------------------
      sNUMB             varchar2(4000);
      sCODE             varchar2(4000);
      sNAME             varchar2(4000);
      sYEAR             varchar2(4000);
      sKBK              varchar2(4000);
      sNEXTYEARSUM      varchar2(4000);
      sNEXTYEARSUM1     varchar2(4000);
      sNEXTYEARSUM2     varchar2(4000);
      sNEXTYEARSUM3     varchar2(4000);
      sNEWROW           varchar2(4000);
      -----------------------------------------------
      nCOUNTROWS        number;
      nREDSTATUS        number;
      nPARTSTATUS       number;
      nREDACTIONS       number;
      sDISABLED         varchar2(4000);
      sDISABLEDHIST     varchar2(4000);

      nPRILSUM1001            number;
      nPRILSUM2001            number;
      nPURCHASES1001SUM       number;
      nPURCHASES2001SUM       number;
      nCHECKPRILPURCHASES1001 number;
      nCHECKPRILPURCHASES2001 number;

      sBTN	          		  varchar2(4000);
      sBTN1	          		  varchar2(4000);
      sBTN2	          		  varchar2(4000);
      sBTN3	          		  varchar2(4000);
      nHISTEXIST       		  number;
      nHISTEXIST1      		  number;
      nHISTEXIST2      		  number;
      nHISTEXIST3      		  number;

      nSUM26300               number;

      --344076908


    begin

        if pORGRN is null then
            zp_exception(0,'Учреждение не выбрано. Выберите или закрепите учреждение.');
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


        -- Права доступа
        ----------------------------------------------------

        nREDSTATUS := ZF_GET_PFHDVERS_STATUS_LAST (pVERSION, pORGRN);

        --nPARTSTATUS := ZF_GET_PART_STATUS(pJURPERS, pVERSION, pORGRN, 'PURCHASES', null);


    	-- 0 - OK, !=0 - возвращает текущий статус, 9 - закрыт филиал, "-1" - не найден статус раздела
    	nPARTSTATUS := ZF_GET_PART_CHECK_MODIFY2(pJURPERS, pVERSION, pORGRN, 'PURCHASES', pORGFL);


    	--htp.p('>>'||nREDSTATUS||'#'||nREDEXSTATUS||'#'||nPARTSTATUS);
        if ((nREDSTATUS in (0,3) or nREDACTIONS = 0 )) and (nPARTSTATUS = 0) then
            sDISABLED    := '';
        else
            sDISABLED    := 'disabled';
        end if;

        if nvl(nREDACTIONS,0) = 1 then sDISABLEDHIST := 'disabled'; end if;

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
              padding: 4px 4px;
               /* background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 50% #e1e1e1 repeat-x;*/
              background: #e0e0e0;
              border-bottom: 1px solid #9fa0a0;
              border-left:1px solid #9fa0a0;
            }
            .report_standard td{
              padding: 4px 4px;
              border-bottom: 1px solid #9fa0a0;
              border-left:1px solid #9fa0a0;
              background-color: #f2f2f2;
            }
            .textarea {resize: vertical;text-align:left !important; }
            .in_txtr {width:99%; border: 1px solid #ccc;text-align:right;}
            .in_txtl {width:99%; border: 1px solid #ccc;text-align:left;}
            .in_txt {width:90%; border: 1px solid #ccc;text-align:right;}
            .in_txt2 {width:70%; border: 1px solid #ccc;text-align:right;}

            .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
            .row { margin-bottom: 5px;}

    		.th1{width: 65px;text-align:center;}     .c1 {width: 65px; word-wrap: break-word; text-align:center;}
            .th2{width: 100%;text-align:center;}     .c2 {width: 100%; word-wrap: break-word; text-align:left;}
    		.th3{width: 65px;text-align:center;}     .c3 {width: 65px; word-wrap: break-word; text-align:center;}
    		.th4{width: 65px;text-align:center;}     .c4 {width: 65px; word-wrap: break-word; text-align:center;}
    		.th5{width: 170px;text-align:center;}    .c5 {width: 170px; word-wrap: break-word; text-align:center;}

            .th6{width: 160px;text-align:center;}    .c6 {width: 160px; word-wrap: break-word; text-align:right;}
            .th7{width: 160px;text-align:center;}    .c7 {width: 160px; word-wrap: break-word; text-align:right;}
            .th8{width: 160px;text-align:center;}    .c8 {width: 160px; word-wrap: break-word; text-align:right;}
            .th9{width: 20px;text-align:center;}     .c9 {width: 20px; word-wrap: break-word; text-align:right;}

            .pagination {text-align: right;
              border-top: 1px solid grey;
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

        -- Диалоговые окна
    	htp.p('<div id="detorg1" title="Закупки"></div>');
        htp.p('<div id="detorg2" title="Закупки"></div>');
        htp.p('<div id="detorg3" title="Закупки"></div>');
    	htp.p('<div id="detorg4" title="Закупки"></div>');

        htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
        <thead>
            <tr>
    			<th class="header th1" rowspan="2"><div class="th1">№ п/п</div></th>
                <th class="header th2" rowspan="2"><div class="th2">Наименование<br>показателя</div></th>
                <th class="header th3" rowspan="2"><div class="th3">Код<br>строки</div></th>
                <th class="header th4" rowspan="2"><div class="th4">Год<br>начала<br>закупки</div></th>
    			<th class="header th5" rowspan="2"><div class="th5">КБК</div></th>
                <th colspan="4" ><div>Сумма выплат по расходам на закупку товаров, работ и услуг, руб. (с точностью до двух знаков после запятой -0,00)</div></th>
                <th class="header th9" rowspan="2"><div class="th9"></div></th>
                <th class="header" rowspan="2"><div style="width:8px"></div></th>
            </tr>

            <tr>
                <th class="header th6"><div class="th6">очередной <br>финансовый год</div></th>
                <th class="header th7"><div class="th7">1-ый год <br>планового периода</div></th>
                <th class="header th8"><div class="th8">2-ой год <br>планового периода</div></th>
    			<th class="header th8"><div class="th8">за пределами плана</div></th>
            </tr>

          </thead>
        <tbody id="fullall" >');

        nPRILSUM1001 := XF_GET_COMM_SERV_TOTAL(pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1)       +
                        XF_GET_TRANS_SERV_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1)     +
                        XF_GET_UTIL_SERV_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1)      +
                        XF_GET_RENT_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1)           +
                        XF_GET_PROPERTY_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1)       +
                        XF_GET_OTHER_SERVS_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1)    +
                        XF_GET_EQUIP_PURCHASE_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1) +
                        XF_GET_INV_PURCHASE_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 1)   +
                        XF_GET_ALLSIX_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pAGRFZ => 1);

        nPRILSUM2001 := XF_GET_COMM_SERV_TOTAL(pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2)       +
                        XF_GET_TRANS_SERV_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2)     +
                        XF_GET_UTIL_SERV_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2)      +
                        XF_GET_RENT_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2)           +
                        XF_GET_PROPERTY_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2)       +
                        XF_GET_OTHER_SERVS_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2)    +
                        XF_GET_EQUIP_PURCHASE_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2) +
                        XF_GET_INV_PURCHASE_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pCONCLSIGN => 2)   +
                        XF_GET_ALLSIX_TOTAL (pJURPERS => pJURPERS, pVERSION => pVERSION, pORGRN => pORGRN, pFILIAL => pORGFL, pAGRFZ => 2);

        begin
            select sum(FZ_44_SUM)
              into nPURCHASES1001SUM
              from Z_PURCHASES
             where ORGRN  = pORGRN
               and ((pORGFL is null) or (FILIAL = pORGFL))
    		   and CODE in ('26100', '26300')
    		   and new_2020 = 2020;
        exception when others then
            nPURCHASES1001SUM := null;
        end;

        begin
            select sum(FZ_44_SUM)
              into nPURCHASES2001SUM
              from Z_PURCHASES
             where ORGRN = pORGRN
               and ((pORGFL is null) or (FILIAL = pORGFL))
               and CODE in ('26200', '26400')
    		   and new_2020 = 2020;
        exception when others then
            nPURCHASES2001SUM := null;
        end;

        if ABS((nvl(nPURCHASES1001SUM,0)) - (nPRILSUM1001)) >= 1 then
            nCHECKPRILPURCHASES1001 := 1;
        end if;

        if ABS((nvl(nPURCHASES2001SUM,0)) - (nPRILSUM2001)) >= 1 then
            nCHECKPRILPURCHASES2001 := 1;
        end if;

        if ((pFILSIGN = 1 and pORGFL is not null) or (pFILSIGN  = 0)) then

            for rec in
        	(
             select P.*, case when P.KBK is not null then KBK.SCODE||'.'|| nvl(STYPEBS_NUMB,'-') else null end SCODE
        	   from Z_PURCHASES P, ZV_KBKALL KBK
        	  where P.ORGRN = pORGRN
                and ((pORGFL is null) or (P.FILIAL = pORGFL))
        		and P.VERSION = pVERSION
        		and P.new_2020 = 2020
                and P.KBK = KBK.NKBK_RN (+)
        	  order by rpad(P.CODE,10)
        	)
        	loop

                nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;
        		--
        		nHISTEXIST  := 0;  sBTN  := 'btn';
                begin
      			    select count(*)
    			  	  into nHISTEXIST
    				  from Z_PURCHASES_HISTORY
    			     where PARENT_ROW = rec.RN
    				   and ETYPE = 'FZ_44';
                exception when others then
                    nHISTEXIST := 0;
                end;

        		if nvl(nHISTEXIST,0) > 0 then
        			sBTN := 'btn btn-primary';
        		end if;

    			--
    			nHISTEXIST1 := 0;  sBTN1 := 'btn';
                begin
      			    select count(*)
    			  	  into nHISTEXIST1
    				  from Z_PURCHASES_HISTORY
    			     where PARENT_ROW = rec.RN
    				   and ETYPE = 'NEXTYEAR1';
                exception when others then
                    nHISTEXIST1 := 0;
                end;

        		if nvl(nHISTEXIST1,0) > 0 then
        			sBTN1 := 'btn btn-primary';
        		end if;

    			--
    			nHISTEXIST2 := 0;  sBTN2 := 'btn';
                begin
      			    select count(*)
    			  	  into nHISTEXIST2
    				  from Z_PURCHASES_HISTORY
    			     where PARENT_ROW = rec.RN
    				   and ETYPE = 'NEXTYEAR2';
                exception when others then
                    nHISTEXIST2 := 0;
                end;

        		if nvl(nHISTEXIST2,0) > 0 then
        			sBTN2 := 'btn btn-primary';
        		end if;

    			--
    			nHISTEXIST3 := 0;  sBTN3 := 'btn';
                begin
      			    select count(*)
    			  	  into nHISTEXIST3
    				  from Z_PURCHASES_HISTORY
    			     where PARENT_ROW = rec.RN
    				   and ETYPE = 'NEXTYEAR3';
                exception when others then
                    nHISTEXIST3 := 0;
                end;

        		if nvl(nHISTEXIST3,0) > 0 then
        			sBTN3 := 'btn btn-primary';
        		end if;

        		sNUMB         := '<td class="c1"><div class="c1">'||rec.NUMB||'</div></td>';
        		sNAME         := '<td class="c2"><div '|| case when nvl(rec.ROW_SIGN,0) = 2 then 'style="margin-left:30px"' end ||' class="c2">'||rec.NAME||'</div></td>';
        		sCODE         := '<td class="c3"><div class="c3">'||rec.CODE||'</div></td>';
        		sYEAR         := '<td class="c4"><div class="c4">'||rec.YEAR||'</div></td>';
    			sKBK          := '<td class="c5"><div class="c5">'||rec.SCODE||'</div></td>';

                sNEXTYEARSUM1 := '<td class="c7"><div class="c7">'||LTRIM(to_char(nvl(rec.NEXT_YEAR_SUM_1,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        		sNEXTYEARSUM2 := '<td class="c8"><div class="c8">'||LTRIM(to_char(nvl(rec.NEXT_YEAR_SUM_2,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
    			sNEXTYEARSUM3 := '<td class="c8"><div class="c8">'||LTRIM(to_char(nvl(rec.NEXT_YEAR_SUM_3,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';


        		if nvl(rec.TOTAL_SIGN,0) =	 1 and rec.CODE = '26000' then
        			if (nvl(nCHECKPRILPURCHASES1001,0) != 0) or (nvl(nCHECKPRILPURCHASES2001,0) != 0) then
        				sNEXTYEARSUM := '<td class="c6" title="Имеются расхождения" style="background-color:lightcoral">
        								 <div class="c6"><a href="javascript:modalWin('||rec.RN||')">'||LTRIM(to_char(nvl(rec.FZ_44_SUM,0),'999G999G999G999G999G990D00'),' ')||'</a></div>
        								 </td>';
        			else
        				sNEXTYEARSUM := '<td class="c6" title="Расхождений нет" style="background-color:lightgreen">
        								 <div class="c6"><a href="javascript:modalWin('||rec.RN||')">'||LTRIM(to_char(nvl(rec.FZ_44_SUM,0),'999G999G999G999G999G990D00'),' ')||'</a></div>
        								 </td>';
        			end if;
        		elsif nvl(rec.TOTAL_SIGN,0) = 1 and rec.CODE != '26000' then
        			sNEXTYEARSUM := '<td class="c6">
        							 <div class="c6">'||LTRIM(to_char(nvl(rec.FZ_44_SUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
                elsif rec.CODE = '26300' then
     		     	sNEXTYEARSUM := '<td class="c6">
     		   	     				 <div class="c6">'||LTRIM(to_char(nvl(rec.FZ_44_SUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        		else

                        sNEXTYEARSUM    := '<td class="c6">
                                     <div class="c6"><input '|| sDISABLEDHIST ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.FZ_44_SUM,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                         onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''FZ_44_SUM'', this);"/>'
                                         || case when nREDACTIONS = 1 and /* !!! PHIL заглушка*/ not (rec.VERSION in (344076908, 345012858) and rec.CODE = '26300' and ZGET_ROLE = 2) then '<span class="'||sBTN||'" style="float:right"   onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.RN||',1);')||'''">+</span>' end ||
                                    '</div>
                                    </td>';

    					sNEXTYEARSUM1    := '<td class="c7">
    									  <div class="c7"><input '|| sDISABLEDHIST ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.NEXT_YEAR_SUM_1,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
    									 	 onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''NEXT_YEAR_SUM_1'', this);"/>'
    									 	 || case when nREDACTIONS = 1 and /* !!! PHIL заглушка*/ not (rec.VERSION in (344076908, 345012858) and rec.CODE = '26300' and ZGET_ROLE = 2) then '<span class="'||sBTN1||'" style="float:right"   onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.RN||',3);')||'''">+</span>' end ||
    									 '</div>
    									 </td>';

    					sNEXTYEARSUM2    := '<td class="c8">
    									  <div class="c8"><input '|| sDISABLEDHIST ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.NEXT_YEAR_SUM_2,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
    									 	 onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''NEXT_YEAR_SUM_2'', this);"/>'
    									 	 || case when nREDACTIONS = 1 and /* !!! PHIL заглушка*/ not (rec.VERSION in (344076908, 345012858) and rec.CODE = '26300' and ZGET_ROLE = 2) then '<span class="'||sBTN2||'" style="float:right"   onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.RN||',4);')||'''">+</span>' end ||
    									 '</div>
    									 </td>';

    					sNEXTYEARSUM3    := '<td class="c8">
    									  <div class="c8"><input '|| sDISABLEDHIST ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.NEXT_YEAR_SUM_3,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
    									 	 onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''NEXT_YEAR_SUM_3'', this);"/>'
    									 	 || case when nREDACTIONS = 1 and /* !!! PHIL заглушка*/ not (rec.VERSION in (344076908, 345012858) and rec.CODE = '26300' and ZGET_ROLE = 2) then '<span class="'||sBTN3||'" style="float:right"   onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin2('||rec.RN||',5);')||'''">+</span>' end ||
    									 '</div>
    									 </td>';
        		end if;

                if nvl(rec.ROW_SIGN,0) = 1 then
                    sNEWROW := '<td class="c9"><div class="c9"><a href="f?p=101:660:&APP_SESSION.:rADDROW:NO::P660_RN:'||rec.RN||'"><img style="width:12px" src="/i/FNDADD11.gif" title="Добавить нацпроект" /></a></div></td>';
                elsif nvl(rec.ROW_SIGN,0) = 2 then
    				sNEWROW := '<td class="c9"><div class="c9"><a href="f?p=101:660:&APP_SESSION.:rDELROW:NO::P660_RN:'||rec.RN||'"><img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку" /></a></div></td>';
    			else
                    sNEWROW :=  '<td class="c9"><div class="c9"></div></td>';
                end if;

                htp.p(
                '<tr '||case when nvl(rec.TOTAL_SIGN ,0) = 1 or rec.CODE = '26300' then 'style="font-weight: bold"' end||'>
                '||sNUMB||'
                '||sNAME||'
                '||sCODE||'
                '||sYEAR||'
    			'||sKBK||'

                '||sNEXTYEARSUM||'
                '||sNEXTYEARSUM1||'
                '||sNEXTYEARSUM2||'
    			'||sNEXTYEARSUM3||'
                '||sNEWROW||'
                ');
        	end loop;
        elsif (pFILSIGN = 1 and pORGFL is null) then

            for rec in
            (
             select P.TOTAL_SIGN, P.NUMB, P.NAME, P.CODE, P.YEAR, KBK.SCODE,
                    sum(FZ_44_SUM) FZ_44_SUM, sum(NEXT_YEAR_SUM_1) NEXT_YEAR_SUM_1, sum(NEXT_YEAR_SUM_2) NEXT_YEAR_SUM_2, sum(NEXT_YEAR_SUM_3) NEXT_YEAR_SUM_3
               from Z_PURCHASES P, ZV_KBKALL KBK
              where P.ORGRN = pORGRN
                and ((pORGFL is null) or (P.FILIAL = pORGFL))
                and P.VERSION = pVERSION
                and P.new_2020 = 2020
                and P.KBK = KBK.NKBK_RN (+)
              group by P.TOTAL_SIGN, P.NUMB, P.NAME, P.CODE, P.YEAR, KBK.SCODE
              order by rpad(P.CODE,10)
            )
            loop
                nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

                sNUMB          := '<td class="c1"><div class="c1">'||rec.NUMB||'</div></td>';
        		sNAME          := '<td class="c2"><div class="c2">'||rec.NAME||'</div></td>';
        		sCODE          := '<td class="c3"><div class="c3">'||rec.CODE||'</div></td>';
        		sYEAR          := '<td class="c4"><div class="c4">'||rec.YEAR||'</div></td>';
    			sKBK           := '<td class="c5"><div class="c5">'||rec.SCODE||'</div></td>';

                sNEXTYEARSUM   := '<td class="c6"><div class="c6"><span class="link_code" onclick="ShowDialog2(''detorg1'','||pORGRN||','||rec.CODE||');">'||LTRIM(to_char(nvl(rec.FZ_44_SUM,0),'999G999G999G999G999G990D00'),' ')||'</span></></div></td>';
                sNEXTYEARSUM1  := '<td class="c7"><div class="c7"><span class="link_code" onclick="ShowDialog2(''detorg2'','||pORGRN||','||rec.CODE||');">'||LTRIM(to_char(nvl(rec.NEXT_YEAR_SUM_1,0),'999G999G999G999G999G990D00'),' ')||'</span></></div></td>';
                sNEXTYEARSUM2  := '<td class="c8"><div class="c8"><span class="link_code" onclick="ShowDialog2(''detorg3'','||pORGRN||','||rec.CODE||');">'||LTRIM(to_char(nvl(rec.NEXT_YEAR_SUM_2,0),'999G999G999G999G999G990D00'),' ')||'</span></></div></td>';
    			sNEXTYEARSUM3  := '<td class="c8"><div class="c8"><span class="link_code" onclick="ShowDialog2(''detorg4'','||pORGRN||','||rec.CODE||');">'||LTRIM(to_char(nvl(rec.NEXT_YEAR_SUM_3,0),'999G999G999G999G999G990D00'),' ')||'</span></></div></td>';

                sNEWROW        :=  '<td class="c9"><div class="c9">'||rec.YEAR||'</div></td>';

                htp.p(
                '<tr '||case when nvl(rec.TOTAL_SIGN,0) = 1 then 'style="font-weight: bold"' end||'>
                '||sNUMB||'
                '||sNAME||'
                '||sCODE||'
                '||sYEAR||'
    			'||sKBK||'

                '||sNEXTYEARSUM||'
                '||sNEXTYEARSUM1||'
                '||sNEXTYEARSUM2||'
    			'||sNEXTYEARSUM3||'
                '||sNEWROW||'
                ');

            end loop;
        end if;

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
              table_body.height("600px");
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

            function save_data(rn, val, field, obj) {
              apex.server.process("save_data", {
                      x01: rn,
                      x02: val,
                      x03: field
                  }, {
                      // refreshObject: "#tablediv",
                     // loadingIndicator: "#save_data",
                      success: function(data) {
                         if (data.status === ''good'') {
                              $(obj).css(''border-bottom'', ''1px solid green'');
                          } else {
                              $(obj).css(''border-bottom'', ''1px solid red'');
                          }
                      }
                  });
            }

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

            $(document).ready(function(){
            var index = 1;
            var tabindex = 1;
               $(".decimal").inputmask({alias: "decimal",
                groupSeparator: " ",
                autoGroup: true,
              allowPlus: false,
              allowMinus: true,
              max: 99999999999.99,
              digits : 2,
              radixPoint:",",
              digitsOptional: false
             });

              $("input .decimal").each(function () {
                $(this).attr("tabindex", index);
                index++;});
              $(".decimal").on("click", function() {
                  tabindex = $(this).attr("tabindex")
                })
                $(".decimal").on("keyup", function(e) {
                  if (e.keyCode === 40) {
                    tabindex++;
                    $(".decimal[tabindex=" + tabindex + "]").focus()
                    $(".decimal[tabindex=" + tabindex + "]").select()
                  }
                  if (e.keyCode == 38) {
                    tabindex--;
                    $(".decimal[tabindex=" + tabindex + "]").focus()
                    $(".decimal[tabindex=" + tabindex + "]").select()
                  }
                })
               });

    		function selecter(obj,rownum)
    		{
    		$("#fix").find("tr").removeClass("selected");
    		$("#fix").find("tr[row="+rownum+"]").addClass("selected");
    		$("#fix tr").removeClass("selected");
    		$(obj).parent("div").parent("td").parent("tr").addClass("selected");
    		}

            function ShowDialog2(id, orgrn, code) {
            $.ajax({
                url: "wwv_flow.show",
                type: "POST",
                data: {
                    p_request: "APPLICATION_PROCESS=dialog_" + id,
                    p_flow_id: $("#pFlowId").val(),
                    p_flow_step_id: $("#pFlowStepId").val(),
                    p_instance: $("#pInstance").val(),
                    x01: orgrn,
                    x02: code

                },
                success: function(data) {

                    $("#" + id).html(data);
                    $("#" + id).dialog({
                        modal: true,
                        closeText: "Закрыть",
                        width: 600,
                        height: 400,
                        maxWidth: 600,
                        maxHeight: 400,
                        position: "center",
                        buttons: {
                            ''Закрыть'': function() {
                                $(this).dialog("close");
                            }
                        }
                    });
            }
            });
            }
        </script>');
    end;
