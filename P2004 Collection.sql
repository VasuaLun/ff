declare
nGMZSUM     varchar2(200);
nSERVSUM    varchar2(200);
nSUBSSUM    varchar2(200);
nPNOSUM     varchar2(200);
nKAPINVSUM  varchar2(200);
pVERSION    number := :P1_VERSION;
pJURPERS    number := :P1_JURPERS;

begin

    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('TEST');
    for rec in (
    select nvl(O.SHORT_NAME, O.CODE) NAME, EA.ORGRN, EA.FILIAL, O.ORGTYPE, E.FOTYPE2,
    sum(EA.SERVSUM) SERVSUM,
    sum(EA.MSUM) MSUM
    from Z_EXPALL EA, Z_EXPMAT E, Z_ORGREG O
    where EA.JUR_PERS     = pJURPERS
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
        nGMZSUM     := '0';
        nSERVSUM    := '0';
        nSUBSSUM    := '0';
        nPNOSUM     := '0';
        nKAPINVSUM  := '0';
        if rec.FOTYPE2 = 4 then
            nGMZSUM  := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
            nSERVSUM := to_char(nvl(rec.SERVSUM,0));
        elsif rec.FOTYPE2 = 5 then
            nSUBSSUM := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
        elsif rec.FOTYPE2 = 1 then
            nPNOSUM := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
        elsif rec.FOTYPE2  = 6 then
            nKAPINVSUM := to_char(nvl(rec.SERVSUM,0)+nvl(rec.MSUM,0));
        end if;

        APEX_COLLECTION.ADD_MEMBER(
            p_collection_name => 'TEST',
            p_c001            => rec.NAME,
            p_c002            => TRIM(nGMZSUM),
            p_c003            => TRIM(nSERVSUM),
            p_c004            => TRIM(nSUBSSUM),
            p_c005            => TRIM(nPNOSUM),
            p_c006            => TRIM(nKAPINVSUM),
            p_n001            => rec.ORGRN,
            p_n002            => rec.FILIAL,
            p_n003            => rec.ORGTYPE);
    end loop;
end;
