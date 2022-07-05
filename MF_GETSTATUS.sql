create or replace function MF_GETSTATUS(
    pMESS number
)
return number
as
    res number;
begin
    begin
        select STATUS
        into res
        from M_MESSAGES
        where rn = pMESS;
    exception when others then
        return null;
    end;
    return res;
end;

create or replace function MF_GETSTATUS_NAME(
    pMESS   number default null,
    pSTATUS number default null,
    pTYPE   number default -- null - название статуса, 1 - цвет
)
return varchar2
as
    res    number;
    vCOLOR varchar2(100);
    vNAME  varchar2(100);
begin
    res := pSTATUS;
    if res is null then
        begin
            select STATUS
            into res
            from M_MESSAGES
            where rn = pMESS;
        exception when others then
            vCOLOR := 'red';
            vNAME  := 'Неизвестный статус';
        end;
    end if;

    if res = 1 then
        vCOLOR := 'red';
        vNAME  := 'Зарегистрировано';
    elsif res = 2 then
        vCOLOR := 'purple';
        vNAME  := 'В работе';
    elsif res = 3 then
        vCOLOR := 'green';
        vNAME  := 'Решено';
    elsif res = 4 then
        vCOLOR := 'green';
        vNAME  := 'Закрыто';
    else
        vCOLOR := 'red';
        vNAME  := 'Неизвестный статус';
    end if;

    if nvl(pTYPE, 0) = 0 then
        return res;
    elsif pTYPE = 1 then
        return 
          
end;