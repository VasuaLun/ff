--101; 510; Z_PURPOSE_OUTCOME
declare
  pJURPERS      number        := :P1_JURPERS;
  pVERSION      number        := :P1_VERSION;
  pORGRN	    number        := nvl(:P1_ORGRN,:P7_ORGFILTER);
  pUSER         varchar2(100) := :APP_USER;
  pFUND         number        := :P510_FUND;
  pKBK          number        := :P510_KBK;

  -----------------------------------------------
  sNUMB         varchar2(4000);
  sPURPOSE      varchar2(4000);
  sNEXTSUM      varchar2(4000);
  sPLANSUM1     varchar2(4000);
  sPLANSUM2     varchar2(4000);
  sDELROW       varchar2(4000);
  sPASS         varchar2(4000);

  --
  sSTRSAVEBTN    varchar2(4000);
  sSTRBACK       varchar2(4000);
  sSTRNAMESTR    varchar2(4000);
  sADDEXP        varchar2(4000);
  sPLUS          varchar2(4000);

  -----------------------------------------------
  sDISABLED     varchar2(100);
  nCOUNTROWS    number;
  nCOUNTROWS1   number;
  nCOUNTROWS2   number;
  nCOUNTROWS3   number;
  nNEXTSUM      number;
  nPLANSUM1     number;
  nPLANSUM2     number;
