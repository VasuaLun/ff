--101; 3030;
declare
 -----------------------------------------------
 sNUMB         varchar2(4000);
 sNAME         varchar2(4000);
 sUSER         varchar2(4000);
 sDOWNLOAD     varchar2(4000);
 sDATE         varchar2(4000);
 sSTATUS       varchar2(4000);
 sFILEDATA     varchar2(4000);

 -----------------------------------------------
 Sv1           varchar2(4000);
 Sv2           varchar2(4000);
 Sv3           varchar2(4000);
 Sv4           varchar2(4000);
 Sv5           varchar2(4000);
 Sv6           varchar2(4000);
 Sv7           varchar2(4000);
 Sv8           varchar2(4000);
 Sv9           varchar2(4000);
 Sv10          varchar2(4000);
 Sv11          varchar2(4000);
 Sv12          varchar2(4000);
 Sv13          varchar2(4000);
 Sv14          varchar2(4000);
 Sv15          varchar2(4000);
 Sv16          varchar2(4000);
 Sv17          varchar2(4000);
 Sv18          varchar2(4000);
 Sv19          varchar2(4000);
 Sv20          varchar2(4000);
 Sv21          varchar2(4000);
 Sv22          varchar2(4000);
 Sv23          varchar2(4000);
 Sv24          varchar2(4000);
 Sv25          varchar2(4000);
 Sv26          varchar2(4000);
 Sv27          varchar2(4000);
 Sv28          varchar2(4000);
 Sv29          varchar2(4000);
 Sv30          varchar2(4000);
 Sv31          varchar2(4000);
 Sv32          varchar2(4000);
 Sv33          varchar2(4000);
 Sv34          varchar2(4000);
 Sv35          varchar2(4000);
 Sv36          varchar2(4000);
 Sv37          varchar2(4000);
 Sv38          varchar2(4000);
 Sv39          varchar2(4000);
 Sv40          varchar2(4000);
 Sv41          varchar2(4000);
 Sv42          varchar2(4000);
 Sv43          varchar2(4000);
 Sv44          varchar2(4000);
 Sv45          varchar2(4000);
 Sv46          varchar2(4000);
 Sv47          varchar2(4000);
 Sv48          varchar2(4000);
 Sv49          varchar2(4000);
 Sv50          varchar2(4000);

 nCOUNTROWS    number;
 nCOUNTRES     number;
 nTOTALSUM     number;
 nITEMROW      number;
 nPREVFOTYPE2  number;

 nRES          number;

 sColor        varchar2(100);
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
        '||case when nvl(nCOUNTRES,0) = 0 then '.show{display:none;}' end||'

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}


        .th1{width: 130px;text-align:center; border-left: 0px !important} .c1 {width: 130px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 130px;text-align:center;}  .c2 {width: 130px; word-wrap: break-word; text-align:left;}
        .Svth{width: 2%;text-align:center;} .Svc {width: 2%; word-wrap: break-word; text-align:center;}


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
        <th class="header th1" ><div class="th1">RN</div></th>
         <th class="header th2" ><div class="th2">IDENT</div></th>

         <th class="header Svth" ><div class="Svth">Sv1</div></th>
         <th class="header Svth" ><div class="Svth">Sv2</div></th>
         <th class="header Svth" ><div class="Svth">Sv3</div></th>
         <th class="header Svth" ><div class="Svth">Sv4</div></th>
         <th class="header Svth" ><div class="Svth">Sv5</div></th>
         <th class="header Svth" ><div class="Svth">Sv6</div></th>
         <th class="header Svth" ><div class="Svth">Sv7</div></th>
         <th class="header Svth" ><div class="Svth">Sv8</div></th>
         <th class="header Svth" ><div class="Svth">Sv9</div></th>
         <th class="header Svth" ><div class="Svth">Sv10</div></th>
         <th class="header Svth" ><div class="Svth">Sv11</div></th>
         <th class="header Svth" ><div class="Svth">Sv12</div></th>
         <th class="header Svth" ><div class="Svth">Sv13</div></th>
         <th class="header Svth" ><div class="Svth">Sv14</div></th>
         <th class="header Svth" ><div class="Svth">Sv15</div></th>
         <th class="header Svth" ><div class="Svth">Sv16</div></th>
         <th class="header Svth" ><div class="Svth">Sv17</div></th>
         <th class="header Svth" ><div class="Svth">Sv18</div></th>
         <th class="header Svth" ><div class="Svth">Sv19</div></th>
         <th class="header Svth" ><div class="Svth">Sv20</div></th>
         <th class="header Svth" ><div class="Svth">Sv21</div></th>
         <th class="header Svth" ><div class="Svth">Sv22</div></th>
         <th class="header Svth" ><div class="Svth">Sv23</div></th>
         <th class="header Svth" ><div class="Svth">Sv24</div></th>
         <th class="header Svth" ><div class="Svth">Sv25</div></th>
         <th class="header Svth" ><div class="Svth">Sv26</div></th>
         <th class="header Svth" ><div class="Svth">Sv27</div></th>
         <th class="header Svth" ><div class="Svth">Sv28</div></th>
         <th class="header Svth" ><div class="Svth">Sv29</div></th>
         <th class="header Svth" ><div class="Svth">Sv30</div></th>
         <th class="header Svth" ><div class="Svth">Sv31</div></th>
         <th class="header Svth" ><div class="Svth">Sv32</div></th>
         <th class="header Svth" ><div class="Svth">Sv33</div></th>
         <th class="header Svth" ><div class="Svth">Sv34</div></th>
         <th class="header Svth" ><div class="Svth">Sv35</div></th>
         <th class="header Svth" ><div class="Svth">Sv36</div></th>
         <th class="header Svth" ><div class="Svth">Sv37</div></th>
         <th class="header Svth" ><div class="Svth">Sv38</div></th>
         <th class="header Svth" ><div class="Svth">Sv39</div></th>
         <th class="header Svth" ><div class="Svth">Sv40</div></th>
         <th class="header Svth" ><div class="Svth">Sv41</div></th>
         <th class="header Svth" ><div class="Svth">Sv42</div></th>
         <th class="header Svth" ><div class="Svth">Sv43</div></th>
         <th class="header Svth" ><div class="Svth">Sv44</div></th>
         <th class="header Svth" ><div class="Svth">Sv45</div></th>
         <th class="header Svth" ><div class="Svth">Sv46</div></th>
         <th class="header Svth" ><div class="Svth">Sv47</div></th>
         <th class="header Svth" ><div class="Svth">Sv48</div></th>
         <th class="header Svth" ><div class="Svth">Sv49</div></th>
         <th class="header Svth" ><div class="Svth">Sv50</div></th>

         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

	for rec in (
        select * from Z_XML_PARSDATE
        where IDENT = :P3032_PRN
        order by RN asc
    )
	loop
        nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;
        htp.p('<tr>
        <td class="c1"><div class=c1">'||rec.RN||'</div></td>
        <td class="c2"><div class=c2">'||rec.IDENT||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv1||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv2||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv3||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv4||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv5||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv6||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv7||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv8||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv9||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv10||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv11||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv12||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv13||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv14||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv15||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv16||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv17||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv18||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv19||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv20||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv21||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv22||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv23||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv24||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv25||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv26||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv27||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv28||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv29||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv30||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv31||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv32||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv33||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv34||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv35||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv36||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv37||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv38||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv39||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv40||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv41||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv42||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv43||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv44||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv45||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv46||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv47||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv48||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv49||'</div></td>
        <td class="Svc"><div class="Svc">'||rec.Sv50||'</div></td>
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
          table_body.height("350px");
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

    </script>');
end;
