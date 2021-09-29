
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

Select NEXT_PERIOD, PLAN1, PLAN2
  into nNEXTPERIOD, nPLAN1, nPLAN2
  from Z_VERSIONS where RN = pVersion;
