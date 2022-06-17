create or replace procedure ZP_EB852_XML
(
 pJURPERS  number,
 pVERSION  number,
 pORGRN    number,
 pFILIAL   number,
 pKVR      number,
 pFILENAME varchar
)
as
    --------------------------------------------------------
    --Таблица ID="ОПП"    
    --Таблица ID="АналитическоеРаспределениеКОСГУ"
    --Таблица ID="ФинОбеспечение"
    --Таблица ID="ВодныйНалог"
    --Таблица ID="ВодныйНалогСуб"    
    --Таблица ID="НалогИсклЗаборВоды"
    --Таблица ID="НалогИсклЗаборВодыСуб"
    --Таблица ID="ТранспортныйНалог"
    --Таблица ID="ТранспортныйНалогСуб"
    --Таблица ID="ИныеНалогиСборы"
    --Таблица ID="ГосПошлина"
    --Таблица ID="РасходыУплатыНалогов"
        
    --------------------------------------------------------
    F1             UTL_FILE.FILE_TYPE;
    sDIRECTORY     varchar2(100):= 'XML_FILES';
    nNUMB          number;
    nOTHERSIGN     number;
    nSTRNUM        number;    
    nFL            number := 0;    
 
    nTOTAL         number;
    nTOTAL_1       number;
    nTOTAL_2       number;
    nTOTAL_3       number;
    nTOTAL_90      number;
    nTOTAL_90_1    number;
    nTOTAL_90_2    number;
    nTOTAL_DET     number;
    nTOTAL_DET_1   number;
    nTOTAL_DET_2   number;
    
    nBASE_SIZE     number;
    nBASE_SIZE_1   number;
    nBASE_SIZE_2   number;
    nSTRCODE       number;
    sINNERTAG      CLOB;
    sTAG           CLOB;
    
    nNEXT_PERIOD number;
    nPLAN1         number;
    nPLAN2         number;
 
    nCOUNTCOL      number;
    sGUID          varchar2(100);
 
    type t_rec is RECORD (
        RN         number,        
        GUID       varchar2(100),
 
        LIC_DATE   DATE,
        LIC_NUM    VARCHAR2(100),
        PURPOSE    VARCHAR2(1000),
        AGR_DATE     DATE,
        AGR_NUMB   VARCHAR2(50),
        WATERCODE  number,
        
        WATER_LIMIT   number,
        WATER_LIMIT_1 number,
        WATER_LIMIT_2 number,
 
        WATER_VALUE  number,
        WATER_VALUE_1 number,
        WATER_VALUE_2 number,
 
        WATER_OVERLIMIT number,
        WATER_OVERLIMIT_1 number,
        WATER_OVERLIMIT_2 number,
 
        WATER_STAVKA number,
        WATER_STAVKA_1 number,
        WATER_STAVKA_2 number,
 
        WATER_OVER_STAVKA number,
        WATER_OVER_STAVKA_1 number,
        WATER_OVER_STAVKA_2 number,
 
        WATER_KOEFF number,
        WATER_KOEFF_1 number,
        WATER_KOEFF_2 number,
 
        WATER_KOEFF_LESS number,
        WATER_KOEFF_LESS_1 number,
        WATER_KOEFF_LESS_2 number,
 
        WATER_KOEFF_LAND number,
        WATER_KOEFF_LAND_1 number,
        WATER_KOEFF_LAND_2 number,
 
        WATER2_SQUARE   number,
        WATER2_SQUARE_1 number,
        WATER2_SQUARE_2 number,           
 
        WATER2_ENERGY number,
        WATER2_ENERGY_1 number,
        WATER2_ENERGY_2 number,
 
        WATER2_WOOD number,
        WATER2_WOOD_1 number,
        WATER2_WOOD_2 number,
 
        WATER2_DIST number,
        WATER2_DIST_1 number,
        WATER2_DIST_2 number,
 
        WATER2_STAVKA number,
        WATER2_STAVKA_1 number,
        WATER2_STAVKA_2 number,
 
        WATER2_KOEFF number,
        WATER2_KOEFF_1 number,
        WATER2_KOEFF_2 number,
 
        TRANS_BASE number,
        TRANS_BASE_1 number,
        TRANS_BASE_2 number,
        TRANS_MONTH_COUNT number,
        TRANS_MONTH_COUNT_1 number,
        TRANS_MONTH_COUNT_2 number,
        TRANS_KOEFF number,
        TRANS_KOEFF_1 number,
        TRANS_KOEFF_2 number,
        TRANS_SHARE number,
        TRANS_SHARE_1 number,
        TRANS_SHARE_2 number,
        TRANS_STAVKA number,
        TRANS_STAVKA_1 number,
        TRANS_STAVKA_2 number,
        TRANS_UP_KOEFF number,
        TRANS_UP_KOEFF_1 number,
        TRANS_UP_KOEFF_2 number,
        TRANS_LMONTH number,
        TRANS_LMONTH_1 number,
        TRANS_LMONTH_2 number,
        TRANS_LKOEFF number,
        TRANS_LKOEFF_1 number,
        TRANS_LKOEFF_2 number,
        TRANS_LCODE varchar2(1000),
        TRANS_LSUM number,
        TRANS_LSUM_1 number,
        TRANS_LSUM_2 number,
        TRANS_LCODE_DN varchar2(1000),
        TRANS_LSUM_DN number,
        TRANS_LSUM_DN_1 number,
        TRANS_LSUM_DN_2 number,
        TRANS_LCODE_W varchar2(1000),
        TRANS_LSUM_W number,
        TRANS_LSUM_W_1 number,
        TRANS_LSUM_W_2 number,
        TRANS_DEDCODE varchar2(1000),
        TRANS_DEDSUM number,
        TRANS_DEDSUM_1 number,
        TRANS_DEDSUM_2 number
    );                                          
    
    type t_arr is table of t_rec index by PLS_INTEGER;
    AA_STR     t_arr;    
 
    function T
    return varchar2 as
    begin
      return chr(009);
    end;
    procedure prnt(p_file in UTL_FILE.FILE_TYPE, pString in varchar2)
    as
       
    begin
       UTL_FILE.PUT_LINE(p_file,pString);
    end;
    
    procedure PRINT_ORG_GRBS_INFO
    as
    begin
       for QORG in (
        select O.CODE, O.NAME, FL.UBP, J.GLAVA_CODE
          from Z_ORGREG O, Z_JURPERS J, Z_ORGFL FL
          where O.RN =  pORGRN
           and O.JUR_PERS = J.RN
           and O.RN = FL.ORGRN
           and (FL.RN = pFILIAL or pFILIAL is null)
        )
        loop
            prnt(F1,'<c ID="PbsName">'||QORG.CODE ||'</c>');
            prnt(F1,'<c ID="PbsCode">'||QORG.UBP||'</c>');
            prnt(F1,'<c ID="PppName">'||QORG.NAME ||'</c>');
            prnt(F1,'<c ID="PppCode">'||QORG.GLAVA_CODE ||'</c>');
        end loop;
    end;
