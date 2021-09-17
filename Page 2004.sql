--101; 2001; Z_JURPERS, Z_ORGREG
declare
 pDEPFIN       number        := :P1_DEPFIN;
 pDEPFINVER    number        := :P1_DEPFIN_VERSION;
 pSORT         number        := :P2004_SORT;

 -----------------------------------------------
 sORGTYPE      varchar2(4000);
 sORGNAME      varchar2(4000);
 sDISTRICT     varchar2(4000);
 sORGKIND      varchar2(4000);
 sSERVCOUNT    varchar2(4000);
 sFIL          varchar2(4000);
 sOTHER        varchar2(4000);
 sPUBLIC       varchar2(4000);
 sCAP          varchar2(4000);
 sOUTCOMESUM   varchar2(4000);
 sLIM          varchar2(4000);
 sDIFFSUM      varchar2(4000);

 sSUPPORT      varchar2(4000);
 sPINORG       varchar2(4000);
 sLOGINUSER    varchar2(4000);

 sSUBSNP       varchar2(4000);
 sGUARLETTER   varchar2(4000);
 sSUBSPRIL     varchar2(4000);
 sSUBSEFFCON   varchar2(4000);

 -----------------------------------------------
 nCOUNTROWS    number;
 dLAST_LOGIN	date;
 SLAST_LOGIN   varchar2(300);
 nUSER_ACTIVE	number;
 sUSER_ACTIVE	varchar2(300);
