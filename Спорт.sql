create or replace procedure ZP_REP_SPORT_EVENT_DETAIL
(
  pJURPERS         number,
  pVersion         number,
  pOrgrn           varchar,
  pCalendRn        varchar,
  pSheetTitle     varchar DEFAULT NULL
)
as
  bPrint        boolean := false;  -- Признак пустого отчета
  nCountCol     pls_integer:= 15;  -- Количество колонок в отчете
  sTITLE        varchar2(2000);    -- Заголовок отчёта
  fl_out        number := 0;        -- признак выхода из цикла
  nCOUNT_EVENT  number := 0;
  nStrCount     number := 1;       -- Порядковый номер строки
  sPREVSERVNAME varchar2(1000);
  nUVERSION     Z_SPORT_CALENDAR.UVERSION%TYPE;
  dUDATE        date;

type RT_EXPTYPE is record
(
    EVENT_RN    number,
    RN             number,
    ORDERNUMB    number,
    NAME        varchar2(500),
    ALLSUM        number
);
 type arrEXPTYPE is table of RT_EXPTYPE index by pls_integer;
 COLL             arrEXPTYPE;
 COLL_EXP_HEAD    arrEXPTYPE;

  FUNCTION F_GET_TEAM_LIST(pEVENT_RN number) RETURN varchar2 is
    sRESULT varchar2(1000) := '';
  BEGIN
    begin
    for c in (
        select NAME from Z_SPORT_EVENT_TEAM ET, Z_SPORT_TEAM T where ET.EVENT_RN = pEVENT_RN
        and ET.TEAM_RN = T.RN)
    loop
        sRESULT:= sRESULT||c.NAME||'; ';
    end loop;
    sRESULT := substr(sRESULT, 0, LENGTH(sRESULT)-2);
    EXCEPTION
    WHEN OTHERS THEN
      sRESULT:= ' - ';
    END;
   return sRESULT;
  END;
begin

    begin
        select 'Расчет нормативных затрат по спортивным мероприятиям '|| O.code, UVERSION, UDATE
          into sTITLE, nUVERSION, dUDATE
          from Z_SPORT_CALENDAR C, Z_ORGREG O
         where C.ORGRN =  O.RN
           and C.JURPERS = pJurPers
           and C.VERSION = pVersion
           and C.ORGRN = pOrgrn
           and C.RN = pCalendRn;
    exception when others then
        null;
    end;

/*коллекция с суммами по видами прочих затрат и мероприятиям*/
    begin
        select E.SPORT_EVENT_RN, ET.RN, ET.ORDERNUMB, ET.NAME, sum(decode(nvl(S.EXIST_SIGN, 0), 1, 0, SUMMA)) OTH_SUM bulk collect into COLL
          from Z_SPORT_EXP E, Z_SPORT_EXP_D D, Z_SPORT_EXPTYPES ET, Z_SPORT S
         where D.EXP_RN= E.RN
           and ET.RN = D.EXPTYPE_RN
           and S.VERSION = pVersion
           and S.RN = E.SPORT_EVENT_RN
           and nvl(S.EXIST_SIGN, 0) != 1 and S.SERV_RN in (select RN from Z_SERVREG where VERSION = pVersion and WORKSERV_SIGN = 3)
           and S.CALENDAR_RN in (select RN from Z_SPORT_CALENDAR where VERSION = pVersion and UVERSION <= nUVERSION)
           and S.RN not in (select S.RN
                              from Z_SPORT S, Z_SPORT_EXP SE
                             where SE.SPORT_EVENT_RN = S.RN
                               and S.FINISH_DATE <= case when to_char(dUDATE, 'MM') < '04' then null
                                                        when to_char(dUDATE, 'MM') < '07' then to_date('31.03.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy')
                                                        when to_char(dUDATE, 'MM') < '10' then to_date('30.06.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy')
                                                        else to_date('30.09.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy') end
                             group by S.RN
                             having sum(nvl(FACT_TOTAL, 0)) = 0
                            )
        group by E.SPORT_EVENT_RN, ET.RN, ET.ORDERNUMB, ET.NAME
        order by ET.ORDERNUMB;
    exception when others then
        null;
    end;

