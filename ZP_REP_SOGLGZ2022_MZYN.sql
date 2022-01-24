create or replace procedure ZP_REP_SOGLGZ2022_MZYN
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
  nROWSTRLENGHT    number;
  nROWSTRHEIGHT    number;
  nKBKSUM          number;
  nKBK             number;
  nCOUNTPER        number;
  nCURSUM          number;
  nGRAPHRN         number;
  sGLAVACODE       Z_JURPERS.GLAVA_CODE%type;
  sORGNAME         Z_ORGREG.NAME%type;

  sMAINNUMB        Z_REP_REESTR.MAIN_SOGLNUMB%type;
  sGRBS_NOTES      Z_REP_REESTR.GRBS_NOTES%type;
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

  nGZSUM           Z_ORG_BUDGDETAIL.SUMMA%type;
  nDETGZSUM        Z_TRANSFER_GRAPH.SUMMA%type;
  nSUMMA           number;
  sPERIOD_NAME     varchar2(50);
  sNUMB            Z_ORGREG.NUMB%type;
  nCOUNT_STR       number := 0;

  sJURPERSPOSITION Z_JURPERS.PERSPOSITION%type;
  sORGPERSPOSITION Z_ORGREG.PERSPOSITION%type;
  sORGSIGNORGNAME  Z_ORGREG.SIGNORGNAME%type;
  sJURDIRECTOR     Z_JURPERS.DIRECTOR%type;
  sORGDIRECTOR     Z_ORGREG.DIRECTOR%type;


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

  type t_alph is table of varchar2(1);
  ARR_NUMALPHA t_alph := t_alph('а', 'б', 'в', 'г', 'д', 'е','ж', 'з', 'и', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'э','ю','я');

