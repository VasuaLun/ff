--101; 429;
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;
 pORGRN	       number         := nvl(:P1_ORGRN,:P7_ORGFILTER);
 nSUMMA		   number;

 -----------------------------------------------
 sREDACTION    varchar2(4000);
 sFUNDS        varchar2(4000);
 sKBK          varchar2(4000);
 sEXPMAT       varchar2(4000);
 sKOSGUCODE    varchar2(4000);
 sSERVREG      varchar2(4000);
 sTYPE         varchar2(4000);
 sDIFF         varchar2(4000);
 sSUMMDIFF     varchar2(4000);
 sBEFORESUM    varchar2(4000);
 sDATE         varchar2(4000);
 sREASON       varchar2(4000);
 -----------------------------------------------
 nCOUNTROWS    number;
 nCOUNTRES     number;
 nTOTALSUM     number;
 nITEMROW      number;
 nPREVFOTYPE2  number;

 nRES          number;

 nSUMMADIF     number;
 nDIFF         number;
 nPRESUM       number;

 sColor        varchar2(100);
 sMSG	       varchar2(250);
begin
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
            display: block; /*height: 100px;*/ overflow-x: hidden;  overflow-y: scroll;
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
        .itogo {font-weight:bold; background-color:#d4d9f5 !important}
        '||case when nvl(nCOUNTRES,0) = 0 then '.show{display:none;}' end||'

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}


        .th1{width: 130px;text-align:center; border-left: 0px !important} .c1 {width: 130px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2 {width: 210px;text-align:center;} .c2  {width: 210px; word-wrap: break-word; text-align:left;}
        .th3 {width: 145px;text-align:center;} .c3  {width: 145px; word-wrap: break-word; text-align:right;}
        .th4 {width: 130px;text-align:center;} .c4  {width: 130px; word-wrap: break-word; text-align:left;}
        .th5 {width: 90px;text-align:center;}  .c5  {width: 90px; font-weight:bold; word-wrap: break-word; text-align:center;}
        .th6 {width: 100%;text-align:center;}  .c6  {width: 100%; word-wrap: break-word; text-align:left;}
        .th7 {width: 90px;text-align:center;}  .c7  {width: 90px; font-weight:bold; word-wrap: break-word; text-align:left;}
        .th8 {width: 110px;text-align:center;} .c8  {width: 110px; word-wrap: break-word; text-align:right;}
        .th9 {width: 110px;text-align:center;} .c9  {width: 110px; word-wrap: break-word; text-align:right;}
        .th10{width: 110px;text-align:center;} .c10 {width: 110px; word-wrap: break-word; text-align:right;}
        .th11{width: 50px;text-align:center;}  .c11 {width: 50px; word-wrap: break-word; text-align:center;}
        .th12{width: 180px;text-align:center;} .c12 {width: 180px; word-wrap: break-word; text-align:left;}

        .c71 {width: 90px; font-weight:bold; word-wrap: break-word; text-align:right;}

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
         <th class="header th1" ><div  class="th1">Редакция ПФХД</div></th>
         <th class="header th2" ><div  class="th2">Целевое средство</div></th>
         <th class="header th3" ><div  class="th3">КБК</div></th>
         <th class="header th4" ><div  class="th4">Статья затрат</div></th>
         <th class="header th5" ><div  class="th5">КОСГУ</div></th>
         <th class="header th6" ><div  class="th6">Услуга</div></th>
         <th class="header th7" ><div  class="th7">Тип</div></th>
         <th class="header th8" ><div  class="th8">Изменение, руб</div></th>
         <th class="header th9" ><div  class="th9">Сумма с учетом изменений, руб</div></th>
		 <th class="header th10" ><div class="th10">Предыдущая сумма, руб</div></th>
         <th class="header th11" ><div class="th11">Дата</div></th>
         <th class="header th12" ><div class="th12">Основание</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    begin
    select
        case :P429_PERIOD1 when 'NEXTPERIOD' then sum(nvl(H.ESUM, 0) - nvl(H.PREVSUM, 0))
                          when 'PLAN1' then sum(nvl(H.PLANSUM1, 0) - nvl(H.PREV_PLANSUM1, 0))
                          when 'PLAN2' then sum(nvl(H.PLANSUM2, 0) - nvl(H.PREV_PLANSUM2, 0)) end nDIFF,

        case :P429_PERIOD1 when 'NEXTPERIOD' then sum(nvl(H.ESUM, 0))
                          when 'PLAN1' then sum(nvl(H.PLANSUM1, 0))
                          when 'PLAN2' then sum(nvl(H.PLANSUM2, 0)) end ESUM,

        case :P429_PERIOD1 when 'NEXTPERIOD' then sum(nvl(H.PREVSUM, 0))
                          when 'PLAN1' then sum(nvl(H.PREV_PLANSUM1, 0))
                          when 'PLAN2' then sum(nvl(H.PREV_PLANSUM2, 0)) end PREVSUM
    into nDIFF, nSUMMADIF, nPRESUM
    from Z_EXP_HISTORY H, Z_ORGREG O, ZV_EXPSTRUCT_HIST A, Z_EXPMAT E, Z_KOSGU K, Z_PFHD_VERSIONS PV, Z_PFHD_BASIS FB, Z_SERVREG S, Z_FUNDS_KBK FK, Z_FUNDS F, zv_KBKALL KB
    where H.VERSION    = :P1_VERSION
      and A.NVERSION   = :P1_VERSION
      and H.PARENT_ROW = A.NRN
      and H.VERSION    = A.NVERSION
      and H.JUR_PERS   = A.NJURPERS
      and H.ORGRN     = O.RN
      and A.NEXPMAT = E.RN
      and E.KOSGURN = K.RN
      and H.PFHD_VERSION_RN = PV.RN
      and H.PFHD_BASIS_RN = FB.RN
      and A.NSERVRN   = S.RN(+)
      and A.NFUNDKBK  = FK.RN(+)
      and FK.PRN = F.RN (+)
      and FK.KBK_RN = KB.NKBK_RN (+)
      and ((:P429_PFHD_VERS is null) or (H.PFHD_VERSION_RN = :P429_PFHD_VERS))
      and ((:P429_FOTYPE is null) or (E.FOTYPE2 = :P429_FOTYPE))
      and (H.ORGRN = nvl(:P1_ORGRN,:P7_ORGFILTER))
      and ((H.HDATE >= :P429_DFROM) or (:P429_DFROM is null))
      and ((H.HDATE <= :P429_DTO) or (:P429_DTO is null))
      and ((KB.SCODE LIKE '%'||:P429_KBK||'%') or (KB.SCODE is null))
      and ((E.CODE LIKE '%'||:P429_KOSGU||'%') or (K.CODE LIKE '%'||:P429_KOSGU||'%') or (H.NOTES LIKE '%'||:P429_KOSGU||'%'));
    exception when others then
        nDIFF := 0;
        nSUMMADIF := 0;
        nPRESUM := 0;
    end;

    sREDACTION := '<td class="c1  itogo"><div  class="c1"></div></td>';
    sFUNDS     := '<td class="c2  itogo"><div  class="c2"></div></td>';
    sKBK       := '<td class="c3  itogo"><div  class="c3"></div></td>';
    sEXPMAT    := '<td class="c4  itogo"><div  class="c4"></div></td>';
    sKOSGUCODE := '<td class="c5  itogo"><div  class="c5"></div></td>';
    sSERVREG   := '<td class="c6  itogo"><div  class="c6"></div></td>';
    sTYPE      := '<td class="c71  itogo"><div  class="c71">Итого:</div></td>';
    sDIFF      := '<td class="c8  itogo"><div  class="c8">'||to_char(nvl(nDIFF, 0),'999G999G999G999G990D00')||'</div></td>';
    sSUMMDIFF  := '<td class="c9  itogo"><div  class="c9">'||to_char(nvl(nSUMMADIF, 0),'999G999G999G999G990D00')||'</div></td>';
    sBEFORESUM := '<td class="c10 itogo"><div class="c10">'||to_char(nvl(nPRESUM, 0),'999G999G999G999G990D00')||'</div></td>';
    sDATE      := '<td class="c11 itogo"><div class="c11"></div></td>';
    sREASON    := '<td class="c12 itogo"><div class="c12"></div></td>';

    htp.p('
        <tr>
            '||sREDACTION||'
            '||sFUNDS||'
            '||sKBK||'
            '||sEXPMAT||'
            '||sKOSGUCODE||'
            '||sSERVREG||'
            '||sTYPE||'
            '||sDIFF||'
            '||sSUMMDIFF||'
            '||sBEFORESUM||'
            '||sDATE||'
            '||sREASON||'
       </tr>');

	for rec in (
        select
          O.CODE sORGCODE,
          H.HDATE,
          case when H.ETYPE = 'REST' then 'Остаток' when H.ETYPE = 'PLAN' then 'Затраты ПЛАН' end sTYPE,
          case :P429_PERIOD1 when 'NEXTPERIOD' then (H.ESUM - H.PREVSUM)
        		 		    when 'PLAN1' then (H.PLANSUM1 - H.PREV_PLANSUM1)
        		 		    when 'PLAN2' then (H.PLANSUM2 - H.PREV_PLANSUM2) end nDIFF,

          case :P429_PERIOD1 when 'NEXTPERIOD' then H.ESUM
        					when 'PLAN1' then H.PLANSUM1
        					when 'PLAN2' then H.PLANSUM2 end ESUM,

          case :P429_PERIOD1 when 'NEXTPERIOD' then H.PREVSUM
        				    when 'PLAN1' then H.PREV_PLANSUM1
        					when 'PLAN2' then H.PREV_PLANSUM2 end PREVSUM,
          E.CODE sEXPMAT,
          case when E.KOSGU is not null then K.CODE||'.'||E.KOSGU else K.CODE end sKOSGU,
          S.CODE sSERVCODE,
          F.NAME sFUNDNAME,
          KB.SCODE sKBK,
          'Ред.№: <span style="font-weight: bold;color:#800000">'||PV.NUMB||'</span>'||case when PV.ARC_SIGN is not null then 'apx' end ||' от <span style="font-weight: bold;color:#800000">'||to_char(PV.VERS_DATE,'dd.mm.yy')||'</span>' sPFHD_VERS,
          FB.CODE||' '||H.NOTES sBASIS
        from Z_EXP_HISTORY H, Z_ORGREG O, ZV_EXPSTRUCT_HIST A, Z_EXPMAT E, Z_KOSGU K, Z_PFHD_VERSIONS PV, Z_PFHD_BASIS FB, Z_SERVREG S, Z_FUNDS_KBK FK, Z_FUNDS F, zv_KBKALL KB
        where H.VERSION    = :P1_VERSION
          and A.NVERSION   = :P1_VERSION
          and H.PARENT_ROW = A.NRN
          and H.VERSION    = A.NVERSION
          and H.JUR_PERS   = A.NJURPERS
          and H.ORGRN     = O.RN
          and A.NEXPMAT = E.RN
          and E.KOSGURN = K.RN
          and H.PFHD_VERSION_RN = PV.RN
          and H.PFHD_BASIS_RN = FB.RN
          and A.NSERVRN   = S.RN(+)
          and A.NFUNDKBK  = FK.RN(+)
          and FK.PRN = F.RN (+)
          and FK.KBK_RN = KB.NKBK_RN (+)
          and ((:P429_PFHD_VERS is null) or (H.PFHD_VERSION_RN = :P429_PFHD_VERS))
          and ((:P429_FOTYPE is null) or (E.FOTYPE2 = :P429_FOTYPE))
          and (H.ORGRN = nvl(:P1_ORGRN,:P7_ORGFILTER))
          and ((H.HDATE >= :P429_DFROM) or (:P429_DFROM is null))
          and ((H.HDATE <= :P429_DTO) or (:P429_DTO is null))
          and ((KB.SCODE LIKE '%'||:P429_KBK||'%') or (KB.SCODE is null))
          and ((E.CODE LIKE '%'||:P429_KOSGU||'%') or (K.CODE LIKE '%'||:P429_KOSGU||'%') or (H.NOTES LIKE '%'||:P429_KOSGU||'%'))
        order by H.HDATE desc, sEXPMAT, sFUNDNAME, sKBK
	)
	loop

        sREDACTION := '<td class="c1"><div  class="c1">'||rec.sPFHD_VERS||'</div></td>';
        sFUNDS     := '<td class="c2"><div  class="c2">'||rec.sFUNDNAME||'</div></td>';
        sKBK       := '<td class="c3"><div  class="c3">'||rec.sKBK||'</div></td>';
        sEXPMAT    := '<td class="c4"><div  class="c4">'||rec.sEXPMAT||'</div></td>';
        sKOSGUCODE := '<td class="c5"><div  class="c5">'||rec.sKOSGU||'</div></td>';
        sSERVREG   := '<td class="c6"><div  class="c6">'||rec.sSERVCODE||'</div></td>';
        sTYPE      := '<td class="c7"><div  class="c7">'||rec.sTYPE||'</div></td>';
        sDIFF      := '<td class="c8"><div  class="c8">'||to_char(nvl(rec.nDIFF, 0),'999G999G999G999G990D00')||'</div></td>';
        sSUMMDIFF  := '<td class="c9"><div  class="c9">'||to_char(nvl(rec.ESUM, 0),'999G999G999G999G990D00')||'</div></td>';
        sBEFORESUM := '<td class="c10"><div class="c10">'||to_char(nvl(rec.PREVSUM, 0),'999G999G999G999G990D00')||'</div></td>';
        sDATE      := '<td class="c11"><div class="c11">'||rec.HDATE||'</div></td>';
        sREASON    := '<td class="c12"><div class="c12">'||rec.sBASIS||'</div></td>';

		if nvl(nCOUNTROWS,0) <= 1500 then
			htp.p('
				<tr>
					'||sREDACTION||'
					'||sFUNDS||'
					'||sKBK||'
                    '||sEXPMAT||'
                    '||sKOSGUCODE||'
                    '||sSERVREG||'
					'||sTYPE||'
                    '||sDIFF||'
					'||sSUMMDIFF||'
                    '||sBEFORESUM||'
                    '||sDATE||'
                    '||sREASON||'
			   </tr>');
			nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;
		else
			EXIT;
		end if;
	end loop;

    if nvl(nCOUNTROWS,0) > 1500 then
		sColor := 'font-weight:regular;color:red';
		sMSG := 'Выбрано слишком много записей. Отображены первые 1500. Необходимо использовать фильтры.';
	else
		sColor := '';
		sMSG := 'Всего записей: ' || nCOUNTROWS;
	end if;

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;'||sColor||'">'||sMSG|| '</li>');
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
          table_body.height("550px");
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

        var el = document.getElementById("row_"+$v("P1577_SELECTED_ROW"));
		if (el!==null){
		 el.scrollIntoView(true);
		  $(el).children().css("background-color","yellow");
		}

    </script>');
end;
