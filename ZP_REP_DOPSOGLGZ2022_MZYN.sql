create or replace procedure ZP_REP_DOPSOGLGZ2022_MZYN
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
  nCOUNTCOL        number;                   -- Количество колонок в отчете
  sTITLE           varchar2(2000);                    -- Заголовок отчёта
  nNEXTPERIOD      Z_VERSIONS.NEXT_PERIOD%type;       -- Очередной год
  nPLAN1           Z_VERSIONS.PLAN1%type;
  nPLAN2           Z_VERSIONS.PLAN2%type;
  nROWSTRLENGHT    number;
  nROWSTRHEIGHT    number;
  nKBKSUM          number;
  nKBK             number;
  nCOUNTPER        number;
  sGLAVACODE       Z_JURPERS.GLAVA_CODE%type;
  sORGNAME         Z_ORGREG.NAME%type;

  dMAINSOGLDATE    Z_REP_REESTR.SOGLDATE%type;
  sMAINSOGLNUMB    Z_REP_REESTR.MAIN_SOGLNUMB%type;
  sMAINDATE        varchar2(100);
  dMAINDATE        Z_REP_REESTR.SOGLDATE%type;

  dDOPSOGLDATE     Z_REP_REESTR.REP_DATE%type;
  sDOPSOGLNUMB     Z_REP_REESTR.SOGLNUMB%type;
  sDOPDATE         varchar2(100);

  nRESULT          number;
  nITEMCOL         number;
  nCURSUM          number;
  sFOOTERLEFT      varchar2(4000);
  sHEADERRIGTH     varchar2(4000);
  sORGFKR          varchar2(100);
  sORGPARTICLE     varchar2(100);
  sORGKVR          varchar2(100);
  bPRINT           boolean := false;

  nGZSUM           Z_ORG_BUDGDETAIL.SUMMA%type;
  nSUMMA           number;
  sPERIOD_NAME     varchar2(50);
  sNUMB            Z_ORGREG.NUMB%type;
  nCOUNT_STR       number := 0;

  sJURPERSPOSITION Z_JURPERS.PERSPOSITION%type;
  sORGPERSPOSITION Z_ORGREG.PERSPOSITION%type;
  sORGSIGNORGNAME  Z_ORGREG.SIGNORGNAME%type;
  sJURDIRECTOR     Z_JURPERS.DIRECTOR%type;
  sORGDIRECTOR     Z_ORGREG.DIRECTOR%type;
  sGLAVA_CODE      Z_JURPERS.GLAVA_CODE%type;

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
        begin
            select NAME, NUMB
              into sORGNAME, sNUMB
              from Z_ORGREG
             where RN = pORGRN;
        exception when OTHERS then
            sORGNAME  := null;
            sNUMB  := null;
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
            select RR.SOGLDATE, RR.MAIN_SOGLNUMB, REP_DATE, SOGLNUMB
              into dMAINSOGLDATE, sMAINSOGLNUMB, dDOPSOGLDATE, sDOPSOGLNUMB
              from Z_REP_REESTR RR
             where RR.RN  = pREDACTION;
        exception when others then
            dMAINSOGLDATE := null;
            sMAINSOGLNUMB := null;
            dDOPSOGLDATE  := null;
            sDOPSOGLNUMB  := null;
        end;

        begin
            select sum(SUMMA)
              into nGZSUM
              from Z_ORG_BUDGDETAIL
             where PRN        = pORGRN
               and RTYPE      = 0
               and TOTAL_SIGN = 0
               and VERSION    = pVERSION
               and JUR_PERS   = pJURPERS;
        exception when others then
            nGZSUM := null;
        end;

        begin
            select NEXT_PERIOD
              into nNextPeriod
              from Z_VERSIONS
             where RN = pVERSION;
        exception when others then
            nNextPeriod := null;
        end;

        begin
            select COUNT(*)
              into nCOUNTPER
              from Z_TRANSFER_GRAPH_PERIODS
             where VERSION = pVERSION
               and REST_SIGN is null;
        exception when others then
            nCOUNTPER := null;
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

        if dDOPSOGLDATE is not null then
            sDOPDATE := '"' ||to_char(dDOPSOGLDATE, 'dd') ||'" ' || LOWER(F_GET_MONTH (to_char(dDOPSOGLDATE, 'mm'),1)) || ' ' || to_char(dDOPSOGLDATE,'yyyy')||' г.';
        else
            sDOPDATE := '"__" ______________ 20__ г.';
        end if;

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
            select GLAVA_CODE, PERSPOSITION, DIRECTOR
              into sGLAVA_CODE, sJURPERSPOSITION, sJURDIRECTOR
              from Z_JURPERS
             where RN = pJURPERS;
        exception when others then
            sGLAVA_CODE      := null;
            sJURPERSPOSITION := null;
            sJURDIRECTOR     := null;
        end;

        begin
            select PERSPOSITION, DIRECTOR, SIGNORGNAME
              into sORGPERSPOSITION, sORGDIRECTOR, sORGSIGNORGNAME
              from Z_ORGREG
             where RN = pORGRN;
        exception when others then
            sORGPERSPOSITION := null;
            sORGDIRECTOR     := null;
            sORGSIGNORGNAME  := null;
        end;

        -- style
        -------------------------------------------------------
        begin
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

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'left_str',
            nWRAPTEXT         => 1,
            sFONTNAME         => 'PT Astra Serif',
            nFONTSIZE         => 14,
            sHALIGNMENT       => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'right_str',
            nWRAPTEXT           => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
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

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_border_right_num',
            sHALIGNMENT         => 'Right',
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            sNUMBERFORMAT       => 'Standard',
            nFONTBOLD           => 1,
            sINDENT             => 1);
        end;
        -------------------------------------------------------

        begin
            ZP_REP_VDK_CHECK (pJURPERS   => pJURPERS,
                               pVERSION  => pVERSION,
                               pORGRN    => pORGRN,
                               pPFHDVERS => pREDACTION,
                               pPROCNAME => 'ZP_REP_DOPSOGLGZ2022_MZYN',
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
            nROWSTRLENGHT := 118;
            nROWSTRHEIGHT := 18;
            nCOUNTCOL     := 4;
            ------------------------------------------------------

            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'Portrait', sPASSWORD => ZF_GET_REP_PASS, sSHEETNAME => 'Соглашение');
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);

            APKG_XLSREP.OPEN_TABLE();
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 160, nCOUNT => 4);

            sTITLE := 'Дополнительное соглашение №'||nvl(sDOPSOGLNUMB, '___');
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCOUNTCOL-1, sCELLDATA => sTITLE, sCELLTYPE => 'String');

            sTITLE := 'к Соглашению о порядке и условиях предоставления государственному бюджетному и государственному автономному учреждению субсидии на финансовое обеспечение выполнения государственного задания на оказание государственных услуг (выполнение работ)' || CHR(13)|| CHR(10) || sMAINDATE||' г.';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 120);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCountCol-1, sCELLDATA => sTITLE, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'г. Салехард', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => sDOPDATE, sCELLTYPE => 'String', nMERGEACROSS => 1);

            for QOrg in
            (
             select JP.SDIRECTOR        SJURDIRECTOR,           -- директор ГРБС
                    JP.SJURNAME         SJURNAME,               -- наименование ГРБС
                    JP.SPERSPOSITION    SJURPERSPOSITION,       -- должность под. лица ГРБС
                    JP.SSIGNPERSON      SJURSIGNPERSON,         -- руководитель ГРБС. в род. пад.
                    JP.SSIGNDOC         SJURSIGNDOC,            -- наим. и номер документа основания ГРБС
                    JP.SJUR_ADDRESS     SJURADDRESS,            -- юр.адрес ГРБС
                    JP.SBANKREQ         SJURBANKREQ,            -- банк. рек. ГРБС

                    O.SDIRECTOR         SORGDIRECTOR,           -- директор орг.
                    O.SORGNAME          SORGNAME,               -- наименование орг.
                    O.SSIGNPERSON       SORGSIGNPERSON,       -- руководитель орг. в род. пад.
                    O.SSIGNDOC          SORGSIGNDOC,            -- наим. и номер документа основания орг
                    O.SPERSPOSITION     SORGPERSPOSITION,       -- должность под. лица орг
                    O.SORG_ADDRESS      SORGADDRESS,            -- юр.адрес орг
                    O.SINN              SORGINN,                -- ИНН орг
                    O.SKPP              SORGKPP,                -- КПП орг
                    O.SRACC             SORGRACC,               -- р/с орг
                    O.SLACC             SORGLACC,               -- л/с орг
                    O.SBANKREQ          SORGBANKREQ,            -- банк. рек. орг
                    O.SSIGNORGNAME      SORGSIGNORGNAME,      -- Наименование учреждения (в родительном падеже)
                    O.SSIGNPERSPOSITION SORGSIGNPERSPOSITION, -- Должность (в родительном падеже):
                    O.SBIK              SORGBIK,              -- БИК
                    O.SOKTMO            SORGOKTMO,            -- ОКТМО
                    O.SOKPO             SORGOKPO,             -- ОКПО
                    O.NORGTYPE          NORGTYPE,             -- Тип учреждения
                    O.NORDERNUMB        NORDERNUMB,            -- №п/п
                    O.SOKVED_MAIN        SOKVED_MAIN            -- ОКВЕД
               from ZV_ORGREG O,
                    ZV_JURPERS JP
              where O.NJURPERS = JP.NJURPERS
                and O.NVERSION = pVERSION
                and O.NORGRN   = pORGRN
            )
            loop
                nValueRow := '        '|| QOrg.SJURNAME  ||', именуемый в дальнейшем «Учредитель», в лице ' ||
                nvl(QOrg.SJURSIGNPERSON, '______________________________________') || ', действующего(-ей)  на основании '||
                nvl(QOrg.SJURSIGNDOC, '__________________') || ', с одной стороны, и '|| QOrg.SORGNAME ||', именуемое в дальнейшем «Учреждение», в лице '||
                nvl(QOrg.SORGSIGNPERSPOSITION, '______________________________________') || ' ' ||
                nvl(QOrg.SORGSIGNPERSON, '______________________________________') ||', действующего(-ей) на основании '||
                nvl(QOrg.SORGSIGNDOC, '__________________') || ', с другой стороны, вместе именуемые «Стороны», в целях оптимизации работы, заключили настоящее дополнительное соглашение к Соглашению о порядке и условиях предоставления государственному бюджетному и государственному автономному учреждению субсидии на финансовое обеспечение выполнения государственного задания на оказание государственных услуг (выполнение работ) (далее – Соглашение) о нижеследующем:';

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HeightRow (nValueRow, 90, 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCountCol-1);

                nValueRow := '        1.Приложение к Соглашению изложить в редакции согласно приложению к настоящему дополнительному соглашению.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HeightRow (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCountCol-1);

                nValueRow := '        2. Остальные условия остаются неизменными. ';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HeightRow (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCountCol-1);
                nValueRow := '        3. Настоящее дополнительное соглашение составлено в трех экземплярах, из них два экземпляра Учредителю, один экземпляр Учреждению.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HeightRow (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCountCol-1);

                nValueRow := '        4. Настоящее дополнительное соглашение вступает в силу с момента подписания сторонами и действует до окончания срока действия Соглашения.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HeightRow (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCountCol-1);

                APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);
                ---- Подпись
                APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HeightRow (StrVal => 'Учредитель: '|| CHR(13)|| CHR(10) ||QOrg.SJURPERSPOSITION, RowStrLenght => 40, RowStrHeight => 20), ZF_HeightRow (StrVal => 'Учреждение: '|| CHR(13)|| CHR(10) ||QOrg.SORGPERSPOSITION || ' ' ||QOrg.SORGSIGNORGNAME, RowStrLenght => 40, RowStrHeight => 20)));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'Учредитель: '|| CHR(13)|| CHR(10) ||QOrg.SJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'Учреждение: '|| CHR(13)|| CHR(10) ||QOrg.SORGPERSPOSITION || ' ' ||QOrg.SORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 50- length(QOrg.SJURDIRECTOR), '_') || QOrg.SJURDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 50- length(QOrg.SORGDIRECTOR), '_') || QOrg.SORGDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 1);
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
            end loop;

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
        end;


        begin -- Body

            nCOUNTCOL     := 8 + RGRAPH.COUNT;
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение к допсоглашению', sPASSWORD => ZF_GET_REP_PASS);
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
            APKG_XLSREP.OPEN_TABLE();

            APKG_XLSREP.ADD_COLUMN(nWIDTH => 120);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 100, nCOUNT => 7);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 120, nCOUNT => RGRAPH.COUNT);

            nValueRow := 'Приложение
                          к допсоглашению к Соглашению о порядке и условиях предоставления государственному бюджетному и
                          государственному автономному учреждению субсидии на финансовое обеспечение
                          выполнения государственного задания на оказание государственных услуг (выполнение работ)';
            APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nValueRow, RowStrLenght => 90, RowStrHeight => 20));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => nValueRow, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'График', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => 'перечисления субсидии в '||nNEXTPERIOD||' году', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => 'рублей', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Код классификации расходов бюджета', sCELLTYPE => 'String', nMERGEACROSS => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'СубКОСГУ', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Мероприятие', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Код дополнительной информации', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Итого на год', sCELLTYPE => 'String', nMERGEDOWN => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'В том числе по месяцам (кварталам, иным периодам)', sCELLTYPE => 'String', nMERGEACROSS => (RGRAPH.COUNT-1));

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
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
             select substr(KBK.SFKR,1,2) PART, substr(KBK.SFKR,3,2) SUBPART, KBK.SPARTICLE, KBK.SKVR, KBK.SCODE, KBK.SEVENT_CODE, KBK.STYPEBS_NUMB, E.RN EXPMAT, K.CODE KOSGUCODE, E.KOSGU DOPKOSGU, KBK.NKBK_RN NKBK_RN
               from Z_TRANSFER_GRAPH TG, ZV_KBKALL KBK, Z_EXPMAT E, Z_KOSGU K
              where TG.JURPERS  = pJURPERS
                and TG.VERSION  = pVERSION
                and TG.ORGRN    = pORGRN
                and TG.SUMMA    > 0
                and TG.KBK_RN   = KBK.NKBK_RN
                and TG.EXPMAT   = E.RN
                and E.KOSGURN   = K.RN
                and TG.FOTYPE2  = 4
              group by substr(KBK.SFKR,1,2), substr(KBK.SFKR,3,2), KBK.SPARTICLE, KBK.SKVR, KBK.SCODE, KBK.SEVENT_CODE, KBK.STYPEBS_NUMB, E.RN, K.CODE, E.KOSGU, KBK.NKBK_RN
              order by substr(KBK.SFKR,1,2), substr(KBK.SFKR,3,2), KBK.SPARTICLE, KBK.SKVR, KBK.SCODE, KBK.SEVENT_CODE, KBK.STYPEBS_NUMB, E.RN, K.CODE, E.KOSGU, KBK.NKBK_RN
            )
            loop
                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.PART, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SUBPART, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SPARTICLE, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SKVR, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '241' || '.' || case when  QKBK.KOSGUCODE like '2%' and QKBK.KOSGUCODE not like '29%' then substr (QKBK.KOSGUCODE, 2,2)
                                                                                                          when  QKBK.KOSGUCODE like '3%' then substr (QKBK.KOSGUCODE, 1,2)
                                                                                                          when  QKBK.KOSGUCODE like '29%' then 90 end || '.' || QKBK.DOPKOSGU, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QKBK.SEVENT_CODE, sCELLTYPE => 'String');
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => case when QKBK.STYPEBS_NUMB = '-' or QKBK.STYPEBS_NUMB = 'ОБ' then 300
                                                                                      when QKBK.STYPEBS_NUMB = 'ОБ' then '800' end, sCELLTYPE => 'String');

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
                           and TG.FOTYPE2  = 4
                           and TG.PERIOD_RN = RGRAPH(I).RN
                           and TG.EXPMAT    = QKBK.EXPMAT
                           and KBK.NKBK_RN  = QKBK.NKBK_RN
                           and KBK.SCODE ||'.'|| nvl(STYPEBS_NUMB,'-') = QKBK.SCODE ||'.'|| nvl(QKBK.STYPEBS_NUMB,'-');
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


            APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);
            ---- Подпись
            APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => sJURPERSPOSITION, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, RowStrLenght => 45, RowStrHeight => 20)));
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => sORGPERSPOSITION || ' ' ||sORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 40- length(sJURDIRECTOR), '_') ||sJURDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 40- length(sORGDIRECTOR), '_') ||sORGDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2);
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

        /*
        if nvl(nRESULT,0) != 0 then
            begin -- page 11
                ZP_REP_VDK_LOG (pJURPERS      => pJURPERS,
                                 pVERSION     => pVERSION,
                                 pORGRN       => pORGRN,
                                 pPFHDVERS    => pREDACTION,
                                 pPROCNAME    => 'ZP_REP_DOPSOGLGZ2022_MZYN',
                                 pUSER        => null);
            end;
        end if;    */

        APKG_XLSREP.CLOSE_REPORT();
        pFile := APKG_XLSREP.GET_BLOB;
    exception when others then
      --APKG_XLSREP.CLOSE_REPORT();
      APKG_XLSREP.FREE_BLOB;
      raise;
    end;
end;

​
