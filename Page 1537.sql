--101; 1537;
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;
 pORGRN	       number         := nvl(:P1537_ORGRN,nvl(:P1_ORGRN,:P7_ORGFILTER));
 pSERVRN       number         := :P1537_SERVRN;
 pPERIOD       varchar2(4000) := nvl(:P1537_PERIOD,'NEXTPERIOD');
 -----------------------------------------------
 sUNRZ         varchar2(4000);
 sSERVCODE     varchar2(4000);
 sEXPGROUP     varchar2(4000);
 sACCEPT_NORM  varchar2(4000);
 sREG_COEFF    varchar2(4000);
 sALIG_COEFF   varchar2(4000);
 sCORRCOEF     varchar2(4000);
 sLIMSUM       varchar2(4000);
 sEXPSUM       varchar2(4000);
 sDIFF         varchar2(4000);
 sVALSUM       varchar2(4000);
 -----------------------------------------------
 nCOUNTROWS    number;
 nCOUNTRES     number;
 nTOTALSUM     number;
 nEXPSUM       number;
 nDIFF         number;
 nVALSUM       number;

 nTOTALSUM_TOT number;
 nEXPSUM_TOT   number;
 nDIFF_TOT     number;

 nITEMROW      number;
 nPREVFOTYPE2  number;

 nRES          number;

 sColor        varchar2(100);
 sMSG	       varchar2(250);
