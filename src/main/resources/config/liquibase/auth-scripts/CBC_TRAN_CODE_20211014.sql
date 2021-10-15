delete from cbc_tran_code where CTR_channel like 'I-%' and ctr_code = 44;
delete from cbc_tran_code where CTR_channel like 'I-%' and ctr_code = 40;
delete from cbc_tran_code where CTR_channel = 'ATM' and ctr_code = 48;

commit;