-- TODO: Clean all Authentic and DCMS table card,account,transaction data

-- ALTER SESSION SET CURRENT_SCHEMA=ATM5RPT;

delete from password_history;
delete from job_history;

delete from dcms_user_activity;

delete from atm_txn_activity_log;
delete from atm_status_history;
delete from atm_status;
delete from atm_journal_log;
delete from atm_downtime;
delete from atm_device_totals;
delete from atm_device_status;
delete from atm_summary_counters;
delete from atm_summary_values;
delete from cbc_moving_cash;
delete from card_custom;
delete from card_account;
delete from customer;
delete from account;
delete from card;
delete from transaction_log_custom;
delete from transaction_log;
