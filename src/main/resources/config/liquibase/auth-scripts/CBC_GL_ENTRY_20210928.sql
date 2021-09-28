insert into cbc_gl_entry (gle_id, gle_glt_id, gle_main_direction, gle_tran_channel, gle_tran_type, gle_card_type, gle_from_account_type, gle_to_account_type, gle_tran_code_exclude, gle_bp_settlement, gle_bp_include, gle_bp_exempt, gle_debit_account, gle_debit_description, gle_credit_account, gle_credit_description, gle_svc_enabled, gle_svc_authentic, gle_svc_amt, gle_entry_enabled, gle_entry_separate, gle_created_ts, gle_last_update_ts)
values (
CBC_GL_ENTRY_SEQUENCE.nextVal, 
(select glt_id from cbc_gl_transaction where glt_name = 'Eload'), 
'ISSUER', 
'ATM', 
1, 
'Default', 
10, 
20, 
null, 
null, 
null, 
null, 
'ACD Eload Bridge', 
'BANCNET ELOAD TRANSACTIONS', 
'Accts. Payable - Bancnet Eload', 
'BANCNET ELOAD TRANSACTIONS',
null, 
null, 
null,
'Y',
'N',
current_timestamp,
current_timestamp
);

insert into cbc_gl_entry (gle_id, gle_glt_id, gle_main_direction, gle_tran_channel, gle_tran_type, gle_card_type, gle_from_account_type, gle_to_account_type, gle_tran_code_exclude, gle_bp_settlement, gle_bp_include, gle_bp_exempt, gle_debit_account, gle_debit_description, gle_credit_account, gle_credit_description, gle_svc_enabled, gle_svc_authentic, gle_svc_amt, gle_entry_enabled, gle_entry_separate, gle_created_ts, gle_last_update_ts)
values (
CBC_GL_ENTRY_SEQUENCE.nextVal, 
(select glt_id from cbc_gl_transaction where glt_name = 'Eload'), 
'ISSUER', 
'ATM', 
1, 
'Default', 
10, 
20, 
null, 
null, 
null, 
null, 
'ACD Eload SVC Charge Bridge', 
'BANCNET ELOAD TRANSACTIONS', 
'Accts. Payable - Bancnet Eload Tfee', 
'BANCNET ELOAD TRANSACTIONS',
null, 
null, 
null,
'N',
'N',
current_timestamp,
current_timestamp
);

commit;