begin

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


        .th1{width: 30px;text-align:center; border-left: 0px !important}    .c1 {width: 30px; word-wrap: break-word; text-align:center; border-left: 0px !important}
		.th2{width: 100%;text-align:center;}   .c2 {width: 100%; word-wrap: break-word; text-align:left;}
		.th3{width: 120px;text-align:center;}   .c3 {width: 120px; word-wrap: break-word; text-align:right;}
        .th4{width: 120px;text-align:center;}   .c4 {width: 120px; word-wrap: break-word; text-align:right;}
        .th5{width: 120px;text-align:center;}  .c5 {width: 120px; word-wrap: break-word; text-align:right;}
        .th6{width: 120px;text-align:center;}   .c6 {width: 120px; word-wrap: break-word; text-align:right;}
        .th7{width: 120px;text-align:center;}   .c7 {width: 120px; word-wrap: break-word; text-align:right;}
        .th8{width: 120px;text-align:center;}   .c8 {width: 120px; word-wrap: break-word; text-align:right;}
        .th9{width: 120px;text-align:center;}   .c9 {width: 120px; word-wrap: break-word; text-align:right;}
		.th10{width: 120px;text-align:center;}  .c10 {width: 120px; word-wrap: break-word; text-align:center;}

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
         <th class="header th1"><div class="th1">Тип</div></th>
         <th class="th2"><div class="th2"><a href="f?p=101:2004:'||v('APP_SESSION')||'::NO::P2004_SORT:'||case when pSORT = 1 then ''|| -1 ||'' when pSORT = -1 then ''|| 0 ||'' else ''|| 1 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Учреждение'
         ||case when pSORT = 1 then ' ↓' end || case when pSORT = -1 then ' ↑' end||'</span></a></div></td>
         <th class="th3"><div class="th3"><a href="f?p=101:2004:'||v('APP_SESSION')||'::NO::P2004_SORT:'||case when pSORT = 2 then ''|| -2 ||'' when pSORT = -2 then ''|| 0 ||'' else ''|| 2 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Всего судсидий'
         ||case when pSORT = 2 then ' ↓' end || case when pSORT = -2 then ' ↑' end||'</span></a></div></td>
         <th class="th4"><div class="th4"><a href="f?p=101:2004:'||v('APP_SESSION')||'::NO::P2004_SORT:'||case when pSORT = 3 then ''|| -3 ||'' when pSORT = -3 then ''|| 0 ||'' else ''|| 3 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">В т.ч. на услуги'
         ||case when pSORT = 3 then ' ↓' end || case when pSORT = -3 then ' ↑' end||'</span></a></div></td>
         <th class="th5"><div class="th5"><a href="f?p=101:2004:'||v('APP_SESSION')||'::NO::P2004_SORT:'||case when pSORT = 4 then ''|| -4 ||'' when pSORT = -4 then ''|| 0 ||'' else ''|| 4 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Иные субсидии'
         ||case when pSORT = 4 then ' ↓' end || case when pSORT = -4 then ' ↑' end||'</span></a></div></td>
         <th class="th6"><div class="th6"><a href="f?p=101:2004:'||v('APP_SESSION')||'::NO::P2004_SORT:'||case when pSORT = 5 then ''|| -5 ||'' when pSORT = -5 then ''|| 0 ||'' else ''|| 5 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Публичные<br>обязательства'
         ||case when pSORT = 5 then ' ↓' end || case when pSORT = -5 then ' ↑' end||'</span></a></div></td>
         <th class="th7"><div class="th7"><a href="f?p=101:2004:'||v('APP_SESSION')||'::NO::P2004_SORT:'||case when pSORT = 6 then ''|| -6 ||'' when pSORT = -6 then ''|| 0 ||'' else ''|| 6 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Капитальные<br>вложения'
         ||case when pSORT = 6 then ' ↓' end || case when pSORT = -6 then ' ↑' end||'</span></a></div></td>
         <th class="th8"><div class="th8"><a href="f?p=101:2004:'||v('APP_SESSION')||'::NO::P2004_SORT:'||case when pSORT = 7 then ''|| -7 ||'' when pSORT = -7 then ''|| 0 ||'' else ''|| 7 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Итого затраты'
         ||case when pSORT = 7 then ' ↓' end || case when pSORT = -7 then ' ↑' end||'</span></a></div></td>
         <th class="header th9" ><div class="th9">Лимит ФО</div></th>
         <th class="header th10" ><div class="th10">Расхождения</div></th>
         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    	for rec in
    	(
            select c001, c002, c003, c004, n001, n002, n003, n004, n005, (n001 + n003 + n004 + n005) as ALLS
            from APEX_collections where collection_name = 'TEST'
            order by
                case when pSORT = 1  then c001 end asc,
                case when pSORT = -1 then c001 end desc,
                case when pSORT = 2  then n001 end asc,
                case when pSORT = -2 then n001 end desc,
                case when pSORT = 3  then n002 end asc,
                case when pSORT = -3 then n002 end desc,
                case when pSORT = 4  then n003 end asc,
                case when pSORT = -4 then n003 end desc,
                case when pSORT = 5  then n004 end asc,
                case when pSORT = -5 then n004 end desc,
                case when pSORT = 6  then n005 end asc,
                case when pSORT = -6 then n005 end desc,
                case when pSORT = 7  then ALLS end asc,
                case when pSORT = -7 then ALLS end desc,
                c004 desc
    	)
    	loop

    		nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

            if rec.c004 = '0' then sORGTYPE := 'Б'; else sORGTYPE := 'А'; end if;

    		sORGTYPE    := '<td class="c1"><div class="c1"></>'||sORGTYPE||'</div></td>';
            sORGNAME    := '<td class="c2"><div class="c2"></>'||rec.c001||'</div></td>';
    		sORGKIND    := '<td class="c4"><div class="c4">-</></div></td>';
            sDISTRICT   := '<td class="c3"><div class="c3">'||rec.n001||'</></div></td>'; -- вывод Всего затрат
            sFIL        := '<td class="c4"><div class="c4">'||rec.n002||'</></div></td>'; -- вывод в том числе на субсиции
            sOTHER      := '<td class="c5"><div class="c5">'||rec.n003||'</></div></td>'; -- вывод иные субсидии
            sPUBLIC     := '<td class="c6"><div class="c6">'||rec.n004||'</></div></td>'; -- вывод публичные обязательства
            sCAP        := '<td class="c7"><div class="c7">'||rec.n005||'</></div></td>'; -- вывод капитальные вложения
            sOUTCOMESUM := '<td class="c8"><div class="c8">'||rec.ALLS||'</></div></td>'; -- вывод Итого затраты
            -- sLIM        := '<td class="c9"><div class="c9">'||rec.c008||'</></div></td>'; -- вывод Лимит ФО
            -- sDIFFSUM    := '<td class="c9"><div class="c9">'||rec.c008||'</></div></td>'; -- вывод разница

    		htp.p('
    			<tr>
    				'||sORGTYPE||'
    				'||sORGNAME||'
    				'||sDISTRICT||'
    				'||sFIL||'
    				'||sOTHER||'
                    '||sPUBLIC||'
                    '||sCAP||'
                    '||sOUTCOMESUM||'
                    '||sORGKIND||'
                    '||sORGKIND||'
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

            function ShowDialog2(id, orgrn, rtype) {
    		$.ajax({
    			url: "wwv_flow.show",
    			type: "POST",
    			data: {
    				p_request: "APPLICATION_PROCESS=dialog_" + id,
    				p_flow_id: $("#pFlowId").val(),
    				p_flow_step_id: $("#pFlowStepId").val(),
    				p_instance: $("#pInstance").val(),
    				x01: orgrn,
                    x02: rtype

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
