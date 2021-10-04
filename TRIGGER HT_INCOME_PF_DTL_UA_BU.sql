create or replace TRIGGER  "HT_INCOME_PF_DTL_UA_BU"
before update on H_INCOME_PRILFORMS_DTL for each row
declare
    nCheck number := ZF_CHECK_INCOME_PART(:NEW.PRN);
begin
    -- initialization
    ---------------------------------------------------------------------------
    :new.MODIFIED := get_time;
    :new.CHUSER   := v('APP_USER');

    -- permission
    ---------------------------------------------------------------------------
    ZF_CHECKPRIV2 (pJURPERS => :new.JURPERS,
                   pVERSION => :new.VERSION,
                   pUSER    => v('APP_USER'),
                   pPART    => 'OrgJustify2');

    ZF_GET_PART_CHECK_MODIFY (pJURPERS => :new.JURPERS,
                              pVERSION => :new.VERSION,
                              pORGRN   => :new.ORGRN,
                              pPART    => 'JUST_INC',
                              pFILIAL  => :new.FILIAL);

    ZF_GET_PFHDVERS_CHECK_MODIFY (pVERSION => :new.VERSION,
                                  pORGRN   => :new.ORGRN);


    -- logic
    ---------------------------------------------------------------------------
    if nCheck = 1 then
        if :new.X1 is NULL and :new.X1 is NULL and :new.X2
            :new.TOTAL := nvl(:new.X1, 1) * nvl(:new.X2, 1) * nvl(:new.X2, 1);
            :new.PLAN1_TOTAL := nvl(:new.PLAN1_X1, 1) * nvl(:new.PLAN1_X2, 1) * nvl(:new.PLAN1_COEFF, 1);
            :new.PLAN2_TOTAL := nvl(:new.PLAN2_X1, 1) * nvl(:new.PLAN2_X2, 1) * nvl(:new.PLAN2_COEFF, 1);
            :new.PLAN3_TOTAL := nvl(:new.PLAN3_X1, 1) * nvl(:new.PLAN3_X2, 1) * nvl(:new.PLAN3_COEFF, 1);
    else
        :new.NOTES := trim(regexp_replace(:new.NOTES, '^[[:blank:][:cntrl:][:space:]]+|[[:blank:][:cntrl:][:space:]]+$', ' '));

        :new.TOTAL := :new.X1 * :new.X2;
        :new.PLAN1_TOTAL := :new.PLAN1_X1 * :new.PLAN1_X2;
        :new.PLAN2_TOTAL := :new.PLAN2_X1 * :new.PLAN2_X2;
        :new.PLAN3_TOTAL := :new.PLAN3_X1 * :new.PLAN3_X2;
    end if;
end;​

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

-- добавление в таблицу
ALTER TABLE table_name
ADD (
    COEFF NUMBER(19,9) DEFAULT null,
    PLAN1_COEFF NUMBER(19,9) DEFAULT null,
    PLAN2_COEFF NUMBER(19,9) DEFAULT null,
    PLAN3_COEFF NUMBER(19,9) DEFAULT null,
    ACODE VARCHAR2(35) DEFAULT null,
);
