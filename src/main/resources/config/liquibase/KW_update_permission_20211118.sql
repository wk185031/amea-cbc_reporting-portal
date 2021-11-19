-- add menu Action Audit under App Admin
insert into app_resource(code,name,jhi_type,seq_no,depth,created_by,created_date,parent_id) 
  values ('MENU:ActionAudit', 'Menu: ActionAudit', 'MENU', (select max(seq_no) + 1 from app_resource), 2, 'system', current_timestamp, (select id from app_resource where code='MENU:AppAdmin'));
  
insert into app_resource(code,name,jhi_type,seq_no,depth,created_by,created_date,parent_id) 
  values ('OPER:ActionAudit.READ', 'Operation: Read ActionAudit', 'OPER', (select max(seq_no) + 1 from app_resource), 3, 'system', current_timestamp, (select id from app_resource where code='MENU:ActionAudit'));
  
-- remove unused menu
delete from role_extra_permissions where permissions_id = (select id from app_resource where code='MENU:Dashboard');
delete from role_extra_permissions where permissions_id = (select id from app_resource where code='MENU:JobScheduler');
delete from role_extra_permissions where permissions_id = (select id from app_resource where code='MENU:TaskGroup');
delete from role_extra_permissions where permissions_id = (select id from app_resource where code='MENU:Task');

delete from app_resource where code='MENU:Dashboard';
delete from app_resource where code='MENU:JobScheduler';
delete from app_resource where code='MENU:TaskGroup';
delete from app_resource where code='MENU:Task';