--101; 1286;
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

 /*
  1е - центр сообщений
  2е - горячая линия
  3е - центр задач
 */
 nCOUNTHL2      number;
 nCOUNTHL2A     number;
 nCOUNTHL2END   number;
 nCOUNTHL3      number;
 nCOUNTHL3A     number;
 nCOUNTHL3END   number;

 nAMOUNT        number;

 -----------------------------------------------
 nCOUNTROWS    number;

 nSUPPNUMB     number;

   -- Массив с логом звонков горячей линии
type t_call is record(
    JURRN    number,
    SUPRN    number,
    countC   number,
    TYP      number
 );
 type t_call_arr is table of t_call;
 CALLARR t_call_arr;

 type t_amount is record(
     SUPRN    number,
     countC1  number,
     countC2  number,
     countC3  number
  );
  type t_amount_arr is table of t_amount;
  AMMARR t_amount_arr;

begin
    -- Инициализация
    ----------------------------------------------------
    select J.RN,
        U.RN,
        COUNT(L.RN) as COUN,
        2 as TYP
    bulk collect into CALLARR
    from Z_SUPPORTLOG L, Z_USERS U, Z_JURPERS J, Z_SUPPORTLOG_HISTORY H
    where L.SUPPORT_USER in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
        and ((L.StATUS = 2 and :P1286_WORK is null)
            or (L.StATUS = 3 and :P1286_WORK = 1))
        and U.LOGIN = L.SUPPORT_USER
        and J.RN = L.JUR_PERS
        and H.LOG_RN = L.RN
        and ((trunc(H.CHANGE_DATE) >= :P1286_DATESTART) or (:P1286_DATESTART is null))
        and ((trunc(H.CHANGE_DATE) <= :P1286_DATEND) or (:P1286_DATEND is null))
    group by J.RN, U.RN
    union all
    select case
             when J.RN is NULL
                then 0
                else J.RN
           end as JUR,
        U.RN as URN,
        count(T.RN) as COUN,
        3 as TYP
    from W_TASK T, Z_USERS U, Z_JURPERS J
    where t.EXECUTER = U.LOGIN
        and T.JURPERS = J.RN (+)
        and ((T.StATUS in (2, 3) and :P1286_WORK is null)
            or (T.StATUS = 5 and :P1286_WORK = 1))
        and T.EXECUTER in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
        and ((trunc(T.MODIFIED) >= :P1286_DATESTART) or (:P1286_DATESTART is null))
        and ((trunc(T.MODIFIED) <= :P1286_DATEND) or (:P1286_DATEND is null))
    group by J.RN, U.RN;

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
        .th_plan1{width: 70px;text-align:center;} .cp1 {width: 70px; word-wrap: break-word; text-align:right;}
		.th_plan2{width: 70px;text-align:center;} .cp2 {width: 70px; word-wrap: break-word; text-align:right;}
		.th_plan3{width: 70px;text-align:center;} .cp3 {width: 70px; word-wrap: break-word; text-align:right;}
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

    if CALLARR.EXISTS(1) then

        -- цикл для вывода строк - по ГРБС
        for recJ in
        (
            select 'Финатек' as NAME,
                0 as RN
            from dual
            union
            select distinct J.NAME as NAME,
                J.RN as RN
            from Z_SUPPORTLOG L,
                Z_JURPERS J,
                Z_SUPPORTLOG_HISTORY H
            where J.RN = L.JUR_PERS
                and H.LOG_RN = L.RN
                and ((trunc(H.CHANGE_DATE) >= :P1286_DATESTART) or (:P1286_DATESTART is null))
                and ((trunc(H.CHANGE_DATE) <= :P1286_DATEND) or (:P1286_DATEND is null))
                and ((L.StATUS = 2 and :P1286_WORK is null)
                    or (L.StATUS = 3 and :P1286_WORK = 1))
            union
            select distinct J.NAME as NAME,
                J.RN as RN
            from W_TASK T,
                Z_JURPERS J
            where J.RN = T.JURPERS
                and ((trunc(T.MODIFIED) >= :P1286_DATESTART) or (:P1286_DATESTART is null))
                and ((trunc(T.MODIFIED) <= :P1286_DATEND) or (:P1286_DATEND is null))
                and ((T.StATUS in (2, 3) and :P1286_WORK is null)
                    or (T.StATUS = 5 and :P1286_WORK = 1))
        )
        loop

            -- счетчик строк
            nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

            -- обнуление итогов по строкам
            nCOUNTHL2A := 0;
            nCOUNTHL3A := 0;

            nSUPPNUMB := 0;

            sJURPERS := '<td class="c1"><div class="c1">'||recJ.NAME||'</></div></td>';

            htp.p('<tr>'||sJURPERS||'');

            -- цикл для динамического вывода пользователей
            for recU in
            (
                select RN, NAME, LOGIN
                from Z_USERS
                where LOGIN in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
            )
            loop

                nSUPPNUMB := nSUPPNUMB + 1;

                -- обнуление
                nCOUNTHL2 := 0;
                nCOUNTHL3 := 0;

                for USE in CALLARR.FIRST..CALLARR.COUNT
                loop

                    if nMARK = 0 then
                        if CALLARR(USE).TYP = 2 then
                            nCOUNTHL2END := nvl(nCOUNTHL2END, 0) + CALLARR(USE).countC;
                            if CALLARR(USE).JURRN = recJ.RN and CALLARR(USE).SUPRN = recU.RN then
                                nCOUNTHL2  := CALLARR(USE).countC;
                                -- сумма откликов по горячей линии в строке
                                nCOUNTHL2A := nCOUNTHL2A + nCOUNTHL2;
                            end if;
                        elsif CALLARR(USE).TYP = 3 then
                            nCOUNTHL3END := nvl(nCOUNTHL3END, 0) + CALLARR(USE).countC;
                            if CALLARR(USE).JURRN = recJ.RN and CALLARR(USE).SUPRN = recU.RN then
                                nCOUNTHL3  := CALLARR(USE).countC;
                                -- сумма откликов по горячей линии в строке
                                nCOUNTHL3A := nCOUNTHL3A + nCOUNTHL3;
                            end if;
                        end if;

                    elsif CALLARR(USE).JURRN = recJ.RN and CALLARR(USE).SUPRN = recU.RN then

                        if CALLARR(USE).TYP = 2 then
                            nCOUNTHL2  := CALLARR(USE).countC;
                            -- сумма откликов по горячей линии в строке
                            nCOUNTHL2A := nCOUNTHL2A + nCOUNTHL2;

                            -- выйти из цикла
                            GOTO output;
                        elsif CALLARR(USE).TYP = 3 then
                            nCOUNTHL3  := CALLARR(USE).countC;
                            -- сумма откликов по горячей линии в строке
                            nCOUNTHL3A := nCOUNTHL3A + nCOUNTHL3;

                            -- выйти из цикла
                            GOTO output;
                        end if;

                    end if;

                end loop;

                nMARK := 1;

                -- lebel для перехода после завершения цикла
                <<output>>
                sMESSAGE  := '<td class="cp1"><div class="cp1">-</></div></td>';
                sDONECALL := '<td class="cp2"><div class="cp2">'||to_char(nvl(nCOUNTHL2,0))||'</></div></td>';
                sTASK     := '<td class="cp3"><div class="cp3">'||to_char(nvl(nCOUNTHL3,0))||'</></div></td>';

                AMMARR(nSUPPNUMB).SUPRN := recU.RN;

                AMMARR(nSUPPNUMB).countC2 := nvl(AMMARR(nSUPPNUMB).countC2, 0) + nCOUNTHL2;
                AMMARR(nSUPPNUMB).countC3 := nvl(AMMARR(nSUPPNUMB).countC3, 0) + nCOUNTHL3;

                htp.p('
                        '||sMESSAGE||'
                        '||sDONECALL||'
                        '||sTASK||'
                     ');
            end loop;

            -- Итого по строке
            nAMOUNT := nCOUNTHL2A + nCOUNTHL3A;

            sMESSAGE  := '<td class="co1"><div class="co1">-</></div></td>';
            sDONECALL := '<td class="co2"><div class="co2">'||nCOUNTHL2A||'</></div></td>';
            sTASK     := '<td class="co3"><div class="co3">'||nCOUNTHL3A||'</></div></td>';
            sAMOUNT   := '<td class="co4"><div class="co4">'||nAMOUNT||'</></div></td>';

            sPERCENT  := '<td class="c2"><div class="c2">'||LTRIM(to_char(nvl(nAMOUNT/(nCOUNTHL2END + nCOUNTHL3END)*100,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

            htp.p('
                    '||sMESSAGE||'
                    '||sDONECALL||'
                    '||sTASK||'
                    '||sAMOUNT||'
                    '||sPERCENT||'
                </tr>');

        end loop;

        sJURPERS := '<td class="c1"><div class="c1">Итого:</></div></td>';

        htp.p('<tr>'||sJURPERS||'');

        for recU in
        (
            select RN, NAME, LOGIN
            from Z_USERS
            where LOGIN in ('VASILTSOVA', 'DEMYANOVA', 'PROHOROVA', 'BUBAEVA')
        )
        loop
            
            for USE in AMMARR.FIRST..AMMARR.COUNT
            loop
                if AMMARR(USE).SUPRN = recU.RN then
                    nCOUNTHL3 := USE;
                end if;
            end loop;

            sMESSAGE  := '<td class="cp1"><div class="cp1">-</></div></td>';
            sDONECALL := '<td class="cp2"><div class="cp2">'||to_char(nvl(AMMARR(nCOUNTHL3).countC2,0))||'</></div></td>';
            sTASK     := '<td class="cp3"><div class="cp3">'||to_char(nvl(AMMARR(nCOUNTHL3).countC3,0))||'</></div></td>';

            htp.p('<tr>
                    '||sMESSAGE||'
                    '||sDONECALL||'
                    '||sTASK||'
                  ');

        end loop;

        sMESSAGE  := '<td class="co1"><div class="co1">-</></div></td>';
        sDONECALL := '<td class="co2"><div class="co2">-</></div></td>';
        sTASK     := '<td class="co3"><div class="co3">-</></div></td>';
        sAMOUNT   := '<td class="co4"><div class="co4">-</></div></td>';

        sPERCENT  := '<td class="c2"><div class="c2">100%</></div></td>';

        htp.p('
                '||sMESSAGE||'
                '||sDONECALL||'
                '||sTASK||'
                '||sAMOUNT||'
                '||sPERCENT||'
            </tr>');

        else htp.p('<tr><td><div>Данные не найдены</div></td></tr>');
    end if;

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
