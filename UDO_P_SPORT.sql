create or replace procedure UDO_P_SPORT
(
    nIDENT         in number,
    nRN_ORG        in number,   -- Организация из параметра
    nJURPERS       in number,   -- Учредитель
    nUSER          in number,   -- Пользователь
    nLOG           in number,   -- Ссылка для записи ошибок в лог
    nRESULT        out number,  -- Если 0, то всё хорошо
    sRESULT_MSG    out varchar2 -- Результирующий текст
)
as
    pJURPERS       number(17):= v('P1_JURPERS');--210725023;
    pVERSION       number(17):= v('P1_VERSION') ;--321190246;
    nROWCNT        pls_integer;
    pORGRN         number;
    nADDEDCOUNT    number;
    sERR_MSG       varchar2(4000);
    nERROR         number;

    -- Для региона
    nNUMBMARK      number;
    nCOUNTRYMARK   number;
    nSUBJECT       number;
    nCOUNTRY       number;

    vINUMBMARK      varchar2(4000);

    nRN_MEMBER     number;
    nRN_EXP        number;
    nMEMBER_RN     number;
    nMEMBER_TYPE   number;
    nMAX_INUM      number;

    nCOUNT         number;
    nCOUNT_SPEC    number;

    nSPORT_MKIND   number;

    nCOUNT_INS     number;
    nCOUNT_INS_EVENT number;
    nCOUNT_INS_MEMBER number;

    nCALENDAR_RN   number;
    pINUMB         number;
    nTOWN          number;
    nKIND_NUM      number;
    nSERVRN        number;
    nRN_EVENT      number;
    dSTART         date;
    dFIN           date;
    nTOWN_RN       number;
    nSPORTKIND     number;
