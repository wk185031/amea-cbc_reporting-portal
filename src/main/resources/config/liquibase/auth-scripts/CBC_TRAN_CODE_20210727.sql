-- Update CDM
delete from cbc_tran_code where CTR_CODE='52' and CTR_CHANNEL='CDM' and CTR_MNEM = 'CTD';


insert into CBC_TRAN_CODE values (CBC_TRAN_CODE_SEQUENCE.nextVal, 250, 'CDM', 'CBY', 'N/A', 'DEBIT', current_timestamp);
insert into CBC_TRAN_CODE values (CBC_TRAN_CODE_SEQUENCE.nextVal, 252, 'CDM', 'CPR', 'CRP', 'DEBIT', current_timestamp);
insert into CBC_TRAN_CODE values (CBC_TRAN_CODE_SEQUENCE.nextVal, 246, 'CDM', 'CBL', 'CBX', 'DEBIT', current_timestamp);
insert into CBC_TRAN_CODE values (CBC_TRAN_CODE_SEQUENCE.nextVal, 251, 'CDM', 'CRL', 'CRX', 'DEBIT', current_timestamp);
