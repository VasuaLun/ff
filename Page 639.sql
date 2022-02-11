--101; 639;
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;

 -----------------------------------------------
 sCHECK        varchar2(4000);
 sNUMB         varchar2(4000);
 sNAME         varchar2(4000);
 sNOTE         varchar2(4000);

 -----------------------------------------------
 nCOUNTROWS    number;

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

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}


        .th1{width: 50px;text-align:center; border-left: 0px !important} .c1 {width: 50px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 70px;text-align:center;}  .c2 {width: 70px; word-wrap: break-word; text-align:left;}
        .th3{width: 100%;text-align:center;}  .c3 {width: 100%; word-wrap: break-word; text-align:left;}
        .th4{width: 450px;text-align:center;} .c4 {width: 450px; word-wrap: break-word; text-align:left;}


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
         <th class="header th1" ><div class="th1"></div></th>
         <th class="header th2" ><div class="th2">№</div></th>
         <th class="header th3" ><div class="th3">Краткое наименование</div></th>
         <th class="header th4" ><div class="th4">Полное Наименование</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    for rec in (
        select
            RN,
            NUMB,
            NAME,
            NOTE
        from Z_SUBTYPE
        where JURPERS = :P1_JURPERS
            and VERSION = :P1_VERSION
        order by NUMB
    )
    loop
        nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

        sCHECK := '<td class="c1"><div class="c1">-</div></td>';
        sNUMB  := '<td class="c2"><div class="c2">'||rec.NUMB||'</div></td>';
        sNUMB:= '<td class="c2 " style="border-left:1px solid #ccc"><div class="c2"><textarea placeholder="-" rows="2" value="'||rec.NUMB||'" class="in_txt2 textarea"
      onfocus="selecter(this,''row_'||rec.RN||''')" onblur="save_data('||rec.RN||',this.value, ''NUMB'', this);"/>'||rec.NUMB||'</textarea></div></td>';
        sNAME  := '<td class="c3"><div class="c3">'||rec.NAME||'</div></td>';
        sNOTE  := '<td class="c4"><div class="c4">'||rec.NOTE||'</div></td>';

        htp.p('
            <tr>
                '||sCHECK||'
                '||sNUMB||'
                '||sNAME||'
                '||sNOTE||'
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

    </script>');
end;


sBTN := '<a style="font-weight:bold; color:blue; text-decoration:underline;float:center" onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin('||RN||',0);')||'''">Ссылка</a>';
