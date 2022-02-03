create or replace procedure ZP_REP_SOGLSUB2022_90_MZYN
(
  pFILE            out BLOB,
  --
  pREDACTION       number,
  pREGNUMB         varchar,
  pUSER            varchar
)
as
  pJURPERS         number;
  pVERSION         number;
  pORGRN           number;
  --
  nVALUEROW        varchar2(4000);
  nCOUNTCOL        number;
  sTITLE           varchar2(2000);
  nNEXTPERIOD      Z_VERSIONS.NEXT_PERIOD%type;
  nPLAN1           Z_VERSIONS.PLAN1%type;
  nPLAN2           Z_VERSIONS.PLAN2%type;
  nKBK             number;
  nFUND            number;
  nNATPROJECT      number;
  nCURSUM          number;
  nDOPSOGL_TYPE    Z_REP_REESTR.DOPSOGL_TYPE%type;
  nSUBTYPE         Z_SOGLKIND.SUBTYPE%type;
  sFUNDNOTES       Z_FUNDS.NOTES%type;
  sSUBCODE         Z_FUNDS.SUBCODE%type;
  sKBKCODE         varchar2(100);
  sPRILNUM         varchar2(100);


  sMAINNUMB        Z_REP_REESTR.MAIN_SOGLNUMB%type;
  dMAINDATE        Z_REP_REESTR.SOGLDATE%type;
  sMAINDATE        varchar2(100);
  nRESULT          number;
  nItemCol         number;
  sFOOTERLEFT      varchar2(4000);
  sHEADERRIGTH     varchar2(4000);
  sORGFKR          varchar2(100);
  sORGPARTICLE     varchar2(100);
  sORGKVR          varchar2(100);
  bPRINT           boolean := false;

  nSUBSUM          Z_ORG_BUDGDETAIL.SUMMA%type;
  nCOUNT_STR       number := 0;

  sJURNAME         Z_JURPERS.FULLNAME%type;
  sGLAVACODE       Z_JURPERS.GLAVA_CODE%type;
  sJURPERSPOSITION Z_JURPERS.PERSPOSITION%type;
  sJURDIRECTOR     Z_JURPERS.DIRECTOR%type;
  sJURSIGNPERSON   Z_JURPERS.SIGNPERSON%type;
  sJURSIGNDOC      Z_JURPERS.SIGNDOC%type;
  sJURADDRESS      Z_JURPERS.ADDRESS%type;
  sJURBANKREQ      Z_JURPERS.BANKREQ%type;
  sJURUBPCODE      Z_JURPERS.UBP_CODE%type;

  sORGNAME         Z_ORGREG.NAME%type;
  sORGPERSPOSITION Z_ORGREG.PERSPOSITION%type;
  sORGSIGNORGNAME  Z_ORGREG.SIGNORGNAME%type;
  sORGDIRECTOR     Z_ORGREG.DIRECTOR%type;
  sORGSIGNPERSPOSITION Z_ORGREG.SIGNPERSPOSITION%type;
  sORGSIGNPERSON   Z_ORGREG.SIGNPERSON%type;
  sORGSIGNDOC      Z_ORGREG.SIGNDOC%type;
  sORGADDRESS      Z_ORGREG.ORG_ADDRESS%type;
  sORGINN          Z_ORGREG.INN%type;
  sORGRACC         Z_ORGREG.RACC%type;
  sORGBANKREQ      Z_ORGREG.BANKREQ_SUB%type;
  sORGBIK          Z_ORGREG.BIK%type;
  sORGKPP          Z_ORGREG.KPP%type;
  sORGOKTMO        Z_ORGREG.OKTMO%type;
  sORGOKPO         Z_ORGREG.OKPO%type;
  sOKVED_MAIN      Z_ORGREG.OKVED_MAIN%type;
  sORGUBPCODE      Z_ORGREG.UBP_CODE%type;

  sORGPERSNAME     Z_ESIGN.PERSNAME%type;
  dORGVALIDFROM    Z_ESIGN.VALIDFROM%type;
  dORGVALIDTO      Z_ESIGN.VALIDTO%type;
  nORGSIGN_ID      Z_ESIGN.SIGN_ID%type;
  sORGISSUERNAME   Z_ESIGN.ISSUERNAME%type;
  dORGSIGN_DATE    Z_ESIGN.SIGN_DATE%type;
  sORGPOSITION     Z_ESIGN.POSITION%type;

  sJURPERSNAME     Z_ESIGN.PERSNAME%type;
  dJURVALIDFROM    Z_ESIGN.VALIDFROM%type;
  dJURVALIDTO      Z_ESIGN.VALIDTO%type;
  nJURSIGN_ID      Z_ESIGN.SIGN_ID%type;
  sJURISSUERNAME   Z_ESIGN.ISSUERNAME%type;
  dJURSIGN_DATE    Z_ESIGN.SIGN_DATE%type;
  sJURPOSITION     Z_ESIGN.POSITION%type;

  nFUNDNOTES       varchar2(1000);
  sEXPDIRNAME      varchar2(1000);
  sDIRNAME         Z_EXPDIR.NAME%type;

  type CGRAPH is record
  (
    RN     number,
    CODE   varchar2(500)
  );

  type TGRAPH  is table of CGRAPH index by pls_integer;
  RGRAPH       TGRAPH;
