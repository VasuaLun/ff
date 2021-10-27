--101; 1287;
declare
 -----------------------------------------------
 sJURCODE      varchar2(4000);
 sORGNAME      varchar2(4000);
 sORGINN       varchar2(4000);
 sINFO         varchar2(4000);
 sDATECREAE    varchar2(4000);

 -----------------------------------------------
 nJMARK        number := 0;
 -----------------------------------------------
 nCOUNTROWS    number;

 -- Блок новых переменных
 pTYPE       number;
 pLOGIN      varchar2(100) := nvl(:P1287_SUPLOGIN, 0);
 pUSER       varchar2(100)  := :APP_USER;


begin
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


        .th1{width: 450px;text-align:center; border-left: 0px !important} .c1 {width: 450px; word-wrap: break-word; text-align:left; border-left: 0px !important}
        .th2{width: 150px;text-align:center;} .c2 {width: 150px; word-wrap: break-word; text-align:center;}
		.th3{width: 100%;text-align:center;} .c3 {width: 100%; word-wrap: break-word; text-align:left;}
		.th4{width: 200px;text-align:center;} .c4 {width: 200px; word-wrap: break-word; text-align:center;}

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


    htp.p('<div><table border="0" id="fix" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%" id="">
      <thead>
          <tr>
           <th class="header th1"><div class="th1">Название Учреждения</div></th>
           <th class="header th2"><div class="th2">ИНН</div></th>
           <th class="header th3"><div class="th3">Информация</div></th>
           <th class="header th4"><div class="th4">Дата</div></th>

           <th class="header"><div style="width:8px"></div></th>

          </tr>
         </thead>
       <tbody id="fullall">');

    for rec in
    (
        select J.RN JRN,
            J.NAME JNAME,
            O.CODE OCODE,
            O.INN INN,
            L.INFO INFO,
            L.SUPOPRT_DATE DATESUP
        from Z_JURPERS J, Z_SUPPORTLOG L, A_ORG O
        where L.SUPPORT_USER = pLOGIN
            and L.status = 2
            and J.RN = L.JUR_PERS
            and L.A_ORGRN = O.RN (+)
        order by J.rn, L.SUPOPRT_DATE desc

    )
    loop

        nCOUNTROWS := nvl(nCOUNTROWS, 0) + 1;

        if nJMARK != rec.JRN then
            nJMARK := rec.JRN;
            htp.p('<tr><td style="display: block;text-align:center;"><span style="font-weight: 800;font-size:18">'||rec.JNAME||'</span></td></tr>');
        end if;

        -- sJURCODE   := '<td class="c1"><div class="c1">'||rec.JNAME||'</></div></td>';

        sORGNAME   := '<td class="c1"><div class="c1">'||rec.OCODE||'</></div></td>';
        sORGINN  := '<td class="c2"><div class="c2">'||rec.INN||'</></div></td>';
        sINFO  := '<td class="c3"><div class="c3">'||rec.INFO||'</></div></td>';
        sDATECREAE  := '<td class="c4"><div class="c4">'||rec.DATESUP||'</></div></td>';

        htp.p('
            <tr>
                '||sORGNAME||'
                '||sORGINN||'
                '||sINFO||'
                '||sDATECREAE||'
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
