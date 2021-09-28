--101; 790; Обоснование доходов СВОД
declare
  pJURPERS      number := :P1_JURPERS;
  pVERSION      number := :P1_VERSION;
  pORGRN        number := nvl(:P7_ORGFILTER,:P1_ORGRN);
  pFILIAL		number := nvl(:P1_ORGFL,:P0_FILIAL);

  pPERIOD       number := nvl(:P790_PERIOD,3);
  count_rows    number(17) := 9;
  nTotal        number(19,2);
  nFullTotal    number(19,2):=0;
  nExpSum       number(19,2);
  nFullExpSum   number(19,2):=0;
  nDiff         number(19,2);
  nFullDiff     number(19,2):=0;
  nTotalVB      number(19,2);
  nFullTotalVB  number(19,2):=0;
  nExpSumVB     number(19,2);
  nFullExpSumVB number(19,2):=0;
  nDiffVB       number(19,2);
  nFullDiffVB   number(19,2):=0;
  sST           varchar2(100) := '999G999G999G999G999G990D00';
  cKVRLIST      expmat_nested;
  cKVRLISTVB    expmat_nested;
  sKVSVB        varchar2(4000);
  sKSGSVB       varchar2(4000);
  sB            clob;
  sKVS          varchar2(4000);
  sKSGS         varchar2(4000);
  sAgrStr       varchar2(4000);
  nPRILFORMS_EXPMAT number;
  --
  sSTRBACK      varchar2(4000);
  sSTRNAMESTR   varchar2(4000);
  sPERIOD       varchar2(4000);
  SPERNAME      varchar2(100);
  nGORIZONT     Z_VERSIONS.GORIZONT%type;


  --task12
  nSUMMA		number := 0;
  nPlanned      number := 0;
  nPlanned1     number := 0;
  nPlanned2     number := 0;
  nPlanned3     number := 0;
  nFullPlanned  number := 0;
  tdc3          varchar2(100):= '<td class="c3">';
  tdc2          varchar2(100):= '<td class="c2">';
  tdc1          varchar2(100):= '<td class="c1" style="border-left:none">';
  mmm 			number := null;
  sBaloon		varchar2(100);
