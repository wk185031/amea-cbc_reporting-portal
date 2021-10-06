update cbc_bin set cbi_cba_id = (select cba_id from cbc_bank where cba_name = 'CHINA BANKING CORPORATION') where cbi_bin = 100200;
delete cbc_bank where cba_name = 'China Banking Corporation (Temp BIN)';

alter table cbc_bank add constraint CBA_CODE_UK unique (cba_code);

commit;