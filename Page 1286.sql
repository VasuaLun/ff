--101; 1285;
declare
 pSTATUS varchar2(1) := :P1286_WORK;

 -----------------------------------------------
 sJURPERS      varchar2(4000);
 sMESSAGE      varchar2(4000);
 sDONECALL     varchar2(4000);
 sTASK         varchar2(4000);
 sAMOUNT       varchar2(4000);
 sPERCENT      varchar2(4000);

 -----------------------------------------------
 nMark          number := 0;
 nCOUNTHL2      number;
 nCOUNTHL2A     number;
 nCOUNTHL2END   number;

 -----------------------------------------------
 nCOUNTROWS    number;

   -- Массив с логом звонков горячей линии
type t_call is record(
    JURRN    number,
    SUPRN    number,
    countC   number
 );
 type t_call_arr is table of t_call;
 CALLARR t_call_arr;

begin
    -- Инициализация
    ----------------------------------------------------
    select J.RN as JUR, U.RN as US, COUNT(L.RN)
    bulk collect into CALLARR
    from Z_SUPPORTLOG L, Z_USERS U, Z_JURPERS J
    where L.SUPPORT_USER in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
        and U.LOGIN = L.SUPPORT_USER
        and J.RN = L.JUR_PERS
        and ((nvl(pSTATUS, 0) = 1 and L.STATUS = 3) or (nvl(pSTATUS, 0) = 0 and L.STATUS = 2))
    group by J.RN, U.RN
    order by J.RN;

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


        .th1{width: 100%;text-align:center; border-left: 0px !important}    .c1 {width: 100%; word-wrap: break-word; text-align:left; border-left: 0px !important}
        .th_plan1{width: 70px;text-align:center;} .cp1 {width: 70px; word-wrap: break-word; text-align:left;}
		.th_plan2{width: 70px;text-align:center;} .cp2 {width: 70px; word-wrap: break-word; text-align:left;}
		.th_plan3{width: 70px;text-align:center;} .cp3 {width: 70px; word-wrap: break-word; text-align:left;}
        .th_out1{width: 50px;text-align:center;}   .co1 {width: 50px; word-wrap: break-word; text-align:right;}
        .th_out2{width: 50px;text-align:center;}   .co2 {width: 50px; word-wrap: break-word; text-align:right;}
        .th_out3{width: 50px;text-align:center;}   .co3 {width: 50px; word-wrap: break-word; text-align:right;}
        .th_out4{width: 50px;text-align:center;}   .co4 {width: 50px; word-wrap: break-word; text-align:right;}
        .th2{width: 40px;text-align:center;}   .c2 {width: 40px; word-wrap: break-word; text-align:right;}


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
           <th class="header th1" rowspan="3"><div class="th1">Проект</div></th>');

    for rec in
    (
        select NAME
        from Z_USERS
        where LOGIN in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
    )
    loop
        htp.p('
           <th class="header" colspan="3"><div>'||rec.NAME||'</div></th>');
    end loop;

    htp.p('<th class="header" colspan="4"><div>Итого</div></th>
           <th class="header th2" rowspan="3"><div class="th2">%</div></th>
           <th class="header" rowspan="3"><div style="width:8px"></div></th></tr><tr>');

    for rec in
    (
        select RN, NAME, LOGIN
        from Z_USERS
        where LOGIN in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
    )
    loop

        htp.p('
                <th class="header th_plan1" rowspan="2"><div class="th_plan1">Центр сообщений</div></th>
                <th class="header th_plan2" rowspan="2"><div class="th_plan2">Горячая линия</div></th>
                <th class="header th_plan3" rowspan="2"><div class="th_plan3">Центр задач</div></th>
             ');
    end loop;

    htp.p('
            <th class="header th_out1" rowspan="2"><div class="th_out1">Центр сооб.</div></th>
            <th class="header th_out2" rowspan="2"><div class="th_out2">Гор. линия</div></th>
            <th class="header th_out3" rowspan="2"><div class="th_out3">Центр задач</div></th>
            <th class="header th_out4" rowspan="2"><div class="th_out4">Всего</div></th>
         ');

    htp.p('</tr></thead><tbody id="fullall">');

    -- цикл для вывода строк
    for recJ in
    (
        select distinct L.JUR_PERS, J.NAME, J.RN
        from Z_SUPPORTLOG L, Z_JURPERS J
        where J.RN = L.JUR_PERS
    )
    loop

        nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

        nCOUNTHL2A := 0;

        sJURPERS := '<td class="c1"><div class="c1">'||recJ.NAME||'</></div></td>';

        htp.p('<tr>'||sJURPERS||'');

        -- цикл для динамического вывода количества пользователей
        for recU in
        (
            select RN, NAME, LOGIN
            from Z_USERS
            where LOGIN in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
        )
        loop

            nCOUNTHL2 := 0;

            for USE in CALLARR.FIRST..CALLARR.COUNT
            loop
                if nMARK = 0 then
                    nCOUNTHL2END := nvl(nCOUNTHL2END, 0) + CALLARR(USE).countC;
                    if CALLARR(USE).JURRN = recJ.RN and CALLARR(USE).SUPRN = recU.RN then
                        nCOUNTHL2  := CALLARR(USE).countC;
                        -- сумма откликов по горячей линии в строке
                        nCOUNTHL2A := nCOUNTHL2A + nCOUNTHL2;
                    end if;
                elsif CALLARR(USE).JURRN = recJ.RN and CALLARR(USE).SUPRN = recU.RN then
                    nCOUNTHL2  := CALLARR(USE).countC;
                    -- сумма откликов по горячей линии в строке
                    nCOUNTHL2A := nCOUNTHL2A + nCOUNTHL2;
                    GOTO output; -- выйти из цикла
                end if;
            end loop;

            nMARK := 1;

            -- lebel для перехода после завершения цикла
            <<output>>
            sMESSAGE  := '<td class="cp1"><div class="cp1">-</></div></td>';
            sDONECALL := '<td class="cp2"><div class="cp2">'||to_char(nvl(nCOUNTHL2,0))||'</></div></td>';
            sTASK     := '<td class="cp3"><div class="cp3">-</></div></td>';

            htp.p('
                    '||sMESSAGE||'
                    '||sDONECALL||'
                    '||sTASK||'
                 ');
        end loop;

        sMESSAGE  := '<td class="co1"><div class="co1">-</></div></td>';
        sDONECALL := '<td class="co2"><div class="co2">'||nCOUNTHL2A||'</></div></td>';
        sTASK     := '<td class="co3"><div class="co3">-</></div></td>';
        sAMOUNT   := '<td class="co4"><div class="co4">'||nCOUNTHL2A||'</></div></td>';

        sPERCENT  := '<td class="c2"><div class="c2">'||LTRIM(to_char(nvl(nCOUNTHL2A/nCOUNTHL2END*100,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

        htp.p('
                '||sMESSAGE||'
                '||sDONECALL||'
                '||sTASK||'
                '||sAMOUNT||'
                '||sPERCENT||'
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
