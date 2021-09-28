create or replace TRIGGER  "HT_INCOME_PF_DTL_UA_BU"
before update on H_INCOME_PRILFORMS_DTL for each row
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
    :new.NOTES := trim(regexp_replace(:new.NOTES, '^[[:blank:][:cntrl:][:space:]]+|[[:blank:][:cntrl:][:space:]]+$', ' '));

    :new.TOTAL := nvl(:new.X1, 1) * nvl(:new.X2, 1);
    :new.PLAN1_TOTAL := :new.PLAN1_X1 * :new.PLAN1_X2;
    :new.PLAN2_TOTAL := :new.PLAN2_X1 * :new.PLAN2_X2;
    :new.PLAN3_TOTAL := :new.PLAN3_X1 * :new.PLAN3_X2;
end;​
