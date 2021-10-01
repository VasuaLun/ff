-- Вывод данных в itemы
declare default_value varchar2(24);
begin
    select D.NOTES into default_value
        from H_INCOME_PRILFORMS_DTL D
        where D.RN = :P794_RN;
    return default_value;
end;

declare default_value varchar2(24);
begin
    select NEXT_PERIOD into default_value
        from Z_VERSIONS where RN = :P1_VERSION;
    return default_value;
end;

declare default_value varchar2(24);
begin
    select PLAN1 into default_value
        from Z_VERSIONS where RN = :P1_VERSION;
    return default_value;
end;

declare default_value varchar2(24);
begin
    select PLAN2 into default_value
        from Z_VERSIONS where RN = :P1_VERSION;
    return default_value;
end;

Select NEXT_PERIOD, PLAN1, PLAN2
  into nNEXTPERIOD, nPLAN1, nPLAN2
  from Z_VERSIONS where RN = pVersion;

declare outcome number;
begin
    outcome := nvl(:P794_P794_1PERCOUNT, 0) * nvl(:P794_1PAY, 0) * nvl(:P794_1DAYSCOUNT, 0);
    return outcome;
end;

declare outcome number;
begin
    outcome := nvl(:P794_2PERCOUNT, 0) * nvl(:P794_2PAY, 0) * nvl(:P794_2DAYSCOUNT, 0);
    return outcome;
end;

-- Работа кнопки SAVE
declare
    str_rn long := :P2011_RN_ARR;
    rn_depfin number := :P2011_DEPFIN_RN;
    rn_jurpers number;
    rn_array dbms_utility.lname_array;
    value_array dbms_utility.lname_array;
    rn_count binary_integer;
    value_count binary_integer;

begin
    if str_rn = 'null' or  str_rn is null or trim(str_rn) = '' then
        ZP_EXCEPTION (0, 'Не выбрано ни одной записи');

    else
            rn_jurpers := to_number(substr(rn_array(i),2));
            INSERT INTO Z_DEPFIN_GRBS(DEPFIN_RN, JURPERS_RN) VALUES (rn_depfin, rn_jurpers);
        :P2011_RN_ARR := null;
    end if;
end;

-- Запрос для item P794_ACODE, для выбора целевой статьи
select F.CODE, F.NAME
from Z_FUNDS F, Z_FUNDS_ORGS FO
where F.JUR_PERS = 1351099
    and F.VERSION = 344076908
    and FO.FUND_RN = F.RN
    and FO.ORG_RN =  nvl(:P1_ORGRN,:P7_ORGFILTER)

select F.CODE, F.NAME
from Z_FUNDS F, Z_FUNDS_ORGS FO
where F.JUR_PERS = :P1_JURPERS
    and F.VERSION = :P1_VERSION
    and FO.FUND_RN = F.RN
    and FO.ORG_RN =  nvl(:P1_ORGRN,:P7_ORGFILTER)

select F.CODE, F.NAME
from Z_FUNDS F, Z_FUNDS_ORGS FO
where F.JUR_PERS = 1351099
    and F.VERSION = 344076908
    and FO.FUND_RN = F.RN
    and FO.ORG_RN = 344150893
