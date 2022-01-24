create or replace procedure ZP_REP_SMETA_SPORT
(
  pFILE            out BLOB,
  pJURPERS     number,
  pVERSION     number,
  pEVENT_RN    number,
  pCALENDAR    number default null
)
as
  nValueRow        varchar2(4000);
  bPrint           boolean := false;
  nCOUNTCOL        pls_integer:= 22;
  sTITLE           varchar2(2000);

  vNAME            varchar2(2000);
  vCODE            varchar2(2000);
  vDIRECTOR        varchar2(2000);
  dSTART_DATE      DATE;
  dFINISH_DATE     DATE;

  nNORM_RN         number;

  -- количество человек
  nSUM_MEM         number := 0;
  nSUM_TRA         number := 0;

  -- План
  -- количество дней проживания
  nDAYS_MEM        number := 0;
  nDAYS_TRA        number := 0;

  nSUM_MEM         number := 0;
  nSUM_TRA         number := 0;

  -- количество дней питания
  nFDAYS_MEM       number := 0;
  nFDAYS_TRA       number := 0;

  nfSUM_MEM        number := 0;
  nfSUM_TRA        number := 0;

  -- Факт
  -- количество дней проживания
  nDAYS_MEM_F      number := 0;
  nDAYS_TRA_F      number := 0;

  nSUM_MEM_F       number := 0;
  nSUM_TRA_F       number := 0;

  -- количество дней питания
  nFDAYS_MEM_F     number := 0;
  nFDAYS_TRA_F     number := 0;

  nfSUM_MEM_F      number := 0;
  nfSUM_TRA_F      number := 0;


  nSUM_B           number;
  nSUM_VB          number;
  sERR             CLOB;
  nERR             number := 0;

  nMARKM           varchar2(100);
  nMARKT           varchar2(100);

  type t_tab1 is record(
    MEM_RN      number,
    SPORT_RN    number,
    MEMBER_TYPE number,
    COST        number,
    DAYS        number,
    COST_FACT   number,
    DAYS_FACT   number,
    SUMMA       number,
    SUMMA_FACT  number,
    EXPTYPE_RN  number,
    SCODE       VARCHAR2(500),
    SNAME       VARCHAR2(500),
    ORDERNUMB   number
    );
  type t_tab_arr1 is table of t_tab1 index BY PLS_INTEGER;
  EXPMET t_tab_arr1;

begin
    begin
        -- Инициализация
        begin
            select S.NAME, S.START_DATE, S.FINISH_DATE, D.CODE, J.DIRECTOR, S.NORM_RN
                into vNAME, dSTART_DATE, dFINISH_DATE, vCODE, vDIRECTOR, nNORM_RN
            from Z_SPORT S, Z_DISTRICT D, Z_JURPERS J
            where S.rn = pEVENT_RN
                and J.RN = pJURPERS
                and S.JURPERS = J.RN
                and D.RN = S.TOWN_RN;
        exception when others then
            vNAME        := null;
            dSTART_DATE  := null;
            dFINISH_DATE := null;
            vCODE        := null;
            vDIRECTOR    := null;
            nNORM_RN     := null;
        end;

        select SE.RN MEM_RN,
                SE.SPORT_EVENT_RN SPORT_RN,
                SE.MEMBER_TYPE MEMBER_TYPE,
                nvl(SUM(O.COST), 0),
                nvl(SUM(O.DAYS), 0),
                nvl(SUM(O.COST_FACT), 0),
                nvl(SUM(O.DAYS_FACT), 0),
                nvl(SUM(O.SUMMA), 0),
                nvl(SUM(O.SUMMA_FACT), 0),
                O.EXPTYPE_RN,
                F.CODE sCODE,
                F.NAME sNAME,
                F.ORDERNUMB
                -- ZP_SPORT_GETNORM(SE.VERSION, SE.RN, N.EXPTYPE_RN)
        BULK COLLECT INTO EXPMET
        from Z_SPORT_EXP SE,
            Z_SPORT_EXP_D O,
            Z_SPORT_EXPTYPES F
        where SE.SPORT_EVENT_RN = 359884669
            and O.EXP_RN   = SE.RN
            and O.EXPTYPE_RN = F.RN
        group by SE.RN, F.CODE, F.NAME, F.ORDERNUMB, O.EXPTYPE_RN, SE.MEMBER_TYPE, SE.SPORT_EVENT_RN
        order by F.ORDERNUMB;


