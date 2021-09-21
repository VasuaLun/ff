create or replace function FUNCDATAANALYZCHECK(
    p_rn in number,
    pVERSION in number,
    pJURPERS in number
)
    return boolean
as
  -----------------------------------------------
  nITEMCOL      number;
  nPLANLIMSUM   number;
  nPLANOUTSUM   number;

  type CEXPGR is record
  (
    KVR     number,
    KOSGU   number,
    DOPKOSGU varchar2(20),
    FOTYPE2 number,
    EXPMAT  number,
    KBK_RN  number,
    PLANSUM number,
    RESTSUM number,
    FACTSUM number
  );

  type TEXPGR  is table of CEXPGR index by pls_integer;
  REXPGR       TEXPGR;

begin

    -- Инициализация
    --------------------------------------------
    for rec in
    (
    select E.EXPKVR, E.KOSGURN, upper(trim(E.KOSGU)) DOPKOSGU, E.FOTYPE2, E.RN EXPMAT, SL.SERVKBK KBK_RN,
           sum(nvl(EA.SERVSUM,0) + nvl(EA.MSUM,0)) PSUM,
           sum(nvl(EA.RESTSUM,0)) RESTSUM
      from Z_EXPALL EA, Z_EXPMAT E, Z_SERVLINKS SL
     where EA.EXP_ARTICLE  = E.RN
       and EA.JUR_PERS = pJURPERS
       and EA.VERSION  = pVERSION
       and EA.ORGRN = p_rn
	   and SL.VERSION = EA.VERSION
	   and SL.ORGRN = EA.ORGRN
	   and SL.SERVRN = EA.SERVRN
       and SL.FICTIV_SERV is null
       and (nvl(EA.SERVSUM,0) > 0 or nvl(EA.MSUM,0) > 0 or nvl(EA.RESTSUM,0) > 0)
     group by E.EXPKVR, E.KOSGURN, E.FOTYPE2, E.RN, SL.SERVKBK, upper(trim(E.KOSGU))
    )
    loop
        nITEMCOL := nvl(nITEMCOL,0) + 1;
        REXPGR(nITEMCOL).KVR     := rec.EXPKVR;
        REXPGR(nITEMCOL).KOSGU   := rec.KOSGURN;
		REXPGR(nITEMCOL).DOPKOSGU := rec.DOPKOSGU;
        REXPGR(nITEMCOL).FOTYPE2 := rec.FOTYPE2;
        REXPGR(nITEMCOL).EXPMAT  := rec.EXPMAT;
		REXPGR(nITEMCOL).KBK_RN  := rec.KBK_RN;
        REXPGR(nITEMCOL).PLANSUM := rec.PSUM;
        REXPGR(nITEMCOL).RESTSUM := rec.RESTSUM;
    end loop;

    for QGR in
    (
     select *
       from Z_CTRLGR
      where JUR_PERS   = pJURPERS
	    and VERSION    = pVERSION
        and ARC_SIGN is null
	  order by NUMB, CODE
    )LOOP
		begin
    		select sum(PSUM) PSUM
    		  into nPLANLIMSUM
    		  from Z_CTRLGR_LIMITS
    		 where PRN      = QGR.RN
    		   and JUR_PERS = pJURPERS
    		   and VERSION  = pVERSION
               and ORGRN = p_rn;
		exception when others then
			nPLANLIMSUM := null;
		end;


        if  REXPGR.COUNT > 0 then
            nPLANOUTSUM := null;

            for rec in
            (
            select KVR, KOSGU, DOPKOSGU, FOTYPE2, EXPMAT, TYPESUM
              from Z_CTRLGR_DETAIL
             where JUR_PERS = pJURPERS
               and VERSION = pVERSION
               and PRN     = QGR.RN
             group by KVR, KOSGU, DOPKOSGU, FOTYPE2, EXPMAT, TYPESUM
            )
            loop
                for I in REXPGR.first..REXPGR.last
                loop
                    if (
                           ((REXPGR(I).KVR = rec.KVR and rec.KVR is not null) or (rec.KVR is null))
                       and ((REXPGR(I).KOSGU = rec.KOSGU and rec.KOSGU is not null) or (rec.KOSGU is null))
					   and ((REXPGR(I).DOPKOSGU = rec.DOPKOSGU and rec.DOPKOSGU is not null) or (rec.DOPKOSGU is null))
                       and ((REXPGR(I).FOTYPE2 = rec.FOTYPE2 and rec.FOTYPE2 is not null) or (rec.FOTYPE2 is null))
                       and ((REXPGR(I).EXPMAT = rec.EXPMAT and rec.EXPMAT is not null) or (rec.EXPMAT is null))
					   and ((REXPGR(I).KBK_RN = QGR.KBK_RN and QGR.KBK_RN is not null and REXPGR(I).KBK_RN is not null) or (QGR.KBK_RN is null))
                   ) then
						nPLANOUTSUM := nvl(nPLANOUTSUM,0) + nvl(REXPGR(I).PLANSUM,0);
                    end if;
                end loop;
            end loop;
        end if;
        nPLANLIMSUM := nvl(nPLANLIMSUM,0) - nvl(nPLANOUTSUM,0);
        if nPLANLIMSUM != 0 then return true; end if;
    end loop;
return false;
end;