begin
    begin
        select NEXT_PERIOD, PLAN1, PLAN2
        into nNEXT_PERIOD, nPLAN1, nPLAN2
         from Z_VERSIONS
         where RN = pVERSION;
    exception when others then
        nNEXT_PERIOD := null;
        nPLAN1 := null;
        nPLAN2 := null;
    end;    
           
 
    F1 := UTL_FILE.FOPEN(sDIRECTORY, ''||nvl(pFILENAME, 'EB_EXPORT')||'.xml','w',32767);
    prnt(F1,'<?xml version="1.0" encoding="windows-1251"?>');
 
    /*-------------------------------------------------  КВР 852  -------------------------------------------------------*/        
    
    prnt(F1,'<Форма ID="ОППВ_08_852">');
    
    PRINT_ORG_GRBS_INFO;
 
    
    -- Таблица ID="ОПП"
    --------------------------------------------------------    
    sINNERTAG := null;
    sTAG      := null;
    nTOTAL_90 := null;
    nTOTAL_90_1 := null;
    nTOTAL_90_2 := null;
    
    for rec in
    (
     select OD.RN STR_RN, OSTR.CODE STRCODE, OD.NAME OUTCOME_NAME
       from Z_JUSTIFY_DICT OD, Z_JUSTIFY_STRCODE OSTR, Z_JUSTIFY_FORMCODE OFORM
      where OD.STR_RN  = OSTR.RN
        and OD.FORM_RN = OFORM.RN
        and OFORM.PART = 'OTHER_TAX_852_1'
      order by OSTR.CODE, OD.NAME
    )
    loop
        begin
            select sum(D.TOTAL), sum(D.TOTAL_1), sum(D.TOTAL_2)
              into nTOTAL, nTOTAL_1, nTOTAL_2
              from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D
             where T.JURPERS   = pJURPERS
               and T.VERSION   = pVersion
               and T.ORGRN     = pOrgRn
               and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
               and D.PRN       = T.RN
               and T.TAX_TYPE in (select PAYMENT_TYPE_RN
                                    from Z_JUSTIFY_PAY_STR_LINKS PSL
                                   where VERSION = pVersion
                                     and STR_RN = rec.STR_RN)
               and D.KVR = (select RN
                              from Z_EXPKVR_ALL
                             where CODE = '852');
        exception when others then
            nTOTAL := null;
            nTOTAL_1 := null;
            nTOTAL_2 := null;
        end;       
        sINNERTAG := sINNERTAG||'<a ID="'||RTRIM(rec.STRCODE, '0') ||'" '||case when COALESCE( nTOTAL, nTOTAL_1, nTOTAL_2 ) is not null then 'b2="'||nvl(nTOTAL, 0)||'" b3="'||nvl(nTOTAL_1, 0)||'" b4="'||nvl(nTOTAL_2, 0) ||'"' end ||'/>'||CHR(10);
   
        nTOTAL_90 := nvl(nTOTAL_90, 0) + (case when RTRIM(rec.STRCODE, '0') in ('01', '03', '05') then nvl(nTOTAL, 0)
                                               when RTRIM(rec.STRCODE, '0') in ('02', '04') then -nvl(nTOTAL, 0)
                                               else 0 end );
        nTOTAL_90_1 := nvl(nTOTAL_90_1, 0) + (case when RTRIM(rec.STRCODE, '0') in ('01', '03', '05') then nvl(nTOTAL_1, 0)
                                                   when RTRIM(rec.STRCODE, '0') in ('02', '04') then -nvl(nTOTAL_1, 0)
                                                   else 0 end );                                       
                                                   
        nTOTAL_90_2 := nvl(nTOTAL_90_2, 0) + (case when RTRIM(rec.STRCODE, '0') in ('01', '03', '05') then nvl(nTOTAL_2, 0)
                                                   when RTRIM(rec.STRCODE, '0') in ('02', '04') then -nvl(nTOTAL_2, 0)
                                                   else 0 end );                                                                                  
    end loop;
    
    if COALESCE( nTOTAL_90, nTOTAL_90_1, nTOTAL_90_2 ) is not null then
        sINNERTAG := sINNERTAG||'<a ID="'||'90'||
                                    '" b2="'||trim(to_char( nvl(nTOTAL_90, 0), '99999999999999990.99'))||
                                    '" b3="'||trim(to_char( nvl(nTOTAL_90_1, 0), '99999999999999990.99'))||
                                    '" b4="'||trim(to_char( nvl(nTOTAL_90_2, 0), '99999999999999990.99')) ||
                                '"/>'||CHR(10);
    end if;
 
    begin
        select sum(D.TOTAL), sum(D.TOTAL_1), sum(D.TOTAL_2)
          into nTOTAL_DET, nTOTAL_DET_1, nTOTAL_DET_2
          from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D, X_JLOV J
         where T.JURPERS   = pJURPERS
           and T.VERSION   = pVersion
           and T.ORGRN     = pOrgRn
           and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
           and T.RN        = D.PRN
 
           and J.PART      = 'TAX_TYPE'
           and T.TAX_TYPE  = J.RN
           and J.NO_INCLUDE is null
           and D.KVR       = (select RN
                                from Z_EXPKVR_ALL
                               where CODE = '852');
    exception when others then
        nTOTAL_DET   := null;
        nTOTAL_DET_1 := null;
        nTOTAL_DET_2 := null;
    end;
 
    if nvl(nTOTAL_DET,0) != nvl(nTOTAL_90,0) then
        ZP_EXCEPTION (0, 'По квр 852 имеются расхождения - Очередной год. Настройка: - ' || trim(to_char(nvl(nTOTAL_DET,0), '999G999G999G999G999G990D00'))||' руб.,' ||
                                                                            trim(to_char(nvl(nTOTAL_90,0), '999G999G999G999G999G990D00'))||' руб.' );
    end if;
 
    if nvl(nTOTAL_DET_1,0) != nvl(nTOTAL_90_1,0) then
        ZP_EXCEPTION (0, 'По квр 852 имеются расхождения - План 1 года. Настройка: - ' || trim(to_char(nvl(nTOTAL_DET_1,0), '999G999G999G999G999G990D00'))||' руб.,' ||
                                                                            trim(to_char(nvl(nTOTAL_90_1,0), '999G999G999G999G999G990D00'))||' руб.' );
    end if;
 
    if nvl(nTOTAL_DET_2,0) != nvl(nTOTAL_90_2,0) then
        ZP_EXCEPTION (0, 'По квр 852 имеются расхождения - План 2 года. Настройка: - ' || trim(to_char(nvl(nTOTAL_DET_2,0), '999G999G999G999G999G990D00'))||' руб.,' ||
                                                                            trim(to_char(nvl(nTOTAL_90_2,0), '999G999G999G999G999G990D00'))||' руб.' );
    end if;
        
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="ОПП">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="ОПП" />';   
    end if;
    
    prnt(F1,sTAG);            
    
    -- Таблица ID="АналитическоеРаспределениеКОСГУ"
    --------------------------------------------------------
    sINNERTAG := null;
    sTAG      := null;
    nSTRCODE := null;
    for rec in
    (
     select K.NAME KOSGUNAME, K.CODE KOSGUCODE,            
            sum(D.TOTAL) TOTAL, sum(D.TOTAL_1) TOTAL_1, sum(D.TOTAL_2) TOTAL_2
       from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D, Z_KOSGU K
       where T.JURPERS   = pJURPERS
         and T.VERSION   = pVersion
         and T.ORGRN     = pOrgRn
         and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
         and D.PRN       = T.RN
         and D.KOSGU     = K.RN
         and T.TAX_TYPE in (select distinct PAYMENT_TYPE_RN
                              from Z_JUSTIFY_PAY_STR_LINKS PSL, Z_JUSTIFY_DICT JOD, Z_JUSTIFY_FORMCODE JOF
                             where VERSION     = pVERSION
                               and PSL.STR_RN  = JOD.RN
                               and JOD.FORM_RN = JOF.RN
                               and JOF.PART = 'OTHER_TAX_852_3')
         and D.KVR = (select RN  
                        from Z_EXPKVR_ALL
                       where CODE = '852')
     group by K.NAME, K.CODE
     order by K.CODE
    )
    loop
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        sINNERTAG := sINNERTAG||'<a ID="'||(nSTRCODE - 1) ||
                                    '" bROWCODE="'||lpad(nSTRCODE||'00',4,0)||
                                    '" b4="'||trim(to_char( nvl(rec.TOTAL, 0), '99999999999999990.99'))||
                                    '" b5="'||trim(to_char( nvl(rec.TOTAL_1, 0), '99999999999999990.99'))||
                                    '" b6="'||trim(to_char( nvl(rec.TOTAL_2, 0), '99999999999999990.99'))||
                                '"/>'||CHR(10);    
    end loop;
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="АналитическоеРаспределениеКОСГУ">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="АналитическоеРаспределениеКОСГУ" />';    
    end if;
    
    prnt(F1, sTAG);
 
 
    -- Таблица ID="РасходыУплатыНалогов"
    --------------------------------------------------------
    sINNERTAG   := null;
    sTAG        := null;
    nSTRCODE    := null;
    nTOTAL_90   := null;
    nTOTAL_90_1 := null;
    nTOTAL_90_2 := null;
 
    for rec in
    (
     select OD.RN STR_RN, OSTR.CODE STRCODE, OD.NAME OUTCOME_NAME
       from Z_JUSTIFY_DICT OD, Z_JUSTIFY_STRCODE OSTR, Z_JUSTIFY_FORMCODE OFORM
      where OD.STR_RN  = OSTR.RN
        and OD.FORM_RN = OFORM.RN
        and OFORM.PART = 'OTHER_TAX_852_2'
      order by OSTR.CODE, OD.NAME
    )
    loop
 
        begin
            select sum(D.TOTAL), sum(D.TOTAL_1), sum(D.TOTAL_2)
              into nTOTAL, nTOTAL_1, nTOTAL_2
              from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D
             where T.JURPERS   = pJURPERS
               and T.VERSION   = pVersion
               and T.ORGRN     = pOrgRn
               and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
               and D.PRN       = T.RN
               and T.TAX_TYPE in (select PAYMENT_TYPE_RN
                                    from Z_JUSTIFY_PAY_STR_LINKS PSL
                                   where VERSION = pVersion
                                     and STR_RN = rec.STR_RN)
               and D.KVR = (select RN
                              from Z_EXPKVR_ALL
                             where CODE = '852');
        exception when others then
            nTOTAL := null;
            nTOTAL_1 := null;
            nTOTAL_2 := null;
        end;   
    
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        sINNERTAG := sINNERTAG||'<a ID="'||RTRIM(rec.STRCODE, '0') ||
                                    '" b2="'||trim(to_char( nvl(nTOTAL, 0), '99999999999999990.99'))||
                                    '" b3="'||trim(to_char( nvl(nTOTAL_1, 0), '99999999999999990.99'))||
                                    '" b4="'||trim(to_char( nvl(nTOTAL_2, 0), '99999999999999990.99'))||
                                '"/>'||CHR(10);    
 
        nTOTAL_90 := nvl(nTOTAL_90, 0) + nvl(nTOTAL, 0);
        nTOTAL_90_1 := nvl(nTOTAL_90_1, 0) + nvl(nTOTAL_1, 0);                                       
        nTOTAL_90_2 := nvl(nTOTAL_90_2, 0) + nvl(nTOTAL_2, 0);  
                                                                
    end loop;
 
    if COALESCE( nTOTAL_90, nTOTAL_90_1, nTOTAL_90_2 ) is not null then
        sINNERTAG := sINNERTAG||'<a ID="'||'90'||
                                    '" b2="'||trim(to_char( nvl(nTOTAL_90, 0), '99999999999999990.99'))||
                                    '" b3="'||trim(to_char( nvl(nTOTAL_90_1, 0), '99999999999999990.99'))||
                                    '" b4="'||trim(to_char( nvl(nTOTAL_90_2, 0), '99999999999999990.99')) ||
                                '"/>'||CHR(10);
    end if;
        
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="РасходыУплатыНалогов">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="РасходыУплатыНалогов" />';    
    end if;
    
    prnt(F1, sTAG);
    
        
    -- Таблица ID="ФинОбеспечение"
    --------------------------------------------------------
    sINNERTAG := null;
    sTAG      := null;
    nSTRCODE := null;
    
    for nFO in 1..5
    loop
        begin
            select sum(TOTAL), sum(TOTAL_1), sum(TOTAL_2) into nTOTAL, nTOTAL_1, nTOTAL_2
            from
                (select D.TOTAL, D.TOTAL_1, D.TOTAL_2
                   from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D
                   where T.JURPERS   = pJURPERS
                     and T.VERSION   = pVERSION
                     and T.ORGRN     = pOrgRn
                     and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
                     and D.PRN       = T.RN
                     and decode(D.FOTYPE2, 4, 1,5, 2, 6, 3, 2, 4, 7, 5) = nFO
                     and T.TAX_TYPE in (select distinct PAYMENT_TYPE_RN
                                          from Z_JUSTIFY_PAY_STR_LINKS PSL, Z_JUSTIFY_DICT JOD, Z_JUSTIFY_FORMCODE JOF
                                         where VERSION     = pVERSION
                                           and PSL.STR_RN  = JOD.RN
                                           and JOD.FORM_RN = JOF.RN
                                           and JOF.PART = 'OTHER_TAX_852_4')
                     and D.KVR = (select RN  
                                    from Z_EXPKVR_ALL
                                   where CODE = '852')
                );
        exception when others then
            nTOTAL := null;
            nTOTAL_1 := null;
            nTOTAL_2 := null;
        end;    
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        sINNERTAG := sINNERTAG||'<a ID="'||lpad(nSTRCODE, 2,0) ||
                                    '"'||case when COALESCE(nTOTAL, nTOTAL_1, nTOTAL_2) is not null then
                                    ' b3="'||trim(to_char( nvl(nTOTAL, 0), '99999999999999990.99'))||
                                    '" b4="'||trim(to_char( nvl(nTOTAL_1, 0), '99999999999999990.99'))||
                                    '" b5="'||trim(to_char( nvl(nTOTAL_2, 0), '99999999999999990.99'))||'"' else null end||
                                '/>'||CHR(10);
    
    end loop;
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="ФинОбеспечение">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="ФинОбеспечение" />';    
    end if;
    
    prnt(F1, sTAG);        
    
    
    --Таблица ID="ВодныйНалог"
    --------------------------------------------------------    
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;
    nCOUNTCOL   := null;
    sGUID       := null;
    AA_STR.delete;
    
    -- WORK_AMOUNT - Числ-ть работ-в, получ. пособие, чел.   
    -- PAY_AMOUNT  - Кол-во выплат в год на 1 раб., шт.   
    -- PAY_SIZE    - Размер выплаты (пособия) в мес., руб
    for rec in
    (
     select T.PLACE, T.OKTMO, T.OBJNAME, FIL.CODE FILCODE,
            T.LIC_DATE, T.LIC_NUM, T.PURPOSE, T.WATERCODE,
            D.*
       from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D, Z_ORGFL FIL
      where T.JURPERS   = pJURPERS
        and T.VERSION   = pVersion
        and T.ORGRN     = pOrgRn
        and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
        and D.PRN       = T.RN
        and T.FILIAL    = FIL.RN
        and T.TAX_TYPE in (select distinct PAYMENT_TYPE_RN
                                 from Z_JUSTIFY_PAY_STR_LINKS PSL, Z_JUSTIFY_DICT JOD, Z_JUSTIFY_FORMCODE JOF
                                where VERSION     = pVERSION
                                  and PSL.STR_RN  = JOD.RN
                                  and JOD.FORM_RN = JOF.RN
                                  and JOF.PART in ('OTHER_TAX_852_211', 'OTHER_TAX_852_212', 'OTHER_TAX_852_213'))
        and D.KVR = (select RN  
                       from Z_EXPKVR_ALL
                      where CODE = '852')
    )
    loop
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        nCOUNTCOL := nvl(nCOUNTCOL,0) + 1;
        sGUID     := lower(REGEXP_REPLACE(SYS_GUID(), '(.{8})(.{4})(.{4})(.{4})(.{12})', '\1-\2-\3-\4-\5'));
        
        AA_STR(nCOUNTCOL).RN     := rec.RN;
        AA_STR(nCOUNTCOL).GUID   := sGUID;
        
        AA_STR(nCOUNTCOL).LIC_DATE := rec.LIC_DATE;
        AA_STR(nCOUNTCOL).LIC_NUM := rec.LIC_NUM;
        AA_STR(nCOUNTCOL).PURPOSE := rec.PURPOSE;
        AA_STR(nCOUNTCOL).WATERCODE := rec.WATERCODE;
        
        AA_STR(nCOUNTCOL).WATER_LIMIT := rec.WATER_LIMIT;
        AA_STR(nCOUNTCOL).WATER_LIMIT_1 := rec.WATER_LIMIT_1;
        AA_STR(nCOUNTCOL).WATER_LIMIT_2 := rec.WATER_LIMIT_2;
 
        AA_STR(nCOUNTCOL).WATER_VALUE := rec.WATER_VALUE;
        AA_STR(nCOUNTCOL).WATER_VALUE_1 := rec.WATER_VALUE_1;
        AA_STR(nCOUNTCOL).WATER_VALUE_2 := rec.WATER_VALUE_2;
 
        AA_STR(nCOUNTCOL).WATER_OVERLIMIT := rec.WATER_OVERLIMIT;
        AA_STR(nCOUNTCOL).WATER_OVERLIMIT_1 := rec.WATER_OVERLIMIT_1;
        AA_STR(nCOUNTCOL).WATER_OVERLIMIT_2 := rec.WATER_OVERLIMIT_2;
 
        AA_STR(nCOUNTCOL).WATER_STAVKA := rec.WATER_STAVKA;
        AA_STR(nCOUNTCOL).WATER_STAVKA_1 := rec.WATER_STAVKA_1;
        AA_STR(nCOUNTCOL).WATER_STAVKA_2 := rec.WATER_STAVKA_2;
 
        AA_STR(nCOUNTCOL).WATER_OVER_STAVKA := rec.WATER_OVER_STAVKA;
        AA_STR(nCOUNTCOL).WATER_OVER_STAVKA_1 := rec.WATER_OVER_STAVKA_1;
        AA_STR(nCOUNTCOL).WATER_OVER_STAVKA_2 := rec.WATER_OVER_STAVKA_2;
 
        AA_STR(nCOUNTCOL).WATER_KOEFF := rec.WATER_KOEFF;
        AA_STR(nCOUNTCOL).WATER_KOEFF_1 := rec.WATER_KOEFF_1;
        AA_STR(nCOUNTCOL).WATER_KOEFF_2 := rec.WATER_KOEFF_2;
 
        AA_STR(nCOUNTCOL).WATER_KOEFF_LESS := rec.WATER_KOEFF_LESS;
        AA_STR(nCOUNTCOL).WATER_KOEFF_LESS_1 := rec.WATER_KOEFF_LESS_1;
        AA_STR(nCOUNTCOL).WATER_KOEFF_LESS_2 := rec.WATER_KOEFF_LESS_2;
 
        AA_STR(nCOUNTCOL).WATER_KOEFF_LAND := rec.WATER_KOEFF_LAND;
        AA_STR(nCOUNTCOL).WATER_KOEFF_LAND_1 := rec.WATER_KOEFF_LAND_1;
        AA_STR(nCOUNTCOL).WATER_KOEFF_LAND_2 := rec.WATER_KOEFF_LAND_2;          
        
        sINNERTAG := sINNERTAG||'<a ID="'||(nSTRCODE - 1) ||
                                    '" b1="'||nvl(rec.PLACE,'0')||
                                    '" b2="'||nvl(rec.OKTMO,'00000000') ||
                                    '" b3="'||rec.OBJNAME || ' ( ' || rec.FILCODE || ' ) ' ||
                                    '" b4="'||trim(to_char( nvl(rec.TOTAL, 0), '99999999999999990.99'))||
                                    '" b5="'||trim(to_char( nvl(rec.TOTAL_1, 0), '99999999999999990.99'))||
                                    '" b6="'||trim(to_char( nvl(rec.TOTAL_2, 0), '99999999999999990.99'))||
                                    '" bFILTERINGCOLUMN="'||sGUID||
                                '"/>'||CHR(10);
    end loop;
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="ВодныйНалог">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="ВодныйНалог" />';    
    end if;
 
      
    prnt(F1, sTAG);
    
    
    --Таблица ID="ВодныйНалогСуб" детализация   
    --------------------------------------------------------
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;
    -- WORK_AMOUNT - Числ-ть работ-в, получ. пособие, чел.:   
    -- PAY_AMOUNT  - Кол-во выплат в год на 1 раб., шт.:   
    -- PAY_SIZE    - Размер выплаты (пособия) в мес., руб:
 
    if AA_STR.COUNT > 0 then
        for I in 1..nCOUNTCOL
        loop    
            
            for K in 1..3
            loop
                nSTRCODE := nvl(nSTRCODE,0) + 1;
 
                
                sINNERTAG := sINNERTAG||'<a ID="'||(nSTRCODE - 1) ||
                                            '" b1="' ||case K when 1 then nNEXT_PERIOD
                                                              when 2 then nPLAN1
                                                              when 3 then nPLAN2 end ||
                                            '" b2="' ||AA_STR(I).LIC_DATE ||
                                            '" b3="' ||AA_STR(I).LIC_NUM ||
                                            '" b4="' ||AA_STR(I).PURPOSE||
                                            '" b5="' ||AA_STR(I).WATERCODE||
                                            
                                            '" b6="' ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER_LIMIT, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER_LIMIT_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER_LIMIT_2, 0), '99999999999999990.99')) end ||
                                                              
                                            '" b7="' ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER_VALUE, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER_VALUE_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER_VALUE_2, 0), '99999999999999990.99')) end ||
                                                              
                                            '" b8="' ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER_OVERLIMIT, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER_OVERLIMIT_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER_OVERLIMIT_2, 0), '99999999999999990.99')) end ||
 
                                            '" b9="' ||null||
                                            '" b10="' ||null||
                 
                                            '" b11="'||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_2, 0), '99999999999999990.99')) end||
                                                              
                                            
                                            '" b12="' ||null||
                                                              
                                            '" b13="'  ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_LESS, 0), '99999999999999990.99'))
                                                                when 2 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_LESS_1, 0), '99999999999999990.99'))
                                                                when 3 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_LESS_2, 0), '99999999999999990.99')) end||
                                                                
                                            '" b14="'  ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_LAND, 0), '99999999999999990.99'))
                                                                when 2 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_LAND_1, 0), '99999999999999990.99'))
                                                                when 3 then trim(to_char( nvl(AA_STR(I).WATER_KOEFF_LAND_2, 0), '99999999999999990.99')) end||
                                            '" b15="' ||1||
                                            
                                            '" bFILTERINGCOLUMN="'||AA_STR(I).GUID||
 
                                            '" bстолбец="'||'0'||
 
                                            '" b9_1="'||1||
                                            '" b10_1="'||2||
                                            '" b12_1="'||3||
                                        '"/>'||CHR(10);
 
 
                                        
            end loop;
            null;        
        end loop;
    end if;
    
    AA_STR.delete;
    
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="ВодныйНалогСуб">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="ВодныйНалогСуб" />';    
    end if;
    
    prnt(F1, sTAG);
    
    
    --Таблица ID="НалогИсклЗаборВоды"
    --------------------------------------------------------    
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;
    
    nCOUNTCOL   := null;
    sGUID       := null;
    AA_STR.delete;    
    for rec in
    (
       select T.PLACE, T.OKTMO, T.OBJNAME, FIL.CODE FILCODE,
              T.LIC_DATE, T.LIC_NUM, T.AGR_DATE, T.AGR_NUMB, T.WATERCODE,
              D.*
         from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D, Z_ORGFL FIL
        where T.JURPERS   = pJURPERS
          and T.VERSION   = pVersion
          and T.ORGRN     = pOrgRn
          and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
          and D.PRN       = T.RN
          and T.FILIAL    = FIL.RN
            
          and T.TAX_TYPE in (select distinct PAYMENT_TYPE_RN
                                   from Z_JUSTIFY_PAY_STR_LINKS PSL, Z_JUSTIFY_DICT JOD, Z_JUSTIFY_FORMCODE JOF
                                  where VERSION     = pVERSION
                                    and PSL.STR_RN  = JOD.RN
                                    and JOD.FORM_RN = JOF.RN
                                    and JOF.PART in ('OTHER_TAX_852_221', 'OTHER_TAX_852_222', 'OTHER_TAX_852_223'))
          and D.KVR = (select RN  
                         from Z_EXPKVR_ALL
                        where CODE = '852')
    )
    loop
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        nCOUNTCOL := nvl(nCOUNTCOL,0) + 1;
        sGUID     := lower(REGEXP_REPLACE(SYS_GUID(), '(.{8})(.{4})(.{4})(.{4})(.{12})', '\1-\2-\3-\4-\5'));
        
        AA_STR(nCOUNTCOL).RN     := rec.RN;
        AA_STR(nCOUNTCOL).GUID   := sGUID;
 
        AA_STR(nCOUNTCOL).LIC_DATE := rec.LIC_DATE;
        AA_STR(nCOUNTCOL).LIC_NUM := rec.LIC_NUM;
        AA_STR(nCOUNTCOL).AGR_DATE := rec.AGR_DATE;
        AA_STR(nCOUNTCOL).AGR_NUMB := rec.AGR_NUMB;
        AA_STR(nCOUNTCOL).WATERCODE := rec.WATERCODE;
        
        AA_STR(nCOUNTCOL).WATER2_SQUARE := rec.WATER2_SQUARE;
        AA_STR(nCOUNTCOL).WATER2_SQUARE_1 := rec.WATER2_SQUARE_1;
        AA_STR(nCOUNTCOL).WATER2_SQUARE_2 := rec.WATER2_SQUARE_2;        
 
        AA_STR(nCOUNTCOL).WATER2_ENERGY := rec.WATER2_ENERGY;
        AA_STR(nCOUNTCOL).WATER2_ENERGY_1 := rec.WATER2_ENERGY_1;
        AA_STR(nCOUNTCOL).WATER2_ENERGY_2 := rec.WATER2_ENERGY_2;        
 
        AA_STR(nCOUNTCOL).WATER2_WOOD := rec.WATER2_WOOD;
        AA_STR(nCOUNTCOL).WATER2_WOOD_1 := rec.WATER2_WOOD_1;
        AA_STR(nCOUNTCOL).WATER2_WOOD_2 := rec.WATER2_WOOD_2;        
 
        AA_STR(nCOUNTCOL).WATER2_DIST := rec.WATER2_DIST;
        AA_STR(nCOUNTCOL).WATER2_DIST_1 := rec.WATER2_DIST_1;
        AA_STR(nCOUNTCOL).WATER2_DIST_2 := rec.WATER2_DIST_2;        
 
        AA_STR(nCOUNTCOL).WATER2_STAVKA := rec.WATER2_STAVKA;
        AA_STR(nCOUNTCOL).WATER2_STAVKA_1 := rec.WATER2_STAVKA_1;
        AA_STR(nCOUNTCOL).WATER2_STAVKA_2 := rec.WATER2_STAVKA_2;                
 
        AA_STR(nCOUNTCOL).WATER2_KOEFF := rec.WATER2_KOEFF;
        AA_STR(nCOUNTCOL).WATER2_KOEFF_1 := rec.WATER2_KOEFF_1;
        AA_STR(nCOUNTCOL).WATER2_KOEFF_2 := rec.WATER2_KOEFF_2;                        
                          
        sINNERTAG := sINNERTAG||'<a ID="'||(nSTRCODE - 1) ||
                                    '" b1="'||rec.PLACE||
                                    '" b2="'|| rec.OKTMO ||
                                    '" b3="'||rec.OBJNAME || ' ( ' || rec.FILCODE || ' ) ' ||
                                    '" b4="'||trim(to_char( nvl(rec.TOTAL, 0), '99999999999999990.99'))||
                                    '" b5="'||trim(to_char( nvl(rec.TOTAL_1, 0), '99999999999999990.99'))||
                                    '" b6="'||trim(to_char( nvl(rec.TOTAL_2, 0), '99999999999999990.99'))||
                                    '" bFILTERINGCOLUMN="'||sGUID||
                                '"/>'||CHR(10);
    end loop;
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="НалогИсклЗаборВоды">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="НалогИсклЗаборВоды" />';    
    end if;
    
    prnt(F1, sTAG);            
    
    
    --Таблица ID="НалогИсклЗаборВодыСуб" детализация  
    --------------------------------------------------------    
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;
 
    if AA_STR.COUNT > 0 then
        for I in 1..nCOUNTCOL
        loop                
            for K in 1..3
            loop
                nSTRCODE := nvl(nSTRCODE,0) + 1;
     
                sINNERTAG := sINNERTAG||'<a ID="'||(nSTRCODE - 1) ||
                                            '" b1="' ||case K when 1 then nNEXT_PERIOD
                                                              when 2 then nPLAN1
                                                              when 3 then nPLAN2 end ||
                                            '" b2="' ||AA_STR(I).LIC_DATE ||
                                            '" b3="' ||AA_STR(I).LIC_NUM ||
                                            '" b4="' ||AA_STR(I).AGR_DATE||
                                            '" b5="' ||AA_STR(I).AGR_NUMB||
                                            '" b6="' ||AA_STR(I).WATERCODE ||
                                            '" b7="' ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER2_SQUARE, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER2_SQUARE_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER2_SQUARE_2, 0), '99999999999999990.99')) end ||
                                            '" b8="' ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER2_ENERGY, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER2_ENERGY_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER2_ENERGY_2, 0), '99999999999999990.99')) end ||
                                            '" b9="' ||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER2_WOOD, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER2_WOOD_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER2_WOOD_2, 0), '99999999999999990.99')) end||
                                            '" b10="'||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER2_DIST, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER2_DIST_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER2_DIST_2, 0), '99999999999999990.99')) end||
                                            '" b11="'||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER2_STAVKA, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER2_STAVKA_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER2_STAVKA_2, 0), '99999999999999990.99'))  end||
                                            '" b12="'||case K when 1 then trim(to_char( nvl(AA_STR(I).WATER2_KOEFF, 0), '99999999999999990.99'))
                                                              when 2 then trim(to_char( nvl(AA_STR(I).WATER2_KOEFF_1, 0), '99999999999999990.99'))
                                                              when 3 then trim(to_char( nvl(AA_STR(I).WATER2_KOEFF_2, 0), '99999999999999990.99')) end||
                                            '" bFILTERINGCOLUMN="'||AA_STR(I).GUID||
                                        '"/>'||CHR(10);
            end loop;
        end loop;
    end if;
    AA_STR.delete;    
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="НалогИсклЗаборВодыСуб">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="НалогИсклЗаборВодыСуб" />';    
    end if;
    
    prnt(F1, sTAG);
 
    
    
    --Таблица ID="ТранспортныйНалог"   
    --------------------------------------------------------
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;   
    
    nCOUNTCOL   := null;
    sGUID       := null;
    AA_STR.delete;    
 
    prnt(F1, '<Таблица ID="ТранспортныйНалог">');
    
    for rec in
    (
       select T.OKTMO, T.TRANS_NAME, T.TRANS_TYPE, T.TRANS_NUM, T.REG_DATE, T.UNREG_DATE, FIL.CODE FILCODE,
              D.*
         from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D, Z_ORGFL FIL
        where T.JURPERS   = pJURPERS
          and T.VERSION   = pVersion
          and T.ORGRN     = pOrgRn
          and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
          and D.PRN       = T.RN
          and T.FILIAL    = FIL.RN
          and T.TAX_TYPE in (select distinct PAYMENT_TYPE_RN
                                   from Z_JUSTIFY_PAY_STR_LINKS PSL, Z_JUSTIFY_DICT JOD, Z_JUSTIFY_FORMCODE JOF
                                  where VERSION     = pVERSION
                                    and PSL.STR_RN  = JOD.RN
                                    and JOD.FORM_RN = JOF.RN
                                    and JOF.PART in ('OTHER_TAX_852_231', 'OTHER_TAX_852_232', 'OTHER_TAX_852_233'))
          and D.KVR = (select RN  
                         from Z_EXPKVR_ALL
                        where CODE = '852')
    )
    loop
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        nCOUNTCOL := nvl(nCOUNTCOL,0) + 1;
        sGUID     := lower(REGEXP_REPLACE(SYS_GUID(), '(.{8})(.{4})(.{4})(.{4})(.{12})', '\1-\2-\3-\4-\5'));
        
        AA_STR(nCOUNTCOL).RN      := rec.RN;
        AA_STR(nCOUNTCOL).GUID    := sGUID;
 
        AA_STR(nCOUNTCOL).TRANS_BASE := rec.TRANS_BASE;
        AA_STR(nCOUNTCOL).TRANS_BASE_1 := rec.TRANS_BASE_1;
        AA_STR(nCOUNTCOL).TRANS_BASE_2 := rec.TRANS_BASE_2;         
 
        AA_STR(nCOUNTCOL).TRANS_MONTH_COUNT := rec.TRANS_MONTH_COUNT;
        AA_STR(nCOUNTCOL).TRANS_MONTH_COUNT_1 := rec.TRANS_MONTH_COUNT_1;
        AA_STR(nCOUNTCOL).TRANS_MONTH_COUNT_2 := rec.TRANS_MONTH_COUNT_2;         
 
        AA_STR(nCOUNTCOL).TRANS_KOEFF := rec.TRANS_KOEFF;
        AA_STR(nCOUNTCOL).TRANS_KOEFF_1 := rec.TRANS_KOEFF_1;
        AA_STR(nCOUNTCOL).TRANS_KOEFF_2 := rec.TRANS_KOEFF_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_SHARE := rec.TRANS_SHARE;
        AA_STR(nCOUNTCOL).TRANS_SHARE_1 := rec.TRANS_SHARE_1;
        AA_STR(nCOUNTCOL).TRANS_SHARE_2 := rec.TRANS_SHARE_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_STAVKA := rec.TRANS_STAVKA;
        AA_STR(nCOUNTCOL).TRANS_STAVKA_1 := rec.TRANS_STAVKA_1;
        AA_STR(nCOUNTCOL).TRANS_STAVKA_2 := rec.TRANS_STAVKA_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_UP_KOEFF := rec.TRANS_UP_KOEFF;
        AA_STR(nCOUNTCOL).TRANS_UP_KOEFF_1 := rec.TRANS_UP_KOEFF_1;
        AA_STR(nCOUNTCOL).TRANS_UP_KOEFF_2 := rec.TRANS_UP_KOEFF_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_LMONTH := rec.TRANS_LMONTH;
        AA_STR(nCOUNTCOL).TRANS_LMONTH_1 := rec.TRANS_LMONTH_1;
        AA_STR(nCOUNTCOL).TRANS_LMONTH_2 := rec.TRANS_LMONTH_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_LKOEFF := rec.TRANS_LKOEFF;
        AA_STR(nCOUNTCOL).TRANS_LKOEFF_1 := rec.TRANS_LKOEFF_1;
        AA_STR(nCOUNTCOL).TRANS_LKOEFF_2 := rec.TRANS_LKOEFF_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_LCODE := rec.TRANS_LCODE;                 
 
        AA_STR(nCOUNTCOL).TRANS_LSUM := rec.TRANS_LSUM;
        AA_STR(nCOUNTCOL).TRANS_LSUM_1 := rec.TRANS_LSUM_1;
        AA_STR(nCOUNTCOL).TRANS_LSUM_2 := rec.TRANS_LSUM_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_LCODE_DN := rec.TRANS_LCODE_DN;                         
 
        AA_STR(nCOUNTCOL).TRANS_LSUM_DN := rec.TRANS_LSUM_DN;
        AA_STR(nCOUNTCOL).TRANS_LSUM_DN_1 := rec.TRANS_LSUM_DN_1;
        AA_STR(nCOUNTCOL).TRANS_LSUM_DN_2 := rec.TRANS_LSUM_DN_2;                 
 
        AA_STR(nCOUNTCOL).TRANS_LCODE_W := rec.TRANS_LCODE_W;                         
            
        AA_STR(nCOUNTCOL).TRANS_LSUM_W := rec.TRANS_LSUM_W;
        AA_STR(nCOUNTCOL).TRANS_LSUM_W_1 := rec.TRANS_LSUM_W_1;
        AA_STR(nCOUNTCOL).TRANS_LSUM_W_2 := rec.TRANS_LSUM_W_2;    
 
        AA_STR(nCOUNTCOL).TRANS_DEDSUM := rec.TRANS_DEDSUM;
        AA_STR(nCOUNTCOL).TRANS_DEDSUM_1 := rec.TRANS_DEDSUM_1;
        AA_STR(nCOUNTCOL).TRANS_DEDSUM_2 := rec.TRANS_DEDSUM_2;    
                      
        
        sINNERTAG := '<a ID="'||(nSTRCODE - 1) ||
                            '" b1="'||replace(rec.OKTMO, '"', '&quot;') ||
                            '" b2="'||replace(rec.TRANS_NAME, '"', '&quot;')|| ' ( ' || rec.FILCODE || ' ) ' ||
                            '" b3="'||replace(rec.TRANS_TYPE, '"', '&quot;') ||
                            '" b4="'|| rec.TRANS_NUM||'" b5="'|| rec.REG_DATE||
                            '" b6="'|| rec.UNREG_DATE ||
                            '" b7="'||trim(to_char( nvl(rec.TOTAL, 0), '99999999999999990.99'))||
                            '" b8="'||trim(to_char( nvl(rec.TOTAL_1, 0), '99999999999999990.99'))||
                            '" b9="'||trim(to_char( nvl(rec.TOTAL_2, 0), '99999999999999990.99'))||
                            '" bFILTERINGCOLUMN="'||sGUID||
                        '"/>';  
        prnt(F1, sINNERTAG);          
    end loop;
 
    prnt(F1, '</Таблица>');
    
    --Таблица ID="ТранспортныйНалогСуб" детализация
    --------------------------------------------------------    
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;
 
    prnt(F1, '<Таблица ID="ТранспортныйНалогСуб">');
    
    for I in 1..nCOUNTCOL
    loop               
        for K in 1..3
        loop
            
            nSTRCODE := nvl(nSTRCODE,0) + 1;
            sINNERTAG := '<a ID="'||(nSTRCODE - 1) ||
                             '" b1="'  || case K when 1 then nNEXT_PERIOD
                                                 when 2 then nPLAN1
                                                 when 3 then nPLAN2 end ||
                             '" b2="'  || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_BASE, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_BASE_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_BASE_2, 0), '99999999999999990.99')) end ||
                             '" b3="'  || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_MONTH_COUNT, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_MONTH_COUNT_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_MONTH_COUNT_2, 0), '99999999999999990.99')) end ||
                             '" b4="'  || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_KOEFF, 0), '99999999999999990.99'))  
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_KOEFF_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_KOEFF_2, 0), '99999999999999990.99')) end||
                             '" b5="'  || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_SHARE, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_SHARE_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_SHARE_2, 0), '99999999999999990.99'))end||
                             '" b6_1="'|| case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_STAVKA, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_STAVKA_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_STAVKA_2, 0), '99999999999999990.99')) end||
                             '" b7_1="'|| case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_UP_KOEFF, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_UP_KOEFF_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_UP_KOEFF_2, 0), '99999999999999990.99'))  end ||
                             '" b9="'  || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_LMONTH, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_LMONTH_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_LMONTH_2, 0), '99999999999999990.99')) end ||
                             '" b10="' || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_LKOEFF, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_LKOEFF_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_LKOEFF_2, 0), '99999999999999990.99')) end||
                             '" b11="' || AA_STR(I).TRANS_LCODE||
                             '" b12="' || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_2, 0), '99999999999999990.99')) end||
                             '" b13="' || AA_STR(I).TRANS_LCODE_DN||
                             '" b15="' || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_DN, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_DN_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_DN_2, 0), '99999999999999990.99')) end||
                             '" b16="' || AA_STR(I).TRANS_LCODE_W||
                             '" b17="' || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_W, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_W_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_LSUM_W_2, 0), '99999999999999990.99')) end||
                             '" b18="' || AA_STR(I).TRANS_DEDCODE||
                             '" b19="' || case K when 1 then trim(to_char( nvl(AA_STR(I).TRANS_DEDSUM, 0), '99999999999999990.99'))
                                                 when 2 then trim(to_char( nvl(AA_STR(I).TRANS_DEDSUM_1, 0), '99999999999999990.99'))
                                                 when 3 then trim(to_char( nvl(AA_STR(I).TRANS_DEDSUM_2, 0), '99999999999999990.99')) end||
                             '" bFILTERINGCOLUMN="'||AA_STR(I).GUID||
                         '"/>';
            prnt(F1, sINNERTAG);      
        end loop;
    end loop;
    AA_STR.delete;
 
    prnt(F1, '</Таблица>');
                     
 
    --Таблица ID="ИныеНалогиСборы"
    --------------------------------------------------------
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;
    -- WORK_AMOUNT - Числ-ть работ-в, получ. пособие, чел.
    -- PAY_AMOUNT  - Кол-во выплат в год на 1 раб., шт.
    -- PAY_SIZE    - Размер выплаты (пособия) в мес., руб
    for rec in
    (
        select T.OKTMO,     
           D.TOTAL TOTAL, D.TOTAL_1 TOTAL_1, D.TOTAL_2 TOTAL_2
          from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D
         where T.JURPERS   = pJURPERS
           and T.VERSION   = pVersion
           and T.ORGRN     = pOrgRn
           and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
           and D.PRN       = T.RN
             
           and T.TAX_TYPE in (select distinct PAYMENT_TYPE_RN
                                    from Z_JUSTIFY_PAY_STR_LINKS PSL, Z_JUSTIFY_DICT JOD, Z_JUSTIFY_FORMCODE JOF
                                   where VERSION     = pVERSION
                                     and PSL.STR_RN  = JOD.RN
                                     and JOD.FORM_RN = JOF.RN
                                     and JOF.PART = 'OTHER_TAX_852_24')
           and D.KVR = (select RN  
                          from Z_EXPKVR_ALL
                         where CODE = '852')
    )
    loop
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        sINNERTAG := sINNERTAG||'<a ID="'||(nSTRCODE - 1) ||
                                    '" b1="'||nvl(rec.OKTMO, 0)||
                                    '" b2="'||trim(to_char( nvl(rec.TOTAL, 0), '99999999999999990.99')) ||
                                    '" b3="'||trim(to_char( nvl(rec.TOTAL_1, 0), '99999999999999990.99')) ||
                                    '" b4="'||trim(to_char( nvl(rec.TOTAL_2, 0), '99999999999999990.99'))||
                                '"/>'||CHR(10);
    end loop;
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="ИныеНалогиСборы">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="ИныеНалогиСборы" />';    
    end if;
    
    prnt(F1, sTAG);            
    
    
    --Таблица ID="ГосПошлина"
    --------------------------------------------------------
    sINNERTAG := null;
    sTAG      := null;    
    nSTRCODE  := null;
    -- WORK_AMOUNT - Числ-ть работ-в, получ. пособие, чел.
    -- PAY_AMOUNT  - Кол-во выплат в год на 1 раб., шт.  
    -- PAY_SIZE    - Размер выплаты (пособия) в мес., руб
    for rec in
    (
        select T.OKTMO,     
               D.TOTAL TOTAL, D.TOTAL_1 TOTAL_1, D.TOTAL_2 TOTAL_2
           from X_OTHER_TAX T, X_OTHER_TAX_DETAIL D
          where T.JURPERS   = pJURPERS
            and T.VERSION   = pVersion
            and T.ORGRN     = pOrgRn
            and ((T.FILIAL = pFILIAL) or (pFILIAL is null))
            and D.PRN       = T.RN
              
            and T.TAX_TYPE in (select distinct PAYMENT_TYPE_RN
                                     from Z_JUSTIFY_PAY_STR_LINKS PSL, Z_JUSTIFY_DICT JOD, Z_JUSTIFY_FORMCODE JOF
                                    where VERSION     = pVERSION
                                      and PSL.STR_RN  = JOD.RN
                                      and JOD.FORM_RN = JOF.RN
                                      and JOF.PART = 'OTHER_TAX_852_25')
            and D.KVR = (select RN  
                           from Z_EXPKVR_ALL
                          where CODE = '852')
    )
    loop
        nSTRCODE := nvl(nSTRCODE,0) + 1;
        sINNERTAG := sINNERTAG||'<a ID="'||(nSTRCODE - 1) ||
                                    '" b1="'||nvl(rec.OKTMO, 0)||
                                    '" b2="'||trim(to_char( nvl(rec.TOTAL, 0), '99999999999999990.99')) ||
                                    '" b3="'||trim(to_char( nvl(rec.TOTAL_1, 0), '99999999999999990.99')) ||
                                    '" b4="'||trim(to_char( nvl(rec.TOTAL_2, 0), '99999999999999990.99')) ||
                                '"/>'||CHR(10);
    end loop;
    
    if sINNERTAG is not null then
        sTAG := '<Таблица ID="ГосПошлина">'||CHR(10)||sINNERTAG||'</Таблица>';
    else
        sTAG := '<Таблица ID="ГосПошлина" />';    
    end if;
    
    prnt(F1, sTAG);            
    
    prnt(F1,'</Форма>');
     
    UTL_FILE.FCLOSE(F1);
    
    begin
        UTL_FILE.FCLOSE_ALL;
    end;
end;
​