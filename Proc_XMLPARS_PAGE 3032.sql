declare
PRN number := :P3032_PRN;
Begin
    ZP_BLOB_TO_XML(PRN);
    ZP_XML_PARSING(PRN);
end;
