-- Вставить несколько строк в таблицу
insert all
    into DV_ORGREG (DEPFIN_VERS_RN, GRBS_VERSION, JUR_PERS) values (357976592, 315594486)
    into DV_ORGREG (DEPFIN_VERS_RN, GRBS_VERSION, JUR_PERS) values (357976592, )
select * from dual;

-- Заполнить все NULL значения определенным
update DV_ORGREG
    set VERSION = 1
where VERSION is NULL

-- Изменения значения ячеек в таблице
update DV_ORGREG
    set ADDRESS = 'Moscow, Lenina'
    where ID = 1;

-- Удаление столбца из таблицы

ALTER TABLE DV_SERVREG DROP COLUMN SERV_NAME;
-- Добавление столбца в таблицу
ALTER TABLE DV_SERVREG
ADD SERV_NAME VARCHAR(50) NULL;

-- Создание sequence
create sequence dv_test_sequence
start with 1
increment by 1;
------------------------------------------------------------------------
insert all
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('COVID', 'COVID', 'xCOVID_RES')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('COVID_RES', 'COVID(результаты)', 'xCOVID')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('AdminStatus', 'Администрирование Статусов', 'убрать')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('SetStatus', 'Установка Статусов', 'убрать')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('StaffDict', 'Группа словарей ШТАТ', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('CtrlGroupBudg', 'Группы контроля (бюджетные)', 'xExpAll')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('CtrlGroupKaz', 'Группы контроля (казенные)', 'xExpAll')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('ORG_BUDG', 'Доходы', 'xINCOME')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('GCONTRACT_ADMIN', 'ЗАКУПКИ', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('Z_REQUEST', 'Заявки учреждений', '????')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('ZKP', 'Реестр закупок', 'xZKP')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('Z_SKP_STATUS', 'Реестр закупок(адм.статусов)', 'xZKP')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('GCONTRACT', 'Централизованные закупки', 'xGCONTRACT')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('ExpAll', 'Затраты бюджетные', 'xExpAll')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('Z_SPORT', 'Календарь спортмероприятий', 'xSPORT')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('PFHD_DICT', 'Настройка ПФХД', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('OrgPFHDZakupki', 'ПФХД.Закупки', 'xPFHD')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('OrgPFHDPlan12', 'ПФХД.Плановые периоды', 'xPFHD')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('OrgJustify2', 'Обоснования', 'xPFHD')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('PFHD', 'ПФХД', 'xPFHD')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('UpDocs', 'Раздел "Документы"', 'убрать')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('OBAS', 'Раздел "ОБАС"', 'убрать')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('ObasAdmin', 'ОБАС (Настройка)', 'убрать')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('QIndVals', 'Раздел "Показатели"', 'xQindVals')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('Staff', 'Раздел "Штат"', 'xSTAFF')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('StaffAdmin', 'Раздел "Штат" (Настройка)', 'xSTAFF')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('EffCon', 'Раздел "Эффективный контракт"', 'xEFFCON')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('EffConAdmin', 'Раздел "Эффективный контракт" (настройка)', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('JURPERS', 'Распорядители', 'SUPPORT')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('Versions', 'Версии', 'SUPPORT')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('STAFFING', 'Реестр кадрового учета', 'xSTAFFING')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('PayReestr', 'Реестр платежей', 'xPAYREESTR')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('SCLCARDS', 'Реестр социальных карт', 'xSCLCARDS')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('ServReg', 'Реестр услуг', 'xSERV')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('ServLinks', 'Привязка услуг к учреждениям', 'xSERV')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('OrgReg', 'Реестр учреждений', 'xORG')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('NewsInfo', 'Сервис "Новости распорядителя"', 'xNewsInfo')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('AdminDicts', 'Словари настройки (Администратор)', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('UserDict', 'Словари пользовательские', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('BaseNormative', 'Словарь "Базовые нормативы"', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('KBK', 'Словарь КБК', 'xUserDict')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('Funds', 'Словарь "Целевые средства"', 'xUserDict')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('PArticle', 'Словарь "Целевые статьи"', 'xUserDict')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('QIndList', 'Словарь "Показатели"', 'xUserDict')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('Smeta', 'Словарь "Смета" (казенные)', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('ExpStruct', 'Словарь "Структура затрат"', 'xADM')
into DV_OLDGROUPS (OLDNAME, NOTE, NEW) values ('SmetaDistr', 'Смета (затраты казенные)', 'xADM')
SELECT * FROM dual;

update W_TASK set EXECUTER = 'PARCKAEV' where RN = 362572574

insert into Z_USERS (LOGIN,           PWD,            NAME,  ROLE, , , , , , , , , , , , , , )
             values ('PARCKAEV', 'V@888ya111', 'Пархаев Василий', 0, , , , , , , , , ,, , , )
-- Заполнение таблицы услугinsert all
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_DICMUNTS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_DESC_DISTR')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_REASONCANCEL')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_UPDOCTYPES')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_UPDOCS_INTSTATUS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_DISTRICT')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_SUPPORT_CATEGORY')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_SPGZ')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_SOGLTYPE')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_SOGLKIND')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_SUBTYPE')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_TRANSFER_GRAPH_DETAIL')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_TRANSFER_GRAPH_PERIODS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_TRANSFER_GRAPH')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_TRANSFER_GRAPH_PERIODS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGROUP')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGKIND')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGMARKS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CALC_GROUPS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_QIND_TYPES')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGPROFILES')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PROFILE_KIND')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PROFILE_TYPE')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_SUBPROFILES')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGGOS_CATEGORY')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGGOS_GROUP')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGGOS_STAFF')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGGOS_CATEGORY')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ORGGOS_GROUP')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_KPI_GROUP')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_SPGZ')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_KPGZ')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_KPGZ_SPGZ')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ZKP_VENDOR')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_STAFFING_PAYMENT_TYPES')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_STAFFING_POSITION')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_STAFFING_CONDITION')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_STAFFING_LINKS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_STAFFING_PAYMENT_TYPES')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_STAFFING_CONDITION')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_STAFFING_POSITION')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PAYMENTS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_RESLIST')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPMAT')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_KOSGU')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPKVR_ALL')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPGROUP')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ACCLIST')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPGROUP')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPGROUP2')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ACCLIST')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_FOTYPE')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPMARKS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_FINSOURCES')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PFHD_BASIS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPSMETA_CATEGORY')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPSMETA')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_ACCLIST')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_EXPKVR')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_BASENORM_KOEFF')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_INDUSTRY_KOEFF')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_OBAS_KOEFF')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR_LIMITS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR_DETAIL')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_DESC_DISTR')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR_FUND')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR_CATEGORY')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_KBK_LIMITS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_GTYPE_BS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR_DETAIL')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_DESC_DISTR')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR_FUND')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CTRLGR_CATEGORY')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_GTYPE_BS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PVHD_RPT_DETAIL')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PVHD_RPT')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_CODESTR_PFHD')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PVHD_RPT2')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PRILFORMS_LINKS101')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PAY_LINKS')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_PFHD_FOTYPE')
into DV_NEWGROUPS (ROLE_GROUP, ROLE_TYPE, ROLE, COMM, NOTE, TABLE_NAME) values ('xADM', 'Словари (Адм)', 'ГРБС', 'НП', '', 'Z_INCOME_KIND')
SELECT * FROM dual;

-- Заполнение словаря-списка
insert all
    into DV_CITYDICTIONARY (ID, CITY_NAME) values (1, 'Москва')
    into DV_CITYDICTIONARY (ID, CITY_NAME) values (2, 'Санкт-Петербург')
    into DV_CITYDICTIONARY (ID, CITY_NAME) values (3, 'Самара')
    into DV_CITYDICTIONARY (ID, CITY_NAME) values (4, 'Новосибирск')
    into DV_CITYDICTIONARY (ID, CITY_NAME) values (5, 'Ростов')
SELECT * FROM dual;

