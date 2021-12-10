create or replace procedure ZP_GET_SPORT_TEAM_BY_RN
(
pVERSFROM   number,
pVERSTO     number,
pINPARAM    number,
pORGRNTO    number default null,
pINSERT     number default 0,
pOUTPARAM   out number,
pOUTLOG     out varchar
)
as
 nORGRNTO   number;
 nJURPERSTO number;
begin

    begin
        select JUR_PERS
          into nJURPERSTO
          from Z_VERSIONS
         where RN = pVERSTO;
    exception when others then
        null;
    end;

    for rec in
    (
     select *
       from Z_SPORT_TEAM
      where RN       = pINPARAM
        and VERSION  = pVERSFROM
    )
    loop

        if pORGRNTO is null then
            ZP_GET_ORGREG_BY_RN(pVERSFROM => pVERSFROM,
                                pVERSTO   => pVERSTO,
                                pINPARAM  => rec.ORGRN,
                                pINSERT   => pINSERT,
                                pOUTPARAM => nORGRNTO,
                                pOUTLOG   => pOUTLOG);
        else
            nORGRNTO := pORGRNTO;
        end if;

        begin
            select RN
              into pOUTPARAM
              from Z_SPORT_TEAM
             where VERSION     = pVERSTO
               and ORGRN       = nORGRNTO
               and NAME        = rec.NAME;
        exception when OTHERS then
            if pINSERT = 1 then
                begin
                    --TEAM_RN;
                    pOUTPARAM := GEN_ID;
                    insert into Z_SPORT_TEAM(RN,
                                           JURPERS,
                                           VERSION,
                                           ORGRN,

                                           NAME,
                                           DESCRIPTION,
                                           DT_ST,
                                           DT_FN,
                                           STAT_NUM,
                                           KIND_NUM)
                                   values (pOUTPARAM,
                                           nJURPERSTO,
                                           pVERSTO,
                                           nORGRNTO,

                                           rec.NAME,
                                           rec.DESCRIPTION,
                                           rec.DT_ST,
                                           rec.DT_FN,
                                           rec.STAT_NUM,
                                           rec.KIND_NUM
                                           );
                    commit;
                exception when others then
                    pOUTLOG   := sqlerrm;
                    pOUTPARAM := null;
                    if pOUTLOG is not null then EXIT; end if;
                end;
            end if;
        end;
    end loop;
end;​
