create or replace procedure ZP_REP_EXPMAT_SERV_N_BODY
(
  pFILE        out BLOB,
  --
  pJURPERS     number,
  pVERSION     number,
  pORGRN       number,
  --
  pVNEBUDGSIGN number,
  pORGTYPE     number,
  pORGGR       number,
  pORGMARK     number
)
as
  bPrint       boolean := false;
  nCountCol    pls_integer:= 11;
  sTITLE       varchar2(2000);
  nCount       pls_integer;
  nQindVal     number(19,3);
  nNextIndex   Z_VERSIONS.NEXT_INDX%type;
  nPSUM        number(19,2);
  nItemCol     pls_integer;
  --
  nPSUM211     number(19,2);
  --
  nPSUM213     number(19,2);
  --
  nSkipCount pls_integer:=0;
  nSkipCount2 pls_integer:=0;
  nSkipCountALL pls_integer:=0;

  nLIMIT_SUM   number;

  type CEXPGR is record
  (
    RN           number,
    CODE         varchar2(500),
    EXPKIND      number,
    EXPKIND_CODE varchar2(500)
  );

  type TEXPGR  is table of CEXPGR index by pls_integer;
  REXPGR       TEXPGR;
begin
  begin
    APKG_XLSREP.OPEN_REPORT(nTYPE => 1);
    ----------------------------------------------Начало стилей--------------------------------
    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'title',
                          sHALIGNMENT         => 'Center',
                          nFONTSIZE           => 12,
                          nFONTBOLD           => 1,
                          nWRAPTEXT           => 1);
    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'table_head',
                          sHALIGNMENT         => 'Center',
                          nBORDERTOPWEIGHT    => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          nWRAPTEXT           => 1,
                          sBACKCOLOR          => '#cfdef0',
                          sFONTCOLOR          => '#1d1d1d',
                          sPATTERN            => 'Solid');

    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'border_center_str',
                          nWRAPTEXT           => 1,
                          nBORDERTOPWEIGHT    => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          sHALIGNMENT         => 'Center',
                          sVALIGNMENT         => 'Top');
    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'border_left_str',
                          nWRAPTEXT           => 1,
                          nBORDERTOPWEIGHT    => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          sHALIGNMENT         => 'Left',
                          sVALIGNMENT         => 'Top');
    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'border_right_num',
                          sHALIGNMENT         => 'Right',
                          nWRAPTEXT           => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          sNUMBERFORMAT       => 'Standard',
                          sINDENT             => 1);
    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'totals_str',
                          sHALIGNMENT         => 'Right',
                          nWRAPTEXT           => 1,
                          nBORDERTOPWEIGHT    => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          sBACKCOLOR          => '#FFF2CC',
                          sPATTERN            => 'Solid',
                          sNUMBERFORMAT       => 'Standard',
                          sINDENT             => 1);

    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'totals_num',
                          sHALIGNMENT         => 'Right',
                          nWRAPTEXT           => 1,
                          nBORDERTOPWEIGHT    => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          sBACKCOLOR          => '#FFF2CC',
                          sPATTERN            => 'Solid',
                          sNUMBERFORMAT       => 'Standard',
                          sINDENT             => 1);
    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'gen_totals_str',
                          sHALIGNMENT         => 'Right',
                          nWRAPTEXT           => 1,
                          nBORDERTOPWEIGHT    => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          nFONTBOLD           => 1,
                          sBACKCOLOR          => '#E2EFDA',
                          sPATTERN            => 'Solid');

    APKG_XLSREP.ADD_STYLE(sSTYLE              => 'gen_totals_num',
                          sHALIGNMENT         => 'Right',
                          nWRAPTEXT           => 1,
                          nBORDERTOPWEIGHT    => 1,
                          nBORDERBOTTOMWEIGHT => 1,
                          nBORDERLEFTWEIGHT   => 1,
                          nBORDERRIGHTWEIGHT  => 1,
                          nFONTBOLD           => 1,
                          sBACKCOLOR          => '#E2EFDA',
                          sPATTERN            => 'Solid',
                          sNUMBERFORMAT       => 'Standard',
                          sINDENT             => 1);
    ----------------------------------------------Конец стилей--------------------------------

    sTITLE := 'Расчет базового норматива';

    APKG_XLSREP.OPEN_SHEET(nHSTATICCELLS => 5, /*nVSTATICCELLS => 6,*/ nPROTECTED => 0);
    APKG_XLSREP.ADD_NAMED_RANGE(sRANGE => 'R2:R4');
    APKG_XLSREP.OPEN_TABLE();
    for rec in
    (
     select E.NEXPGROUP, E.SEXPGROUP_NAME, E.NEXPKIND, E.SEXPKIND
       from ZV_EXPMAT E
      where E.NJURPERS = pJURPERS
        and E.NVERSION = pVERSION
        /*and EXISTS (select null
                      from ZV_EXPALL EA, ZV_SERVLINKS SL, ZV_SERVREG SR
                     where EA.NEXPMAT = E.NEXPMAT
                       and EA.NORGRN = SL.NORGRN
                       and EA.NSERVRN = SL.NSERVRN
                       and SL.NSERVRN = SR.NSERVRN
                       and EA.NSERVSUM > 0
                       and ((pORGRN is null) or (SL.NORGRN = pORGRN))
                       and ((pORGGR is null) or (SL.NORGROUP = pORGGR))
                       and ((pORGTYPE is null) or (SL.NORGTYPE = pORGTYPE))
                       and ((pORGMARK is null) or (SL.NORGMARK = pORGMARK))
                       and SL.NORGTYPE in (0,1)
                       and SL.NWORKSERV in (1,3)
                       and NPARENT_SIGN is null)*/
        and E.NEXPTYPE <> 5
        and NEXPGROUP is not null
      group by E.NEXPGROUP_NUMB, E.NEXPGROUP, E.SEXPGROUP_NAME, E.NEXPKIND, E.SEXPKIND
      order by E.NEXPKIND, E.NEXPGROUP_NUMB, E.SEXPGROUP_NAME
    )
    loop
        nItemCol := nvl(nItemCol,0) + 1;
        REXPGR(nItemCol).RN := rec.NEXPGROUP;
        REXPGR(nItemCol).CODE := rec.SEXPGROUP_NAME;
        REXPGR(nItemCol).EXPKIND := rec.NEXPKIND;
        REXPGR(nItemCol).EXPKIND_CODE := rec.SEXPKIND;

    end loop;


    if REXPGR.Count = 0 then
      zp_exception(0,'Не найдено групп затрат по данным условиям отбора');
    end if;

    nCountCol := nvl(nCountCol,0) + nvl(REXPGR.Count,0)/*+4*/;

    select nvl(NEXT_INDX,1)
     into nNextIndex
     from Z_VERSIONS
    where RN = pVERSION;

    APKG_XLSREP.ADD_COLUMN(nWIDTH => 160);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 100);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 80, nCount => 2);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 300);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 100, nCount => 2);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 200);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 110, nCount => REXPGR.Count*3);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 120, nCount => 3);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 100, nCount => 4);
    APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCountCol-1, sCELLDATA => sTITLE, sCELLTYPE => 'String');



    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'УН рег.номер', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Группа услуг', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Стоимостная группа', sCELLTYPE => 'String', nMERGEDOWN => 3);

    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Код услуги', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Наименование услуги', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Единица измерения', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Группа учреждений', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Наименование учреждений', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Плановый показатель объема', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Итого норматив затрат на услугу', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Группы затрат', sCELLTYPE => 'String', nMERGEACROSS => REXPGR.Count*3-1);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Объем бюджетных ассигнований', sCELLTYPE => 'String', nMERGEDOWN => 3);

    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Базовый норматив', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Отраслевой коэффициент', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Территориальный коэффициент', sCELLTYPE => 'String', nMERGEDOWN => 3);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Коэффициент выравнивания', sCELLTYPE => 'String', nMERGEDOWN => 3);

    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    for rec in
    (
     select NAME, NUM, rownum from Z_LOV where PART = 'EXPKIND' order by NUM
    )
    loop
        nCount := null;
        for I in REXPGR.first..REXPGR.last
        loop
            if REXPGR(I).EXPKIND = rec.NUM then
                nCount := nvl(nCount,0) + 3;
            end if;
        end loop;

        if nCount is not null then
            APKG_XLSREP.ADD_CELL(sSTYLE       => 'table_head',
                                 sCELLDATA    => rec.NAME,
                                 sCELLTYPE    => 'String',
                                 nSKIPINDEX   => case when rec.rownum = 1 then 10 else 0 end,
                                 nMERGEACROSS => nCount-1);
        end if;
    end loop;

    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    for I in REXPGR.first..REXPGR.last
    loop
       APKG_XLSREP.ADD_CELL(sSTYLE       => 'table_head',
                            sCELLDATA    => nvl(REXPGR(I).CODE,'Группа затрат не задана'),
                            sCELLTYPE    => 'String',
                            nSKIPINDEX   => case when I = 1 then 10 else 0 end,
                            nMERGEACROSS => 2);
    end loop;

    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    for I in REXPGR.first..REXPGR.last
    loop
       APKG_XLSREP.ADD_CELL(sSTYLE       => 'table_head',
                            sCELLDATA    => 'План',
                            sCELLTYPE    => 'String',
                            nSKIPINDEX   => case when I = 1 then 10 else 0 end);

       APKG_XLSREP.ADD_CELL(sSTYLE       => 'table_head',
                            sCELLDATA    => 'Лимит',
                            sCELLTYPE    => 'String');

       APKG_XLSREP.ADD_CELL(sSTYLE       => 'table_head',
                            sCELLDATA    => 'Отклонение',
                            sCELLTYPE    => 'String');
    end loop;




    for QServ in
    (
     select SR.SSERVSIGN_CODE, SR.SCOSTGROUP_NAME, SR.NSERVRN, SR.SUNIQREGNUM, SR.SREGNUM, SR.SSERVCODE, SR.SMEASURE_CODE
       from ZV_SERVREG SR
      where SR.NJURPERS = pJURPERS
        and SR.NVERSION = pVERSION
        and SR.NWORKSERV in (1,3)
        and SR.NPARENT_SIGN is null
      order by SR.NORDERNUMB, lpad(SR.SREGNUM,20), SR.SSERVCODE
    )
    loop
        for QOrg in
        (
         select O.NORGROUP, O.NORGRN, O.SORGROUP_CODE, O.SORGCODE, SL.NLINKS, SL.NACCEPT_NORM,    SL.NCORRCOEF, SL.NREGKOEFF, SL.NALIGKOEFF
           from ZV_ORGREG O, ZV_SERVLINKS SL
          where SL.NORGRN = O.NORGRN
            and ((O.NORGTYPE = pORGTYPE) or (pORGTYPE is null))
            and ((O.NORGROUP = pORGGR) or (pORGGR is null))
            and ((O.NORGRN = pORGRN) or (pORGRN is null))
            and ((pORGMARK) is null or (SL.NORGMARK = pORGMARK))
            and SL.NSERVRN = QServ.NSERVRN
            and O.NORGTYPE in (0,1)
          order by O.NORGROUP, O.NORDERNUMB, O.SNUMB, O.SORGCODE
        )
        loop
            nQindVal := Z_GETSERVCOUNT3 (pSERVRN => QServ.NSERVRN, pORGRN => QOrg.NORGRN, pNUMDATE => 3);
            APKG_XLSREP.ADD_ROW();
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QServ.SUNIQREGNUM, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QServ.SSERVSIGN_CODE, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QServ.SCOSTGROUP_NAME, sCELLTYPE => 'String');

            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QServ.SREGNUM, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => QServ.SSERVCODE, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => QServ.SMEASURE_CODE, sCELLTYPE => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA  => QOrg.SORGROUP_CODE, sCELLTYPE  => 'String');

            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA  => QOrg.SORGCODE, sCELLTYPE  => 'String');
            APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num',
                                 sCELLDATA => nQindVal,
                                 sCELLTYPE => 'Number');
            nCount:=REXPGR.Count*3+nSkipCountALL;
            APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => '=SUM(RC[1]:RC['||nCount||'])', sCELLTYPE => 'Formula');
          --  zp_exception(0,nCount);
              for I in REXPGR.first..REXPGR.last
            loop


                select sum(EA.NSERVSUM) PSUM
                 into nPSUM
                 from ZV_EXPALL EA, ZV_EXPMAT E
                where EA.NEXPMAT = E.NEXPMAT
                  and ((EA.NVNEBUDG_SIGN = pVNEBUDGSIGN) or (pVNEBUDGSIGN is null))
                  and EA.NORGRN = QOrg.NORGRN
                  and EA.NSERVRN = QServ.NSERVRN
                  and E.NEXPGROUP = REXPGR(I).RN
                  and E.NEXPKIND = REXPGR(I).EXPKIND
                  and E.NEXPTYPE <> 5;

                select sum(ACCEPT_NORM) PSUM
                 into nLIMIT_SUM
                 from Z_SERVLINKS_NORM SN
                where VERSION = pVERSION
                  and LINKRN =      QOrg.NLINKS
                  and EXPGROUP = REXPGR(I).RN
                  and ORGRN    = QOrg.NORGRN
                  and SERVRN  = QServ.NSERVRN;




                /*if REXPGR(I).CODE in ('ОТ1','ОТ2','МЗ') then

                     APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num',
                                          sCELLDATA => case when nQindVal > 0 then substr(nPSUM211/nQindVal,1,30) else 0 end,
                                          sCELLTYPE => 'Number');

                    APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num',
                                         sCELLDATA => case when nQindVal > 0 then substr(nPSUM213/nQindVal,1,30) else 0 end,
                                         sCELLTYPE => 'Number');    */


                    APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num',
                                         sCELLDATA => case when nQindVal > 0 then substr(nvl(nPSUM, 0)/nQindVal,1,30) else 0 end,
                                         sCELLTYPE => 'Number');

                    APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num',
                                         sCELLDATA => nvl(nLIMIT_SUM, 0),
                                         sCELLTYPE => 'Number');

                    APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num',
                                         sCELLDATA => '=RC[-2]-RC[-1]',
                                         sCELLTYPE => 'Formula');

            end loop;
            APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num',
                                 sCELLDATA => '=RC[-'||to_char(nCount+2)||']*RC[-'||to_char(nCount+1)||']',
                                 sCELLTYPE => 'Formula');

            APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num', sCELLDATA => nvl(QOrg.NACCEPT_NORM, 0), sCELLTYPE => 'Number');
            APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num', sCELLDATA => nvl(QOrg.NCORRCOEF, 0), sCELLTYPE => 'Number');
            APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num', sCELLDATA => nvl(QOrg.NREGKOEFF, 0), sCELLTYPE => 'Number');
            APKG_XLSREP.ADD_CELL(sSTYLE    => 'border_right_num', sCELLDATA => nvl(QOrg.NALIGKOEFF, 0), sCELLTYPE => 'Number');
            bPRINT := true;
        end loop;
    end loop;

    APKG_XLSREP.FLUSH_ROWCELLS();

    APKG_XLSREP.CLOSE_TABLE_AND_SHEET;
    APKG_XLSREP.CLOSE_REPORT();
    pFILE := APKG_XLSREP.GET_BLOB;
  exception
    when others then
      APKG_XLSREP.FREE_BLOB;
      raise;
  end;

  if not bPRINT then
    zp_exception(0,'Формирование пустого отчёта невозможно!');
  end if;
end;​
