delete from cbc_tran_code where ctr_mnem = 'CDI' AND CTR_CHANNEL = 'CDM';
delete from cbc_tran_code where ctr_code = 42 and CTR_CHANNEL like 'I-%';

commit;