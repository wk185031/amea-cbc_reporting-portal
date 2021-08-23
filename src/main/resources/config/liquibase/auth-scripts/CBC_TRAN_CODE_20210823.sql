-- Update CTR_CODE = 21 to CREDIT
update CBC_TRAN_CODE set CTR_DEBIT_CREDIT='CREDIT' where CTR_CODE=21;

-- Remove duplicate entry for MBK 01
delete from CBC_TRAN_CODE where CTR_CODE = 1 and CTR_CHANNEL = 'MBK' and CTR_MNEM = 'MXD';

commit;