begin
  htp.p('<style>
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
        background-color: #dbe8f8; color: #000;
        cursor: pointer; font-weight:bolder;
      }
    .report_standard  thead > tr {width: 100%; }
    .report_standard  tbody > tr {width: 100%; display: block}
    .report_standard > tbody {
        display: block; height: 500px; overflow-x: hidden;  overflow-y: scroll;
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
      line-height: 1.5em;
      vertical-align: middle;
    }
    .report_standard th {
      color:#222;
      font: bold 14px "Helvetica Neue",Helvetica,Arial,sans-serif;
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

    .in_txt {width:70px; border: 1px solid #ccc;text-align:right;}
    .in_txt2 {width:100%; border: 1px solid #ccc;text-align:right;}

    .link_code {font-weight: bold; color:#0000ff;}
    .row { margin-bottom: 5px;}

    .th0{width: auto;text-align:center;}     .c1 {width: auto; word-wrap: break-word; text-align:center;}
    .th1{width: 40px;text-align:center;}     .c1 {width: 40px; word-wrap: break-word; text-align:center;}
    .th2{width: 100%; text-align:center;}   .c2 {width: 100%; word-wrap: break-word;text-align:left;}
    .th3{width: 120px;text-align:center;}     .c3 {width: 120px; word-wrap: break-word; text-align:right;}
	.th4{width: auto;text-align:center;}    .c4 {width: auto; word-wrap: break-word; text-align:center;}
    .th5{width: 135px;text-align:center;}    .c5 {width: 135px; word-wrap: break-word; text-align:center;}
    .th6{width: 50px;text-align:center;}     .c6 {width: 50px; word-wrap: break-word; text-align:center;}
    .th7{width: 121px;text-align:center;}    .c7 {width: 121px; word-wrap: break-word; text-align:right;}
    .th99{width: 45px;text-align:center;}    .c99 {width: 45px; word-wrap: break-word; text-align:right;}


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
 .group {
    font-weight: bold;
    background-color: #dddbf8 !important;
}
    </style>');

    begin
        select GORIZONT
          into nGORIZONT
          from Z_VERSIONS
         where RN = pVERSION;
    exception when others then
        null;
    end;

    sPERIOD := '<select onchange="apex.submit({request:this.value,set:{''P790_PERIOD'':this.value}});" style="float:right; margin-right:5px">';

  	for rec in
      (select NAME, NUM
         from Z_LOV
        where part = 'VERS_YEAR'
          and ((nGORIZONT = 1 and NUM in (3,4,5,6)) or (nGORIZONT = 2))
        order by NUM)
  	loop
  		sPERIOD := sPERIOD||'<option value="'||rec.NUM||'" '||case when pPERIOD = rec.NUM then 'selected="selected"' end||'>'||rec.NAME||'</option>';
        if pPERIOD = rec.NUM then sPERNAME := rec.NAME; end if;
  	end loop;

  	sPERIOD := sPERIOD||'</select>';

    sSTRNAMESTR  := '<div style="font-weight: bold;font-size: 14px;padding: 5px 3px;border-bottom: 1px solid #ccc;margin-bottom: 5px;">Обоснование доходов - СВОД</div>';

    htp.p(
    '<div style="background: whitesmoke;padding: 10px;border: 1px solid #ccc;"><div>
		'||sPERIOD||'
        '||sSTRNAMESTR ||'
    </div>');

  htp.p('
  <div id="tablediv" class="tablediv"><table border="0" id="fix" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%; border:0px" >
    <thead>
        <tr>
         <th class="header th1 myCell" style="border-left:0px"><div class="th1">Код</div></th>
         <th class="header th2" ><div class="th2">Наименование формы</div></th>
         <th class="header th3" ><div class="th3">Запланировано</div></th>
         <th class="header th3" ><div class="th3">Обосновано</div></th>
         <th class="header th3" ><div class="th3">Отклонение</div></th>
         <th class="header th6" ><div class="th6">Статус</div></th>
         <th class="header" ><div style="width:8px"></div></th>
        </tr>

      </thead>
    <tbody id="fullall">
  ');

  if ZF_USER_SUPPORT(:APP_USER) then
	mmm := 1;
  end if;

  for tbls in
  (
    select t.*,
	(
	select  case pPERIOD when 3 then sum(round(P.total,2))
				         when 4 then sum(round(P.PLAN1_TOTAL,2))
				         when 5 then sum(round(P.PLAN2_TOTAL,2))
                         when 6 then sum(round(P.PLAN3_TOTAL,2)) end
     from H_INCOME_PRILFORMS P, Z_INCOME I
    where P.PART = t.NORDER
      and P.ORGRN = pORGRN
      and ((pFILIAL is null) or (P.FILIAL = pFILIAL))
      and P.INCOME = I.RN (+)
      and I.DEBCRED_SIGN is null
	) as plan_sum
    from XV_INCOME_FORMS101 t

  )LOOP
	nPlanned := 0;
	-- расчет суммы запланировано
    for QCODE in
    (
     select STRCODE
      from (select REGEXP_SUBSTR(''||tbls.INCOME_CODES||'', '[^,; ]+', REGEXP_INSTR(''||tbls.INCOME_CODES||'', '[^,; ]+', 1, LEVEL, 0), 1) STRCODE
            from DUAL
         CONNECT BY REGEXP_INSTR(''||tbls.INCOME_CODES||'', '[^,; ]+', 1, LEVEL) > 0
          )
     group by STRCODE
     order by STRCODE
    )
    loop
			select case pPERIOD when 3 then sum(B.SUMMA)
                                when 4 then sum(B.PLANSUM1)
                                when 5 then sum(B.PLANSUM2)
                                when 6 then sum(B.PLANSUM3)  end
              into nSUMMA
			  from Z_ORG_VBDETAIL B, Z_INCOME I, Z_KOSGU K
			 where B.INCOME   = I.RN
			   and I.KOSGU    =  K.RN
			   and K.CODE     = TRIM(QCODE.STRCODE)
			   and B.VERSION  = pversion
			   and B.PRN      = porgrn
			   and ((nvl(I.IFTAX,0) =  0 and tbls.SFORMNUM != 8) or (nvl(I.IFTAX,0) = 1 and tbls.SFORMNUM = 8) or (nvl(I.IFTAX,0) = 1 and tbls.SFORMNUM = 6))
			   and ((pFILIAL is null) or (FILIAL = pFILIAL))
               and I.DEBCRED_SIGN is null;

		nPlanned := nPlanned + nvl(nSUMMA,0);

			select case pPERIOD when 3 then sum(B.SUMMA)
                                when 4 then sum(B.PLANSUM1)
                                when 5 then sum(B.PLANSUM2)
                                when 6 then sum(B.PLANSUM3) end
              into nSUMMA
			  from Z_ORG_BUDGDETAIL B, Z_INCOME I, Z_KOSGU K
			 where B.INCOME = I.RN
			   and I.KOSGU  =  K.RN
			   and K.CODE   = TRIM(QCODE.STRCODE)
			   and B.VERSION  = pversion
			   and B.PRN      = porgrn
			   and ((nvl(I.IFTAX,0) =  0 and tbls.SFORMNUM != 8) or (nvl(I.IFTAX,0) = 1 and tbls.SFORMNUM = 8) or (nvl(I.IFTAX,0) = 1 and tbls.SFORMNUM = 6))
			   and ((pFILIAL is null) or (FILIAL = pFILIAL))
               and I.DEBCRED_SIGN is null;

		nPlanned := nPlanned + nvl(nSUMMA,0);

    end loop;

      nTotal   := tbls.plan_sum;
      --
      --nPlanned := 0;
      nDiff := nvl((nPlanned),0) - nvl(nTotal,0);
      --totals
      nFullTotal := nvl(nFullTotal,0) + nvl(nTotal,0);
      nFullDiff := nvl(nFullDiff,0) + nvl(nDiff,0);
      nFullPlanned := nvl(nFullPlanned,0) + nvl(nPlanned,0);

	if nDiff != 0 then
		sBaloon := '<img src="/i/red.png" title="Имеются расхождения" style="width:16px;"/>';
	else
		sBaloon := '<img src="/i/green.png" title="Нет расхождений" style="width:16px;"/>';
	end if;

    sB := sb||('<tr>
		'||tdc1||'<div class="c1">'||tbls.sFormNum||'</div></td>
		'||tdc2||'<div class="c2"><a class="ahrf" href="'||tbls.sPageLink||'">'||tbls.sFormName||'</a></div></td>
		'||sAgrStr||'
		'||tdc3||'<div class="c3"><a href="javascript:ModalJustify('||tbls.nORDER||','||pPERIOD ||');">'||LTRIM(to_char(nvl(nPlanned,0),sST),' ')||'</a></div></td>

		'||tdc3||'<div class="c3"><a href="javascript:ModalJustify('||tbls.nORDER||','||pPERIOD ||');">'||LTRIM(to_char(nvl(tbls.plan_sum,0),sST),' ')||'</a></div></td>
		'||tdc3||'<div class="c3" style="color:'||case when nDiff != 0 then 'red' when nDiff =0 then 'green' end||'">'||LTRIM(to_char(nDiff,sST),' ')||'</div></td>
		'||tdc3||'<div class="c6" >'||sBaloon||'</div></td>
		</tr>');

    END LOOP;

    nFullDiff := nvl(nFullPlanned,0) - (nvl(nFullTotal,0));
    htp.p('<tr>
        <td class="c1 group" style="border-left:none"><div class="c1"></div></td>
        <td class="c2 group"><div class="c2" style="font-weight:bold; text-align:right">ИТОГО:</div></td>
        <td class="c3 group"><div class="c3">'||LTRIM(to_char(nvl(nFullPlanned,0),sST),' ')||'</div></td>
        <td class="c3 group"><div class="c3">'||LTRIM(to_char(nvl(nFullTotalVB,0) + nvl(nFullTotal,0),sST),' ') ||'</div></td>
        <td class="c3 group"><div class="c3">'||LTRIM(to_char(nvl(nFullDiff,0),sST),' ')||'</div></td>
        <td class="c6 group"><div class="c6"></div></td>
        </tr>');

  htp.p(sB);
  htp.p('</tbody></table></div>');
  htp.p('<ul class="pagination" style="margin:0px">');
  htp.p('<li style="float:right;">Всего записей: <b>'||count_rows||'</b></li>');
  htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
  htp.p('<li style="float:left; " id="save_shtat"></li>');
  htp.p('<li style="clear:both"></li></ul>');

end;
