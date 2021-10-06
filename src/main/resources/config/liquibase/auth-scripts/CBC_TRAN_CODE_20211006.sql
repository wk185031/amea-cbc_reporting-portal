Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,21,'PGW','BZC','BZT','CREDIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,51,'I-CDM','BRL','BRX','DEBIT',CURRENT_TIMESTAMP);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,122,'I-CDM','BCH','N/A','DEBIT',CURRENT_TIMESTAMP);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,51,'I-ATM','BRL','BRX','DEBIT',CURRENT_TIMESTAMP);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,122,'I-ATM','BCH','N/A','DEBIT',CURRENT_TIMESTAMP);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,40,'I-CDM','CDI','CRI','DEBIT',CURRENT_TIMESTAMP);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,40,'I-CDM','CCI','CRR','CREDIT',CURRENT_TIMESTAMP);

commit;