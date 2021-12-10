declare
  pVersion	number := :P1_VERSION;
  pORGRN	number := :P1214_ORGRN;

  pKVR		number := :P1214_KVR;
  pKOSGU	number := :P1214_KOSGU;
  pFOTYPE	number := :P1214_FOTYPE2;
  pKBK		number := :P1214_KBK;
  pRES          number;

begin
    -- Очередной год
	pRES := ZF_CALC_AVAILIBLE_CASH (pVERSION, pORGRN, pKVR, pKOSGU, pFOTYPE, pKBK);
        if nvl(pRES, 0) > 0 then
             :P1214_AVAILIBLE_REST_COLOR := 'green';
        else
             :P1214_AVAILIBLE_REST_COLOR := 'red';
        end if;

	:P1214_AVAILIBLE_REST := to_char(nvl(pRES, 0), '999G999G999G999G990D00');

    -- План 1
    pRES := ZF_CALC_AVAILIBLE_CASH (pVERSION, pORGRN, pKVR, pKOSGU, pFOTYPE, pKBK, 2);
        if nvl(pRES, 0) > 0 then
             :P1214_AVAILIBLE_PLAN1_COLOR := 'green';
        else
             :P1214_AVAILIBLE_PLAN1_COLOR := 'red';
        end if;

    :P1214_AVAILIBLE_PLAN1 := to_char(nvl(pRES, 0), '999G999G999G999G990D00');

    -- План 2
    pRES := ZF_CALC_AVAILIBLE_CASH (pVERSION, pORGRN, pKVR, pKOSGU, pFOTYPE, pKBK, 3);
        if nvl(pRES, 0) > 0 then
             :P1214_AVAILIBLE_PLAN2_COLOR := 'green';
        else
             :P1214_AVAILIBLE_PLAN2_COLOR := 'red';
        end if;

    :P1214_AVAILIBLE_PLAN2 := to_char(nvl(pRES, 0), '999G999G999G999G990D00');

exception when others then
	:P1214_AVAILIBLE_REST := 0;
    :P1214_AVAILIBLE_PLAN1 := 0;
    :P1214_AVAILIBLE_PLAN2 := 0;
	:P1214_AVAILIBLE_REST_COLOR := 'red';
    :P1214_AVAILIBLE_PLAN1_COLOR := 'red';
    :P1214_AVAILIBLE_PLAN2_COLOR := 'red';
--zp_exception(0, 'ERR CALC = '||:P1214_AVAILIBLE_REST||' '||sqlerrm);
end;




$('#P1214_AVAILIBLE_REST').closest('td').show();
$('#P1214_AVAILIBLE_REST').css('color', $v("P1214_AVAILIBLE_REST_COLOR"));
console.log($v("P1214_AVAILIBLE_REST_COLOR"));

$('#P1214_AVAILIBLE_PLAN1').closest('td').show();
$('#P1214_AVAILIBLE_PLAN1').css('color', $v("P1214_AVAILIBLE_PLAN1_COLOR"));
console.log($v("P1214_AVAILIBLE_PLAN1_COLOR"));

$('#P1214_AVAILIBLE_PLAN2').closest('td').show();
$('#P1214_AVAILIBLE_PLAN2').css('color', $v("P1214_AVAILIBLE_PLAN2_COLOR"));
console.log($v("P1214_AVAILIBLE_PLAN2_COLOR"));
/*if($v("P1214_AVAILIBLE_REST") == ''){
      $('#P1214_AVAILIBLE_REST').closest('td').hide();}
else
   {
      $('#P1214_AVAILIBLE_REST').closest('td').show();
}*/
