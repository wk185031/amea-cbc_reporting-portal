-- CBCAXUPISSLOG-1317: update CBS GL Handoff file and header name

update report_definition set red_file_name_prefix='ATM_CBC02_POS' where red_ins_id=2 and red_name='ATM CBC GL POS 001';
update report_definition set red_file_name_prefix='ATM_CBC02_ELD' where red_ins_id=2 and red_name='ATM CBC GL ELD 001';
update report_definition set red_file_name_prefix='ATM_CBC02_IBFT' where red_ins_id=2 and red_name='ATM CBC GL IBFT 001';
update report_definition set red_file_name_prefix='ATM_CBC02_MVC' where red_ins_id=2 and red_name='ATM CBC GL MVC 001';
update report_definition set red_file_name_prefix='ATM_CBC02_BEEP' where red_ins_id=2 and red_name='ATM CBC GL BEEP 001';
update report_definition set red_file_name_prefix='ATM_CBC02_REC' where red_ins_id=2 and red_name='ATM CBC GL REC 001';
update report_definition set red_file_name_prefix='ATM_CBC02_CASH' where red_ins_id=2 and red_name='ATM CBC GL CASH 001';
update report_definition set red_file_name_prefix='ATM_CBC02_ACQ' where red_ins_id=2 and red_name='ATM CBC GL ACQ 001';
update report_definition set red_file_name_prefix='ATM_CBC02_ISS' where red_ins_id=2 and red_name='ATM CBC GL ISS 001';
update report_definition set red_file_name_prefix='ATM_CBC02_ONUS' where red_ins_id=2 and red_name='ATM CBC GL ONUS 001';
update report_definition set red_file_name_prefix='ATM_CBC02_BP' where red_ins_id=2 and red_name='ATM CBC GL BP 001';
update report_definition set red_file_name_prefix='ATM_CBC02_IE' where red_ins_id=2 and red_name='ATM CBC GL IE 001';

commit;