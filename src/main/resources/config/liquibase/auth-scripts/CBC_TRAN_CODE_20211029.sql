Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,42,'I-ATM','ADI','ARI','DEBIT',current_timestamp);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,42,'I-ATM','ACI','ARR','CREDIT',current_timestamp);

commit;