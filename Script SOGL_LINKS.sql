create table Z_SOGLINKS(
    RN       number (17, 0),
    JURPERS  number (17, 0),
    VERSION  number (17, 0),
    SUBTYPE  number (17, 0),
    SOGLKIND number (17, 0),
    MODIFIED TIMESTAMP (6) DEFAULT null,
	CHUSER   VARCHAR2(100) DEFAULT null,
	CREATED  TIMESTAMP (6) DEFAULT null,
	CREATEU  VARCHAR2(100) DEFAULT null,
    CONSTRAINT C_SOGLINKS_RN_PK PRIMARY KEY (RN)
    USING INDEX  ENABLE,
    CONSTRAINT C_SOGLINKS_UK UNIQUE (JURPERS, VERSION, SUBTYPE, SOGLKIND)
    USING INDEX  ENABLE
);

/
    ALTER TABLE  Z_SOGLINKS ADD CONSTRAINT C_SOGLINKS_FK FOREIGN KEY (SUBTYPE)
    	  REFERENCES  Z_SUBTYPE (RN) ENABLE
    /
    ALTER TABLE  Z_SOGLINKS ADD CONSTRAINT C_SOGLINKS_SOGLKIND_FK FOREIGN KEY (SOGLKIND)
          REFERENCES  Z_SOGLKIND (RN) ENABLE
    /
    ALTER TABLE  Z_SOGLINKS ADD CONSTRAINT C_SOGLINKS_JURPERS_FK FOREIGN KEY (JURPERS)
    	  REFERENCES  Z_JURPERS (RN) ENABLE
    /
    ALTER TABLE  Z_SOGLINKS ADD CONSTRAINT C_SOGLINKS_VERSIONS_FK FOREIGN KEY (VERSION)
    	  REFERENCES  Z_VERSIONS (RN) ENABLE

CREATE OR REPLACE TRIGGER  "ZT_SOGLINKS_UA_BI"
before insert on Z_SOGLINKS for each row
begin
  -- initialization
  ---------------------------------------------------------------------------
  if :new.RN is null then :new.RN := gen_id(); end if;
  if :new.JURPERS is null then :new.JURPERS := v('P1_JURPERS'); end if;
  if :new.VERSION is null then :new.VERSION := v('P1_VERSION'); end if;


  :new.CREATED := get_time;
  :new.CREATEU := v('APP_USER');
  :new.MODIFIED := get_time;
  :new.CHUSER := v('APP_USER');

end;
/
ALTER TRIGGER  "ZT_SOGLINKS_UA_BI" ENABLE
/

CREATE OR REPLACE TRIGGER  "ZT_SOGLINKS_UA_BU"
before update on Z_SOGLINKS for each row
declare
nCOUNT number;
begin
  -- initialization
  ---------------------------------------------------------------------------
  :new.MODIFIED := get_time;
  :new.CHUSER := v('APP_USER');
end;
/
ALTER TRIGGER  "ZT_SOGLINKS_UA_BU" ENABLE
/
