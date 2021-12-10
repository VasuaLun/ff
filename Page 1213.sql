--101; 1213; Z_ZKP_SPEC
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;
 pORGRN	       number         := nvl(:P1_ORGRN,:P7_ORGFILTER);

 pUSER         varchar2(100)  := :APP_USER;
 pROLE         number         := ZGET_ROLE;
 -----------------------------------------------
 nNUMB		   number;
 nTOTAL		   number;
 nTOTAL1       number;
 nTOTAL2       number;
 sZKP_TYPE	   varchar2(200);
 sZKP_STATUS   varchar2(200);
 sZKP_OBJECT   varchar2(100);
 dRDATE		   date;
 sKFO          varchar2(4000);
 sKBK          varchar2(4000);
 sKOSGU        varchar2(4000);
 sKVR	       varchar2(4000);
 sSERV         varchar2(4000);
 sSUBS         varchar2(4000);
 sKPGZ         varchar2(4000);
 sSPGZ         varchar2(4000);
 sCOUNT        varchar2(4000);
 sPRICE        varchar2(4000);
 sITOGO        varchar2(4000);
 sDELROW       varchar2(4000);
 sNEWROW       varchar2(4000);
 sDisabled	   varchar2(10) := null;

 sITOGOPLAN1    varchar2(4000);
 sITOGOPLAN2    varchar2(4000);

 sEXPFKR       varchar2(4000);
 sPROG         varchar2(4000);
 sSUBPROG      varchar2(4000);
 sMEANING      varchar2(4000);
 -----------------------------------------------
 nCOUNTROWS    varchar2(4000);
 nQUANT        Z_ZKP_SPECPRICE.QUANT%type;
 nPRICE        Z_ZKP_SPECPRICE.PRICE%type;
 nSUMMA        Z_ZKP_SPECPRICE.SUMMA%type;
 nSUMMA1       Z_ZKP_SPECPRICE.SUMMA%type;
 nSUMMA2       Z_ZKP_SPECPRICE.SUMMA%type;

