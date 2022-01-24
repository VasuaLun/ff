-- Page 1501
declare
  count_rows    number(17) := 0;
  sExists		varchar(250);

  nCOUNTLINK   number;

  sCHECKBOX    varchar2(4000);
  sPROCNAME    varchar2(4000);
  sNUMB        varchar2(4000);
  sVERSIONAME  varchar2(4000);
  sJURNAME     varchar2(4000);
  sSTATUS      varchar2(4000);
  sBaloon      varchar2(4000);

begin

  if :P1501_PRN is null THEN zp_exception(0, 'Выберите ВДК');
  else
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

        .th0{width: auto;text-align:center;}  .c0 {width: auto; word-wrap: break-word; text-align:center;}
        .th1{width: 100px;text-align:center;} .c1 {width: 100px; word-wrap: break-word; text-align:center;}
        .th2{width: 100%; text-align:center;} .c2 {width: 100%; word-wrap: break-word;text-align:left;}
        .th3{width: 200px;text-align:center;}   .c3 {width: 200px; word-wrap: break-word; text-align:left;}
        .th4{width: 200px;text-align:center;}   .c4 {width: 200px; word-wrap: break-word; text-align:left;}
        .th5{width: 70px;text-align:center;}    .c5 {width: 70px; word-wrap: break-word; text-align:center;}


        .th_plan{width: 40px;text-align:center;} .c_plan {width: 40px; word-wrap: break-word; text-align:center;}
        .th_kv{width: 40px;text-align:center;}   .c_kv {width: 40px; word-wrap: break-word; text-align:center;}

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
             <th class="header th0"  style="border-left:none;"><div class="th0"><input type="checkbox" onclick="selectAll()"/></div></th>
             <th class="header th1" ><div class="th1">Код отчета</div></th>
    		 <th class="header th2" ><div class="th2">Процедура отчета</div></th>
    		 <th class="header th3" ><div class="th3">ГРБС</div></th>
             <th class="header th4" ><div class="th4">Версия</div></th>
             <th class="header th5" ><div class="th5">Статус</div></th>

           <th class="header" ><div style="width:8px"></div></th>
          </thead>
        <tbody id="fullall">
      ');

      FOR rec in
      (
        select distinct D.RN RN,
            D.PROC_NAME PROCNAME,
            D.NUMB NUMB,
            V.NAME VERSIONAME,
            J.NAME JURNAME,
            case when :P1501_CONNECTED = 1 then L.USE_SIGN
            else 5 end USED
        from Z_RPT_LIB_DETAIL D,
            Z_RPT_LIB_VDK_LINKS L,
            Z_JURPERS J,
            Z_VERSIONS V
        where D.RN = L.LIBDET_RN
            and ((L.VDK_RN != :P1501_PRN and :P1501_CONNECTED = 2)
                or (L.VDK_RN = :P1501_PRN and :P1501_CONNECTED = 1)
                or (:P1501_CONNECTED = 0))
            and D.VERSION = V.RN (+)
            and D.JURPERS = J.RN (+)
            and (D.JURPERS = :P1501_JUR or :P1501_JUR = 0)
            and (V.NEXT_PERIOD = :P1501_VERSION or :P1501_VERSION is null)
            and ((upper(D.PROC_NAME) like '%'||upper(:P1501_FIND)||'%') or (D.NUMB like '%'||:P1501_FIND||'%') or :P1501_FIND is null)
        order by D.PROC_NAME
      )
      loop

        if :P1501_CONNECTED = 2 then
            select nvl(count(RN), 0) into nCOUNTLINK from Z_RPT_LIB_VDK_LINKS where VDK_RN = :P1501_PRN and LIBDET_RN = rec.RN;
        end if;

        if nvl(:P1501_CONNECTED, 0) != 2 or nCOUNTLINK = 0 then

            if rec.USED = 1 then
                sBaloon := '<img src="/i/green.png" title="ВДК включен" style="width:16px;"/>';
            elsif rec.USED != 5 then
                sBaloon := '<img src="/i/red.png" title="ВДК отключен" style="width:16px;"/>';
            else
                sBaloon := '-';
            end if;

            sCHECKBOX   := '<td class="c0"><div class="c0" style="text-align:center"><input type="checkbox" value="'||rec.rn||'" id="status_'||rec.rn||'" class="status" onclick="selectChek($(this).val());"/></div></td>';
            sNUMB       := '<td class="c1" style="border-left:1px solid #ccc"><div class="c1">'||rec.NUMB||'</div></td>';
            sPROCNAME   := '<td class="c2" style="border-left:1px solid #ccc"><div class="c2">'||rec.PROCNAME||'</div></td>';
            sVERSIONAME := '<td class="c3" style="border-left:1px solid #ccc"><div class="c3">'||rec.VERSIONAME||'</div></td>';
            sJURNAME    := '<td class="c4" style="border-left:1px solid #ccc"><div class="c4">'||rec.JURNAME||'</div></td>';
            sSTATUS     := '<td class="c5" style="border-left:1px solid #ccc"><div class="c5">'||sBaloon||'</div></td>';

            htp.p('<tr id="row_'||rec.RN||'" row="'||rec.RN||'">
                    '||sCHECKBOX||'
                    '||sNUMB||'
                    '||sPROCNAME||'
                    '||sJURNAME||'
                    '||sVERSIONAME||'
                    '||sSTATUS||'
                </tr>');

            count_rows := count_rows + 1;
        end if;

      end loop;

      htp.p('</tbody></table></div>');
      htp.p('<ul class="pagination" style="margin:0px">');
      htp.p('<li style="float:right;">Всего записей: <b>'||count_rows||'</b></li>');
      htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
      htp.p('<li style="float:left; " id="save_shtat"></li>');
      htp.p('<li style="clear:both"></li></ul>');


      htp.p('<script>

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


        var checks=[];
        function selectChek(value){

          if (checks.indexOf(value)===-1) {
          checks.push(value);
          } else {
          checks.splice(checks.indexOf(value),1);
          }
          console.log(checks);

         $("#P1501_RN_ARR").val(checks);
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
      $("#P2011_ADD_EXPMATS").click(function(){
          $("#divLoading").addClass("show");
      console.log("asd");
      });
      });
      </script>
        '
      );
  end if;
end;