begin

    if pORGRN is null then
        zp_exception(0,'Учреждение не выбрано. Выберите или закрепите учреждение.');
    end if;

    -- Инициализация
    ----------------------------------------------------
	begin
		select sum(NEXTSUM), sum(PLANSUM1), sum(PLANSUM2)
          into nNEXTSUM, nPLANSUM1, nPLANSUM2
		  from Z_PURPOSE_OUTCOME
		 where JUR_PERS = pJURPERS
		   and VERSION  = pVERSION
		   and ORGRN    = pORGRN
		   and KBK      = pKBK
		   and FUNDS    = pFUND;
	exception when others then
		nNEXTSUM   := null;
		nPLANSUM1  := null;
		nPLANSUM2  := null;
	end;
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
        .textarea {resize: vertical;text-align:left !important; }
        .in_txtr {width:99%; border: 1px solid #ccc;text-align:right;}
        .in_txtl {width:99%; border: 1px solid #ccc;text-align:left;}
        .in_txt2 {width:90%; border: 1px solid #ccc;text-align:right;}
        .group {font-weight:bold; background-color:#d4d9f5 !important}

        .link_code {font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}

        .th1{width: 30px;text-align:center;}    .c1 {width: 30px; word-wrap: break-word; text-align:center;}
        .th2{width: 100%;text-align:center;}    .c2 {width: 100%; word-wrap: break-word; text-align:left;}
        .th3{width: 100px;text-align:center;}   .c3 {width: 100px; word-wrap: break-word; text-align:center;}
		.th4{width: 100px;text-align:center;}   .c4 {width: 100px; word-wrap: break-word; text-align:center;}
		.th5{width: 100px;text-align:center;}   .c5 {width: 100px; word-wrap: break-word; text-align:center;}
        .th6{width: 30px;text-align:center;}    .c6 {width: 30px; word-wrap: break-word; text-align:center;}
        .th7{width: 30px;text-align:center;}    .c7 {width: 30px; word-wrap: break-word; text-align:center;}
        .c11 {width: 15px; word-wrap: break-word; text-align:left;}
        .c12 {width: 30px; word-wrap: break-word; text-align:left;}

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

    sSTRBACK    := '<span class="btn" style="float:right; margin-right:5px" onclick="location.href='''||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':413:'||:APP_SESSION)||'''">Назад</span>';
    sSTRSAVEBTN := '<span class="btn btn-primary"  style="float:right;margin-right:5px" onclick="apex.submit({showWait:true});">Сохранить</span>';
    sSTRNAMESTR  := '<div style="font-weight: bold;font-size: 14px;padding: 5px 3px;border-bottom: 1px solid #ccc;margin-bottom: 5px;">Цели расходов</div>';

	sADDEXP  := '<span class="btn btn-primary" style="float:right; margin-right:5px" onclick="javascript:apex.submit(''rADD'');">Добавить строку</span>';


    htp.p(
    '<div style="background: whitesmoke;padding: 10px;border: 1px solid #ccc;"><div>
        '||sSTRSAVEBTN||'
        '||sSTRBACK||'
		'||sADDEXP||'
        '||sSTRNAMESTR ||'
    </div>');


    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1 myCell" style="border-left:0px" ><div class="th1">№ п/п</div></th>
         <th class="header th2" ><div class="th2">Цели расходования</div></th>
		 <th class="header th3" ><div class="th3">Сумма на <br>очередной год</div></th>
		 <th class="header th4" ><div class="th4">Cумма на 1й год <br>план. периода</div></th>
         <th class="header th5" ><div class="th5">Cумма на 2й год <br>план. периода</div></th>
         <th class="header th6" ><div class="th6"></div></th>
         <th class="header th7" ><div class="th7"></div></th>
         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    htp.p('
        <tr>
            '||sNUMB||'
            '||sPURPOSE||'
            '||sNEXTSUM||'
			'||sPLANSUM1||'
            '||sPLANSUM2||'
            '||sDELROW||'
        </tr>');

	sNUMB     := '<td class="c1 group"><div class="c1"></></div></td>';
    sPURPOSE  := '<td class="c2 group"><div style="text-align:right" class="c2"></>ИТОГО</div></td>';
	sNEXTSUM  := '<td class="c3 group"><div style="text-align:right" class="c3"></>'||LTRIM(to_char(nNEXTSUM,'999G999G999G999G999G990D00'),' ')||'</div></td>';
	sPLANSUM1 := '<td class="c4 group"><div style="text-align:right" class="c4"></>'||LTRIM(to_char(nPLANSUM1,'999G999G999G999G999G990D00'),' ')||'</div></td>';
	sPLANSUM2 := '<td class="c5 group"><div style="text-align:right" class="c5"></>'||LTRIM(to_char(nPLANSUM2,'999G999G999G999G999G990D00'),' ')||'</div></td>';
    sPLUS     := '<td class="c7 group"><div class="c7"></></div></td>';
	sDELROW   := '<td class="c6 group"><div class="c6"></></div></td>';


	htp.p('
		<tr>
			'||sNUMB||'
			'||sPURPOSE||'
			'||sNEXTSUM||'
			'||sPLANSUM1||'
			'||sPLANSUM2||'
            '||sPLUS||'
			'||sDELROW||'
		</tr>');

    for rec in
    (
    select LEVEL, *
      from Z_PURPOSE_OUTCOME
    where JUR_PERS = pJURPERS
      and VERSION  = pVERSION
      and ORGRN    = pORGRN
      and KBK      = pKBK
      and FUNDS    = pFUND
      and PRN is NULL
    START WITH prn IS NULL
    connect by prior P.RN  = P.PRN
      ORDER SIBLINGS BY P.CREATED
    order by CREATED

    )

    for rec in
    (
     select *
       from Z_PURPOSE_OUTCOME
      where JUR_PERS = pJURPERS
        and VERSION  = pVERSION
        and ORGRN    = pORGRN
        and KBK      = pKBK
        and FUNDS    = pFUND
        and PRN is NULL
      order by CREATED
    )
    loop

        nCOUNTROWS  := nvl(nCOUNTROWS,0) + 1;

        nCOUNTROWS1  := nvl(nCOUNTROWS1,0) + 1;

        nCOUNTROWS2 := 0;

        sNUMB       := '<td class="c1"><div class="c1">'||nCOUNTROWS1||'</></div></td>';

		sPURPOSE     := '<td class="c2">
						  <div class="c2"><textarea '||sDISABLED||' placeholder="Введите цель расходования" rows="3" value="'||rec.PURPOSE||'" class="in_txtl textarea"
						      onfocus="selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''PURPOSE'', this);"/>'||rec.PURPOSE||'</textarea>
						  </div>
						  </td>';


        sNEXTSUM    := '<td class="c3">
                       <div class="c3"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.NEXTSUM,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                             onfocus="validate(this,''0'') ;selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''NEXTSUM'', this);"/>
                       </div>
                       </td>';

        sPLANSUM1   := '<td class="c4">
                       <div class="c4"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.PLANSUM1,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                             onfocus="validate(this,''0'') ;selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''PLANSUM1'', this);"/></div>
                       </td>';

        sPLANSUM2   := '<td class="c5">
                      <div class="c5"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec.PLANSUM2,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                            onfocus="validate(this,''0'') ;selecter(this,''row_'||rec.rn||''')" onblur="save_data('||rec.rn||',this.value, ''PLANSUM2'', this);"/></div>
                      </td>';

        -- Вариант удаления без всплывающего окна
        /*
        sDELROW := '<td class="c6">
                    <div class="c6"><a href= "f?p=&APP_ID.:510:'||:app_session||':rDEL:NO::P510_DELRN:'||rec.RN||'" style="font-weight: bold; text-align:right; color:#0000ff">
                        <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                    </div>
                    </td>';
        */

        -- Вариант удаления с всплывающем окном
        sDELROW := '<td class="c6"><div class="c6"><a href="javascript:apex.confirm(''Вы уверены, что хотите удалить цель расходования и подпункты?'', {request:''rDEL'', set:{''P510_DELRN'':'||rec.RN||'}});">
                        <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                    </div>
                    </td>';

        sPLUS :=    '<td class="c7" style="border-left:1px solid #ccc"><div class="c7"><a href="f?p=101:510:&APP_SESSION.:rADDROW:NO::P510_RN:'||rec.RN||'"><img style="width:12px" src="/i/FNDADD11.gif" title="Добавить строку" /></a></div></td>';

        htp.p('
            <tr>
                '||sNUMB||'
                '||sPURPOSE||'
                '||sNEXTSUM||'
    			'||sPLANSUM1||'
                '||sPLANSUM2||'
                '||sPLUS||'
                '||sDELROW||'
            </tr>');

        -- Вывод 2го уровня
        for rec2 in
        (
         select *
           from Z_PURPOSE_OUTCOME
          where JUR_PERS = pJURPERS
            and VERSION  = pVERSION
            and ORGRN    = pORGRN
            and KBK      = pKBK
            and FUNDS    = pFUND
            and PRN = rec.RN
          order by CREATED
        )
        loop

            nCOUNTROWS2  := nvl(nCOUNTROWS2,0) + 1;

            nCOUNTROWS3 := 0;

            sNUMB       := '<td class="c1"><div class="c1">'||nCOUNTROWS1||'.'||nCOUNTROWS2||'</></div></td>';

            sPASS       := '<td class="c11"><div class="c11"></></div></td>';

            sPURPOSE     := '<td class="c2" style="border-left:none">
                              <div class="c2"><textarea '||sDISABLED||' placeholder="Введите цель расходования" rows="3" value="'||rec2.PURPOSE||'" class="in_txtl textarea"
                                  onfocus="selecter(this,''row_'||rec2.rn||''')" onblur="save_data('||rec2.rn||',this.value, ''PURPOSE'', this);"/>'||rec2.PURPOSE||'</textarea>
                              </div>
                              </td>';


            sNEXTSUM    := '<td class="c3">
                           <div class="c3"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec2.NEXTSUM,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                 onfocus="validate(this,''0'') ;selecter(this,''row_'||rec2.rn||''')" onblur="save_data('||rec2.rn||',this.value, ''NEXTSUM'', this);"/>
                           </div>
                           </td>';

            sPLANSUM1   := '<td class="c4">
                           <div class="c4"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec2.PLANSUM1,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                 onfocus="validate(this,''0'') ;selecter(this,''row_'||rec2.rn||''')" onblur="save_data('||rec2.rn||',this.value, ''PLANSUM1'', this);"/></div>
                           </td>';

            sPLANSUM2   := '<td class="c5">
                          <div class="c5"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec2.PLANSUM2,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                onfocus="validate(this,''0'') ;selecter(this,''row_'||rec2.rn||''')" onblur="save_data('||rec2.rn||',this.value, ''PLANSUM2'', this);"/></div>
                          </td>';


            sDELROW := '<td class="c6"><div class="c6"><a href="javascript:apex.confirm(''Вы уверены, что хотите удалить цель расходования и подпункты?'', {request:''rDEL'', set:{''P510_DELRN'':'||rec2.RN||'}});">
                            <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                        </div>
                        </td>';

            sPLUS :=    '<td class="c7" style="border-left:1px solid #ccc"><div class="c7"><a href="f?p=101:510:&APP_SESSION.:rADDROW:NO::P510_RN:'||rec2.RN||'"><img style="width:12px" src="/i/FNDADD11.gif" title="Добавить строку" /></a></div></td>';

            htp.p('
                <tr>
                    '||sNUMB||'
                    '||sPASS||'
                    '||sPURPOSE||'
                    '||sNEXTSUM||'
        			'||sPLANSUM1||'
                    '||sPLANSUM2||'
                    '||sPLUS||'
                    '||sDELROW||'
                </tr>');

            for rec3 in
            (
             select *
               from Z_PURPOSE_OUTCOME
              where JUR_PERS = pJURPERS
                and VERSION  = pVERSION
                and ORGRN    = pORGRN
                and KBK      = pKBK
                and FUNDS    = pFUND
                and PRN = rec2.RN
              order by CREATED
            )
            loop

                nCOUNTROWS3  := nvl(nCOUNTROWS3,0) + 1;

                sNUMB       := '<td class="c1"><div class="c1">'||nCOUNTROWS1||'.'||nCOUNTROWS2||'.'||nCOUNTROWS3||'</></div></td>';

                sPASS       := '<td class="c12"><div class="c12"></></div></td>';

                sPURPOSE     := '<td class="c2" style="border-left:none">
                                  <div class="c2" padding-left: 10 px><textarea '||sDISABLED||' placeholder="Введите цель расходования" rows="3" value="'||rec3.PURPOSE||'" class="in_txtl textarea"
                                      onfocus="selecter(this,''row_'||rec3.rn||''')" onblur="save_data('||rec3.rn||',this.value, ''PURPOSE'', this);"/>'||rec3.PURPOSE||'</textarea>
                                  </div>
                                  </td>';


                sNEXTSUM    := '<td class="c3">
                               <div class="c3"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec3.NEXTSUM,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                     onfocus="validate(this,''0'') ;selecter(this,''row_'||rec3.rn||''')" onblur="save_data('||rec3.rn||',this.value, ''NEXTSUM'', this);"/>
                               </div>
                               </td>';

                sPLANSUM1   := '<td class="c4">
                               <div class="c4"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec3.PLANSUM1,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                     onfocus="validate(this,''0'') ;selecter(this,''row_'||rec3.rn||''')" onblur="save_data('||rec3.rn||',this.value, ''PLANSUM1'', this);"/></div>
                               </td>';

                sPLANSUM2   := '<td class="c5">
                              <div class="c5"><input '|| sDISABLED ||'  placeholder="0,00" type="text" value="'||LTRIM(to_char(rec3.PLANSUM2,'999G999G999G999G999G990D00'),' ')||'" class="in_txt2 decimal"
                                    onfocus="validate(this,''0'') ;selecter(this,''row_'||rec3.rn||''')" onblur="save_data('||rec3.rn||',this.value, ''PLANSUM2'', this);"/></div>
                              </td>';


                sDELROW := '<td class="c6"><div class="c6"><a href="javascript:apex.confirm(''Вы уверены, что хотите удалить цель расходования?'', {request:''rDEL'', set:{''P510_DELRN'':'||rec3.RN||'}});">
                                <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>
                            </div>
                            </td>';

                sPLUS := '<td class="c7"><div class="c7"></></div></td>';

                htp.p('
                    <tr>
                        '||sNUMB||'
                        '||sPASS||'
                        '||sPURPOSE||'
                        '||sNEXTSUM||'
            			'||sPLANSUM1||'
                        '||sPLANSUM2||'
                        '||sPLUS||'
                        '||sDELROW||'
                    </tr>');
            end loop;
        end loop;
    end loop;

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;">Всего записей: <b>'||nvl(nCOUNTROWS,0)||'</b></li>');
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
    </script>');
end;
