DECLARE
  json_output json;
  ------------------------

  nParent_row   NUMBER(17);
  sValue        varchar2(4000);
  sValueRow     varchar2(4000);
  sField_name   varchar2(4000);
  nRn          	number(17);
  nPeriod 		number(1);
  sStrValue 	varchar2(4000);

  nKVR1   		number(17) := null;
  nFO1    		number(17) := null;
  nKOSGU1 		number(17) := null;
BEGIN
	json_output := json;

	nRn		:= apex_application.g_x01;
	sValueRow := to_number(replace(apex_application.g_x02,' '));
	sValue	:= replace(apex_application.g_x02,' ');
    sField_name := apex_application.g_x03;

    if sField_name = 'ACCEPT_NORM1' then
        update Z_SERVLINKS_NORM  set ACCEPT_NORM = sValueRow where RN = nRN;
    elsif sField_name = 'ACCEPT_NORM2' then
        update Z_SERVLINKS_NORM  set ACCEPT_NORM2 = sValueRow where RN = nRN;
    elsif sField_name = 'ACCEPT_NORM3' then
        update Z_SERVLINKS_NORM  set ACCEPT_NORM3 = sValueRow where RN = nRN;
    elsif sField_name = 'CORRCOEF1' then
        update Z_SERVLINKS_NORM  set CORRCOEF = sValueRow where RN = nRN;
    elsif sField_name = 'CORRCOEF2' then
        update Z_SERVLINKS_NORM  set CORRCOEF2 = sValueRow where RN = nRN;
    elsif sField_name = 'CORRCOEF3' then
        update Z_SERVLINKS_NORM  set CORRCOEF3 = sValueRow where RN = nRN;
    elsif sField_name = 'REG_COEFF' then
        update Z_SERVLINKS_NORM  set REG_COEFF = sValueRow where RN = nRN;
    elsif sField_name = 'ALIG_COEFF' then
        update Z_SERVLINKS_NORM  set ALIG_COEFF = sValueRow where RN = nRN;
    end if;

    select

    json_output.put('status','good');
    json_output.put('message','Запись изменена.');
    json_output.htp;


  EXCEPTION
    WHEN others THEN
  begin
     json_output.put('status','error');
     json_output.put('message','Внимание!!! Произошла ошибка сохранения данных! <br> '||SQLERRM);
     json_output.htp;
    end;

  --
 END;