begin

    nVALSUM  := Z_GETSERVCOUNT3(pSERVRN, pORGRN, case pPERIOD when 'NEXTPERIOD' then 3
                                                              when 'PLAN1'      then 4
                                                              when 'PLAN2'      then 5 end);

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


        .th1{width: 160px;text-align:center; border-left: 0px !important} .c1 {width: 160px; word-wrap: break-word; text-align:left; border-left: 0px !important}
        .th2{width: 100%;text-align:center;}   .c2 {width: 100%; word-wrap: break-word; text-align:left;}
        .th3{width: 100px;text-align:center;}  .c3 {width: 100px; word-wrap: break-word; text-align:center;}
        .th4{width: 100px;text-align:center;}  .c4 {width: 100px; word-wrap: break-word; text-align:right;}
        .th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:right;}
        .th6{width: 120px;text-align:center;}  .c6 {width: 120px; word-wrap: break-word; text-align:right;}
        .th7{width: 100px;text-align:center;}  .c7 {width: 100px; word-wrap: break-word; text-align:right;}
        .th8{width: 100px;text-align:center;}  .c8 {width: 100px; word-wrap: break-word; text-align:right;}
        .th9{width: 100px;text-align:center;}  .c9 {width: 100px; word-wrap: break-word; text-align:right;}
        .th10{width: 100px;text-align:center;} .c10 {width: 100px; word-wrap: break-word; text-align:right;}
        .th11{width: 100px;text-align:center;} .c11 {width: 100px; word-wrap: break-word; text-align:right;}
        .c2_r{width: 100%; word-wrap: break-word; text-align:right;}

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
         <th class="header th1" ><div class="th1">УНРЗ</div></th>
         <th class="header th2" ><div class="th2">Наименование услуги</div></th>
         <th class="header th3" ><div class="th3">Группа<br>затрат</div></th>
         <th class="header th4" ><div class="th4">Базовый норматив</div></th>
         <th class="header th5" ><div class="th5">Отраслевой<br>коэффициент</div></th>
         <th class="header th6" ><div class="th6">Территориальный<br>коэффициент</div></th>
         <th class="header th7" ><div class="th7">Коэффициент<br>выравнивания</div></th>
         <th class="header th8" ><div class="th8">Показатель<br>объема</div></th>
         <th class="header th9" ><div class="th9">Итого лимит</div></th>
         <th class="header th10"><div class="th10">Итого затрат</div></th>
         <th class="header th11"><div class="th11">Отклонение</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
      <tbody id="fullall" >
  	    <tr>
  		 <th class="header th2" ><div class="c2_r">Всего</div></th>
  		 <th class="header th9" ><div id ="alllimmsum" class="c9"></div></th>
  		 <th class="header th10" ><div id ="allplansum" class="c10"></div></th>
  		 <th class="header th11" ><div id ="alldiffsum" class="c11"></div></th>
          </tr>');

	for rec in (
        select SR.CODE SRCODE, SR.UNIQREGNUM_FULL UNIQREGNUM, EG.CODE EXPGROUP, EG.RN EG,
            case pPERIOD when 'NEXTPERIOD' then nvl(SN.ACCEPT_NORM, 0)
                         when 'PLAN1'      then nvl(SN.ACCEPT_NORM2, 0)
                         when 'PLAN2'      then nvl(SN.ACCEPT_NORM3, 0) end ACCEPT_NORM,
            case pPERIOD when 'NEXTPERIOD' then nvl(SN.CORRCOEF, 1)
                         when 'PLAN1'      then nvl(SN.CORRCOEF2, 1)
                         when 'PLAN2'      then nvl(SN.CORRCOEF3, 1) end CORRCOEF,
            nvl(SN.ALIG_COEFF, 1) ALIG_COEFF, nvl(SN.REG_COEFF, 1) REG_COEFF
        from Z_SERVLINKS SL, Z_SERVREG SR, Z_SERVLINKS_NORM SN, Z_EXPGROUP EG
        where SL.SERVRN = SR.RN
            and SR.VERSION = pVERSION
            and SR.JUR_PERS = pJURPERS
            -- and sr.rn = 352283440
            -- and SL.ORGRN = 349248734
            and SR.RN = pSERVRN
            and SL.ORGRN = pORGRN
            and SN.LINKRN = SL.RN
            and SN.SERVRN = SR.RN
            and EG.RN = SN.EXPGROUP
	)
	loop

        nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

        select case pPERIOD when 'NEXTPERIOD' then sum(EL.SERVSUM)
                            when 'PLAN1'      then sum(EL.SERVSUM_2)
                            when 'PLAN2'      then sum(EL.SERVSUM_3) end SERVSUM
        into nEXPSUM
        from Z_EXPALL EL, Z_EXPMAT E
        where EL.VERSION = pVERSION
            and EL.JUR_PERS = pJURPERS
            -- and EL.SERVRN = 352283440
            -- and EL.ORGRN = 349248734
            and EL.SERVRN = pSERVRN
            and EL.ORGRN = pORGRN
            and E.RN = EL.EXP_ARTICLE
            and EL.VNEBUDG_SIGN = 0
            and E.EXPGROUP = rec.EG;

        nTOTALSUM := rec.ACCEPT_NORM * rec.ALIG_COEFF * rec.REG_COEFF * rec.CORRCOEF * nVALSUM;
        nDIFF := nTOTALSUM - nEXPSUM;

        sUNRZ        := '<td class="c1"><div  class="c1">' ||rec.UNIQREGNUM||'</div></td>';
        sSERVCODE    := '<td class="c2"><div  class="c2">' ||rec.SRCODE||'</div></td>';
        sEXPGROUP    := '<td class="c3"><div  class="c3">' ||rec.EXPGROUP||'</div></td>';
        sACCEPT_NORM := '<td class="c4"><div  class="c4">' ||LTRIM(to_char(nvl(rec.ACCEPT_NORM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        sREG_COEFF   := '<td class="c5"><div  class="c5">' ||LTRIM(to_char(nvl(rec.ALIG_COEFF,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        sALIG_COEFF  := '<td class="c6"><div  class="c6">' ||LTRIM(to_char(nvl(rec.REG_COEFF,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        sCORRCOEF    := '<td class="c7"><div  class="c7">' ||LTRIM(to_char(nvl(rec.CORRCOEF,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        sVALSUM      := '<td class="c8"><div  class="c7">' ||LTRIM(to_char(nvl(nVALSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        sLIMSUM      := '<td class="c9"><div  class="c8">' ||LTRIM(to_char(nvl(nTOTALSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        sEXPSUM      := '<td class="c10"><div  class="c9">' ||LTRIM(to_char(nvl(nEXPSUM,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';
        sDIFF        := '<td class="c11"><div class="c10">'||LTRIM(to_char(nvl(nDIFF,0),'999G999G999G999G999G990D00'),' ')||'</div></td>';

        nTOTALSUM_TOT := nvl(nTOTALSUM_TOT, 0) + nvl(nTOTALSUM, 0);
        nEXPSUM_TOT   := nvl(nEXPSUM_TOT,   0) + nvl(nEXPSUM, 0);
        nDIFF_TOT     := nvl(nTOTALSUM_TOT, 0) - nvl(nEXPSUM_TOT, 0);

		htp.p('
			<tr>
				'||sUNRZ||'
                '||sSERVCODE||'
				'||sEXPGROUP||'
                '||sACCEPT_NORM||'
                '||sREG_COEFF||'
                '||sALIG_COEFF||'
                '||sCORRCOEF||'
                '||sVALSUM||'
                '||sLIMSUM||'
                '||sEXPSUM||'
                '||sDIFF||'
		   </tr>');
	end loop;

	sMSG := 'Всего записей: ' || nCOUNTROWS;

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right">'||sMSG|| '</li>');
    htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
    htp.p('<li style="float:left; " id="save_shtat"></li>');
    htp.p('<li style="clear:both"></li></ul>');
    htp.p(
    '<script>

        $(function(){

          $("#alllimmsum").text("'||to_char(nTOTALSUM_TOT,'999G999G999G999G999G990D00')||'");
          $("#allplansum").text("'||to_char(nEXPSUM_TOT,'999G999G999G999G999G990D00')||'");
          $("#alldiffsum").text("'||to_char(nDIFF_TOT,'999G999G999G999G999G990D00')||'");

          table_body=$("#fullall");


          if (window.screen.height<=1024) {
          table_body.height("350px");
          $(".report_standard").css("width","100%");
          } else {
          table_body.height("650px");
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
