update cbc_tran_code set ctr_rev_mnem = 'PSR' where ctr_channel = 'BNT' and ctr_rev_mnem = 'POS';
update cbc_tran_code set ctr_debit_credit= 'DEBIT' where ctr_channel = 'BNT' and ctr_code = 122;
update cbc_tran_code set ctr_mnem = 'BTD', ctr_rev_mnem = 'BTR' where ctr_channel = 'ATM' 
and ctr_code = 44 and ctr_debit_credit = 'DEBIT';
update cbc_tran_code set ctr_mnem = 'BTC', ctr_rev_mnem = 'BTT' where ctr_channel = 'ATM' 
and ctr_code = 44 and ctr_debit_credit = 'CREDIT';

commit;