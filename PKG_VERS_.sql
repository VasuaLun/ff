create or replace package body PKG_VERS_COPY is
    
    sSQL varchar2(4000);
    sSQL1 varchar2(4000);
    sSQL2  varchar2(4000);
    procedure ZP_UPDATE_TABLES_STG_DET_COPY(pTABLENAME VARCHAR DEFAULT NULL)
    as
        nNULLABLE_SIGN number;
        nUNIQ_SIGN     number;
        nCOUNTUQ_COLS  number;

        nFK_SIGN       number;
        nFK_TABLE      varchar2(100);
        nCOPY_SIGN     number;
    begin
        if pTABLENAME is not null then
            begin
                insert into Z_TABLES_SETTINGS_COPY (OWNER, TABLE_NAME, CHECKSIGN) VALUES('APXWS', pTABLENAME, 1);
            end;
        end if;
        
        begin
            for QTABS in
            (
                select *
                  from Z_TABLES_SETTINGS_COPY
                 where CHECKSIGN = 1
            )
            loop
                for QCOLS in
                (
                    select *
                      from ALL_TAB_COLUMNS
                     where OWNER      = QTABS.OWNER
                       and TABLE_NAME = QTABS.TABLE_NAME
                )
                loop
                    --Проверяем может быть атрибут пустым
                    if QCOLS.NULLABLE = 'Y' then
                        nNULLABLE_SIGN := 1;
                    else
                        nNULLABLE_SIGN := null;
                    end if;
                    -------------------------------------

                    --Проверяем состоит атрибут в уникальном ключе
                    select count(*)
                      into nCOUNTUQ_COLS
                      from USER_CONS_COLUMNS
                     where OWNER           = QTABS.OWNER
                       and TABLE_NAME      = QTABS.TABLE_NAME
                       and COLUMN_NAME     = QCOLS.COLUMN_NAME
                       and CONSTRAINT_NAME like '%UK';

                    if nCOUNTUQ_COLS > 0 then
                        nUNIQ_SIGN := 1;
                    else
                        nUNIQ_SIGN := null;
                    end if;
                    ----------------------------------------------

                    --Проверяем состоит атрибут во внешнем ключе
                    begin
                        select c_pk.table_name r_table_name
                          into nFK_TABLE
                          from all_cons_columns a, all_constraints c, all_constraints c_pk
                         where c.owner             = a.owner
                           and a.constraint_name   = c.constraint_name
                           and c.r_owner           = c_pk.owner
                           and c.r_constraint_name = c_pk.constraint_name
                           and c.constraint_type   = 'R'
                           and a.table_name        = QTABS.TABLE_NAME
                           and a.column_name       = QCOLS.COLUMN_NAME;
                    exception when others then
                        nFK_TABLE := null;
                    end;

                    if nFK_TABLE is not null then
                        nFK_SIGN := 1;
                    else
                        nFK_SIGN := null;
                    end if;
                    ----------------------------------------------
                    -- Инициализации флагов копирования
                    nCOPY_SIGN   := null;

                    if QCOLS.COLUMN_NAME in ('CREATEU', 'CREATED', 'MODIFIED', 'CHUSER','RN') then
                        nCOPY_SIGN   := 0;
                    end if;

                    ----------------------------------------------
                    begin
                        insert into Z_TABLES_SETTINGS_DET_COPY(OWNER, TABLE_NAME, COLUMN_NAME, COLUMN_ID, UNIQ_SIGN, NULLABLE_SIGN, FK_SIGN, FK_TABLE_NAME, COPY_SIGN, DATA_TYPE)
                                                        values(QCOLS.OWNER, QCOLS.TABLE_NAME, QCOLS.COLUMN_NAME, QCOLS.COLUMN_ID, nUNIQ_SIGN, nNULLABLE_SIGN, nFK_SIGN, nFK_TABLE,  nCOPY_SIGN, QCOLS.DATA_TYPE);
                    exception when others then
                        null;
                    end;
                end loop;
            end loop;
        end;
    end;

    procedure ZP_VERS_COPY
    (
      pPART         number,      
      pSUBPART      number,
      --
      pJURPERSFROM  number,
      pJURPERSTO    number,
      pVERSFROM     number,
      pVERSTO       number      
    )
    as
        nKBK_NEW_FROM  number;
        nKBK_NEW_TO    number;
        nCOUNT         number;
        sFIELD_ARR     varchar2(4000);
        sINSERT_ARR1   varchar2(4000);
    begin    
        begin
            select nvl(KBK_NEW,0)
              into nKBK_NEW_FROM
              from Z_VERSIONS
             where RN = pVERSFROM;
        exception when others then nKBK_NEW_FROM := null;
        end;
        
        begin
            select nvl(KBK_NEW,0)
              into nKBK_NEW_TO
              from Z_VERSIONS
             where RN = pVERSTO;
        exception when others then nKBK_NEW_TO := null;
        end;
    
        if nKBK_NEW_TO <> nKBK_NEW_FROM then
            ZP_EXCEPTION(0,'Необходимо проверить настройку "Новая классификация КБК" у Версий. Дальнейшее копирование невозможно');
        end if;

        if ((pVERSFROM is null) or (pVERSTO is null)) then
            ZP_EXCEPTION(0,'Копирование не возможно. Не заданы версии из которой копировать и/или в которую копировать.');        
        end if;    
        
        for rec in
        (
         select *
           from Z_TABLES_SETTINGS_COPY
          where COPY_PART    = pPART
            and COPY_SUBPART = pSUBPART
            and TABLE_NAME   = 'Z_EXPGROUP'
        )
        loop            
            --------------------------
            SSQL1 := 'insert into '||rec.TABLE_NAME||'(';
                    
            for QFIELD in
            (
            select *
              from Z_TABLES_SETTINGS_DET_COPY
             where TABLE_NAME = rec.TABLE_NAME
               and COPY_SIGN = 1
            --    and UNIQ_SIGN = 1
             order by COLUMN_ID
            )
            loop
                nCOUNT := nvl(nCOUNT, 0) + 1;
                if nCOUNT != 1 then
                    sFIELD_ARR := sFIELD_ARR ||',';
                    sINSERT_ARR1 := sINSERT_ARR1 ||',';
                end if;
            
                    sFIELD_ARR  := sFIELD_ARR|| QFIELD.COLUMN_NAME;
                    sINSERT_ARR1 := sINSERT_ARR1||case  when replace(QFIELD.COLUMN_NAME, '_', '') = 'JURPERS' then ''||pJURPERSTO||''
                                                        when QFIELD.COLUMN_NAME = 'VERSION' then ''||pVERSTO||''
                                                        else
                                                            case when lower(QFIELD.DATA_TYPE) like 'varchar%' or lower(QFIELD.DATA_TYPE) like 'timestamp%' then ''''''||'''||rec.'||QFIELD.COLUMN_NAME||'||'''||''''''
                                                                 else '''||rec.'||QFIELD.COLUMN_NAME||'||'''
                                                            end
                                                        end;
            end loop;

            SSQL1 := SSQL1||sFIELD_ARR|| ') values (';
            --------------------------
            -- /*
            SSQL :=
            '
             declare
                sSQL_STM  varchar2(4000);
             begin
                for rec in
                (
                select '||sFIELD_ARR||'
                  from '||rec.TABLE_NAME||'
                 where VERSION  = :1
                    -- and rownum = 1;
                )
                loop
                    sSQL_STM := null;
                    -- htp.p('''||sSQL1||sINSERT_ARR1||')'');
                    sSQL_STM := '''||sSQL1||sINSERT_ARR1||');'';

                    htp.p(sSQL_STM);

                    sSQL_STM := ''begin ''||sSQL_STM||''end;'';
                    htp.p(sSQL_STM);

                    begin
                        EXECUTE IMMEDIATE sSQL_STM;
                    exception when others then
                        htp.p(sqlerrm);
                    end;

                end loop;
            end;';
            -- htp.p(SSQL);
            htp.p(sSQL);

            begin
                EXECUTE IMMEDIATE SSQL USING pVERSFROM;
            exception when others then
                htp.p(sqlerrm);
            end;

        end loop;

    end;    
end;