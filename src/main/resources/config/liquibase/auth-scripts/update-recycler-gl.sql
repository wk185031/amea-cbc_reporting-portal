SET DEFINE OFF;
ALTER SESSION SET CURRENT_SCHEMA = ATM5ADM;

-- CBC_GL_ACCOUNT
insert into CBC_GL_ACCOUNT (GLA_ID,GLA_NAME,GLA_NUMBER,GLA_LAST_UPDATE_TS) values (CBC_GL_ACCOUNT_SEQUENCE.nextVal, 'Cash on Hand - CAM','0010131001', current_timestamp);

alter table CBC_GL_ACCOUNT add GLA_INSTITUTION varchar2(10);

update CBC_GL_ACCOUNT set GLA_INSTITUTION='CBC';


-- add Recycler entry into CBC_GL_ENTRY
insert into CBC_GL_ENTRY (GLE_ID, GLE_GLT_ID, GLE_MAIN_DIRECTION, GLE_TRAN_CHANNEL, GLE_TRAN_TYPE, GLE_CARD_TYPE, GLE_FROM_ACCOUNT_TYPE, GLE_TO_ACCOUNT_TYPE, GLE_TRAN_CODE_EXCLUDE, GLE_BP_SETTLEMENT, GLE_BP_INCLUDE, GLE_BP_EXEMPT, GLE_DEBIT_ACCOUNT, GLE_DEBIT_DESCRIPTION, GLE_CREDIT_ACCOUNT, GLE_CREDIT_DESCRIPTION, GLE_SVC_ENABLED, GLE_SVC_AUTHENTIC, GLE_SVC_AMT, GLE_ENTRY_ENABLED, GLE_ENTRY_SEPARATE, GLE_CREATED_TS, GLE_LAST_UPDATE_TS) 
  values (CBC_GL_ENTRY_SEQUENCE.nextVal, (select GLT_ID from CBC_GL_TRANSACTION where GLT_NAME='Recycler'), 'PROPRIETARY', 'BRM', 1, 'Default', '00', '00', null, null, null, null, 'ACD Withdrawal Bridge', 'ON-US/INTRBRNCH WITHDRAWAL','Cash on Hand - CAM','ON-US/INTRBRNCH WITHDRAWAL',null,null,null,'Y','N',null,current_timestamp);

insert into CBC_GL_ENTRY (GLE_ID, GLE_GLT_ID, GLE_MAIN_DIRECTION, GLE_TRAN_CHANNEL, GLE_TRAN_TYPE, GLE_CARD_TYPE, GLE_FROM_ACCOUNT_TYPE, GLE_TO_ACCOUNT_TYPE, GLE_TRAN_CODE_EXCLUDE, GLE_BP_SETTLEMENT, GLE_BP_INCLUDE, GLE_BP_EXEMPT, GLE_DEBIT_ACCOUNT, GLE_DEBIT_DESCRIPTION, GLE_CREDIT_ACCOUNT, GLE_CREDIT_DESCRIPTION, GLE_SVC_ENABLED, GLE_SVC_AUTHENTIC, GLE_SVC_AMT, GLE_ENTRY_ENABLED, GLE_ENTRY_SEPARATE, GLE_CREATED_TS, GLE_LAST_UPDATE_TS) 
  values (CBC_GL_ENTRY_SEQUENCE.nextVal, (select GLT_ID from CBC_GL_TRANSACTION where GLT_NAME='Recycler'), 'PROPRIETARY', 'BRM', 128, 'Default', '00', '00', null, null, null, null, 'ACD Withdrawal Bridge', 'ON-US/INTRBRNCH WITHDRAWAL','Cash on Hand - CAM','ON-US/INTRBRNCH WITHDRAWAL',null,null,null,'Y','N',null,current_timestamp);

update cbc_tran_code set ctr_channel='BNT' where ctr_channel='OB';
insert into cbc_tran_code values((select max(ctr_id) + 1 from cbc_tran_code), '41','BNT','BXC','BXR','CREDIT',current_timestamp);
update cbc_tran_code set ctr_debit_credit='DEBIT' where ctr_code='40' and ctr_channel='BNT' and ctr_mnem='BXD';
update cbc_tran_code set ctr_debit_credit='CREDIT' where ctr_code='40' and ctr_channel='BNT' and ctr_mnem='BXC';

commit;