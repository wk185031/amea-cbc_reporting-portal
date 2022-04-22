-- CBCUPISSLOG-1267: Fix service charge entry not set to true
update cbc_gl_entry set gle_svc_enabled='Y' where gle_glt_id=9 and GLE_DEBIT_DESCRIPTION='I/E BEEP SERVICE CHARGE';
