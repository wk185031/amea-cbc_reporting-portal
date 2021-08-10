-- CBC_GL_ENTRY
update CBC_GL_ENTRY set GLE_SVC_ENABLED = 'Y' WHERE GLE_CREDIT_ACCOUNT = 'Accts Payable - Bancnet Withdrawal TFee';
update CBC_GL_ENTRY set GLE_SVC_ENABLED = 'Y' WHERE GLE_CREDIT_ACCOUNT = 'Accts Payable - Bancnet Inquiry Tfee';

update CBC_GL_ENTRY set GLE_SVC_ENABLED = 'Y' WHERE GLE_CREDIT_ACCOUNT = 'Accts. Payable - Bancnet Instapay TFee';
update CBC_GL_ENTRY set GLE_SVC_ENABLED = 'Y' WHERE GLE_CREDIT_ACCOUNT = 'Accts. Payable - RFID TFee';
update CBC_GL_ENTRY set GLE_TRAN_CHANNEL = 'BNT' where GLE_GLT_ID = (select GLT_ID from CBC_GL_TRANSACTION where GLT_NAME = 'CASH CARD') AND GLE_MAIN_DIRECTION='ISSUER' AND GLE_TRAN_CHANNEL='ATM';

-- CBC_GL_ACCOUNT
insert into CBC_GL_ACCOUNT (gla_id, gla_name, gla_number, gla_last_update_ts, gla_institution) values (cbc_gl_account_sequence.nextval, 'Accts. Payable - BEEP TFee', '50080024537047', current_timestamp, 'CBC');

commit;
