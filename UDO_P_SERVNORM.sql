create or replace procedure UDO_P_SERVNORM
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
    nCOUNT_INS     number;

    nSERVRN        number;
    nEXPGROUP      number;
    nLINKRN        number;
    nRN            number;

begin

    select count(*)
        into nROWCNT
    from (select *
        from UDO_SERVNORM
        where IDENT = nIDENT);

   if pVERSION is null then
       ZP_EXCEPTION (0, 'Не задана версия.');
   end if;

   -- Бежим по буферной таблице
   for rec in
   (
    select t.*, rownum
        from UDO_SERVNORM t
    where t.IDENT = nIDENT
   )
   loop

        -- Проверка на заполнение учреждения по ИНН
        if rec.INN is null then
            sERR_MSG  := 'Строка: '||((rec.rownum + 1) + 1)||', отсутствует ИНН: ' || rec.INN;
        end if;

        -- Проверка на заполнение данных об услуги
        if (rec.SERV_NAME is null) and (rec.SERV_CODE is null) and (rec.UNIQREGNUM is null) then
            sERR_MSG  := 'Строка: '||((rec.rownum + 1) + 1)||', отсутствует услуга: ' ||rec.SERV_NAME||', '||rec.SERV_CODE||', '||rec.UNIQREGNUM;
        end if;

        -- Проверка на заполнение группы затрат
        if rec.EXPGROUP is null then
            sERR_MSG  := 'Строка: '||((rec.rownum + 1) + 1)||', отсутствует группа затрат: ' ||rec.EXPGROUP;
        end if;

        if rec.ACCEPT_NORM is null
            and rec.ACCEPT_NORM2 is null
            and rec.ACCEPT_NORM3 is null
            and rec.ALIG_COEFF is null
            and rec.REG_COEFF is null
            and rec.CORRCOEF is null
            and rec.CORRCOEF2 is null
            and rec.CORRCOEF3 is null then
            sERR_MSG  := 'Строка: '||((rec.rownum + 1) + 1)||', отсутствуют числовые данные по нормативу: ';
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

        -- Получение RN услуги
        if sERR_MSG is null then
            begin
                select RN
                into nSERVRN
                   from Z_SERVREG
                where (lower(NAME) = regexp_replace(lower(rec.SERV_NAME), '[ ""''-]+','%')
                        or lower(CODE) = regexp_replace(lower(rec.SERV_CODE), '[ ""''-]+','%')
                        or lower(UNIQREGNUM_FULL) = regexp_replace(lower(rec.UNIQREGNUM), '[ ""''-]+','%')
                        )
                    and VERSION  = pVERSION
                    and JUR_PERS = pJURPERS;
            exception when others then
                sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не найдена услуга: ' || rec.SERV_NAME;
                nERROR := nvl(nERROR,0) + 1;
                nSERVRN := null;
            end;
        end if;

        -- Получение RN группы затрат
        if sERR_MSG is null then
            begin
                select RN
                into nEXPGROUP
                   from Z_EXPGROUP
                where CODE = TRIM(rec.EXPGROUP)
                    and VERSION  = pVERSION
                    and JUR_PERS = pJURPERS;
            exception when others then
                sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не найдена группа затрат: ' || rec.EXPGROUP;
                nERROR := nvl(nERROR,0) + 1;
                nSERVRN := null;
            end;
        end if;

        -- Получение на RN привязки услуги к учреждению
        if sERR_MSG is null then
            begin
                select RN
                into nLINKRN
            from Z_SERVLINKS
            where VERSION  = pVERSION
                and JUR_PERS = pJURPERS
                and ORGRN = pORGRN
                and SERVRN = nSERVRN;
            exception when others then
                sERR_MSG  := 'Строка: '||(rec.rownum + 1)||', не найдена услуга : ' ||rec.SERV_NAME|| ' у учреждения ' ||rec.INN;
                nERROR := nvl(nERROR,0) + 1;
                nLINKRN := null;
            end;
        end if;

        if sERR_MSG is null then
            begin
                nRN := gen_id();
                insert into Z_SERVLINKS_NORM(RN, JUR_PERS, VERSION, LINKRN, EXPGROUP, ORGRN, SERVRN, ACCEPT_NORM, ACCEPT_NORM2, ACCEPT_NORM3, ALIG_COEFF, REG_COEFF, CORRCOEF, CORRCOEF2, CORRCOEF3)
                                    values(nRN, pJURPERS, pVERSION, nLINKRN, nEXPGROUP, pORGRN, nSERVRN,
                                    to_number(nvl(rec.ACCEPT_NORM, '0')), to_number(nvl(rec.ACCEPT_NORM2, '0')), to_number(nvl(rec.ACCEPT_NORM3, '0')),
                                    to_number(nvl(rec.ALIG_COEFF, '1')), to_number(nvl(rec.REG_COEFF, '1')),
                                    to_number(nvl(rec.CORRCOEF, '1')), to_number(nvl(rec.CORRCOEF2, '1')), to_number(nvl(rec.CORRCOEF3, '1')));

                nCOUNT_INS := nvl(nCOUNT_INS, 0) + 1;
            exception when others then
                sERR_MSG  := 'Строка '||(rec.rownum + 1)||': Не удалось для группы: ' || rec.EXPGROUP||sqlerrm;
                nERROR := nvl(nERROR,0) + 1;
            end;
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

    sRESULT_MSG := 'Всего обработано строк файла: '|| nvl(nROWCNT,0)||'. Добавлено строк: ' || nvl(nCOUNT_INS,0) ||'. Ошибок: ' || nvl(nERROR,0) ||'.';

end;
