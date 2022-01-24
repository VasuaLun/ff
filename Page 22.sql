--101; 22;
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;
 pORGRN	       number         := nvl(:P1_ORGRN,:P7_ORGFILTER);
 pPERIOD       number         := :P22_PERIOD;
 nSUMMA		   number;

 -----------------------------------------------
 sNUMB         varchar2(4000);
 sEXPMATNAME   varchar2(4000);
 sKOSGUCODE    varchar2(4000);
 sDOPKOSGU     varchar2(4000);
 sKVRCODE      varchar2(4000);
 sEXPTYPE      varchar2(4000);
 sFOTYPE2      varchar2(4000);
 sEXPGROUP     varchar2(4000);
 sRESTYPE      varchar2(4000);
 sSUMMA        varchar2(4000);
 sRESULT       varchar2(4000);
 sEXPKIND      varchar2(4000);
 sKESR         varchar2(4000);

 sALIG_COEFF   varchar2(4000);
 sREG_COEFF    varchar2(4000);
 sCORRCOEF     varchar2(4000);
 -----------------------------------------------
 nCOUNTROWS    number;
 nCOUNTRES     number;
 nTOTALSUM     number;
 nITEMROW      number;
 nPREVFOTYPE2  number;

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


        .th1{width: 35px;text-align:center; border-left: 0px !important} .c1 {width: 35px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 50px;text-align:center;}   .c2 {width: 50px; word-wrap: break-word; text-align:center;}

        .th3{width: 100%;text-align:center;}   .c3 {width: 100%; word-wrap: break-word; text-align:left;}

        .th4{width: 90px;text-align:center;}  .c4 {width: 90px; word-wrap: break-word; text-align:right;}
        .th5{width: 90px;text-align:center;}  .c5 {width: 90px; word-wrap: break-word; text-align:right;}
        .th6{width: 90px;text-align:center;}  .c6 {width: 90px; word-wrap: break-word; text-align:right;}
        .th7{width: 130px;text-align:center;} .c7 {width: 130px; word-wrap: break-word; text-align:right;}
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

    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1" ><div class="th1">п/п</div></th>
         <th class="header th2" ><div class="th2">Группа</div></th>
         <th class="header th3" ><div class="th3">Наименование</div></th>
         <th class="header th4" ><div class="th4">Отраслевой коэфф.</div></th>
         <th class="header th5" ><div class="th5">Терр. коэфф.</div></th>
         <th class="header th6" ><div class="th6">Коэфф. выравнивания</div></th>
         <th class="header th7" ><div class="th7">Базовый норматив</div></th>
         <th class="header th8" ><div class="th8">Итого</div></th>
		 <th class="header th9" ><div class="th9">-</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    /*
    begin
    select case pPERIOD
            when 1 then nvl(sum(nvl(D.ACCEPT_NORM, 0) * nvl(D.ALIG_COEFF, 1) * nvl(D.REG_COEFF, 1) * nvl(D.CORRCOEF, 1)), 0)
            when 2 then nvl(sum(nvl(D.ACCEPT_NORM2, 0) * nvl(D.ALIG_COEFF, 1) * nvl(D.REG_COEFF, 1) * nvl(D.CORRCOEF2, 1)), 0)
            when 3 then nvl(sum(nvl(D.ACCEPT_NORM3, 0) * nvl(D.ALIG_COEFF, 1) * nvl(D.REG_COEFF, 1) * nvl(D.CORRCOEF3, 1)), 0) end RES,
        case pPERIOD
                when 1 then nvl(sum(D.ACCEPT_NORM),0)
                when 2 then nvl(sum(D.ACCEPT_NORM2),0)
                when 3 then nvl(sum(D.ACCEPT_NORM3),0) end SUMMA
        into nRES, nSUMMA
    from Z_SERVLINKS_NORM D, Z_EXPGROUP EG
    where D.VERSION  = :P1_VERSION
      and D.EXPGROUP = EG.RN
      and D.LINKRN   = :P22_RN;
    exception when others then
        nSUMMA := 0;
        nRES := 0;
    end;
    */

    for QREC in
    (
        select case pPERIOD
               when 1 then nvl(D.ACCEPT_NORM, 0)  * nvl(D.CORRCOEF,  1)
               when 2 then nvl(D.ACCEPT_NORM2, 0) * nvl(D.CORRCOEF2, 1)
               when 3 then nvl(D.ACCEPT_NORM3, 0) * nvl(D.CORRCOEF3, 1) end * nvl(D.ALIG_COEFF, 1) * nvl(D.REG_COEFF, 1) as RES,
            case pPERIOD
                    when 1 then nvl(D.ACCEPT_NORM, 0)
                    when 2 then nvl(D.ACCEPT_NORM2, 0)
                    when 3 then nvl(D.ACCEPT_NORM3, 0) end SUMMA
        from Z_SERVLINKS_NORM D, Z_EXPGROUP EG
        where D.VERSION  = :P1_VERSION
          and D.EXPGROUP = EG.RN
          and D.LINKRN   = :P22_RN
    )
    loop
        nRES := nvl(nRES, 0) +  QREC.RES;
        nSUMMA := nvl(nSUMMA, 0) + QREC.SUMMA;
    end loop;

	sNUMB        := '<td class="c1  itogo"><div class="c1"></div></td>';
	sEXPKIND     := '<td class="c2  itogo"><div class="c2"></div></td>';
	sEXPMATNAME  := '<td class="c3  itogo"><div class="c3"></div></td>';
    sALIG_COEFF  := '<td class="c4  itogo"><div class="c4"></div></td>';
    sREG_COEFF   := '<td class="c5  itogo"><div class="c4"></div></td>';
    sCORRCOEF    := '<td class="c6  itogo"><div class="c5"></div></td>';
	sKOSGUCODE   := '<td class="c7  itogo"><div class="c7">'||to_char(nSUMMA,'999G999G999G999G999G990D000000000')||'</div></td>';
    sRESULT      := '<td class="c8  itogo"><div class="c8">'||to_char(nRES,'999G999G999G999G999G990D00')||'</div></td>';
	sDOPKOSGU    := '<td class="c9  itogo"><div class="c9"></div></td>';

	htp.p('<tr>'||sNUMB||'
				'||sEXPKIND||'
				'||sEXPMATNAME||'
                '||sALIG_COEFF||'
                '||sREG_COEFF||'
                '||sCORRCOEF||'
				'||sKOSGUCODE||'
                '||sRESULT||'
				'||sDOPKOSGU||'
		   </tr>');

	for rec in (
		select
			D.RN,
			EG.NUM,
			EG.CODE,
			EG.NAME,
            D.ALIG_COEFF,
            D.REG_COEFF,
            case pPERIOD
                when 1 then D.CORRCOEF
                when 2 then D.CORRCOEF2
                when 3 then D.CORRCOEF3 end CORRCOEF,
            case pPERIOD
                when 1 then D.ACCEPT_NORM
                when 2 then D.ACCEPT_NORM2
                when 3 then D.ACCEPT_NORM3 end ACCEPT_NORM,
			'<a href ="javascript:apex.confirm(''Удалить норматив по группе затрат?'', {request:''rDEL_REC'', set:{''P22_DEL_RN'':'||D.RN||', ''P22_DEL_TYPE'':''T_SERVLINKS_NORM''}});"><img src="/i/menu/remove_16x16.gif" title="Удалить запись" style="cursor:pointer" /></a>' DELSIGN
			from Z_SERVLINKS_NORM D, Z_EXPGROUP EG
			where D.VERSION  = :P1_VERSION
			  and D.EXPGROUP = EG.RN
			  and D.LINKRN   = :P22_RN
		order by EG.NUM
	)
	loop



		sNUMB        := '<td class="c1"><div class="c1">'||rec.NUM||'</div></td>';
		sEXPKIND     := '<td class="c2"><div class="c2">'||rec.CODE||'</div></td>';
		sEXPMATNAME  := '<td class="c3"><div class="c3">'||rec.NAME ||'</div></td>';

        if pPERIOD = 1 then
            sALIG_COEFF  := '<td class="c4"><div class="c4"><input type="text" value="'||nvl(rec.ALIG_COEFF, 1)||'" class="in_txtr decimal"
                                            onblur="save_data('||rec.rn||',this.value, ''ALIG_COEFF'', this);"/></div></td>';
            sREG_COEFF   := '<td class="c5"><div class="c5"><input type="text" value="'||nvl(rec.REG_COEFF, 1)||'" class="in_txtr decimal"
                                            onblur="save_data('||rec.rn||',this.value, ''REG_COEFF'', this);"/></div></td>';
        else
            sALIG_COEFF  := '<td class="c4"><div class="c4">'||to_char(nvl(rec.ALIG_COEFF, 1),'999G999G999G999G990D00')||'</div></td>';
            sREG_COEFF  := '<td class="c5"><div class="c5">'||to_char(nvl(rec.REG_COEFF, 1),'999G999G999G999G990D00')||'</div></td>';
        end if;

        sCORRCOEF    := '<td class="c6"><div class="c6"><input type="text" value="'||nvl(rec.CORRCOEF, 1)||'" class="in_txtr decimal"
                                        onblur="save_data('||rec.rn||',this.value, ''CORRCOEF'||pPERIOD||''', this);"/></div></td>';
		sKOSGUCODE   := '<td class="c7"><div class="c7"><input type="text" value="'||rec.ACCEPT_NORM||'" class="in_txtr decimal"
                                      onblur="save_data('||rec.rn||',this.value, ''ACCEPT_NORM'||pPERIOD||''', this);"/></div></td>';

        nRES := nvl(rec.ALIG_COEFF, 1) * nvl(rec.REG_COEFF, 1) * nvl(rec.CORRCOEF, 1) * nvl(rec.ACCEPT_NORM, 0);

        sRESULT      := '<td class="c8"><div class="c8">'||to_char(nRES,'999G999G999G999G990D00')||'</div></td>';
		sDOPKOSGU    := '<td class="c9"><div class="c9">'||rec.DELSIGN||'</div></td>';

		if nvl(nCOUNTROWS,0) <= 500 then
			htp.p('
				<tr id="row_'||rec.RN||'">
					'||sNUMB||'
					'||sEXPKIND||'
					'||sEXPMATNAME||'
                    '||sALIG_COEFF||'
                    '||sREG_COEFF||'
                    '||sCORRCOEF||'
					'||sKOSGUCODE||'
                    '||sRESULT||'
					'||sDOPKOSGU||'
			   </tr>');
			nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;
		else
			EXIT;
		end if;
	end loop;

    if nvl(nCOUNTROWS,0) > 500 then
		sColor := 'font-weight:regular;color:red';
		sMSG := 'Выбрано слишком много записей. Отображены первые 500. Необходимо использовать фильтры.';
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
          table_body.height("350px");
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
