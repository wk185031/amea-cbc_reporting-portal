select count(*) from ATM5ADM.cbc_bin;

create table ATM5ADM.cbc_bin_bkup as (select * from ATM5ADM.cbc_bin);

truncate table ATM5ADM.cbc_bin cascade;

insert into ATM5ADM.cbc_bin (select * from ATM5ADM.cbc_bin_bkup where cbi_cba_id not in (select cba_id from ATM5ADM.cbc_bank where cba_code in ('0728','0850')));
  
insert into ATM5ADM.cbc_bin (select * from ATM5ADM.cbc_bin_bkup where cbi_cba_id in (select cba_id from ATM5ADM.cbc_bank where cba_code in ('0728','0850'))
AND CBI_LAST_UPDATE_TS > TO_DATE('20211015 23:59:59','YYYYMMDD HH24:MI:SS'));
  
insert into ATM5ADM.cbc_bin (select * from ATM5ADM.cbc_bin_bkup where cbi_cba_id in (select cba_id from ATM5ADM.cbc_bank where cba_code in ('0728','0850'))
AND CBI_LAST_UPDATE_TS < TO_DATE('20211015 00:00:00','YYYYMMDD HH24:MI:SS'));

commit;

select count(*) from ATM5ADM.cbc_bin;