begin

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
        select NAME
          into sORGNAME
          from Z_ORGREG
         where RN = pORGRN;
    exception when OTHERS then
        sORGNAME  := null;
    end;

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
    -------------------------------------------------------

    begin
        APKG_XLSREP.OPEN_REPORT(nTYPE => 1);
        begin -- Style
          ----------------------------------------------Начало стилей--------------------------------
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
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sNUMBERFORMAT       => 'Standard',
            nFONTBOLD           => 1,
            sINDENT             => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_ecp1',
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            nWRAPTEXT           => 1,
            nFONTBOLD           => 1,
            nBORDERTOPWEIGHT    => 2,
            nBORDERLEFTWEIGHT   => 2,
            nBORDERRIGHTWEIGHT  => 2,
            sBORDERCOLOR        => '#0000ff',
            sFONTCOLOR          => '#0000ff',
            sHALIGNMENT         => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_ecp2',
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            nWRAPTEXT           => 1,
            nFONTBOLD           => 1,
            nBORDERLEFTWEIGHT   => 2,
            nBORDERRIGHTWEIGHT  => 2,
            sBORDERCOLOR        => '#0000ff',
            sFONTCOLOR          => '#0000ff',
            sHALIGNMENT         => 'Left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'bold_ecp3',
            sFONTNAME           => 'PT Astra Serif',
            nFONTSIZE           => 14,
            nWRAPTEXT           => 1,
            nFONTBOLD           => 1,
            nBORDERBOTTOMWEIGHT => 2,
            nBORDERLEFTWEIGHT   => 2,
            nBORDERRIGHTWEIGHT  => 2,
            sBORDERCOLOR        => '#0000ff',
            sFONTCOLOR          => '#0000ff',
            sHALIGNMENT         => 'Left');
            ----------------------------------------------Конец стилей--------------------------------
        end;

        begin
            ZP_REP_VDK_CHECK (pJURPERS   => pJURPERS,
                               pVERSION  => pVERSION,
                               pORGRN    => pORGRN,
                               pPFHDVERS => pREDACTION,
                               pPROCNAME => 'ZP_REP_SOGLGZ2020_MZYN',
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
                select RR.MAIN_SOGLNUMB, RR.SOGLDATE, GRBS_NOTES
                  into sMAINNUMB, dMAINDATE, sGRBS_NOTES
                  from Z_REP_REESTR RR
                 where RR.RN  = pREDACTION;
            exception when others then
                sMAINNUMB    := null;
                dMAINDATE    := null;
                sORGFKR      := null;
                sORGPARTICLE := null;
                sORGKVR      := null;
                sGRBS_NOTES  := null;
            end;

            begin -- Body
            begin
                select NUMB
                  into sNUMB
                  from Z_ORGREG
                 where RN       = pORGRN
                   and VERSION  = pVERSION
                   and JUR_PERS = pJURPERS;
            exception when others then
                sNUMB  := null;
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
                select sum(SUMMA)
                  into nDETGZSUM
                  from Z_TRANSFER_GRAPH
                 where ORGRN   = pORGRN
                   and VERSION = pVERSION
                   and JURPERS = pJURPERS
                   and FOTYPE2 = 4;
            exception when others then
                nDETGZSUM := null;
            end;

            begin
                select NEXT_PERIOD
                  into nNextPeriod
                  from Z_VERSIONS
                 where RN = pVERSION;
            exception when others then
                nNextPeriod := null;
            end;

            /*sFOOTERLEFT := '&amp;L&amp;&quot;Verdana,Полужирный&quot;&amp;K000000&amp;L&amp;&quot;Verdana,Полужирный&quot;&amp;K00-014';
            if nvl(nGZSUM,0) <> nvl(nDETGZSUM,0) then
                sHEADERRIGTH  := '&amp;C&amp;&quot;Times New Roman,обычный&quot;&amp;72&#10;&amp;100&#10;Черновик';
            else
                sHEADERRIGTH := '&amp;R&amp;&quot;Verdana,Полужирный&quot;&amp;K000000&amp;R&amp;&quot;Verdana,Полужирный&quot;&amp;K00-014'||sNUMB||'';
            end if;*/

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

            ------------------------------------------------------


            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'Portrait', sPASSWORD => ZF_GET_REP_PASS, sSHEETNAME => 'Соглашение');
            APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);

            APKG_XLSREP.OPEN_TABLE();
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 160, nCOUNT => 4);


            sTITLE := 'СОГЛАШЕНИЕ';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCOUNTCOL-1, sCELLDATA => sTITLE, sCELLTYPE => 'String');

            sTITLE := 'о порядке и условиях предоставления государственному бюджетному и государственному автономному учреждению субсидии на финансовое обеспечение выполнения государственного задания на оказание государственных услуг (выполнение работ)';
            APKG_XLSREP.ADD_ROW(nHEIGHT => 50);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCountCol-1, sCELLDATA => sTITLE, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str', sCELLDATA => 'г. Салехард', sCELLTYPE => 'String', nMERGEACROSS => 1);

            if dMAINDATE is not null then
                    sMAINDATE := '"' ||to_char(dMAINDATE, 'dd') ||'" ' || LOWER(F_GET_MONTH (to_char(dMAINDATE, 'mm'),1)) || ' ' || to_char(dMAINDATE,'yyyy')||' г.';
            else
                sMAINDATE := '"__" ______________ 20__ г.';
            end if;

            APKG_XLSREP.ADD_CELL(sSTYLE => 'right_str', sCELLDATA => sMAINDATE, sCELLTYPE => 'String', nMERGEACROSS => 1);

            for rec in
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
                nVALUEROW := '        '|| rec.SJURNAME  ||' (далее – департамент, автономный округ), именуемый в дальнейшем «Учредитель», в лице '||
                nvl(rec.SJURSIGNPERSON, '______________________________________') || ', действующего на основании '||
                nvl(rec.SJURSIGNDOC, '__________________') || ', с одной стороны, и '|| rec.SORGNAME ||', именуемое в дальнейшем «Учреждение», в лице '||
                nvl(rec.SORGSIGNPERSPOSITION, '______________________________________') || ' ' ||
                nvl(rec.SORGSIGNPERSON, '______________________________________') ||', действующего на основании '||
                nvl(rec.SORGSIGNDOC, '__________________') || ', с другой стороны, вместе именуемые Сторонами, заключили настоящее Соглашение о нижеследующем.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (nVALUEROW, 90, 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                -- 1 Пункт
                nVALUEROW := '1. Предмет Соглашения';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
                nVALUEROW := '        1.1. Предметом настоящего Соглашения является определение порядка и условий предоставления Учредителем Учреждению из окружного бюджета субсидии на финансовое обеспечение выполнения Учреждением установленного Учредителем государственного задания на оказание государственных услуг (выполнение работ) (далее - субсидия, государственное задание).';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                -- 2 Пункт
                nVALUEROW := '2. Права и обязанности Сторон';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.1 Учредитель обязуется:';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.1.1 определять размер субсидии на основании нормативных затрат на оказание государственных услуг (выполнение работ) и содержание государственного имущества, рассчитываемых в соответствии с Порядком определения нормативных затрат на оказание государственных услуг (выполнение работ) государственных учреждений, находящихся в ведении Учредителя, утвержденным в установленном порядке;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.1.2 перечислять Учреждению субсидию в соответствии с графиком перечисления субсидии, являющимся неотъемлемой частью настоящего Соглашения, в порядке, размере и на условиях, установленных настоящим Соглашением;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.1.3. рассматривать предложения Учреждения по вопросам, связанным с исполнением настоящего Соглашения, и сообщать Учреждению о результатах их рассмотрения в срок не более 1 месяца со дня поступления указанных предложений;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.1.4. возвращать Учреждению первичные документы, представленные им для осуществления контроля за исполнением Учреждением государственного задания и использованием субсидии.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.2. Учредитель вправе:';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.2.1. принимать в пределах своей компетенции меры по обеспечению выполнения Учреждением государственного задания;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.2.2. осуществлять контроль за выполнением Учреждением государственного задания, целевым и эффективным использованием Учреждением предоставляемой в соответствии с настоящим Соглашением субсидии;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.2.3. изменять размер предоставляемой в соответствии с настоящим Соглашением субсидии в течение срока выполнения государственного задания в случае внесения соответствующих изменений в государственное задание;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.2.4. запрашивать у Учреждения необходимую информацию и первичные документы, необходимые для контроля за выполнением Учреждением государственного задания и расходованием средств субсидии;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.2.5. осуществлять проверку представляемой Учреждением отчетности о выполнении государственного задания и об использовании субсидии.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.3 Учреждение обязуется:';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);


                nVALUEROW := '        2.3.1. оказывать государственные услуги (выполнять работы) в соответствии с требованиями к составу, качеству и (или) объему (содержанию), условиям, порядку и результатам оказания государственных услуг (выполнению работ), определенными государственным заданием, правовыми актами Ямало-Ненецкого автономного округа, в том числе правовыми актами Учредителя;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.3.2. обеспечивать целевое и эффективное использование предоставленной субсидии в соответствии с настоящим Соглашением и установленным государственным заданием в рамках достижения целей, ради которых Учреждение создано;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.3.3. своевременно информировать Учредителя об изменении условий оказания государственных услуг (выполнения работ), которые могут повлиять на изменение размера Субсидии;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.3.4. возвратить Субсидию или ее часть в случае изменения размера Субсидии или в случаях установления факта невыполнения государственного задания или факта нецелевого использования средств Субсидии в порядке и сроки, установленные настоящим Соглашением;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.3.5. представлять Учредителю:';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        а) отчетность о выполнении государственного задания, а также информацию и (или) первичные документы, необходимые для контроля за выполнением Учреждением государственного задания и расходованием средств субсидии - в сроки и по форме, установленные государственным заданием;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        б) информацию и (или) первичные документы, необходимые для контроля за выполнением Учреждением государственного задания и расходованием средств субсидии - в течение 3 рабочих дней с даты получения мотивированного запроса Учредителя;';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        в) информацию о заключении договора о предоставлении в аренду государственного имущества - в течение 10 рабочих дней после заключения указанного договора.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        2.4. Учреждение вправе обращаться к Учредителю с предложением об изменении размера субсидии в связи с изменением в государственном задании показателей объема (содержания) оказываемых государственных услуг (выполняемых работ) и (или) показателей качества (в случае их установления).';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                -- 3 Пункт
                nVALUEROW := '3. Размер субсидии, порядок ее предоставления и возврата';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
                nVALUEROW := '        3.1. Учредитель по настоящему Соглашению в '||nNEXTPERIOD||' году предоставляет Учреждению субсидию в размере ' || LTRIM(to_char(nvl(nGZSUM,0),'999G999G999G999G999G990D00'),' ') || ' ( '||IntToStrPrim (TRUNC(nvl(nGZSUM,0)), 2) || ') рублей '|| substr (to_char(nvl(nGZSUM,0),'999G999G999G999G990D00'), -2,2) || ' копеек, в том числе на возмещение нормативных затрат на оказание государственных услуг (выполнение работ) ' || LTRIM(to_char(nvl(nGZSUM,0),'999G999G999G999G999G990D00'),' ') || ' ( '||IntToStrPrim (TRUNC(nvl(nGZSUM,0)), 2) || ') рублей '|| substr (to_char(nvl(nGZSUM,0),'999G999G999G999G990D00'), -2,2) || ' копеек на реализацию Учреждением мероприятий государственных программ';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := sGRBS_NOTES;
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        3.2. Субсидия перечисляется Учредителем в установленном порядке на лицевой  счет  Учреждения,  открытый в финансовом органе автономного округа.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        3.3. Субсидия перечисляется Учредителем Учреждению в сроки и размерах, установленных графиком ее перечисления согласно приложению к настоящему Соглашению.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        3.3.1. Перечисление Учредителем субсидии в декабре осуществляется не позднее 10 рабочих дней со дня представления Учреждением предварительного отчета об исполнении государственного задания за соответствующий финансовый год. Если на основании предусмотренного подпунктом 2.3.5 пункта 2.3 настоящего Соглашения отчета показатели объема, указанные в предварительном отчете, меньше показателей, установленных в государственном задании, то соответствующие средства субсидии подлежат перечислению в окружной бюджет в соответствии с бюджетным законодательством Российской Федерации.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        3.4. При уменьшении размера субсидии в случаях, установленных подпунктом 2.2.3 пункта 2.2 настоящего Соглашения, Учреждение обязано в течение 20 рабочих дней со дня изменения размера субсидии, но не позднее 25 декабря текущего года произвести частичный или полный возврат предоставленной субсидии.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        3.5. В случае если Учреждением по итогам финансового года не выполнено государственное задание по установленным им показателям (с учетом параметров возможных отклонений от установленных показателей, определённых государственным заданием), неиспользованные остатки средств субсидии, образовавшиеся в связи с невыполнением государственного задания, подлежат возврату в окружной бюджет. Не допускается расходование Учреждением в очередном финансовом году не использованных в текущем финансовом году остатков средств субсидии до утверждения Учредителем годового отчета о выполнении государственного задания.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        3.6. Учредитель в течение 10 календарных дней со дня установления фактов невыполнения государственного задания и (или) нецелевого использования средств субсидии направляет Учреждению письменное требование о возврате соответствующих средств субсидии. Требование о возврате средств субсидии должно быть исполнено Учреждением в течение 10 календарных дней со дня его получения.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                -- 4 Пункт
                nVALUEROW := '4. Ответственность Сторон';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                  nVALUEROW := '        4.1. В случае неисполнения или ненадлежащего исполнения обязательств, определенных настоящим Соглашением, Стороны несут ответственность в соответствии с законодательством Российской Федерации.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                -- 5 Пункт
                APKG_XLSREP.ADD_ROW(nPAGEBREAK => 1);
                nVALUEROW := '5. Срок действия Соглашения';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        5.1. Настоящее Соглашение вступает в силу с момента его подписания обеими Сторонами и действует до 31 декабря '||nNEXTPERIOD||' года, а в части представления Учреждением Учредителю отчетности, информации и первичных документов, а также возврата субсидии или ее части - до полного исполнения обязательств.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                -- 6 Пункт
                APKG_XLSREP.ADD_ROW(nPAGEBREAK => 1);
                nVALUEROW := '6. Заключительные положения';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        6.1. Изменение условий настоящего Соглашения осуществляется по взаимному согласию Сторон в письменной форме в виде дополнений к настоящему Соглашению, которые являются неотъемлемой его частью.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        6.2. В части отношений между Сторонами, не урегулированных положениями настоящего Соглашения, применяется законодательство Российской Федерации и законодательство автономного округа, а также Положение о формировании и финансовом обеспечении выполнения государственного задания, утвержденное постановлением Правительства автономного округа, правовые акты Учредителя, устав Учреждения.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        6.3. Споры между Сторонами решаются путем переговоров или в судебном порядке в соответствии с законодательством Российской Федерации.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                nVALUEROW := '        6.4. Настоящее Соглашение заключено Сторонами в форме электронного документа в информационной системе «Отраслевой информационный ресурс» (на базе ПО «Электронный сервис «РАМЗЭС 2.0») и подписано усиленными квалифицированными подписями лиц, имеющих право действовать от имени каждой из Сторон Соглашения.';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);


                -- 7 Пункт
                nVALUEROW := '7. Платежные реквизиты Сторон';
                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => nVALUEROW, ROWSTRLENGHT => 90, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'center_str', sCELLDATA => nVALUEROW, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Учредитель', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Учреждение', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => rec.SJURNAME, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => rec.SORGNAME, RowStrLenght => 45, RowStrHeight => 20)));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SJURNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Место нахождения:', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Место нахождения:', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => rec.SJURADDRESS, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => rec.SORGADDRESS, RowStrLenght => 45, RowStrHeight => 20)));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SJURADDRESS, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SORGADDRESS, sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Банковские реквизиты:', sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_left_str', sCELLDATA => 'Банковские реквизиты:', sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => 'ИНН' || rec.SORGINN, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SJURBANKREQ, sCELLTYPE => 'String', nMERGEACROSS => 1, nMERGEDOWN => 7);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'ИНН' || rec.SORGINN, sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => 'р/с ' || rec.SORGRACC, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'р/с ' || rec.SORGRACC, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => rec.SORGBANKREQ, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SORGBANKREQ, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => 'БИК ' || rec.SORGBIK, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'БИК ' || rec.SORGBIK, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => 'КПП ' ||rec.SORGKPP, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'КПП ' ||rec.SORGKPP, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);



                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => 'ОКТМО ' || rec.SORGOKTMO, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'ОКТМО ' || rec.SORGOKTMO, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => 'ОКПО ' || rec.SORGOKPO, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'ОКПО ' || rec.SORGOKPO, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

                APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => 'ОКВЭД ' || rec.SOKVED_MAIN, ROWSTRLENGHT => 45, ROWSTRHEIGHT => 20));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => 'ОКВЭД ' || rec.SOKVED_MAIN, sCELLTYPE => 'String', nMERGEACROSS => 1, nSKIPINDEX => 2);

                ---- Подпись
                APKG_XLSREP.ADD_ROW (nHEIGHT => 20);
                APKG_XLSREP.ADD_CELL(nMERGEACROSS => nCountCol-1);

                APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => rec.SJURPERSPOSITION, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => rec.SORGPERSPOSITION || ' ' ||rec.SORGSIGNORGNAME, RowStrLenght => 45, RowStrHeight => 20)));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SORGPERSPOSITION || ' ' ||rec.SORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 1);

                APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 45- length(rec.SJURDIRECTOR), '_') || rec.SJURDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 1);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 45- length(rec.SORGDIRECTOR), '_') || rec.SORGDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 1);

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

                /*------------------------------------------------------------------------------------------------------------------------------------------*/
                /*------------------------------------------ВТОРОЙ ЛИСТ-------------------------------------------------------------------------------------*/
                /*------------------------------------------------------------------------------------------------------------------------------------------*/
                nCOUNTCOL     := 8 + RGRAPH.COUNT;
                APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'landscape', sSHEETNAME => 'Приложение к соглашению', sPASSWORD => ZF_GET_REP_PASS);
                APKG_XLSREP.ADD_RUNTITLE(sFOOTERLEFT => sFOOTERLEFT,  sHEADERRIGTH => sHEADERRIGTH);
                APKG_XLSREP.OPEN_TABLE();

                APKG_XLSREP.ADD_COLUMN(nWIDTH => 80, nCOUNT => 2);
                APKG_XLSREP.ADD_COLUMN(nWIDTH => 100, nCOUNT => 2);
                APKG_XLSREP.ADD_COLUMN(nWIDTH => 80, nCOUNT => 2);
                APKG_XLSREP.ADD_COLUMN(nWIDTH => 150, nCOUNT => 2);
                APKG_XLSREP.ADD_COLUMN(nWIDTH => 120, nCOUNT => RGRAPH.COUNT);

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
                 select substr(KBK.SFKR,1,2) PART, substr(KBK.SFKR,3,2) SUBPART, KBK.SPARTICLE, KBK.SKVR, KBK.SCODE, KBK.SEVENT_CODE, KBK.STYPEBS_NUMB, E.RN EXPMAT, K.CODE KOSGUCODE, E.KOSGU DOPKOSGU, KBK.NKBK_RN KBK_RN
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
                    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => '241' || '.' || case when  QKBK.KOSGUCODE like '2%' then substr (QKBK.KOSGUCODE, 2,2)
                                                                                                          when  QKBK.KOSGUCODE like '3%' then substr (QKBK.KOSGUCODE, 1,2) end || '.' || QKBK.DOPKOSGU, sCELLTYPE => 'String');
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
                               and KBK.NKBK_RN   = QKBK.KBK_RN;
                               -- and KBK.SCODE ||'.'|| nvl(STYPEBS_NUMB,'-') = QKBK.SCODE ||'.'|| nvl(QKBK.STYPEBS_NUMB,'-');
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
                APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HEIGHTROW (StrVal => rec.SJURPERSPOSITION, RowStrLenght => 45, RowStrHeight => 20), ZF_HEIGHTROW (StrVal => rec.SORGPERSPOSITION || ' ' ||rec.SORGSIGNORGNAME, RowStrLenght => 45, RowStrHeight => 20)));
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SJURPERSPOSITION, sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'top_left_str', sCELLDATA => rec.SORGPERSPOSITION || ' ' ||rec.SORGSIGNORGNAME, sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 40- length(rec.SJURDIRECTOR), '_') || rec.SJURDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => lpad('/ ', 40- length(rec.SORGDIRECTOR), '_') || rec.SORGDIRECTOR, sCELLTYPE => 'String', nMERGEACROSS => 2);
                APKG_XLSREP.ADD_ROW (nHEIGHT => 50);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2, nSKIPINDEX => 8);
                APKG_XLSREP.ADD_CELL(sSTYLE => 'bottom_left_str', sCELLDATA => 'М.П.', sCELLTYPE => 'String', nMERGEACROSS => 2);
            end loop;

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

        if nvl(nRESULT,0) != 0 then
            begin -- page 11
                ZP_REP_VDK_LOG (pJURPERS      => pJURPERS,
                                 pVERSION     => pVERSION,
                                 pORGRN       => pORGRN,
                                 pPFHDVERS    => pREDACTION,
                                 pPROCNAME    => 'ZP_REP_SOGLGZ2020_MZYN',
                                 pUSER        => null);
            end;
        end if;
        end;

        APKG_XLSREP.CLOSE_REPORT();
        pFile := APKG_XLSREP.GET_BLOB;
    exception when others then
      --APKG_XLSREP.CLOSE_REPORT();
      APKG_XLSREP.FREE_BLOB;
      raise;
    end;
end;


​
