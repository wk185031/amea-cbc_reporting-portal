-- CBCUPISSLOG-1334: Enable eGov and disable CASA biller

-- ATM
update cbc_gl_entry set gle_entry_enabled='Y' where gle_glt_id=5 and gle_debit_description in ('BANCNET EGOV-PHILHEALTH', 'BANCNET EGOV-PAG IBIG', 'BANCNET EGOV - SSS');
update cbc_gl_entry set gle_entry_enabled='N' where gle_glt_id=5 and gle_debit_description = 'ATM BILLS PAYMENT';

-- Cash Card
update cbc_gl_entry set gle_entry_enabled='Y' where gle_glt_id=9 and gle_tran_type in (50,250) and GLE_BP_INCLUDE in ('063','065','067');
update cbc_gl_entry set gle_entry_enabled='N' where gle_glt_id=9 and gle_tran_type in (50,250) and gle_debit_description = 'ATM BILLS PAYMENT';

-- Recycler
update cbc_gl_entry set gle_entry_enabled='Y' where gle_glt_id=10 and gle_tran_type in (50,250) and GLE_BP_INCLUDE in ('063','065','067');
update cbc_gl_entry set gle_entry_enabled='N' where gle_glt_id=10 and gle_tran_type in (50,250) and gle_debit_description = 'ATM BILLS PAYMENT';
