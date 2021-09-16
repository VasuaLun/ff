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


-- Заполнение таблицы услуг
insert all
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

Z_DICMUNTS
Z_DESC_DISTR
Z_REASONCANCEL
Z_UPDOCTYPES
Z_UPDOCS_INTSTATUS
Z_DISTRICT
Z_SUPPORT_CATEGORY
Z_SPGZ
Z_SOGLTYPE
Z_SOGLKIND
Z_SUBTYPE
Z_TRANSFER_GRAPH_DETAIL
Z_TRANSFER_GRAPH_PERIODS
Z_TRANSFER_GRAPH
Z_TRANSFER_GRAPH_PERIODS
Z_ORGROUP
Z_ORGKIND
Z_ORGMARKS
Z_CALC_GROUPS
Z_QIND_TYPES
Z_ORGPROFILES
Z_PROFILE_KIND
Z_PROFILE_TYPE
Z_SUBPROFILES
Z_ORGGOS_CATEGORY
Z_ORGGOS_GROUP
Z_ORGGOS_STAFF
Z_ORGGOS_CATEGORY
Z_ORGGOS_GROUP
Z_KPI_GROUP
Z_SPGZ
Z_KPGZ
Z_KPGZ_SPGZ
Z_ZKP_VENDOR
Z_STAFFING_PAYMENT_TYPES
Z_STAFFING_POSITION
Z_STAFFING_CONDITION
Z_STAFFING_LINKS
Z_STAFFING_PAYMENT_TYPES
Z_STAFFING_CONDITION
Z_STAFFING_POSITION
Z_PAYMENTS
Z_RESLIST
Z_EXPMAT
Z_KOSGU
Z_EXPKVR_ALL
Z_EXPGROUP
Z_ACCLIST
Z_EXPGROUP
Z_EXPGROUP2
Z_ACCLIST
Z_FOTYPE
Z_EXPMARKS
Z_FINSOURCES
Z_PFHD_BASIS
Z_EXPSMETA_CATEGORY
Z_EXPSMETA
Z_ACCLIST
Z_EXPKVR
Z_BASENORM_KOEFF
Z_INDUSTRY_KOEFF
Z_OBAS_KOEFF
Z_CTRLGR_LIMITS
Z_CTRLGR_DETAIL
Z_DESC_DISTR
Z_CTRLGR
Z_CTRLGR_FUND 
Z_CTRLGR_CATEGORY 
Z_KBK_LIMITS
Z_GTYPE_BS
Z_CTRLGR_DETAIL
Z_DESC_DISTR
Z_CTRLGR
Z_CTRLGR_FUND 
Z_CTRLGR_CATEGORY 
Z_GTYPE_BS
Z_PVHD_RPT_DETAIL
Z_PVHD_RPT
Z_CODESTR_PFHD
Z_PVHD_RPT2
Z_PRILFORMS_LINKS101
Z_PAY_LINKS
Z_PFHD_FOTYPE
Z_INCOME_KIND


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
