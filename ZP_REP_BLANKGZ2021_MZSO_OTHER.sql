create or replace procedure ZP_REP_BLANKGZ2021_MZSO_OTHER
(
  pREDACTION   number,
  --
  sFOOTERLEFT  varchar,
  sHEADERRIGTH varchar
)
as
  pJURPERS     number;
  pVERSION     number;
  pORGRN       number;
  --
  nCOUNTCOL    number := 14;
  nCURITEM     pls_integer;
  nPrint       pls_integer := 0;
begin
    -- initializations globals
    -------------------------------------------------------
    begin
        select JUR_PERS, VERSION, ORGRN
          into pJURPERS, pVERSION, pORGRN
          from Z_REP_REESTR
         where RN = pREDACTION;
    exception when OTHERS then
        ZP_EXCEPTION (0, 'Ошибка. Редакция электронного документа не найдена.');
        pJURPERS  := null;
        pVERSION  := null;
        pORGRN    := null;
    end;
    -------------------------------------------------------

    nCountCol := 14;
    APKG_XLSREP.OPEN_SHEET(nPROTECTED => 1, sSHEETNAME => 'Прочие', sORIENTATION => 'Landscape', SPASSWORD => ZF_GET_REP_PASS);
    APKG_XLSREP.OPEN_TABLE();
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 300);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 150);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 150);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 90, nCOUNT => 11);

    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b', nMERGEACROSS => nCountCol-1, sCELLDATA => 'Часть 3. Прочие сведения о государственном задании', sCELLTYPE => 'String');

    APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '1. Основания для досрочного прекращения выполнения государственного задания', sCELLTYPE => 'String');

    nCURITEM := 1;
    for rec in
    (
     select REASON
       from Z_REASONCANCEL
      where version = pVersion
        and JUR_PERS = pJurPers
      order by ORDERNUMB
    )
    loop
        APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HeightRow (StrVal => rec.REASON, RowStrLenght => 130, RowStrHeight => 15)));
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8', sCELLDATA => nCURITEM, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8', nMERGEACROSS => nCountCol-2, sCELLDATA => rec.REASON, sCELLTYPE => 'String');
        nPrint := 1;
        nCURITEM := nvl(nCURITEM,0) + 1;
    end loop;

    if nPrint = 0 then
        APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8', sCELLDATA => null, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8', nMERGEACROSS => nCountCol-2, sCELLDATA => null, sCELLTYPE => 'String');
    end if;

    nPrint := 0;
    APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '2. Иная информация, необходимая для выполнения (контроля за выполнением) государственного задания', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => 'Не предусмотрено', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

    APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);

    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '3. Порядок контроля за выполнением государственного задания', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_ROW(nHEIGHT => 45);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8',  sCELLDATA => 'Форма контроля', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8',  nMERGEACROSS => 5,  sCELLDATA => 'Периодичность', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8',  nMERGEACROSS => 6,  sCELLDATA => 'Органы исполнительной власти, осуществляющие контроль за выполнением государственного задания', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8',  sCELLDATA => '1', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8',  nMERGEACROSS => 5,  sCELLDATA => '2', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8',  nMERGEACROSS => 6,  sCELLDATA => '3', sCELLTYPE => 'String');

    for rec in
    (
      select N.NAME, N.PERIOD, N.RESPON
       from Z_SERVORDCONTROL S, Z_ORDERCONTROL N, Z_SERVLINKS SL
      where S.ORDCTRL_RN = N.RN(+)
        and S.PRN        = SL.SERVRN
        and SL.ORGRN     = pORGRN
      group by N.ORDERNUM, N.NAME, N.PERIOD, N.RESPON
      order by lpad(N.ORDERNUM,10,' ')
    )
    loop
        APKG_XLSREP.ADD_ROW(nHEIGHT => greatest(ZF_HeightRow (StrVal => rec.NAME, RowStrLenght => 35, RowStrHeight => 15),ZF_HeightRow (StrVal => rec.PERIOD, RowStrLenght => 35, RowStrHeight => 15)));
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8', sCELLDATA => rec.name, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8', nMERGEACROSS => 5, sCELLDATA => rec.PERIOD, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8', nMERGEACROSS => 6, sCELLDATA => rec.RESPON, sCELLTYPE => 'String');
        nPrint := 1;
    end loop;

    if nPrint = 0 then
        APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str8', sCELLDATA => null, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8', nMERGEACROSS => 5, sCELLDATA => null, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8', nMERGEACROSS => 6, sCELLDATA => null, sCELLTYPE => 'String');
    end if;

    nPrint := 0;
    APKG_XLSREP.ADD_ROW(nHEIGHT => 15);
    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '4. Требования к отчетности о выполнении государсвтенного задания', sCELLTYPE => 'String');

    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => 'отчетность формируется в соответствии с формой № 2, утвержденной постановлением Правительства Сахалинской области от 11.09.2014 № 444, в государственной автоматизированной системе управления бюджетным процессом Сахалинской области', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);

    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '4.1. Периодичность представления отчетов о выполнении государственного задания', sCELLTYPE => 'String');

    for rec in
    (
     select TO_CHAR(N.ACTNAME_CLOB) ACTNAME_CLOB
       from Z_SERVNPA SN, Z_NPA N, Z_SERVLINKS SL
      where N.VERSION = pVERSION
        and N.PART = '4.1'
        and SN.NPA_RN = N.RN
        and SN.PRN    = SL.SERVRN
        and SL.ORGRN  = pORGRN
      group by TO_CHAR(N.ACTNAME_CLOB), N.ORDERNUM
      order by N.ORDERNUM
    )
    loop
        APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => rec.ACTNAME_CLOB, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
        nPrint := 1;
    end loop;

    if nPrint = 0 then
        APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => 'Не предусмотрено', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
    end if;

    nPrint := 0;
    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '4.2. Сроки представления отчетов о выполнении государсвтенного задания', sCELLTYPE => 'String');

    for rec in
    (
     select TO_CHAR(N.ACTNAME_CLOB) ACTNAME_CLOB
       from Z_SERVNPA SN, Z_NPA N, Z_SERVLINKS SL
      where N.VERSION = pVERSION
        and N.PART = '4.2'
        and SN.NPA_RN = N.RN
        and SN.PRN    = SL.SERVRN
        and SL.ORGRN  = pORGRN
      group by TO_CHAR(N.ACTNAME_CLOB), N.ORDERNUM
      order by N.ORDERNUM
    )
    loop
        APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => rec.ACTNAME_CLOB, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
        nPrint := 1;
    end loop;

    if nPrint = 0 then
        APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => 'Не предусмотрено', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
    end if;

    nPrint := 0;
    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '4.2.1 Сроки представления предварительного отчета о выполнении государсвтенного задания', sCELLTYPE => 'String');

    for rec in
    (
     select TO_CHAR(N.ACTNAME_CLOB) ACTNAME_CLOB
       from Z_SERVNPA SN, Z_NPA N, Z_SERVLINKS SL
      where N.VERSION = pVERSION
        and N.PART = '4.2.1'
        and SN.NPA_RN = N.RN
        and SN.PRN    = SL.SERVRN
        and SL.ORGRN  = pORGRN
      group by TO_CHAR(N.ACTNAME_CLOB), N.ORDERNUM
      order by N.ORDERNUM
    )
    loop
        APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => rec.ACTNAME_CLOB, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
        nPrint := 1;
    end loop;

    if nPrint = 0 then
        APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => 'Не предусмотрено', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
    end if;

    nPrint := 0;

    -- убрано 01.12.2021 по запросу аналитиков _ parkhaev
    /*
    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => null, sCELLTYPE => 'String');

    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => 'отчетность направляется в министерство здравоохранения Сахалинской области на бумажном носителе с обязательным представлением пояснительной записки при невыполнении и (или) перевыполнении показателей качества и объёма оказания государственной услуги (работы) ', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
    */
    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'left_str8b',  nMERGEACROSS => nCountCol-1, sCELLDATA => '5. Иные показатели, связанные с выполнением государственного задания', sCELLTYPE => 'String');

    nPrint := 0;
    for rec in
    (
     select TO_CHAR(N.ACTNAME_CLOB) ACTNAME_CLOB
       from Z_ORGNPA ONPA, Z_NPA N
      where N.VERSION = pVERSION
        and N.PART = '5.'
        and ONPA.NPA_RN = N.RN
        and ONPA.ORGRN  = pORGRN
      order by N.ORDERNUM
    )
    loop
        APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => rec.ACTNAME_CLOB, sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
        nPrint := 1;
    end loop;

    if nPrint = 0 then
        APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str8',  sCELLDATA => 'Отсутствует', sCELLTYPE => 'String', nMERGEACROSS => nCOUNTCOL-1);
    end if;
    -----------------------------
    APKG_XLSREP.FLUSH_ROWCELLS();
    APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
end;​
