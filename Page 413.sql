-- 101; 413; Z_TRANSFER_GRAPH
declare
  pJURPERS      number        := :P1_JURPERS;
  pVERSION      number        := :P1_VERSION;
  pORGRN	       number        := nvl(:P1_ORGRN,:P7_ORGFILTER);
  pFILIAL       number        := nvl(:P1_ORGFL,:P0_FILIAL);

  pUSER         varchar2(100)  := :APP_USER;
  ------
  nCOUNTROWS    number(17) := 0;
  nSUMMA        number:=0;
  sKBK_NAME     varchar2(1000);
  sFUND_NAME    varchar2(1000);
  sEXPDIR_NAME  varchar2(100);
  nPrevKBK      number(17);
  nPrevFUND     number(17);
  nPrevEXPDIR   number(17);
  nKBK_SUM      number(19,2);
  nEXPDIR_SUM   number(19,2);

  nGMZ_SUM      number(19,2); --SUMBUDG1
  nOTHER_SUM    number(19,2); --SUMBUDG2
  nPNO_SUM      number(19,2); --SUMBUDG3
  nBI_SUM       number(19,2); --SUMBUDG4
  nKAP_INV      number(19,2); --SUMBUDG5

  nKBK_FUND     number;

  nStatus         number;
  sRECIPIENT_LIST varchar2(4000);
  sSUMMA          varchar2(4000);
  nREDACTIONS     number;
  nPARTSTATUS     number;
  nCOUNTDOPSOGL   number;
  sPART           varchar2(100);
  sDOPPART        varchar2(100);
  nREDSTATUS      number;
  nHIST           number;
  sDISABLED       varchar2(50);
