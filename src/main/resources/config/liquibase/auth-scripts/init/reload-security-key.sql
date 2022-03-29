-- Reload security key in report portal

delete from encryption_key;
delete from secure_key;
delete from security_parameters;
	
insert into encryption_key(select * from <AX_SCHEMA_NAME>.ENCRYPTION_KEY@<AX_DB_LINK>);
insert into secure_key(select * from <AX_SCHEMA_NAME>.SECURE_KEY@<AX_DB_LINK>);
insert into security_parameters(select * from <AX_SCHEMA_NAME>.SECURITY_PARAMETERS@<AX_DB_LINK>);

commit;