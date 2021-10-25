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

declare
    p_notes varchar2(500) := :P794_NOTE;
    p_x1          number  := :P794_1PERCOUNT;
    p_x2          number  := :P794_1PAY;
    p_total       number  := :P794_1OUTCOME;
    p_planx1      number  := :P794_2PERCOUNT;
    p_planx2      number  := :P794_2PAY;
    p_plan1_total number  := :P794_2OUTCOME;
    p_plan2x1     number  := :P794_3PERCOUNT;
    p_plan2x2     number  := :P794_3PAY;
    p_plan2_total number  := :P794_3OUTCOME;
    p_plan3x1     number  := :P794_4PERCOUNT;
    p_plan3x2     number  := :P794_4PAY;
    p_plan3_total number  := :P794_4OUTCOME;
    p_coeff       number  := :P794_1DAYSCOUNT;
    p_plan1_coeff number  := :P794_2DAYSCOUNT;
    p_plan2_coeff number  := :P794_3DAYSCOUNT;
    p_plan3_coeff number  := :P794_4DAYSCOUNT;
    p_content     varchar2(500) := :P794_CONTENT;

begin
    p_notes := :P794_NOTE;
    UPDATE H_INCOME_PRILFORMS_DTL
    set NOTES = p_notes,
        X1 = p_x1,
        X2 = p_x2,
        TOTAL = p_total,
        PLAN1_X1 = p_planx1,
        PLAN1_X2 = p_planx2,
        PLAN1_TOTAL = p_plan1_total,
        PLAN2_X1 = p_plan2x1,
        PLAN2_X2 = p_plan2x2,
        PLAN2_TOTAL = p_plan2_total,
        PLAN3_X1 = p_plan3x1,
        PLAN3_X2 = p_plan3x2,
        PLAN3_TOTAL = p_plan3_total,
        COEFF = p_coeff,
        PLAN1_COEFF = p_plan1_coeff,
        PLAN2_COEFF = p_plan2_coeff,
        PLAN3_COEFF = p_plan3_coeff,
        CONTENT = p_content
    where RN = :P794_RN;
end;

-- Работа кнопки SAVE
declare

    p_coeff       number  := :P794_1DAYSCOUNT;
    p_plan1_coeff number  := :P794_2DAYSCOUNT;
    p_plan2_coeff number  := :P794_3DAYSCOUNT;
    p_plan3_coeff number  := :P794_4DAYSCOUNT;
    p_content     varchar2(500) := :P794_CONTENT;

begin
    UPDATE H_INCOME_PRILFORMS_DTL
    set NOTES = :P794_NOTE,
        X1 = :P794_1PERCOUNT,
        X2 = :P794_1PAY,
        TOTAL = :P794_1OUTCOME,
        PLAN1_X1 = :P794_2PERCOUNT,
        PLAN1_X2 = :P794_2PAY,
        PLAN1_TOTAL = :P794_2OUTCOME,
        PLAN2_X1 = :P794_3PERCOUNT,
        PLAN2_X2 = :P794_3PAY,
        PLAN2_TOTAL = :P794_3OUTCOME,
        PLAN3_X1 = :P794_4PERCOUNT,
        PLAN3_X2 = :P794_4PAY,
        PLAN3_TOTAL = :P794_4OUTCOME,
        COEFF = :P794_1DAYSCOUNT,
        PLAN1_COEFF = :P794_2DAYSCOUNT,
        PLAN2_COEFF = :P794_3DAYSCOUNT,
        PLAN3_COEFF = :P794_4DAYSCOUNT,
        FUND = :P794_FUND,
        CONTENT = :P794_CONTENT
    where RN = :P794_RN;
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
where F.JUR_PERS = v('P794_JURPERS')
    and F.VERSION = v('P794_VERSION')
    and FO.FUND_RN = F.RN
    and FO.ORG_RN =  v(':P794_ORGRN')

select F.CODE, F.NAME
from Z_FUNDS F, Z_FUNDS_ORGS FO
where F.JUR_PERS = 1351099
    and F.VERSION = 344076908
    and FO.FUND_RN = F.RN
    and FO.ORG_RN = 344150893

-- Функция для работы триггера update
create or replace function ZF_CHECK_INCOME_PART (p_col_prn in number)
return number
as
    vCHECK varchar2(100);
begin
    select PART into vCHECK from  H_INCOME_PRILFORMS where RN = p_col_prn;
    if vCHECK = '10' then return 1;
    else return 0;
    end if;
end;

-- Код ЦС
select F.RN, F.CODE as Код, F.NAME as Название
from Z_ORG_BUDGDETAIL D, Z_FUNDS F
where D.rtype = 5
    and D.VERSION = v('P794_VERSION')
    and D.JUR_PERS = v('P794_JURPERS')
    and D. PRN = v('P794_ORG')
    and D.FUND = F.RN (+)

    declare default_value varchar2(24);
    begin
        select PLAN1 into default_value
            from Z_VERSIONS where RN = :P1_VERSION;
        return default_value;
    end;


begin
    UPDATE H_INCOME_PRILFORMS_DTL
    set NOTES       = :P794_NOTE,
        X1          = replace(:P794_1PERCOUNT, ' '),
        X2          = replace(:P794_1PAY, ' '),
        TOTAL       = replace(:P794_1OUTCOME, ' '),
        PLAN1_X1    = replace(:P794_2PERCOUNT, ' '),
        PLAN1_X2    = replace(:P794_2PAY, ' '),
        PLAN1_TOTAL = replace(:P794_2OUTCOME, ' '),
        PLAN2_X1    = replace(:P794_3PERCOUNT, ' '),
        PLAN2_X2    = replace(:P794_3PAY, ' '),
        PLAN2_TOTAL = replace(:P794_3OUTCOME, ' '),
        PLAN3_X1    = replace(:P794_4PERCOUNT, ' '),
        PLAN3_X2    = replace(:P794_4PAY, ' '),
        PLAN3_TOTAL = replace(:P794_4OUTCOME, ' '),
        COEFF       = replace(:P794_1DAYSCOUNT, ' '),
        PLAN1_COEFF = replace(:P794_2DAYSCOUNT, ' '),
        PLAN2_COEFF = replace(:P794_3DAYSCOUNT, ' '),
        PLAN3_COEFF = replace(:P794_4DAYSCOUNT, ' '),
        FUND        = :P794_FUND,
        CONTENT     = :P794_CONTENT
    where RN = :P794_RN;
end;
