declare
vMARK       varchar2(4000) := 'null'; -- Маркер смены поля
vSEQ        varchar2(4000) := '0'; -- номер первого элемента с определенным именем
vGMZSUM     varchar2(200);
vSERVSUM    varchar2(200);
vSUBSSUM    varchar2(200);
vPNOSUM     varchar2(200);
vKAPINVSUM  varchar2(200);
vOUTCOMESUM varchar2(200);

nORGRN      number := 0;
nFILIAL     number := 0;
nORGTYPE    number := 0;

nGMZSUM     number := 0;
nSERVSUM    number := 0;
nSUBSSUM    number := 0;
nPNOSUM     number := 0;
nKAPINVSUM  number := 0;
nINCOMESUM  number := 0;

pVERSION    number := :P1_VERSION;
pJURPERS    number := :P1_JURPERS;

begin
    -- Проверка на существование и пересоздание коллекции
    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('TEST');
    -- заполнение коллекции
    for rec in (
        select nvl(O.SHORT_NAME, O.CODE) NAME, EA.ORGRN, EA.FILIAL, O.ORGTYPE, E.FOTYPE2,
        sum(EA.SERVSUM) SERVSUM,
        sum(EA.MSUM) MSUM
        from Z_EXPALL EA, Z_EXPMAT E, Z_ORGREG O
        where EA.JUR_PERS   = pJURPERS
        and EA.VERSION      = pVERSION
        and O.JUR_PERS      = pJURPERS
        and O.VERSION       = pVERSION
        and EA.EXP_ARTICLE  = E.RN
        and EA.ORGRN        = O.RN
        and O.ORGTYPE in (0,1)
        and O.CLOSED_SIGN = 0
        and EA.VNEBUDG_SIGN = 0
        and E.FOTYPE2 in (1,4,5,6)
        group by nvl(O.SHORT_NAME, O.CODE), EA.ORGRN, EA.FILIAL, O.ORGTYPE, E.FOTYPE2
    )
    loop
        vGMZSUM     := '0';
        vSERVSUM    := '0';
        vSUBSSUM    := '0';
        vPNOSUM     := '0';
        vKAPINVSUM  := '0';

        if rec.FOTYPE2 = 4 then
            vGMZSUM  := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
            vSERVSUM := to_char(nvl(rec.SERVSUM,0));
        elsif rec.FOTYPE2 = 5 then
            vSUBSSUM := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
        elsif rec.FOTYPE2 = 1 then
            vPNOSUM := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
        elsif rec.FOTYPE2  = 6 then
            vKAPINVSUM := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
        end if;

        APEX_COLLECTION.ADD_MEMBER(
            p_collection_name => 'TEST',
            p_c001            => rec.NAME,
            p_c002            => vGMZSUM,
            p_c003            => vSERVSUM,
            p_c004            => vSUBSSUM,
            p_c005            => vPNOSUM,
            p_c006            => vKAPINVSUM,
            p_n001            => rec.ORGRN,
            p_n002            => rec.FILIAL,
            p_n003            => rec.ORGTYPE);
    end loop;

    -- сортировка коллекции перед ее оптимизацией
    APEX_COLLECTION.SORT_MEMBERS(
        p_collection_name => 'TEST',
        p_sort_on_column_number => '1');

    -- оптимизация коллекции для упращения сбора информации
    for rec in
    (
        select c001, c002, c003, c004, c005, c006, n001, n002, n003, seq_id from APEX_collections where collection_name = 'TEST' order by c001
    )
    loop
        if rec.c001 != vMARK then

            if vMARK != 'null' then
                vOUTCOMESUM := to_char(nvl(nGMZSUM, 0) + nvl(nSUBSSUM, 0) + nvl(nPNOSUM, 0) + nvl(nKAPINVSUM, 0));

                select sum(B.SUMMA) into nINCOMESUM
                from Z_ORG_BUDGDETAIL B, Z_ORGREG O, Z_INCOME I
                where B.JUR_PERS    = pJURPERS
                 and B.VERSION      = pVERSION
                 and O.JUR_PERS     = pJURPERS
                 and O.VERSION      = pVERSION
                 and B.PRN          = O.RN
                 and B.INCOME       = I.RN(+)
                 and B.TOTAL_SIGN   = 0
                 and O.ORGTYPE in (0,1)
                 and O.CLOSED_SIGN = 0
                 and nvl(I.EXCEPT_SIGN,0) = 0
                 and O.RN = nORGRN
                group by B.PRN, B.FILIAL, O.ORGTYPE;

            APEX_COLLECTION.UPDATE_MEMBER(
                p_collection_name => 'TEST',
                p_seq  => vSEQ,
                p_c001 => vMARK,
                p_c002 => to_char(nGMZSUM),
                p_c003 => to_char(nSERVSUM),
                p_c004 => to_char(nSUBSSUM),
                p_c005 => to_char(nPNOSUM),
                p_c006 => to_char(nKAPINVSUM),
                p_c007 => vOUTCOMESUM,
                p_c008 => to_char(nINCOMESUM),
                p_n001 => nORGRN,
                p_n002 => nFILIAL,
                p_n003 => nORGTYPE);
            end if;

            nORGRN     := rec.n001;
            nFILIAL    := rec.n002;
            nORGTYPE   := rec.n003;
            nGMZSUM    := to_number(rec.c002);
            nSERVSUM   := to_number(rec.c003);
            nSUBSSUM   := to_number(rec.c004);
            nPNOSUM    := to_number(rec.c005);
            nKAPINVSUM := to_number(rec.c006);

            vSEQ := rec.seq_id;
            vMARK := rec.c001;
        else
            nGMZSUM    := nGMZSUM    + to_number(rec.c002);
            nSERVSUM   := nSERVSUM   + to_number(rec.c003);
            nSUBSSUM   := nSUBSSUM   + to_number(rec.c004);
            nPNOSUM    := nPNOSUM    + to_number(rec.c005);
            nKAPINVSUM := nKAPINVSUM + to_number(rec.c006);

            APEX_COLLECTION.DELETE_MEMBER(
                p_collection_name => 'TEST',
                p_seq => rec.seq_id);
        end if;
    end loop;

    -- заполнение последнего элемента
    vOUTCOMESUM := to_char(nvl(nGMZSUM, 0) + nvl(nSUBSSUM, 0) + nvl(nPNOSUM, 0) + nvl(nKAPINVSUM, 0));

    select sum(B.SUMMA) into nINCOMESUM
    from Z_ORG_BUDGDETAIL B, Z_ORGREG O, Z_INCOME I
    where B.JUR_PERS    = pJURPERS
     and B.VERSION      = pVERSION
     and O.JUR_PERS     = pJURPERS
     and O.VERSION      = pVERSION
     and B.PRN          = O.RN
     and B.INCOME       = I.RN(+)
     and B.TOTAL_SIGN   = 0
     and O.ORGTYPE in (0,1)
     and O.CLOSED_SIGN = 0
     and nvl(I.EXCEPT_SIGN,0) = 0
     and O.RN = nORGRN
    group by B.PRN, B.FILIAL, O.ORGTYPE;

    APEX_COLLECTION.UPDATE_MEMBER(
        p_collection_name => 'TEST',
        p_seq  => vSEQ,
        p_c001 => vMARK,
        p_c002 => to_char(nGMZSUM),
        p_c003 => to_char(nSERVSUM),
        p_c004 => to_char(nSUBSSUM),
        p_c005 => to_char(nPNOSUM),
        p_c006 => to_char(nKAPINVSUM),
        p_c007 => vOUTCOMESUM,
        p_c008 => to_char(nINCOMESUM),
        p_n001 => nORGRN,
        p_n002 => nFILIAL,
        p_n003 => nORGTYPE);

end;
