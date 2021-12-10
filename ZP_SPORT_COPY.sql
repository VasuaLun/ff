create or replace procedure ZP_SPORT_COPY
(
  pVERSFROM     number,
  pVERSTO       number,
  pTYPEACTION   number,
  pORGRNFROM    number default null,
  pORGRNTO      number default null,
  pTABLE        varchar2(200) default null
)
as
  nJURPERSTO    number;

  nORGREGTO     number;

  nFINDRN       number;
  nCOUNTPREV    number;
  nCOUNTCUR     number;
  nCOUNTPREVCUR number;
  sOUTLOG       varchar2(4000);
begin
     ---------------------------------------------------------------
     ---------------------------- Спорт ----------------------------
     -- 1. Z_SPORT_TEAM           (Команды)
     -- 1. Z_SPORT_MEMBER         (Участники)

    ---------------------------------------------------------------
    if ((pVERSFROM is null) or (pVERSTO is null)) then
        ZP_EXCEPTION(0,'Копирование не возможно. Не заданы версии из которой копировать и/или в которую копировать.');
    end if;

    begin
        select JUR_PERS
          into nJURPERSTO
          from Z_VERSIONS
         where RN = pVERSTO;
    exception when others then
        null;
    end;

    -- Команды
    if pTABLE is null or pTABLE = 'Z_SPORT_TEAM' then

        if nvl(pTYPEACTION,0) = 1 then

            for rec in
            (
            select *
              from Z_SPORT_TEAM
             where VERSION  = pVERSFROM
              and ((pORGRNFROM is null) or (ORGRN = pORGRNFROM))
              and ORGRN != 344343669
            order by rn desc
            )
            loop
                ZP_GET_SPORT_TEAM_BY_RN(pVERSFROM => pVERSFROM,
                                        pVERSTO   => PVERSTO,
                                        pINPARAM  => rec.RN,
                                        pINSERT   => 1,
                                        pOUTPARAM => nFINDRN,
                                        pOUTLOG   => sOUTLOG);

                if nFINDRN is null then
                    ZP_EXCEPTION (0, 'Не удалось скопировать запись раздела "Команды"'||sOUTLOG);
                end if;
            end loop;
        elsif nvl(pTYPEACTION,0) = 2 then
            begin
                delete from Z_SPORT_TEAM
                      where VERSION  = PVERSTO
                        and ((pORGRNTO is null) or (ORGRN = pORGRNTO));
            exception when others then
                ZP_EXCEPTION (0, 'Не удалось удалить записи раздела "Команды". Ошибка - '  || sqlerrm);
            end;
        end if;
    end if;

    if pTABLE is null or pTABLE = 'Z_SPORT_MEMBER' then

        if nvl(pTYPEACTION,0) = 1 then

            for rec in
            (
            select *
              from Z_SPORT_MEMBER
             where VERSION  = pVERSFROM
              and ((pORGRNFROM is null) or (ORGRN = pORGRNFROM))
                and ORGRN != 344343669
            order by rn desc
            )
            loop
                ZP_GET_SPORT_MEMBER_BY_RN(pVERSFROM => pVERSFROM,
                                            pVERSTO   => PVERSTO,
                                            pINPARAM  => rec.RN,
                                            pINSERT   => 1,
                                            pOUTPARAM => nFINDRN,
                                            pOUTLOG   => sOUTLOG);

                if nFINDRN is null then
                    ZP_EXCEPTION (0, 'Не удалось скопировать запись раздела "Участники"' ||sOUTLOG);
                end if;
            end loop;
        elsif nvl(pTYPEACTION,0) = 2 then
            begin
                delete from Z_SPORT_MEMBER
                      where VERSION  = PVERSTO
                        and ((pORGRNTO is null) or (ORGRN = pORGRNTO));
            exception when others then
                ZP_EXCEPTION (0, 'Не удалось удалить записи раздела "Участники". Ошибка - '  || sqlerrm);
            end;
        end if;
    end if;
end;​
