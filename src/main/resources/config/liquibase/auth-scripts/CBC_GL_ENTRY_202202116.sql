delete from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='ACQUIRER';
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='INTER-ENTITY' and GLE_BP_INCLUDE='*' fetch first row only);
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='INTER-ENTITY' and GLE_BP_INCLUDE='063' fetch first row only);
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='INTER-ENTITY' and GLE_BP_INCLUDE='067' fetch first row only);
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='INTER-ENTITY' and GLE_BP_INCLUDE='019' fetch first row only);

delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='ON-US' and GLE_BP_INCLUDE='*' fetch first row only);
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='ON-US' and GLE_BP_INCLUDE='063' fetch first row only);
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='ON-US' and GLE_BP_INCLUDE='067' fetch first row only);
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='ON-US' and GLE_BP_INCLUDE='019' fetch first row only);
delete from cbc_gl_entry where GLE_ID in (select GLE_ID from cbc_gl_entry where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='ON-US' and GLE_BP_INCLUDE is null);

Insert into CBC_GL_ENTRY (GLE_ID,GLE_GLT_ID,GLE_MAIN_DIRECTION,GLE_TRAN_CHANNEL,GLE_TRAN_TYPE,GLE_CARD_TYPE,GLE_FROM_ACCOUNT_TYPE,GLE_TO_ACCOUNT_TYPE,GLE_TRAN_CODE_EXCLUDE,GLE_BP_SETTLEMENT,GLE_BP_INCLUDE,GLE_BP_EXEMPT,GLE_DEBIT_ACCOUNT,GLE_DEBIT_DESCRIPTION,GLE_CREDIT_ACCOUNT,GLE_CREDIT_DESCRIPTION,GLE_SVC_ENABLED,GLE_SVC_AUTHENTIC,GLE_SVC_AMT,GLE_ENTRY_ENABLED,GLE_ENTRY_SEPARATE,GLE_CREATED_TS,GLE_LAST_UPDATE_TS) 
    values (CBC_GL_ENTRY_SEQUENCE.nextVal,9,'INTER-ENTITY','BRM',250,'Default','00','00',null,null,'065',null,'Accts. Payable - Cash Card - Reg','BANCNET EGOV - SSS','Accts. Payable - EGOV - SSS','BANCNET EGOV - SSS',null,null,null,'N','N',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
Insert into CBC_GL_ENTRY (GLE_ID,GLE_GLT_ID,GLE_MAIN_DIRECTION,GLE_TRAN_CHANNEL,GLE_TRAN_TYPE,GLE_CARD_TYPE,GLE_FROM_ACCOUNT_TYPE,GLE_TO_ACCOUNT_TYPE,GLE_TRAN_CODE_EXCLUDE,GLE_BP_SETTLEMENT,GLE_BP_INCLUDE,GLE_BP_EXEMPT,GLE_DEBIT_ACCOUNT,GLE_DEBIT_DESCRIPTION,GLE_CREDIT_ACCOUNT,GLE_CREDIT_DESCRIPTION,GLE_SVC_ENABLED,GLE_SVC_AUTHENTIC,GLE_SVC_AMT,GLE_ENTRY_ENABLED,GLE_ENTRY_SEPARATE,GLE_CREATED_TS,GLE_LAST_UPDATE_TS) 
    values (CBC_GL_ENTRY_SEQUENCE.nextVal,9,'ON-US','BRM',250,'Default','00','00',null,null,'065',null,'Accts. Payable - Cash Card - Reg','BANCNET EGOV - SSS','Accts. Payable - EGOV - SSS','BANCNET EGOV - SSS',null,null,null,'N','N',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
    
update cbc_gl_entry set GLE_ENTRY_ENABLED='Y' where gle_tran_type=250 and gle_glt_id=9 and gle_tran_channel='BRM' and gle_main_direction='ON-US' and GLE_BP_INCLUDE='*';
update cbc_gl_entry set gle_svc_enabled='Y' where gle_glt_id=11 and gle_debit_account='ACD BEEP Inter-Entity SVC Charge Bridge';
update cbc_gl_entry set gle_svc_enabled='Y' where gle_glt_id=7 and gle_debit_account='ACD Eload SVC Charge Bridge';
update cbc_gl_entry set gle_svc_enabled='Y' where gle_glt_id=12 and gle_debit_account='ACD Inter-Entity IBFT SVC Bridge';
