--101; 791; H_INCOME_PRILFORMS
declare
 pJURPERS    number         := :P1_JURPERS;
 pVERSION    number         := :P1_VERSION;
 pORGRN	     number         := nvl(:P1_ORGRN,:P7_ORGFILTER);
 pFILIAL     number         := nvl(:P1_ORGFL,:P0_FILIAL);

 pUSER       varchar2(100)  := :APP_USER;
 pROLE       number         := ZGET_ROLE;

 pINUMB      varchar2(4000) := :P791_INUMB;
 pSEARCH     varchar2(4000) := :P791_SEARCH;
 pPART       varchar2(4000) := :P791_PART;
 -----------------------------------------------
 sINUMB      varchar2(4000);
 sCODE       varchar2(4000);
 sFULLNAME   varchar2(4000);
 sKOSGU      varchar2(4000);
 sFOTYPE     varchar2(4000);
 sFILIAL     varchar2(4000);
 sNEXTSUM    varchar2(4000);
 sPLANSUM1   varchar2(4000);
 sPLANSUM2   varchar2(4000);
 sOTHERSUM   varchar2(4000);
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
begin
    -- Инициализация
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

	select sum(round(D.TOTAL,2)), sum(round(D.PLAN1_TOTAL,2)), sum(round(D.PLAN2_TOTAL,2)), sum(round(D.PLAN3_TOTAL,2))
      into nTOTAL, nTOTAL1, nTOTAL2, nTOTAL3
	  from H_INCOME_PRILFORMS D
	 where D.JURPERS  = pJURPERS
	   and D.VERSION  = pVERSION
       and D.ORGRN    = pORGRN
	   and ((pFILIAL is null) or (D.FILIAL   = pFILIAL))
	   and D.PART     = pPART
	   and ((pINUMB is null) or (D.INUMB = pINUMB))

       and (
	        (pSEARCH is null)
	         or
	        (
			  (Upper(D.NAME) like '%'||Upper(pSEARCH)||'%')
		      or (Upper(D.CODE) like '%'||Upper(pSEARCH)||'%')
		    )
		   );
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

        .th1{width: 50px;text-align:center; border-left: 0px !important} .c1 {width: 50px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 150px;text-align:center;}   .c2 {width: 150px; word-wrap: break-word; text-align:center;}
        .th3{width: 100%;text-align:center;}   .c3 {width: 100%; word-wrap: break-word; text-align:left;}
		.th4{width: 120px;text-align:center;}   .c4 {width: 120px; word-wrap: break-word; text-align:center;}

		.th5{width: 60px;text-align:center;}   .c5 {width: 60px; word-wrap: break-word; text-align:center;}
		.th6{width: 200px;text-align:center;}   .c6 {width: 200px; word-wrap: break-word; text-align:center;}

		.th7{width: 150px;text-align:center;}   .c7 {width: 150px; word-wrap: break-word; text-align:right;}
		.th8{width: 150px;text-align:center;}   .c8 {width: 150px; word-wrap: break-word; text-align:right;}
		.th9{width: 150px;text-align:center;}   .c9 {width: 150px; word-wrap: break-word; text-align:right;}
		.th10{width: 150px;text-align:center;}  .c10 {width: 150px; word-wrap: break-word; text-align:right;}

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
         <th class="header th1" rowspan="3" style="border-left:0px" ><div class="th1">Вн.№</div></th>
         <th class="header th2" rowspan="3" ><div class="th2">Код карточки</div></th>
         <th class="header th3" rowspan="3" ><div class="th3">Содержание</div></th>
		 <th class="header th4" rowspan="3" ><div class="th4">КОСГУ(Код строки)</div></th>
		 <th class="header th5" rowspan="3" ><div class="th5">Вид ФО</div></th>
		 <th class="header th6" rowspan="3" ><div class="th6">Филиал</div></th>

		 <th colspan="4"><div>Сумма, руб.</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>

        <tr>
		 <th class="header th7" ><div class="th7">'||nNEXTPERIOD||'</div></th>
		 <th class="header th8" ><div class="th8">'||nPLAN1||'</div></th>
		 <th class="header th9" ><div class="th9">'||nPLAN2||'</div></th>
		 <th class="header th10" ><div class="th10">За пределами</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>

        <tr>
		 <th class="header th7 group" ><div style="text-align:right" class="th7">'||LTRIM(to_char(nvl(nTOTAL,0),'999G999G999G999G999G990D00'),' ')||'</div></th>
		 <th class="header th8 group" ><div style="text-align:right" class="th8">'||LTRIM(to_char(nvl(nTOTAL1,0),'999G999G999G999G999G990D00'),' ')||'</div></th>
		 <th class="header th9 group" ><div style="text-align:right" class="th9">'||LTRIM(to_char(nvl(nTOTAL2,0),'999G999G999G999G999G990D00'),' ')||'</div></th>
		 <th class="header th10 group" ><div style="text-align:right" class="th10">'||LTRIM(to_char(nvl(nTOTAL3,0),'999G999G999G999G999G990D00'),' ')||'</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>

      </thead>

    <tbody id="fullall" >');

	for rec in
	(
      select t.RN,
             t.INUMB as INUMB,
      		 t.CODE as CODE,
             nvl(rtrim(t.NAME),'- нет -') as fullname,
			 D.NUMB sPFHD_CODE,
			 K.CODE KOSGU,
			 I.FOTYPE2 FOTYPE,
			 F.CODE FILIAL,
             t.TOTAL as NEXTSUM,
			 t.PLAN1_TOTAL as PLANSUM1,
			 t.PLAN2_TOTAL as PLANSUM2,
             t.PLAN3_TOTAL as OTHERSUM
        from H_INCOME_PRILFORMS t, Z_INCOME I, Z_INCOME_DETAIL ID, Z_ORGFL F, Z_CODESTR_PFHD D, Z_KOSGU K
        where T.JURPERS  = pJURPERS
		  and T.VERSION  = pVERSION
		  and T.ORGRN    = pORGRN
		  and ((pFILIAL is null) or (T.FILIAL   = pFILIAL))
		  and T.PART     = pPART

          and T.INCOME 	 = I.RN
		  and T.PART 	 = pPART
		  and I.CODEPFHD = D.RN
		  and I.KOSGU    = K.RN
		  and T.FILIAL   = F.RN
		  and T.INCOME_SUBTYPE = ID.RN(+)

		  and ((pINUMB is null) or (T.INUMB = pINUMB))

		  and (
	           (pSEARCH is null)
	            or
	           (
			     (Upper(T.NAME) like '%'||Upper(pSEARCH)||'%')
		         or (Upper(T.CODE) like '%'||Upper(pSEARCH)||'%')
		       )
		      )
		  --
		order by F.CODE, t.INUMB
	)
	loop
    	if nvl(nCOUNTROWS,0) <= 500 then

			sINUMB     := '<td class="c1"><div class="c1">'||rec.INUMB||'</></div></td>';
			sCODE      := '<td class="c2"><div class="c2">'||rec.CODE||'</></div></td>';
            sFULLNAME  := '<td class="c3"><div class="c3"><a href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':792:'||:APP_SESSION||'::::P792_RN:'||rec.RN)||'" class = "link_code">'||rec.FULLNAME||'</a></div></td>';
            if pPART = 10 then
                sFULLNAME  := '<td class="c3"><div class="c3"><a href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':793:'||:APP_SESSION||'::::P793_RN:'||rec.RN)||'" class = "link_code">'||rec.FULLNAME||'</a></div></td>';
                else
                sFULLNAME  := '<td class="c3"><div class="c3"><a href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':792:'||:APP_SESSION||'::::P792_RN:'||rec.RN)||'" class = "link_code">'||rec.FULLNAME||'</a></div></td>';
            end if;
			sKOSGU     := '<td class="c4"><div class="c4">'||rec.KOSGU||'</></div></td>';
			sFOTYPE    := '<td class="c5"><div class="c5">'||rec.FOTYPE||'</></div></td>';
			sFILIAL    := '<td class="c6"><div class="c6">'||rec.FILIAL||'</></div></td>';

			sNEXTSUM    := '<td class="c7"><div class="c7">'||LTRIM(to_char(nvl(rec.NEXTSUM,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
			sPLANSUM1   := '<td class="c8"><div class="c8">'||LTRIM(to_char(nvl(rec.PLANSUM1,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
			sPLANSUM2   := '<td class="c9"><div class="c9">'||LTRIM(to_char(nvl(rec.PLANSUM2,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
			sOTHERSUM   := '<td class="c10"><div class="c10">'||LTRIM(to_char(nvl(rec.OTHERSUM,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

            htp.p('
                <tr id="row_'||rec.RN||'" >
					'||sINUMB||'
					'||sCODE||'
					'||sFULLNAME||'
					'||sKOSGU||'
					'||sFOTYPE||'
					'||sFILIAL||'

					'||sNEXTSUM||'
					'||sPLANSUM1||'
					'||sPLANSUM2||'
					'||sOTHERSUM||'
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

		var el = document.getElementById("row_"+$v("P791_SELECTED_ROW"));
		if (el!==null){
		 el.scrollIntoView(true);
		  $(el).children().css("background-color","yellow");
		}
    </script>');
end;
