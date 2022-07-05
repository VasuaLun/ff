declare
    nPRN       number := :P4_MESS_PRN;
    nTYPE      number;
    nROLE_FROM number;
    nROLE_TO   number;
    nCOMPANY   number;
    nJURPERS   number;
begin
    begin
        select JURPERS, AORG, TICKETTYPE, ROLE_FROM, ROLE_TO
        into nJURPERS, nCOMPANY, nTYPE, nROLE_FROM, nROLE_TO
        from M_MESSAGES 
        where RN = nPRN;
    exception when others then
        nJURPERS   := null;
        nCOMPANY   := null;
        nTYPE      := null;
        nROLE_FROM := null;
        nROLE_TO   := null;
    end;

    :P4_JURPERS    := nJURPERS;
    :P4_COMPANY_TO := nCOMPANY;
    :P4_TYPE       := nTYPE;

    if nROLE_FROM != ZGET_ROLE then 
        :P4_ROLE       := nROLE_FROM;
    else
        :P4_ROLE       := nROLE_TO;
    end if;
end;

javascript:apex.confirm("отправить сообщение?", {
       request:"pSENT",
       set:{ "P4_END":null}});