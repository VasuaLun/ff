create or replace procedure ZP_GET_SPORT_MEMBER_BY_RN
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
 nTEAM_RN   number;
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
       from Z_SPORT_MEMBER
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
              from Z_SPORT_MEMBER
             where VERSION     = pVERSTO
               and ORGRN       = nORGRNTO
               and SURNAME     = rec.SURNAME
               and NAME        = rec.NAME
               and BIRTHDATE   = rec.BIRTHDATE
               and MEMBER_TYPE = rec.MEMBER_TYPE
               and ((SNILS       = rec.SNILS and rec.SNILS is not null) or (rec.SNILS is null));
        exception when OTHERS then
            if pINSERT = 1 then
                begin
                    if rec.TEAM_RN is not null then
                    ZP_GET_SPORT_TEAM_BY_RN(pVERSFROM => pVERSFROM,
                                        pVERSTO   => pVERSTO,
                                        pINPARAM  => rec.TEAM_RN,
                                        pORGRNTO  => nORGRNTO,
                                        pINSERT   => pINSERT,
                                        pOUTPARAM => nTEAM_RN,
                                        pOUTLOG   => pOUTLOG);
                    pOUTPARAM := GEN_ID;
                else pOUTPARAM := 0;
                    end if;
                    insert into Z_SPORT_MEMBER(RN,
                                               JURPERS,
                                               VERSION,
                                               ORGRN,

                                               MEMBER_TYPE,
                                               SURNAME,
                                               NAME,
                                               MIDDLE_NAME,
                                               SEX,
                                               BIRTHDATE,
                                               DOCTYPE,
                                               DOCNUM,
                                               STATUS_NUM,
                                               TYPE_NUM,
                                               TEAM_RN,
                                               KIND_NUM,
                                               LEVEL_NUM,
                                               YEARSTART,
                                               RANK_NUM,
                                               MARK_NUM,
                                               MKIND_NUM,
                                               SNILS,
                                               EDUCATION,
                                               DT_FIN_EDUCATE,
                                               CAT_NUM,
                                               GRBS_MARK,
                                               MARK_NUM_RF)
                                       values (pOUTPARAM,
                                               nJURPERSTO,
                                               pVERSTO,
                                               nORGRNTO,

                                               rec.MEMBER_TYPE,
                                               rec.SURNAME,
                                               rec.NAME,
                                               rec.MIDDLE_NAME,
                                               rec.SEX,
                                               rec.BIRTHDATE,
                                               rec.DOCTYPE,
                                               rec.DOCNUM,
                                               rec.STATUS_NUM,
                                               rec.TYPE_NUM,
                                               nTEAM_RN,
                                               rec.KIND_NUM,
                                               rec.LEVEL_NUM,
                                               rec.YEARSTART,
                                               rec.RANK_NUM,
                                               rec.MARK_NUM,
                                               rec.MKIND_NUM,
                                               rec.SNILS,
                                               rec.EDUCATION,
                                               rec.DT_FIN_EDUCATE,
                                               rec.CAT_NUM,
                                               rec.GRBS_MARK,
                                               rec.MARK_NUM_RF);
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
