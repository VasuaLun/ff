--210; 3;
declare
    pMESSRN           number := :P3_MESS_RN;

    sTYPE	      varchar2(4000);
    sSTATUS       varchar2(4000);
    sJURPERS      varchar2(4000);
    -----------------------------------------------
    nCOUNTROWS    number;
    -----------------------------------------------
    sColor        varchar2(100);
    sMSG	      varchar2(250);

begin

    for STEP in
    (
        select *
        from M_MESSAGES
        where (pRN = pMESSRN or RN = pMESSRN)
        order by prn nulls first, rn
    )
    loop
        nCOUNTROWS := nvl(nCOUNTROWS, 0) + 1;

        if (nCOUNTROWS = 1) then
            begin
                select NAME 
                into sJURPERS
                from Z_JURPERS
                where rn = STEP.JURPERS;
            exception when no_data_found then
                sJURPERS := null;
            end;
            sJURPERS := 'ГРБС: '||sJURPERS||';';
            sSTATUS  := '  Статус: <span style="color:'||(pSTATUS => STEP.STATUS, pTYPE => 1)||'">'||MF_GETSTATUS_NAME(pSTATUS => STEP.STATUS)||'</span>;';
            sTYPE    := '  Вид решения: '||'Вид решения;';
            htp.p('<div style="float: right;"><span style="font-weight: bold;">'||sJURPERS
                                                                                ||sSTATUS
                                                                                ||sTYPE||
                  '</span></div><br><br>');
        end if;

        htp.p('<div style="border-top: 1px solid #B2B2B2; padding-bottom: 5px; '||case when ZGET_ROLE = STEP.ROLE_FROM then 'padding-left: 200px;' end||'" class="message-item">');
        htp.p('<div style="margin: 0; padding: 7px 10px 10px 20px;">'
        || '<b>' || 'Роль' || '</b> - ' || ZGET_ROLE_NAME(STEP.ROLE_FROM) || ' : '||'<span style="font-weight: bold; color:red">'||'Имя автора'||'</span>'
        || '<span style="font-weight: normal; font-size: 20px; margin: 4px 4px 0px 4px;">&rArr;</span>'
        || ZF_USER_NAME(STEP.USER_AUTHOR, 1) || '<span style="float: right; font-weight: bold;">'
        || TO_CHAR(STEP.date_create, 'dd.mm.yyyy HH24:MI') ||'</span></div>');
        htp.p('<div class="message-text">' || STEP.message_text || '</div>');

    htp.p('<div class="attach_list" style="margin: 0 0 4px 18px;"><ul style="padding-left: 10px; margin: 0 0 0 10px; border-left: 1px solid #AAAAAA;">');

        htp.p('</ul></div></div>');
        htp.p('');
    end loop;    
end;