/*коллекция с видами прочих затрат по мероприятию для заголовка*/
    begin
        select distinct null, ET.RN, ET.ORDERNUMB, ET.NAME, null bulk collect into COLL_EXP_HEAD
          from Z_SPORT_EXP E, Z_SPORT_EXP_D D, Z_SPORT_EXPTYPES ET, Z_SPORT S
         where D.EXP_RN= E.RN
           and S.VERSION = pVersion
           and ET.RN = D.EXPTYPE_RN
           and S.RN = E.SPORT_EVENT_RN
           and nvl(S.EXIST_SIGN, 0) != 1 and S.SERV_RN in (select RN from Z_SERVREG where VERSION = pVersion and WORKSERV_SIGN = 3)
           and S.CALENDAR_RN in (select RN from Z_SPORT_CALENDAR where VERSION = pVersion and UVERSION <= nUVERSION)
           and S.RN not in (select S.RN
                              from Z_SPORT S, Z_SPORT_EXP SE
                             where SE.SPORT_EVENT_RN = S.RN
                               and S.FINISH_DATE <= case when to_char(dUDATE, 'MM') < '04' then null
                                                        when to_char(dUDATE, 'MM') < '07' then to_date('31.03.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy')
                                                        when to_char(dUDATE, 'MM') < '10' then to_date('30.06.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy')
                                                        else to_date('30.09.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy') end
                             group by S.RN
                             having sum(nvl(FACT_TOTAL, 0)) = 0
                        )
        order by ET.ORDERNUMB;
    exception when others then
        null;
    end;


    APKG_XLSREP.OPEN_SHEET(nPROTECTED => 0, sSHEETNAME => pSheetTitle, nHSTATICCELLS => 3);
   -- APKG_XLSREP.ADD_NAMED_RANGE(sRANGE => 'R2');
    APKG_XLSREP.OPEN_TABLE();

    APKG_XLSREP.ADD_COLUMN(nWIDTH => 50);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 400);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 200);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 100, nCOUNT => 5);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 250, nCOUNT => 2);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 80);
    APKG_XLSREP.ADD_COLUMN(nWIDTH => 90, nCOUNT => COLL_EXP_HEAD.COUNT + 5);


    APKG_XLSREP.ADD_ROW(nHEIGHT => 25);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'title', nMERGEACROSS => nCountCol + COLL_EXP_HEAD.COUNT , sCELLDATA => sTITLE, sCELLTYPE => 'String');

    APKG_XLSREP.ADD_ROW(nHEIGHT => 20);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => '№ п/п', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Наименование мероприятия', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Команды', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Уровень мероприятия', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Вид спорта', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Начало мероприятия', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Окончание мероприятия', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Количество дней проведения', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Место проведения мероприятия (точный адрес и наименование объекта)', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Государственная работа', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Количество участников', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEACROSS => (3 + COLL_EXP_HEAD.COUNT), sCELLDATA => 'Плановые затраты', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', nMERGEDOWN => 1, sCELLDATA => 'Итого затрат', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_ROW(nHEIGHT => 40);

    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Транспорт', sCELLTYPE => 'String', nSKIPINDEX => 11);
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Проживание', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Питание', sCELLTYPE => 'String');
    APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => 'Суточные', sCELLTYPE => 'String');

    for i in 1..COLL_EXP_HEAD.COUNT
    loop
        APKG_XLSREP.ADD_CELL(sSTYLE => 'table_head', sCELLDATA => COLL_EXP_HEAD(i).NAME, sCELLTYPE => 'String');
    end loop;

    for rec in (
    select RN, INUMB, EVENT_NAME, EVENT_LEVEL, SPORT_KIND, ST_DT, FN_DT, CNT_DAY, LOCATION, SERVNAME, UNIQREGNUM, count(MEMBER) CNT_MEMBER, sum(TRANSIT) TRANSIT, sum(HOTEL) HOTEL, sum(FOOD) FOOD, sum(DAILY) DAILY, count(UNIQREGNUM) OVER (PARTITION BY  UNIQREGNUM, EVENT_LEVEL) AS COUNT_EVENT_BY_SERV /*,sum(other),*/
    from (
    select S.RN,
           S.INUMB,
           S.NAME event_name,
           (select name form_name from z_lov where part = 'SPORT_EVENT_LEVEL' and num = S.EVENT_LEVEL) EVENT_LEVEL,
           (select NAME from Z_LOV where PART = 'SPORT_KIND' and NUM = S.KIND_NUM) SPORT_KIND,
           to_char(S.START_DATE, 'dd.mm.yyyy') ST_DT,
           to_char(S.FINISH_DATE, 'dd.mm.yyyy') FN_DT,
           (S.FINISH_DATE - S.START_DATE + 1) CNT_DAY,
           (select code from Z_DISTRICT where VERSION = S.VERSION and rn = S.DISTRICT_RN) || ', ' ||(select CODE from Z_DISTRICT where VERSION = S.VERSION and RN = S.TOWN_RN) || case when LOCALITY is null then '' else ',' || LOCALITY end LOCATION,
           SR.UNIQREGNUM,
           SR.NAME SERVNAME,
           E.RN MEMBER,
           decode(nvl(S.EXIST_SIGN, 0), 1, 0, nvl(PLAN_TRANSIT, 0))  TRANSIT,
           decode(nvl(S.EXIST_SIGN, 0), 1, 0, nvl(PLAN_DAYS, 0) * nvl(PLAN_HOTEL, 0))   HOTEL,
           decode(nvl(S.EXIST_SIGN, 0), 1, 0, nvl(PLAN_FOOD_DAYS, 0) * nvl(PLAN_FOOD, 0))  FOOD,
           decode(nvl(S.EXIST_SIGN, 0), 1, 0, nvl(PLAN_DAILY, 0))  DAILY
       from Z_SPORT S, Z_SPORT_EXP E, Z_SERVREG SR
      where S.RN = E.SPORT_EVENT_RN
        and S.JURPERS = pJurPers
        and S.VERSION = pVersion
        and SR.VERSION = pVersion
        and S.SERV_RN = SR.RN
        and S.ORGRN = pOrgrn
        and nvl(S.EXIST_SIGN, 0) != 1 and S.SERV_RN in (select RN from Z_SERVREG where VERSION = pVersion and WORKSERV_SIGN = 3)
        and S.CALENDAR_RN in (select RN from Z_SPORT_CALENDAR where VERSION = pVersion and UVERSION <= nUVERSION)
        and S.RN not in (select S.RN
                           from Z_SPORT S, Z_SPORT_EXP SE
                          where SE.SPORT_EVENT_RN = S.RN
                            and S.FINISH_DATE <= case when to_char(dUDATE, 'MM') < '04' then null
                                                      when to_char(dUDATE, 'MM') < '07' then to_date('31.03.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy')
                                                      when to_char(dUDATE, 'MM') < '10' then to_date('30.06.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy')
                                                      else to_date('30.09.'||to_char(dUDATE, 'yyyy'), 'dd.mm.yyyy') end
                          group by S.RN
                          having sum(nvl(FACT_TOTAL, 0)) = 0
                    ))
     group by RN, INUMB, EVENT_NAME, SPORT_KIND, ST_DT, FN_DT, CNT_DAY, LOCATION, SERVNAME, EVENT_LEVEL, UNIQREGNUM
     order by SERVNAME, EVENT_LEVEL, SPORT_KIND, EVENT_NAME, ST_DT, FN_DT
    )
    loop

        if sPREVSERVNAME != rec.SERVNAME||' '||rec.UNIQREGNUM or sPREVSERVNAME is null then

            APKG_XLSREP.ADD_ROW(nHEIGHT => 30);
            APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_border_left_str', sCELLDATA => rec.SERVNAME||' ('||rec.UNIQREGNUM||'), кол-во мероприятий: '||rec.COUNT_EVENT_BY_SERV ||'', sCELLTYPE => 'String', nMERGEACROSS => 9);

            for col in 1..(COLL_EXP_HEAD.COUNT + 6)
            loop
                APKG_XLSREP.ADD_CELL(sSTYLE => case when col = 1 then 'bold_border_center_str' else 'bold_border_right_num' end, sCELLDATA => '=SUM(R[1]C:R['||rec.COUNT_EVENT_BY_SERV||']C)', sCELLTYPE => 'Formula');
            end loop;

            sPREVSERVNAME := rec.SERVNAME||' '||rec.UNIQREGNUM;
        end if;

        APKG_XLSREP.ADD_ROW(nHEIGHT => ZF_HEIGHTROW (StrVal => rec.EVENT_NAME, ROWSTRLENGHT => 60, ROWSTRHEIGHT => 15));

        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => nStrCount, sCELLTYPE => 'Number');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => rec.EVENT_NAME, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => F_GET_TEAM_LIST(rec.RN), sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => rec.EVENT_LEVEL, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => rec.SPORT_KIND, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => rec.ST_DT , sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => rec.FN_DT, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => rec.CNT_DAY, sCELLTYPE => 'Number');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => rec.LOCATION, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_left_str', sCELLDATA => rec.SERVNAME, sCELLTYPE => 'String');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_center_str', sCELLDATA => rec.CNT_MEMBER, sCELLTYPE => 'Number');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => rec.TRANSIT, sCELLTYPE => 'Number');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => rec.HOTEL, sCELLTYPE => 'Number');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => rec.FOOD, sCELLTYPE => 'Number');
        APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => rec.DAILY, sCELLTYPE => 'Number');


        for i in 1..COLL_EXP_HEAD.COUNT
        loop
            for j in 1..COLL.COUNT
            loop
                if COLL_EXP_HEAD(i).RN = COLL(j).RN and COLL(j).EVENT_RN = rec.RN then
                fl_out := 1;
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => COLL(j).ALLSUM, sCELLTYPE => 'Number');
                exit;
            end if;
            end loop;

            if fl_out = 0 then
                APKG_XLSREP.ADD_CELL(sSTYLE => 'border_right_num', sCELLDATA => 0, sCELLTYPE => 'Number');
            else
                fl_out := 0;
            end if;
        end loop;

        --sPREVSERVNAME := rec.SERVNAME;

        APKG_XLSREP.ADD_CELL(sSTYLE => 'bold_border_right_num', sCELLDATA => '=SUM(RC[-'||(COLL_EXP_HEAD.COUNT + 4)||']:RC[-1])', sCELLTYPE => 'Formula');
        bPrint := true;
        nStrCount := nStrCount + 1;
    end loop;

    APKG_XLSREP.FLUSH_ROWCELLS();
    APKG_XLSREP.CLOSE_TABLE_AND_SHEET;

    if not bPRINT then
        zp_exception(0,'Формирование пустого отчёта невозможно!');
    end if;
exception when others then
 zp_exception(0, 'ERR: '||sqlerrm||'. '||dbms_utility.format_error_backtrace);
end;​
