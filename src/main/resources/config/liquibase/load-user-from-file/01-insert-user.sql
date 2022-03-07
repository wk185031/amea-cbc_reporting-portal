insert into JHI_USER(LOGIN,PASSWORD_HASH,FIRST_NAME,LAST_NAME,EMAIL,ACTIVATED,LANG_KEY,CREATED_BY,CREATED_DATE) select LOGIN_NAME,'$2a$10$Bb4PEnXPDws1YtKfHJnySOVl/5O8tejT7KpUKGbJ7WQvmp/3KY8Ly',FIRST_NAME,LAST_NAME,EMAIL,1,'en','migration',current_timestamp from LOAD_USER;

insert into JHI_USER_AUTHORITY(user_id,authority_name) select id,'ROLE_USER' from jhi_user where created_by='migration';

insert into USER_EXTRA(NAME,CREATED_BY,CREATED_DATE,USER_ID,LOGIN_FLAG) select (FIRST_NAME || ' ' || LAST_NAME), CREATED_BY, CREATED_DATE, ID, 0 from JHI_USER where CREATED_BY = 'migration';

insert into USER_EXTRA_BRANCHES(USER_EXTRA_ID,BRANCH_ID) select ue.id,lu.branch_code from JHI_USER u join USER_EXTRA ue on u.ID=ue.USER_ID join LOAD_USER lu on u.LOGIN=lu.LOGIN_NAME where u.CREATED_BY='migration' and lu.BRANCH_CODE is not null;

insert into USER_EXTRA_INSTITUTIONS(USER_EXTRAS_ID,INSTITUTIONS_ID) select ue.id,22 from JHI_USER u join USER_EXTRA ue on u.ID=ue.USER_ID join LOAD_USER lu on u.LOGIN=lu.LOGIN_NAME where lu.INSTITUTION_CODE='CBC';
insert into USER_EXTRA_INSTITUTIONS(USER_EXTRAS_ID,INSTITUTIONS_ID) select ue.id,2 from JHI_USER u join USER_EXTRA ue on u.ID=ue.USER_ID join LOAD_USER lu on u.LOGIN=lu.LOGIN_NAME where lu.INSTITUTION_CODE='CBS';

insert into USER_EXTRA_ROLES(USER_EXTRAS_ID,ROLES_ID) select ue.id,re.id from JHI_USER u join USER_EXTRA ue on u.ID=ue.USER_ID join LOAD_USER lu on u.LOGIN=lu.LOGIN_NAME join ROLE_EXTRA re on lu.ROLE_NAME=re.NAME;

commit;