Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,49,'EBK','EDI','ERI','DEBIT',CURRENT_TIMESTAMP);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,49,'EBK','ECI','ERR','CREDIT',CURRENT_TIMESTAMP);

commit;