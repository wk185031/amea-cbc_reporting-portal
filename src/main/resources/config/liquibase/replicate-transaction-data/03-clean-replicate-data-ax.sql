-- Script to delete the load test data in Authentic table

delete from transaction_log where trl_auth_data='9999:fake-data';
delete from transaction_log where trl_auth_data='9000:fake-data';
delete from atm_status_history where ash_seq_nmbr > 1000000;
delete from atm_txn_activity_log where ata_timestamp=to_timestamp('2022-03-10 22:22:22', 'YYYY-MM-DD HH24:MI:SS');