begin

    if pORGRN is null then
        zp_exception(0,'Учреждение не выбрано. Выберите или закрепите учреждение.');
    end if;

    -- Права доступа
    ----------------------------------------------------

	nPARTSTATUS := ZF_GET_PART_CHECK_MODIFY2(pJURPERS => pJURPERS,
											 pVERSION => pVERSION,
											 pORGRN   => pORGRN,
											 pPART    => 'SOGLGRAF',
											 pFILIAL  => pFILIAL);


    select REDACTIONS
	  into nREDACTIONS
	  from Z_JURPERS
	 where RN = pJURPERS;

   select NEW_TRANS_GRAPH
     into nHIST
     from Z_VERSIONS
    where RN = pVERSION;

	----------------------------------------------------

	apex_javascript.add_library (
	p_name                  => 'jquery.inputmask.bundle',
	p_directory             => '/i/');
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
                     background-color: #FFFAF0; color: #000;
                     cursor: pointer;
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

    .in_txt {width:300px; border: 1px solid #ccc; text-align:left;}
	.in_txt2 {width:70%; border: 1px solid #ccc;text-align:right;}


    .link_code {font-weight: bold; color:#0000ff;}
    .row { margin-bottom: 5px;}

    .th0{width: 100%;text-align:left;}     .c0 {width: 100%; word-wrap: break-word; text-align:left;}
    .th1{width: 150px;text-align:center;}  .c1 {width: 150px; word-wrap: break-word; text-align:right;}
    .th2{width: 350px;text-align:center;}  .c2 {width: 350px; word-wrap: break-word; text-align:left;}
    .th3{width: 16px;text-align:center;}   .c3 {width: 16px; word-wrap: break-word; text-align:center;}
    .th4{width: 100px;text-align:center;}  .c4 {width: 100px; word-wrap: break-word; text-align:right;}
    .th5{width: 120px;text-align:center;}  .c5 {width: 120px; word-wrap: break-word; text-align:center;}
	.th6{width: 300px;text-align:center;}  .c6 {width: 300px; word-wrap: break-word; text-align:left;}
	.th7{width: 100px;text-align:center;}  .c7 {width: 100px; word-wrap: break-word; text-align:center;}
    .th8{width: 30px;text-align:center;}   .c8 {width: 30px; word-wrap: break-word; text-align:center;}
	.th9{width: 30px;text-align:center;}   .c9 {width: 30px; word-wrap: break-word; text-align:center;}

    .c2 a {
      text-decoration: none;
      font-size: 13px;
      color: red;
    }
    .c3 a {
      text-decoration: none;
      font-size: 13px;
      color: green;
    }
     .report_standard .selected td {background-color:#C0FFC1;}

    /*th.th4, th.th5, th.th6, th.th11 {border-right:1px solid #9fa0a0;}
    td.c11, td.c4, td.c6 {border-right:1px solid #9fa0a0;}*/
    .report_standard td.orange {background-color: #FFE8AD;}
    .report_standard td.totals {background-color: #e1e1e1;}

    .level1 td {background-color: #FFEEC3;}
    .level2 td {background-color: /*#FFF4DA;*/ #f2f2f2;}
    .level3 td {background-color: #f2f2f2;}

    .pagination {text-align: right; border: 1px solid grey;
      margin: 0px;
      border-top: none;
      padding: 5px;
      /*background: rgb(213, 213, 213);*/
      background: url(/i/themes/theme_17/images/sReportBG-Aqua.png) 0 50% #e1e1e1 repeat-x;cursor:move;
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
	.report_standard .col_milk_blue {background:#C6D9F0;}   .col_milk_blue input {background:#C6D9F0; border-bottom: 1px solid gray}
    .report_standard .col_milk_pink {background:#FDE9D9}   .col_milk_pink input {background:#FDE9D9; border-bottom: 1px solid gray}
    .report_standard .col_milk_green {background:rgb(175, 255, 136);}  .col_milk_green input {background:rgb(175, 255, 136); border-bottom: 1px solid gray}
    .report_standard .col_milk_yellow {background:#F9F2D0;} .col_milk_yellow input {background:#F9F2D0; border-bottom: 1px solid gray}
	.report_standard .col_milk_white {background:#FFFFFF}  .col_milk_white input {background:#FFFFFF; border-bottom: 1px solid gray}
    </style>');


    begin
      select SUM(case when nvl(P.REST_SIGN,0) = 1 then - G.SUMMA else G.SUMMA end)
        into nSUMMA
        from Z_TRANSFER_GRAPH G, Z_TRANSFER_GRAPH_PERIODS P
       where G.ORGRN = pORGRN
         and G.VERSION = pVERSION
         and G.PERIOD_RN = P.RN
		 and (G.FUND_RN = :P413_FUND or :P413_FUND is null)
		 and (G.KBK_RN = :P413_KBK or :P413_KBK is null)
		 and (G.FOTYPE2 = :P413_FOTYPE2 or :P413_FOTYPE2 is null)
		 and (G.PERIOD_RN = :P413_PERIOD or :P413_PERIOD is null);
    exception when others then null;
    end;

    for rec in
    (
    select RTYPE, sum(SUMMA) SUMMA
      from Z_ORG_BUDGDETAIL
     where PRN = pORGRN
       and VERSION = pVERSION
       and TOTAL_SIGN = 0
	   and (KBK = :P413_KBK or :P413_KBK is null)
	   and (FUND = :P413_FUND or :P413_FUND is null)
	   and (FOTYPE2 = :P413_FOTYPE2 or :P413_FOTYPE2 is null)
     group by RTYPE
    )
    loop
        if rec.RTYPE = 0 then
            nGMZ_SUM := nvl(nGMZ_SUM,0) + nvl(rec.SUMMA,0);
        elsif rec.RTYPE = 4 then
            nOTHER_SUM := nvl(nOTHER_SUM,0) + nvl(rec.SUMMA,0);
        elsif rec.RTYPE = 5 then
            nPNO_SUM := nvl(nPNO_SUM,0) + nvl(rec.SUMMA,0);
        elsif rec.RTYPE = 6 then
            nBI_SUM := nvl(nBI_SUM,0) + nvl(rec.SUMMA,0);
        elsif rec.RTYPE = 11 then
            nKAP_INV := nvl(nKAP_INV,0) + nvl(rec.SUMMA,0);
        end if;
    end loop;


    htp.p('<div><table border="0" id="fix" cellpadding="0" cellspacing="0" class="report_standard" style="width:100%" id="">
    <thead>

      <tr>
        <th class="header th2"  style="border-left:none"><div class="th2" style="text-align:center">Вид ФО</div></th>
        <th class="header th0"  ><div class="th0" style="text-align:center">Целевая статья</div></th>
		<th class="header th6"  ><div class="th6" style="text-align:center">КБК</div></th>
        <th class="header th4"  ><div class="th4" style="text-align:center">Объем финансового<br>обеспечения, руб</div></th>
        <th class="header th1"  ><div class="th1" style="text-align:center">Сумма, руб</div></th>
        <th class="header th4"  ><div class="th4" style="text-align:center">Расхождения</div></th>
        <th class="header th8"  ><div class="th8" style="text-align:center"></div></th>
		<th class="header th9"  ><div class="th9" style="text-align:center"></div></th>
        <th class="header" style="padding:0px" ><div style="width:17px; padding:0px"></div></th>
       </tr>

       <tr>
        <th class="header th2" style="border-left:none"><div class="th2" style ="text-align:right; color:#aa2b15;"><div></th>
		<th class="header th0""><div class="th0" style ="text-align:right; color:#aa2b15;"><b></b><div></th>
        <th class="header th6""><div class="th6" style ="text-align:right; color:#aa2b15;"><b>Итого:</b><div></th>
        <th class="header th4"><div class="th4" style ="text-align:right; color:#aa2b15;"><b>'||LTRIM(to_char((nvl(nGMZ_SUM,0)+ nvl(nOTHER_SUM,0)+ nvl(nPNO_SUM,0)+ nvl(nBI_SUM,0)+nvl(nKAP_INV,0)),'999G999G999G999G999G990D00'),' ')||'</b></div></th>
        <th class="header th1"><div class="th1" style ="text-align:right; color:black;"><b>'||LTRIM(to_char(nvl(nSUMMA,0),'999G999G999G999G999G990D00'),' ')||'</b></div></th>
        <th class="header th4"><div class="th4" style ="text-align:right; color:red;"><b>'||LTRIM(to_char((nvl(nGMZ_SUM,0)+ nvl(nOTHER_SUM,0)+ nvl(nPNO_SUM,0)+ nvl(nBI_SUM,0)+nvl(nKAP_INV,0)) - nvl(nSUMMA,0) ,'999G999G999G999G999G990D00'),' ')||'</b></div></th>
        <th class="header th8"><div class="th8" style ="text-align:right; color:black;"></div></th>
		<th class="header th9"><div class="th9" style ="text-align:right; color:black;"></div></th>
        <th class="header" style="padding:0px" ><div style="width:17px; padding:0px"></div></th>
       </tr>

      </thead>
    <tbody id="fullall">
	');

    for QGroup in
    (
     select EXPDIR
        from Z_TRANSFER_GRAPH
       where ORGRN = pORGRN
         and VERSION = pVERSION
		 and (FUND_RN = :P413_FUND or :P413_FUND is null)
		 and (KBK_RN = :P413_KBK or :P413_KBK is null)
		 and (FOTYPE2 = :P413_FOTYPE2 or :P413_FOTYPE2 is null)
		 and (PERIOD_RN = :P413_PERIOD or :P413_PERIOD is null)
       group by EXPDIR
       order by EXPDIR
    )
	loop
		--------------------------------------------------
		if QGroup.EXPDIR = 5 then
			sPART    := 'SOGLPUB';
			sDOPPART := 'DOPSOGLPUB';
		elsif QGroup.EXPDIR = 0 then
			sPART    := 'SOGLGZ';
			sDOPPART := 'DOPSOGLGZ';
		elsif QGroup.EXPDIR = 4 then
			sPART    := 'SOGLCS';
			sDOPPART := 'DOPSOGLCS';
		end if;


		--------------------------------------------------
        nPrevFUND := null;
        nPrevKBK  := null;
        begin
            select NAME
              into sEXPDIR_NAME
              from Z_LOV
             where part = 'EXPDIR'
               and NUM = QGroup.EXPDIR;
        exception when others then null;
        end;

        begin
            select sum(case when nvl(P.REST_SIGN,0) = 1 then - G.SUMMA else G.SUMMA end)
              into nEXPDIR_SUM
              from Z_TRANSFER_GRAPH G, Z_TRANSFER_GRAPH_PERIODS P
             where G.ORGRN = pORGRN
               and G.VERSION = pVERSION
               and G.EXPDIR = QGroup.EXPDIR
               and G.PERIOD_RN = P.RN
	  		   and (G.FUND_RN = :P413_FUND or :P413_FUND is null)
	  		   and (G.KBK_RN = :P413_KBK or :P413_KBK is null)
			   and (G.FOTYPE2 = :P413_FOTYPE2 or :P413_FOTYPE2 is null)
			   and (G.PERIOD_RN = :P413_PERIOD or :P413_PERIOD is null);
        exception when others then nEXPDIR_SUM := null;
        end;

        --Заглушка
        if QGroup.EXPDIR = 0 then
            sEXPDIR_NAME := 'Субсидия на государственное задание';
        end if;

        htp.p('<tr>
			    <td class="cost_totals c3" style="background: rgb(220, 225, 253);border-left:none;"><div></div></div></td>
			    <td class="c0"  style ="background-color: rgb(220, 225, 253);" ><div class="c0" style ="text-align:left; color:#aa2b15;"><b>'||sEXPDIR_NAME||'</b></div></td>
			    <td class="c4"  style ="background-color: rgb(220, 225, 253);border-left:1px solid #ccc;" ><div class="c4" style ="text-align:right; color:#aa2b15;"><b>'||case QGroup.EXPDIR when 0 then LTRIM(to_char(nvl(nGMZ_SUM,0),'999G999G999G999G999G990D00'),' ')
                                                                                                                                                                                       when 4 then LTRIM(to_char(nvl(nOTHER_SUM,0),'999G999G999G999G999G990D00'),' ')
                                                                                                                                                                                       when 5 then LTRIM(to_char(nvl(nPNO_SUM,0),'999G999G999G999G999G990D00'),' ')
                                                                                                                                                                                       when 6 then LTRIM(to_char(nvl(nBI_SUM,0),'999G999G999G999G999G990D00'),' ')
																																													   when 11 then LTRIM(to_char(nvl(nKAP_INV,0),'999G999G999G999G999G990D00'),' ') end||'</b></div></td>
           <td class="c1"  style ="background-color: rgb(220, 225, 253);border-left:1px solid #ccc;" ><div class="c1" style ="text-align:right; color:black;"><b>'||LTRIM(to_char(nvl(nEXPDIR_SUM,0),'999G999G999G999G999G990D00'),' ')||'</b></div></td>
           <td class="c4"  style ="background-color: rgb(220, 225, 253);border-left:1px solid #ccc;" ><div class="c4" style ="text-align:right; color:red;"><b>'||case QGroup.EXPDIR when 0 then LTRIM(to_char(nvl(nGMZ_SUM,0)-nvl(nEXPDIR_SUM,0),'999G999G999G999G999G990D00'),' ')
                                                                                                                                                                                       when 4 then LTRIM(to_char(nvl(nOTHER_SUM,0)-nvl(nEXPDIR_SUM,0),'999G999G999G999G999G990D00'),' ')
                                                                                                                                                                                       when 5 then LTRIM(to_char(nvl(nPNO_SUM,0)-nvl(nEXPDIR_SUM,0),'999G999G999G999G999G990D00'),' ')
                                                                                                                                                                                       when 6 then LTRIM(to_char(nvl(nBI_SUM,0)-nvl(nEXPDIR_SUM,0),'999G999G999G999G999G990D00'),' ')
																																													   when 11 then LTRIM(to_char(nvl(nKAP_INV,0)-nvl(nEXPDIR_SUM,0),'999G999G999G999G999G990D00'),' ')end||'</b></div></td>
           <td class="c8"  style ="background-color: rgb(220, 225, 253);border-left:1px solid #ccc;"><div class="c8" ></div></td>
		   <td class="c9"  style ="background-color: rgb(220, 225, 253);border-left:1px solid #ccc;"><div class="c9" ></div></td>
           </tr>');

		for MAIN in
		(
		  select G.KBK_RN, G.FUND_RN, G.EXPDIR, lpad(KBK.SFULLKBKCODE,50), lpad(F.SUBCODE,50), lpad(F.CODE,10)
			from Z_TRANSFER_GRAPH G, Z_LOV L, ZV_KBKALL KBK, Z_FUNDS F
		   where G.ORGRN     = pORGRN
			 and G.VERSION   = pVERSION
			 and G.EXPDIR    = QGroup.EXPDIR
			 and G.STATUS    = L.NUM (+)
			 and L.PART (+)  = 'QIND_REQUEST'
             and G.KBK_RN    = KBK.NKBK_RN (+)
             and G.FUND_RN   = F.RN (+)
			 and (G.FUND_RN = :P413_FUND or :P413_FUND is null)
			 and (G.KBK_RN = :P413_KBK or :P413_KBK is null)
			 and (G.FOTYPE2 = :P413_FOTYPE2 or :P413_FOTYPE2 is null)
			 and (G.PERIOD_RN = :P413_PERIOD or :P413_PERIOD is null)
		   group by G.KBK_RN, G.FUND_RN, G.EXPDIR, lpad(KBK.SFULLKBKCODE,50), lpad(F.SUBCODE,50), lpad(F.CODE,10)
		   order by G.EXPDIR, lpad(KBK.SFULLKBKCODE,50), lpad(F.SUBCODE,50), lpad(F.CODE,10)

		)
		loop
            begin
                select sum(case when nvl(P.REST_SIGN,0) = 1 then - G.SUMMA else G.SUMMA end)
                  into nKBK_SUM
                  from Z_TRANSFER_GRAPH G, Z_TRANSFER_GRAPH_PERIODS P
                 where G.ORGRN = pOrgRn
                   and G.VERSION = pVersion
                   and G.KBK_RN = MAIN.KBK_RN
                   and G.EXPDIR = QGroup.EXPDIR
		  		   and (G.FUND_RN = :P413_FUND or :P413_FUND is null)
		  		   and (G.KBK_RN = :P413_KBK or :P413_KBK is null)
				   and (G.FOTYPE2 = :P413_FOTYPE2 or :P413_FOTYPE2 is null)
                   and ((G.FUND_RN is null and MAIN.FUND_RN is null) or (G.FUND_RN is not null and MAIN.FUND_RN is not null and G.FUND_RN = MAIN.FUND_RN))
                   and G.PERIOD_RN = P.RN
				   and (G.PERIOD_RN = :P413_PERIOD or :P413_PERIOD is null);
            exception when others then nKBK_SUM := null;
            end;

            sSUMMA     := '<td class="c1" style="border-left:1px solid #ccc"><div class="c1" style ="text-align:right; color:black;"><b>'||LTRIM(to_char(nvl(nKBK_SUM,0),'999G999G999G999G999G990D00'),' ')||'</b></div></td>';

			if MAIN.FUND_RN is null then
				if (nPrevKBK is null) or (MAIN.KBK_RN <> nPrevKBK) then

					begin
						select SFULLKBKCODE
						  into sKBK_NAME
						  from ZV_KBKALL
						 where nKBK_RN = MAIN.KBK_RN;
					exception when others then null;
					end;

                    sFUND_NAME :=  '<td class="c0" style="border-left:1px solid #ccc"><div class="c0" style ="text-align:left;"></div>-нет-</td>';

					htp.p('<tr>
                       <td class="c2" style="border-left:1px solid #ccc"><div class="c2" style ="text-align:left;">'||sEXPDIR_NAME||'</div></td>
                       '||sFUND_NAME||'
					   <td class="c6" style="border-left:1px solid #ccc"><div class="c6" style ="text-align:left;"><a href="f?p=101:1420:'||v('APP_SESSION')||'::NO::P1420_EXPDIR,P1420_FUND,P1420_KBK:'||QGroup.EXPDIR||','||null||','||MAIN.KBK_RN||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">'||sKBK_NAME||'</span></a></div></td>
                       <td class="c4" style="border-left:1px solid #ccc"><div class="c4" style ="text-align:right; color:#aa2b15;"></div></td>
					   '||sSUMMA||'
					   <td class="c4" style="border-left:1px solid #ccc"><div class="c4" style ="text-align:right; color:#aa2b15;"></div></td>
					   <td class="c8" style="border-left:1px solid #ccc"><div class="c8" style ="text-align:right; color:#aa2b15;"></div></td>
					   <td class="c9" style="border-left:1px solid #ccc"><div class="c9" style ="text-align:right; color:#aa2b15;"></div></td>

					   </tr>');
					nPrevKBK := MAIN.KBK_RN;
					nCOUNTROWS:=nCOUNTROWS + 1;
				end if;
			else
				if (nPrevFUND is null or (nvl(MAIN.FUND_RN,0) <> nvl(nPrevFUND,0))) or (nPrevKBK is null or (nvl(MAIN.KBK_RN,0) <> nvl(nPrevKBK,0))) then


					begin
						select F.CODE || ' - ' || F.NAME, S.NAME SUBTYPE
						  into sFUND_NAME, sRECIPIENT_LIST
						  from Z_FUNDS F, Z_SUBTYPE S
						 where F.RN = MAIN.FUND_RN
						   and F.SUBTYPE = S.RN(+);
					exception when others then sFUND_NAME := '-нет-';
					end;

					begin
						select SFULLKBKCODE
						  into sKBK_NAME
						  from ZV_KBKALL
						 where nKBK_RN = main.KBK_RN;
					exception when others then begin
												select SCODE || '.' || nvl(STYPEBS_NUMB, 'Нет')  || case when SEVENT_CODE is not null then '-' else SEVENT_CODE end
												  into sKBK_NAME
												  from ZV_KBKALL
												 where nKBK_RN = MAIN.KBK_RN;
												 exception when others then ZP_EXCEPTION(0,MAIN.KBK_RN);
												end;
					end;

                    sFUND_NAME :=  '<td class="c0" style="border-left:1px solid #ccc"><div class="c0" style ="text-align:left;"></div>'||case when nvl(sRECIPIENT_LIST,0) = 'Терапевты' then '<a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':465:'||:APP_SESSION||'::::P465_FUND,P465_ORGRN,P465_KBK,P413_SELECT_ROW:'||MAIN.FUND_RN ||','|| pOrgRn ||','|| MAIN.KBK_RN ||','|| null)||'">'||sFUND_NAME||'</a>'
                     when nvl(sRECIPIENT_LIST,0) = 'Доступная среда' then '<a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':464:'||:APP_SESSION||'::::P464_FUND,P464_ORGRN,P464_KBK,P413_SELECT_ROW:'||MAIN.FUND_RN ||','|| pOrgRn ||','|| MAIN.KBK_RN ||','|| null)||'">'||sFUND_NAME||'</a>'
                     when nvl(sRECIPIENT_LIST,0) = 'Цели расходов' then '<a class="link_code" href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':510:'||:APP_SESSION||'::::P510_FUND,P510_ORGRN,P510_KBK,P413_SELECT_ROW:'||MAIN.FUND_RN ||','|| pOrgRn ||','|| MAIN.KBK_RN ||','|| null)||'">'||sFUND_NAME||'</a>'
                     else ''||sFUND_NAME||'</span></a>' end||'</td>';

                    sKBK_NAME := '<td class="c6" style="border-left:1px solid #ccc"><div class="c6" style ="text-align:left;"><a href="f?p=101:1420:'||v('APP_SESSION')||'::NO::P1420_EXPDIR,P1420_FUND,P1420_KBK:'||QGroup.EXPDIR||','||MAIN.FUND_RN||','||MAIN.KBK_RN||'"><span style="font-weight: bold; color:#0000ff" onclick="openLoader();">'||sKBK_NAME||'</span></a></div></td>';

					htp.p('<tr>
                        <td class="c2" style="border-left:1px solid #ccc"><div class="c2" style ="text-align:left;">'||sEXPDIR_NAME||'</div></td>
					    '||sFUND_NAME||'
                        '||sKBK_NAME||'
                        <td class="c4" style="border-left:1px solid #ccc"><div class="c4" style ="text-align:right; color:#aa2b15;"></div></td>
					    '||sSUMMA||'
					   <td class="c4" style="border-left:1px solid #ccc"><div class="c4" style ="text-align:right; color:#aa2b15;"></div></td>
					   <td class="c8" style="border-left:1px solid #ccc"><div class="c8" style ="text-align:right; color:#aa2b15;"></div></td>
					   <td class="c9" style="border-left:1px solid #ccc"><div class="c9" style ="text-align:right; color:#aa2b15;"></div></td>

					   </tr>');
					nPrevFUND := MAIN.FUND_RN;
					nPrevKBK := MAIN.KBK_RN;
					nCOUNTROWS:=nCOUNTROWS + 1;
				end if;
			end if;



		end loop;
    end loop;

  htp.p('</tbody></table></div>');

  htp.p('<ul class="pagination">');
  htp.p('<li style="float:right;">Всего записей: <b>'||nCOUNTROWS||'</b></li>');
  htp.p('<li style="float:left; display: none;" id="loading_scroll"><img src="/i/378.GIF" style="width: 130px"/> </li>');
  htp.p('<li style="float:left; " id="save_shtat"></li>');
  htp.p('<li style="clear:both"></li></ul>');
  htp.p('<script>

    var el = document.getElementById("row_"+$v("P413_SELECT_ROW"));
   if (el!==null){
    el.scrollIntoView(true);
     $(el).children().css("background-color","yellow");
   }

    $(function(){
      table_body=$("#fullall");
      if (window.screen.height<=1024) {
      table_body.height("400px");
      $(".report_standard").css("width","100%");
      } else {
      table_body.height("600px");
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

    /*$(el).parents(''.level1'').css(''display'',''block'');
    $(el).parents(''.level2'').css(''display'',''block'');
    $(el).parents(''.level3'').css(''display'',''block'');
    }
    */
     function selecter(obj,rownum){
     $("#fix").find("tr").removeClass("selected");
      $("#fix").find("tr[row=''"+rownum+"'']").addClass("selected");
      $("#fix tr").removeClass("selected");
      $(obj).parent("div").parent("td").parent("tr").addClass("selected");

           }
    $(document).ready(function(){

       $(".decimal").inputmask({alias: "decimal",
        groupSeparator: " ",
        autoGroup: true,
        allowPlus: false,
        allowMinus: false,
        max: 999999999.99,
        digits : 2,
        radixPoint:",",
        digitsOptional: false
       });

       });
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
    </script>'
  );
end;
