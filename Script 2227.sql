-- Добавить чекбокс группы затрат по периодам
ALTER TABLE Z_SERVLINKS
    ADD NORM_EXPGTOUP number default null;

-- Переименованно поле сумма для итога очередного года
alter table Z_SERVLINKS_NORM
    rename column SUMMA to ACCEPT_NORM;

alter table Z_SERVLINKS_NORM
    add (
        ACCEPT_NORM2 number default null, -- сумма по периодам
        ACCEPT_NORM3 number default null,
        ALIG_COEFF   number default null, -- отраслевой коэффицент
        REG_COEFF    number default null, -- территориальный коэффицент
        CORRCOEF     number default null, -- коэффицент выравнивания
        CORRCOEF2    number default null,
        CORRCOEF3    number default null
    );

-- 1. Внести изменения в таблицу
-- 2. Добавить ITEM NORM_EXPGTOUP на 22 страницу
-- 3. Поменять тир вывода региона Норматив по затратам услуг, если NORM_EXPGTOUP is not NULL

-- Временная таблица для загрузчика
CREATE GLOBAL TEMPORARY TABLE  UDO_SERVNORM
   (INN VARCHAR2(50) DEFAULT NULL,
	UNIQREGNUM VARCHAR2(4000) DEFAULT NULL,
	SERV_CODE VARCHAR2(4000) DEFAULT NULL,
	SERV_NAME VARCHAR2(4000) DEFAULT NULL,
	EXPGROUP VARCHAR2(4000) DEFAULT NULL,
    ACCEPT_NORM varchar2(4000) DEFAULT NULL,
    ACCEPT_NORM2 varchar2(4000) DEFAULT NULL,
    ACCEPT_NORM3 varchar2(4000) DEFAULT NULL,
    ALIG_COEFF varchar2(4000) DEFAULT NULL,
    REG_COEFF varchar2(4000) DEFAULT NULL,
    CORRCOEF varchar2(4000) DEFAULT NULL,
    CORRCOEF2 varchar2(4000) DEFAULT NULL,
    CORRCOEF3 varchar2(4000) DEFAULT NULL,
    IDENT VARCHAR2(4000) DEFAULT NULL
   ) ON COMMIT PRESERVE ROWS

 alter table UDO_SERVNORM add IDENT VARCHAR2(4000) DEFAULT NULL


insert into A_XLSLOADTYPE (CODE, NAME, APPNUM, PART) values('ЗагрузкаНормативов','Загрузка нормативов по группам затрат', 101, 'BASE_NORM')


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE  "Z_SERVLINKS_NORM"
   (	"RN" NUMBER(17,0) NOT NULL ENABLE,
	"JUR_PERS" NUMBER(17,0) NOT NULL ENABLE,
	"VERSION" NUMBER(17,0) NOT NULL ENABLE,
	"LINKRN" NUMBER(17,0) NOT NULL ENABLE,
	"EXPGROUP" NUMBER(17,0) NOT NULL ENABLE,
	"ORGRN" NUMBER(17,0) NOT NULL ENABLE,
	"SERVRN" NUMBER(17,0) NOT NULL ENABLE,
	"SUMMA" NUMBER(19,9) DEFAULT NULL,
	"MODIFIED" TIMESTAMP (6) NOT NULL ENABLE,
	"CHUSER" VARCHAR2(100) NOT NULL ENABLE,
	"CREATEU" VARCHAR2(100) NOT NULL ENABLE,
	"CREATED" TIMESTAMP (6) NOT NULL ENABLE,
	 CONSTRAINT "C_SERVLINKS_NORM_RN_PK" PRIMARY KEY ("RN")
  USING INDEX  ENABLE,
	 CONSTRAINT "C_SERVLINKS_NORM_UK" UNIQUE ("JUR_PERS", "VERSION", "LINKRN", "EXPGROUP")
  USING INDEX  ENABLE
   )
