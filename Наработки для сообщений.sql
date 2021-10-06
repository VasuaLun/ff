-- Выборка аналитиков из z_users
select * from Z_USERS where upper(POSITION) like 'АНАЛИТИК%'

-- Распределение сообщений по ГРБС
select * from V_MCTICKET_BASE where NJURPERS = 1508934 order by DDATE_CREATE desc SJURPERS  desc
