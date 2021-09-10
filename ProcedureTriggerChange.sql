create or replace procedure DV_TESTTRIGG_CHANGE
as
vNAME       varchar2(4000); -- название триггера
cLINE       clob;
nCOUNT      number := 0;
vOldTEXT    varchar2(4000) := 'ZF_CHECKPRIV2';
vNewTEXT    varchar2(4000) := 'ZF_CHECKPRIV3();';
nSPOS       number := 0; -- начало искомой процедуры в body
nLPOS       number := 0; -- положение ; в body



begin

    for rec in (
        select TRIGGER_NAME NAME, DESCRIPTION, TRIGGER_BODY BODY from ALL_TRIGGERS
    )
    loop
        cLINE := to_clob(rec.BODY);
        if instr(cLINE, vOldTEXT) > 0 then
            vNAME := rec.NAME; -- присвоение текущего названия триггера

            nSPOS := instr(cLINE, vOldTEXT);
            nLPOS := instr(cLINE, ';', nSPOS);

            vOldTEXT := substr(cLINE, nSPOS, nLPOS - nSPOS + 1); -- нахождение подстроки до ;*/

            cLINE := replace(cLINE, vOldTEXT, '/*'||vOldTEXT||'*/'||chr(10)||vNewTEXT);
            dbms_output.put_line(chr(10) || vNAME || chr(10) || cLINE || chr(10));
            vOldTEXT := 'ZF_CHECKPRIV2';
            nCOUNT := nCOUNT + 1;
        end if;
    end loop;

    dbms_output.put_line(nCOUNT);
end;

/*
BEGIN
   DV_TESTTRIGG_CHANGE;
END;


execute immediate 'alter trigger '||rec.NAME||' enable';
*/