/*
            select S.NAME, S.START_DATE, S.FINISH_DATE, D.CODE, J.DIRECTOR, S.NORM_RN
                into vNAME, dSTART_DATE, dFINISH_DATE, vCODE, vDIRECTOR, nNORM_RN
            from Z_SPORT S, Z_DISTRICT D, Z_JURPERS J
            where S.rn = pEVENT_RN
                and J.RN = pJURPERS
                and S.JURPERS = J.RN
                and D.RN = S.TOWN_RN;

            for rtc in(
                select SE.RN MEM_RN, SE.SPORT_EVENT_RN SPORT_RN, SE.MEMBER_TYPE MEMBER_TYPE,
                    O.COST, O.DAYS, O.COST_FACT, O.DAYS_FACT, O.SUMMA, O.SUMMA_FACT, SE.VERSION, O.EXPTYPE_RN,
                    F.CODE sCODE, F.NAME sNAME
                from Z_SPORT_EXP SE,
                    Z_SPORT_EXP_D O,
                    Z_SPORT_EXPTYPES F
                where SE.SPORT_EVENT_RN = 359884669
                    and O.EXP_RN   = SE.RN
                    and O.EXPTYPE_RN = F.RN
                order by F.ORDERNUMB
            )
            loop
                if rec.MEMBER_TYPE = 1 then
                    nCON_MEM := nCON_MEM + 1;
                elsif MEMBER_TYPE = 2 then
                    nCON_TRA := nCON_TRA + 1;
                end if;

                -- Питание
                if rec.sCODE = '02' then
                    if rec.MEMBER_TYPE = 1 then
                        nDAYS_MEM := nDAYS_MEM + rec.DAYS;
                        nSUM_MEM  := nSUM_MEM  + rec.DAYS * rec.COST;

                        nDAYS_MEM_F := nDAYS_MEM_F + rec.DAYS_FACT;
                        nSUM_MEM_F  := nSUM_MEM_F  + rec.DAYS_FACT * rec.COST_FACT;

                    elsif rec.MEMBER_TYPE = 2 then
                        nSUM_TRA  := nSUM_TRA  + rec.DAYS * rec.COST;
                        nDAYS_TRA := nDAYS_TRA + rec.DAYS;

                        nDAYS_TRA_F := nDAYS_TRA_F + rec.DAYS_FACT;
                        nSUM_TRA_F  := nSUM_TRA_F  + rec.DAYS_FACT * rec.COST_FACT;

                -- Цена за проживание в сутки
                elsif rec.sCODe = '03' then
                    if rec.MEMBER_TYPE = 1 then
                        nFDAYS_MEM := nFDAYS_MEM + rec.DAYS;
                        nfSUM_MEM  := nfSUM_MEM  + rec.DAYS * rec.COST;

                        nFDAYS_MEM_F := nFDAYS_MEM_F + rec.DAYS_FACT;
                        nfSUM_MEM_F  := nfSUM_MEM_F  + rec.DAYS_FACT * rec.COST_FACT;
                    elsif rec.MEMBER_TYPE = 2 then
                        nFDAYS_TRA := nFDAYS_TRA + rec.DAYS;
                        nfSUM_TRA  := nfSUM_TRA  + rec.DAYS * rec.COST;

                        nFDAYS_TRA_F := nFDAYS_TRA_F + rec.DAYS_FACT;
                        nfSUM_TRA_F  := nfSUM_TRA_F  + rec.DAYS_FACT * rec.COST_FACT;
                -- Стоимость проезда
            elsif rec.sCODE = '01' then
                    if rec.MEMBER_TYPE = 1 then

                    elsif rec.MEMBER_TYPE = 2 then
                else

                then

            end loop;
*/
            for rec in (
                select MEMBER_TYPE
                from Z_SPORT_EXP
                where sport_event_rn = pEVENT_RN
                group by MEMBER_TYPE
            )
            loop
                if rec.MEMBER_TYPE = 1 then
                    nSUM_MEM   := rec.SUMMA;
                    -- nDAYS_MEM  := rec.DAYS;
                    -- nFDAYS_MEM := rec.F_DAYS;
                elsif rec.MEMBER_TYPE = 2 then
                    SUM_TRA := rec.SUMMA;
                    -- nDAYS_TRA := rec.DAYS;
                    -- nFDAYS_TRA := rec.F_DAYS;
                end if;
            end loop;

        end;
        APKG_XLSREP.OPEN_REPORT(nTYPE => 1);
        -- style
        -------------------------------------------------------
        begin
            APKG_XLSREP.ADD_STYLE(sSTYLE => 'title',
            sHALIGNMENT         => 'Center',
            nFONTSIZE           => 8,
            nFONTBOLD           => 1,
            nWRAPTEXT           => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'border_title',
            nWRAPTEXT           => 1,
            nBORDERLEFTWEIGHT   => 1,
            nFONTSIZE           => 8,
            nFONTBOLD           => 1,
            sHALIGNMENT         => 'Center');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'text_left',
            sHALIGNMENT         => 'left',
            nFONTSIZE           => 8,
            nWRAPTEXT           => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'text_center',
            sHALIGNMENT         => 'center',
            nFONTSIZE           => 8,
            nWRAPTEXT           => 1);

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'border_center_str',
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            nBORDERRIGHTWEIGHT  => 1,
            sHALIGNMENT         => 'Center');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'top_border_right_number',
            nWRAPTEXT           => 1,
            nBORDERTOPWEIGHT    => 1,
            nBORDERBOTTOMWEIGHT => 1,
            nBORDERLEFTWEIGHT   => 1,
            sHALIGNMENT         => 'right');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'down_border_left_number',
            nWRAPTEXT           => 1,
            nBORDERBOTTOMWEIGHT    => 1,
            sHALIGNMENT         => 'left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'down_border_left_text',
            nWRAPTEXT           => 1,
            nBORDERBOTTOMWEIGHT => 1,
            sHALIGNMENT         => 'left');

            APKG_XLSREP.ADD_STYLE(sSTYLE => 'left_border_left_text',
            nWRAPTEXT           => 1,
            nBORDERLEFTWEIGHT   => 1,
            sHALIGNMENT         => 'left');

        end;
        -------------------------------------------------------

        begin -- Body
            APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sORIENTATION => 'Portrait', sPASSWORD => ZF_GET_REP_PASS, sSHEETNAME => 'Отчет');

            APKG_XLSREP.OPEN_TABLE();
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 120);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 50);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 30, nCOUNT => 7);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 90);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 30);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 40, nCOUNT => 2);
            APKG_XLSREP.ADD_COLUMN(nWIDTH => 60);


            -- Блок утверждаю
            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => '"Утверждаю"', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Смету в сумме', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'down_border_left_number', sCELLDATA => '0.00', sCELLTYPE => 'String', nMERGEACROSS => 3); -- вставить сумму
            APKG_XLSREP.ADD_CELL(nSKIPINDEX => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Министр спорта РК', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => '_______________ '||vDIRECTOR||'', sCELLTYPE => 'String', nMERGEACROSS => 3); -- вставить министра спорта и место под подпись

            -- Заголовок Смета
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(nSKIPINDEX => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'title', sCELLDATA => 'СМЕТА №', sCELLTYPE => 'String', nMERGEACROSS => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'down_border_left_text', sCELLDATA => ' ', sCELLTYPE => 'String', nMERGEACROSS => 2); -- c редакции

            -- Блок данные
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Расходов на', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'down_border_left_text', sCELLDATA => vNAME, sCELLTYPE => 'String', nMERGEACROSS => 12); -- название мероприятия
            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => '', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'down_border_left_text', sCELLDATA => ' ', sCELLTYPE => 'String', nMERGEACROSS => 12);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Место проведения', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'down_border_left_text', sCELLDATA => vCODE, sCELLTYPE => 'String', nMERGEACROSS => 12); -- место проведения

            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'Время проведения (считая день приезда и отъезда)', sCELLTYPE => 'String', nMERGEACROSS => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => 'с', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => dSTART_DATE, sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => 'по', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => dFINISH_DATE, sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => '2021 г.', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',             sCELLDATA => 'Количество участников', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'down_border_left_text', sCELLDATA => nSUM_MEM, sCELLTYPE => 'Number', nMERGEACROSS => 3); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center',           sCELLDATA => ' ', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center',           sCELLDATA => 'в т.ч. сотрудников', sCELLTYPE => 'String', nMERGEACROSS => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center',           sCELLDATA => ' ', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',             sCELLDATA => 'чел.', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'Количество судей (тренеров, специалистов)', sCELLTYPE => 'String', nMERGEACROSS => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nSUM_TRA, sCELLTYPE => 'Number', nMERGEACROSS => 1); -- количество судей
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => 'в т.ч. иногородних', sCELLTYPE => 'String', nMERGEACROSS => 3);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => ' ', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'чел.', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Ответственный (подотчетное лицо)', sCELLTYPE => 'String', nMERGEACROSS => 2);

            -- Шапка таблицы 1
            APKG_XLSREP.ADD_ROW(nHEIGHT => 10);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование статей расходов (№ раздела)', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Сумма в рублях', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Факт. '||chr(10)||' расход', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Примечание', sCELLTYPE => 'String', nMERGEACROSS => 1);

            -- Пункт 1
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nSKIPINDEX => 6, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_title', sCELLDATA => '1.Питание (раздел ___ Норм расходов)', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            nMARKM := null;
            nMARKT := null;

            for FOOD in EXPMET.FIRST..EXPMET.COUNT
            loop
                if EXPMET(FOOD).SCODE = '03' or '01'
                    if EXPMET(FOOD).MEMBER_TYPE = 1 then
                        if nMARKM is null then
                            nMARKM := EXPMET(FOOD).SCODE;
                            nFDAYS_MEM := nFDAYS_MEM + EXPMET(FOOD).DAYS;
                        elsif nMARKM != EXPMET(FOOD).SCODE then
                            nMARKM := '0';
                        else
                            nFDAYS_MEM := nFDAYS_MEM + EXPMET(FOOD).DAYS;
                        end if;
                    else
                        if nMARKT is null then
                            nMARKT := EXPMET(FOOD).SCODE;
                            nFDAYS_TRA := nFDAYS_TRA + EXPMET(FOOD).DAYS;
                        elsif nMARKT != EXPMET(FOOD).SCODE then
                            nMARKT := '0';
                        else
                            nFDAYS_TRA := nFDAYS_TRA + EXPMET(FOOD).DAYS;
                        end if;
                    end if;
                elsif EXPMET(FOOD).SCODE = '02' or '04' then
                        if EXPMET(FOOD).MEMBER_TYPE = 1 then
                            if nMARKM is null then
                                nMARKM := EXPMET(FOOD).SCODE;
                                nDAYS_MEM := nDAYS_MEM + EXPMET(FOOD).DAYS;
                            elsif nMARKM != EXPMET(FOOD).SCODE then
                                nMARKM := '0';
                            else
                                nDAYS_MEM := nDAYS_MEM + EXPMET(FOOD).DAYS;
                            end if;
                        else
                            if nMARKT is null then
                                nMARKT := EXPMET(FOOD).SCODE;
                                nDAYS_TRA := nDAYS_TRA + EXPMET(FOOD).DAYS;
                            elsif nMARKT != EXPMET(FOOD).SCODE then
                                nMARKT := '0';
                            else
                                nDAYS_TRA := nDAYS_TRA + EXPMET(FOOD).DAYS;
                            end if;
                        end if;
                elsif EXPMET(FOOD).SCODE = '124' then
                        if EXPMET(FOOD).MEMBER_TYPE = 1 then
                            if nMARKM is null then
                                nMARKM := EXPMET(FOOD).SCODE;
                                nDAYS_MEM := nDAYS_MEM + EXPMET(FOOD).DAYS;
                            elsif nMARKM != EXPMET(FOOD).SCODE then
                                nMARKM := '0';
                            else
                                nDAYS_MEM := nDAYS_MEM + EXPMET(FOOD).DAYS;
                            end if;
                        else
                            if nMARKT is null then
                                nMARKT := EXPMET(FOOD).SCODE;
                                nDAYS_TRA := nDAYS_TRA + EXPMET(FOOD).DAYS;
                            elsif nMARKT != EXPMET(FOOD).SCODE then
                                nMARKT := '0';
                            else
                                nDAYS_TRA := nDAYS_TRA + EXPMET(FOOD).DAYS;
                            end if;
                        end if;
                end if;
            end loop;

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text', sCELLDATA => 'Участники', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nSUM_MEM,   sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'чел.',     sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nFDAYS_MEM, sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'дн.',      sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => ' ',        sCELLTYPE => 'String'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'руб.',     sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => nfSUM_MEM, sCELLTYPE => 'Number', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => nfSUM_MEM_F, sCELLTYPE => 'Number', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text', sCELLDATA => 'Тренеры (специалисты)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nSUM_TRA,   sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'чел.',     sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nFDAYS_TRA, sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'дн.',      sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => ' ',        sCELLTYPE => 'String'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'руб.',     sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nSKIPINDEX => 6, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_border_right_number', sCELLDATA => 'Итого по ст.1', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nSKIPINDEX => 6, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            -- Пункт 2
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_title', sCELLDATA => '2. Проживание (раздел ____ Норм расходов)', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text', sCELLDATA => 'Участников', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nSUM_MEM,  sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'чел.',    sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nDAYS_MEM, sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'сут.',    sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => ' ',       sCELLTYPE => 'String'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'руб.',    sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text', sCELLDATA => 'Тренеров (специалистов)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nSUM_TRA,  sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'чел.',    sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nDAYS_TRA, sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'сут.',    sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => ' ',       sCELLTYPE => 'String'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'руб.',    sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nSKIPINDEX => 6, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_border_right_number', sCELLDATA => 'Итого по ст.2', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nSKIPINDEX => 6, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            -- Пункт 3
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_title', sCELLDATA => '3. Проезд (раздел ___ Норм расходов)', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text', sCELLDATA => 'Проезд участников', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nSUM_MEM, sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'чел.',   sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'х',      sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => ' ',      sCELLTYPE => 'String', nMERGEACROSS => 1); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'руб.',   sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text', sCELLDATA => 'Проезд тренеров'||chr(10)||'(специалистов)', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => nSUM_TRA, sCELLTYPE => 'Number'); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'чел.',   sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'х',      sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_center', sCELLDATA => ' ',      sCELLTYPE => 'String', nMERGEACROSS => 1); -- количество участников
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left',   sCELLDATA => 'руб.',   sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nSKIPINDEX => 6, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_border_right_number', sCELLDATA => 'Итого по ст.3', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            -- Шапка таблицы 2
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Наименование статей расходов', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Сумма в рублях', sCELLTYPE => 'String', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Факт. '||chr(10)||' расход', sCELLTYPE => 'String', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => 'Примечание', sCELLTYPE => 'String', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'left_border_left_text');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nSKIPINDEX => 6, nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            -- Пункт 4
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_title', sCELLDATA => '4. Услуги по предоставлению объектов спорта (раздел 10'||chr(10)||'Норма расходов)', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            -- Раздел с услугами

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_border_right_number', sCELLDATA => 'Итого по ст.4', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            -- Пункт 5
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_title', sCELLDATA => '5. Прочие расходы', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'top_border_right_number', sCELLDATA => 'Итого по ст.5', sCELLTYPE => 'String', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            -- Итог таблицы
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', nMERGEACROSS => 6);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 2);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', nMERGEACROSS => 1);

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Всего по смете руб.', sCELLTYPE => 'String');

            APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Смету проверил:', sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'text_left', sCELLDATA => 'Генеральный директор'||chr(10)||'ГБУ РК "ЦСП СК РК":', sCELLTYPE => 'String', nMERGEACROSS => 5);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'down_border_left_text', sCELLDATA => ' ', sCELLTYPE => 'String', nMERGEACROSS => 5, nSKIPINDEX => 1); -- c редакции

            APKG_XLSREP.FLUSH_ROWCELLS();
            APKG_XLSREP.CLOSE_TABLE_AND_SHEET;

        end;


        APKG_XLSREP.CLOSE_REPORT();
        pFile := APKG_XLSREP.GET_BLOB;
    exception when others then
        --APKG_XLSREP.CLOSE_REPORT();
        APKG_XLSREP.FREE_BLOB;
        raise;
    end;

    -- if not bPRINT then
    --     zp_exception(0,'Формирование пустого отчёта невозможно!');
    -- end if;
end;
​
