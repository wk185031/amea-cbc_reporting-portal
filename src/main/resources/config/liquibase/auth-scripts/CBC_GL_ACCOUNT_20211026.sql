INSERT INTO CBC_GL_ACCOUNT (GLA_ID,GLA_NAME,GLA_NUMBER,GLA_LAST_UPDATE_TS,GLA_INSTITUTION) VALUES (CBC_GL_ACCOUNT_SEQUENCE.nextVal, 'Cash Card Tran Clrg', '0012401114', current_timestamp, 'CBC');
INSERT INTO CBC_GL_ACCOUNT (GLA_ID,GLA_NAME,GLA_NUMBER,GLA_LAST_UPDATE_TS,GLA_INSTITUTION) VALUES (CBC_GL_ACCOUNT_SEQUENCE.nextVal, 'Accts. Payable - Cash Card', '50080024535101', current_timestamp, 'CBC');
INSERT INTO CBC_GL_ACCOUNT (GLA_ID,GLA_NAME,GLA_NUMBER,GLA_LAST_UPDATE_TS,GLA_INSTITUTION) VALUES (CBC_GL_ACCOUNT_SEQUENCE.nextVal, 'Cash Card Tran Clrg', '0012401114', current_timestamp, 'CBS');
INSERT INTO CBC_GL_ACCOUNT (GLA_ID,GLA_NAME,GLA_NUMBER,GLA_LAST_UPDATE_TS,GLA_INSTITUTION) VALUES (CBC_GL_ACCOUNT_SEQUENCE.nextVal, 'Accts. Payable - Cash Card', '50080024535101', current_timestamp, 'CBS');
	
COMMIT;