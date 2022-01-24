-- App 101
-- Page 520 - Перечень ВДК
--
declare --
  pJURPERS       number         := :P1_JURPERS;
  pVERSION       number         := :P1_VERSION;
  pUSER          varchar2(100)  := :APP_USER;
  -----------------------------------------------
  sNUMB       varchar2(4000);
  sPART       varchar2(4000);
  sPROCNAME   varchar2(4000);
  sERRTEXT    varchar2(4000);
  sVDKCOUNT   varchar2(4000);
  sCHECKSIGN  varchar2(4000);
  sERRTYPE    varchar2(4000);

  sBACK       varchar2(4000);
  sBUDGET     varchar2(4000);
  sADDVDK     varchar2(4000);
  -----------------------------------------------
  nCOUNTROWS  number;
begin

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
          padding: 4px 4px;
           /* background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 50% #e1e1e1 repeat-x;*/
          background: #e0e0e0;
          border-bottom: 1px solid #9fa0a0;
          border-left:1px solid #9fa0a0;
        }
        .report_standard td{
          padding: 4px 4px;
          border-bottom: 1px solid #9fa0a0;
          border-left:1px solid #9fa0a0;
          background-color: #f2f2f2;
        }

        .link_code {font-weight: bold; color:#0000ff;}

        .th1{width: 50px;text-align:center;}  .c1 {width: 50px; word-wrap: break-word; text-align:center;}
        .th2{width: 250px;text-align:center;} .c2 {width: 250px; word-wrap: break-word; text-align:left;}
        .th3{width: 250px;text-align:center;} .c3 {width: 250px; word-wrap: break-word; text-align:left;}
        .th4{width: 100%;text-align:center;}  .c4 {width: 100%; word-wrap: break-word; text-align:left;}

        .th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:center;}
        .th6{width: 100px;text-align:center;}  .c6 {width: 100px; word-wrap: break-word; text-align:center;}
        .th7{width: 120px;text-align:center;}  .c7 {width: 120px; word-wrap: break-word; text-align:center;}


        .pagination {text-align: right;
          border-top: 1px solid grey;
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

    apex_javascript.add_library (
    p_name                  => 'jquery.inputmask.bundle',
    p_directory             => '/i/');

	sBACK   := '<span class="btn" style="float:right; margin-right:10px" onclick="location.href='''||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':33:'||:APP_SESSION)||'''">Назад</span>';
	sBUDGET := '<div style="font-weight: bold;font-size: 16px;padding: 5px 3px;border-bottom: 1px solid #ccc;margin-bottom: 5px;">Перечень контролей ВДК</div>';
    sADDVDK  := '<span class="btn btn-primary" style="float:right;" onclick="location.href='''||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':521:'||:APP_SESSION ||'::NO:521:P521_RN:' )||'''">Добавить</span>';

	htp.p('<div style="background: whitesmoke;padding: 10px;border: 1px solid #ccc;"><div>
           '||sADDVDK||'
           '||sBACK||'
		   '||sBUDGET ||'
		   </div>'
		   );

    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1" rowspan="3"><div class="th1">№</div></th>
         <th class="header th2" rowspan="3"><div class="th2">Раздел</div></th>
         <th class="header th3" rowspan="3"><div class="th3">Процедура</div></th>
		 <th class="header th4" rowspan="3"><div class="th4">Текст ошибки</div></th>
         <th class="header th5" rowspan="3"><div class="th5">Привязан к отчетам	</div></th>
         <th class="header th6" rowspan="3"><div class="th6">Проверен</div></th>
         <th class="header th7" rowspan="3"><div class="th7">Тип</div></th>
		 <th class="header"><div style="width:8px"></div></th>
        </tr>
    </thead>
    <tbody id="fullall">');

    for rec in
    (
     select V.RN,
            V.NUMB,
            V.PART,
            V.ERRTEXT,
            V.PROCNAME,
       (select count(*) from Z_RPT_LIB_VDK_LINKS L where L.VDK_RN = V.RN) VDK_COUNT,
       case when nvl(CHECK_SIGN,0) = 1 then 'Да' end CHECK_SIGN,
       case V.ERRTYPE when 1 then '<span style="font-weight: bold; color:#ff0000">Ошибка</span>' when 2 then '<span style="font-weight: bold; color:#008000">Предупреждение</span>' end ERRTYPE
       from Z_RPT_LIB_VDK V
       order by lpad(V.numb,10), V.code
    )
    loop

        sNUMB       := '<td class="c1"><div class="c1">'||rec.NUMB||'</></div></td>';
        sPART       := '<td class="c2"><div class="c2"><a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':521:'||:APP_SESSION||'::::P521_RN,P520_SELECT_ROW:'||rec.RN||','||rec.RN)||'">'||rec.PART||'</a></div></td>';
        sPROCNAME   := '<td class="c3"><div class="c3">'||rec.PROCNAME||'</div></td>';
        sERRTEXT    := '<td class="c4"><div class="c4">'||rec.ERRTEXT||'</div></td>';
        sVDKCOUNT   := '<td class="c5"><div class="c5"><a href="javascript:ModalWin('||rec.RN||');">'||rec.VDK_COUNT||'</a></></div></td>';
        sCHECKSIGN  := '<td class="c6"><div class="c6">'||rec.CHECK_SIGN||'</></div></td>';
        sERRTYPE    := '<td class="c7"><div class="c7">'||rec.ERRTYPE||'</></div></td>';

        htp.p('
            <tr id="row_'||rec.RN||'">
                '||sNUMB||'
                '||sPART||'
                '||sPROCNAME||'
                '||sERRTEXT||'
                '||sVDKCOUNT||'
                '||sCHECKSIGN||'
                '||sERRTYPE||'
            </tr>');
        nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;
    end loop;

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;">Всего записей: <b>'||nCOUNTROWS||'</b></li>');
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

        var el = document.getElementById("row_"+$v("P520_SELECT_ROW"));
       if (el!==null){
        el.scrollIntoView(true);
         $(el).children().css("background-color","yellow");
       }

    </script>');
end;