/
ALTER TABLE  "Z_SERVLINKS_NORM" ADD CONSTRAINT "C_SERVLINKS_NORM_EXPGROUP_FK" FOREIGN KEY ("EXPGROUP")
	  REFERENCES  "Z_EXPGROUP" ("RN") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "Z_SERVLINKS_NORM" ADD CONSTRAINT "C_SERVLINKS_NORM_JURPERS_FK" FOREIGN KEY ("JUR_PERS")
	  REFERENCES  "Z_JURPERS" ("RN") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "Z_SERVLINKS_NORM" ADD CONSTRAINT "C_SERVLINKS_NORM_LINKRN_FK" FOREIGN KEY ("LINKRN")
	  REFERENCES  "Z_SERVLINKS" ("RN") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "Z_SERVLINKS_NORM" ADD CONSTRAINT "C_SERVLINKS_NORM_ORGRN_FK" FOREIGN KEY ("ORGRN")
	  REFERENCES  "Z_ORGREG" ("RN") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "Z_SERVLINKS_NORM" ADD CONSTRAINT "C_SERVLINKS_NORM_SERVRN_FK" FOREIGN KEY ("SERVRN")
	  REFERENCES  "Z_SERVREG" ("RN") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "Z_SERVLINKS_NORM" ADD CONSTRAINT "C_SERVLINKS_NORM_VERSION_FK" FOREIGN KEY ("VERSION")
	  REFERENCES  "Z_VERSIONS" ("RN") ENABLE
/

CREATE INDEX  "ZI_SERVLINKS_NORM_EXPGROUP_FK" ON  "Z_SERVLINKS_NORM" ("EXPGROUP")
/

CREATE INDEX  "ZI_SERVLINKS_NORM_JURPERS_FK" ON  "Z_SERVLINKS_NORM" ("JUR_PERS")
/

CREATE INDEX  "ZI_SERVLINKS_NORM_LINKRN_FK" ON  "Z_SERVLINKS_NORM" ("LINKRN")
/

CREATE INDEX  "ZI_SERVLINKS_NORM_ORGRN_FK" ON  "Z_SERVLINKS_NORM" ("ORGRN")
/

CREATE INDEX  "ZI_SERVLINKS_NORM_SERVRN_FK" ON  "Z_SERVLINKS_NORM" ("SERVRN")
/

CREATE INDEX  "ZI_SERVLINKS_NORM_VERSION_FK" ON  "Z_SERVLINKS_NORM" ("VERSION")
/

CREATE OR REPLACE TRIGGER  "ZT_SERVLINKS_NORM_UA_BD"
before delete on Z_SERVLINKS_NORM for each row
begin
    -- permission
    ---------------------------------------------------------------------------
    ZF_CHECKPRIV2 (pJURPERS => :old.JUR_PERS,
                   pVERSION => :old.VERSION,
                   pUSER    => v('APP_USER'),
                   pPART    => 'ServLinks');
end;
/
ALTER TRIGGER  "ZT_SERVLINKS_NORM_UA_BD" ENABLE
/

CREATE OR REPLACE TRIGGER  "ZT_SERVLINKS_NORM_UA_BI"
before insert on Z_SERVLINKS_NORM for each row
declare
    nCNT number;
begin
    -- initialization
    ---------------------------------------------------------------------------
    if :new.RN is null then :new.RN := gen_id(); end if;
    if :new.JUR_PERS is null then :new.JUR_PERS := v('P1_JURPERS'); end if;
    if :new.VERSION is null then :new.VERSION := v('P1_VERSION'); end if;

    :new.CREATED := get_time;
    :new.CREATEU := v('APP_USER');
    :new.MODIFIED := get_time;
    :new.CHUSER := v('APP_USER');

    -- permission
    ---------------------------------------------------------------------------
    ZF_CHECKPRIV2 (pJURPERS => :new.JUR_PERS,
                   pVERSION => :new.VERSION,
                   pUSER    => v('APP_USER'),
                   pPART    => 'ServLinks');

    -- logic
    ---------------------------------------------------------------------------
   select ORGRN, SERVRN
    into :new.ORGRN, :new.SERVRN
    from Z_SERVLINKS
   where RN = :new.LINKRN;
end;
/
ALTER TRIGGER  "ZT_SERVLINKS_NORM_UA_BI" ENABLE
/

CREATE OR REPLACE TRIGGER  "ZT_SERVLINKS_NORM_UA_BU"
before update on Z_SERVLINKS_NORM for each row
begin
    -- initialization
    ---------------------------------------------------------------------------
    :new.MODIFIED := get_time;
    :new.CHUSER := v('APP_USER');

    -- permission
    ---------------------------------------------------------------------------
    ZF_CHECKPRIV2 (pJURPERS => :new.JUR_PERS,
                   pVERSION => :new.VERSION,
                   pUSER    => v('APP_USER'),
                   pPART    => 'ServLinks');

    -- logic
    ---------------------------------------------------------------------------
end;
/
ALTER TRIGGER  "ZT_SERVLINKS_NORM_UA_BU" ENABLE
/
