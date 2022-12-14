-- ACCOUNT
create index IDX_ACN_ACN_ACCOUNT_NUMBER on ACCOUNT(ACN_ACCOUNT_NUMBER);
create index IDX_ACN_ACN_ISS_ID on ACCOUNT(ACN_ISS_ID);

-- TRANSACTION_LOG
create index IDX_TRL_TRL_TSC_CODE on TRANSACTION_LOG(TRL_TSC_CODE);
create index IDX_TRL_TRL_TQU_ID on TRANSACTION_LOG(TRL_TQU_ID);
create index IDX_TRL_TRL_ACTION_RESPONSE_CODE on TRANSACTION_LOG(TRL_ACTION_RESPONSE_CODE);
create index IDX_TRL_TRL_FRD_REV_INST_ID on TRANSACTION_LOG(TRL_FRD_REV_INST_ID);
create index IDX_TRL_TRL_ISS_NAME on TRANSACTION_LOG(TRL_ISS_NAME);
create index IDX_TRL_TRL_SYSTEM_TIMESTAMP on TRANSACTION_LOG(TRL_SYSTEM_TIMESTAMP);
create index IDX_TRL_TRL_POST_COMP_CODE on TRANSACTION_LOG(TRL_POST_COMPLETION_CODE);
create index IDX_TRL_TRL_CARD_ACPT_TERMINAL_IDENT on TRANSACTION_LOG(TRL_CARD_ACPT_TERMINAL_IDENT);
create index IDX_TRL_TRL_MCC_ID on TRANSACTION_LOG(TRL_MCC_ID);
create index IDX_TRL_TRL_DEO_NAME on TRANSACTION_LOG(TRL_DEO_NAME);
create index IDX_TRL_TRL_EXT_ID on TRANSACTION_LOG(TRL_EXT_ID);
create index IDX_TRL_TRL_ACQR_INST_ID on TRANSACTION_LOG(TRL_ACQR_INST_ID);
create index IDX_TRL_TRL_ACCOUNT_1_ACN_ID on TRANSACTION_LOG(TRL_ACCOUNT_1_ACN_ID);
create index IDX_TRL_TRL_ACCOUNT_2_ACN_ID on TRANSACTION_LOG(TRL_ACCOUNT_2_ACN_ID);

-- TRANSACTION_LOG_CUSTOM
create index IDX_TRLC_TRL_CARD_BIN on TRANSACTION_LOG_CUSTOM(TRL_CARD_BIN);
create index IDX_TRLC_TRL_ORIGIN_CHANNEL on TRANSACTION_LOG_CUSTOM(TRL_ORIGIN_CHANNEL);
create index IDX_TRLC_BILLER_CODE on TRANSACTION_LOG_CUSTOM(TRL_BILLER_CODE);

-- CARD
create index IDX_CRD_CRD_PAN on CARD(CRD_PAN);

-- CARD_PRODUCT
create index IDX_CPD_CPD_CODE on CARD_PRODUCT(CPD_CODE);
create index IDX_CPD_CPD_NAME on CARD_PRODUCT(CPD_NAME);

-- CBC_BANK
create index IDX_CBA_CBA_CODE on CBC_BANK(CBA_CODE);
create index IDX_CBA_CBA_MNEM on CBC_BANK(CBA_MNEM);

-- CBC_BILLER
create index IDX_CBL_CBL_CODE on CBC_BILLER(CBL_CODE);
create index IDX_CBL_CBL_SETTLEMENT_TYPE on CBC_BILLER(CBL_SETTLEMENT_TYPE);

-- CBC_BIN
create index IDX_CBI_CBI_BIN on CBC_BIN(CBI_BIN);

-- CBC_TRAN_CODE
create index IDX_CTR_CTR_CODE on CBC_TRAN_CODE(CTR_CODE);
create index IDX_CTR_CTR_CHANNEL on CBC_TRAN_CODE(CTR_CHANNEL);
create index IDX_CTR_CTR_DEBIT_CREDIT on CBC_TRAN_CODE(CTR_DEBIT_CREDIT);

