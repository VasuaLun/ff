-- Выборка аналитиков из z_users
select * from Z_USERS where upper(POSITION) like 'АНАЛИТИК%'
