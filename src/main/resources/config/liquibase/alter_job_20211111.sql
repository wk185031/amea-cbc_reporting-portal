update job set table_sync = 'ACCOUNT,ACCOUNT_TYPE,ATM_SUMMARY_COUNTERS,ATM_SUMMARY_VALUES,BRANCH,CARD,CARD_ACCOUNT,CARD_PRODUCT,CUSTOMER,CBC_MOVING_CASH,CBC_BANK,CBC_BIN,CBC_BILLER,CBC_TRAN_CODE,CBC_GL_TRANSACTION,CBC_GL_ACCOUNT,CBC_GL_ENTRY,ATM_STATIONS,ATM_BRANCHES,ATM_STATUS,ATM_STATUS_HISTORY,ATM_DEVICE_STATUS,ATM_DEVICE_TOTALS,ATM_TXN_ACTIVITY_LOG,ATM_JOURNAL_LOG,AUTH_RESULT_CODE,ENCRYPTION_KEY,SECURE_KEY,SECURITY_PARAMETERS,TRANSACTION_CODE,TRANSACTION_LOG,MERCHANT,TABLE_DETAILS,DEVICE_ESTATE_OWNER,ISSUER,AUTH_PROCESSING_PROFILE' where name = 'DB_SYNC';

commit;