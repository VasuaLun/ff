--101; 537; Детализация затрат по услугам
declare
 pJURPERS      number        := :P1_JURPERS;
 pVERSION      number        := :P1_VERSION;
 pORGRN	       number        := nvl(:P537_ORGRN,nvl(:P1_ORGRN,:P7_ORGFILTER));
 pORGFL        number        := :P537_ORGFL;

 pUSER         varchar2(100) := :APP_USER;
 pPERIOD       varchar2(4000):= nvl(:P537_PERIOD,'NEXTPERIOD');
 pROLE         number        := ZGET_ROLE;
 -----------------------------------------------
 sSERVTYPE     varchar2(4000);
 sPERCFOT      varchar2(4000);
 sSERVCODE     varchar2(4000);
 sPLANSUM      varchar2(4000);
 sFACTSUM      varchar2(4000);
 sSUMBUDG      varchar2(4000);
 sDIFFSUM      varchar2(4000);
 sUNRZ         varchar2(4000);
 -----------------------------------------------
 sSTRBACK      varchar2(4000);
 sSTRNAMESTR   varchar2(4000);
 sPERIOD       varchar2(4000);
 sADDROW	   varchar2(4000);
 sCALCNORM 	   varchar2(4000);
 -----------------------------------------------
 nCOUNTROWS    number;
 nGORIZONT     Z_VERSIONS.GORIZONT%type;
 -----------------------------------------------
 nREPPERIOD    number;
 nCURPERIOD    number;
 nNEXTPERIOD   number;
 nPLAN1        number;
 nPLAN2        number;
 nITEMCOL      number;
 nPLANSUM      number;
 nFACTSUM      number;
 nFOTSUM       number;
 nVALSUM       number;
 nSUMBUDG      number;
 nFULLPLANSUM  number;
 nVOLUME  	   number;

 nALLPLANSUM      number;
 nALLFACTSUM      number;
 nALLDIFFSUM      number;
 nALLSUMBUDG      number;

 type CEXPGR is record
 (
   SERVRN  number,
   FOTSUM  number,
   PLANSUM number,
   FACTSUM number
 );

 type TEXPGR  is table of CEXPGR index by pls_integer;
 REXPGR       TEXPGR;

