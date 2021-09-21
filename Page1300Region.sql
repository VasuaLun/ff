--101; 1300;
declare
 pJURPERS      number        := :P1_JURPERS;
 pVERSION      number        := :P1_VERSION;
 pSORT         number        := :P1300_SORT;

 pUSER         varchar2(100) := :APP_USER;
 pROLE         number        := ZGET_ROLE;
 bUSER_SUPPORT boolean       := ZF_USER_SUPPORT (pUSER);
 nUSER_SUPPORT number(1)	 := 0;
 bUSER_MANAGER boolean       := :APP_USER = 'MANAGER';

 -----------------------------------------------
 sORGTYPE      varchar2(4000);
 sORGNAME      varchar2(4000);
 sDISTRICT     varchar2(4000);
 sORGKIND      varchar2(4000);
 --
 sEXP_LIMIT     varchar2(4000);
 sEXP_PLAN     	varchar2(4000);
 sEXP_DIFF     	varchar2(4000);
 nEXP_DIFF		number(19,2);
 sIND_LIMIT     varchar2(4000);
 sIND_PLAN     	varchar2(4000);
 sIND_DIFF     	varchar2(4000);
 nIND_DIFF		number(19,2);

 nEXP_DIFF_PERC number(19,2);
 nIND_DIFF_PERC number(19,2);

 sCOLOR			varchar2(100);
 sNORMAIV     	varchar2(4000);
 sSTUDY     	varchar2(4000);
 sTEACHER     	varchar2(4000);
 sBALL    		varchar2(4000);
 sSOLV    		varchar2(4000);
 sNORMAIV1     	varchar2(4000);


 nIND_VAL		number(19,2);
 nIND_CACL		number(19,2);

 nPLANLIMSUM	number(19,2);
 nPLANSUM		number(19,2);
 nPLANOUTSUM    number(19,2);
 nPOST_FACT		number(19,2);
 nNORMAIV		number(19,2);
 --
 nFOTALL		number(19,2);
 nFOT1			number(19,2);
 nTEACHER		number(19,2);
 -----------------------------------------------
 nCOUNTROWS    number;
 NITEMCOL	   number;
 sNEW_ORGGROUP varchar2(300) := ' ';
 dLAST_LOGIN	date;
 SLAST_LOGIN   varchar2(300);
 nUSER_ACTIVE	number;
 sUSER_ACTIVE	varchar2(300);
--
 type CEXPGR is record
 (
   ORGRN   number,
   KVR     number,
   KOSGU   number,
   DOPKOSGU varchar2(20),
   FOTYPE2 number,
   EXPMAT  number,
   KBK_RN  number,
   PLANSUM number
 );

 type TEXPGR  is table of CEXPGR index by pls_integer;
 REXPGR       TEXPGR;



