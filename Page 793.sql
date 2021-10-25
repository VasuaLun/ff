--101; 793; H_INCOME_PRILFORMS_DTL
declare
 pJURPERS    number         := :P1_JURPERS;
 pVERSION    number         := :P1_VERSION;
 pORGRN	     number         := nvl(:P1_ORGRN,:P7_ORGFILTER);
 pFILIAL     number         := nvl(nvl(:P1_ORGFL,:P0_FILIAL),:P793_FILIAL);

 pUSER       varchar2(100)  := :APP_USER;
 pROLE       number         := ZGET_ROLE;

 pINCPRIL    number         := :P793_RN;
 -----------------------------------------------
 sINUMB         varchar2(4000);
 sNOTES         varchar2(4000);
 sX1SUM         varchar2(4000);
 sX2SUM         varchar2(4000);
 sCOLSUM         varchar2(4000);
 sTOTALSUM      varchar2(4000);
 sPLAN1X1SUM    varchar2(4000);
 sPLAN1X2SUM    varchar2(4000);
 sPLAN1COL      varchar2(4000);
 sPLAN1TOTALSUM varchar2(4000);
 sPLAN2X1SUM    varchar2(4000);
 sPLAN2X2SUM    varchar2(4000);
 sPLAN2COL      varchar2(4000);
 sPLAN2TOTALSUM varchar2(4000);
 sPLAN3X1SUM    varchar2(4000);
 sPLAN3X2SUM    varchar2(4000);
 sPLAN3COLSUM   varchar2(4000);
 sPLAN3TOTALSUM varchar2(4000);
 sDELROW		varchar2(4000);
 sEMPTY         varchar2(4000);
 -----------------------------------------------
 nCOUNTROWS  number;

 sColor      varchar2(100);
 sMSG	     varchar2(250);

 nNEXTPERIOD Z_VERSIONS.NEXT_PERIOD%type;
 nPLAN1      Z_VERSIONS.PLAN1%type;
 nPLAN2      Z_VERSIONS.PLAN2%type;

 nTOTAL 	 number;
 nTOTAL1	 number;
 nTOTAL2	 number;
 nTOTAL3	 number;

 nREDSTATUS	number;
 nREDRN		number;
 nPARTSTATUS	number;
 sDISABLED		varchar2(50) := '';
 sDISABLED_DEBCRED varchar2(50) := '';
 nDEBCRED_SIGN  number;
 sDisplay		varchar2(50);

