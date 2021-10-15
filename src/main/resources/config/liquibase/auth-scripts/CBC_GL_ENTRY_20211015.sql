-- insert InstaPay Receivable account
Insert into CBC_GL_ACCOUNT (GLA_ID,GLA_NAME,GLA_NUMBER,GLA_LAST_UPDATE_TS) values (CBC_GL_ACCOUNT_SEQUENCE.nextVal,'Accts. Receivable - Bancnet Instapay','50080012221151',current_timestamp);

-- Update InstaPay receivable account
update CBC_GL_ENTRY set gle_debit_account='Accts. Receivable - Bancnet Instapay' where gle_glt_id=9 and gle_tran_type=21 and gle_tran_channel='PGW';

-- Update PesoNet Fee account
update CBC_GL_ENTRY set gle_debit_account='ACD PesoNet SVC Bridge',gle_debit_description='PESONET TRANSFER CHARGE', gle_credit_description='PESONET TRANSFER CHARGE' where gle_glt_id=9 and gle_tran_type=47 and gle_svc_enabled='Y';


commit;