create or replace procedure XML_FACRCOSTS(
    nRN         in number,
    sRESULT_MSG out varchar2(4000);
)
as
    nCOUNTROW   number;
    sERR_MSG     varchar2(4000);
    -- pVERSION    number(17):= v('P1_VERSION');
    pVERSION := 343567920;
    sRESULT_MSG varchar2(4000);
    nERROR      number;

    pORGRN      number;
    pFOTYPE2    number;
    pCODE       number;
    pFUND       number;
    pEXPFKR     number;
    pRN         number;

begin

    select COUNT(*)
        into nCOUNTROW
    from XML_EXP1
    where XMLDOCRN = nRN;

    for rec in
    (
        select *
        from XML_EXP1
        where XMLDOCRN = RN
    )
    loop
        if rec.VERSION is NULL then
            sERR_MSG  := 'Строка: '||rec.rownum||', не задана версия в файле';
        end if;

        if rec.INN is NULL then
            sERR_MSG  := 'Строка: '||rec.rownum||', не задан ИНН учреждения';
        end if;

        if rec.FOTYPE2 is NULL then
            sERR_MSG  := 'Строка: '||rec.rownum||', не задан вид финансового обеспечения';
        end if;

        if rec.KVR is NULL then
            sERR_MSG  := 'Строка: '||rec.rownum||', не задан КВР';
        end if;

        if rec.KOSGU is NULL then
            sERR_MSG  := 'Строка: '||rec.rownum||', не задан КОСГУ';
        end if;

        if sERR_MSG is null then
            begin
                select RN into pORGRN
                  from Z_ORGREG
                 where version = pVERSION
                   and INN = trim(rec.INN);
            exception when others then
                sERR_MSG  := 'Строка: '||rec.rownum||', не найдена организация по ИНН: ' || rec.INN;
                nERROR := nvl(nERROR,0) + 1;
                pORGRN := null;
            end;
        end if;

        if sERR_MSG is null then
            begin
                select RN into pFOTYPE2
                from Z_FOTYPE
                where VERSION = 343567920
                    and CODE = trim(rec.TypeFO);
            exception when others then
                sERR_MSG  := 'Строка: '||rec.rownum||', не найден вид финансового обеспечения: ' || rec.TypeFO;
                nERROR := nvl(nERROR,0) + 1;
                pFOTYPE2 := null;
            end;
        end if;

        if sERR_MSG is null and rec.CODE is not null then
            begin
                select RN into pFUND
                from Z_FUNDS
                where VERSION = 343567920
                    and CODE = trim(rec.CODE);
            exception when others then
                sERR_MSG  := 'Строка: '||rec.rownum||', не найдена целевая статья в данной версии: ' || rec.CODE;
                nERROR := nvl(nERROR,0) + 1;
                pFUND := null;
            end;
        end if;

        if sERR_MSG is null and rec.PRECODE is not null and rec.PARTCODE is not null then
            begin
                select RN into pEXPFKR
                from Z_EXPFKR
                where NUMB = trim(rec.PRECODE) || trim(rec.PARTCODE);
            exception when others then
                sERR_MSG  := 'Строка: '||rec.rownum||', не найдена функциональная классификация расходов: ' || rec.PRECODE || rec.PARTCODE;
                nERROR := nvl(nERROR,0) + 1;
                pEXPFKR := null;
            end;
        end if;

        -- Заполнение таблицы
        if sERR_MSG is null and rec.PRECODE is not null and rec.PARTCODE is not null then
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

    sRESULT_MSG := 'Всего обработано строк файла: '|| nvl(nROWCNT,0)||'. Добавлено строк: ' || nvl(nCOUNT_INS,0) ||'. Ошибок: ' || nvl(nERROR,0) ||'.';
    end loop;
end;