begin
    -- Права доступа
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
        '||case when pORGRN is not null then '.show{display:none;}' end||'

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}

        .th1{width: 140px;text-align:center; border-left: 0px !important}    .c1 {width: 140px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 140px;text-align:center;}   .c2 {width: 140px; word-wrap: break-word; text-align:center;}
        .th3{width: 40px;text-align:center;}    .c3 {width: 40px; word-wrap: break-word; text-align:center;}
		.th31{width: 40px;text-align:center;}    .c31 {width: 40px; word-wrap: break-word; text-align:center;}
		.th4{width: 100%;text-align:center;}    .c4 {width: 100%; word-wrap: break-word; text-align:left;}

        .th5{width: 100px;text-align:center;}   .c5 {width: 100px; word-wrap: break-word; text-align:center;}
        .th6{width: 120px;text-align:center;}   .c6 {width: 120px; word-wrap: break-word; text-align:center;}
        .th7{width: 120px;text-align:center;}   .c7 {width: 120px; word-wrap: break-word; text-align:center;}

        .th8{width: 100px;text-align:center;}   .c8 {width: 100px; word-wrap: break-word; text-align:right;}
        .th9{width: 100px;text-align:center;}   .c9 {width: 100px; word-wrap: break-word; text-align:right;}

        <!-- Вот тут -->
        .th10{width: 100px;text-align:center;}  .c10 {width: 100px; word-wrap: break-word; text-align:right;}
        .th11{width: 30px;text-align:center;}   .c11 {width: 30px; word-wrap: break-word; text-align:center;}
        .th12{width: 30px;text-align:center;}   .c12 {width: 30px; word-wrap: break-word; text-align:center;}

		.all_itg{text-align:right;}
        .pagination {text-align: right;
          border-left: 1px solid grey;
          border-right: 1px solid grey;
          border-bottom: 1px solid grey;
          margin: 0px;

          padding: 5px;
          background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 100% #e1e1e1 repeat-x;cursor:move;
        }
		.part {margin-right:10px; font-weight:bold; color: #800000;}
        .pagination li {display: inline; margin-left:5px; font-size: 12px; padding: 2px; cursor:default; }
        .selected_row{padding: 4px 4px;
          border-bottom: 1px solid #9fa0a0;
          background-color: #FAFF82;
        }
    </style>');
	if not (:P1213_ZKP_RN is not null and ZF_REESTR_STATUS_GET(:P1_VERSION, :P1213_ZKP_RN, 'ZKP_REESTR') in (0, 3)) then
		sDisabled := 'disabled';
	end if;

	begin
		select NUMB, (select NAME from Z_LOV where PART='ZKP_TYPE' and NUM = Z.ZKP_TYPE) ZKP_TYPE, (select NAME from Z_LOV where PART='ZKP_STATUS' and NUM = Z.ZKP_STATUS) ZKP_STATUS, case when LENGTH(ZKP_OBJECT)<100 then ZKP_OBJECT else substr(ZKP_OBJECT, 0, 97)||'...' end ZKP_OBJECT, RDATE
		into nNUMB, sZKP_TYPE, sZKP_STATUS, sZKP_OBJECT, dRDATE
		from Z_ZKP Z
		where RN = :P1213_ZKP_RN;
	exception when others then
		zp_exception(0, 'Не удалось получить информацию о закупке');
	end;

	select sum(nvl(SUMMA, 0)), sum(nvl(SUMMA2, 0)), sum(nvl(SUMMA3, 0)) into nTOTAL, nTOTAL1, nTOTAL2 from Z_ZKP_SPECPRICE ZSP, Z_ZKP_SPEC ZS
	where ZSP.ZKP_RN = :P1213_ZKP_RN
	  and ZS.RN = ZSP.ZKP_SPEC_RN
	  and ZS.ZKP_RN = ZSP.ZKP_RN
	  and (ZS.FOTYPE2 = :P1213_FO or :P1213_FO is null)
 	  and (ZS.SERV_RN = :P1213_SERV_RN or :P1213_SERV_RN is null)
	  and (ZS.FUND_RN = :P1213_FUND_RN or :P1213_FUND_RN is null)
	  and (ZS.KOSGU_RN = :P1213_KOSGU or :P1213_KOSGU is null)
	  and (ZS.KVR_RN = :P1213_KVR or :P1213_KVR is null)
	  and (ZS.KBK_RN = :P1213_KBK or :P1213_KBK is null);

	htp.p('<div style="padding-bottom:10px;font-weight: bold;">
			 Закупка: <span class="part"> ID:'||nNUMB||' от '||to_char(dRDATE, 'dd.mm.yyyy')||': '||sZKP_OBJECT ||'('|| sZKP_TYPE||')'||'</span><span style="padding-left: 20px;padding-right: 5px; font-weight: bold;"> Этап закупки:</span><span class="part">'||sZKP_STATUS||'</span>
		   </div>');

    htp.p('<div id="tablediv"><table border="0" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%;">
    <thead>
        <tr>
         <th class="header th1"  rowspan="2" style="border-left:0px" ><div class="th1">КФО</div></th>
         <th class="header th2"  rowspan="2"><div class="th2">КБК</div></th>
         <th class="header th3"  rowspan="2"><div class="th3">КОСГУ</div></th>
		 <th class="header th31" rowspan="2"><div class="th31">КВР</div></th>
         <th class="header th4"  rowspan="2"><div class="th4">Услуга(работа)</div></th>
		 <th class="header th5"  rowspan="2"><div class="th5">Код субсидии</div></th>
		 <th class="header th6"  rowspan="2"><div class="th6">КПГЗ</div></th>
         <th class="header th7"  rowspan="2"><div class="th7">СПГЗ</div></th>
         <th class="header th8"  rowspan="2"><div class="th8">Кол-во</div></th>
         <th class="header th9"  rowspan="2"><div class="th9">Цена (стоимость)</div></th>
		 <th class="header" colspan="3"><div>Цена контракта</div></th>

         <th class="header th11" rowspan="2"><div class="th11"></div></th>
         <th class="header th12" rowspan="2"><div class="th12"></div></th>
         <th class="header" rowspan="2"><div style="width:8px"></div></th>
        </tr>

        <tr>
         <th class="header th10" ><div class="th10">Очередной год</div></th>
         <th class="header th10" ><div class="th10">План 1</div></th>
         <th class="header th10" ><div class="th10">План 2</div></th>
        </tr>

		<tr>
         <th colspan="10"><div class="all_itg">Всего:</div></th>
		 <th class="header th10"><div class="c10">'||to_char(nvl(nTOTAL,0),'999G999G999G999G999G990D00')||'</div></th>
         <th class="header th10"><div class="c10">'||to_char(nvl(nTOTAL1,0),'999G999G999G999G999G990D00')||'</div></th>
         <th class="header th10"><div class="c10">'||to_char(nvl(nTOTAL2,0),'999G999G999G999G999G990D00')||'</div></th>
         <th class="header th11"><div class="c11"></div></th>
         <th class="header th12"><div class="c12"></div></th>
         <th class="header"><div style="width:8px"></div></th>
       </tr>
      </thead>
    <tbody id="fullall" >');

    for QZKPSPEC in
    (
     select ZS.RN ZSRN, L.NAME FOTYPE2, KBK.SCODE KBKSCODE, K.CODE KOSGUCODE, SR.CODE SERVCODE, F.CODE FUNDCODE, KVR.CODE KVRCODE, KBK.SFKR, substr(KBK.SPARTICLE, 0, 2) PROG, substr(KBK.SPARTICLE, 0, 4) SUBPROG, trim(substr(KBK.SPARTICLE, 5)) MEANING
 	   from Z_ZKP_SPEC ZS, ZV_KBKALL KBK, Z_KOSGU K, Z_SERVLINKS SL, Z_SERVREG SR, Z_FUNDS F, Z_LOV L, Z_EXPKVR_ALL KVR
 	  where ZS.JUR_PERS    = pJURPERS
        and ZS.VERSION     = pVERSION
        and ZS.KBK_RN      = KBK.NKBK_RN (+)
		and ZS.KVR_RN      = KVR.RN (+)
        and ZS.KOSGU_RN    = K.RN (+)
        and ZS.SERV_RN     = SL.RN (+)
        and SL.SERVRN      = SR.RN (+)
        and ZS.FUND_RN     = F.RN (+)
        and ZS.FOTYPE2     = L.NUM (+)
        and L.PART (+)     = 'FOTYPE2'
		and ZS.ZKP_RN 	   = :P1213_ZKP_RN
		and (ZS.FOTYPE2 = :P1213_FO or :P1213_FO is null)
		and (ZS.SERV_RN = :P1213_SERV_RN or :P1213_SERV_RN is null)
		and (ZS.FUND_RN = :P1213_FUND_RN or :P1213_FUND_RN is null)
		and (ZS.KOSGU_RN = :P1213_KOSGU or :P1213_KOSGU is null)
		and (ZS.KVR_RN = :P1213_KVR or :P1213_KVR is null)
		and (ZS.KBK_RN = :P1213_KBK or :P1213_KBK is null)
    )
    loop
	    begin
			select EXPFKR.NAME, EXPROGRAM.NAME PR, EXPROGRAM_SUB.NAME, EXPDIR.NAME
			  into sEXPFKR, sPROG, sSUBPROG, sMEANING
			  from Z_EXPFKR EXPFKR, Z_EXPROGRAM EXPROGRAM, Z_EXPROGRAM EXPROGRAM_SUB, Z_EXPDIR EXPDIR
			 where EXPFKR.NUMB = QZKPSPEC.SFKR
			   and EXPROGRAM.VERSION = pVERSION
			   and EXPROGRAM_SUB.VERSION = pVERSION
			   and EXPROGRAM.CODE = QZKPSPEC.PROG
			   and EXPROGRAM_SUB.CODE = replace(QZKPSPEC.SUBPROG, ' ', '.')
			   and EXPDIR.VERSION = pVERSION
			   and EXPDIR.CODE = QZKPSPEC.MEANING;
		exception when others then
			sEXPFKR := null;
			sPROG := null;
			sSUBPROG := null;
			sMEANING := null;
		end;

        sKFO    := '<td class="c1"><div class="c1"><a class="link_code" onClick ="modalWin2( '||:P1213_ZKP_RN||','||QZKPSPEC.ZSRN||');">'||QZKPSPEC.FOTYPE2||'</a></div></td>';
        sKBK    := '<td class="c2"><div class="c2" title="РзПр: '||sEXPFKR ||chr(10)||'Программа: '||sPROG  ||chr(10)||'Подпрограмма: '|| sSUBPROG ||chr(10)||'Направление: '||sMEANING ||'">'||QZKPSPEC.KBKSCODE||'</></div></td>';
        sKOSGU  := '<td class="c3"><div class="c3">'||QZKPSPEC.KOSGUCODE||'</></div></td>';
		sKVR    := '<td class="c31"><div class="c31">'||QZKPSPEC.KVRCODE||'</></div></td>';
        sSERV   := '<td class="c4"><div class="c4">'||QZKPSPEC.SERVCODE ||'</></div></td>';
        sSUBS   := '<td class="c5"><div class="c5">'||QZKPSPEC.FUNDCODE ||'</></div></td>';

        sKPGZ   := '<td class="c6"><div class="c6">'||'-'||'</></div></td>';
        sSPGZ   := '<td class="c7"><div class="c7">'||'-'||'</></div></td>';

        begin
            select sum(ZSP.QUANT), sum(nvl(ZSP.PRICE_FACT, ZSP.PRICE)), sum(nvl(SUMMA, 0)), sum(nvl(SUMMA2, 0)), sum(nvl(SUMMA3, 0))
              into nQUANT, nPRICE, nSUMMA, nSUMMA1, nSUMMA2
              from Z_ZKP_SPECPRICE ZSP
             where ZSP.ZKP_SPEC_RN = QZKPSPEC.ZSRN;
        exception when others then
            nQUANT := null;
            nPRICE := null;
            nSUMMA := null;
            nSUMMA1 := null;
            nSUMMA2 := null;
        end;

        sCOUNT  := '<td class="c8"><div class="c8">'||LTRIM(to_char(nvl(nQUANT,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
        sPRICE  := '<td class="c9"><div class="c9">'||LTRIM(to_char(nvl(nPRICE,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
        sITOGO  := '<td class="c10"><div class="c10">'||LTRIM(to_char(nvl(nSUMMA,0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';

        sITOGOPLAN1 := '<td class="c10"><div class="c10">'||LTRIM(to_char(nvl(nSUMMA1, 0), '999G999G999G999G999G990D00'),' ')||'</></div></td>';
        sITOGOPLAN2 := '<td class="c10"><div class="c10">'||LTRIM(to_char(nvl(nSUMMA2, 0), '999G999G999G999G999G990D00'),' ')||'</></div></td>';

        sDELROW := '<td class="c11">
                    <div class="c11">'||case when sDisabled is null then '<a href= "javascript:apex.confirm(''Удалить выбранную спецификацию (и все связанные с ней суммы)?'', {request:''rDEL'', set:{''P1213_DEL_RN'':'||QZKPSPEC.ZSRN||'}});" style="font-weight: bold; text-align:right; color:#0000ff">
                        <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>' else ' ' end||'
                    </div>
                    </td>';


        --sNEWROW := '<td class="c11"><div class="c11"><a href="f?p=101:1213:&APP_SESSION.:rADDROW:NO::P1213_RN:'||QZKPSPEC.ZSRN||'" onClick="modalWin(&P1213_ZKP_RN.,&P1213_RN.);"><img style="width:12px" src="/i/FNDADD11.gif" title="Удалить строку" /></a></div></td>';
		sNEWROW := '<td class="c12"><div class="c12">'||case when sDisabled is null then '<a onClick="modalWin(&P1213_ZKP_RN.,'||QZKPSPEC.ZSRN||');"><img style="width:12px" src="/i/FNDADD11.gif" title="Добавить суммы" /></a>' else null end||'</div></td>';

        htp.p('
            <tr>
                '||sKFO||'
                '||sKBK||'
                '||sKOSGU||'
				'||sKVR||'
                '||sSERV||'
                '||sSUBS||'

                '||sKPGZ||'
                '||sSPGZ||'
                '||sCOUNT||'
                '||sPRICE||'
                '||sITOGO||'

                '||sITOGOPLAN1||'
                '||sITOGOPLAN2||'

                '||sDELROW||'
                '||sNEWROW||'
            </tr>');
        nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

        for QZKPSPECPRICE in
        (
         select ZSP.RN ZSPRN, KPGZ.RN KPGZRN,
                KPGZ.CODE KPGZCODE, KPGZ.NAME KPGZNAME,
                SPGZ.CODE SPGZCODE, SPGZ.NAME SPGZNAME,
                ZSP.QUANT, nvl(ZSP.PRICE_FACT, ZSP.PRICE) PRICE, ZSP.SUMMA, ZSP.SUMMA2, ZSP.SUMMA3
           from Z_ZKP_SPECPRICE ZSP, Z_KPGZ KPGZ, Z_SPGZ SPGZ
          where ZSP.ZKP_SPEC_RN = QZKPSPEC.ZSRN
           and ZSP.KPGZ_RN      = KPGZ.RN (+)
           and ZSP.SPGZ_RN      = SPGZ.RN (+)
        )
        loop

            sKFO    := '<td class="c1"><div class="c1">'||'-'||'</></div></td>';
            sKBK    := '<td class="c2"><div class="c2">'||'-'||'</></div></td>';
            sKOSGU  := '<td class="c3"><div class="c3">'||'-'||'</></div></td>';
			sKVR  := '<td class="c31"><div class="c31">'||'-'||'</></div></td>';
            sSERV   := '<td class="c4"><div class="c4">'||'-' ||'</></div></td>';
            sSUBS   := '<td class="c5"><div class="c5">'||'-' ||'</></div></td>';

            sKPGZ   := '<td class="c6"><div class="c6" title="'||QZKPSPECPRICE.KPGZNAME ||'"><a href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':580:'||:APP_SESSION||'::::P580_ZKP_RN,P580_KPGZ_RN:'||:P1213_ZKP_RN||','||QZKPSPECPRICE.KPGZRN)||'" style="font-weight: bold; text-align:right; color:#0000ff">'||QZKPSPECPRICE.KPGZCODE||'</a></div></td>';
            sSPGZ   := '<td class="c7"><div class="c7" title="'||QZKPSPECPRICE.SPGZNAME ||'">'||QZKPSPECPRICE.SPGZNAME ||'</></div></td>';

            sCOUNT := '<td class="c8">
                          <div class="c8">'||LTRIM(to_char(QZKPSPECPRICE.QUANT,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sPRICE     := '<td class="c9">
                          <div class="c9">'||LTRIM(to_char(QZKPSPECPRICE.PRICE,'999G999G999G999G999G990D00'),' ')||'</div></td>';

            sITOGO  := '<td class="c10"><div class="c10"><a href="#" style="font-weight: bold; text-align:right; color:#0000ff" onClick="modalWin3(&P1213_ZKP_RN.,'||QZKPSPECPRICE.ZSPRN||');">'||LTRIM(to_char(nvl(QZKPSPECPRICE.SUMMA,0),'999G999G999G999G999G990D00'),' ')||'</a></div></td>';

            sITOGOPLAN1  := '<td class="c10"><div class="c10"><a href="#" style="font-weight: bold; text-align:right; color:#0000ff" onClick="modalWin3(&P1213_ZKP_RN.,'||QZKPSPECPRICE.ZSPRN||');">'||LTRIM(to_char(nvl(QZKPSPECPRICE.SUMMA2,0),'999G999G999G999G999G990D00'),' ')||'</a></div></td>';
            sITOGOPLAN2  := '<td class="c10"><div class="c10"><a href="#" style="font-weight: bold; text-align:right; color:#0000ff" onClick="modalWin3(&P1213_ZKP_RN.,'||QZKPSPECPRICE.ZSPRN||');">'||LTRIM(to_char(nvl(QZKPSPECPRICE.SUMMA3,0),'999G999G999G999G999G990D00'),' ')||'</a></div></td>';

            sDELROW := '<td class="c11">
                        <div class="c11">'||case when sDisabled is null then '<a href= "f?p=&APP_ID.:1213:'||:app_session||':rDEL_SUM:NO::P1213_DEL_RN:'||QZKPSPECPRICE.ZSPRN||'" style="font-weight: bold; text-align:right; color:#0000ff">
                            <img style="width:12px" src="/i/menu/remove_16x16.gif" title="Удалить строку"></a>' else null end||'
                        </div>
                        </td>';

            sNEWROW := '<td class="c12"><div class="c12"></></div></td>';

            htp.p('
                <tr>
                    '||sKFO||'
                    '||sKBK||'
                    '||sKOSGU||'
					'||sKVR||'
                    '||sSERV||'
                    '||sSUBS||'

                    '||sKPGZ||'
                    '||sSPGZ||'
                    '||sCOUNT||'
                    '||sPRICE||'
                    '||sITOGO||'

                    '||sITOGOPLAN1||'
                    '||sITOGOPLAN2||'

                    '||sDELROW||'
                    '||sNEWROW||'
                </tr>');
            nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

        end loop;
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
					  document.location.reload();
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

        function ShowDialog2(id, orgrn, income, kbk, rtype) {
		$.ajax({
			url: "wwv_flow.show",
			type: "POST",
			data: {
				p_request: "APPLICATION_PROCESS=dialog_" + id,
				p_flow_id: $("#pFlowId").val(),
				p_flow_step_id: $("#pFlowStepId").val(),
				p_instance: $("#pInstance").val(),
				x01: orgrn,
                x02: income,
                x03: kbk,
                x04: rtype

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
