update cbc_tran_code set ctr_mnem='BTD', ctr_rev_mnem='N/A' where ctr_channel='I-CDM' and ctr_code=44 and ctr_debit_credit='DEBIT';
delete from cbc_tran_code where ctr_channel='I-CDM' and ctr_code=44 and ctr_debit_credit='CREDIT';


commit;