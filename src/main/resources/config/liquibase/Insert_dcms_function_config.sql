insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Account_De-linking','Pattern for Account De-linking','.*(Account Delinked)$','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Account_linking','Pattern for Account linking','.*(Account linked)$','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Card_Activation','Pattern for Card Activation','^Status.*(ACTIVE)$','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Renewal_Replace','Pattern for Renewal/Replacement','.*(Renewed|Replaced).*','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Close_Card','Pattern for Close Card','^Status.*(CLOSED)$','system',current_timestamp,null,null);		
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Default_Account_Change','Pattern for Default Account Change','Default account updated','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Hotlist','Pattern for Hotlist','^Status.*(BLOCKED|LOST|STOLEN)$','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Dehotlist','Pattern for Dehotlist','^(Status changed from BLOCKED).*(ACTIVE)$','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Repin','Pattern for Repin','.*(Repin).*','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Reset_Pin_Counter','Pattern for Reset Pin Counter','.*(Reset Pin).*','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Stop_Card_Renewal','Pattern for Stop_Card_Renewal','(Auto renewal).*','system',current_timestamp,null,null);
insert into system_configuration (id, name, description, config, created_by, created_date, last_modified_by, last_modified_date) values 
	((select max(id) + 1 from system_configuration),'dcms.function.pattern.Transaction_Limit_Update','Pattern for Transaction Limit Update','(Transaction limit).*','system',current_timestamp,null,null);	