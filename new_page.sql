    CREATE TABLE  Z_SCREENING
       (RN NUMBER(17,0) NOT NULL ENABLE,
    	JUR_PERS NUMBER(17,0) NOT NULL ENABLE,
    	VERSION NUMBER(17,0) DEFAULT null,
        ORGRN NUMBER(17,0) DEFAULT null,
        FUND NUMBER(17,0) DEFAULT null,
        METHOD VARCHAR2(20000) NOT NULL ENABLE,
        CPERSONS NUMBER(17,0) DEFAULT null,
        SEX NUMBER(17,0) DEFAULT null,
        AGE VARCHAR2(25) DEFAULT null,
        RESEARCH VARCHAR2(2000) NOT NULL ENABLE,
        MODIFIED TIMESTAMP (6) DEFAULT null,
        CHUSER VARCHAR2(100) DEFAULT null,
    	CREATED TIMESTAMP (6) DEFAULT null,
    	CREATEU VARCHAR2(100) DEFAULT null,
        CONSTRAINT C_SCREENING_PK PRIMARY KEY (RN)
        USING INDEX  ENABLE
        )

        /
        ALTER TABLE  Z_SCREENING ADD CONSTRAINT C_SCREENING_JUR_FK FOREIGN KEY (JUR_PERS)
        	  REFERENCES  Z_JURPERS (RN) ENABLE
        /
        ALTER TABLE  Z_SCREENING ADD CONSTRAINT C_SCREENING_VERS_FK FOREIGN KEY (VERSION)
        	  REFERENCES  Z_VERSIONS (RN) ENABLE
        /
        ALTER TABLE  Z_SCREENING ADD CONSTRAINT C_SCREENING_FUND_FK FOREIGN KEY (FUND)
	          REFERENCES  Z_FUNDS (RN) ENABLE
        /

        create or replace TRIGGER  "ZT_SCREENING_UA_BI"
                        before insert on Z_SCREENING for each row
                        begin
                        -- initialization
                        ---------------------------------------------------------------------------
                        if :new.RN is null then :new.RN := gen_id(); end if;
                        if :new.JUR_PERS is null then :new.JUR_PERS := ZGET_JURPERS(user); end if;
                        if :new.VERSION is null then :new.VERSION := ZGET_VERSION(user); end if;
                        if :new.ORGRN is null then :new.ORGRN := nvl( v('P1_ORGRN'), v('P7_ORGFILTER')); end if;
                        if :new.FUND is null then
                            :new.FUND := v('P1500_FUND');
                            -- :new.FUND := 368476441 ;
                        end if;

                        :new.CREATED := get_time;
                        :new.CREATEU := v('APP_USER');
                        :new.MODIFIED := get_time;
                        :new.CHUSER := v('APP_USER');

                        -- logic
                        ---------------------------------------------------------------------------

                        :new.METHOD   := trim(regexp_replace(:new.METHOD, '^[[:blank:][:cntrl:][:space:]]+|[[:blank:][:cntrl:][:space:]]+$', ' '));
                        :new.CPERSONS := trim(regexp_replace(:new.CPERSONS, '^[[:blank:][:cntrl:][:space:]]+|[[:blank:][:cntrl:][:space:]]+$', ' '));
                        :new.AGE      := trim(regexp_replace(:new.AGE, '^[[:blank:][:cntrl:][:space:]]+|[[:blank:][:cntrl:][:space:]]+$', ' '));
                        :new.RESEARCH := trim(regexp_replace(:new.RESEARCH, '^[[:blank:][:cntrl:][:space:]]+|[[:blank:][:cntrl:][:space:]]+$', ' '));
                end;​

/
ALTER TRIGGER  "ZT_SCREENING_UA_BI" ENABLE
/