-- CBC_GL_ENTRY
create index IDX_GLE_GLE_TRAN_TYPE on CBC_GL_ENTRY(GLE_TRAN_TYPE);
create index IDX_GLE_GLE_DEBIT_ACCOUNT on CBC_GL_ENTRY(GLE_DEBIT_ACCOUNT);
create index IDX_GLE_GLE_ENTRY_ENABLED on CBC_GL_ENTRY(GLE_ENTRY_ENABLED);
create index IDX_GLE_GLE_TRAN_CHANNEL on CBC_GL_ENTRY(GLE_TRAN_CHANNEL);
create index IDX_GLE_GLE_SVC_ENABLED on CBC_GL_ENTRY(GLE_SVC_ENABLED);
create index IDX_GLE_GLE_MAIN_DIRECTION on CBC_GL_ENTRY(GLE_MAIN_DIRECTION);
create index IDX_GLE_GLE_BP_INCLUDE on CBC_GL_ENTRY(GLE_BP_INCLUDE);

-- CBC_GL_ACCOUNT
create index IDX_GLA_GLA_NAME on CBC_GL_ACCOUNT(GLA_NAME);
create index IDX_GLA_GLA_INSTITUTION on CBC_GL_ACCOUNT(GLA_INSTITUTION);

-- CBC_GL_TRANSACTION
create index IDX_GLT_GLT_NAME on CBC_GL_TRANSACTION(GLT_NAME);

-- CUSTOMER
create index IDX_CUST_CUST_NUMBER on CUSTOMER(CUST_NUMBER);

-- DCMS_USER_ACTIVITY
create index IDX_DUAC_DUAC_FUNCTION on DCMS_USER_ACTIVITY(FUNCTION);
create index IDX_DUAC_DUAC_CREATED_DATE on DCMS_USER_ACTIVITY(CREATED_DATE);

-- ATM_BRANCHES
create index IDX_ABR_ABR_CODE on ATM_BRANCHES(ABR_CODE);

-- ATM_STATIONS
create index IDX_AST_AST_TERMINAL_ID on ATM_STATIONS(AST_TERMINAL_ID);
create index IDX_AST_ABR_ID on ATM_STATIONS(AST_ABR_ID);
create index IDX_AST_AST_TERMINAL_TYPE on ATM_STATIONS(AST_TERMINAL_TYPE);
create index IDX_AST_AST_DEO_ID on ATM_STATIONS(AST_DEO_ID);

-- ATM_TXN_ACTIVITY_LOG
create index IDX_ATA_ATA_TXN_STATE on ATM_TXN_ACTIVITY_LOG(ATA_TXN_STATE);
create index IDX_ATA_ATA_LAST_UPDATE_TS on ATM_TXN_ACTIVITY_LOG(ATA_LAST_UPDATE_TS);

-- ATM_DEVICE_TOTALS
create index IDX_ATO_ATO_EVENT on ATM_DEVICE_TOTALS(ATO_EVENT);

-- ATM_DEVICE_STATUS
create index IDX_ADS_ADS_DEVICE_ID on ATM_DEVICE_STATUS(ADS_DEVICE_ID);
create index IDX_ADS_ADS_AST_ID on ATM_DEVICE_STATUS(ADS_AST_ID);

-- ATM_JOURNAL_LOG
create index IDX_AJL_AJL_AST_ID on ATM_JOURNAL_LOG(AJL_AST_ID);

-- ATM_STATUS_HISTORY
create index IDX_ASH_ASH_COMM_STATUS on ATM_STATUS_HISTORY(ASH_COMM_STATUS);
create index IDX_ASH_ASH_SERVICE_STATE_REASON on ATM_STATUS_HISTORY(ASH_SERVICE_STATE_REASON);