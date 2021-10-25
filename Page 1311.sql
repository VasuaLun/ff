-- App 101
-- Page 1311
-- Анализ (детализация показателей объема)
declare
  count_rows    number(17) := 0;
  pORGRN		number(17);
  pVERSION      number(17);
  pJURPERS      number(17);

  nSUMM         number(19,2);

begin
  pORGRN   := :P1311_ORGRN;
  pVERSION := :P1_VERSION;
  pJURPERS := :P1_JURPERS;

  htp.p('<style>

     .report_standard tbody tr:hover td {
           background-color: #FFFAF0; color: #000;
           cursor: pointer;
        }
    .report_standard  thead > tr {width: 100%; }
    .report_standard  tbody > tr {width: 100%; display: block}
    .report_standard > tbody {
        display: block; height: 300px; overflow-x: hidden;  overflow-y: scroll;
      }
    .report_standard  tbody::-webkit-scrollbar {
              width: 16px!important
          }

    .report_standard  tbody::-webkit-scrollbar-thumb {
              background-color: rgb(195, 195, 195);
              border-radius: 20px;
              border: 3px solid rgba(255, 255, 255, 1);
          }

    .report_standard  tbody::-webkit-scrollbar-track {
             background: rgba(255, 255, 255, 1);
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
    }
    .report_standard th{
      text-align:center;
    }
    .report_standard th {
      color:#222;
      font: bold 12px/12px Arial, sans-serif;
      text-shadow: 0 1px 0 rgba(255, 255, 255, 0.5);
      padding: 4px 4px;
       /* background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 50% #e1e1e1 repeat-x;*/
      background: #e1e1e1;
      border-bottom: 1px solid #9fa0a0;
      border-left:1px solid #9fa0a0;
    }
    .report_standard td{
      padding: 4px 4px;
      border-bottom: 1px solid #9fa0a0;
      background-color: #f2f2f2;
    }

    .in_txt {width:70px; border: 1px solid #ccc;text-align:right;}

    .link_code {font-weight: bold; color:#0000ff;}
    .row { margin-bottom: 5px;}

    .th1{width: 100%; text-align:center;}   .c1 {width: 100%; word-wrap: break-word;text-align:left;}
	.th2{width: 200px;text-align:left;}     .c2 {width: 200px; word-wrap: break-word; text-align:right;}

    .selected td {background-color:#C0FFC1;}

    .report_standard td.orange {background-color: #FFE8AD;}
    .report_standard td.totals {background-color: #e1e1e1;}

    .level1 td {background-color: #FFEEC3;}
    .level2 td {background-color: /*#FFF4DA;*/ #f2f2f2;}
    .level3 td {background-color: #f2f2f2;}

    .pagination {text-align: right;
      border: 1px solid grey;
      margin: 0px;

      padding: 5px;
      background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 100% #e1e1e1 repeat-x;cursor:move;
    }
    .pagination li {display: inline; margin-left:5px; font-size: 12px; padding: 2px; cursor:default; }
    .selected_row{padding: 4px 4px;
      border-bottom: 1px solid #9fa0a0;
      background-color: #FAFF82;
    }


    .down.up {
      background: url(/i/themes/theme_21/images/up_arrow.png) no-repeat left center;
      cursor:pointer;
      width:15px;height:15px;
      float:left;

    }
    .down {
      background: url(/i/themes/theme_21/images/down_arrow.png) no-repeat left center;
      cursor:pointer;
      width:15px; height:15px;
      float:left;
    }

    .level1 {display:none;}
    .level2 {display:none;}
    .report_standard .col_milk_lgreen {background:#F4FFEC;font-weight:bold;}   .col_milk_lgreen input {background:#F4FFEC;; border-bottom: 1px solid gray}
    .report_standard .col_milk_pink {background:#FDE9D9}   .col_milk_pink input {background:#FDE9D9; border-bottom: 1px solid gray}
    .report_standard .col_milk_green {background:rgb(175, 255, 136);}  .col_milk_green input {background:rgb(175, 255, 136); border-bottom: 1px solid gray}
    .report_standard .col_milk_yellow {background:#F9F2D0;} .col_milk_yellow input {background:#F9F2D0; border-bottom: 1px solid gray}
    .report_standard .col_milk_white {background:#FFFFFF}  .col_milk_white input {background:#FFFFFF; border-bottom: 1px solid gray}

    </style>


  ');


  htp.p('<div><table border="0" id="fix" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%; border-bottom:0px" id="">
    <thead>
        <tr>
		 <th class="header th1" ><div class="th1">Тип финансирования</div></th>
		 <th class="header th2" ><div class="th2">Расчетный норматив на обного обучающегося</div></th>
       <th class="header" ><div style="width:8px"></div></th>
      </thead>
    <tbody>
  ');

      --if APEX_COLLECTION.COLLECTION_EXISTS ('DETAIL') then zp_exception(0, 'тут zzz'); end if;
      for rec in
      (
        select name, rn
        from Z_FINSOURCES
        where version = pVERSION
        and JUR_PERS = pJURPERS
        order by name
      )
      loop
        begin
            select sum(n002) into nSUMM
            from APEX_collections
            where collection_name = 'DETAIL'
                and n001 = pORGRN
                and n003 = rec.rn
            group by n003;
        exception when NO_DATA_FOUND then
            nSUMM := 0;
        end;


          htp.p('<tr>
                 <td class="c1 " style="border-left:1px solid #ccc"><div class="c1">'||rec.name||'</div></td>
                 <td class="c2 " style="border-left:1px solid #ccc"><div class="c2">'||to_char(nSUMM,'999G999G999G999G990D00')||'</div></td>
                 </tr>');
      end loop;
/*

      for rec in
      (
		select c001 as FINNAME,
            SUM(n002) as FINSUM
		from APEX_collections
        where collection_name = 'DETAIL'
            and n001 = pORGRN
        group by c001
      )
      LOOP
         htp.p('<tr>
				  <td class="c1 " style="border-left:1px solid #ccc"><div class="c1">'||rec.FINNAME||'</div></td>
				  <td class="c2 " style="border-left:1px solid #ccc"><div class="c2">'||to_char(rec.FINSUM,'999G999G999G999G990D00')||'</div></td>
                </tr>');
              count_rows:=count_rows + 1;
      END LOOP;
*/

      htp.p('</tbody></table></div>');
      htp.p('<ul class="pagination" style="margin:0px">');
      htp.p('<li style="float:right;">Всего записей: <b>'||count_rows||'</b></li>');
      htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
      htp.p('<li style="float:left; " id="save_shtat"></li>');
      htp.p('<li style="clear:both"></li></ul>');

  htp.p('<script>
    var checks=[];
    function selectChek(value){

      if (checks.indexOf(value)===-1) {
      checks.push(value);
      } else {
      checks.splice(checks.indexOf(value),1);
      }
      console.log(checks);

     $("#P330_RN_ARR").val(checks);
    }
    function selectAll(){
    var elements = $("input.status");
     for(i in elements) {
      selectChek($(elements[i]).val());
      if($(elements[i]).is(":checked")) {
        $(elements[i]).prop("checked",false);
        } else {
        $(elements[i]).prop("checked",true);
        }
     }
    }
    function open_levels(obj) {
      if ($(".level1, .level2").css("display")==="block") {
        $(".level1, .level2").css("display","none");
        $(".down.up").removeClass("up");
      }
      else {
        $(".level1, .level2").css("display","block");
        $(".down").addClass("up");
      }
    }


    $(function(){
      table_body=$("#fullall");
      if (window.screen.height<=1024) {
      table_body.height("410px");
      $(".report_standard").css("width","100%");
      } else {
      table_body.height("410px");
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
            table_body.height(Math.max(32, staticOffset + e.pageY) + "px");
            return false;
          }

          function endDrag(e){
            $(document).unbind("mousemove", performDrag).unbind("mouseup", endDrag);
            table_body.css("opacity", 1);
          }


    });



  function ShowDialog2(id, orgrn) {
$.ajax({
        url: "wwv_flow.show",
        type: "POST",
        data: {
            p_request: "APPLICATION_PROCESS=dialog_" + id,
            p_flow_id: $("#pFlowId").val(),
            p_flow_step_id: $("#pFlowStepId").val(),
            p_instance: $("#pInstance").val(),
            x01: orgrn

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

  function save_data(rn, val, field, obj) {
      console.log(obj)

      apex.server.process("save_data", {
              x01: rn,
              x02: val,
              x03: field
          }, {
              //refreshObject: "#result",
             // loadingIndicator: "#save_data",
              success: function(data) {
                 if (data.status === ''good'') {
                      $(obj).css(''border-bottom'', ''1px solid green'');
                  } else {
                      $(obj).css(''border-bottom'', ''1px solid red'');
                  }
                  console.log(data);
              }
          });

  }


    var checks=[];
    function selectChek(value){

      if (checks.indexOf(value)===-1) {
      checks.push(value);
      } else {
      checks.splice(checks.indexOf(value),1);
      }
      console.log(checks);

     $("#P1301_RN_ARR").val(checks);
    }
    function selectAll(){
    var elements = $("input.status");
     for(i in elements) {
      selectChek($(elements[i]).val());
      if($(elements[i]).is(":checked")) {
        $(elements[i]).prop("checked",false);
        } else {
        $(elements[i]).prop("checked",true);
        }
     }
    }
    </script>
    <script>
$(document).ready(function(){
$("#P1301_ADD_EXPMATS").click(function(){
    $("#divLoading").addClass("show");
console.log("asd");
});
});
</script>
    '
  );
end;