begin

    select count(*)
        into nROWCNT
    from (select *
        from UDO_SPORT
        where IDENT = nIDENT);

   if pVERSION is null then
       ZP_EXCEPTION (0, 'Не задана версия.');
   end if;

   -- Бежим по буферной таблице
   for rec in
   (
    select t.*, rownum
        from UDO_SPORT t
    where t.IDENT = nIDENT
    order by INUMB
   )
   loop

        if nvl(vINUMBMARK, '-') != rec.INUMB then

            vINUMBMARK := rec.INUMB;
            -- Проверка на заполнение учреждения по ИНН
            if rec.INN is null then
                sERR_MSG  := 'Строка: '||((rec.rownum + 1) + 1)||', отсутствует ИНН: ' || rec.INN;
            end if;

            -- Проверка заполнение внутреннего номера мероприятия
            if rec.INUMB is null then
                sERR_MSG  := 'Строка: '||((rec.rownum + 1) + 1)||', отсутствует внутренний номер мероприятия: ' || rec.INUMB;
            end if;

            -- Проверка на заполнение мероприятия
            if rec.NAME is null then
                sERR_MSG := 'Строка: '||((rec.rownum + 1) + 1)||', Отсутствует название мероприятия: ' || rec.NAME;
            end if;

            -- Проверка на заполнение календаря
            if rec.CALENDAR_RN is null then
                sERR_MSG := 'Строка: '||((rec.rownum + 1) + 1)||', Отсутствует календарь: ' || rec.CALENDAR_RN;
            end if;

            -- Нахождение RN организации
            if sERR_MSG is null then
                begin
                    select RN into pORGRN
                      from Z_ORGREG
                     where version = pVERSION
                       and INN = TRIM(rec.INN);
                exception when others then
                    sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не найдена организация по ИНН: ' || rec.INN;
                    nERROR := nvl(nERROR,0) + 1;
                    pORGRN := null;
                end;
            end if;

            -- Проверка уникальности номера мероприятия
            if sERR_MSG is null then
                begin
                    select RN into pINUMB
                        from Z_SPORT
                    where VERSION = pVERSION
                        and JURPERS = pJURPERS
                        and ORGRN = pORGRN
                        and INUMB = rec.INUMB;
                    sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не уникальный номер мероприятия: ' || rec.INUMB;
                    nERROR := nvl(nERROR,0) + 1;
                exception when others then
                    pINUMB := rec.INUMB;
                end;
            end if;

            -- Проверить правильность календаря
            if sERR_MSG is null then
                begin
                    select RN
                    into nCALENDAR_RN
                        from Z_SPORT_CALENDAR
                    where UNUMB || '-' || UVERSION = rec.CALENDAR_RN
                        and VERSION  = pVERSION
                        and JURPERS = pJURPERS
                        and ORGRN = pORGRN
                        and PART = 'SPORT_CALEND';
                exception when others then
                    sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не найден период календаря: ' || rec.SERV_NAME||', '||sqlerrm;
                    nERROR := nvl(nERROR,0) + 1;
                    nCALENDAR_RN := null;
                end;
            end if;

            -- Получение RN услуги
            if sERR_MSG is null then
                begin
                    select RN
                    into nSERVRN
                       from Z_SERVREG
                    where (NAME = rec.SERV_NAME
                            or CODE = rec.SERV_CODE
                            or UNIQREGNUM_FULL = rec.UNIQREGNUM
                            )
                        and VERSION  = pVERSION
                        and JUR_PERS = pJURPERS;
                exception when others then
                    sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не найдена услуга: ' || rec.SERV_NAME;
                    nERROR := nvl(nERROR,0) + 1;
                    nSERVRN := null;
                end;
            end if;

            -- Получение RN вида спорта
            if sERR_MSG is null then
                if rec.TYPE_GAME is not null then
                    begin
                        select NUM
                        into nKIND_NUM
                        from z_lov
                        where part = 'SPORT_KIND'
                            and lower(name) like regexp_replace(lower(rec.TYPE_GAME), '[ ""''-]+','%');
                    exception when others then
                        nKIND_NUM := null;
                        sERR_MSG := 'Строка '||(rec.rownum + 1)||': Не найден вид спорта с наименованием : '||rec.TYPE_GAME||'.';
                        nERROR := nvl(nERROR,0) + 1;
                    end;
                end if;
            end if;

            -- Получение RN города
            if sERR_MSG is null then
                begin
                    select RN, NUMB, COUNTRY_NUM
                    into nTOWN, nNUMBMARK, nCOUNTRYMARK
                       from Z_DISTRICT
                      where lower(CODE) = regexp_replace(lower(rec.TOWN), '[ ""''-]+','%')
                        and VERSION  = pVERSION
                        and JUR_PERS = pJURPERS;

                    select RN
                    into nSUBJECT
                        from Z_DISTRICT
                        where NUMB = nNUMBMARK
                            and REGION_LEVEL = 0
                            and VERSION  = pVERSION
                            and JUR_PERS = pJURPERS;

                    select RN
                    into nCOUNTRY
                        from Z_DISTRICT
                        where NUMB = nCOUNTRYMARK
                            and REGION_LEVEL = 2
                            and VERSION  = pVERSION
                            and JUR_PERS = pJURPERS;

                exception when others then
                    sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не найден город проведения: ' || rec.TOWN;
                    nERROR := nvl(nERROR,0) + 1;
                    nTOWN := null;
                end;
            end if;

            if sERR_MSG is null then
                if rec.START_DATE is not null then
                    begin
                       select rec.START_DATE into dSTART from dual;
                    exception when others then
                        dSTART := null;
                        sERR_MSG := 'Строка '||(rec.rownum + 1)||': Указана некорректная дата начала мероприятия: '||rec.START_DATE||'.'||sqlerrm;
                        nERROR := nvl(nERROR,0) + 1;
                    end;
                else
                    sERR_MSG  := 'Строка '||(rec.rownum + 1)||': Отсутствует дата начала мероприятия';
                    nERROR := nvl(nERROR,0) + 1;
                end if;
            end if;

            if sERR_MSG is null then
                if rec.FINISH_DATE is not null then
                    begin
                       select rec.FINISH_DATE into dFIN from dual;
                    exception when others then
                        dFIN := null;
                        sERR_MSG := 'Строка '||(rec.rownum + 1)||': Указана некорректная дата окончания мероприятия : '||rec.FINISH_DATE||'.'||sqlerrm;
                        nERROR := nvl(nERROR,0) + 1;
                    end;
                else
                    sERR_MSG  := 'Строка '||(rec.rownum + 1)||': Отсутствует дата окончания мероприятия';
                    nERROR := nvl(nERROR,0) + 1;
                end if;
            end if;

            if sERR_MSG is null then
                begin
                    nRN_EVENT := gen_id();
                    insert into Z_SPORT(RN, JURPERS, VERSION, ORGRN, CALENDAR_RN, INUMB, NAME, START_DATE, FINISH_DATE, SERV_RN, KIND_NUM, DISTRICT_RN, TOWN_RN, COUNTRY_RN)
                                        values(nRN_EVENT, pJURPERS, pVERSION, pORGRN, nCALENDAR_RN, pINUMB, rec.NAME, dSTART, dFIN, nSERVRN, nKIND_NUM, nSUBJECT, nTOWN, nCOUNTRY);

                    nCOUNT_INS_EVENT := nvl(nCOUNT_INS_EVENT, 0) + 1;

                exception when others then
                    sERR_MSG  := 'Строка '||(rec.rownum + 1)||': Не удалось мероприятие: ' || rec.NAME||sqlerrm;
                    nERROR := nvl(nERROR,0) + 1;
                end;
            end if;
        end if;

        -- Проверка наличия прикрепленных участников
        if rec.MEMBER_NAME is not null then

            -- Получение RN участника
            if sERR_MSG is null then
                if (regexp_replace(lower(rec.MEMBER_NAME), '[ ""''-]+№1234567890', '%') like 'условный участник') then
                    nMEMBER_RN := null;

                    -- Получение RN типа участника
                    if rec.MEMBER_TYPE is not null then
                        begin
                            select NUM
                            into nMEMBER_TYPE
                            from Z_LOV
                            where part = 'SPORT_MKIND'
                                and lower(name) like regexp_replace(lower(rec.MEMBER_TYPE), '[ ""''-]+','%');
                        exception when others then
                            nMEMBER_TYPE := null;
                            sERR_MSG := 'Строка '||(rec.rownum + 1)||': Не найден тип объекта с наименованием : '||rec.MEMBER_TYPE||'.';
                            nERROR := nvl(nERROR,0) + 1;
                        end;
                    else
                        nMEMBER_TYPE := null;
                        sERR_MSG := 'Строка '||(rec.rownum + 1)||': Не найден тип объекта с наименованием : '||rec.MEMBER_TYPE||'.';
                        nERROR := nvl(nERROR,0) + 1;
                    end if;

                else
                    begin
                        select RN
                        into nMEMBER_RN
                        from Z_SPORT_MEMBER
                        where VERSION  = pVERSION
                            and JURPERS = pJURPERS
                            and ORGRN = pORGRN
                            and lower(SURNAME||NAME||MIDDLE_NAME) = regexp_replace(lower(rec.MEMBER_NAME), '[ ""''-]+');
                    exception when others then
                        nMEMBER_RN := null;
                        sERR_MSG := 'Строка '||(rec.rownum + 1)||': Не участник с именем : '||rec.MEMBER_NAME||'.';
                        nERROR := nvl(nERROR,0) + 1;
                    end;
                end if;
            end if;

            if sERR_MSG is null then
                if nMEMBER_RN is not null then
                    -- Проверка на дублирование участника
                    select count(*) into nCOUNT
                      from Z_SPORT_EXP
                     where SPORT_EVENT_RN = nRN_EVENT
                       and MEMBER_RN = nMEMBER_RN;

                    -- Проверка на вид спорта участника
                    select count(*) into nCOUNT_SPEC
                      from Z_SPORT_SPEC
                     where MEMBER_RN = nMEMBER_RN
                       and KIND_NUM = (select KIND_NUM from Z_SPORT where RN = nRN_EVENT);
                end if;

                if ((nCOUNT = 0 and nCOUNT_SPEC = 1) or nMEMBER_RN is null) then
                    select max(INUMB) into nMAX_INUM
                      from Z_SPORT_EXP
                     where SPORT_EVENT_RN = nRN_EVENT;

                    if nMEMBER_RN is not null then
                        select member_type into nMEMBER_TYPE
                          from Z_SPORT_MEMBER
                         where RN = nMEMBER_RN;
                    end if;

                    if sERR_MSG is null then
                        begin
                            nRN_EXP := gen_id();
                            insert into Z_SPORT_EXP(RN, JURPERS,VERSION,ORGRN,SPORT_EVENT_RN,MEMBER_RN, INUMB, MEMBER_TYPE)
                                            values(nRN_EXP, pJURPERS, pVERSION,  pORGRN, nRN_EVENT, nMEMBER_RN, nvl(nMAX_INUM,0) + 1, nMEMBER_TYPE);
                            nCOUNT_INS_MEMBER := nvl(nCOUNT_INS_MEMBER, 0) + 1;
                        exception when others then
                            sERR_MSG  := 'Строка '||(rec.rownum + 1)||': Не удалось добавить участника : ' || rec.MEMBER_NAME||sqlerrm;
                            nERROR := nvl(nERROR,0) + 1;
                        end;
                    end if;
                end if;
            end if;
        end if;

        -- Вовод данных об ошибку в строке
        if sERR_MSG is not null then
            APXA.AP_XLSLOGERR_BASE_INSERT
            (
            nPRN => nLOG,
            nERROR_TYPE => 1,
            sERROR_MSG => sERR_MSG
            );
            sERR_MSG := null;
        end if;
    end loop;

    nRESULT := 0;
    sRESULT_MSG := 'Всего обработано строк файла: '|| nvl(nROWCNT,0)||'. Добавлено мероприятий: ' || nvl(nCOUNT_INS_EVENT,0) ||'. Добавлено прикрепленных участников: ' || nvl(nCOUNT_INS_MEMBER,0) ||'. Ошибок: ' || nvl(nERROR,0) ||'.';

    -- sRESULT_MSG := 'Всего обработано строк файла: '|| nvl(nROWCNT,0)||'. Добавлено строк: ' || nvl(nCOUNT_INS,0) ||'. Ошибок: ' || nvl(nERROR,0) ||'.';

end;