begin
	if bUSER_SUPPORT then nUSER_SUPPORT := 1; end if;

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
        .textarea {resize: vertical;text-align:left !important; }
        .in_txtr {width:95%; border: 1px solid #ccc;text-align:right;}
        .in_txtl {width:95%; border: 1px solid #ccc;text-align:left;}
        .in_txt2 {width:70%; border: 1px solid #ccc;text-align:right;}
        .group {font-weight:bold; background-color:#d4d9f5 !important}
        '||case when not bUSER_MANAGER then '.show{display:none;}' end||'
		'||case when not bUSER_SUPPORT then '.show2{display:none;}' end||'

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}

        .th1{width: 30px;text-align:center; border-left: 0px !important}    .c1 {width: 30px; word-wrap: break-word; text-align:center; border-left: 0px !important}
		.th2{width: 100%;text-align:center;}   .c2 {width: 100%; word-wrap: break-word; text-align:left;}
		.th3{width: 100px;text-align:center;}   .c3 {width: 100px; word-wrap: break-word; text-align:right;}
        .th4{width: 100px;text-align:center;}   .c4 {width: 100px; word-wrap: break-word; text-align:right;}
        .th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:right;}
		.th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:right;}
		.th5{width: 100px;text-align:center;}  .c5 {width: 100px; word-wrap: break-word; text-align:right;}
        .th6{width: 70px;text-align:center;}   .c6 {width: 70px; word-wrap: break-word; text-align:right;}
        .th7{width: 70px;text-align:center;}   .c7 {width: 70px; word-wrap: break-word; text-align:right;}
        .th8{width: 70px;text-align:center;}   .c8 {width: 70px; word-wrap: break-word; text-align:right;}
        .th9{width: 100px;text-align:center;}   .c9 {width: 100px; word-wrap: break-word; text-align:right;}
		.th10{width: 80px;text-align:center;}  .c10 {width: 80px; word-wrap: break-word; text-align:right;}
		.th11{width: 80px;text-align:center;}  .c11 {width: 80px; word-wrap: break-word; text-align:right;}
		.th12{width: 30px;text-align:center;}  .c12 {width: 30px; word-wrap: break-word; text-align:center;}
		.th13{width: 150px;text-align:center;}  .c13 {width: 150px; word-wrap: break-word; text-align:left;}

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
         <th class="header th1"  rowspan="2"><div class="th1">Тип</div></th>
         <th class="header th2"  rowspan="2"><div class="th2"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 1 then ''|| -1 ||'' when pSORT = -1 then ''|| 0 ||'' else ''|| 1 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Учреждение'
         ||case when pSORT = 1 then ' ↓' end || case when pSORT = -1 then ' ↑' end||'</span></a></div></td>
         <th colspan="3"><div>Затраты</div></th>
         <th colspan="3"><div>Контингент</div></th>
         <th class="header th9"  rowspan="2"><div class="th9"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 8 then ''|| -8 ||'' when pSORT = -8 then ''|| 0 ||'' else ''|| 8 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Расч.норматив на 1 обуч.'
         ||case when pSORT = 8 then ' <img src="/i/arrow_up_green_48.png" style="width:16px;"/>' end || case when pSORT = -8 then ' ↑' end||'</span></a></div></td>
         <th class="header th10"  rowspan="2"><div class="th10"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 9 then ''|| -9 ||'' when pSORT = -9 then ''|| 0 ||'' else ''|| 9 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Кол-во обуч. на 1 препод.'
         ||case when pSORT = 9 then ' ↓' end || case when pSORT = -9 then ' ↑' end||'</span></a></div></td>
         <th class="header th11"  rowspan="2"><div class="th11"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 10 then ''|| -10 ||'' when pSORT = -10 then ''|| 0 ||'' else ''|| 10 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Доля педаг.раб.%'
         ||case when pSORT = 10 then ' ↓' end || case when pSORT = -10 then ' ↑' end||'</span></a></div></td>
         <th class="header th12" rowspan="2"><div class="th12">Инд</div></th>
         <th class="header th13" rowspan="2"><div class="th13">Решение</div></th>
         <th class="header" rowspan="2"><div style="width:8px"></div></th>

        </tr>

        <tr>
        <th class="header th3"><div class="th3"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 2 then ''|| -2 ||'' when pSORT = -2 then ''|| 0 ||'' else ''|| 2 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Лимит'
        ||case when pSORT = 2 then ' ↓' end || case when pSORT = -2 then ' ↑' end||'</span></a></div></td>
        <th class="header th4"><div class="th4"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 3 then ''|| -3 ||'' when pSORT = -3 then ''|| 0 ||'' else ''|| 3 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">План'
        ||case when pSORT = 3 then ' ↓' end || case when pSORT = -3 then ' ↑' end||'</span></a></div></td>
        <th class="header th5"><div class="th5"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 4 then ''|| -4 ||'' when pSORT = -4 then ''|| 0 ||'' else ''|| 4 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Расхождение'
        ||case when pSORT = 4 then ' ↓' end || case when pSORT = -4 then ' ↑' end||'</span></a></div></td>
        <th class="header th6"><div class="th6"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 5 then ''|| -5 ||'' when pSORT = -5 then ''|| 0 ||'' else ''|| 5 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Лимит'
        ||case when pSORT = 5 then ' ↓' end || case when pSORT = -5 then ' ↑' end||'</span></a></div></td>
        <th class="header th7"><div class="th7"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 6 then ''|| -6 ||'' when pSORT = -6 then ''|| 0 ||'' else ''|| 6 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">План'
        ||case when pSORT = 6 then ' ↓' end || case when pSORT = -6 then ' ↑' end||'</span></a></div></td>
        <th class="header th8"><div class="th8"><a href="f?p=101:1300:'||v('APP_SESSION')||'::NO::P1300_SORT:'||case when pSORT = 7 then ''|| -7 ||'' when pSORT = -7 then ''|| 0 ||'' else ''|| 7 ||'' end||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">Расхожд'
        ||case when pSORT = 7 then ' ↓' end || case when pSORT = -7 then ' ↑' end||'</span></a></div></td>
        </tr>


      </thead>
    <tbody id="fullall" >');

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for rec in
    (
        select c001, to_number(c002) as ORGRN, c003, to_number(c004) as POST_FACT, to_number(c005) as EXP_DIFF, to_number(c006) as IND_DIFF, to_number(c007) as NORMAIV, n001, n002, n003, n004, c008, c009, c010, c011, c012, c013, c014, c015, c016, c017, c018, c019, c020, to_number(c021) as TRACHER
        from APEX_collections where collection_name = 'DATANAL'
        order by
        case when pSORT = 1  then c003     end asc,
        case when pSORT = -1 then c003     end desc,
        case when pSORT = 2  then n001     end asc,
        case when pSORT = -2 then n001     end desc,
        case when pSORT = 3  then n002     end asc,
        case when pSORT = -3 then n001     end desc,
        case when pSORT = 4  then EXP_DIFF end asc,
        case when pSORT = -4 then EXP_DIFF end desc,
        case when pSORT = 5  then n003     end asc,
        case when pSORT = -5 then n003     end desc,
        case when pSORT = 6  then n004     end asc,
        case when pSORT = -6 then n004     end desc,
        case when pSORT = 7  then IND_DIFF end asc,
        case when pSORT = -7 then IND_DIFF end desc,
        case when pSORT = 8  then NORMAIV  end asc,
        case when pSORT = -8 then NORMAIV  end desc,
        case when pSORT = 9  then POST_FACT  end asc,
        case when pSORT = -9 then POST_FACT  end desc,
        case when pSORT = 10  then TRACHER  end asc,
        case when pSORT = -10 then TRACHER  end desc,
        case when pSORT = 0 then c001 end
    )
    loop
        nCOUNTROWS := nvl(nCOUNTROWS, 0) + 1;
        htp.p('
            <tr>
                '||rec.c008||'
                '||rec.c009||'
                '||rec.c010||'
                '||rec.c011||'
                '||rec.c012||'
                '||rec.c013||'
                '||rec.c014||'
                '||rec.c015||'
                '||rec.c016||'
                '||rec.c017||'
                '||rec.c018||'
                '||rec.c019||'
                '||rec.c020||'
            </tr>');

    end loop;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



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

		function selecter(obj,rownum)
		{
		$("#fix").find("tr").removeClass("selected");
		$("#fix").find("tr[row="+rownum+"]").addClass("selected");
		$("#fix tr").removeClass("selected");
		$(obj).parent("div").parent("td").parent("tr").addClass("selected");
		}
    </script>');
end;
