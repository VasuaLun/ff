--101; 1510;
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;
 pORGRN	       number         := nvl(:P1_ORGRN,:P7_ORGFILTER);
 pPRN          number;--         := 341935910;
 pJUR_SEL      number         := :P1510_JUR;
 pREP_SEL      number         := :P1510_REP;
 -- pDET_SELT     varchar2(200)  := :P1510_DET;
 pDET_SEL      varchar2(200)  := :P1510_DET;
 pOLD_YEAR     varchar2(200)  := :P1510_OLD_YEAR;
 pNEW_YEAR     varchar2(200)  := :P1510_NEW_YEAR;

 vREP_NOTE	   varchar2(4000);
 vPARAMS	   varchar2(4000);
 vPROC_NAME    varchar2(4000);
 vVERSION      varchar2(4000);
 nRN           number;
 nVDKCOUNT     number;

 -----------------------------------------------
 sNUMB         varchar2(4000);
 sLIB          varchar2(4000);
 sPROCNAME     varchar2(4000);
 sJURPERS      varchar2(4000);
 sVERSION      varchar2(4000);
 sVDK          varchar2(4000);
 sPARAMS       varchar2(4000);

 sREP_SEL      varchar2(32767);
 sDET_SEL      varchar2(32767);
 sJUR_SEL      varchar2(32767);

 -----------------------------------------------
 nCOUNTROWS    number;
 nCOUNTRES     number;
 nTOTALSUM     number;
 nITEMROW      number;
 nPREVFOTYPE2  number;
 nNUMB         number;

 nRES          number;

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


        .th1{width: 50px;text-align:center; border-left: 0px !important} .c1 {width: 50px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 150px;text-align:center;} .c2 {width: 150px; word-wrap: break-word; text-align:left;}
        .th3{width: 100%;text-align:center;}  .c3 {width: 100%; word-wrap: break-word; text-align:left;}
        .th4{width: 200px;text-align:center;} .c4 {width: 200px; word-wrap: break-word; text-align:left;}
        .th5{width: 100px;text-align:center;} .c5 {width: 100px; word-wrap: break-word; text-align:center;}
        .th6{width: 50px;text-align:center;}  .c6 {width: 50px; word-wrap: break-word; text-align:center;}
        .th7{width: 90px;text-align:center;}  .c7 {width: 90px; word-wrap: break-word; text-align:center;}

        .th8{width: 130px;text-align:center;} .c8 {width: 130px; word-wrap: break-word; text-align:right;}
        .th9{width: 30px;text-align:center;}   .c9 {width: 30px; word-wrap: break-word; text-align:center;}


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

    sREP_SEL := '<select onchange="apex.submit({request:this.value,set:{''P1510_REP'':this.value}});" style="float:right; margin-right:5px; width:200px">';
    for REP in(
        select '<Не выбрано>' NAME, null RN from dual
        union all
        select REP_NOTE NAME, NUMB RN
        from Z_RPT_LIB
        where REP_NOTE like '%'||v('P1510_OLD_YEAR')||'%'
        order by NAME
    )
    loop
        sREP_SEL := sREP_SEL || '<option value="'||REP.RN||'"'||case when REP.RN = pREP_SEL or (pREP_SEL is null and REP.RN is null) then 'selected="selected"' end||'>'||REP.NAME||'</option>';
    end loop;
    sREP_SEL := sREP_SEL || '</select>';

    sDET_SEL := '<select onchange="apex.submit({request:this.value,set:{''P1510_DET'':this.value}});" style="float:right; margin-right:5px; width:200px">';
    for DET in(
        select '<Все>' NAME, null RN from dual
        union all
        select distinct PROC_NAME NAME , PROC_NAME
        from Z_RPT_LIB_DETAIL
        where PRN = :P1510_REP
        order by NAME desc
    )
    loop
        sDET_SEL := sDET_SEL || '<option value="'||DET.RN||'"'||case when DET.RN = pDET_SEL or (pDET_SEL is null and DET.RN is null) then 'selected="selected"' end||'>'||DET.NAME||'</option>';
    end loop;
    sDET_SEL := sDET_SEL || '</select>';

    sJUR_SEL := '<select onchange="apex.submit({request:this.value,set:{''P1510_JUR'':this.value}});" style="float:right; margin-right:5px; width:200px">';
    for JUR in(
        select '<Все>' NAME, null RN from dual
        union all
        select J.NAME NAME, J.RN RN
        from Z_RPT_LIB_DETAIL D, Z_JURPERS J
        where PROC_NAME = :P1510_DET
            and D.JURPERS = J.RN
            and :P1510_DET is not null
        order by NAME desc
    )
    loop
        sJUR_SEL := sJUR_SEL || '<option value="'||JUR.RN||'"'||case when (JUR.RN = pJUR_SEL or pJUR_SEL is null) then 'selected="selected"' end||'>'||JUR.NAME||'</option>';
    end loop;
    sJUR_SEL := sJUR_SEL || '</select>';

    htp.p(
    '<div style="background: whitesmoke;padding: 10px;border: 1px solid #ccc;"><div>
        '||sJUR_SEL||'
        '||sDET_SEL||'
        '||sREP_SEL||'
    </div>');

    htp.p('<div style="font-weight: bold;font-size: 14px;padding: 5px 3px;border-bottom: 1px solid #ccc;margin-bottom: 5px;">Состояние отчетов '||pNEW_YEAR||' года относительно '||pOLD_YEAR||' года</div>');

    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1" ><div class="th1">п/п</div></th>
         <th class="header th2" ><div class="th2">Отчет</div></th>
         <th class="header th3" ><div class="th3">Процедура</div></th>
         <th class="header th4" ><div class="th4">ГРБС</div></th>
         <th class="header th5" ><div class="th5">Версия</div></th>
         <th class="header th6" ><div class="th6">ВДК</div></th>
         <th class="header th7" ><div class="th7">Параметры</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    pPRN := pREP_SEL;

    if pPRN is not null then
        select replace(REP_NOTE, pOLD_YEAR, pNEW_YEAR), PARAMS
        into vREP_NOTE, vPARAMS
        from Z_RPT_LIB
        where numb = pPRN;

        begin
            select NUMB
            into nNUMB
            from Z_RPT_LIB
            where REP_NOTE = vREP_NOTE;
        exception when others then
            nNUMB := null;
        end;

        for PRO in (
            select D.PROC_NAME,
                D.VERSION,
                D.PARAMS,
                D.PRN,
                J.RN JURPERS,
                J.NAME JNAME,
                V.NAME VNAME,
                (select count(*) from Z_RPT_LIB_VDK_LINKS L where L.LIBDET_RN = D.RN)  VDK_COUNT
            from Z_RPT_LIB_DETAIL D, Z_JURPERS J, Z_VERSIONS V
            where D.PRN = pPRN
            and ((D.PROC_NAME like pDET_SEL) or (pDET_SEL is null))
                and D.JURPERS = J.RN (+)
                and D.VERSION = V.RN (+)
                and ((D.JURPERS = pJUR_SEL) or (pJUR_SEL is null))
        )
        loop
            nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

            if nNUMB is null then
                sColor := 'style="font-weight:regular;color:red"';
                sNUMB     := '<td class="c1"><div class="c1">'||nCOUNTROWS||'</div></td>';
                sLIB      := '<td class="c2"'||sColor||'><div class="c2">'||vREP_NOTE||'</div></td>';
                sPROCNAME := '<td class="c3"'||sColor||'><div class="c3">'||PRO.PROC_NAME||'</div></td>';
                sJURPERS  := '<td class="c4"'||sColor||'><div class="c4">'||PRO.JNAME||'</div></td>';
                sVERSION  := '<td class="c5"><div class="c5">'||PRO.VNAME||'</div></td>';
                sVDK      := '<td class="c6"'||sColor||'><div class="c6">'||case when PRO.VDK_COUNT > 0 then LTRIM(to_char(lpad(PRO.VDK_COUNT,3,0)),' ') else '---' end||'</div></td>';

                if PRO.PARAMS is not null then sPARAMS := 'Есть'; else sPARAMS := '-Нет-'; end if;
                sPARAMS   := '<td class="c7"'||sColor||'><div class="c7">'||sPARAMS||'</div></td>';
            else
                sColor := 'style="font-weight:regular;color:green"';

                begin
                    select D.RN, D.PROC_NAME, V.NAME, D.PARAMS,
                    (select count(*) from Z_RPT_LIB_VDK_LINKS L where L.LIBDET_RN = D.RN)  VDK_COUNT
                    into nRN, vPROC_NAME, vVERSION, vPARAMS, nVDKCOUNT
                    from Z_RPT_LIB_DETAIL D, Z_VERSIONS V
                    where D.PROC_NAME = replace(PRO.PROC_NAME, to_char(pOLD_YEAR), to_char(pNEW_YEAR))
                    and PRO.JURPERS = D.JURPERS
                    and D.PRN = nNUMB
                    and D.VERSION = V.RN(+);
                exception when others then
                    vPROC_NAME := NULL;
                    vVERSION   := NULL;
                    vPARAMS    := NULL;
                end;

                sNUMB     := '<td class="c1"><div class="c1">'||nCOUNTROWS||'</div></td>';
                sLIB      := '<td class="c2"'||sColor||'><div class="c2">'||vREP_NOTE||'</div></td>';

                if vPROC_NAME is NULL then
                    sColor := 'style="font-weight:regular;color:red"';
                    sPROCNAME := '<td class="c3"'||sColor||'><div class="c3">'||PRO.PROC_NAME||'</div></td>';
                    sVERSION  := '<td class="c5"><div class="c5">'||nvl(PRO.VNAME, '--')||'</div></td>';
                    sVDK      := '<td class="c6"'||sColor||'><div class="c6">'||case when PRO.VDK_COUNT > 0 then LTRIM(to_char(lpad(PRO.VDK_COUNT,3,0)),' ') else '---' end||'</div></td>';
                else
                    sPROCNAME := '<td class="c3"'||sColor||'><div class="c3">'||vPROC_NAME||'</div></td>';
                    sVERSION   := '<td class="c5"><div class="c5"><a href="javascript:modalWinVers('||nRN||','||PRO.JURPERS||');">'||nvl(vVERSION, '--')||'</a></div></td>';
                    sVDK := '<td class="c6"><div class="c6"><span><a href="javascript:modalWin('||nRN||');">'||case when nVDKCOUNT > 0 then LTRIM(to_char(lpad(nVDKCOUNT,3,0)),' ') else '---' end||'</a></span></div></td>';
                end if;

                sJURPERS  := '<td class="c4"><div class="c4">'||PRO.JNAME||'</div></td>';

                if vPARAMS is NULL and PRO.PARAMS is NULL and vPROC_NAME is not null then
                    sColor := 'style="font-weight:regular;color:green"';
                    sPARAMS   := '<td class="c7"'||sColor||'><div class="c7">NULL</div></td>';
                elsif vPARAMS is NULL then
                    sColor := 'style="font-weight:regular;color:red"';
                    sPARAMS   := '<td class="c7"'||sColor||'><div class="c7">NULL</div></td>';
                elsif vPARAMS != PRO.PARAMS then
                    sColor := 'style="font-weight:regular;color:red"';
                    sPARAMS   := '<td class="c7"'||sColor||'><div class="c7">неидентично</div></td>';
                else
                    sColor := 'style="font-weight:regular;color:green"';
                    sPARAMS   := '<td class="c7"'||sColor||'><div class="c7">идентично</div></td>';
                end if;
            end if;

    		htp.p('
    			<tr>
    				'||sNUMB||'
    				'||sLIB||'
    				'||sPROCNAME||'
                    '||sJURPERS||'
                    '||sVERSION||'
                    '||sVDK||'
                    '||sPARAMS||'
    		   </tr>');
        end loop;
    end if;
	sMSG := 'Всего записей: ' || nCOUNTROWS;

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
          table_body.height("450px");
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
