update CBC_TRAN_CODE set CTR_REV_MNEM='BTR' where CTR_CODE=44 and CTR_CHANNEL='BNT' and CTR_DEBIT_CREDIT='DEBIT';

delete from cbc_tran_code where ctr_code=1 and ctr_channel='EBK' and ctr_debit_credit='DEBIT' and ctr_mnem='EXD';

ALTER TABLE CBC_TRAN_CODE ADD CONSTRAINT cbc_tran_code_uq UNIQUE (CTR_CODE,CTR_CHANNEL,CTR_DEBIT_CREDIT);

commit;