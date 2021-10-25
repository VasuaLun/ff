--101; 638; Z_ZKP
declare
 pJURPERS      number         := :P1_JURPERS;
 pVERSION      number         := :P1_VERSION;
 pORGRN	       number         := nvl(:P1_ORGRN,:P7_ORGFILTER);

 pUSER         varchar2(100)  := :APP_USER;
 pROLE         number         := ZGET_ROLE;

 pKBK          varchar2(4000)  := :P638_KBK;
 pKVR          number          := :P638_KVR;
 pKOSGU        number          := :P638_KOSGU;
 pFOTYPE       number          := :P638_FOTYPE2;
 pTYPE         number          := :P638_TYPE;
 pPERIOD       number          := :P638_PERIOD;


 nPAY_SUMMA    number;
 nTEND_ECONOMY number;
 nUSER_RN	     number;
 nORG_CHILD    number;
 -----------------------------------------------
 sORGNAME     varchar2(4000);
 sNUMB        varchar2(4000);
 sRDATE       varchar2(4000);
 sSPECCOUNT   varchar2(4000);
 sSPECSUMMA   varchar2(4000);
 sECONOMY	    varchar2(4000);
 sSTATUS      varchar2(4000);
 sARCROW      varchar2(4000);
 sAGRNUMB     varchar2(4000);
 sAGRDATE     varchar2(4000);
 sPROVIDER    varchar2(4000);
 sZKPOBJECT   varchar2(4000);
 sZKPTYPE     varchar2(4000);
 sGRBSMARK    varchar2(4000);
 -----------------------------------------------
 nCOUNTROWS    number;
 nTOTALSUM     number;

 sColor        varchar2(100);
 sMSG	         varchar2(250);
 nSOGLCOUNT    number;
 nCHECKCOUNT   number;
 nACCEPTROLE   number;
 nSPEC_SUMMA   number;
 nSPEC_SUMMA2  number;
 nSPEC_SUMMA3  number;
 nECONOMY      number;
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
        .itogo {font-weight:bold; background-color:#d4d9f5 !important}
        '||case when pORGRN is not null then '.show{display:none;}' end||'

        .link_code {text-decoration: underline;font-weight: bold; color:#0000ff;}
        .row { margin-bottom: 5px;}


        .th1{width: 120px;text-align:center; border-left: 0px !important}    .c1 {width: 120px; word-wrap: break-word; text-align:center; border-left: 0px !important}
        .th2{width: 50px;text-align:center;'|| case when pORGRN is not null then 'border-left: 0px !important' end||'}   .c2 {width: 50px; word-wrap: break-word; text-align:center;'|| case when pORGRN is not null then 'border-left: 0px !important' end||'}
        .th3{width: 70px;text-align:center;}     .c3 {width: 70px; word-wrap: break-word; text-align:center;}
		    .th4{width: 120px;text-align:center;}    .c4 {width: 120px; word-wrap: break-word; text-align:center;}

        .th5{width: 70px;text-align:center;}     .c5 {width: 70px; word-wrap: break-word; text-align:center;}
        .th6{width: 150px;text-align:center;}    .c6 {width: 150px; word-wrap: break-word; text-align:left;}
	     	.th7{width: 100%;text-align:center;}     .c7 {width: 100%; word-wrap: break-word; text-align:left;}

        .th8{width: 100px;text-align:center;}    .c8 {width: 100px; word-wrap: break-word; text-align:center;}
        .th9{width: 60px;text-align:center;}     .c9 {width: 60px; word-wrap: break-word; text-align:center;}
        .th10{width: 100px;text-align:center;}   .c10 {width: 100px; word-wrap: break-word; text-align:right;}
		    .th11{width: 100px;text-align:center;}   .c11 {width: 100px; word-wrap: break-word; text-align:right;}
        .th12{width: 110px;text-align:center;}   .c12 {width: 110px; word-wrap: break-word; text-align:center;}
        .th13{width: 100px;text-align:center;}   .c13 {width: 100px; word-wrap: break-word; text-align:center;}

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
         <th class="header th1 show" ><div class="th1">Учреждение</div></th>
         <th class="header th2" ><div class="th2">ID</div></th>
         <th class="header th3" ><div class="th3">Дата</div></th>
		     <th class="header th4" ><div class="th4">Номер контракта</div></th>
		     <th class="header th5" ><div class="th5">Дата заключения</div></th>
         <th class="header th6" ><div class="th6">Поставщик</div></th>
         <th class="header th7" ><div class="th7">Объект закупки</div></th>
         <th class="header th8" ><div class="th8">Тип закупки</div></th>
         <th class="header th10" ><div class="th10">Цена контракта</div></th>
	    	 <th class="header th11" ><div class="th11">Экономия</div></th>
		     <th class="header th12" ><div class="th12">Статус</div></th>
         <th class="header th13" ><div class="th13">Отметка ГРБС</div></th>
         <th class="header"><div style="width:8px"></div></th>
        </tr>
      </thead>
    <tbody id="fullall" >');

    select RN into nUSER_RN from Z_USERS where LOGIN = :APP_USER;
  	select count(*) into nORG_CHILD from Z_USER_ORGS where PRN = nUSER_RN;

    begin
        select sum(case pPERIOD
                        when 3 then nvl(SUMMA, 0)
                        when 4 then nvl(SUMMA2, 0)
                        when 5 then nvl(SUMMA3, 0) end),
          case pPERIOD when 3 then sum(case when nvl(PRICE,0) > 0 and nvl(PRICE_FACT,0) > 0 then QUANT * (nvl(PRICE,0) - nvl(PRICE_FACT,0)) end)
            else 0 end
          into nTOTALSUM, nTEND_ECONOMY
          from Z_ZKP Z, Z_ORGREG O, Z_ZKP_SPEC ZS, Z_ZKP_SPECPRICE ZSP, Z_STATUS S, Z_ZKP_VENDOR P
         where Z.JUR_PERS  = pJURPERS
           and Z.VERSION   = pVERSION
           and Z.RN        = ZSP.ZKP_RN (+)
           and Z.RN        = ZS.ZKP_RN (+)
           and Z.RN        = S.PERIOD  (+)
		   and ZS.RN	   = ZSP.ZKP_SPEC_RN
           and Z.VENDOR_ALL_RN = P.RN(+)
		   --and ZS.KOSGU_RN != 172
		   and nvl(Z.EXIST_SIGN, 0) != 1
		   and ZF_REESTR_STATUS_GET(pVERSION,  Z.RN, 'ZKP_REESTR') = 5
           and ((pORGRN is null) or (Z.ORGRN    = pORGRN))
		       and Z.ORGRN = O.RN
           and ((pFOTYPE is null) or (ZS.FOTYPE2 = pFOTYPE))
           and ((pKBK is null) or (ZS.KBK_RN = pKBK))
           and ((pKOSGU is null) or (ZS.KOSGU_RN = pKOSGU))
           and ((pKVR is null) or (ZS.KVR_RN = pKVR))
           and ((O.A_ORGRN in (select ORG from Z_USER_ORGS where PRN = nUSER_RN)) or (nORG_CHILD = 0))
           and (
                  (pTYPE = 1 and Z.AGRDATE is not null or Z.AGRNUMB is not null or Z.VENDOR_ALL_RN is not null)
               or (pTYPE = 2 and Z.AGRDATE is null and Z.AGRNUMB is null and Z.VENDOR_ALL_RN is null)
               );
    exception when others then
        nTOTALSUM := null;
    		nTEND_ECONOMY := null;
    end;

    sORGNAME        := '<td class="c1  show itogo"><div class="c1"></></div></td>';
    sNUMB           := '<td class="c2  itogo"><div class="c2"></></div></td>';
    sRDATE          := '<td class="c3  itogo"><div class="c3"></></div></td>';
    sAGRNUMB        := '<td class="c4  itogo"><div class="c4"></></div></td>';
    sAGRDATE        := '<td class="c5  itogo"><div class="c5"></></div></td>';
    sPROVIDER       := '<td class="c6  itogo"><div class="c6"></></div></td>';
    sZKPOBJECT      := '<td class="c7  itogo"><div class="c7"></></div></td>';
    sZKPTYPE        := '<td class="c8  itogo"><div class="c8">Итого:</></div></td>';
    sSPECSUMMA      := '<td class="c10 itogo"><div class="c10">'||LTRIM(to_char(nvl(nTOTALSUM, 0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
	  sECONOMY        := '<td class="c11 itogo"><div class="c10" style="color:'||case when nvl(nTEND_ECONOMY, 0) > 0 then 'green'  when nvl(nTEND_ECONOMY, 0) < 0 then 'red' end||'">'||LTRIM(to_char(nvl(nTEND_ECONOMY, 0),'999G999G999G999G999G990D00'),' ')||'</></div></td>';
    sSTATUS         := '<td class="c12 itogo"><div class="c12"></></div></td>';
    sGRBSMARK       := '<td class="c13 itogo"><div class="c13"></></div></td>';

    htp.p('
        <tr>'||sORGNAME||'
            '||sNUMB||'
            '||sRDATE||'
            '||sAGRNUMB||'
            '||sAGRDATE||'
            '||sPROVIDER||'
            '||sZKPOBJECT||'
            '||sZKPTYPE||'
            '||sSPECSUMMA||'
		      	'||sECONOMY||'
            '||sSTATUS||'
            '||sGRBSMARK||'
       </tr>');

    for rec in
    (
     select Z.RN ZKPRN, Z.RDATE, Z.NOTES, Z.GRBS_NOTES, Z.NUMB, Z.AGRNUMB, Z.AGRDATE, Z.ARC_SIGN, Z.ZKP_OBJECT, Z.INFO,
            S.EXP_PLAN nSTATUS,
            O.SHORT_NAME,
		      	ADD_FILENAME, ADD_FILENAME2, ADD_FILENAME3,
            P.CODE PROVIDER,
            L.NAME ZKP_TYPE,
            L2.NAME GRBSMARK,
			      Z.FILENAME_ORG, Z.FILENAME_GRBS, Z.RPT_FILENAME, Z.ZKP_JOIN_TYPE
 	     from Z_ZKP Z, Z_STATUS S, Z_ORGREG O, Z_ZKP_VENDOR P, Z_LOV L, Z_LOV L2, Z_ZKP_SPECPRICE ZSP
 	    where Z.JUR_PERS = pJURPERS
        and Z.RN        = ZSP.ZKP_RN (+)
        and Z.VERSION  = pVERSION
 	      and ((pORGRN is null) or (Z.ORGRN    = pORGRN))
          and ((pPERIOD = 3) or (pPERIOD = 4 and zsp.SUMMA2 is not null) or (pPERIOD = 5 and zsp.SUMMA3 is not null))
		    --
 		    and Z.RN  = S.PERIOD  (+)
 		    and Z.VERSION = S.VERSION (+)
 		    and Z.ORGRN    = O.RN
        and Z.VENDOR_ALL_RN = P.RN(+)

        and Z.ZKP_TYPE = L.NUM (+)

        and L.PART (+) = 'ZKP_TYPE'
		and nvl(Z.EXIST_SIGN, 0) != 1
		and ZF_REESTR_STATUS_GET(pVERSION,  Z.RN, 'ZKP_REESTR') = 5

        and Z.GRBS_MARK = L2.NUM (+)
        and L2.PART (+) = 'ZKP_GRBSMARK'
        and (
               (pTYPE = 1 and Z.AGRDATE is not null or Z.AGRNUMB is not null or Z.VENDOR_ALL_RN is not null)
            or (pTYPE = 2 and Z.AGRDATE is null and Z.AGRNUMB is null and Z.VENDOR_ALL_RN is null)
            )
        and Z.RN in (select ZKP_RN from Z_ZKP_SPEC
                                  where ZKP_RN = Z.RN
                                    and ((pFOTYPE is null) or (FOTYPE2 = pFOTYPE))
                                    and ((pKBK is null) or (KBK_RN = pKBK))
                                    and ((pKOSGU is null) or (KOSGU_RN = pKOSGU))
                                    and ((pKVR is null) or (KVR_RN = pKVR)))
      order by RDATE desc, O.CODE, Z.NUMB
    )
    loop
        nCOUNTROWS := nvl(nCOUNTROWS,0) + 1;

        begin
            select sum(nvl(ZSP.SUMMA, 0)),
                   sum(nvl(SUMMA2,0)),
                   sum(nvl(SUMMA3,0)),
                   sum(case when nvl(PRICE,0) > 0 and nvl(PRICE_FACT,0) > 0 then QUANT * (nvl(PRICE,0) - nvl(PRICE_FACT,0)) else 0 end)
              into nSPEC_SUMMA, nSPEC_SUMMA2, nSPEC_SUMMA3, nECONOMY
              from Z_ZKP_SPECPRICE ZSP, Z_ZKP_SPEC ZS
             where ZSP.ZKP_RN = rec.ZKPRN
               and ZSP.ZKP_SPEC_RN = ZS.RN
			   --and ZS.KOSGU_RN != 172
			   and ZF_REESTR_STATUS_GET(pVERSION,  rec.ZKPRN, 'ZKP_REESTR') = 5
               and ((pFOTYPE is null) or (ZS.FOTYPE2 = pFOTYPE))
               and ((pKBK is null) or (ZS.KBK_RN = pKBK))
               and ((pKOSGU is null) or (ZS.KOSGU_RN = pKOSGU))
               and ((pKVR is null) or (ZS.KVR_RN = pKVR));
    		exception when others then
    			  nSPEC_SUMMA  := 0;
            nSPEC_SUMMA2 := 0;
            nSPEC_SUMMA3 := 0;
            nECONOMY     := 0;
    		end;

    		begin
      		select SUM(nvl(SUMMA,0)) into nPAY_SUMMA
      		  from Z_PAY P, Z_ZKP_SPEC_LINKS SL, Z_ZKP_SPEC ZS
      		 where P.RN = SL.PAY_RN
      		   and SL.ZKPSPEC_RN = ZS.RN
      		   and ZS.ZKP_RN = rec.ZKPRN
      		   and P.STATUS != 2
             and ((pFOTYPE is null) or (ZS.FOTYPE2 = pFOTYPE))
             and ((pKBK is null) or (ZS.KBK_RN = pKBK))
             and ((pKOSGU is null) or (ZS.KOSGU_RN = pKOSGU))
             and ((pKVR is null) or (ZS.KVR_RN = pKVR));
    		exception when others then
    			nPAY_SUMMA:= 0;
    		end;

        select COUNT(*)
          into nSOGLCOUNT
          from Z_STATUS S, Z_STATUS_HIST SH
         where S.RN = SH.PRN
           and S.PERIOD = rec.ZKPRN
           and SH.EXP_PLAN = 1;

        select COUNT(*)
          into nCHECKCOUNT
          from Z_STATUS S, Z_STATUS_HIST SH
         where S.RN = SH.PRN
           and S.PERIOD = rec.ZKPRN
           and SH.EXP_PLAN = 2;

        sORGNAME    := '<td class="c1 show"><div class="c1">'||rec.SHORT_NAME||'</></div></td>';

        sNUMB      := '<td class="c2"><div class="c2"><a href="'||APEX_UTIL.PREPARE_URL('f?p='||:APP_ID||':1210:'||:APP_SESSION||'::::P1210_RN,P1210_FROM_PAGE:'||rec.ZKPRN||','||638)||'" class = "link_code">'||rec.NUMB||'</a></div></td>';

        sRDATE      := '<td class="c3"><div class="c3">'|| to_char(rec.RDATE, 'dd.mm.yyyy')||'</></div></td>';

        sAGRNUMB    := '<td class="c4"><div class="c4">'||rec.AGRNUMB||'</></div></td>';
        sAGRDATE    := '<td class="c5"><div class="c5">'||to_char(rec.AGRDATE, 'dd.mm.yyyy')||'</></div></td>';

        sPROVIDER   := '<td class="c6"><div class="c6">'||rec.PROVIDER||'</></div></td>';

        sZKPOBJECT   := '<td class="c7"><div class="c7">'||case when length(rec.ZKP_OBJECT) > 100 then substr(rec.ZKP_OBJECT,0,100)||'...' else rec.ZKP_OBJECT end||'</></div></td>';

        sZKPTYPE    := '<td class="c8"><div class="c8">'||rec.ZKP_TYPE||'</></div></td>';

        if pPERIOD = 3 then
		    sSPECSUMMA  := '<td class="c10"><div class="c10"><a title="План 1й год: '||LTRIM(to_char(nvl(nSPEC_SUMMA2, 0),'999G999G999G999G999G990D00'),' ')||chr(13)||'План 2й год: '||LTRIM(to_char(nvl(nSPEC_SUMMA3, 0),'999G999G999G999G999G990D00'),' ')||'" class = "link_code" style="color:'||case when nPAY_SUMMA is null then 'black' when nvl(nPAY_SUMMA, 0) = nvl(nSPEC_SUMMA, 0) then 'green' else '#f37d0f' end||';">'||LTRIM(to_char(nvl(nSPEC_SUMMA, 0),'999G999G999G999G999G990D00'),' ')||'</a></div></td>';

		    sECONOMY    := '<td class="c11"><div class="c11" style="font-weight: bold; color:'||case when nECONOMY > 0 then 'green'  when nECONOMY < 0 then 'red' end||'">'||to_char(nECONOMY, '999G999G999G999G999G990D00')||'</></div></td>';

        elsif pPERIOD = 4 then
            sSPECSUMMA  := '<td class="c10"><div class="c10">'||LTRIM(to_char(nvl(nSPEC_SUMMA2, 0),'999G999G999G999G999G990D00'),' ')||'</a></div></td>';

		    sECONOMY    := '<td class="c11"><div class="c11">-</></div></td>';

        elsif pPERIOD = 5 then
            sSPECSUMMA  := '<td class="c10"><div class="c10">'||LTRIM(to_char(nvl(nSPEC_SUMMA3, 0),'999G999G999G999G999G990D00'),' ')||'</a></div></td>';

		    sECONOMY    := '<td class="c11"><div class="c11">-</></div></td>';
        end if;

        if rec.nSTATUS = 1 and nSOGLCOUNT > 1 then
            sSTATUS := '<td class="c12"><div style="font-weight: bold; color:'||ZF_GET_REDACTION_STATUS_COLOR (rec.nSTATUS)||'" class="c12" title="'||'Отправлен на согласование повторно'||'">'||ZF_GET_REDACTION_STATUS_NAME (rec.nSTATUS)|| case when rec.nSTATUS = 1 and nSOGLCOUNT > 1 then ' (П) ' end ||'</></div></td>';
        elsif rec.nSTATUS = 2 and nCHECKCOUNT > 1 then
            sSTATUS := '<td class="c12"><div style="font-weight: bold; color:'||ZF_GET_REDACTION_STATUS_COLOR (rec.nSTATUS)||'" class="c12" title="'||'Взят на проверку повторно'||'">'||ZF_GET_REDACTION_STATUS_NAME (rec.nSTATUS)|| case when rec.nSTATUS = 2 and nSOGLCOUNT > 1 then ' (П) ' end ||'</></div></td>';
        elsif rec.nSTATUS = 4 then
            begin
                select ROLE
                  into nACCEPTROLE
                  from (
                select U.ROLE
                  from Z_STATUS S, Z_STATUS_HIST SH, Z_USERS U
                 where S.RN = SH.PRN
                   and S.PERIOD = rec.ZKPRN
                   and SH.EXP_PLAN = 4
                   and SH.CHUSER = U.LOGIN
                 order by CHDATE desc
                    )
                where ROWNUM = 1;
            exception when others then
                nACCEPTROLE := null;
            end;

            sSTATUS := '<td class="c12"><div style="font-weight: bold; color:'||ZF_GET_REDACTION_STATUS_COLOR (rec.nSTATUS)||'" class="c12">'||ZF_GET_REDACTION_STATUS_NAME (rec.nSTATUS)|| case nACCEPTROLE when 1 then ' (П) '
                                                                                                                                                                                                             when 4 then ' (У) ' end ||'</></div></td>';
        else
            sSTATUS := '<td class="c12"><div style="font-weight: bold; color:'||ZF_GET_REDACTION_STATUS_COLOR (rec.nSTATUS)||'" class="c12"">'||ZF_GET_REDACTION_STATUS_NAME (rec.nSTATUS)||'</></div></td>';
        end if;

        sGRBSMARK   := '<td class="c13"><div class="c13">'||rec.GRBSMARK||'</></div></td>';

        if nvl(nCOUNTROWS,0) <= 500 then
            htp.p('
                <tr id="row_'||rec.ZKPRN||'" row="'||rec.ZKPRN||'">
                    '||sORGNAME||'
                    '||sNUMB||'
                    '||sRDATE||'
                    '||sAGRNUMB||'
                    '||sAGRDATE||'
                    '||sPROVIDER||'
                    '||sZKPOBJECT||'
                    '||sZKPTYPE||'

                    '||sSPECSUMMA||'
					          '||sECONOMY||'
                    '||sSTATUS||'
                    '||sGRBSMARK||'
                </tr>');
        else
            EXIT;
        end if;
    end loop;

    if nvl(nCOUNTROWS,0) > 500 then
		    sColor := 'font-weight:regular;color:red';
		    sMSG := 'Выбрано слишком много записей. Отображены первые 500. Необходимо использовать фильтры.';
	  else
		    sColor := '';
		    sMSG := '';
	  end if;

    htp.p('</tbody></table></div>');
    htp.p('<ul class="pagination" style="margin:0px">');
    htp.p('<li style="float:right;'||sColor||'">'||sMSG||' Всего записей: <b>'||nCOUNTROWS||'</b></li>');
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

        var el = document.getElementById("row_"+$v("P1211_SELECTED_ROW"));
		if (el!==null){
		 el.scrollIntoView(true);
		  $(el).children().css("background-color","yellow");
		}

    </script>');
end;
