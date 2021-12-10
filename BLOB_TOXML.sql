create or replace procedure ZP_BLOB_TO_XML(
    nRN in number
)
as

cCLOB         CLOB;
vBUFFER       varchar2(32767);
bBUFF_START   pls_integer := 1;
bBUFF_END     pls_integer := 32767;
bTO_BLOB      blob;
xRES          xmltype;
GRN           number;
---------------------------------
sERRMSG varchar2(4000);

begin

    dbms_lob.createtemporary(cCLOB, TRUE);

    begin
        select ADD_DOCDATA into bTO_BLOB from tbl_attach_file where ATTACH_ID = nRN;
    exception when others then
        sERRMSG := sERRMSG || '  Не удалось найти данные файла';
        bTO_BLOB := NULL;
    end;

    if sERRMSG is null then
        for i in 1 .. ceil(dbms_lob.getlength(bTO_BLOB) / bBUFF_END) loop

            vBUFFER := utl_raw.cast_to_varchar2(dbms_lob.substr(bTO_BLOB,
                                                                  bBUFF_END,
                                                                  bBUFF_START), UTF);
            -- if vBUFFER is null then
            --     sERRMSG := sERRMSG || '  Пустой файл';
            -- end if;

            dbms_lob.writeappend(cCLOB, length(vBUFFER), vBUFFER);
            bBUFF_START := bBUFF_START + bBUFF_END;
        end loop;
    end if;



    if sERRMSG is null then
        xRES := xmltype.createxml(cCLOB);
        delete from Test_xml where PRN = nRN;
        GRN := gen_id();
        insert into Test_xml(xml_data, RN, PRN) values(xRES, GRN, nRN);
        update tbl_attach_file set STATUS = 1 where ATTACH_ID = nRN;
        -- dbms_output.put_line(xRES.getclobval());
        -- zp_exception(0, sERRMSG || 'nen');

    else
        dbms_output.put_line(sERRMSG);
    end if;
end;​
