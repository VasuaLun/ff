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

    -- создание буфера clob
    dbms_lob.createtemporary(cCLOB, TRUE);

    -- забираем blob файла из БД
    begin
        select ADD_DOCDATA into bTO_BLOB from tbl_attach_file where ATTACH_ID = nRN;
    exception when others then
        sERRMSG := sERRMSG || '  Не удалось найти данные файла';
        bTO_BLOB := NULL;
    end;

    if sERRMSG is null then
        -- преобразовываем файл из BLOB в VARCHAR2
        for i in 1 .. ceil(dbms_lob.getlength(bTO_BLOB) / bBUFF_END) loop

            vBUFFER := utl_raw.cast_to_varchar2(dbms_lob.substr(bTO_BLOB,
                                                                  bBUFF_END,
                                                                  bBUFF_START));
            -- если буфер не пустой меняем кодировку с системной на UTB8, которая используется на bus gov
            if vBUFFER is not null then
                begin
                    vBUFFER := convert (vBUFFER,'CL8MSWIN1251', 'AL32UTF8');
                exception when others then
                    sERRMSG := sERRMSG || ' Ошибка в кодировке файла';
                    zp_exception(0, 'Ошибка в кодировке файла');
                end;
            end if;

            -- перевод varchar2 в clob
            dbms_lob.writeappend(cCLOB, length(vBUFFER), vBUFFER);
            bBUFF_START := bBUFF_START + bBUFF_END;

        end loop;
    end if;

    -- перевод clob в xmltype, запись его в БД
    if sERRMSG is null then
        xRES := xmltype.createxml(cCLOB);
        delete from Test_xml where PRN = nRN;
        GRN := gen_id();
        insert into Test_xml(xml_data, RN, PRN) values(xRES, GRN, nRN);
        update tbl_attach_file set STATUS = 1 where ATTACH_ID = nRN;
    else
        dbms_output.put_line(sERRMSG);
    end if;
end;
​
