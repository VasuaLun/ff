declare
vMARK       varchar2(4000) := 'null'; -- Маркер смены поля
vSEQ        varchar2(4000) := '0'; -- номер первого элемента с определенным именем
vGMZSUM     varchar2(200);
vSERVSUM    varchar2(200);
vSUBSSUM    varchar2(200);
vPNOSUM     varchar2(200);
vKAPINVSUM  varchar2(200);
vOUTCOMESUM varchar2(200);
vDIFF       varchar2(200);

vORGRN      varchar2(200);
vFILIAL     varchar2(200);
vORGTYPE    varchar2(200);

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
        nGMZSUM     := 0;
        nSERVSUM    := 0;
        nSUBSSUM    := 0;
        nPNOSUM     := 0;
        nKAPINVSUM  := 0;

        if rec.FOTYPE2 = 4 then
            nGMZSUM  := nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0);
            nSERVSUM := nvl(rec.SERVSUM,0);
        elsif rec.FOTYPE2 = 5 then
            nSUBSSUM := nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0);
        elsif rec.FOTYPE2 = 1 then
            nPNOSUM := nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0);
        elsif rec.FOTYPE2  = 6 then
            nKAPINVSUM := nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0);
        end if;

        APEX_COLLECTION.ADD_MEMBER(
            p_collection_name => 'TEST',
            p_c001            => rec.NAME,
            p_c002            => to_char(rec.ORGRN),
            p_c003            => to_char(rec.FILIAL),
            p_c004            => to_char(rec.ORGTYPE),
            p_n001            => nGMZSUM,
            p_n002            => nSERVSUM,
            p_n003            => nSUBSSUM,
            p_n004            => nPNOSUM,
            p_n005            => nKAPINVSUM);
    end loop;

    -- сортировка коллекции перед ее оптимизацией
    APEX_COLLECTION.SORT_MEMBERS(
        p_collection_name => 'TEST',
        p_sort_on_column_number => '1');

    -- оптимизация коллекции для упращения сбора информации
    for rec in
    (
        select c001, c002, c003, c004, n001, n002, n003, n004, n005, seq_id from APEX_collections where collection_name = 'TEST' order by c001
    )
    loop
        if rec.c001 != vMARK then

            if vMARK != 'null' then

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
                 and O.RN = to_number(vORGRN)
                group by B.PRN, B.FILIAL, O.ORGTYPE;

            APEX_COLLECTION.UPDATE_MEMBER(
                p_collection_name => 'TEST',
                p_seq  => vSEQ,
                p_c001 => vMARK,
                p_c002 => vORGRN,
                p_c003 => vFILIAL,
                p_c004 => vORGTYPE,
                p_n001 => nGMZSUM,
                p_n002 => nSERVSUM,
                p_n003 => nSUBSSUM,
                p_n004 => nPNOSUM,
                p_n005 => nKAPINVSUM);
            end if;

            vORGRN     := rec.c002;
            vFILIAL    := rec.c003;
            vORGTYPE   := rec.c004;
            nGMZSUM    := rec.n001;
            nSERVSUM   := rec.n002;
            nSUBSSUM   := rec.n003;
            nPNOSUM    := rec.n004;
            nKAPINVSUM := rec.n005;

            vSEQ := rec.seq_id;
            vMARK := rec.c001;
        else
            nGMZSUM    := nGMZSUM    + rec.n001;
            nSERVSUM   := nSERVSUM   + rec.n002;
            nSUBSSUM   := nSUBSSUM   + rec.n003;
            nPNOSUM    := nPNOSUM    + rec.n004;
            nKAPINVSUM := nKAPINVSUM + rec.n005;

            APEX_COLLECTION.DELETE_MEMBER(
                p_collection_name => 'TEST',
                p_seq => rec.seq_id);
        end if;
    end loop;

    -- заполнение последнего элемента
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
     and O.RN = to_number(vORGRN)
    group by B.PRN, B.FILIAL, O.ORGTYPE;

    APEX_COLLECTION.UPDATE_MEMBER(
        p_collection_name => 'TEST',
        p_seq  => vSEQ,
        p_c001 => vMARK,
        p_c002 => vORGRN,
        p_c003 => vFILIAL,
        p_c004 => vORGTYPE,
        p_n001 => nGMZSUM,
        p_n002 => nSERVSUM,
        p_n003 => nSUBSSUM,
        p_n004 => nPNOSUM,
        p_n005 => nKAPINVSUM);
end;
