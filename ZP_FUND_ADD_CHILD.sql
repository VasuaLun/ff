create or replace procedure ZP_FUND_ADD_CHILD
(
 pGRAFRN  number
)
as
 nMAXORDERNUM number;
begin
    for rec in
    (
     select *
       from Z_PURPOSE_OUTCOME
      where RN = pGRAFRN
    )
    loop

    begin
        insert into Z_PURPOSE_OUTCOME(RN,
                                     JUR_PERS,
                                     VERSION,
                                     ORGRN,
                                     KBK,
                                     FUNDS,
                                     PRN)
                             values (gen_id,
                                     rec.JUR_PERS,
                                     rec.VERSION,
                                     rec.ORGRN,
                                     rec.KBK,
                                     rec.FUNDS,
                                     pGRAFRN
                                     );
        exception when others then
            ZP_EXCEPTION (0,sqlerrm);
        end;
    end loop;
end;​
