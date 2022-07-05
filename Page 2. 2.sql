--210; 2;
declare
    sNUMBP        varchar2(4000);
    sTICKETTYPE   varchar2(4000);
    sNUMB         varchar2(4000);
    sTEXT         varchar2(4000);
    sUSER_AUTHOR  varchar2(4000);
    sDATE_CREATE  varchar2(4000);
    sEXEUSER      varchar2(4000);
    sFILE         varchar2(4000);
    sSTATUS       varchar2(4000);

    sREAD        varchar2(4000);
    sIMAGE       varchar2(100);
    sTYPECODE    varchar2(30);
    -----------------------------------------------
    nUSER         number := ZF_GET_USERRN;
    nROLE         number := ZGET_ROLE;
    nJURPERS      number;
    nORGRN        number;
    nREAD         number;
    -----------------------------------------------
    nCOUNTROWS    number;
    -----------------------------------------------
    sColor        varchar2(100);
    sMSG  	      varchar2(250);
begin

    -- Инициализация
    begin
        select JUR_PERS, ORG
        into nJURPERS, nORGRN
        from Z_USERS
        where RN = nUSER;
    exception when others then
        nJURPERS := null;
        nORGRN   := null;
    end;

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
        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}

        .th1{width: 40px;text-align:center; border-left: 0px !important} .c1 {width: 40px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 50px;text-align:center;}   .c2  {width: 50px; word-wrap: break-word; text-align:center;}
        .th3{width: 50px;text-align:center;}   .c3  {width: 50px; word-wrap: break-word; text-align:left;}
        .th4{width: 90px;text-align:center;}   .c4  {width: 90px; word-wrap: break-word; text-align:right;}
        .th5{width: 100%;text-align:center;}   .c5  {width: 100%; word-wrap: break-word; text-align:left;}
        .th6{width: 180px;text-align:center;}  .c6  {width: 180px; word-wrap: break-word; text-align:left;}
        .th7{width: 130px;text-align:center;}  .c7  {width: 130px; word-wrap: break-word; text-align:center;}
        .th8{width: 130px;text-align:center;}  .c8  {width: 130px; word-wrap: break-word; text-align:center;}
        .th9{width: 130px;text-align:center;}  .c9  {width: 130px; word-wrap: break-word; text-align:left;}
        .th10{width: 130px;text-align:center;} .c10 {width: 130px; word-wrap: break-word; text-align:centre;}
        .th11{width: 130px;text-align:center;} .c11 {width: 130px; word-wrap: break-word; text-align:left;}
        .th12{width: 130px;text-align:center;} .c12 {width: 130px; word-wrap: break-word; text-align:right;}


        .pagination {text-align: right;
          border-left: 1px solid grey;
          border-right: 1px solid greМы y;
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

    -- <th class="header th4" ><div class="th4" >Адресат</div></th>
    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1" ><div class="th1">п/п</div></th>
         <th class="header th2" ><div class="th2">Тип</div></th>
         <th class="header th3" ><div class="th3">Номер</div></th>
         <th class="header th5" ><div class="th5">Сообщение</div></th>
         <th class="header th7" ><div class="th6">Автор</div></th>
         <th class="header th8" ><div class="th7">Создано</div></th>
         <th class="header th9" ><div class="th8">Изменено</div></th>
         <th class="header th10"><div class="th9">Назначен</div></th>
		 <th class="header th11"><div class="th10">Файл</div></th>
         <th class="header th12"><div class="th11">Статус</div></th>
         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    for MESS in
    (
        select RN,
               TICKETTYPE, NUMB,
               MESSAGE_TEXT_NOHTML TEXT,
               USER_AUTHOR,
               DATE_CREATE,
               EXEUSER,
               STATUS,
               nvl(IS_CLOSED, 0) IS_CLOSED,
               nvl(IS_READ, 0) IS_READ
        from M_MESSAGES
        where prn is null
            and (to_char(NUMB) like '%'||:P2_NUMBER||'%' or :P2_NUMBER is null)
            and ((ROLE_TO = nROLE or ROLE_FROM = nROLE) and (nJURPERS = JURPERS and ((nORGRN = AORG and nROLE = 2) or nROLE = 1) or nROLE = 0))
            and (JURPERS = :P2_JURPERS or :P2_JURPERS is null)
        order by NUMB desc
    )
    loop
        nCOUNTROWS := nvl(nCOUNTROWS, 0) + 1;
        sREAD      := null;
        nREAD      := 0;

        begin
            select RN
            into nREAD
            from M_MESSAGES
            where (prn = MESS.RN)
                and ROLE_TO = nROLE
                and IS_READ = 0
            and rownum = 1;
        exception when others then
            nREAD := 0;
        end;

        if nREAD > 0 then 
            sREAD := 'style="font-weight:bold"'; 
        end if;
        
        sUSER_AUTHOR := ZF_USER_NAME(MESS.USER_AUTHOR);

        -- закинуть в основной запрос
        begin
            select IMG_NAME, CODE
            into sIMAGE, sTYPECODE
            from MCTICKETTYPE
            where RN = MESS.TICKETTYPE;
        exception when others then 
            sIMAGE    := null;
            sTYPECODE := null;
        end;

        sNUMBP       := '<td class="c1" ><div class="c1"><a href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':3:'||:APP_SESSION||'::::P3_MESS_RN:'||MESS.RN||'')||'" class = "link_code"><div style="width:33px; height:33px; background:url(&APP_IMAGES.'||case MESS.IS_CLOSED when 0 then 'mail-ic.png' else 'mail-ic-close.png' end||');" title="Сообщение"></div></a></div></td>';
        sTICKETTYPE  := '<td class="c2" ><div class="c2"><div style="width:30px; height:30px; background:url(&APP_IMAGES.'||sIMAGE||');" title="'||sTYPECODE||'"></div></div></td>';
        sNUMB        := '<td class="c3" ><div class="c3">' ||MESS.NUMB       ||'</div></td>';
        sTEXT        := '<td class="c5" ><div class="c5">' ||MESS.TEXT       ||'</div></td>';
        sUSER_AUTHOR := '<td class="c6" ><div class="c6">' ||sUSER_AUTHOR||'</div></td>';
        sDATE_CREATE := '<td class="c7" ><div class="c7">' ||to_char(MESS.DATE_CREATE,'dd.mm.yyyy')||'</div></td>';
        sDATE_CREATE := '<td class="c8" ><div class="c8">' ||to_char(MESS.DATE_CREATE,'dd.mm.yyyy')||'</div></td>';
        sEXEUSER     := '<td class="c9" ><div class="c9">' ||MESS.EXEUSER    ||'</div></td>';
        sFILE        := '<td class="c10"><div class="c10">'||'MESS.FILE'     ||'</div></td>';
        sSTATUS      := '<td class="c11"><div class="c11">'||MF_GETSTATUS_NAME(pSTATUS => MESS.STATUS)||'</div></td>';

        if nCOUNTROWS < 100 then
            htp.p('<tr '||sREAD||' id="row_'||MESS.RN||'" row="'||MESS.RN||'">
                    '||sNUMBP      ||'
                    '||sTICKETTYPE ||'
                    '||sNUMB       ||'
                    '||sTEXT       ||'
                    '||sUSER_AUTHOR||'
                    '||sDATE_CREATE||'
                    '||sDATE_CREATE||'
                    '||sEXEUSER    ||'
                    '||sFILE       ||'
                    '||sSTATUS     ||'
        		   </tr>');
        end if;
	  end loop;

  if nvl(nCOUNTROWS,0) > 100 then
		sColor := 'font-weight:regular;color:red';
		sMSG := 'Выбрано слишком много записей. Отображены первые 100 из '||nCOUNTROWS||'. Необходимо использовать фильтры.';
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

        var el = document.getElementById("row_"+$v("P2_SELECTED_ROW"));
		if (el!==null){
		 el.scrollIntoView(true);
		  $(el).children().css("background-color","yellow");
		}

    </script>');
end;