-- Заполнение таблицы сопоставления услуг и организаций
insert all
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 1, 1000, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 2, 2000, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 3, 3000, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 4, 1200, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 5, 1300, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 6, 900 , 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 7, 800 , 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 8, 7400, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (4, 1, 2488, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (4, 3, 9800, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 2, 4500, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 3, 6500, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 6, 3000, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 7, 480 , 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 1, 4560, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 7, 6854, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 2, 1547, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 4, 5623, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (5, 7, 1405, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (5, 1, 5870, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (5, 2, 6540, 1)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 1, 1000, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 2, 2000, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 3, 3000, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 4, 1200, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 5, 1300, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 6, 900 , 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 7, 800 , 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (1, 8, 7400, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (4, 1, 2488, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (4, 3, 9800, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 2, 4500, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 3, 6500, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 6, 3000, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (2, 7, 480 , 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 1, 4560, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (5, 2, 6540, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 7, 6854, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 2, 1547, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (3, 4, 5623, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (5, 7, 1405, 2)
    into DV_SERVLINKS (ORG_ID, SERV_ID, SEVRE_PRICE, VERSION) values (5, 1, 5870, 2)
SELECT * FROM dual;

-- Двухуровненвый Join для связи компаний и предоставляемых ими услуг
select org.NAME as orgname, serv.SERV_NAME as servname
from DV_ORGREG org
inner join DV_SERVLINKS link on org.ID = link.ORG_ID
inner join DV_SERVREG serv on link.SERV_ID = serv.ID;

select "ROWID",
"ORG_ID",
"SERV_ID"
from "#OWNER#"."DV_SERVLINKS"


-- Отображение таблицы на странице Учреждения VER 0 (без услуг)
select DV_ORGREG.NAME as NAME,
    DV_CITYDICTIONARY.CITY_NAME as CITY_NAME
 from DV_ORGREG DV_ORGREG,
    DV_CITYDICTIONARY DV_CITYDICTIONARY
 where DV_CITYDICTIONARY.ID=DV_ORGREG.CITY_ID

 -- Отображение таблицы на странице Учреждения VER 1 (с количеством услуг)
select DV_ORGREG.NAME as NAME,
     DV_CITYDICTIONARY.CITY_NAME as CITY_NAME,
     (select COUNT(*) as SERV_COUNT
     from DV_ORGREG DV_ORGREG,
        DV_SERVLINKS DV_SERVLINKS
     where DV_ORGREG.ID = DV_SERVLINKS.ORG_ID
     group by DV_SERVLINKS.ORG_ID)
  from DV_ORGREG DV_ORGREG,
     DV_CITYDICTIONARY DV_CITYDICTIONARY
  where DV_CITYDICTIONARY.ID=DV_ORGREG.CITY_ID

select COUNT(*) as SERV_COUNT
  from DV_ORGREG DV_ORGREG,
     DV_SERVLINKS DV_SERVLINKS
  where DV_ORGREG.ID = DV_SERVLINKS.ORG_ID
  group by DV_SERVLINKS.ORG_ID

select DV_ORGREG.NAME as NAME,
     DV_CITYDICTIONARY.CITY_NAME as CITY_NAME,
     COUNT(DV_SERVLINKS.SERV_ID) as SERV_COUNT
    from DV_ORGREG DV_ORGREG, DV_SERVLINKS DV_SERVLINKS
    left join DV_SERVLINKS DV_SERVLINKS
    on DV_SERVLINKS.ORG_ID = DV_ORGREG.ID
    where DV_ORGREG.ID = DV_SERVLINKS.ORG_ID and
    DV_ORGREG.ID = DV_SERVLINKS.ORG_ID
    group by DV_SERVLINKS.ORG_ID


    select serv.SERV_NAME as display_value, serv.ID as return_value
    from DV_SERVREG serv
    inner join DV_SERVLINKS link on link.SERV_ID = serv.ID
    inner join DV_ORGREG org on link.ORG_ID = org.ID
    where link.ORG_ID = :P22_ID_ORG;

-- Услуги по датам Ver 1
select org.NAME, servejourn.SERV_DATE,
COUNT(servejourn.ID_SERV) as SERV_COUNT
    from DV_ORGREG org,
        DV_SERVJOURNAL servejourn
    where org.ID = servejourn.ID_ORG
    group by servejourn.SERV_DATE, org.NAME
    order by servejourn.SERV_DATE

-- Услуги по датам Ver 2
select org.NAME, servejourn.SERV_DATE,
COUNT(servejourn.ID_SERV) as SERV_COUNT,
SUM()
    from DV_ORGREG org,
        DV_SERVJOURNAL servejourn
    where org.ID = servejourn.ID_ORG
    group by servejourn.SERV_DATE, org.NAME
    order by servejourn.SERV_DATE

-- История совершения услуг Ver 1
select DV_ORGREG.NAME as NAME,
    DV_SERVREG.SERV_NAME as SERV_NAME,
    DV_SERVLINKS.SEVRE_PRICE as SEVRE_PRICE,
    DV_SERVJOURNAL.SERV_DATE as SERV_DATE
 from DV_ORGREG DV_ORGREG,
    DV_SERVJOURNAL DV_SERVJOURNAL,
    DV_SERVREG DV_SERVREG,
    DV_SERVLINKS DV_SERVLINKS
 where DV_SERVJOURNAL.ID_ORG=DV_ORGREG.ID
    and DV_SERVJOURNAL.ID_SERV=DV_SERVREG.ID
    and DV_SERVLINKS.SERV_ID=DV_SERVREG.ID
 order by DV_SERVJOURNAL.SERV_DATE ASC, DV_ORGREG.NAME ASC, DV_SERVREG.SERV_NAME ASC

 -- История совершения услуг Ver2
 select DV_ORGREG.NAME as NAME,
     DV_SERVREG.SERV_NAME as SERV_NAME,
     DV_SERVLINKS.SEVRE_PRICE as SEVRE_PRICE,
     DV_SERVJOURNAL.SERV_DATE as SERV_DATE
  from DV_ORGREG DV_ORGREG,
     DV_SERVLINKS DV_SERVLINKS,
     DV_SERVREG DV_SERVREG,
     DV_SERVJOURNAL DV_SERVJOURNAL
  where DV_SERVJOURNAL.ID_ORG=DV_ORGREG.ID
     and DV_SERVJOURNAL.ID_SERV=DV_SERVREG.ID
     and DV_SERVREG.ID=DV_SERVLINKS.SERV_ID
     and DV_ORGREG.ID=DV_SERVLINKS.ORG_ID
  order by DV_SERVJOURNAL.SERV_DATE ASC, DV_ORGREG.NAME ASC, DV_SERVREG.SERV_NAME ASC

  -- Услуги компаний отображение
  select DV_ORGREG.NAME as NAME,
    DV_SERVREG.SERV_NAME as SERV_NAME,
    DV_SERVLINKS.SEVRE_PRICE as SEVRE_PRICE
 from DV_SERVREG DV_SERVREG,
    DV_ORGREG DV_ORGREG,
    DV_SERVLINKS DV_SERVLINKS
 where DV_ORGREG.ID=DV_SERVLINKS.ORG_ID
    and DV_SERVLINKS.SERV_ID=DV_SERVREG.ID
 order by DV_ORGREG.NAME ASC, DV_SERVREG.SERV_NAME ASC

 select o.ROWID, o.NAME as NAME,
     t.CITY_NAME as CITY_NAME
  from DV_ORGREG o,
     DV_CITYDICTIONARY t
  where (t.ID=o.CITY_ID(+) and o.CITY_ID = :P16_CITY and
 UPPER(o.NAME) like UPPER('%'||:P16_SEARCH||'%')) or
 (t.ID=o.CITY_ID(+) and :P16_CITY is NULL and
 UPPER(o.NAME) like UPPER('%'||:P16_SEARCH||'%'))

 -- Исправленное отображение для Статистики (с учетом версий)
 select j.ROWID, o.NAME as NAME,
     s.SERV_NAME as SERV_NAME,
     L.SEVRE_PRICE as SEVRE_PRICE,
     j.SERV_DATE as SERV_DATE
  from DV_ORGREG o,
     DV_SERVLINKS L,
     DV_SERVREG s,
     DV_SERVJOURNAL j
  where j.ID_ORG=o.A_ID
     and j.ID_SERV=s.A_SERVEID
     and s.ID=L.SERV_ID
     and o.ID=L.ORG_ID
     and j.VERSION = :P1_VERSION
  order by j.SERV_DATE ASC, o.NAME ASC, s.SERV_NAME ASC

  begin
  htp.p('<table border = "1" class="uReport uReportStandard">');
    for rec in
    (
  select ROWID, ID,
  SERV_NAME
  from DV_SERVREG where VERSION = :P1_VERSION
    )LOOP

      htp.p('<tr>');
          htp.p('<td style="background-color: yellow">'||'<a href="f?p=103:19:'||v('APP_SESSION')||'::NO::P19_ID:'||rec.ID||'">Edit</a></td>');
          htp.p('<td><div style="color:red"><b>'||rec.SERV_NAME||'</b></div></td>');
      htp.p('</tr>');
    END LOOP;
   htp.p('</table>');
  end;

-- Пример с массивом для "selecta"
  declare
  type arrayNAME is varray(34) of integer;
  array arrayNAME := arrayNAME();
  begin
  end;

  set serveroutput on size unlimited;
  DECLARE
     TYPE  XX_VAR_TYPE IS VARRAY(100)  OF  NUMBER  ;
     l_array  XX_VAR_TYPE :=  XX_VAR_TYPE(100,200,300,400,500);
    BEGIN
     l_array.TRIM(3);
     FOR I IN 1..l_array.COUNT
     LOOP
     DBMS_OUTPUT.PUT_LINE(l_array(I));
     END LOOP;
   END;

-- Проба работы с ассоциацивным массивом данных
DECLARE
   TYPE ID_t IS TABLE OF DV_ORGREG.ID%TYPE;
   TYPE NAME_t IS TABLE OF DV_ORGREG.NAME%TYPE;
   IDs ID_t;
   NAMEs NAME_t;
BEGIN
   SELECT ID, NAME BULK COLLECT INTO IDs, NAMEs
      FROM DV_ORGREG;
  FOR I IN 1..IDs.COUNT
  LOOP
  DBMS_OUTPUT.PUT_LINE(NAMEs(I));
  END LOOP;
END;

 DECLARE
     TYPE list_of_names_t IS TABLE OF VARCHAR2 (100);

     happyfamily   list_of_names_t := list_of_names_t ();
     children      list_of_names_t := list_of_names_t ();
     parents       list_of_names_t := list_of_names_t ();
  BEGIN
     happyfamily.EXTEND (4);
     happyfamily (1) := ‘Veva’;
     happyfamily (2) := ‘Chris’;
     happyfamily (3) := ‘Eli’;
     happyfamily (4) := ‘Steven’;

     children.EXTEND;
     children (children.LAST) := ‘Chris’;
     children.EXTEND;
     children (children.LAST) := ‘Eli’;

     parents := happyfamily MULTISET EXCEPT children;

     FOR l_row IN 1 .. parents.COUNT
     LOOP
        DBMS_OUTPUT.put_line (parents (l_row));
     END LOOP;
  END;

declare
 TYPE t_tab1 IS RECORD(
    RN number,
    CODE varchar2(100),
    PRN number
 );
 TYPE t_tab_arr1 IS TABLE OF t_tab1;
 regcode T_TAB_ARR1;
begin
    select RN, CODE, PRN BULK COLLECT
    into regcode
    from Z_ORGREG
    where JUR_PERS = 1351099
    order by CODE;
    FOR l_row IN 1 .. parents.COUNT
    LOOP
       DBMS_OUTPUT.put_line (parents (l_row));
    END LOOP;
end;

select distinct l.NAME as NAME,
    l.NUM as NUM,
    o.VERSION as VERSION
                from Z_ORGREG o,
                    Z_EXPALL ea,
                    Z_EXPMAT em,
                    Z_LOV l
              where l.NUM=em.FOTYPE2
                    and em.RN=ea.EXP_ARTICLE
                    and ea.ORGRN=o.RN
                    and o.VERSION = 138308075
                    and l.PART = 'FOTYPE2'
 order by NUM;

 select o.CODE as code,
     (SUM(ea.SERVSUM) + SUM(ea.MSUM)) as expsum,
     l.NAME as name
     from Z_LOV l
     inner join Z_EXPMAT em on l.NUM = em.FOTYPE2
     inner join Z_EXPALL ea on em.RN = ea.EXP_ARTICLE
     inner join Z_ORGREG o  on ea.ORGRN = o.RN
     where o.VERSION = 138308075
           and l.PART = 'FOTYPE2'
     group by name, code
 order by o.RN;

  SELECT ORGRN, SUM(SERVSUM) + SUM(MSUM), FOTYPE2 BULK COLLECT INTO C_EXPALL_ITEMS_SET
FROM Z_EXPALL, Z_EXPMAT WHERE Z_EXPMAT.RN = Z_EXPALL.EXP_ARTICLE
AND  Z_EXPMAT.VERSION = pVERSION AND Z_EXPMAT.JUR_PERS = pJURPERS
GROUP BY Z_EXPALL.ORGRN,  Z_EXPMAT.FOTYPE2
ORDER BY ORGRN;

select  O.A_ORGRN, O.RN ORGRN, substr(L.NAME,1,1) ORGTYPE, nvl(O.SHORT_NAME,O.CODE) ORGNAME, D.CODE DISTRICT, OK.CODE ORGKIND, FL.RN MAIN_FL, G.CODE ORGROUP
  from Z_ORGREG O, Z_LOV L, Z_DISTRICT D, Z_ORGKIND OK, Z_ORGFL FL,  Z_ORGROUP G
 where O.ORGTYPE = L.NUM (+)
   and L.PART (+) = 'ORGTYPE'
   and O.DISTRICT = D.RN(+)
   and O.ORGKIND = OK.RN (+)
   and O.JUR_PERS = pJURPERS
   and O.VERSION  = pVERSION
   and O.CLOSED_SIGN = 0
   and (O.FAKE_SIGN is null or nUSER_SUPPORT = 1)
   and O.RN = FL.ORGRN and FL.CODE = 'ОСНОВНОЙ'
   and O.PRN = G.RN(+)
   and O.RN = nvl(pORGRN, O.RN) --and rownum<15
   and nvl(O.PRN, 0) = nvl(:P2_ORGROUP, nvl(O.PRN, 0))
   and O.ORGTYPE = nvl(:P2_ORGTYPE, O.ORGTYPE)
   and nvl(O.ORGKIND, 0) = nvl(:P2_ORGKIND, nvl(O.ORGKIND, 0))
   and nvl(O.REGION, 0) = nvl(:P2_RFREGIONS, nvl(O.REGION, 0))
   and nvl(O.DISTRICT, 0) = nvl(:P2_DISTRICT, nvl(O.DISTRICT, 0))
   and nvl(O.ORGMARK, 0) = nvl(:P2_ORGMARK, nvl(O.ORGMARK, 0))
   and nvl(O.ORGPROFILE, 0) = nvl(:P2_ORGPROFILE, nvl(O.ORGPROFILE, 0))

   select JURPERS_RN from Z_DEPFIN_GRBS where DEPFIN_RN = rec.RN and rownum = 1 order by RN

-- Запрос для ФинДепартаментов
   select D.RN DEPRN, D.CODE DEPCODE, J.RN JURRN, J.NAME JURCODE, nvl(O.SHORT_NAME,O.CODE) ORGNAME, substr(L.NAME,1,1) ORGTYPE, DIS.CODE DISTRICT, OK.CODE ORGKIND, FL.RN MAIN_FL, GR.CODE ORGROUP
   from Z_DEPFIN D, Z_DEPFIN_GRBS G, Z_JURPERS J, Z_ORGREG O, Z_DEPFIN_VERS_GRBS GRV, Z_LOV L, Z_DISTRICT DIS, Z_ORGKIND OK, Z_ORGFL FL, Z_ORGROUP GR
   where G.DEPFIN_RN = D.RN
   and G.JURPERS_RN = J.RN
   and O.JUR_PERS = J.RN
   and O.VERSION = GRV.GRBS_VERSION
   and O.ORGTYPE = L.NUM (+)
   and L.PART (+) = 'ORGTYPE'
   and O.DISTRICT = DIS.RN(+)
   and O.ORGKIND = OK.RN (+)
   and O.RN = FL.ORGRN and FL.CODE = 'ОСНОВНОЙ'
   and O.PRN = GR.RN(+)

-- Переход на страницу - окно
   sADDEXP  := '<span class="btn btn-primary" style="float:right" onclick="location.href='''||APEX_UTIL.PREPARE_URL('javascript:modalWin();')||'''">Добавить статьи затрат</span>';

   select ZGET_SERVREG_PRNIMG(S.NSERVPRN, S.NPARENT_SIGN) as PRN_IMG,
          S.NSERVRN SERVRN,
          S.NPARENT_SIGN PARENT_SIGN,
          S.SUNIQREGNUM regnum,
          S.SUNIQREGNUM_FULL regnum_full,
          S.SSERVCODE SERVCODE,
          S.NSERVPRN PRN,
          S.SWORKSERV_NAME sPriznak,
          S.SSERVSIGN_CODE sServGroup,
          S.SSERVKIND_NAME sServKind,
          S.SSERVTYPE_NAME sServType,
          S.SCOSTGROUP_NAME sServCost,
          Z_GETSERVCOUNT_FAST(s.nSERVRN, nORGRN) nYplan3
     from ZV_SERVREG S
   where S.nVERSION    = nVERSION
     and ((Upper(S.SREGNUM) like Upper(:P6_SEARCH)||'%')
      or (Upper(S.SSERVCODE) like '%'||Upper(:P6_SEARCH)||'%'))
     and ((:P6_WORKSERV_SIGN is null) or(S.NWORKSERV = :P6_WORKSERV_SIGN))
     and ((:P6_SERVSIGN is null) or (S.NSERVSIGN = :P6_SERVSIGN))
     and ((:P6_SERVTYPE2 is null) or(S.NSERVTYPE = :P6_SERVTYPE2))
     and ((:P6_SERVTYPE is null) or(S.NSERVKIND = :P6_SERVTYPE))
     and ((:P6_COSTGROUP is null) or(S.NCOSTGROUP = :P6_COSTGROUP))
     --and ((:P6_QINDFILT is null) or (Q.RN = :P6_QINDFILT))
     and (S.NSERVRN  in (select L.SERVRN from Z_SERVLINKS L where L.VERSION = nVERSION and L.ORGRN = nORGRN))
   order by S.NORDERNUMB, lpad(REGNUM, 20, ' ')


   SELECT
   DF_V.RN RN,
   DF_V.DEPFIN_RN,
   DF_V.CODE,
   (CASE DEFULT_SIGN WHEN 1 THEN 'Основная' ELSE '-' END) DEFAULT_SIGN,
   (CASE SHOW_SIGN WHEN 1 THEN 'Показывать' ELSE 'Скрыть' END) SHOW_SIGN,
   DF_V.NOTES,
   (
       SELECT COUNT(DISTINCT J.RN)
       FROM Z_DEPFIN_VERS_GRBS DF_VG, Z_DEPFIN_VERS DF_V, Z_VERSIONS V, Z_DEPFIN_GRBS DF_G, Z_JURPERS J
       WHERE DF_VG.DEPFIN_VERS_RN = DF_V.RN
       AND DF_G.JURPERS_RN = V.JUR_PERS
       AND J.RN = V.JUR_PERS
       AND DF_V.DEPFIN_RN = :P2010_RN AND DF_V.RN = RN) nCOUNT
   FROM Z_DEPFIN_VERS DF_V
   WHERE :P2010_RN = DF_V.DEPFIN_RN

    ALTER TABLE H_INCOME_PRILFORMS_DTL
        MODIFY (COEFF NUMBER(19,9) DEFAULT null,
             PLAN1_COEFF number(19,9) default null,
             PLAN2_COEFF number(19,9) default null,
             PLAN3_COEFF number(19,9) default null);

    ALTER TABLE H_INCOME_PRILFORMS_DTL
        ADD ACODE varchar2(35);

        ALTER TABLE H_INCOME_PRILFORMS_DTL
            MODIFY ACODE varchar2(35) default null;

            declare  cursor_returned_no_rows exception;  name_is_null            exception;  cursor c1  is    select emp_id, emp_name    from   emp_test    where  emp_id = 1;  cursor_is_empty boolean := true;begin  for c1_rec in c1  loop    cursor_is_empty := false;    if c1_rec.emp_name is null    then      raise name_is_null;    end if;    insert into dep_test    values (c1_rec.emp_id, c1_rec.emp_name);  end loop;  if cursor_is_empty  then    raise cursor_returned_no_rows;  end if;exception  when cursor_returned_no_rows  then    dbms_output.put_line ('Your exception message here!');  when name_is_null  then    dbms_output.put_line('Name is null');  -- or whatever other handling you may need

select * from Z_ORG_BUDGDETAIL D, Z_FUNDS F
where D.rtype = 5
    and D.VERSION = 349188019
    and D.JUR_PERS = 349188018
    and D. PRN = 349249424
    and D.FUND = F.RN (+)

where F.JUR_PERS = v('P794_JURPERS')
    and F.VERSION = v('P794_VERSION')
    and FO.FUND_RN = F.RN
    and FO.ORG_RN =  v(':P794_ORGRN')

    select *
    from Z_USERS
    where LOGIN in ()

alter table H_INCOME_PRILFORMS_DTL
rename column ACODE to FUND;

ALTER TABLE H_INCOME_PRILFORMS_DTL
modify FUND NUMBER(17,0) DEFAULT null;

select B.JUR_PERS,
    B.VERSION, B.NAME,
    B.SUMMA,
    H.ESUM
from Z_ORG_BUDGDETAIL B,
    Z_BUDGDETAIL_HISTORY H
where B.rn = H.PARENT_ROW
    and B.SUMMA != H.ESUM
order by B.RN

select * from  Z_ZKP_SPECPRICE

select * from  Z_PAY

select * from Z_JURPERS where upper(NAME) like '%ПРЕФЕКТУРА%'

select * from Z_VERSIONS where JUR_PERS = 293293778

select * from Z_QIND_HISTORY where JUR_PERS = 1351099 and VERSION = 344076908 and ORGRN = 344146425 and parent_row = 363165061 order by rn desc

select * from Z_QINDVALS where JUR_PERS = 1351099 and VERSION = 344076908 and QIND = 344078230 order by rn desc

select * from Z_QINDLIST where CODE = 'Соответствие порядкам и стандартам мед. помощи' and JUR_PERS = 1351099 and VERSION = 344076908

select * from Z_USERS where login = 'MOZM759'

select J.NAME, L.SUPOPRT_DATE, L.INFO, L.MODIFIED, L.CHUSER from Z_JURPERS J, Z_SUPPORTLOG L where L.SUPPORT_USER = 'DEMYANOVA' and L.status = 2 and J.RN = L.JUR_PERS order by L.rn desc

-- Добавить в таблицу на прод PRN
ALTER TABLE Z_PURPOSE_OUTCOME
ADD PRN number(17, 0) DEFAULT null


select * from Z_SERVLINKS_NORM

select * from X_FOT where SERV_RN = 350465743

select * from Z_ORGREG where INN = '5031097320' and VERSION = 351290431

select * from Z_JURPERS where rn = 272007622

select * from Z_VERSIONS where JUR_PERS= 272007622

select * from Z_SERVREG where rn = 350465743

select MAT.RN from Z_EXPALL EALL, Z_EXPMAT MAT where EALL.EXP_ARTICLE = MAT.RN and EALL.VERSION = 351290431 and ORGRN in (270793923, 351303311, 351303419)

select * from Z_PRILFORMS_EXPMAT where EXPMAT in (select MAT.RN from Z_EXPALL EALL, Z_EXPMAT MAT where EALL.EXP_ARTICLE = MAT.RN and EALL.VERSION = 351290431 and ORGRN in (270793923, 351303311, 351303419) )

select * from Z_PRILFORMS_EXPMAT

select * from ZV_XPRILFORMS, Z_EXPMAT where nexpmat in (select MAT.RN from Z_EXPALL EALL, Z_EXPMAT MAT where EALL.EXP_ARTICLE = MAT.RN and EALL.VERSION = 351290431 and ORGRN in (270793923, 351303311, 351303419))


select ATTACH_ID,
dbms_lob.getlength(ADD_DOCDATA) ADD_DOCDATA,
ADD_MIMETYPE,
ADD_FILENAME,
ADD_LASTUPDATE,
ADD_CHARSET,
ATTACH_USER
from TBL_ATTACH_FILE

select E.EXPTYPE, EA.SERVRN, sum(EA.SERVSUM) ,
   sum(nvl(EA.SERVSUM,0)) PSUM,
sum(FSERVSUM1)+sum(FSERVSUM2)+sum(FSERVSUM3)+sum(FSERVSUM4) FSUM
  from Z_EXPALL EA, Z_SERVREG SR, Z_EXPMAT E
 where EA.SERVRN     = SR.RN
   and (nvl(EA.SERVSUM,0) > 0 or
        nvl(EA.SERVSUM_0,0) > 0 or
        nvl(EA.SERVSUM_1,0) > 0 or
        nvl(EA.SERVSUM_2,0) > 0 or
        nvl(EA.SERVSUM_3,0) > 0 or
        nvl(EA.SERVSUM_4,0) > 0)
   and SR.WORKSERV_SIGN in (1,3)
   and SR.PARENT_SIGN is null
   and EA.JUR_PERS = 349188018
   and EA.VERSION  = 349188019
   and EA.ORGRN    = 349248213
   and EA.FILIAL   = 349248215
   and EA.VNEBUDG_SIGN = 0
   and EA.EXP_ARTICLE = E.RN
 group by E.EXPTYPE, EA.SERVRN

 select E.EXPTYPE, EA.SERVRN, sum(EA.SERVSUM) ,
    sum(nvl(EA.SERVSUM,0)) PSUM,
 sum(FSERVSUM1)+sum(FSERVSUM2)+sum(FSERVSUM3)+sum(FSERVSUM4) FSUM
   from Z_EXPALL EA, Z_SERVREG SR, Z_EXPMAT E, Z_SERVLINKS SL
  where EA.SERVRN     = SR.RN
    and (nvl(EA.SERVSUM,0) > 0 or
         nvl(EA.SERVSUM_0,0) > 0 or
         nvl(EA.SERVSUM_1,0) > 0 or
         nvl(EA.SERVSUM_2,0) > 0 or
         nvl(EA.SERVSUM_3,0) > 0 or
         nvl(EA.SERVSUM_4,0) > 0)
    and SR.WORKSERV_SIGN in (1,3)
    and SR.PARENT_SIGN is null
    and EA.JUR_PERS = 349188018
    and EA.VERSION  = 349188019
    and EA.ORGRN    = 349248213
    and EA.FILIAL   = 349248215
    and EA.VNEBUDG_SIGN = 0
    and EA.EXP_ARTICLE = E.RN
    and SL.SERVRN = SR.RN
    and SL.ORGRN = 349248213
    and (SL.NORM_EXPGTOUP is NULL or (SL.NORM_EXPGTOUP is not null and E.EXPGROUP is not null))
  group by E.EXPTYPE, EA.SERVRN

  select E.EXPTYPE, EA.SERVRN, sum(EA.SERVSUM) ,
     case pPERIOD when 'NEXTPERIOD' then sum(nvl(EA.SERVSUM,0))
                     when 'MPLAN_02' then sum(nvl(EA.SERVSUM_0,0))
                     when 'MPLAN_01' then sum(nvl(EA.SERVSUM_1,0))
                     when 'PLAN1' then sum(nvl(EA.SERVSUM_2,0))
                     when 'PLAN2' then sum(nvl(EA.SERVSUM_3,0))
                     when 'PLAN3' then sum(nvl(EA.SERVSUM_4,0)) end PSUM,
  sum(FSERVSUM1)+sum(FSERVSUM2)+sum(FSERVSUM3)+sum(FSERVSUM4) FSUM
  from Z_EXPALL EA, Z_SERVREG SR, Z_EXPMAT E, Z_SERVLINKS SL
   where EA.SERVRN     = SR.RN
     and (nvl(EA.SERVSUM,0) > 0 or
          nvl(EA.SERVSUM_0,0) > 0 or
          nvl(EA.SERVSUM_1,0) > 0 or
          nvl(EA.SERVSUM_2,0) > 0 or
          nvl(EA.SERVSUM_3,0) > 0 or
          nvl(EA.SERVSUM_4,0) > 0)
     and SR.WORKSERV_SIGN in (1,3)
     and SR.PARENT_SIGN is null
     and EA.JUR_PERS = pJURPERS
     and EA.VERSION  = pVERSION
     and EA.ORGRN    = pORGRN
     and ((pORGFL is null) or (EA.FILIAL   = pORGFL))
     and EA.VNEBUDG_SIGN = 0
     and EA.EXP_ARTICLE = E.RN
     and SL.SERVRN = SR.RN
     and SL.ORGRN = pORGRN
     and (SL.NORM_EXPGTOUP is NULL or (SL.NORM_EXPGTOUP is not null and E.EXPGROUP is not null))
   group by E.EXPTYPE, EA.SERVRN


   select
   RN,
   JUR_PERS,
   CODE,
   NAME
   from Z_FOTYPE
   where VERSION = 343567920
   order by CODE


   case pQUARTER when 'f1' then vQUARTER := '<th class="header th7" ><div class="th7">ФАКТ 1кв</div></th>'
                     when 'f2' then vQUARTER := '<th class="header th8" ><div class="th8">ФАКТ 2кв</div></th>'
                     when 'f3' then vQUARTER := '<th class="header th9" ><div class="th9">ФАКТ 3кв</div></th>'
                     when 'f4' then vQUARTER := '<th class="header th10" ><div class="th10">ФАКТ 4кв</div></th>'
       end;


       SELECT
          xt.content, xt.position, xt.financialYear, xt.fullName, xt.inn, xt.firstYear, xt.lastYear,
          xtp.law, xtp.content, xtp.supplier, xtp.innSupplier, xtp.contractNumber, xtp.conclusionDate,
          xtp.expirationDate, xtp.reestrNumber, xtp.scheduleNumber, xtp.publicationDate, xtp.identificationCode,
          xtp.methodSupplier

       FROM   Test_xml x,
              XMLTABLE('/calculatePurchaseRamzes'
                PASSING x.xml_data
                COLUMNS
                    content       VARCHAR2(100) PATH '/calculatePurchaseRamzes/header/createDateTime',
                    position      varchar2(100) path '/calculatePurchaseRamzes/position/versionNumber',
                    financialYear varchar2(100) path '/calculatePurchaseRamzes/position/financialYear',
                    firstYear     varchar2(100) path '/calculatePurchaseRamzes/position/firstYear',
                    lastYear      varchar2(100) path '/calculatePurchaseRamzes/position/lastYear',
                    fullName      varchar2(100) path '/calculatePurchaseRamzes/position/institution/fullName',
                    inn           varchar2(100) path '/calculatePurchaseRamzes/position/institution/inn',
                    purchase xmltype path '/calculatePurchaseRamzes/position/purchase'
                ) xt,

                XMLTABLE('/purchase'
                  PASSING xt.purchase
                  COLUMNS
                      law      varchar2(100) path '/purchase/generalInformation/law',
                      content  varchar2(100) path '/purchase/generalInformation/content',
                      supplier varchar2(100) path '/purchase/generalInformation/contractInformation/supplier',
                      innSupplier varchar2(100) path '/purchase/generalInformation/contractInformation/innSupplier',
                      contractNumber varchar2(100) path '/purchase/generalInformation/contractInformation/contractNumber',
                      conclusionDate varchar2(100) path '/purchase/generalInformation/contractInformation/conclusionDate',
                      expirationDate varchar2(100) path '/purchase/generalInformation/contractInformation/expirationDate',
                      reestrNumber  varchar2(100) path '/purchase/generalInformation/purchaseInformation/reestrNumber',
                      scheduleNumber  varchar2(100) path '/purchase/generalInformation/purchaseInformation/scheduleNumber',
                      publicationDate varchar2(100) path '/purchase/generalInformation/purchaseInformation/publicationDate',
                      identificationCode varchar2(100) path '/purchase/generalInformation/purchaseInformation/identificationCode',
                      methodSupplier varchar2(100) path '/purchase/generalInformation/purchaseInformation/methodSupplier',
                      purchaseValue xmltype path '/purchase/purchaseValue'
                ) xtp
       where x.prn = 6


-- Ошибка 9.12.2021 14:00

       select * from Z_FUNDS where SUBCODE = 'УДАЛИТЬ'

       select * from X_ALLSIX_DETAIL where version = 366830712 and FUND in (select RN from Z_FUNDS where SUBCODE = 'УДАЛИТЬ')


       select code from Z_ORGREG where rn = 367631877

       select * from X_ALLSIX where rn = 368109012

       544 страница


       SELECT
                  xt.id, xt.createDateTime, xt.positionId, xt.changeDate, xt.placregNum, xt.placfullName, xt.placinn, xt.plackpp, xt.initregNum, xt.initfullName, xt.initinn,
                  xt.initkpp, xt.versionNumber, xt.reportYear, xt.financialYear,  xt.nextFinancialYear, xt.planFirstYear, xt.planLastYear,
                  xtp.code, xtp.name, xtp.typeserv, xtp.ordinalNumber, xtp.catcode, xtp.catname,
                  xtq.regNum, xtq.name, xtq.code, xtq.symbol, xtq.reportYear, xtq.currentYear, xtq.nextYear, xtq.planFirstYear, xtq.planLastYear,
                  xtv.regNum, xtv.name, xtv.code, xtv.symbol, xtv.reportYear, xtv.currentYear, xtv.nextYear, xtv.planFirstYear, xtv.planLastYear, xti.regNum
              FROM   Test_xml x,
                     XMLTABLE('/stateTask640r'
                       PASSING x.xml_data
                       COLUMNS
                           id             varchar2(300) PATH '/stateTask640r/header/id',
                           createDateTime varchar2(300) path '/stateTask640r/header/createDateTime',
                           positionId     varchar2(300) path '/stateTask640r/body/position/positionId',
                           changeDate     varchar2(300) path '/stateTask640r/body/position/changeDate',
                           placregNum     varchar2(300) path '/stateTask640r/body/position/placer/regNum',
                           placfullName   varchar2(300) path '/stateTask640r/body/position/placer/fullName',
                           placinn        varchar2(300) path '/stateTask640r/body/position/placer/inn',
                           plackpp        varchar2(300) path '/stateTask640r/body/position/placer/kpp',
                           initregNum     varchar2(300) path '/stateTask640r/body/position/initiator/regNum',
                           initfullName   varchar2(300) path '/stateTask640r/body/position/initiator/fullName',
                           initinn        varchar2(300) path '/stateTask640r/body/position/initiator/inn',
                           initkpp        varchar2(300) path '/stateTask640r/body/position/initiator/kpp',
                           versionNumber  varchar2(300) path '/stateTask640r/body/position/versionNumber',
                           reportYear     varchar2(300) path '/stateTask640r/body/position/reportYear',
                           financialYear  varchar2(300) path '/stateTask640r/body/position/financialYear',
                           nextFinancialYear varchar2(300) path '/stateTask640r/body/position/nextFinancialYear',
                           planFirstYear varchar2(300) path '/stateTask640r/body/position/planFirstYear',
                           planLastYear  varchar2(300) path '/stateTask640r/body/position/planLastYear',
                           service xmltype path '/stateTask640r/body/position/service'
                       ) xt,

                           XMLTABLE('/service'
                             PASSING xt.service
                             COLUMNS
                                 code          varchar2(300) path '/service/code',
                                 name          varchar2(300) path '/service/name',
                                 typeserv      varchar2(300) path '/service/type',
                                 ordinalNumber varchar2(300) path '/service/ordinalNumber',
                                 catcode       varchar2(300) path '/service/category/code',
                                 catname       varchar2(300) path '/service/category/name',
                                 qualityIndex xmltype path '/service/qualityIndex',
                                 volumeIndex  xmltype path '/service/volumeIndex',
                                 servindexes  xmltype path '/service/indexes'
                           ) xtp,

                               XMLTABLE('/qualityIndex'
                                 PASSING xtp.qualityIndex
                                 COLUMNS
                                     regNum varchar2(300) path '/qualityIndex/index/regNum',
                                     name   varchar2(300) path '/qualityIndex/index/name',
                                     code   varchar2(300) path '/qualityIndex/index/unit/code',
                                     symbol varchar2(300) path '/qualityIndex/index/unit/symbol',
                                     reportYear varchar2(300) path '/qualityIndex/valueYear/reportYear',
                                     currentYear varchar2(300) path '/qualityIndex/valueYear/currentYear',
                                     nextYear varchar2(300) path '/qualityIndex/valueYear/nextYear',
                                     planFirstYear varchar2(300) path '/qualityIndex/valueYear/planFirstYear',
                                     planLastYear varchar2(300) path '/qualityIndex/valueYear/planLastYear'
                               ) xtq,

                               XMLTABLE('/volumeIndex'
                                 PASSING xtp.volumeIndex
                                 COLUMNS
                                     regNum        varchar2(300) path '/volumeIndex/index/regNum',
                                     name          varchar2(300) path '/volumeIndex/index/name',
                                     code          varchar2(300) path '/volumeIndex/index/unit/code',
                                     symbol        varchar2(300) path '/volumeIndex/index/unit/symbol',
                                     reportYear    varchar2(300) path '/volumeIndex/valueYear/reportYear',
                                     currentYear   varchar2(300) path '/volumeIndex/valueYear/currentYear',
                                     nextYear      varchar2(300) path '/volumeIndex/valueYear/nextYear',
                                     planFirstYear varchar2(300) path '/volumeIndex/valueYear/planFirstYear',
                                     planLastYear  varchar2(300) path '/volumeIndex/valueYear/planLastYear'
                               ) xtv,

                               XMLTABLE('/indexes'
                                 PASSING xtp.servindexes
                                 COLUMNS
                                     regNum        varchar2(300) path '/indexes/regNum'
                               ) xti
              where x.prn = 368557371

              SELECT
                         xt.id, xt.createDateTime, xt.positionId, xt.changeDate, xt.placregNum, xt.placfullName, xt.placinn, xt.plackpp, xt.initregNum, xt.initfullName, xt.initinn,
                         xt.initkpp, xt.versionNumber, xt.reportYear, xt.financialYear,  xt.nextFinancialYear, xt.planFirstYear, xt.planLastYear
                     FROM   Test_xml x,
                            XMLTABLE('/stateTask640r'
                              PASSING x.xml_data
                              COLUMNS
                              id             varchar2(300) PATH '/stateTask640r/header/id',
                              createDateTime varchar2(300) path '/stateTask640r/header/createDateTime',
                              positionId     varchar2(300) path '/stateTask640r/body/position/positionId',
                              changeDate     varchar2(300) path '/stateTask640r/body/position/changeDate',
                              placregNum     varchar2(300) path '/stateTask640r/body/position/placer/regNum',
                              placfullName   varchar2(300) path '/stateTask640r/body/position/placer/fullName',
                              placinn        varchar2(300) path '/stateTask640r/body/position/placer/inn',
                              plackpp        varchar2(300) path '/stateTask640r/body/position/placer/kpp',
                              initregNum     varchar2(300) path '/stateTask640r/body/position/initiator/regNum',
                              initfullName   varchar2(300) path '/stateTask640r/body/position/initiator/fullName',
                              initinn        varchar2(300) path '/stateTask640r/body/position/initiator/inn',
                              initkpp        varchar2(300) path '/stateTask640r/body/position/initiator/kpp',
                              versionNumber  varchar2(300) path '/stateTask640r/body/position/versionNumber',
                              reportYear     varchar2(300) path '/stateTask640r/body/position/reportYear',
                              financialYear  varchar2(300) path '/stateTask640r/body/position/financialYear',
                              nextFinancialYear varchar2(300) path '/stateTask640r/body/position/nextFinancialYear',
                              planFirstYear varchar2(300) path '/stateTask640r/body/position/planFirstYear',
                              planLastYear  varchar2(300) path '/stateTask640r/body/position/planLastYear',
                              service xmltype path '/stateTask640r/body/position/service'
                              ) xt
                     where x.prn = 368557371


 declare
 sERRMSG xmltype;
 begin
 select XML_DATA into sERRMSG from Test_xml where rn = 364814692;
 dbms_output.put_line(sERRMSG.getclobval());
 end;


select * from Z_XML_PARSDATE
where IDENT = :P3032_PRN
  and (lower(:P3032_FIND) like lower(Sv1)
    or lower(:P3032_FIND) like lower(Sv2)
    or lower(:P3032_FIND) like lower(Sv3)
    or lower(:P3032_FIND) like lower(Sv4)
    or lower(:P3032_FIND) like lower(Sv5)
    or lower(:P3032_FIND) like lower(Sv6)
    or lower(:P3032_FIND) like lower(Sv7)
    or lower(:P3032_FIND) like lower(Sv8)
    or lower(:P3032_FIND) like lower(Sv9)
    or lower(:P3032_FIND) like lower(Sv10)
    or lower(:P3032_FIND) like lower(Sv11)
    or lower(:P3032_FIND) like lower(Sv12)
    or lower(:P3032_FIND) like lower(Sv13)
    or lower(:P3032_FIND) like lower(Sv14)
    or lower(:P3032_FIND) like lower(Sv15)
    or lower(:P3032_FIND) like lower(Sv16)
    or lower(:P3032_FIND) like lower(Sv17)
    or lower(:P3032_FIND) like lower(Sv18)
    or lower(:P3032_FIND) like lower(Sv19)
    or lower(:P3032_FIND) like lower(Sv20)
    or lower(:P3032_FIND) like lower(Sv21)
    or lower(:P3032_FIND) like lower(Sv22)
    or lower(:P3032_FIND) like lower(Sv23)
    or lower(:P3032_FIND) like lower(Sv24)
    or lower(:P3032_FIND) like lower(Sv25)
    or lower(:P3032_FIND) like lower(Sv26)
    or lower(:P3032_FIND) like lower(Sv27)
    or lower(:P3032_FIND) like lower(Sv28)
    or lower(:P3032_FIND) like lower(Sv29)
    or lower(:P3032_FIND) like lower(Sv30)
    or lower(:P3032_FIND) like lower(Sv31)
    or lower(:P3032_FIND) like lower(Sv32)
    or lower(:P3032_FIND) like lower(Sv33)
    or lower(:P3032_FIND) like lower(Sv34)
    or lower(:P3032_FIND) like lower(Sv35)
    or lower(:P3032_FIND) like lower(Sv36)
    or lower(:P3032_FIND) like lower(Sv37)
    or lower(:P3032_FIND) like lower(Sv38)
    or lower(:P3032_FIND) like lower(Sv39)
    or lower(:P3032_FIND) like lower(Sv40)
    or lower(:P3032_FIND) like lower(Sv41)
    or lower(:P3032_FIND) like lower(Sv42)
    or lower(:P3032_FIND) like lower(Sv43)
    or lower(:P3032_FIND) like lower(Sv44)
    or lower(:P3032_FIND) like lower(Sv45)
    or lower(:P3032_FIND) like lower(Sv46)
    or lower(:P3032_FIND) like lower(Sv47)
    or lower(:P3032_FIND) like lower(Sv48)
    or lower(:P3032_FIND) like lower(Sv49)
    or lower(:P3032_FIND) like lower(Sv50)
    or :P3032_FIND is null)
order by RN asc

declare
PRN number := :P3032_PRN;
TYPEF number := nvl(:P3032_PARSING_TYPE, 0);
nRES number;
Begin
    ZP_BLOB_TO_XML(PRN);

    if TYPEF = 1 then
        ZP_XML_PARSING(PRN, nRES);
        update TBL_ATTACH_FILE set PARS_PROC = 'ZP_XML_PARSING' where ATTACH_ID = :P3030_RPN;
    elsif TYPEF = 2 then
        ZP_XML_PARSING2(PRN, nRES);
        update TBL_ATTACH_FILE set PARS_PROC = 'ZP_XML_PARSING2' where ATTACH_ID = :P3030_RPN;
    elsif TYPEF = 3 then
        ZP_XML_PARSING3(PRN, nRES);
        update TBL_ATTACH_FILE set PARS_PROC = 'ZP_XML_PARSING3' where ATTACH_ID = :P3030_RPN;
    elsif TYPEF = 4 then
        ZP_XML_PARSING5(PRN, nRES);
        update TBL_ATTACH_FILE set PARS_PROC = 'ZP_XML_PARSING5' where ATTACH_ID = :P3030_RPN;
    else zp_exception(0, 'Выберите тип загруженного файла');
    end if;

    if nRES = 0 then
        zp_exception(0, 'Файл неверно сформирован или выбран неверный тип файла');
    end if;
end;


select NFORMNUM, NKOSGU, NKVR, NFOTYPE2, sum(JUSTIFY) JUSTIFY, sum(OUTCOME) OUTCOME
from
(select NFORMNUM, NKOSGU, NKVR, NFOTYPE2,
sum(nvl(NTOTAL, 0)) JUSTIFY, 0 OUTCOME
from ZV_XPRILFORMS where NORGRN =  367631715
and NFILIAL = 367631741 and NVERSION = 366830712 and  NFORMNUM = 19 and NNO_INCLUDE is null
group by NFORMNUM, NKOSGU, NKVR, NFOTYPE2
union all
select PRILFORM_NUM, E.KOSGURN, E.EXPKVR, E.FOTYPE2, 0,
     sum(nvl(A.SERVSUM,0) + nvl(A.MSUM,0)+ nvl(A.RESTSUM,0))
from Z_EXPALL A, Z_EXPMAT E, Z_PRILFORMS_EXPMAT L
            where A.ORGRN = 367631715
            and A.FILIAL = 367631741
            and A.VERSION = 366830712
            and L.VERSION = A.VERSION
            and L.PRILFORM_NUM = 19
            and A.EXP_ARTICLE = E.RN
            and E.RN          = L.EXPMAT
group by L.PRILFORM_NUM, E.KOSGURN, E.EXPKVR, E.FOTYPE2)
group by NFORMNUM, NKOSGU, NKVR, NFOTYPE2;

select NFORMNUM, NKOSGU, NKVR, NFOTYPE2, sum(JUSTIFY) JUSTIFY, sum(OUTCOME)
from
(select NFORMNUM, NKOSGU, NKVR, NFOTYPE2,
sum(nvl(NTOTAL, 0)) JUSTIFY, 0 OUTCOME
from ZV_XPRILFORMS where NORGRN =  367631715
and NFILIAL = 367631741 and NVERSION = 366830712 and  NFORMNUM = 19 and NNO_INCLUDE is null
group by NFORMNUM, NKOSGU, NKVR, NFOTYPE2
union all
select PRILFORM_NUM, L.KOSGU_RN, L.EXPKVR, L.FOTYPE2, 0,
    sum(nvl(A.SERVSUM,0) + nvl(A.MSUM,0)+ nvl(A.RESTSUM,0))
from Z_EXPALL A, Z_EXPMAT E, Z_PRILFORMS_LINKS101 L
where A.ORGRN     = 367631715
    and A.FILIAL = 367631741
    and A.VERSION     = 366830712
    and L.VERSION     = A.VERSION
    and A.EXP_ARTICLE = E.RN
    and L.PRILFORM_NUM = 19
    and E.FOTYPE2 = L.FOTYPE2
    and e.KOSGURN = L.KOSGU_RN
    and e.EXPKVR  = L.EXPKVR
group by L.PRILFORM_NUM, L.KOSGU_RN, L.EXPKVR, L.FOTYPE2)
group by NFORMNUM, NKOSGU, NKVR, NFOTYPE2;

select count(*)
  from Z_PRILFORMS_EXPMAT D, Z_EXPMAT E,  Z_KOSGU K, Z_LOV L1
 where D.VERSION = 366830712
   and D.EXPMAT = E.RN
   and E.KOSGURN = K.RN
   and E.EXPDIR = L1.NUM and L1.PART = 'EXPDIR'
   and PRILFORM_NUM  = 19;

   select PRILFORM_NUM, L.KOSGU_RN, L.EXPKVR, L.FOTYPE2, 0,
        sum(nvl(A.SERVSUM,0) + nvl(A.MSUM,0)+ nvl(A.RESTSUM,0))
   from Z_EXPALL A, Z_EXPMAT E, Z_PRILFORMS_LINKS101 L
   where A.ORGRN     = 367631715
       and A.FILIAL = 367631741
       and A.VERSION     = 366830712
       and L.VERSION     = A.VERSION
       and A.EXP_ARTICLE = E.RN
       and L.PRILFORM_NUM = 19
       and E.FOTYPE2 = L.FOTYPE2
       and e.KOSGURN = L.KOSGU_RN
       and e.EXPKVR  = L.EXPKVR
   group by L.PRILFORM_NUM, L.KOSGU_RN, L.EXPKVR, L.FOTYPE2

   select NFORMNUM, NKOSGU, NKVR, NFOTYPE2,
   sum(nvl(NTOTAL, 0)) JUSTIFY, 0 OUTCOME
   from ZV_XPRILFORMS where NORGRN =  367631715
   and NFILIAL = 367631741 and NVERSION = 366830712 and  NFORMNUM = 19 and NNO_INCLUDE is null
   group by NFORMNUM, NKOSGU, NKVR, NFOTYPE2

   select V.RN from Z_QINDVALS V, Z_QINDLIST L where PRN in (select L.RN from Z_SERVLINKS L, Z_SERVREG S where L.SERVRN = S.RN and S.WORKSERV_SIGN = 3 and S.VERSION = 344328102) and V.QIND = L.RN and L.QINDSIGN = 2 and nvl(YPLAN3, 0) != 1 and nvl(YPLAN4, 0) != 1 and nvl(YPLAN5, 0) != 1

   alter table Z_QINDVALS set YPLAN3 = 1, YPLAN4 = 1, YPLAN5 = 1 where rn in (344891473, 345536374, 345536371, 345536391, 344891475, 345536344, 344891474, 345536396, 344891476, 344872608, 345536392, 345536370, 344890077, 344872610, 345536375, 345536369, 344872609, 345536372, 345536334, 344890075, 344891471, 344872607, 345536338)

344891473, 345536374, 345536371, 345536391, 344891475, 345536344, 344891474, 345536396, 344891476, 344872608, 345536392, 345536370, 344890077, 344872610, 345536375, 345536369, 344872609, 345536372, 345536334, 344890075, 344891471, 344872607, 345536338


select * from Z_QINDVALS where rn in (344891473, 345536374, 345536371, 345536391, 344891475, 345536344, 344891474, 345536396, 344891476, 344872608, 345536392, 345536370, 344890077, 344872610, 345536375, 345536369, 344872609, 345536372, 345536334, 344890075, 344891471, 344872607, 345536338)

select V.RN from Z_QINDVALS V, Z_QINDLIST L where PRN in (select L.RN from Z_SERVLINKS L, Z_SERVREG S where L.SERVRN = S.RN and S.WORKSERV_SIGN = 3 and S.VERSION = 364129300) and V.QIND = L.RN and L.QINDSIGN = 2 and nvl(YPLAN3, 0) != 1 and nvl(YPLAN4, 0) != 1 and nvl(YPLAN5, 0) != 1 and V.VERSION = 364129300

update Z_QINDVALS set YPLAN3 = 1, YPLAN4 = 1, YPLAN5 = 1 where RN in (select V.RN from Z_QINDVALS V, Z_QINDLIST L where PRN in (select L.RN from Z_SERVLINKS L, Z_SERVREG S where L.SERVRN = S.RN and S.WORKSERV_SIGN = 3 and S.VERSION = 364129300) and V.QIND = L.RN and L.QINDSIGN = 2 and nvl(YPLAN3, 0) != 1 and nvl(YPLAN4, 0) != 1 and nvl(YPLAN5, 0) != 1 and V.VERSION = 364129300)

select * from Z_SERVLINKS

select K.CODE||'-'||E.KOSGU||' '||E.CODE, E.RN
from Z_EXPMAT E, Z_KOSGU K, Z_TRANSFER_GRAPH G
where E.KOSGURN = K.RN
and E.VERSION = :P1_VERSION
and FOTYPE2 = decode(:P529_ETYPE, 0, 4, 4, 5)
and E.RN = G.EXPMAT
and G.RN = :P529_PARENT_ROW

select * from Z_TRANSFER_GRAPH_HISTORY H1, Z_TRANSFER_GRAPH_HISTORY H2 where H1.PARENT_ROW  = H2.PARENT_ROW and H1.PREVSUM = H2.ESUM and H1.EXPMAT is null and H2.EXPMAT is not null order by H1.RN desc

select H1.RN from Z_TRANSFER_GRAPH_HISTORY H1, Z_TRANSFER_GRAPH_HISTORY H2 where H1.PARENT_ROW  = H2.PARENT_ROW and H1.PREVSUM = H2.ESUM and H1.EXPMAT is null and H2.EXPMAT is not null and H1.ORGRN = H2.ORGRN and H1.REDACTION = H2.REDACTION and H1.VERSION = 368475462 order by H1.RN desc

select H.RN, H.ESUM, H.EXPMAT, G.RN, G.SUMMA, G.EXPMAT from Z_TRANSFER_GRAPH_HISTORY H, Z_VERSIONS V, Z_TRANSFER_GRAPH G where H.VERSION = V.RN and V.NEXT_PERIOD = 2022 and G.RN = H.PARENT_ROW and (H.ESUM != G.SUMMA or G.EXPMAT != H.EXPMAT) and NUM = (select max(NUM) from Z_TRANSFER_GRAPH_HISTORY where PARENT_ROW = H.PARENT_ROW)


begin


    select V.RN VERSION
    from Z_TRANSFER_GRAPH TG, Z_VERSIONS V
    where TG.VERSION = V.RN
        and V.NEXT_PERIOD = 2022
        and TG.rn not in
        (select PARENT_ROW from Z_TRANSFER_GRAPH_HISTORY)
        and V.NEW_TRANS_GRAPH = 1 and TG.ORGRN = 364197326
        and TG.JURPERS = 254562839

begin
for rec in (
    select distinct TG.ORGRN, TG.FILIAL, TG.VERSION
    from Z_TRANSFER_GRAPH TG, Z_VERSIONS V
    where TG.VERSION = V.RN
        and V.NEXT_PERIOD = 2022
        and TG.rn not in
        (select PARENT_ROW from Z_TRANSFER_GRAPH_HISTORY)
        and V.NEW_TRANS_GRAPH = 1 and TG.ORGRN = 364197326
        and TG.JURPERS = 254562839
)
loop
    ZP_TRANSFER_GRAPH_LIST_DUBL(254562839, rec.VERSION, rec.ORGRN, rec.FILIAL);
end loop;
end;

select * from Z_ORGREG where rn = 364197326

select * from z_phfd_version where rn =370781868

select REP_PERIOD,   REP_PERIOD sRN from Z_VERSIONS where ((JUR_PERS = :P1501_JUR)  or (:P1501_JUR is NULL and RN = :P1_VERSION)) and VISIBLE_SIGN = 1
union all
select CUR_PERIOD,   CUR_PERIOD sRN from Z_VERSIONS where ((JUR_PERS = :P1501_JUR)  or (:P1501_JUR is NULL and RN = :P1_VERSION)) and VISIBLE_SIGN = 1
union all
select NEXT_PERIOD, NEXT_PERIOD sRN from Z_VERSIONS where ((JUR_PERS = :P1501_JUR)  or (:P1501_JUR is NULL and RN = :P1_VERSION)) and VISIBLE_SIGN = 1

select * from Z_RPT_LIB where numb = 367083409

select * from Z_RPT_LIB_DETAIL where prn = 367083409

select * from Z_VERSIONS

declare
MESS varchar2(4000);
begin
 ZP_CHANGE_YEAR_PROC('ZP_TEST_YEAR2022', '2022', '2023', MESS);
 htp.p(MESS);
end;

select V.CODE VCODE,  V.NAME VNAME, sum(SD.SUMMA), sum(SD.FSUM1)
			  from Z_SMETA_DISTR SD, Z_EXPKVR_ALL V
			 where SD.EXPKVR = V.RN
			--   and ((SD.TYPE_BS = :P232_GTYPE_BS) or (:P232_GTYPE_BS is null))
			   and SD.ORGRN = 364967255
			group by V.CODE,  V.NAME
			   and SD.EXPKVR = :P232_KVR
			   and (SD.KBK = :P232_KBK or :P232_KBK is null)
			   and SD.VERSION=:P1_VERSION
			   and SD.JUR_PERS =:P1_JURPERS
			group by V.CODE,  V.NAME

select ED.KBK, ED.EXPKVR, GB.RN nTYPE_BS, GB.NUMB sTYPE_BS,
               sum(ED.SUMMA) SUMMA,
               sum (ED.FSUM1) FSUM1, sum (ED.FSUM2) FSUM2, sum (ED.FSUM3) FSUM3, sum (ED.FSUM4) FSUM4
            from Z_SMETA_DISTR ED, Z_EXPSMETA  E, Z_GTYPE_BS GB
           where ED.VERSION=364948348
             and ED.PRN is not null
			 and ED.TYPE_BS = GB.RN(+)
             and ED.PRN = E.RN (+)
             and ED.ORGRN = 364967255
and  EXPKVR is null
           group by ED.KBK, ED.EXPKVR, GB.NUMB,GB.RN
           order by ZF_GET_SMETA_KBK2 (KBK, ED.EXPKVR, GB.RN)

           select * from Z_SMETA_DISTR where VERSION = 364948348  and  EXPKVR is null

select * from Z_EXPSMETA where rn in (select PRN from Z_SMETA_DISTR where VERSION = 364948348  and  EXPKVR is null)

select E.CODE, E.RN SMETA, SD.PRN, SD.KVR, SD.RN from Z_EXPSMETA E, Z_SMETA_DISTR SD where SD.PRN = E.RN and SD.VERSION = 364948348  and  SD.EXPKVR is null and E.CODE like '%244%'

select E.CODE, E.RN SMETA, SD.PRN, SD.KVR, SD.RN from Z_EXPSMETA E, Z_SMETA_DISTR SD where SD.PRN = E.RN and SD.VERSION = 364948348  and  SD.EXPKVR is null and E.CODE like '%244%'

update Z_SMETA_DISTR set

364948672 - 244 КВР

select * from Z_EXPKVR where VERSION = 364948348

select * from Z_SPORT_NORM


select * from Z_SMETA_DISTR where VERSION = 364948348  and  EXPKVR is null

select * from Z_EXPSMETA where rn in (select PRN from Z_SMETA_DISTR where VERSION = 364948348  and  EXPKVR is null)

select E.CODE, E.RN SMETA, SD.PRN, SD.KVR, SD.RN from Z_EXPSMETA E, Z_SMETA_DISTR SD where SD.PRN = E.RN and SD.VERSION = 364948348  and  SD.EXPKVR is null and E.CODE like '%244%'

select E.CODE, E.RN SMETA, SD.PRN, SD.KVR, SD.RN from Z_EXPSMETA E, Z_SMETA_DISTR SD where SD.PRN = E.RN and SD.VERSION = 364948348  and  SD.EXPKVR is null and E.CODE like '%244%'

update Z_SMETA_DISTR set

364948672 - 244 КВР

select * from Z_EXPKVR where VERSION = 364948348

select * from Z_SPORT_NORM


select SE.RN MEM_RN, SE.SPORT_EVENT_RN SPORT_RN, SE.MEMBER_TYPE MEMBER_TYPE,
O.COST, O.DAYS, O.COST_FACT, O.DAYS_FACT,
F.CODE sCODE, F.NAME sNAME
from Z_SPORT_EXP SE,
    Z_SPORT_EXP_D O,
    Z_SPORT_EXPTYPES F
where SE.SPORT_EVENT_RN = 359884669
    and O.EXP_RN   = SE.RN
    and O.EXPTYPE_RN = F.RN
    order by F.ORDERNUMB

    select sum(EL.SERVSUM)
    from Z_EXPALL EL, Z_EXPMAT E
    where EL.VERSION = 369267229
        and EL.JUR_PERS = 349188018
        and EL.SERVRN = 369277509
        and EL.ORGRN = 369290067
        and E.RN = EL.EXP_ARTICLE
        and EL.VNEBUDG_SIGN = 0
        and E.EXPGROUP = rec.EG;

select * from Z_SERVREG where version = 369267229

select * from Z_SERVLINKS_NORM where SERVRN = 369277509	and orgrn = 369290067

    select SR.CODE SRCODE, SR.UNIQREGNUM_FULL UNIQREGNUM, EG.CODE EXPGROUP, EG.RN EG,
       nvl(SN.ACCEPT_NORM, 0) *
        nvl(SN.CORRCOEF, 1) *
        nvl(SN.ALIG_COEFF, 1) * nvl(SN.REG_COEFF, 1) * 659405.50 REG_COEFF
    from Z_SERVLINKS SL, Z_SERVREG SR, Z_SERVLINKS_NORM SN, Z_EXPGROUP EG
    where SL.SERVRN = SR.RN
        and SR.VERSION = 369267229
        and SR.JUR_PERS = 349188018
        and SR.RN = 369277509
        and SL.ORGRN = 369290067
        and SN.LINKRN = SL.RN
        and SN.SERVRN = SR.RN
        and EG.RN = SN.EXPGROUP

        declare
        type t_tab1 is record(
            MEM_RN      number,
            SPORT_RN    number,
            MEMBER_TYPE number,
            COST        number,
            DAYS        number,
            COST_FACT   number,
            DAYS_FACT   number,
            SUMMA       number,
            SUMMA_FACT  number,
            EXPTYPE_RN  number,
            SCODE       VARCHAR2(500),
            SNAME       VARCHAR2(500),
            ORDERNUMB   number
            );
          type t_tab_arr1 is table of t_tab1 index BY PLS_INTEGER;
          EXPMET t_tab_arr1;
        begin
        select SE.RN MEM_RN,
                        SE.SPORT_EVENT_RN SPORT_RN,
                        SE.MEMBER_TYPE MEMBER_TYPE,
                        nvl(SUM(O.COST), 0),
                        nvl(SUM(O.DAYS), 0),
                        nvl(SUM(O.COST_FACT), 0),
                        nvl(SUM(O.DAYS_FACT), 0),
                        nvl(SUM(O.SUMMA), 0),
                        nvl(SUM(O.SUMMA_FACT), 0),
                        O.EXPTYPE_RN,
                        F.CODE sCODE,
                        F.NAME sNAME,
                        F.ORDERNUMB
                BULK COLLECT
                INTO EXPMET
                from Z_SPORT_EXP SE,
                    Z_SPORT_EXP_D O,
                    Z_SPORT_EXPTYPES F
                where SE.SPORT_EVENT_RN = 359884669
                    and O.EXP_RN   = SE.RN
                    and O.EXPTYPE_RN = F.RN
                group by SE.RN, F.CODE, F.NAME, F.ORDERNUMB, O.EXPTYPE_RN, SE.MEMBER_TYPE, SE.SPORT_EVENT_RN
                order by F.ORDERNUMB;
        for i in EXPMET.FIRST..EXPMET.COUNT
        loop
            htp.p('MEM_RN  '||EXPMET(I).MEM_RN);
            htp.p('SPORT_RN  '||EXPMET(I).SPORT_RN);
            htp.p('MEMBER_TYPE  '||EXPMET(I).MEMBER_TYPE);
            htp.p('COST  '||EXPMET(I).COST);
            htp.p('DAYS  '||EXPMET(I).DAYS);
            htp.p('COST_FACT  '||EXPMET(I).COST_FACT);
            htp.p('DAYS_FACT  '||EXPMET(I).DAYS_FACT);
            htp.p('SUMMA  '||EXPMET(I).SUMMA);
            htp.p('SUMMA_FACT  '||EXPMET(I).SUMMA_FACT);
            htp.p('EXPTYPE_RN  '||EXPMET(I).EXPTYPE_RN);
            htp.p('SCODE  '||EXPMET(I).SCODE);
            htp.p('SNAME  '||EXPMET(I).SNAME);
            htp.p('ORDERNUMB  '||EXPMET(I).ORDERNUMB);
        end loop;
        htp.p('hello');
        end;

    declare
        p_sub number;
    begin
        if nvl(:P1_ORGRN, :P7_ORGFILTER) is not null and :P1_JURPERS = 161583520 then return true;
        else return false;
        end if;
    end;
declare
    p_old    varchar2(200) := :P1510_OLD_YEAR;
    p_new    varchar2(200) := :P1510_NEW_YEAR;
    p_proc   number := :P1510_PROCNAME;
    p_param  number := :P1510_PARAM;
    p_ver    number := :P1510_VERSION;
    p_vdk    number := :P1510_VDK;
    p_unproc number := :P1510_UNDERPROC;
    p_jur    number := :P1510_JURPERS;
    sMESSAGE varchar2(4000);
begin
    ZP_CHANGE_YEAR_LIB(pPRN       => p_proc,
                       pOLD_YEAR  => p_old,
                       pNEW_YEAR  => p_new,
                       pVDKCOPY   => p_vdk,
                       pVERCOPY   => p_ver,
                       pPARAMCOPY => p_param,
                       pPROCRN    => p_unproc,
                       pJURPERS   => p_
                       sOUTMSG    => sMESSAGE);
    :P1510_COPYED := 1;

    :P1510_JUR    := ;
    :P1510_REP    := p_proc;
    :P1510_DET    := p_unproc;
end;
    P1510_JUR		Hidden
    P1510_REP		Hidden
    P1510_DET


130 = 100000 10
131 = 100000 11
132 = 100001 00
133 = 100001 01


134 = 100001 10