begin

    --htp.p('>>'||pFILIAL);
    -- permissions
    ----------------------------------------------------
	nREDSTATUS := ZF_GET_PFHDVERS_STATUS_LAST (pVERSION => pVERSION,
											   pORGRN   => pORGRN);
	nREDRN := ZF_GET_PFHDVERS_LAST (pVERSION => pVERSION,
									pORGRN   => pORGRN);

	nPARTSTATUS := ZF_GET_PART_CHECK_MODIFY2(pJURPERS => pJURPERS,
											 pVERSION => pVERSION,
											 pORGRN   => pORGRN,
											 pPART    => 'JUST_INC');

	if ((nREDSTATUS in (0,3)  )) and (nPARTSTATUS = 0) then
		sDISABLED    := '';
	else
		sDISABLED    := 'disabled';
	end if;

    -- initialization
    ----------------------------------------------------
    begin
        Select NEXT_PERIOD, PLAN1, PLAN2
          into nNEXTPERIOD, nPLAN1, nPLAN2
          from Z_VERSIONS where RN = pVersion;
    exception
        when NO_DATA_FOUND then
        nNEXTPERIOD := null;
        nPLAN1       := null;
        nPLAN2       := null;
    end;

	-- получим признак дебкред задолженности
	select I.DEBCRED_SIGN
      into nDEBCRED_SIGN
      from H_INCOME_PRILFORMS F, Z_INCOME I
     where F.INCOME = I.RN
       and F.RN = pINCPRIL;

	if nDEBCRED_SIGN is not null then
		sDisplay := 'display: none;';
		sDISABLED_DEBCRED := 'disabled';
	else
		sDisplay := null;
		sDISABLED_DEBCRED := '';
	end if;

	select sum(D.TOTAL), sum(D.PLAN1_TOTAL), sum(D.PLAN2_TOTAL), sum(D.PLAN3_TOTAL)
      into nTOTAL, nTOTAL1, nTOTAL2, nTOTAL3
	  from H_INCOME_PRILFORMS_DTL D
	 where D.JURPERS  = pJURPERS
	   and D.VERSION  = pVERSION
       and D.ORGRN    = pORGRN
	   and D.FILIAL   = pFILIAL
	   and D.PRN      = pINCPRIL;
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

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}

        .th1{width: 15px;text-align:center; border-left: 0px !important} .c1 {width: 15px; word-wrap: break-word; text-align:center; border-left: 0px !important}
		.th2{width: 100%;text-align:center;}   .c2 {width: 100%; word-wrap: break-word; text-align:left;}
        .th21{width: 100px;text-align:center;}   .c21 {width: 100px; word-wrap: break-word; text-align:left;}

        .th3{width: 70px;text-align:center;}   .c3 {width: 70px; word-wrap: break-word; text-align:center;}
		.th4{width: 70px;text-align:center;}   .c4 {width: 70px; word-wrap: break-word; text-align:center;}
        .th41{width: 80px;text-align:center;}  .c41 {width: 80px; word-wrap: break-word; text-align:right;}
		.th5{width: 90px;text-align:center;}   .c5 {width: 90px; word-wrap: break-word; text-align:right;}

        .th6{width: 70px;text-align:center;}   .c6 {width: 70px; word-wrap: break-word; text-align:center;}
		.th7{width: 70px;text-align:center;}   .c7 {width: 70px; word-wrap: break-word; text-align:center;}
        .th71{width: 80px;text-align:center;}  .c71 {width: 80px; word-wrap: break-word; text-align:right;}
		.th8{width: 90px;text-align:center;}   .c8 {width: 90px; word-wrap: break-word; text-align:right;}

        .th9{width: 70px;text-align:center;}   .c9 {width: 70px; word-wrap: break-word; text-align:center;}
		.th10{width: 70px;text-align:center;}  .c10 {width: 70px; word-wrap: break-word; text-align:center;}
        .th101{width: 80px;text-align:center;}  .c101 {width: 80px; word-wrap: break-word; text-align:right;}
		.th11{width: 90px;text-align:center;}  .c11 {width: 90px; word-wrap: break-word; text-align:right;}

        .th12{width: 70px;text-align:center;}  .c12 {width: 70px; word-wrap: break-word; text-align:center;}
		.th13{width: 70px;text-align:center;}  .c13 {width: 70px; word-wrap: break-word; text-align:center;}
        .th131{width: 80px;text-align:center;}  .c131 {width: 80px; word-wrap: break-word; text-align:right;}
		.th14{width: 90px;text-align:center;}  .c14 {width: 90px; word-wrap: break-word; text-align:right;}

		.th15{width: 20px;text-align:center;}  .c15 {width: 20px; word-wrap: break-word; text-align:center;}

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
         <th class="header th1" rowspan="3" style="border-left:0px" ><div class="th1">№</div></th>
         <th class="header th2" rowspan="3" ><div class="th2">Описание (категория<br>получателей)</div></th>
         <th class="header th21" rowspan="3" ><div class="th21">Код</div></th>
         <th colspan="4"><div>'||nNEXTPERIOD||'</div></th>
		 <th colspan="4"><div>'||nPLAN1||'</div></th>
		 <th colspan="4"><div>'||nPLAN2||'</div></th>
		 <th colspan="4"><div> За пределами </div></th>
		 <th class="header th15" rowspan="3" ><div class="th15"></div></th>
         <th class="header" rowspan="3"><div style="width:8px"></div></th>
        </tr>

        <tr>
		 <th class="header th3" ><div class="th3">'||case when sDisplay is null then 'Кол-во человек' else '' end||'</div></th>
		 <th class="header th4" ><div class="th4">'||case when sDisplay is null then 'Средняя плата' else 'Сумма,руб.' end||'</div></th>
         <th class="header th41" ><div class="th41">Кол-во выплат(руб),<br>коэфф.</div></th>
		 <th class="header th5" ><div class="th5">Итого, руб</div></th>

		 <th class="header th6" ><div class="th6">'||case when sDisplay is null then 'Кол-во человек' else '' end||'</div></th>
		 <th class="header th7" ><div class="th7">'||case when sDisplay is null then 'Средняя плата' else 'Сумма,руб.' end||'</div></th>
         <th class="header th71" ><div class="th71">Кол-во выплат(руб),<br>коэфф.</div></th>
		 <th class="header th8" ><div class="th8">Итого, руб</div></th>

		 <th class="header th9" ><div class="th9">'||case when sDisplay is null then 'Кол-во человек' else '' end||'</div></th>
		 <th class="header th10" ><div class="th10">'||case when sDisplay is null then 'Средняя плата' else 'Сумма,руб.' end||'</div></th>
         <th class="header th101" ><div class="th101">Кол-во выплат(руб),<br>коэфф.</div></th>
		 <th class="header th11" ><div class="th11">Итого, руб</div></th>

		 <th class="header th12" ><div class="th12">'||case when sDisplay is null then 'Кол-во человек' else '' end||'</div></th>
		 <th class="header th13" ><div class="th13">'||case when sDisplay is null then 'Средняя плата' else 'Сумма,руб.' end||'</div></th>
         <th class="header th131" ><div class="th131">Кол-во выплат(руб),<br>коэфф.</div></th>
		 <th class="header th14" ><div class="th14">Итого, руб</div></th>
        </tr>

        <tr>
		 <th class="header th3 group" ><div class="th3">-</div></th>
		 <th class="header th4 group" ><div class="th4">-</div></th>
         <th class="header th41 group" ><div class="th41">-</div></th>
		 <th class="header th5 group" ><div style="text-align:right" class="th5">'||LTRIM(to_char(nvl(nTOTAL,0),'999G999G999G999G999G990D00'),' ')||'</div></th>

		 <th class="header th6 group" ><div class="th6">-</div></th>
		 <th class="header th7 group" ><div class="th7">-</div></th>
         <th class="header th71 group" ><div class="th71">-</div></th>
		 <th class="header th8 group" ><div style="text-align:right" class="th8">'||LTRIM(to_char(nvl(nTOTAL1,0),'999G999G999G999G999G990D00'),' ')||'</div></th>

		 <th class="header th9 group" ><div class="th9">-</div></th>
		 <th class="header th10 group" ><div class="th10">-</div></th>
         <th class="header th101 group" ><div class="th101">-</div></th>
		 <th class="header th11 group" ><div style="text-align:right" class="th11">'||LTRIM(to_char(nvl(nTOTAL2,0),'999G999G999G999G999G990D00'),' ')||'</div></th>

		 <th class="header th12 group" ><div class="th12">-</div></th>
		 <th class="header th13 group" ><div class="th13">-</div></th>
         <th class="header th141 group" ><div class="th141">-</div></th>
		 <th class="header th14 group" ><div style="text-align:right" class="th14">'||LTRIM(to_char(nvl(nTOTAL3,0),'999G999G999G999G999G990D00'),' ')||'</div></th>
        </tr>

      </thead>

    <tbody id="fullall" >');

	for rec in
	(
     select D.*, F.CODE
       from H_INCOME_PRILFORMS_DTL D, Z_FUNDS F
      where D.JURPERS  = pJURPERS
	    and D.VERSION  = pVERSION
        and D.ORGRN    = pORGRN
	    and D.FILIAL   = pFILIAL
	    and D.PRN      = pINCPRIL
        and D.FUND     = F.RN (+)
	  order by D.INUMB
	)
	loop
		null;
    	if nvl(nCOUNTROWS,0) <= 500 then

			sINUMB     := '<td class="c1"><div class="c1">'||rec.INUMB||'</></div></td>';

            sNOTES     := '<td class="c2"><div class="c2"><span style="font-weight: bold;color:#0000ff;white-space: nowrap" onclick="modalWin2('||rec.rn||','||pVERSION||','||pJURPERS||','||pORGRN||')">'||nvl(rec.NOTES, '-')||'</span></></div></td>';

            sEMPTY  := '<td class="c21"><div class="c21">'||rec.CODE||'</></div></td>';

			-----

            sX1SUM     := '<td class="c3"><div class="c3">'||LTRIM(to_char(rec.X1,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sX2SUM     := '<td class="c4"><div class="c4">'||LTRIM(to_char(rec.X2,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sCOLSUM     := '<td class="c41"><div class="c41">'||LTRIM(to_char(rec.COEFF,'999G999G999G999G999G990D00'),' ')||'</></div></td>';

			sTOTALSUM   := '<td class="c5"><div class="c5">'||LTRIM(to_char(rec.TOTAL,'999G999G999G999G999G990D00'),' ')||'</></div></td>';

			-----
            sPLAN1X1SUM := '<td class="c6"><div class="c6">'||LTRIM(to_char(rec.PLAN1_X1,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sPLAN1X2SUM := '<td class="c7"><div class="c7">'||LTRIM(to_char(rec.PLAN1_X2,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sPLAN1COL   := '<td class="c71"><div class="c71">'||LTRIM(to_char(rec.PLAN1_COEFF,'999G999G999G999G999G990D00'),' ')||'</></div></td>';

			sPLAN1TOTALSUM := '<td class="c8"><div class="c8">'||LTRIM(to_char(nvl(rec.PLAN1_TOTAL,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

			-----
            sPLAN2X1SUM := '<td class="c9"><div class="c9">'||LTRIM(to_char(rec.PLAN2_X1,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sPLAN2X2SUM := '<td class="c10"><div class="c10">'||LTRIM(to_char(rec.PLAN2_X2,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sPLAN2COL := '<td class="c101"><div class="c101">'||LTRIM(to_char(rec.PLAN2_COEFF,'999G999G999G999G999G990D00'),' ')||'</></div></td>';

			sPLAN2TOTALSUM := '<td class="c11"><div class="c11">'||LTRIM(to_char(nvl(rec.PLAN2_TOTAL,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

			-----
            sPLAN3X1SUM := '<td class="c12"><div class="c12">'||LTRIM(to_char(rec.PLAN3_X1,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sPLAN3X2SUM := '<td class="c13"><div class="c13">'||LTRIM(to_char(rec.PLAN3_X2,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sPLAN3COLSUM := '<td class="c131"><div class="c131">'||LTRIM(to_char(rec.PLAN3_COEFF,'999G999G999G999G999G990D00'),' ')||'</></div></td>';

			sPLAN3TOTALSUM := '<td class="c14"><div class="c14">'||LTRIM(to_char(nvl(rec.PLAN3_TOTAL,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

            if sDISABLED is null then
                sDELROW := '<td class="c15">
                            <div class="c15"><a href= "f?p=&APP_ID.:793:'||:app_session||':rDELEXP:NO::P793_DELRN:'||rec.RN||'" style="font-weight: bold; text-align:right; color:#0000ff">
                                <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                            </div>
                            </td>';

			else
                sDELROW := '<td class="c15">
                            <div class="c15"><a href= "'||APEX_UTIL.PREPARE_URL('javascript:apex.confirm(''Статус раздела или редакции ПФХД не позволяет изменять текущие данные по доходам. Обратитесь к Администратору.'');')||'">
                                <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                            </div>
                            </td>';
            end if;

			if sDISABLED_DEBCRED is not null then
                sDELROW := '<td class="c15">
                            <div class="c15"></div></td>';

			end if;


            htp.p('
                <tr id="row_'||rec.RN||'" >
					'||sINUMB||'
					'||sNOTES||'

                    '||sEMPTY||'

					'||sX1SUM||'
					'||sX2SUM||'
                    '||sCOLSUM||'
					'||sTOTALSUM||'

					'||sPLAN1X1SUM||'
					'||sPLAN1X2SUM||'
                    '||sPLAN1COL||'
					'||sPLAN1TOTALSUM||'

					'||sPLAN2X1SUM||'
					'||sPLAN2X2SUM||'
                    '||sPLAN2COL||'
					'||sPLAN2TOTALSUM||'

					'||sPLAN3X1SUM||'
					'||sPLAN3X2SUM||'
                    '||sPLAN3COLSUM||'
					'||sPLAN3TOTALSUM||'

					'||sDELROW||'
			    </tr>');
            nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;
        else
            EXIT;
        end if;

    end loop;

    if nvl(nCOUNTROWS,0) > 500 then
		sColor := 'font-weight:regular;color:red';
		sMSG := 'Выбрано слишком много записей. Используйте фильтры.';
	else
		sColor := '';
		sMSG := 'Всего записей: ' || nCOUNTROWS;
	end if;

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;'||sColor||'"><b>'||sMSG||'</b></li>');
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

		function save_data(rn, val, field, obj) {
		  console.log(obj)

		  apex.server.process("save_data", {
				  x01: rn,
				  x02: val,
				  x03: field
			  }, {
				  //refreshObject: "#result",
				 // loadingIndicator: "#save_data",
				  success: function(data) {
					 if (data.status === ''good'') {
						  $(obj).css(''border-bottom'', ''1px solid green'');
					  } else {
						  $(obj).css(''border-bottom'', ''1px solid red'');
					  }
					  console.log(data);
				  }
			  });

		}
    </script>');
end;