begin
    begin
        APKG_XLSREP.OPEN_REPORT(nTYPE => 1);

        -- initializations globals
        -------------------------------------------------------
        begin
            select JUR_PERS, VERSION, ORGRN
              into pJURPERS, pVERSION, pORGRN
              from Z_REP_REESTR
             where RN = pREDACTION;
        exception when OTHERS then
            ZP_EXCEPTION (0, 'Ошибка. Редакция ПФХД не найдена.');
            pJURPERS  := null;
            pVERSION  := null;
            pORGRN    := null;
        end;

        -- initializations
        -------------------------------------------------------
        for rec in
        (
        select TGP.RN, TGP.CODE
          from Z_TRANSFER_GRAPH_PERIODS TGP
         where TGP.JURPERS  = pJURPERS
           and TGP.VERSION  = pVERSION
           and TGP.REST_SIGN is null
       order by TGP.PERIOD_NUM
        )
        loop
            nItemCol := nvl(nItemCol,0) + 1;
            RGRAPH(nItemCol).RN := rec.RN;
            RGRAPH(nItemCol).CODE := rec.CODE;
        end loop;

        if nvl(RGRAPH.COUNT,0) = 0 then
            ZP_EXCEPTION (0, 'Не заполнен словарь периодов.');
        end if;

        begin
            select GLAVA_CODE, PERSPOSITION, DIRECTOR, FULLNAME, SIGNPERSON, SIGNDOC, ADDRESS, BANKREQ, UBP_CODE
              into sGLAVACODE, sJURPERSPOSITION, sJURDIRECTOR, sJURNAME, sJURSIGNPERSON, sJURSIGNDOC, sJURADDRESS, sJURBANKREQ, sJURUBPCODE
              from Z_JURPERS
             where RN = pJURPERS;
        exception when others then
            sGLAVACODE       := null;
            sJURPERSPOSITION := null;
            sJURDIRECTOR     := null;
            sJURNAME         := null;
            sJURSIGNPERSON   := null;
            sJURSIGNDOC      := null;
            sJURADDRESS      := null;
            SJURBANKREQ      := null;
            sJURUBPCODE      := null;
        end;

        begin
            select NAME,
                   PERSPOSITION, DIRECTOR, SIGNORGNAME, SIGNPERSPOSITION, SIGNPERSON, SIGNDOC,
                   ORG_ADDRESS, INN, RACC, BANKREQ_SUB, BIK, KPP, OKTMO, OKPO, OKVED_MAIN,
                   UBP_CODE
              into sORGNAME,
                   sORGPERSPOSITION, sORGDIRECTOR, sORGSIGNORGNAME, sORGSIGNPERSPOSITION, sORGSIGNPERSON, sORGSIGNDOC,
                   sORGADDRESS, sORGINN, sORGRACC, SORGBANKREQ, sORGBIK, sORGKPP, sORGOKTMO, sORGOKPO, sOKVED_MAIN,
                   sORGUBPCODE
              from Z_ORGREG
             where RN = pORGRN;
        exception when others then
            sORGPERSPOSITION := null;
            sORGDIRECTOR     := null;
            sORGSIGNORGNAME  := null;
            sORGNAME         := null;
            sORGSIGNPERSPOSITION := null;
            sORGSIGNPERSON   := null;
            sORGSIGNDOC      := null;
            sORGADDRESS      := null;
            sORGINN          := null;
            sORGRACC         := null;
            sORGBANKREQ      := null;
            sORGBIK          := null;
            sORGKPP          := null;
            sORGOKTMO        := null;
            sORGOKPO         := null;
            sOKVED_MAIN      := null;
            sORGUBPCODE      := null;
        end;

        begin
            select NEXT_PERIOD, PLAN1, PLAN2
              into nNEXTPERIOD, nPLAN1, nPLAN2
              from Z_VERSIONS
             where RN       = pVERSION
               and JUR_PERS = pJURPERS;
        exception when others then
            nNEXTPERIOD := null;
            nPLAN1      := null;
            nPLAN2      := null;
        end;

        begin
            select RR.MAIN_SOGLNUMB, RR.SOGLDATE, SFKR, SPARTICLE, SKVR, RR.KBK, RR.FUND, KBK.NNATPROJECT, RR.DOPSOGL_TYPE, F.NOTES, F.SUBCODE, KBK.SCODE, SK.SUBTYPE, E.NAME EXPDIRNAME
              into sMAINNUMB, dMAINDATE, sORGFKR, sORGPARTICLE, sORGKVR, nKBK, nFUND, nNATPROJECT, nDOPSOGL_TYPE, sFUNDNOTES, sSUBCODE, sKBKCODE, nSUBTYPE, sEXPDIRNAME
              from Z_REP_REESTR RR, ZV_KBKALL KBK, Z_FUNDS F, Z_SOGLKIND SK, Z_PARTICLE P, Z_EXPDIR E
             where RR.RN           = pREDACTION
               and RR.KBK          = KBK.NKBK_RN (+)
               and RR.FUND         = F.RN (+)
               and KBK.NPARTICLE   = P.RN (+)
               and P.EXPDIR        = E.RN (+)
               and RR.DOPSOGL_TYPE = SK.NUMB
               and RR.JUR_PERS     = SK.JURPERS;
        exception when others then
            sMAINNUMB     := null;
            dMAINDATE     := null;
            sORGFKR       := null;
            sORGPARTICLE  := null;
            sORGKVR       := null;
            nKBK          := null;
            nFUND         := null;
            nNATPROJECT   := null;
            nDOPSOGL_TYPE := null;
            sFUNDNOTES    := null;
            sSUBCODE      := null;
            sKBKCODE      := null;
            nSUBTYPE      := null;
            sEXPDIRNAME   := null;
        end;

        begin
            select sum(B.SUMMA)
              into nSUBSUM
              from Z_ORG_BUDGDETAIL B, Z_FUNDS F
             where B.PRN        = pORGRN
               and B.FOTYPE2    = 5
               and B.TOTAL_SIGN = 0
               and B.VERSION    = pVERSION
               and B.JUR_PERS   = pJURPERS
               and B.FUND     = F.RN
               and F.SUBTYPE  = nSUBTYPE
               and ((nKBK) is null or (B.KBK = nKBK))
               and ((nFUND) is null or (B.FUND = nFUND));
        exception when others then
            nSUBSUM := null;
        end;

        begin
            select PERSNAME, VALIDFROM, VALIDTO, SIGN_ID, ISSUERNAME, SIGN_DATE, POSITION
              into sORGPERSNAME, dORGVALIDFROM, dORGVALIDTO, nORGSIGN_ID, sORGISSUERNAME, dORGSIGN_DATE, sORGPOSITION
              from Z_ESIGN
             where USEROLE = 'ORG'
               and ORGRN   = pORGRN
               and DOC_RN  = pREDACTION;
        exception when others then
            sORGPERSNAME   := null;
            dORGVALIDFROM  := null;
            dORGVALIDTO    := null;
            nORGSIGN_ID    := null;
            sORGISSUERNAME := null;
            dORGSIGN_DATE  := null;
            sORGPOSITION   := null;
        end;

        begin
            select PERSNAME, VALIDFROM, VALIDTO, SIGN_ID, ISSUERNAME, SIGN_DATE, POSITION
              into sJURPERSNAME, dJURVALIDFROM, dJURVALIDTO, nJURSIGN_ID, sJURISSUERNAME, dJURSIGN_DATE, sJURPOSITION
              from Z_ESIGN
             where USEROLE = 'GRBS'
               and ORGRN   = pORGRN
               and DOC_RN  = pREDACTION;
        exception when others then
            sJURPERSNAME   := null;
            dJURVALIDFROM  := null;
            dJURVALIDTO    := null;
            nJURSIGN_ID    := null;
            sJURISSUERNAME := null;
            dJURSIGN_DATE  := null;
            sJURPOSITION   := null;
        end;

        if dMAINDATE is not null then
            sMAINDATE := '"' ||to_char(dMAINDATE, 'dd') ||'" ' || LOWER(F_GET_MONTH (to_char(dMAINDATE, 'mm'),1)) || ' ' || to_char(dMAINDATE,'yyyy')||' г.';
        else
            sMAINDATE := '"__" ______________ 20__ г.';
        end if;

        begin
            select NOTES
              into nFUNDNOTES
              from Z_FUNDS
             where RN = nFUND;
        exception when others then
            nFUNDNOTES := null;
        end;

        --styles
        -------------------------------------------------------
        begin
            APKG_XLSREP.ADD_STYLE(sSTYLE => 'title',
            sHALIGNMENT       => 'Center',
            sFONTNAME         => 'PT Astra Serif',
            nFONTSIZE         => 14,
            nFONTBOLD         => 1,
            nWRAPTEXT         => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'center_str',
            nWRAPTEXT         => 1,
            sFONTNAME         => 'PT Astra Serif',
            nFONTSIZE         => 14,
            sHALIGNMENT       => 'Center');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'center_str8',
            nWRAPTEXT         => 1,
            sFONTNAME         => 'PT Astra Serif',
            nFONTSIZE         => 10,
            sHALIGNMENT       => 'Center');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'left_str',
            nWRAPTEXT         => 1,
            sFONTNAME         => 'PT Astra Serif',
            nFONTSIZE         => 12,
            sHALIGNMENT       => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'right_str',
            nWRAPTEXT           => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 12,
            sHALIGNMENT         => 'Right');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_left_str',
            nWRAPTEXT           => 1,
            sHALIGNMENT         => 'Left',
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            nFONTBOLD           => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bottom_left_str',
            nWRAPTEXT           => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sHALIGNMENT         => 'Left',
            sVALIGNMENT         => 'Bottom');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bottom_border_left_str',
            nWRAPTEXT           => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            nBORDERBOTTOMWEIGHT => 1,
            sHALIGNMENT         => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bottom_border_center_str',
            nWRAPTEXT           => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            nBORDERBOTTOMWEIGHT => 1,
            sHALIGNMENT         => 'Center');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'top_left_str',
            nWRAPTEXT           => 1,
            sHALIGNMENT         => 'Justify',
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sVALIGNMENT         => 'Top');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'border_left_str',
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sHALIGNMENT         => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'border_center_str',
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sHALIGNMENT         => 'Center');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'border_right_num',
            sHALIGNMENT         => 'Right',
            nWRAPTEXT           => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sINDENT             => 1,
            sNUMBERFORMAT       => 'Standard');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_border_right_str',
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sHALIGNMENT         => 'Right',
            nFONTBOLD           => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_center_str',
            nWRAPTEXT           => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sHALIGNMENT         => 'Center',
            nFONTBOLD           => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_border_right_num',
            sHALIGNMENT         => 'Right',
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sNUMBERFORMAT       => 'Standard',
            nFONTBOLD           => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sINDENT             => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_ecp1',
            nWRAPTEXT           => 1,
            nFONTBOLD           => 1,
            nBORDERTOPWEIGHT    => 2,
            nBORDERLEFTWEIGHT   => 2,
            nBORDERRIGHTWEIGHT  => 2,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sBORDERCOLOR        => '#0000ff',
            sFONTCOLOR          => '#0000ff',
            sHALIGNMENT         => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_ecp2',
            nWRAPTEXT           => 1,
            nFONTBOLD           => 1,
            nBORDERLEFTWEIGHT   => 2,
            nBORDERRIGHTWEIGHT  => 2,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sBORDERCOLOR        => '#0000ff',
            sFONTCOLOR          => '#0000ff',
            sHALIGNMENT         => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_ecp3',
            nWRAPTEXT           => 1,
            nFONTBOLD           => 1,
            nBORDERBOTTOMWEIGHT => 2,
            nBORDERLEFTWEIGHT   => 2,
            nBORDERRIGHTWEIGHT  => 2,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sBORDERCOLOR        => '#0000ff',
            sFONTCOLOR          => '#0000ff',
            sHALIGNMENT         => 'Left');
        end;
        -------------------------------------------------------

        begin
            ZP_REP_VDK_CHECK (pJURPERS   => pJURPERS,
                               pVERSION  => pVERSION,
                               pORGRN    => pORGRN,
                               pPFHDVERS => pREDACTION,
                               pPROCNAME => 'ZP_REP_SOGLSUB2022_MZYN',
                               pUSER     => null,
                               pRESULT   => nRESULT);
        end;

        sFOOTERLEFT := '&amp;L&amp;&quot;Verdana,Полужирный&quot;&amp;K000000&amp;L&amp;&quot;Verdana,Полужирный&quot;&amp;K00-014';

        if nvl(nRESULT,0) = 1 then
            sHEADERRIGTH := '&amp;C&amp;&quot;Times New Roman,обычный&quot;&amp;72&#10;&amp;100&#10;Черновик';
        else
            sHEADERRIGTH := '&amp;R&amp;&quot;Verdana,полужирный&quot; &amp;12 &amp;K00-009'||pREGNUMB||'';
        end if;

        begin -- Body

            -- initializations
            ------------------------------------------------------
            nCOUNTCOL     := 4;
            ------------------------------------------------------
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'Portrait', sPASSWORD => ZF_GET_REP_PASS, sSHEETNAME => 'Соглашение');
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);

            APKG_XLSREP.OPEN_TABLE();
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 160, nCOUNT => 4);


            sTITLE := 'СОГЛАШЕНИЕ';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCOUNTCOL-1, sCELLDATA => sTITLE, sCELLTYPE => 'String');

            sTITLE := 'о предоставлении субсидии в соответствии с абзацем вторым пункта 1 статьи 78.1 Бюджетного кодекса Российской Федерации';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCountCol-1, sCELLDATA => sTITLE, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'г. Салехард', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(место заключения соглашения)', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => sMAINDATE, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => '№ '||nvl(sMAINNUMB, '____'), sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => '(дата заключения соглашения)', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => '(номер  соглашения)', sCELLTYPE => 'String', nMERGEACROSS => 1);


            nVALUEROW := '        '|| sJURNAME  ||', именуемый в дальнейшем «Учредитель», в лице '||
            nvl(sJURSIGNPERSON, '______________________________________') || ', действующего на основании '||
            nvl(SJURSIGNDOC, '__________________') || ', с одной стороны, и '|| SORGNAME ||', именуемое в дальнейшем «Учреждение», в лице '||
            nvl(sORGSIGNPERSPOSITION, '______________________________________') || ' ' ||
            nvl(sORGSIGNPERSON, '______________________________________') ||', действующего на основании '||
            nvl(sORGSIGNDOC, '__________________') || ', с другой стороны, вместе именуемые «Стороны», в соответствии с Бюджетным кодексом Российской Федерации, Порядком определения объема и условий предоставления государственным автономным и бюджетным учреждениям Ямало-Ненецкого автономного округа субсидий на иные цели, утверждённого постановлением Правительства Ямало-Ненецкого автономного округа от 20 октября 2020 года № 1226-П (далее - Субсидия, Правила предоставления субсидии), заключили настоящее соглашение о нижеследующем.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (nVALUEROW, 90, 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            -- I. Предмет Соглашения
            nVALUEROW := 'I. Предмет Соглашения';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '1.1. Предметом настоящего Соглашения является предоставление Учреждению из окружного бюджета в 2022 году Субсидии в целях: '||nFUNDNOTES;
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            if nvl(nNATPROJECT,0) = 1 then
                nVALUEROW := '1.1.1. достижения результатов национальных (региональных) проектов ' || sEXPDIRNAME;
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
            end if;

            -- II. Условия и финансовое обеспечение предоставления Субсидии
            nVALUEROW := 'II. Условия и финансовое обеспечение предоставления Субсидии';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '2.1. Субсидия предоставляется Учреждению для достижения цели, указанной в пункте 1.1 настоящего Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '2.2. Субсидия предоставляется Учреждению в размере ' || TRIM(to_char(nSUBSUM,'999G999G999G999G990D00')) || ' ( '||IntToStrPrim (TRUNC(nSUBSUM), 2) || ') рублей '|| substr (to_char(nSUBSUM,'999G999G999G999G990D00'), -2,2) || ' копеек,  в том числе:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '2.2.1. в пределах лимитов бюджетных обязательств,  доведенных Учредителю как получателю средств окружного бюджета по кодам классификации расходов окружного бюджета (далее  -  коды  БК), по коду Субсидии '||sSUBCODE||', в следующем размере:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := 'в '||nNEXTPERIOD||' году ' || TRIM(to_char(nSUBSUM,'999G999G999G999G990D00')) || ' ( '||IntToStrPrim (TRUNC(nSUBSUM), 2) || ') рублей '|| substr (to_char(nSUBSUM,'999G999G999G999G990D00'), -2,2) || ' копеек по коду БК ' || sGLAVACODE || '.'|| sKBKCODE ;
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '2.3. Размер Субсидии рассчитывается в соответствии с Правилами предоставления субсидии утверждёнными постановлением Правительства Ямало-Ненецкого автономного округа от 20 октября 2020 года №1226-П.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            -- III. Порядок перечисления Субсидии
            nVALUEROW := 'III. Порядок перечисления Субсидии';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '3.1. Перечисление Субсидии осуществляется в установленном порядке приказом департамента финансов Ямало-Ненецкого автономного округа от 5 июля 2021 года № 89-29-01-03/134 «Об утверждении Порядка санкционирования расходов государственных бюджетных и автономных учреждений Ямало-Ненецкого автономного округа, источником финансового обеспечения которых являются субсидии, полученные в соответствии с абзацем вторым пункта 1 статьи 78.1 и статьей 78.2 Бюджетного кодекса Российской Федерации»:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '3.1.1. на лицевой счет, открытый Учреждению в УФК по Ямало-Ненецкому автономному округу согласно графику перечисления Субсидии в соответствии с приложением №1 к  настоящему  Соглашению, являющимся  неотъемлемой частью настоящего Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            -- IV. Взаимодействие Сторон
            nVALUEROW := 'IV. Взаимодействие Сторон';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1. Учредитель обязуется:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.1. обеспечивать предоставление Учреждению Субсидии на цель, указанную в пункте 1.1 настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.2. устанавливать значения результатов предоставления Субсидии в соответствии с приложением №3 к  настоящему  Соглашению; ';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.3. обеспечивать перечисление Субсидии на счет Учреждения, указанный в разделе VII настоящего Соглашения, согласно графику перечисления Субсидии в соответствии с приложением № 1 к настоящему Соглашению, являющимся неотъемлемой частью настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.4. утверждать Сведения об операциях с целевыми субсидиями на 2022 год (далее - Сведения) по форме Сведений об операциях с целевыми субсидиями на 2022 год (ф. 0501016), Сведения с учетом внесенных изменений не позднее 5 рабочих дней со дня получения указанных документов от Учреждения в соответствии с пунктом 4.3.2 настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.5. осуществлять контроль за соблюдением Учреждением цели и условий предоставления Субсидии, а также оценку достижения значений результатов предоставления Субсидии, установленных настоящим Соглашением, в том числе путем осуществления следующих мероприятий:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.5.1. проведение плановых и внеплановых проверок:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.5.1.1. по месту нахождения Учредителя на основании документов, представленных по его запросу Учреждением в соответствии с пунктом 4.3.4 настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.5.1.2. по месту нахождения Учреждения по документальному и фактическому изучению операций с использованием средств Субсидии, произведенных Учреждением;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.5.2. приостановление предоставления Субсидии в случае установления по итогам проверки(ок), указанной(ых) в пункте 4.1.5.1 настоящего Соглашения, факта(ов) нарушений цели(ей) и условий, определенных Правилами предоставления субсидии и настоящим Соглашением (получения от органа государственного финансового контроля информации о нарушении Учреждением цели(ей) и условий предоставления Субсидии, установленных Правилами предоставления субсидии, и настоящим Соглашением), до устранения указанных нарушений с обязательным уведомлением Учреждения не позднее 10 рабочих дней после принятия решения о приостановлении;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.5.3. направление требования Учреждению о возврате Учредителю в окружной бюджет Субсидии или ее части, в том числе в случае не устранения нарушений, указанных в пункте 4.1.5.2 настоящего Соглашения, в размере и сроки, установленные в данном требовании;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.6. рассматривать предложения, документы и иную информацию, направленную Учреждением, в том числе в соответствии с пунктами 4.4.1 - 4.4.2 настоящего Соглашения, в течение 10 рабочих дней со дня их получения и уведомлять Учреждение о принятом решении (при необходимости);';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.1.7. направлять разъяснения Учреждению по вопросам, связанным с исполнением настоящего Соглашения, не позднее 30 календарных дней со дня получения обращения Учреждения в соответствии с пунктом 4.4.5 настоящего Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.2. Учредитель вправе:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.2.1. запрашивать у Учреждения информацию и документы, необходимые для осуществления контроля за соблюдением Учреждением цели и условий предоставления Субсидии, установленных Правилами предоставления субсидии, и настоящим Соглашением в соответствии с пунктом 4.1.5 настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.2.2. принимать решение об изменении условий настоящего Соглашения на основании информации и предложений, направленных Учреждением в соответствии с пунктом 4.4.2 настоящего Соглашения, включая уменьшение размера Субсидии, а также увеличение размера Субсидии, при наличии неиспользованных лимитов бюджетных обязательств, указанных в пункте 2.2 настоящего Соглашения, и при условии предоставления Учреждением информации, содержащей финансово-экономическое обоснование данных изменений;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.2.3. принимать в установленном бюджетным законодательством Российской Федерации порядке решение о наличии или отсутствии потребности в направлении в 2022 году остатка Субсидии, не использованного в 2021 году, а также об использовании средств, поступивших в 2022 году Учреждению от возврата дебиторской задолженности прошлых лет, возникшей от использования Субсидии, на цель, указанную в пункте 1.1 настоящего Соглашения, не позднее 10 рабочих дней после получения от Учреждения следующих документов, обосновывающих потребность в направлении остатка Субсидии на цель, указанную в пункте 1.1 настоящего Соглашения:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.2.3.1. документы (копии документов), подтверждающие наличие и объем указанных обязательств учреждения (за исключением обязательств по выплатам физическим лицам);';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.2.3.2. мотивированное обращение с приложением пояснительной записки, которая должна содержать информацию о причинах образования остатков субсидии, а также обоснование потребности в их использовании на те же цели в текущем финансовом году;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.2.3.3. информации, обосновывающей потребность использования остатков субсидии согласно приложению № 7 к настоящему Соглашению.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3. Учреждение обязуется:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.1. направлять Учредителю на утверждение Сведения и Сведения с учетом внесенных изменений одновременно с предоставлением плана финансово-хозяйственной деятельности;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.2. использовать Субсидию для достижения цели, указанной в пункте 1.1 настоящего Соглашения, в соответствии с условиями предоставления Субсидии, установленными Правилами предоставления субсидии, и настоящим Соглашением на осуществление выплат, указанных в Сведениях;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.2.(1). обеспечить достижение значений результатов предоставления Субсидии и соблюдение сроков их достижения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.3. направлять по запросу Учредителя документы и информацию, необходимые для осуществления контроля за соблюдением цели и условий предоставления Субсидии в соответствии с пунктом 4.2.1 настоящего Соглашения, не позднее 5 рабочих дней со дня получения указанного запроса;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.4. направлять Учредителю ежеквартально в срок до 10 числа месяца, следующего за отчетным кварталом отчет:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.4.1. об осуществлении расходов, источником финансового обеспечения которых является субсидия на иные цели, по форме в соответствии с приложением № 4 к настоящему Соглашению, являющимся неотъемлемой частью настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.4.2. о достижении результатов предоставления субсидии на иные цели по форме в соответствии с приложением № 5 к настоящему Соглашению, являющимся неотъемлемой частью настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.4.3. о расходах, источником финансового обеспечения которых является Субсидия, по форме в соответствии с приложением № 6 к настоящему Соглашению, являющимся неотъемлемой частью настоящего Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.5. устранять выявленный(е) по итогам проверки, проведенной Учредителем, факт(ы) нарушения цели(ей) и условий предоставления Субсидии, определенных Правилами предоставления субсидии, и настоящим Соглашением (получения от органа государственного финансового контроля информации о нарушении Учреждением цели(ей) и условий предоставления Субсидии, установленных Правилами предоставления субсидии и настоящим Соглашением), включая возврат Субсидии или ее части Учредителю в окружной бюджет, в течение 10 рабочих дней со дня получения требования Учредителя об устранении нарушения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.3.6. возвращать неиспользованный остаток Субсидии в доход окружного бюджета в случае отсутствия решения Учредителя о наличии потребности в направлении не использованного в 2022 году остатка Субсидии на цель, указанную в пункте 1.1 настоящего Соглашения, не позднее 10 апреля 2023 года.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.4. Учреждение вправе:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.4.1. направлять Учредителю документы, указанные в пункте 4.2.3 настоящего Соглашения, не позднее 5 рабочих дней, со дня окончания финансового года;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.4.2. направлять Учредителю предложения о внесении изменений в настоящее Соглашение, в том числе в случае выявления необходимости изменения размера Субсидии с приложением информации, содержащей финансово-экономическое обоснование данного изменения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.4.3. направлять в 2023 году не использованный остаток Субсидии, полученный в соответствии с настоящим Соглашением, на осуществление выплат в соответствии с целью, указанной в пункте 1.1 настоящего Соглашения, на основании решения Учредителя, указанного в пункте 4.2.3 настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.4.4. направлять в 2023 году средства, поступившие Учреждению от возврата дебиторской задолженности прошлых лет, возникшей от использования Субсидии, на осуществление выплат в соответствии с целью, указанной в пункте 1.1 настоящего Соглашения, на основании решения Учредителя, указанного в пункте 4.2.3 настоящего Соглашения;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '4.4.5. обращаться к Учредителю в целях получения разъяснений в связи с исполнением настоящего Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            -- V. Ответственность Сторон
            APKG_XLSREP.ADD_ROW(nPAGEBREAK => 1);
            nVALUEROW := 'V. Ответственность Сторон';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '5.1. В случае неисполнения или ненадлежащего исполнения своих обязательств по настоящему Соглашению Стороны несут ответственность в соответствии с законодательством Российской Федерации и автономного округа.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            -- VI. Заключительные положения
            nVALUEROW := 'VI. Заключительные положения';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.1. Расторжение настоящего Соглашения Учредителем в одностороннем порядке возможно в случаях:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.1.1. прекращения деятельности Учреждения при реорганизации или ликвидации;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.1.2. нарушения Учреждением цели и условий предоставления Субсидии, установленных Правилами предоставления субсидии, и настоящим Соглашением;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.1.3. не достижения Учреждением значений результатов предоставления Субсидии;';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.2. Расторжение Соглашения осуществляется по соглашению сторон, за исключением расторжения в одностороннем порядке, предусмотренного пунктом 6.1 настоящего Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.3. Споры, возникающие между Сторонами в связи с исполнением настоящего Соглашения, решаются ими, по возможности, путем проведения переговоров с оформлением соответствующих протоколов или иных документов. При не достижении согласия споры между Сторонами решаются в судебном порядке.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.4. Настоящее Соглашение вступает в силу с даты его подписания лицами, имеющими право действовать от имени каждой из Сторон, но не ранее доведения лимитов бюджетных обязательств, указанных в пункте 2.2 настоящего Соглашения, и действует до 31 декабря 2022 года. При этом прекращение срока действия Соглашения не влечет прекращения обязательств Учреждения по предоставлению Учредителю отчетности в соответствии с Соглашением и обязательств Учреждения по возврату Субсидии или её части в соответствии с Соглашением.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.5. Изменение настоящего Соглашения, в том числе в соответствии с положениями пункта 4.2.2 настоящего Соглашения, осуществляется по соглашению Сторон и оформляется в виде дополнительного соглашения, являющегося неотъемлемой частью настоящего Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.6. Документы и иная информация, предусмотренные настоящим Соглашением, направляются Сторонами следующим способом:';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.6.1. на бумажном носителе, с дублированием  копии на электронный адрес.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            nVALUEROW := '6.7. Настоящее Соглашение заключено Сторонами в форме электронного документа в информационной системе «Отраслевой информационный ресурс» (на базе ПО «Электронный сервис «РАМЗЭС 2.0») и подписано усиленными квалифицированными подписями лиц, имеющих право действовать от имени каждой из Сторон Соглашения.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            -- VII. Платежные реквизиты Сторон
            nVALUEROW := 'VII. Платежные реквизиты Сторон';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Учредитель', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Учреждение', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => sJURNAME, RowStrLenght => 55, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => sORGNAME, RowStrLenght => 55, RowStrHeight => 20)));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Место нахождения:', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Место нахождения:', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => sJURADDRESS, RowStrLenght => 55, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => sORGADDRESS, RowStrLenght => 55, RowStrHeight => 20)));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURADDRESS, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGADDRESS, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Банковские реквизиты:', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Банковские реквизиты:', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 220);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURBANKREQ, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGBANKREQ, sCELLTYPE => 'String', nMERGEACROSS => 1);

            ---- Подпись
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => sJURPERSPOSITION, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, RowStrLenght => 45, RowStrHeight => 20)));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 30- length(sJURDIRECTOR), '_') || sJURDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 30- length(sORGDIRECTOR), '_') || sORGDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 1);

            if sJURPERSNAME is not null and sORGPERSNAME is not null then
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp1', sCELLDATA => 'Подписано. Заверено ЭП.', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp1', sCELLDATA => 'Подписано. Заверено ЭП.', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'ФИО: '||sJURPERSNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'ФИО: '||sORGPERSNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Должность: '||sJURPOSITION||'', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Должность: '||sORGPOSITION||'', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Действует c '||dJURVALIDFROM|| ' по: '||dJURVALIDTO||'', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Действует c '||dORGVALIDFROM|| ' по: '||dORGVALIDTO||'', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Серийный номер: '||nJURSIGN_ID||'', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Серийный номер: '||nORGSIGN_ID||'', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Издатель: '||sJURISSUERNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Издатель: '||sORGISSUERNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp3', sCELLDATA => 'Время подписания: '||to_char(dJURSIGN_DATE, 'DD.MM.YYYY HH24:MI:SS')||'', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp3', sCELLDATA => 'Время подписания: '||to_char(dORGSIGN_DATE, 'DD.MM.YYYY HH24:MI:SS')||'', sCELLTYPE => 'String', nMERGEACROSS => 1);
            end if;

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;

        begin -- Body

            nCOUNTCOL     := 8 + RGRAPH.COUNT;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение №1', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 120);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 120, nCOUNT => 7);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 120, nCOUNT => RGRAPH.COUNT);

            nValueRow := 'Приложение №1' || CHR(13) || CHR(10) ||
                          'к Соглашению от '||sMAINDATE||' № '|| sMAINNUMB || ' о предоставлении' || CHR(13) || CHR(10) ||
                          'субсидии в соответствии с абзацем вторым пункта 1 статьи' || CHR(13) || CHR(10) ||
                          '78.1 Бюджетного кодекса Российской Федерации';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'График перечисления Субсидии', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'КОДЫ', sCELLTYPE => 'String', nSKIPINDEX => nCOUNTCOL-2, nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование Учреждения', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => sORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 6, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по Сводному реестру', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => sORGUBPCODE, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование Учредителя', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => sJURNAME, sCELLTYPE => 'String', nMERGEACROSS => 6, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по Сводному реестру', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => sJURUBPCODE, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование федерального проекта', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 6, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по БК', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование регионального  проекта', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => 'Борьба с онкологическими заболеваниями', sCELLTYPE => 'String', nMERGEACROSS => 6, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по БК', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => sKBKCODE, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Вид документа', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => 0, sCELLTYPE => 'String', nMERGEACROSS => 6, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => '(первичный - "0", уточненный - "1", "2", "3", "...")', sCELLTYPE => 'String', nMERGEACROSS => 6, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Единица измерения: руб (с точностью до второго знака после запятой)', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по ОКЕИ', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 13);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '383', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Код классификации расходов бюджета', sCELLTYPE => 'String', nMERGEACROSS => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'СубКОСГУ', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Мероприятие', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Тип средств', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Итого на год', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'В том числе по месяцам (кварталам, иным периодам)', sCELLTYPE => 'String', nMERGEACROSS => (RGRAPH.COUNT-1));

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Рз', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'ПР', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'ЦСР', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'ВР', sCELLTYPE => 'String');

            for I in RGRAPH.first..RGRAPH.last
            loop
               APKG_XLSREP.ADD_CELL(sSTYLE       => 'border_center_str',
                                    sCELLDATA    => nvl(RGRAPH(I).CODE,'Период не задан'),
                                    sCELLTYPE    => 'String',
                                    nSKIPINDEX   => case I when 1 then 4 else 0 end);
            end loop;


            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            for I in 1..nCOUNTCOL
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => I, sCELLTYPE => 'String');
            end loop;

            for QKBK in
            (
             select TG.KBK_RN, TG.FUND_RN, substr(KBK.SFKR,1,2) PART, substr(KBK.SFKR,3,2) SUBPART, KBK.SPARTICLE, KBK.SKVR, KBK.SCODE, KBK.SEVENT_CODE, KBK.STYPEBS_NUMB, E.RN EXPMAT, K.CODE KOSGUCODE, E.KOSGU DOPKOSGU
               from Z_TRANSFER_GRAPH TG, ZV_KBKALL KBK, Z_EXPMAT E, Z_KOSGU K, Z_FUNDS F
              where TG.JURPERS  = pJURPERS
                and TG.VERSION  = pVERSION
                and TG.ORGRN    = pORGRN
                and TG.SUMMA    > 0
                and TG.KBK_RN   = KBK.NKBK_RN
                and TG.EXPMAT   = E.RN
                and E.KOSGURN   = K.RN
                and TG.FUND_RN  = F.RN
                and F.SUBTYPE   = nSUBTYPE
                and TG.FOTYPE2  = 5
                and ((nKBK) is null or (TG.KBK_RN = nKBK))
                and ((nFUND) is null or (TG.FUND_RN = nFUND))
              group by TG.KBK_RN, TG.FUND_RN, substr(KBK.SFKR,1,2), substr(KBK.SFKR,3,2), KBK.SPARTICLE, KBK.SKVR, KBK.SCODE, KBK.SEVENT_CODE, KBK.STYPEBS_NUMB, E.RN, K.CODE, E.KOSGU
              order by substr(KBK.SFKR,1,2), substr(KBK.SFKR,3,2), KBK.SPARTICLE, KBK.SKVR, KBK.SCODE, KBK.SEVENT_CODE, KBK.STYPEBS_NUMB, E.RN, K.CODE, E.KOSGU
            )
            loop
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.PART, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SUBPART, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SPARTICLE, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SKVR, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '241' || '.' || case when  QKBK.KOSGUCODE like '2%' then substr (QKBK.KOSGUCODE, 2,2)
                                                                                                      when  QKBK.KOSGUCODE like '3%' then substr (QKBK.KOSGUCODE, 1,2) end || '.' || QKBK.DOPKOSGU, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SEVENT_CODE, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => case when QKBK.STYPEBS_NUMB = '-' or QKBK.STYPEBS_NUMB = 'ОБ' then '300'
                                                                                      when QKBK.STYPEBS_NUMB = 'ОБ' then '800' else QKBK.STYPEBS_NUMB end, sCELLTYPE => 'String');

                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => '=SUM(RC[1]:RC['||RGRAPH.COUNT||'])', sCELLTYPE   => 'Formula');

                for I in RGRAPH.first..RGRAPH.last
                loop
                    nCURSUM := null;

                    begin
                        select sum(TG.SUMMA)
                          into nCURSUM
                          from Z_TRANSFER_GRAPH TG, ZV_KBKALL KBK
                         where TG.KBK_RN    = KBK.NKBK_RN
                           and TG.JURPERS  = pJURPERS
                           and TG.VERSION  = pVERSION
                           and TG.ORGRN    = pORGRN
                           and TG.FOTYPE2  = 5
                           and TG.PERIOD_RN = RGRAPH(I).RN
                           and TG.EXPMAT    = QKBK.EXPMAT
                           and KBK.SCODE ||'.'|| nvl(STYPEBS_NUMB,'-') = QKBK.SCODE ||'.'|| nvl(QKBK.STYPEBS_NUMB,'-')
                           and TG.KBK_RN = QKBK.KBK_RN
                           and TG.FUND_RN = QKBK.FUND_RN;
                    exception when others then
                        nCURSUM := null;
                    end;


                   APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => nvl(nCURSUM,0), sCELLTYPE   => 'Number');
                end loop;


                nCOUNT_STR := nCOUNT_STR + 1;
                bPrint := true;
            end loop;

            if nvl(nCOUNT_STR,0) > 0 then
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_border_right_str', sCELLDATA => 'ИТОГО:', sCELLTYPE => 'String', nSKIPINDEX => 6);

                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_border_right_num', sCELLDATA => '=sum(R[-'||nCOUNT_STR||']C:R[-1]C)', sCELLTYPE => 'Formula', nCOUNT => RGRAPH.COUNT+1);
            else
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'X', sCELLTYPE => 'String', nCOUNT => nCOUNTCOL);
            end if;

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Сроки перечисления субсидии: в соответствии с настоящим графиком в указанном месяце не ранее 1 числа и не позднее последнего числа данного месяца.', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL - 1);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);
            ---- Подпись
            APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => sJURPERSPOSITION, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, RowStrLenght => 45, RowStrHeight => 20)));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 30- length(sJURDIRECTOR), '_') ||sJURDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 30- length(sORGDIRECTOR), '_') ||sORGDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2);

            if sJURPERSNAME is not null and sORGPERSNAME is not null then
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp1', sCELLDATA => 'Подписано. Заверено ЭП.', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp1', sCELLDATA => 'Подписано. Заверено ЭП.', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'ФИО: '||sJURPERSNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'ФИО: '||sORGPERSNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Должность: '||sJURPOSITION||'', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Должность: '||sORGPOSITION||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Действует c '||dJURVALIDFROM|| ' по: '||dJURVALIDTO||'', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Действует c '||dORGVALIDFROM|| ' по: '||dORGVALIDTO||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Серийный номер: '||nJURSIGN_ID||'', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Серийный номер: '||nORGSIGN_ID||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Издатель: '||sJURISSUERNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Издатель: '||sORGISSUERNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp3', sCELLDATA => 'Время подписания: '||to_char(dJURSIGN_DATE, 'DD.MM.YYYY HH24:MI:SS')||'', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp3', sCELLDATA => 'Время подписания: '||to_char(dORGSIGN_DATE, 'DD.MM.YYYY HH24:MI:SS')||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
            end if;

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;

        begin -- Body
            nCOUNTCOL     := 5;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение №2', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 25);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 250);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 90, nCOUNT => 7);

            nValueRow := 'Приложение №2'|| CHR(13) || CHR(10) ||
                          'к Соглашению о предоставлении субсидии в'|| CHR(13) || CHR(10) ||
                          'соответствии с абзацем вторым пункта 1 статьи 78.1' || CHR(13) || CHR(10) ||
                          'Бюджетного кодекса Российской Федерации'|| CHR(13) || CHR(10) ||
                          'от '||sMAINDATE||' №'|| sMAINNUMB;

            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => ' Дополнительные исследования при проведении диспансеризации определенных групп взрослого населения в СОКБ', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 100);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '№ п/п', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Метод исследования', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Число лиц, подлежащих обследованию в 2022 году (чел.)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Пол, возраст', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Область исследования', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            for I in 1..nCOUNTCOL
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => I, sCELLTYPE => 'String');
            end loop;

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);

            ---- Подпись
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'Учредитель', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'Учреждение', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 1);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 25);

            APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => sJURPERSPOSITION, RowStrLenght => 40, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, RowStrLenght => 40, RowStrHeight => 20)));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 30- length(sJURDIRECTOR), '_') ||sJURDIRECTOR || '/', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 30- length(sORGDIRECTOR), '_') ||sORGDIRECTOR || '/', sCELLTYPE => 'String', nMERGEACROSS => 1,nSKIPINDEX => 1);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 1);

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;

        begin -- Body

            nCOUNTCOL     := 7;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение №3', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 50);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 210, nCOUNT => 3);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 115, nCOUNT => 3);

            nValueRow := 'Приложение №3'|| CHR(13) || CHR(10) ||
                          'к Соглашению о предоставлении субсидии в' || CHR(13) || CHR(10) ||
                          'соответствии с абзацем вторым пункта 1 статьи 78.1' || CHR(13) || CHR(10) ||
                          ' Бюджетного кодекса Российской Федерации' || CHR(13) || CHR(10) ||
                          'от '||sMAINDATE||' №'|| sMAINNUMB;

            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'Значения результатов предоставления субсидии на иные цели', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'КОДЫ', sCELLTYPE => 'String', nSKIPINDEX => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование Учреждения', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => sORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по Сводному реестру', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => sORGUBPCODE, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование Учредителя', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => sJURNAME, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по Сводному реестру', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => sJURUBPCODE, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование федерального проекта', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'по БК', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Вид документа', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_center_str', sCELLDATA => '0', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => '(первичный - "0", уточненный - "1", "2", "3", "...")', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '№ п/п', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование показателя', sCELLTYPE => 'String', nMERGEACROSS => 1, nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование проекта (мероприятия)', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Единица измерения по ОКЕИ/единица измерения', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Плановое значение показателя', sCELLTYPE => 'String', nMERGEDOWN => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'наименование', sCELLTYPE => 'String', nSKIPINDEX => 4);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'код', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String');

            for I in 1..nCOUNTCOL-1
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => I, sCELLTYPE => 'String', nMERGEACROSS => case when I = 2 then 1 else 0 end);
            end loop;

            nCOUNT_STR := null;
            for rec in
            (
             select C.*, R.NAME INDNAME, D.CODE MEASURECODE, D.OKEI
               from Z_CSINDRES_CARD C,  Z_CSINDRES R, Z_DICMUNTS D
              where C.CSINDRES = R.RN (+)
                and R.MEASURE  = D.RN (+)
                and C.ORGRN    = pORGRN
                and ((nFUND is null) or (C.FUND = nFUND))
            )
            loop
                begin
                    select P.NDIRNAME
                      into sDIRNAME
                      from Z_ORG_BUDGDETAIL B, ZV_KBKALL KBK, ZV_PARTICLE P
                     where B.FUND    = rec.FUND
                       and B.PRN     = pORGRN
                       and B.KBK     = KBK.NKBK_RN
                       and KBK.NPARTICLE = P.PARTRN;
                exception when others then
                    sDIRNAME := null;
                end;

                nCOUNT_STR := nvl(nCOUNT_STR,0) + 1;
                APKG_XLSREP.ADD_ROW;
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => nCOUNT_STR, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => rec.INDNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => sDIRNAME, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => rec.MEASURECODE, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => rec.OKEI, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => rec.PLANSUM, sCELLTYPE => 'Number');

            end loop;
            ---- Подпись

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'Учредитель', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'Учреждение', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 25);

            APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => sJURPERSPOSITION, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, RowStrLenght => 45, RowStrHeight => 20)));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 40- length(sJURDIRECTOR), '_') ||sJURDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 40- length(sORGDIRECTOR), '_') ||sORGDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2);

            if sJURPERSNAME is not null and sORGPERSNAME is not null then
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp1', sCELLDATA => 'Подписано. Заверено ЭП.', sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp1', sCELLDATA => 'Подписано. Заверено ЭП.', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'ФИО: '||sJURPERSNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'ФИО: '||sORGPERSNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Должность: '||sJURPOSITION||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Должность: '||sORGPOSITION||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Действует c '||dJURVALIDFROM|| ' по: '||dJURVALIDTO||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Действует c '||dORGVALIDFROM|| ' по: '||dORGVALIDTO||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Серийный номер: '||nJURSIGN_ID||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Серийный номер: '||nORGSIGN_ID||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Издатель: '||sJURISSUERNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp2', sCELLDATA => 'Издатель: '||sORGISSUERNAME||'', sCELLTYPE => 'String', nMERGEACROSS => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp3', sCELLDATA => 'Время подписания: '||to_char(dJURSIGN_DATE, 'DD.MM.YYYY HH24:MI:SS')||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_ecp3', sCELLDATA => 'Время подписания: '||to_char(dORGSIGN_DATE, 'DD.MM.YYYY HH24:MI:SS')||'', sCELLTYPE => 'String', nMERGEACROSS => 2);
            end if;

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;


        begin -- Body
            nCOUNTCOL     := 11;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение №4', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 70);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 130, nCOUNT => 10);

            nValueRow := 'Приложение №4' || CHR(13) || CHR(10) ||
                          'к Соглашению о предоставлении субсидии в'|| CHR(13) || CHR(10) ||
                          'соответствии с абзацем вторым пункта 1 статьи 78.1' || CHR(13) || CHR(10) ||
                          'Бюджетного кодекса Российской Федерации'|| CHR(13) || CHR(10) ||
                          'от '||sMAINDATE||' №'|| sMAINNUMB;

            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 25);

            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => 'Отчёт', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 40);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => 'об осуществлении расходов, источником финансового обеспечения которых является субсидия на иные цели', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-2, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(наименование учреждения)', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-2, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'за __________________________   ', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-2, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(период, нарастающим итогом с начала финансового года)', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-2, nSKIPINDEX => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'рубли', sCELLTYPE => 'String', nSKIPINDEX => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 120);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '№ п/п', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование исследований', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Плановое количество лиц подлежащих обследованию (чел.)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Фактическое количество обследованных лиц, (чел.)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Годовой плановый объем субсидии', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Перечислено учреждению на отчетную дату', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Кассовые расходы', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Фактические расходы', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Отклонение (графа 3 – графа 4)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Отклонение (графа 6 – графа 7)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Причины отклонения', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            for I in 1..nCOUNTCOL
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => I, sCELLTYPE => 'String');
            end loop;

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 1, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nCOUNT => nCOUNTCOL-1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 2, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nCOUNT => nCOUNTCOL-1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 3, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nCOUNT => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_border_right_str', sCELLDATA => 'Итого', sCELLTYPE => 'String', nMERGEACROSS => 4);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_border_right_num', sCELLDATA => 0, sCELLTYPE => 'Number', nCOUNT => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);
            ---- Подпись

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Руководитель учреждения', sCELLTYPE => 'String', nMERGEACROSS => 2 );

            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(подпись)  ', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(расшифровка подписи)  ', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 1 );

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2 );

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Главный бухгалтер', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(подпись)  ', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(расшифровка подписи)  ', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 1 );
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => '«_____»________________20    года', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Исполнитель: ФИО, телефон', sCELLTYPE => 'String' , nMERGEACROSS => 2);


            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;

        begin -- Body
            nCOUNTCOL     := 9;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение №5', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 25);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 250);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 90, nCOUNT => 7);

            nValueRow := 'Приложение №5'|| CHR(13) || CHR(10) ||
                          'к Соглашению о предоставлении субсидии в'|| CHR(13) || CHR(10) ||
                          'соответствии с абзацем вторым пункта 1 статьи 78.1' || CHR(13) || CHR(10) ||
                          'Бюджетного кодекса Российской Федерации'|| CHR(13) || CHR(10) ||
                          'от '||sMAINDATE||' №'|| sMAINNUMB;

            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 25);

            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'ОТЧЕТ', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'о достижении результатов предоставления субсидии на иные цели', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'по состоянию на _____________ 20__ года', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-2, nSKIPINDEX => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование получателя субсидии:____________________________', sCELLTYPE => 'String', nMERGEACROSS => 3 );
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Периодичность: ежеквартальная (с нарастающим итогом)', sCELLTYPE => 'String', nMERGEACROSS => 3);


            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);

            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '№ п/п', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование показателя', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование проекта (мероприятия)', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Единица измерения по ОКЕИ/единица измерения', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Плановое значение показателя', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Достигнутое значение показателя по состоянию на отчетную дату', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Процент выполнения плана', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Причина отклонения', sCELLTYPE => 'String', nMERGEDOWN => 1);


            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'наименование', sCELLTYPE => 'String', nSKIPINDEX => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'код', sCELLTYPE => 'String');


            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            for I in 1..nCOUNTCOL
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => I, sCELLTYPE => 'String');
            end loop;

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nCOUNT => nCOUNTCOL);


            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);
            ---- Подпись

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Руководитель учреждения', sCELLTYPE => 'String', nMERGEACROSS => 1 );

            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(подпись)  ', sCELLTYPE => 'String',  nSKIPINDEX => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(расшифровка подписи)  ', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2 );

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2 );

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Главный бухгалтер', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(подпись)  ', sCELLTYPE => 'String',  nSKIPINDEX => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(расшифровка подписи)  ', sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2 );
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Исполнитель: ФИО, телефон', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;

        begin -- Body
            nCOUNTCOL     := 14;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение №6', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 90, nCOUNT => nCOUNTCOL);

            nValueRow := 'Приложение №6'|| CHR(13) || CHR(10) ||
                          'к Соглашению о предоставлении субсидии в' || CHR(13) || CHR(10) ||
                          'соответствии с абзацем вторым пункта 1 статьи 78.1' || CHR(13) || CHR(10) ||
                          ' Бюджетного кодекса Российской Федерации' || CHR(13) || CHR(10) ||
                          'от '||sMAINDATE||' №'|| sMAINNUMB;
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'Отчет о расходах, источником финансового обеспечения которых является Субсидия', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'на "__" ____________ 20__ г.', sCELLTYPE => 'String', nSKIPINDEX => 5, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 40);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(период, нарастающим итогом с начала года)', sCELLTYPE => 'String', nSKIPINDEX => 5, nMERGEACROSS => 2);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование Учредителя', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 5);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование Учреждения', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 5);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Единица измерения: рубль (с точностью до второго десятичного знака)', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);


            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Субсидия', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Код по бюджетной классификации Российской Федерации ', sCELLTYPE => 'String', nMERGEDOWN => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Остаток Субсидии на начало текущего финансового года', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Поступления ', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Выплаты', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Курсовая разница', sCELLTYPE => 'String', nMERGEDOWN => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Остаток Субсидии на конец отчетного периода ', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'наименование', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'код', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'всего', sCELLTYPE => 'String', nMERGEDOWN => 1, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'из них, разрешенный к использованию', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'всего, в том числе', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'из окружного бюджета', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'возврат дебиторской задолженности прошлых лет', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'всего', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'из них: возвращено в окружной бюджет', sCELLTYPE => 'String', nMERGEDOWN => 1);


            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Всего', sCELLTYPE => 'String', nMERGEDOWN => 1, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'в том числе:', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'требуется в направлении на те же цели ', sCELLTYPE => 'String', nSKIPINDEX => 12);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'подлежит возврату ', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            for I in 1..nCOUNTCOL
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => I, sCELLTYPE => 'String');
            end loop;

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nCOUNT => nCOUNTCOL);


            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);
            ---- Подпись

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Руководитель (уполномоченное лицо)', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nSKIPINDEX => 1, nMERGEACROSS => 1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(должность)', sCELLTYPE => 'String', nSKIPINDEX => 3, nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(подпись)', sCELLTYPE => 'String', nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(расшифровка подписи)', sCELLTYPE => 'String', nSKIPINDEX => 1, nMERGEACROSS => 1 );

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => '"__" _________ 20__ г.', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Исполнитель: ФИО, телефон', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;

        begin -- Body
            nCOUNTCOL     := 24;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение №7', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 30);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 90, nCOUNT => nCOUNTCOL - 1);

            nValueRow := 'Приложение №7'|| CHR(13) || CHR(10) ||
                          'к Соглашению о предоставлении субсидии в' || CHR(13) || CHR(10) ||
                          'соответствии с абзацем вторым пункта 1 статьи 78.1' || CHR(13) || CHR(10) ||
                          ' Бюджетного кодекса Российской Федерации' || CHR(13) || CHR(10) ||
                          'от '||sMAINDATE||' №'|| sMAINNUMB;
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_center_str', sCELLDATA => 'ИНФОРМАЦИЯ,', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 40);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'обосновывающая потребность использования остатков субсидии', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 40);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Наименование главного распорядителя бюджетных средств', sCELLTYPE => 'String', nMERGEACROSS => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 6);


            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 60);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '№ п/п', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование цели предоставления субсидии', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование государственного учреждения', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Основание (реквизиты и наименование правового акта)', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Объем ассигнований, предусмотренный правовым актом (руб.)', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Дата докладной записки по открытию ассигнований ', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Дата заключения соглашения учредителя с государственным учреждением', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Дата перечисления субсидии государственному учреждению', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Объем субсидии, перечисленный государственному учреждению', sCELLTYPE => 'String', nMERGEDOWN => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Использовано государственным учреждением в отчетном году (руб.)', sCELLTYPE => 'String', nMERGEDOWN => 3);


            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Неиспользованный на 01 января текущего финансового года остаток субсидии', sCELLTYPE => 'String', nMERGEACROSS => 1, nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Потребность в возврате неиспользованного остатка целевых средств (субсидии)', sCELLTYPE => 'String', nMERGEACROSS => 11);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 90);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'объем субсидии (руб.) ', sCELLTYPE => 'String', nMERGEACROSS => 4, nSKIPINDEX => 12);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'предмет контракта (договора)', sCELLTYPE => 'String', nMERGEDOWN => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'в том числе', sCELLTYPE => 'String', nMERGEACROSS => 5);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 90);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'объем субсидии, руб.', sCELLTYPE => 'String', nMERGEDOWN => 1, nSKIPINDEX => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'дата возврата в окружной бюджет', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'потребность в средствах окружного бюджета', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'стоимость контракта, размещенная на торги, договора', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'экономия по результатам торгов', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'стоимость контракта (договора)', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'оплачено в отчетном году', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'дата проведения торгов', sCELLTYPE => 'String', nMERGEDOWN => 1, nSKIPINDEX => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'дата заключения контракта', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'номер контракта', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'первичное размещение/размещение за счет средств экономии иных контрактов (договоров)', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'дата поставки товаров (оказание услуг, выполнение работ) по контракту (договору) ', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 90);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'дата ', sCELLTYPE => 'String', nSKIPINDEX => 22);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'примечание к фактическому исполнению ', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            for I in 1..nCOUNTCOL
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => I, sCELLTYPE => 'String');
            end loop;

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => null, sCELLTYPE => 'String', nCOUNT => nCOUNTCOL);


            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);
            ---- Подпись

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 40);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Директор департамента', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(подпись)', sCELLTYPE => 'String', nSKIPINDEX => 2, nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Исполнитель', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_border_left_str', sCELLDATA => null, sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str8', sCELLDATA => '(подпись)', sCELLTYPE => 'String', nSKIPINDEX => 2, nMERGEACROSS => 1);

 
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'Тел.', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => '_______________ 20__ года', sCELLTYPE => 'String', nMERGEACROSS => 2);

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;

        if nvl(nRESULT,0) != 0 then
            begin -- page 11
                ZP_REP_VDK_LOG (pJURPERS      => pJURPERS,
                                 pVERSION     => pVERSION,
                                 pORGRN       => pORGRN,
                                 pPFHDVERS    => pREDACTION,
                                 pPROCNAME    => 'ZP_REP_SOGLSUB2022_MZYN',
                                 pUSER        => null);
            end;
        end if;

        APKG_XLSREP.CLOSE_REPORT();
        pFile := APKG_XLSREP.GET_BLOB;
    exception when others then
      --APKG_XLSREP.CLOSE_REPORT();
      APKG_XLSREP.FREE_BLOB;
      raise;
    end;
end;

​
