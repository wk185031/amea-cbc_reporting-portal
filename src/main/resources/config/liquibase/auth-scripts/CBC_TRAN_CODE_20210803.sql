-- release-20210806
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,31,'I-CDM','INQ','N/A','DEBIT',CURRENT_TIMESTAMP);
Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,31,'CDM','INQ','N/A','DEBIT',CURRENT_TIMESTAMP);

update CBC_TRAN_CODE set CTR_CHANNEL='I-CDM' where CTR_CHANNEL='CDM' and CTR_CODE=1 and CTR_MNEM='CWI';
update cbc_tran_code set ctr_channel = concat('I-',CTR_CHANNEL) where ctr_code=48;

update cbc_tran_code set ctr_rev_mnem = 'ABR' where ctr_code = 50 and ctr_channel = 'ATM' and ctr_mnem = 'ABP';
update cbc_tran_code set ctr_rev_mnem = 'MBR' where ctr_code = 50 and ctr_channel = 'MBK' and ctr_mnem = 'MBP';
update cbc_tran_code set ctr_rev_mnem = 'TBR' where ctr_code = 50 and ctr_channel = 'IVR' and ctr_mnem = 'TBP';
update cbc_tran_code set ctr_rev_mnem = 'EBR' where ctr_code = 50 and ctr_channel = 'EBK' and ctr_mnem = 'EBP';
update cbc_tran_code set ctr_rev_mnem = 'CBR' where ctr_code = 50 and ctr_channel = 'CDM' and ctr_mnem = 'CBY';
update cbc_tran_code set ctr_rev_mnem = 'BYR' where ctr_code = 50 and ctr_channel = 'BNT' and ctr_mnem = 'BPY';
update cbc_tran_code set ctr_rev_mnem = 'CBR' where ctr_code = 250 and ctr_channel = 'CDM' and ctr_mnem = 'CBY';
update cbc_tran_code set ctr_rev_mnem = 'BYR' where ctr_code = 250 and ctr_channel = 'BNT' and ctr_mnem = 'BPY';