begin
	-- Инициализация
    --------------------------------------------
	for rec in
	(
    select E.EXPTYPE, EA.SERVRN, sum(EA.SERVSUM) ,
       case pPERIOD when 'NEXTPERIOD' then sum(nvl(EA.SERVSUM,0))
                       when 'MPLAN_02' then sum(nvl(EA.SERVSUM_0,0))
                       when 'MPLAN_01' then sum(nvl(EA.SERVSUM_1,0))
                       when 'PLAN1' then sum(nvl(EA.SERVSUM_2,0))
                       when 'PLAN2' then sum(nvl(EA.SERVSUM_3,0))
                       when 'PLAN3' then sum(nvl(EA.SERVSUM_4,0)) end PSUM,
    sum(FSERVSUM1)+sum(FSERVSUM2)+sum(FSERVSUM3)+sum(FSERVSUM4) FSUM
    from Z_EXPALL EA, Z_SERVREG SR, Z_EXPMAT E, Z_SERVLINKS SL
     where EA.SERVRN     = SR.RN
       and (nvl(EA.SERVSUM,0) > 0 or
            nvl(EA.SERVSUM_0,0) > 0 or
            nvl(EA.SERVSUM_1,0) > 0 or
            nvl(EA.SERVSUM_2,0) > 0 or
            nvl(EA.SERVSUM_3,0) > 0 or
            nvl(EA.SERVSUM_4,0) > 0)
       and SR.WORKSERV_SIGN in (1,3)
       and SR.PARENT_SIGN is null
       and EA.JUR_PERS = pJURPERS
       and EA.VERSION  = pVERSION
       and EA.ORGRN    = pORGRN
       and ((pORGFL is null) or (EA.FILIAL   = pORGFL))
       and EA.VNEBUDG_SIGN = 0
       and EA.EXP_ARTICLE = E.RN
       and SL.SERVRN = SR.RN
       and SL.ORGRN = pORGRN
       and (SL.NORM_EXPGTOUP is NULL or (SL.NORM_EXPGTOUP is not null and E.EXPGROUP is not null))
     group by E.EXPTYPE, EA.SERVRN
	)
	loop
	    nITEMCOL := nvl(nITEMCOL,0) + 1;
        if rec.EXPTYPE = 1 then REXPGR(nITEMCOL).FOTSUM := rec.PSUM; end if;
	    REXPGR(nITEMCOL).SERVRN := rec.SERVRN;
	    REXPGR(nITEMCOL).PLANSUM := rec.PSUM;
        REXPGR(nITEMCOL).FACTSUM := rec.FSUM;
        if rec.EXPTYPE = 1 then nFULLPLANSUM := nvl(nFULLPLANSUM,0) + nvl(rec.PSUM,0); end if;
	end loop;

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

        .th1{width: 65px;text-align:center; border-left: 0px !important}    .c1 {width: 65px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 100%;text-align:center;}    .c2 {width: 100%; word-wrap: break-word; text-align:left;}
        .th3{width: 120px;text-align:center;}   .c3 {width: 120px; word-wrap: break-word; text-align:right;}
		.th31{width: 120px;text-align:center;}   .c31 {width: 120px; word-wrap: break-word; text-align:right;}
		.th4{width: 120px;text-align:center;}   .c4 {width: 120px; word-wrap: break-word; text-align:right;}
		.th5{width: 120px;text-align:center;}   .c5 {width: 120px; word-wrap: break-word; text-align:right;}
        .th6{width: 120px;text-align:center;}   .c6 {width: 120px; word-wrap: break-word; text-align:right;}
        .th7{width: 120px;text-align:center;}   .c7 {width: 120px; word-wrap: break-word; text-align:right;}
        .th8{width: 180px;text-align:center;}   .c8 {width: 180px; word-wrap: break-word; text-align:center;}
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

	sPERIOD := '<select onchange="apex.submit({request:this.value,set:{''P537_PERIOD'':this.value}});" style="float:right; margin-right:5px">
				  '||case when nGORIZONT = 2 then '<option value="MPLAN_02"'||case when pPERIOD ='MPLAN_02' then 'selected="selected"' end||'>План -2 год</option>' end||'
				  '||case when nGORIZONT = 2 then '<option value="MPLAN_01"'||case when pPERIOD ='MPLAN_01' then 'selected="selected"' end||'>План -1 год</option>' end||'
				  <option value="NEXTPERIOD"'||case when pPERIOD ='NEXTPERIOD' then 'selected="selected"' end||'>Очередной год</option>
				  <option value="PLAN1"'||case when pPERIOD ='PLAN1' then 'selected="selected"' end||'>План 1 года</option>
				  <option value="PLAN2"'||case when pPERIOD ='PLAN2' then 'selected="selected"' end||'>План 2 года</option>
				  <option value="PLAN3"'||case when pPERIOD ='PLAN3' then 'selected="selected"' end||'>За пределами</option>
			  </select>';


    sSTRBACK    := '<span class="btn" style="float:right; margin-right:5px" onclick="location.href='''||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':34:'||:APP_SESSION)||'''">Назад</span>';
    sSTRNAMESTR  := '<div style="font-weight: bold;font-size: 14px;padding: 5px 3px;border-bottom: 1px solid #ccc;margin-bottom: 5px;">Детализация затрат по услугам</div>';


    htp.p(
    '<div style="background: whitesmoke;padding: 10px;border: 1px solid #ccc;"><div>
        '||sSTRBACK||'
		'||sADDROW||'
		'||sPERIOD||'
        '||sSTRNAMESTR ||'
    </div>');

    -- Диалоговые окна
	htp.p('<div id="detorg" title="Доходы"></div>');

    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1"><div class="th1">Тип</div></th>
         <th class="header th8"><div class="th8">УНРЗ</div></th>
         <th class="header th2"><div class="th2">Услуга</div></th>
         <th class="header th3"><div class="th3">%</div></th>
		 <th class="header th31"><div class="th31">Расчетный норматив, руб.</div></th>
		 <th class="header th4"><div class="th4">Плановые затраты, руб.</div></th>
		 <th class="header th5"><div class="th5">Фактические затраты, руб.</div></th>
         <th class="header th6"><div class="th6">Лимит фин. обеспечения</div></th>
         <th class="header th7"><div class="th7">Отклонение</div></th>
         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >
	    <tr>
		 <th class="header th2" ><div class="c2_r">Всего</div></th>
		 <th class="header th4" ><div id ="allplansum" class="c4"></div></th>
		 <th class="header th5" ><div id ="allfactsum" class="c5"></div></th>
		 <th class="header th6" ><div id ="allsumbudg" class="c6"></div></th>
		 <th class="header th7" ><div id ="alldiffsum" class="c7"></div></th>
        </tr>');

	for rec in
	(
    select SL.SERVRN, L.NOTE SERTYPE, SR.CODE SRCODE,
           SL.ACCEPT_NORM, SL.CORRCOEF, SL.REG_COEFF, SL.NORM_EXPGTOUP,
           case pPERIOD when 'NEXTPERIOD' then SL.ALIG_COEFF
                        when 'PLAN1' then SL.ALIG_COEFF_2
                        when 'PLAN2' then SL.ALIG_COEFF_3
                        when 'PLAN3' then SL.ALIG_COEFF end ALIG_COEFF,
          SR.UNIQREGNUM_FULL
      from Z_SERVLINKS SL, Z_SERVREG SR, Z_LOV L
     where SL.SERVRN   = SR.RN
       and SL.JUR_PERS = pJURPERS
       and SL.VERSION  = pVERSION
       and SL.ORGRN    = pORGRN
       and SR.WORKSERV_SIGN in (1,3)
       and SR.PARENT_SIGN is null
       and SR.WORKSERV_SIGN = L.NUM (+)
       and L.PART (+) = 'SERVTYPE'
	)
	loop
		nVALSUM  := null;
		nSUMBUDG := null;
        nFOTSUM  := null;
		if  REXPGR.COUNT > 0 then
			nPLANSUM := null;
            nFACTSUM := null;
			for I in REXPGR.first..REXPGR.last
			loop
				if REXPGR(I).SERVRN = rec.SERVRN then
                    nFOTSUM  := nvl(nFOTSUM,0) + nvl(REXPGR(I).FOTSUM,0);
					nPLANSUM := nvl(nPLANSUM,0) + nvl(REXPGR(I).PLANSUM,0);
                    nFACTSUM := nvl(nFACTSUM,0) + nvl(REXPGR(I).FACTSUM,0);
				end if;
			end loop;
		end if;

		for qv in
		(
		select QL.NQINDRN
           from ZV_SERVIND SI, ZV_QINDLIST QL
          where SI.NQINDRN = QL.NQINDRN
            and SI.NSERVRN = rec.SERVRN
            and QL.NQINDSIGN = 2
			and rownum = 1
		)
		loop
			nVOLUME := nvl(Z_GETINDVAL( qv.NQINDRN, pORGRN, rec.SERVRN, null),0);
		end loop;


		nVALSUM  := Z_GETSERVCOUNT3(rec.SERVRN, pORGRN, case pPERIOD when 'NEXTPERIOD' then 3
                                                                 when 'PLAN1' then 4
                                                                 when 'PLAN2' then 5 end);
        -- Если просчет по группам затрат, перенести в запрос rec
        if rec.NORM_EXPGTOUP is null then
    		nSUMBUDG := nvl(nVALSUM,0) * nvl(rec.ACCEPT_NORM,0) * nvl(rec.CORRCOEF,1) * nvl(rec.REG_COEFF,1) * nvl(rec.ALIG_COEFF,1);
        else
            for QEXP in
            (
            select case pPERIOD when 'NEXTPERIOD' then nvl(ACCEPT_NORM, 0)  * nvl(CORRCOEF, 1)
                                when 'PLAN1'      then nvl(ACCEPT_NORM2, 0) * nvl(CORRCOEF2, 1)
                                when 'PLAN2'      then nvl(ACCEPT_NORM3, 0) * nvl(CORRCOEF3, 1) end * nvl(ALIG_COEFF, 1) * nvl(REG_COEFF, 1) as SUMMA
            from Z_SERVLINKS_NORM
            where ORGRN = pORGRN
              and SERVRN = rec.SERVRN
              and VERSION = pVERSION
            )
            loop
                -- nSUMBUDG := nvl(nSUMBUDG,0) + round(nvl(QEXP.SUMMA,0), 2);
                nSUMBUDG := nvl(nSUMBUDG,0) + nvl(QEXP.SUMMA,0);
            end loop;

            -- nSUMBUDG := round(nvl(nSUMBUDG, 0), 2) * nvl(nVALSUM,0);
            nSUMBUDG := nvl(nSUMBUDG, 0) * nvl(nVALSUM,0);
        end if;

		nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

		sSERVTYPE  := '<td class="c1"><div class="c1">'||rec.SERTYPE||'</></div></td>';
		sSERVCODE  := '<td class="c2"><div class="c2">'||rec.SRCODE||'</></div></td>';


        sPERCFOT  := '<td class="c3"><div class="c3">'||LTRIM(to_char(nvl(case when nvl(nFULLPLANSUM,0) > 0 then (nFOTSUM/nFULLPLANSUM)*100 else null end,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
		sCALCNORM  := '<td class="c31"><div class="c31">'||nvl(case when nvl(nPLANSUM,0) != 0 and nvl(nVOLUME,0) != 0 then LTRIM(to_char(nPLANSUM/nVOLUME,'999G999G999G999G999G990D00'),' ') end, '-')||'</></div></td>';

		sPLANSUM   := '<td class="c4"><div class="c4">'||LTRIM(to_char(nvl(nPLANSUM,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
		sFACTSUM    := '<td class="c5"><div class="c5">'||LTRIM(to_char(nvl(nFACTSUM,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

        if rec.NORM_EXPGTOUP is null then
            sSUMBUDG   := '<td class="c6"><div class="c6"><span class="link_code" onclick="ShowDialog2(''detorg'','||pORGRN||','||rec.SERVRN||','''||pPERIOD||''');">'||case when rec.ACCEPT_NORM is not null then LTRIM(to_char(nSUMBUDG,'999G999G999G999G999G990D00'),' ') else '-Нет-' end||'</span></></div></td>';
        else
            -- sSUMBUDG   := '<td class="c6"><div class="c6">'||LTRIM(to_char(nvl(nSUMBUDG,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
            sSUMBUDG   := '<td class="c6"><div class="c6"><a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':1537:'||:APP_SESSION||'::::P1537_ORGRN,P1537_SERVRN,P1537_PERIOD:'||pORGRN||','||rec.SERVRN||','||pPERIOD)||'">'||LTRIM(to_char(nvl(nSUMBUDG,0),'999G999G999G999G999G990D00'),' ')||'</a></div></td>';
        end if;

		sDIFFSUM   := '<td class="c7"><div class="c7">'||case when rec.ACCEPT_NORM is not null then LTRIM(to_char(nvl(nSUMBUDG,0) - nvl(nPLANSUM,0),'999G999G999G999G999G990D00'),' ') else '-Нет-' end||'</></div></td>';

        sUNRZ      := '<td class="c8"><div class="c8">'||rec.UNIQREGNUM_FULL ||'</></div></td>';

		nALLPLANSUM := nvl(nALLPLANSUM, 0) + nvl(nPLANSUM,0);
		nALLFACTSUM := nvl(nALLFACTSUM, 0) + nvl(nFACTSUM,0);
        nALLSUMBUDG := nvl(nALLSUMBUDG, 0) + round(nvl(nSUMBUDG,0), 2); -- ТУТ
		-- nALLSUMBUDG := nvl(nALLSUMBUDG, 0) + nvl(nSUMBUDG,0); -- ТУТ
		nALLDIFFSUM := nvl(nALLDIFFSUM, 0) + round(nvl(nSUMBUDG,0), 2) - nvl(nPLANSUM,0);

		htp.p('
			<tr>
				'||sSERVTYPE||'
                '||sUNRZ||'
				'||sSERVCODE||'

                '||sPERCFOT||'
				'||sCALCNORM||'

				'||sPLANSUM||'
				'||sFACTSUM||'

				'||sSUMBUDG||'
				'||sDIFFSUM||'
			</tr>');
	end loop;


    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;">Всего записей: <b>'||nCOUNTROWS||'</b></li>');
    htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
    htp.p('<li style="float:left; " id="save_shtat"></li>');
    htp.p('<li style="clear:both"></li></ul>');
    htp.p(
    '<script>
        $(function(){
		  $("#allplansum").text("'||to_char(nALLPLANSUM,'999G999G999G999G999G990D00')||'");
		  $("#allfactsum").text("'||to_char(nALLFACTSUM,'999G999G999G999G999G990D00')||'");
		  $("#allsumbudg").text("'||to_char(nALLSUMBUDG,'999G999G999G999G999G990D00')||'");
		  $("#alldiffsum").text("'||to_char(nALLDIFFSUM,'999G999G999G999G999G990D00')||'");

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


        function ShowDialog2(id, orgrn, servrn, period) {
        $.ajax({
            url: "wwv_flow.show",
            type: "POST",
            data: {
                p_request: "APPLICATION_PROCESS=dialog_" + id,
                p_flow_id: $("#pFlowId").val(),
                p_flow_step_id: $("#pFlowStepId").val(),
                p_instance: $("#pInstance").val(),
                x01: orgrn,
                x02: servrn,
                x03: period

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
