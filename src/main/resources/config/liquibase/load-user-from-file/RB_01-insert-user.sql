delete from USER_EXTRA_ROLES where user_extras_id in (select id from user_extra where created_by='migration');
delete from USER_EXTRA_INSTITUTIONS where user_extras_id in (select id from user_extra where created_by='migration');
delete from USER_EXTRA_BRANCHES where USER_EXTRA_ID in (select id from user_extra where created_by='migration');
delete from user_extra_password_history where user_extra_id in (select id from user_extra where created_by='migration');
delete from USER_EXTRA where created_by='migration';
delete from JHI_USER_AUTHORITY where USER_ID in (select ID from JHI_USER where created_by='migration');
delete from JHI_USER where created_by='migration';

commit;