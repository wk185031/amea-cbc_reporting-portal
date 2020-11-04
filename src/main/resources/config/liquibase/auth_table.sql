CREATE TABLE TABLE_DETAILS 
   (	
    "TDE_TABLE_NAME" VARCHAR2(40 BYTE) NOT NULL ENABLE, 
	"TDE_SEQ_NAME" VARCHAR2(40 BYTE), 
	"TDE_SEQ_COL" VARCHAR2(40 BYTE), 
	"TDE_CACHE_TYPE" VARCHAR2(2 BYTE), 
	"TDE_SHORT_NAME" VARCHAR2(5 BYTE), 
	"TDE_TABLE_TABLESPACE" VARCHAR2(50 BYTE), 
	"TDE_INDEX_TABLESPACE" VARCHAR2(50 BYTE), 
	"TDE_HIGH_VOLUME" VARCHAR2(1 BYTE), 
	"TDE_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"TDE_PARTITION_KEY" VARCHAR2(31 BYTE), 
	"TDE_PARTITION_INTERVAL" NUMBER(5,0), 
	"TDE_CLUSTERED" CHAR(1 BYTE) DEFAULT 'Y', 
	 CONSTRAINT "TDE_PK" PRIMARY KEY ("TDE_TABLE_NAME")
  ) TABLESPACE AUTH_REPORT_DATA_TS;

 CREATE TABLE ACCOUNT 
   (	
    "ACN_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ACN_ATP_ID" NUMBER(19,0), 
	"ACN_ACCOUNT_NUMBER" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	"ACN_APD_ID" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"ACN_STATUS" VARCHAR2(2 BYTE) NOT NULL ENABLE, 
	"ACN_STATUS_DATE" DATE, 
	"ACN_DELINQUENCY" VARCHAR2(2 BYTE), 
	"ACN_DELINQUENCY_DATE" DATE, 
	"ACN_CUR_ID" NUMBER(5,0), 
	"ACN_AMT_CODE_1" NUMBER(10,0), 
	"ACN_BALANCE_1" NUMBER(19,0), 
	"ACN_AMT_CODE_2" NUMBER(10,0), 
	"ACN_BALANCE_2" NUMBER(19,0), 
	"ACN_AMT_CODE_3" NUMBER(10,0), 
	"ACN_BALANCE_3" NUMBER(19,0), 
	"ACN_LAST_BATCH_UPDATE_DATE" DATE, 
	"ACN_CREDIT_LIMIT" NUMBER(19,0), 
	"ACN_TEMP_CREDIT_LIMIT" NUMBER(19,0), 
	"ACN_TEMP_CREDIT_LIMIT_DATE" DATE, 
	"ACN_GUARANTEE_AMOUNT" NUMBER(19,0), 
	"ACN_GUARANTEE_TYPE" VARCHAR2(2 BYTE), 
	"ACN_GUARANTEE_EXPIRY_DATE" DATE, 
	"ACN_LAST_FEP_HOST_TRACE_NBR" NUMBER(10,0), 
	"ACN_LAST_HOST_FEP_TRACE_NBR" NUMBER(10,0), 
	"ACN_SPECIFIC_DATA" VARCHAR2(1250 BYTE), 
	"ACN_PART_NO" NUMBER(10,0), 
	"ACN_CUSTOM_DATA" VARCHAR2(4000 BYTE), 
	"ACN_STATUS_2" VARCHAR2(2 BYTE), 
	"ACN_STATUS_2_DATE" DATE, 
	"ACN_LAST_SOURCE" VARCHAR2(5 BYTE), 
	"ACN_LAST_TERMINAL_ID" VARCHAR2(20 BYTE), 
	"ACN_FEP_HOST_SUM" NUMBER(10,0), 
	"ACN_HOST_FEP_SUM" NUMBER(10,0), 
	"ACN_PAN" VARCHAR2(128 BYTE), 
	"ACN_LAST_BATCH_SESSION" NUMBER(10,0), 
	"ACN_FUNCTIONS" VARCHAR2(20 BYTE), 
	"ACN_OVERRIDE_PERMISSION" VARCHAR2(1 BYTE), 
	"ACN_ISS_ID" NUMBER(19,0), 
	"ACN_LIMIT_CONFIG" VARCHAR2(4000 BYTE), 
	"ACN_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"ACN_ACCOUNT_NUMBER_EKY_ID" NUMBER(19,0), 
	"ACN_PAN_EKY_ID" NUMBER(19,0), 
	 CONSTRAINT "ACN_PK" PRIMARY KEY ("ACN_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;


  
CREATE TABLE ACCOUNT_TYPE 
   (	
    "ATP_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ATP_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ATP_ISO_ID" NUMBER(19,0), 
	"ATP_ATG_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ATP_INTERNAL_ID" NUMBER(19,0), 
	"ATP_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "ATP_PK" PRIMARY KEY ("ATP_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;  
  
CREATE TABLE CARD_ACCOUNT 
   (	
    "CAT_CRD_ID" NUMBER(19,0) NOT NULL ENABLE, 
    "CAT_ACN_ID" NUMBER(19,0) NOT NULL ENABLE, 
    "CAT_DEFAULT_FOR_TYPE" VARCHAR2(1 BYTE), 
    "CAT_OVERALL_DEFAULT" VARCHAR2(1 BYTE), 
    "CAT_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp,
	 CONSTRAINT "CAT_PK" PRIMARY KEY ("CAT_CRD_ID", "CAT_ACN_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ; 
  
 CREATE TABLE ATM_BRANCHES
   (	"ABR_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ABR_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ABR_CONTACT" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ABR_ALO_LOCATION_ID" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ABR_CODE" VARCHAR2(8 BYTE), 
	"ABR_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "ABR_PK" PRIMARY KEY ("ABR_ID")
   ) TABLESPACE AUTH_REPORT_DATA_TS;
   
CREATE TABLE ATM_DEVICE_STATUS 
   (	
    "ADS_DEVICE_ID" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ADS_HEALTH" VARCHAR2(50 BYTE), 
	"ADS_DEVICE_DATA" VARCHAR2(100 BYTE), 
	"ADS_DEVICE_DESCRIPTION" VARCHAR2(100 BYTE), 
	"ADS_DEVICE_SUPPLY" VARCHAR2(50 BYTE), 
	"ADS_DEVICE_ADDITIONAL_DATA" VARCHAR2(100 BYTE), 
	"ADS_AST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ADS_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"ADS_DEVICE_VARIANT_ID" NUMBER(5,0), 
	"ADS_ATNC_ID" NUMBER(19,0), 
	 CONSTRAINT "ADS_PK" PRIMARY KEY ("ADS_AST_ID", "ADS_DEVICE_ID")
   ) TABLESPACE AUTH_REPORT_DATA_TS;
   
 CREATE TABLE ATM_DEVICE_TOTALS 
   (	
    "ATO_BUSINESS_DAY" DATE NOT NULL ENABLE, 
	"ATO_CUR_ISO_ID" NUMBER(5,0) NOT NULL ENABLE, 
	"ATO_DENOMINATION" NUMBER(10,0) NOT NULL ENABLE, 
	"ATO_SEQ_NMBR" NUMBER(19,0) NOT NULL ENABLE, 
	"ATO_COUNTER" NUMBER(10,0) NOT NULL ENABLE, 
	"ATO_MEDIA_TYPE" VARCHAR2(30 BYTE), 
	"ATO_EVENT" VARCHAR2(50 BYTE), 
	"ATO_AST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ATO_TIMESTAMP" TIMESTAMP (6), 
	"ATO_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "ATO_PK" PRIMARY KEY ("ATO_AST_ID", "ATO_BUSINESS_DAY", "ATO_CUR_ISO_ID", "ATO_DENOMINATION", "ATO_SEQ_NMBR")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE ATM_STATIONS 
   (	
    "AST_LUNO" VARCHAR2(3 BYTE) NOT NULL ENABLE, 
	"AST_IP_ADDRESS" VARCHAR2(15 BYTE) NOT NULL ENABLE, 
	"AST_MACCING_ENABLED" VARCHAR2(15 BYTE) NOT NULL ENABLE, 
	"AST_NOTE_MIX_CONSTANT" VARCHAR2(50 BYTE), 
	"AST_ARE_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"AST_ALO_LOCATION_ID" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"AST_ABR_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"AST_IN_SERVICE_MSG" NUMBER(5,0), 
	"AST_OUT_OF_SERVICE_MSG" NUMBER(5,0), 
	"AST_LOGGING" VARCHAR2(3 BYTE), 
	"AST_ACO_ID" VARCHAR2(4 BYTE) NOT NULL ENABLE, 
	"AST_REQUIRED_STATE" VARCHAR2(15 BYTE), 
	"AST_TERMINAL_ID" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"AST_HKS_NAME" VARCHAR2(50 BYTE), 
	"AST_AEP_SERIAL" VARCHAR2(8 BYTE), 
	"AST_ACTIVE" VARCHAR2(3 BYTE) DEFAULT 'YES' NOT NULL ENABLE, 
	"AST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"AST_ACP_ACI_ID" NUMBER(19,0), 
	"AST_MAX_DISPENSE" NUMBER(10,0), 
	"AST_DEO_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"AST_DISABLE_EPP_SER_NUM_CHK" VARCHAR2(3 BYTE) NOT NULL ENABLE, 
	"AST_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"AST_DIALUP" VARCHAR2(3 BYTE) DEFAULT 'NO' NOT NULL ENABLE, 
	"AST_ALIAS_NAME" VARCHAR2(40 BYTE), 
	"AST_DCG_ID" NUMBER(19,0), 
	"AST_MACHINE_NUMBER" VARCHAR2(6 BYTE), 
	"AST_TERMINAL_TYPE" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	 CONSTRAINT "AST_PK" PRIMARY KEY ("AST_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE ATM_STATUS 
   (	
    "ATS_OPERATION_STATUS" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ATS_COMM_STATUS" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ATS_HEALTH" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ATS_SERVICE_STATE_REASON" VARCHAR2(50 BYTE), 
	"ATS_MODEL_NUMBER" VARCHAR2(75 BYTE), 
	"ATS_BUSINESS_DAY" DATE, 
	"ATS_CONFIGURATION_ID" VARCHAR2(4 BYTE), 
	"ATS_ACTIVITY" VARCHAR2(50 BYTE), 
	"ATS_STAGE" VARCHAR2(50 BYTE), 
	"ATS_CASH_DISPENSE_POSSIBLE" VARCHAR2(7 BYTE), 
	"ATS_IAP_NAME" VARCHAR2(50 BYTE), 
	"ATS_AST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ATS_SW_VERSION" VARCHAR2(20 BYTE), 
	"ATS_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"ATS_DEVICE_STATUS_BITMAP" VARCHAR2(100 BYTE), 
	"ATS_LAST_TPK_CHANGE" TIMESTAMP (6), 
	"ATS_EPP_ED" VARCHAR2(2048 BYTE), 
	"ATS_EPP_VS" VARCHAR2(2048 BYTE), 
	"ATS_LAST_TELLER_SESSION_ID" VARCHAR2(32 BYTE) DEFAULT (null), 
	"ATS_LAST_EJUPLOAD_CHANGE" TIMESTAMP (6), 
	 CONSTRAINT "ATS_PK" PRIMARY KEY ("ATS_AST_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE ATM_STATUS_HISTORY 
   (	
    "ASH_SEQ_NMBR" NUMBER(19,0) NOT NULL ENABLE, 
	"ASH_OPERATION_STATUS" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ASH_COMM_STATUS" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ASH_HEALTH" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ASH_SERVICE_STATE_REASON" VARCHAR2(50 BYTE), 
	"ASH_CASH_DISPENSE_POSSIBLE" VARCHAR2(7 BYTE), 
	"ASH_BUSINESS_DAY" DATE, 
	"ASH_AST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ASH_TIMESTAMP" TIMESTAMP (6), 
	"ASH_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"ASH_DEVICE_STATUS_BITMAP" VARCHAR2(100 BYTE), 
	 CONSTRAINT "ASH_PK" PRIMARY KEY ("ASH_AST_ID", "ASH_TIMESTAMP", "ASH_SEQ_NMBR")
   ) TABLESPACE AUTH_REPORT_DATA_TS ;
   
   CREATE TABLE ATM_TXN_ACTIVITY_LOG 
   (	
    "ATA_BUS_DATE" DATE NOT NULL ENABLE, 
	"ATA_TXN_SEQ_NBR" NUMBER(19,0) NOT NULL ENABLE, 
	"ATA_TXN_TYPE" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ATA_TXN_STATE" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ATA_SEQ_NBR" NUMBER(19,0) NOT NULL ENABLE, 
	"ATA_PAN" VARCHAR2(200 BYTE) NOT NULL ENABLE, 
	"ATA_AMT_REQSTD" NUMBER(19,0), 
	"ATA_AMT_COMPLETED" NUMBER(19,0), 
	"ATA_RESPONSE_CODE" NUMBER(5,0), 
	"ATA_ICC_TXN" VARCHAR2(3 BYTE) DEFAULT 'NO' NOT NULL ENABLE, 
	"ATA_ICC_DATA" VARCHAR2(2000 BYTE), 
	"ATA_ADDITIONAL_DATA" VARCHAR2(2000 BYTE), 
	"ATA_ICC_ISSUER_SCRIPT_RESULTS" VARCHAR2(100 BYTE), 
	"ATA_PAN_EKY_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ATA_AST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ATA_NOTES_DISPENSE_PROFILE" VARCHAR2(16 BYTE), 
	"ATA_NOTES_DENOM_PROFILE" VARCHAR2(64 BYTE), 
	"ATA_EMV_PROC_RESULTS" VARCHAR2(4 BYTE), 
	"ATA_TRL_ID" NUMBER(19,0), 
	"ATA_EML_ID" NUMBER(19,0), 
	"ATA_SESSION_ID" VARCHAR2(50 BYTE), 
	"ATA_TIMESTAMP" TIMESTAMP (6), 
	"ATA_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"ATA_TXN_CUR_ISO_ID" NUMBER(19,0), 
	"ATA_AST_TERMINAL_ID" VARCHAR2(15 BYTE), 
	"ATA_ANC_ID" NUMBER(19,0), 
	"ATA_COINS_DISPENSE_PROFILE" VARCHAR2(16 BYTE), 
	"ATA_COINS_DENOM_PROFILE" VARCHAR2(64 BYTE), 
	 CONSTRAINT "ATA_PK" PRIMARY KEY ("ATA_AST_ID", "ATA_BUS_DATE", "ATA_TXN_SEQ_NBR", "ATA_TXN_TYPE", "ATA_TXN_STATE", "ATA_TIMESTAMP", "ATA_SEQ_NBR")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE AUTH_RESULT_CODE 
   (	
    "ARC_CODE" NUMBER(10,0) NOT NULL ENABLE, 
	"ARC_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ARC_ART_ID" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"ARC_FORCE_POST_FLAG" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"ARC_CONTINUE_IND" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"ARC_ACTION_CODE" VARCHAR2(10 BYTE), 
	"ARC_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "ARC_PK" PRIMARY KEY ("ARC_CODE")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE BRANCH 
   (	
    "BRC_CODE" VARCHAR2(20 CHAR) NOT NULL ENABLE, 
	"BRC_NAME" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	"BRC_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "BRC_PK" PRIMARY KEY ("BRC_CODE")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CARD 
   (	
    "CRD_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CRD_PAN" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	"CRD_CARD_SEQUENCE_NBR" NUMBER(5,0) NOT NULL ENABLE, 
	"CRD_CPD_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CRD_PURGE_DATE" DATE, 
	"CRD_ISSUE_DATE_1" DATE, 
	"CRD_EXPIRY_DATE_1" DATE NOT NULL ENABLE, 
	"CRD_DISCRETIONARY_DATA_1" VARCHAR2(128 BYTE), 
	"CRD_ISSUE_DATE_2" DATE, 
	"CRD_EXPIRY_DATE_2" DATE, 
	"CRD_DISCRETIONARY_DATA_2" VARCHAR2(128 BYTE), 
	"CRD_CARDHOLDER_NAME" VARCHAR2(45 BYTE), 
	"CRD_REGISTRATION_ADDR1" VARCHAR2(45 BYTE), 
	"CRD_REGISTRATION_ADDR2" VARCHAR2(45 BYTE), 
	"CRD_REGISTRATION_ADDR3" VARCHAR2(45 BYTE), 
	"CRD_REGISTRATION_ADDR4" VARCHAR2(45 BYTE), 
	"CRD_REGISTRATION_ADDR5" VARCHAR2(45 BYTE), 
	"CRD_REGISTRATION_ZIP_CODE" VARCHAR2(20 BYTE), 
	"CRD_COMMENT" VARCHAR2(30 BYTE), 
	"CRD_CREATION_DATE" DATE, 
	"CRD_STATUS_1" VARCHAR2(2 BYTE), 
	"CRD_STATUS_1_DATE" DATE, 
	"CRD_STATUS_2" VARCHAR2(2 BYTE), 
	"CRD_STATUS_2_DATE" DATE, 
	"CRD_PVKI" NUMBER(5,0), 
	"CRD_PREV_PIN_CHANGE_DATE" DATE, 
	"CRD_CURRENT_PVV" VARCHAR2(128 BYTE), 
	"CRD_PREVIOUS_PVV" VARCHAR2(128 BYTE), 
	"CRD_PIN_RETRY_COUNT" NUMBER(5,0), 
	"CRD_PRIMARY_ACN_ID" NUMBER(19,0), 
	"CRD_SECONDARY_ACN_ID" NUMBER(19,0), 
	"CRD_LAST_FEP_HOST_TRACE_NBR" NUMBER(10,0), 
	"CRD_LAST_HOST_FEP_TRACE_NBR" NUMBER(10,0), 
	"CRD_PART_NO" NUMBER(19,0), 
	"CRD_CUSTOM_DATA" VARCHAR2(4000 BYTE), 
	"CRD_OPEN_ACCOUNT_IND" VARCHAR2(1 BYTE), 
	"CRD_CURRENT_PIN_OFFSET" VARCHAR2(18 BYTE), 
	"CRD_PREVIOUS_PIN_OFFSET" VARCHAR2(18 BYTE), 
	"CRD_LAST_SOURCE" VARCHAR2(5 BYTE), 
	"CRD_LAST_TERMINAL_ID" VARCHAR2(20 BYTE), 
	"CRD_PIN_BLOCK" VARCHAR2(32 BYTE), 
	"CRD_PREV_PIN_BLOCK" VARCHAR2(32 BYTE), 
	"CRD_CUSTOM_INDEX_1" VARCHAR2(20 BYTE), 
	"CRD_SEND_PIN_UNBLOCK_SCRIPT" VARCHAR2(1 BYTE), 
	"CRD_SEND_PIN_CHANGE_SCRIPT" VARCHAR2(1 BYTE), 
	"CRD_FUNCTIONS" VARCHAR2(20 BYTE), 
	"CRD_OVERRIDE_PERMISSION" VARCHAR2(1 BYTE), 
	"CRD_ISS_ID" NUMBER(19,0), 
	"CRD_BIN" NUMBER(10,0), 
	"CRD_EMV_LEVEL" VARCHAR2(10 BYTE), 
	"CRD_LIMIT_CONFIG" VARCHAR2(4000 BYTE), 
	"CRD_MULTIPLE_ACCOUNTS" VARCHAR2(1 BYTE), 
	"CRD_CUST_ID" NUMBER(19,0), 
	"CRD_PIN_MAILER_CADD_ID_FK" NUMBER(19,0), 
	"CRD_STMT_MAILER_CADD_ID_FK" NUMBER(19,0), 
	"CRD_CARD_DELIVERY_CADD_ID_FK" NUMBER(19,0), 
	"CRD_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"CRD_PREVIOUS_PVV_EKY_ID" NUMBER(19,0), 
	"CRD_CURRENT_PVV_EKY_ID" NUMBER(19,0), 
	"CRD_DISCRETIONARY_D1_EKY_ID" NUMBER(19,0), 
	"CRD_DISCRETIONARY_D2_EKY_ID" NUMBER(19,0), 
	"CRD_PAN_EKY_ID" NUMBER(19,0), 
	"CRD_PREVIOUS_PVN2" VARCHAR2(16 BYTE), 
	"CRD_CURRENT_PVN2" VARCHAR2(16 BYTE), 
	"CRD_CELL_PHONE" VARCHAR2(20 BYTE), 
	"CRD_EMAIL" VARCHAR2(50 BYTE), 
	 CONSTRAINT "CRD_PK" PRIMARY KEY ("CRD_ID")
   ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CARD_PRODUCT 
   (	
    "CPD_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CPD_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"CPD_NETWORK" VARCHAR2(30 BYTE), 
	"CPD_CODE" VARCHAR2(30 BYTE), 
	"CPD_CDT_ID" NUMBER(19,0), 
	"CPD_ALP_ID" NUMBER(19,0), 
	"CPD_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "CPD_PK" PRIMARY KEY ("CPD_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_BANK
   (
    "CBA_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CBA_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"CBA_CODE" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	"CBA_MNEM" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	"CBA_TYPE" VARCHAR2(15 BYTE) NOT NULL ENABLE, 
	"CBA_MEMBERSHIP" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"CBA_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"CBA_SHORT_NAME" VARCHAR2(50 BYTE), 
	"CBA_INSTAPAY_FLAG" VARCHAR2(5 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	 CONSTRAINT "CBA_PK" PRIMARY KEY ("CBA_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_BILLER 
   (	
    "CBL_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CBL_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"CBL_CODE" VARCHAR2(6 BYTE) NOT NULL ENABLE, 
	"CBL_MNEM" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	"CBL_TYPE" VARCHAR2(15 BYTE) NOT NULL ENABLE, 
	"CBL_SETTLEMENT_TYPE" VARCHAR2(10 BYTE), 
	"CBL_PAN_LENGTH" NUMBER(2,0) NOT NULL ENABLE, 
	"CBL_BIN_LENGTH" VARCHAR2(2 BYTE), 
	"CBL_BIN_START" VARCHAR2(15 BYTE), 
	"CBL_BIN_VALIDATION" VARCHAR2(5 BYTE), 
	"CBL_CHK_DIGIT_VALIDATION" VARCHAR2(5 BYTE), 
	"CBL_CHK_DIGIT_ACC_START" VARCHAR2(15 BYTE), 
	"CBL_CHK_DIGIT_ACC_LENGTH" VARCHAR2(5 BYTE), 
	"CBL_VALIDATION_CLASS" VARCHAR2(255 BYTE), 
	"CBL_GL_CASA_ACCOUNT" VARCHAR2(30 BYTE), 
	"CBL_WEIGHT" VARCHAR2(30 BYTE), 
	"CBL_VARIANT" VARCHAR2(30 BYTE), 
	"CBL_ACC_NUM_LENGTH" VARCHAR2(50 BYTE), 
	"CBL_ACC_NUM_BIN" VARCHAR2(1000 BYTE), 
	"CBL_ACC_NUM_BIN_EXCLUDE" VARCHAR2(100 BYTE), 
	"CBL_CHK_DIGIT_BIN_EXCEPTION" VARCHAR2(100 BYTE), 
	"CBL_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "CBL_PK" PRIMARY KEY ("CBL_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_GL_ACCOUNT
   (	
    "GLA_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"GLA_NAME" VARCHAR2(60 BYTE) NOT NULL ENABLE, 
	"GLA_NUMBER" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"GLA_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "GLA_PK" PRIMARY KEY ("GLA_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_GL_ENTRY 
   (	
    "GLE_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"GLE_GLT_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"GLE_MAIN_DIRECTION" VARCHAR2(50 BYTE), 
	"GLE_TRAN_CHANNEL" VARCHAR2(20 BYTE), 
	"GLE_TRAN_TYPE" NUMBER(10,0) NOT NULL ENABLE, 
	"GLE_CARD_TYPE" VARCHAR2(50 BYTE), 
	"GLE_FROM_ACCOUNT_TYPE" VARCHAR2(10 BYTE), 
	"GLE_TO_ACCOUNT_TYPE" VARCHAR2(10 BYTE), 
	"GLE_TRAN_CODE_EXCLUDE" VARCHAR2(20 BYTE), 
	"GLE_BP_SETTLEMENT" VARCHAR2(20 BYTE), 
	"GLE_BP_INCLUDE" VARCHAR2(100 BYTE), 
	"GLE_BP_EXEMPT" VARCHAR2(100 BYTE), 
	"GLE_DEBIT_ACCOUNT" VARCHAR2(70 BYTE) NOT NULL ENABLE, 
	"GLE_DEBIT_DESCRIPTION" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"GLE_CREDIT_ACCOUNT" VARCHAR2(70 BYTE) NOT NULL ENABLE, 
	"GLE_CREDIT_DESCRIPTION" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"GLE_SVC_ENABLED" VARCHAR2(1 BYTE), 
	"GLE_SVC_AUTHENTIC" VARCHAR2(1 BYTE), 
	"GLE_SVC_AMT" NUMBER(22,6), 
	"GLE_ENTRY_ENABLED" VARCHAR2(1 BYTE), 
	"GLE_ENTRY_SEPARATE" VARCHAR2(1 BYTE), 
	"GLE_CREATED_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"GLE_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "GLE_PK" PRIMARY KEY ("GLE_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_GL_TRANSACTION 
   (	
    "GLT_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"GLT_NAME" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"GLT_CODE" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"GLT_ENABLED" VARCHAR2(1 BYTE), 
	"GLT_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "GLT_PK" PRIMARY KEY ("GLT_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_MOVING_CASH 
   (	
    "CMV_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CMV_TXN_CODE" NUMBER(6,0) NOT NULL ENABLE, 
	"CMV_FROM_ACC_NO" VARCHAR2(36 BYTE) NOT NULL ENABLE, 
	"CMV_FROM_ACC_TYPE" VARCHAR2(10 BYTE), 
	"CMV_TO_ACC_NO" VARCHAR2(36 BYTE), 
	"CMV_CUR_ID" NUMBER(3,0) NOT NULL ENABLE, 
	"CMV_AMOUNT" NUMBER(22,6) NOT NULL ENABLE, 
	"CMV_CIF" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"CMV_CHANNEL_ID" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"CMV_CHANNEL_DESC" VARCHAR2(15 BYTE), 
	"CMV_TXN_REF_NO" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"CMV_OTP" VARCHAR2(32 BYTE), 
	"CMV_PASSCODE" VARCHAR2(15 BYTE), 
	"CMV_SENDER_MOBILE" VARCHAR2(15 BYTE), 
	"CMV_RECV_MOBILE" VARCHAR2(15 BYTE), 
	"CMV_TXN_RECV_MODE" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"CMV_RETRY_CNT" NUMBER(*,0) DEFAULT 0 NOT NULL ENABLE, 
	"CMV_STATUS" VARCHAR2(15 BYTE) NOT NULL ENABLE, 
	"CMV_TXN_FEE" NUMBER(22,6) DEFAULT 0 NOT NULL ENABLE, 
	"CMV_TXN_EXTRA" VARCHAR2(100 BYTE), 
	"CMV_ATM_ID" VARCHAR2(8 BYTE), 
	"CMV_CREATED_TS" TIMESTAMP (6), 
	"CMV_TXN_FULFILL_TS" TIMESTAMP (6), 
	"CMV_CHANGE_MODE_TS" TIMESTAMP (6), 
	"CMV_EXPIRED_TS" TIMESTAMP (6), 
	"CMV_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"CMV_CRD_ID" NUMBER(19,0), 
	 CONSTRAINT "CBC_MOV_PK" PRIMARY KEY ("CMV_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_TRAN_CODE 
   (	
    "CTR_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CTR_CODE" NUMBER(10,0) NOT NULL ENABLE, 
	"CTR_CHANNEL" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	"CTR_MNEM" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	"CTR_REV_MNEM" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	"CTR_DEBIT_CREDIT" VARCHAR2(6 BYTE) NOT NULL ENABLE, 
	"CTR_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "CTR_PK" PRIMARY KEY ("CTR_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CUSTOMER 
   (	
    "CUST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CUST_NUMBER" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	"CUST_TITLE" VARCHAR2(20 CHAR), 
	"CUST_FIRST_NAME" VARCHAR2(100 CHAR), 
	"CUST_MIDDLE_NAME" VARCHAR2(100 CHAR), 
	"CUST_LAST_NAME" VARCHAR2(100 CHAR), 
	"CUST_CCNY_ID" VARCHAR2(50 CHAR), 
	"CUST_GENDER" VARCHAR2(1 CHAR), 
	"CUST_DOB" DATE, 
	"CUST_EMAIL_ADDRESS" VARCHAR2(100 CHAR), 
	"CUST_STATUS" VARCHAR2(20 CHAR), 
	"CUST_WORK_PHONE" VARCHAR2(20 CHAR), 
	"CUST_MOBILE_PHONE" VARCHAR2(20 CHAR), 
	"CUST_DEVICE_ID" VARCHAR2(18 CHAR), 
	"CUST_CCAT_ID" NUMBER(19,0), 
	"CUST_NAT_CTY_ISO_ID" NUMBER(5,0), 
	"CUST_CUSTOM_DATA" VARCHAR2(4000 CHAR), 
	"CUST_CREATED_DATE_TS" TIMESTAMP (6), 
	"CUST_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"CUST_LIMIT_CONFIG" VARCHAR2(4000 BYTE), 
	"CUST_HOME_PHONE" VARCHAR2(20 CHAR), 
	"CUST_CUIT_CODE_1" VARCHAR2(10 CHAR), 
	"CUST_IDENT_NUMBER_1" VARCHAR2(100 CHAR), 
	"CUST_CUIT_CODE_2" VARCHAR2(10 CHAR), 
	"CUST_IDENT_NUMBER_2" VARCHAR2(100 CHAR), 
	"CUST_CUIT_CODE_3" VARCHAR2(10 CHAR), 
	"CUST_IDENT_NUMBER_3" VARCHAR2(100 CHAR), 
	"CUST_ISS_ID" NUMBER(19,0), 
	"CUST_RESIDENCE_IND" VARCHAR2(1 CHAR), 
	"CUST_BACKGROUND_IND" VARCHAR2(20 CHAR), 
	"CUST_IDENT_NUMBER_1_EKY_ID" NUMBER(19,0), 
	"CUST_IDENT_NUMBER_2_EKY_ID" NUMBER(19,0), 
	"CUST_IDENT_NUMBER_3_EKY_ID" NUMBER(19,0), 
	 CONSTRAINT "CUST_PK" PRIMARY KEY ("CUST_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE MERCHANT 
   (	
    "MER_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"MER_ACQ_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"MER_NUMBER" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"MER_DEFAULT_CUR_ID" NUMBER(5,0) NOT NULL ENABLE, 
	"MER_CAPTURE_IND" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"MER_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"MER_COUNTRY_CODE" NUMBER(5,0), 
	"MER_ZIP_CODE" VARCHAR2(20 BYTE), 
	"MER_CUSTOM_DATA" VARCHAR2(4000 BYTE), 
	"MER_ERG_NAME" VARCHAR2(100 BYTE), 
	"MER_REFERENCE_1" VARCHAR2(30 BYTE), 
	"MER_REFERENCE_2" VARCHAR2(30 BYTE), 
	"MER_STATUS" VARCHAR2(10 BYTE) DEFAULT 'INACTIVE', 
	"MER_CLEARING_HOUSE" VARCHAR2(50 BYTE), 
	"MER_SERVICE_FEE" NUMBER(5,0), 
	"MER_SMBR_ID" NUMBER(19,0), 
	"MER_INTERNET_SECURITY_LEVEL" VARCHAR2(1 BYTE), 
	"MER_ORG_ID" NUMBER(19,0), 
	"MER_PRIMARY_CON_ID" NUMBER(19,0), 
	"MER_SECONDARY_CON_ID" NUMBER(19,0), 
	"MER_TXN_SECURITY_IND" VARCHAR2(1 BYTE) DEFAULT '0' NOT NULL ENABLE, 
	"MER_AUTHORISATION_LIFECYCLE" NUMBER(19,0) DEFAULT '00' NOT NULL ENABLE, 
	"MER_OTHER_NAME" VARCHAR2(50 CHAR), 
	"MER_MCC" NUMBER(5,0) NOT NULL ENABLE, 
	"MER_ADDRESS" VARCHAR2(50 CHAR), 
	"MER_CITY" VARCHAR2(50 CHAR), 
	"MER_EFFECTIVE_DATE" DATE, 
	"MER_STATUS_TS" TIMESTAMP (6), 
	"MER_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"MER_MVV" VARCHAR2(10 BYTE), 
	"MER_SDWO" VARCHAR2(1 BYTE), 
	 CONSTRAINT "MER_PK" PRIMARY KEY ("MER_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE TRANSACTION_CODE 
   (	
    "TSC_CODE" NUMBER(10,0) NOT NULL ENABLE, 
	"TSC_TTY_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"TSC_DESCRIPTION" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"TSC_AUTH_ALLOWED" VARCHAR2(1 BYTE), 
	"TSC_CUSTOM_AUTH_TRANCODE" VARCHAR2(10 BYTE), 
	"TSC_FINANCIAL_TRANS_ALLOWED" VARCHAR2(1 BYTE), 
	"TSC_CUSTOM_FINANCIAL_TRANSCODE" VARCHAR2(10 BYTE), 
	"TSC_REVERSAL_ALLOWED" VARCHAR2(1 BYTE), 
	"TSC_CUSTOM_REVERSAL_TRANCODE" VARCHAR2(10 BYTE), 
	"TSC_FORCE_POST_ALLOWED" VARCHAR2(1 BYTE), 
	"TSC_CUSTOM_FORCE_POST_TRANCODE" VARCHAR2(10 BYTE), 
	"TSC_NOTIFY_ALLOWED" VARCHAR2(1 BYTE), 
	"TSC_CUSTOM_NOTIFY_TRANCODE" VARCHAR2(10 BYTE), 
	"TSC_STOP" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"TSC_AMS_CODE" VARCHAR2(20 BYTE), 
	"TSC_AMS_PRINTABLE" VARCHAR2(1 BYTE), 
	"TSC_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "TSC_PK" PRIMARY KEY ("TSC_CODE")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE TRANSACTION_LOG 
   (	
    "TRL_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"TRL_BUSINESS_DATE" DATE NOT NULL ENABLE, 
	"TRL_APPR_ID" NUMBER(19,0), 
	"TRL_TSC_CODE" NUMBER(10,0) NOT NULL ENABLE, 
	"TRL_TQU_ID" VARCHAR2(2 BYTE) NOT NULL ENABLE, 
	"TRL_TCG_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"TRL_TTY_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"TRL_FUNCTION_CODE" NUMBER(5,0), 
	"TRL_MESSAGE_REASON_CODE" NUMBER(5,0), 
	"TRL_STAN" VARCHAR2(100 BYTE), 
	"TRL_RRN" VARCHAR2(20 BYTE), 
	"TRL_AMT_COMPLETED" NUMBER(22,6), 
	"TRL_AMT_COMPLETED_PREV_TXN" NUMBER(22,6), 
	"TRL_AMT_TXN" NUMBER(22,6), 
	"TRL_AMT_CARDHOLDER_BILLING" NUMBER(22,6), 
	"TRL_AMT_CARDHOLDER_BILLING_FEE" NUMBER(22,6), 
	"TRL_CONVERSION_RATE_CARDHOLDER" NUMBER(38,12), 
	"TRL_TXN_CUR_ISO_ID" NUMBER(19,0), 
	"TRL_CARD_BILLING_CUR_ISO_ID" NUMBER(19,0), 
	"TRL_PAN_CTY_ISO_ID" NUMBER(19,0), 
	"TRL_PAN" VARCHAR2(128 BYTE), 
	"TRL_CARD_TYPE" VARCHAR2(50 BYTE), 
	"TRL_CARD_SEQUENCE_NBR" NUMBER(5,0), 
	"TRL_DATE_EXPIRY" VARCHAR2(10 BYTE), 
	"TRL_CARD_TRACK_NBR" NUMBER(5,0), 
	"TRL_CARD_TRACK_DATA" VARCHAR2(200 BYTE), 
	"TRL_CARD_ISSUER_REF_DATA" VARCHAR2(100 BYTE), 
	"TRL_PIN_RETRY_COUNT" NUMBER(5,0), 
	"TRL_CARD_STATUS_CODE" VARCHAR2(10 BYTE), 
	"TRL_ACQR_CTY_ISO_ID" NUMBER(19,0), 
	"TRL_ACQR_INST_ID" VARCHAR2(20 BYTE), 
	"TRL_MCC_ID" NUMBER(19,0), 
	"TRL_CARD_ACCEPTOR_MBC_ID" NUMBER(19,0), 
	"TRL_CARD_ACPT_TERMINAL_IDENT" VARCHAR2(10 BYTE), 
	"TRL_CARD_ACPT_IDENT_CODE" VARCHAR2(20 BYTE), 
	"TRL_CARD_ACPT_NAME_LOCATION" VARCHAR2(100 BYTE), 
	"TRL_AUTHORISED_BY" VARCHAR2(100 BYTE), 
	"TRL_APPROVAL_CODE" VARCHAR2(10 BYTE), 
	"TRL_ACTION_RESPONSE_CODE" NUMBER(5,0), 
	"TRL_POST_COMPLETION_CODE" VARCHAR2(2 BYTE), 
	"TRL_MATCH_FLAG" VARCHAR2(1 BYTE), 
	"TRL_SERVICE_CODE" NUMBER(5,0), 
	"TRL_STANDIN_REASON_INDICATOR" NUMBER(5,0), 
	"TRL_AUTHORIZATION_LIFE_CYCLE" NUMBER(10,0), 
	"TRL_MESSAGE_NBR" NUMBER(10,0), 
	"TRL_ORIG_TXN_MESSAGE_TYPE" VARCHAR2(10 BYTE), 
	"TRL_ORIG_TXN_STAN" VARCHAR2(100 BYTE), 
	"TRL_ORIG_TXN_ACQR_INST_ID" VARCHAR2(20 BYTE), 
	"TRL_ORIG_TXN_FRD_REV_INST_ID" VARCHAR2(20 BYTE), 
	"TRL_ORIG_TXN_CUR_ISO_ID" NUMBER(19,0), 
	"TRL_ORIG_TXN_APPROVAL_CODE" VARCHAR2(10 BYTE), 
	"TRL_ORIG_TXN_BUSINESS_DATE" DATE, 
	"TRL_ORIG_TXN_AMT" NUMBER(22,6), 
	"TRL_FRD_REV_INST_ID" VARCHAR2(20 BYTE), 
	"TRL_ACCOUNT_TYPE_1_ATP_ID" NUMBER(19,0), 
	"TRL_ACCOUNT_1_ACN_ID" VARCHAR2(128 BYTE), 
	"TRL_ACCOUNT_1_BALANCE_DATE" DATE, 
	"TRL_ACCOUNT_1_MAX_AVAILABLE" NUMBER(22,6), 
	"TRL_ACCOUNT_1_SPENT_AMOUNT" NUMBER(22,6), 
	"TRL_ACCOUNT_1_BALANCE_DATA" VARCHAR2(512 BYTE), 
	"TRL_ACCOUNT_TYPE_2_ATP_ID" NUMBER(19,0), 
	"TRL_ACCOUNT_2_ACN_ID" VARCHAR2(128 BYTE), 
	"TRL_ACCOUNT_2_BALANCE_DATE" DATE, 
	"TRL_ACCOUNT_2_MAX_AVAILABLE" NUMBER(22,6), 
	"TRL_ACCOUNT_2_SPENT_AMOUNT" NUMBER(22,6), 
	"TRL_ACCOUNT_2_BALANCE_DATA" VARCHAR2(512 BYTE), 
	"TRL_PREV_TXN_SAME_PERIOD" VARCHAR2(1 BYTE), 
	"TRL_PREV_TXN_TRL_ID" NUMBER(19,0), 
	"TRL_PREV_TXN_TSC_CODE" NUMBER(10,0), 
	"TRL_PREV_TXN_TQU_ID" VARCHAR2(2 BYTE), 
	"TRL_ADDITIONAL_RESPONSE_DATA" VARCHAR2(1000 BYTE), 
	"TRL_TXN_STATUS" VARCHAR2(2 BYTE), 
	"TRL_REFERRAL_CONF_DATA" VARCHAR2(255 BYTE), 
	"TRL_ADDNL_ACTION_CODES" VARCHAR2(1000 BYTE), 
	"TRL_CUSTOM_DATA" VARCHAR2(4000 BYTE), 
	"TRL_CARD_DATA_INPUT_CPBLTY" VARCHAR2(2 BYTE), 
	"TRL_CARDHOLDER_AUTHENT_CPBLTY" VARCHAR2(2 BYTE), 
	"TRL_CARD_CAPTURE_CPBLTY" VARCHAR2(2 BYTE), 
	"TRL_OPERATING_ENVIRONMENT" VARCHAR2(2 BYTE), 
	"TRL_CARDHOLDER_PRESENT_IND" VARCHAR2(2 BYTE), 
	"TRL_CARD_PRESENT_IND" VARCHAR2(2 BYTE), 
	"TRL_CARD_DATA_INPUT_MODE" VARCHAR2(2 BYTE), 
	"TRL_CARDHOLDER_AUTHENT_METHOD" VARCHAR2(2 BYTE), 
	"TRL_CARDHOLDER_AUTHENT_ENTITY" VARCHAR2(2 BYTE), 
	"TRL_CARD_DATA_OUTPUT_CPBLTY" VARCHAR2(2 BYTE), 
	"TRL_TERMINAL_OUTPUT_CPBLTY" VARCHAR2(2 BYTE), 
	"TRL_PIN_CAPTURE_CPBLTY" VARCHAR2(2 BYTE), 
	"TRL_DEST_STAN" VARCHAR2(100 BYTE), 
	"TRL_ORIGIN_ICH_NAME" VARCHAR2(50 BYTE), 
	"TRL_DEST_ICH_NAME" VARCHAR2(50 BYTE), 
	"TRL_AUX_MESSAGE_TYPE" NUMBER(5,0), 
	"TRL_ORIGIN_FEP_NBR" NUMBER(10,0), 
	"TRL_AUTH_DATA" VARCHAR2(26 BYTE), 
	"TRL_PRODUCT_CODE" VARCHAR2(8 BYTE), 
	"TRL_RVRSL_TYPE" NUMBER(5,0), 
	"TRL_ISS_CHARGE_ID" VARCHAR2(2000 BYTE), 
	"TRL_ISS_CHARGE_AMT" NUMBER(22,6), 
	"TRL_ACQ_CHARGE_ID" VARCHAR2(2000 BYTE), 
	"TRL_ACQ_CHARGE_AMT" NUMBER(22,6), 
	"TRL_TAC_ACC_SEQ" NUMBER(5,0), 
	"TRL_BPM_BILL_SEQ" NUMBER(5,0), 
	"TRL_EFFECTIVE_TQU_ID" VARCHAR2(2 BYTE), 
	"TRL_ORIGIN_IAP_NAME" VARCHAR2(50 BYTE), 
	"TRL_DEST_IAP_NAME" VARCHAR2(50 BYTE), 
	"TRL_MESSAGE_TYPE" VARCHAR2(10 BYTE), 
	"TRL_CARD_ADNL_STATUS_CODE" VARCHAR2(10 BYTE), 
	"TRL_ACN_STATUS_CODE" VARCHAR2(10 BYTE), 
	"TRL_PART_NO" NUMBER(5,0), 
	"TRL_SESSION" VARCHAR2(12 BYTE), 
	"TRL_TRANSACTION_ID" VARCHAR2(20 BYTE), 
	"TRL_LOCATION_LOGGED" VARCHAR2(20 BYTE), 
	"TRL_AUTHENTIC_MSG_REF" VARCHAR2(20 BYTE), 
	"TRL_TXN_TO_SETTLE_RATE" NUMBER(22,6), 
	"TRL_CARDBILLING_TO_SETTLE_RATE" NUMBER(22,6), 
	"TRL_AMT_SETTLE" NUMBER(22,6), 
	"TRL_SETTLE_CUR_ISO_ID" NUMBER(19,0), 
	"TRL_AMT_ACCOUNT" NUMBER(22,6), 
	"TRL_ACCOUNT_CUR_ISO_ID" NUMBER(19,0), 
	"TRL_SETTLE_TO_ACCOUNT_RATE" NUMBER(22,6), 
	"TRL_AMT_MERCH_SETTLE" NUMBER(22,6), 
	"TRL_MERCH_SETTLE_CUR_ISO_ID" NUMBER(19,0), 
	"TRL_SETTLE_TO_MER_SETTLE_RATE" NUMBER(22,6), 
	"TRL_ACQ_NAME" VARCHAR2(50 BYTE), 
	"TRL_TIME_ZONE" VARCHAR2(10 BYTE), 
	"TRL_ORIGIN_RESULT_CODE" VARCHAR2(10 BYTE), 
	"TRL_DESTINATION_RESULT_CODE" VARCHAR2(10 BYTE), 
	"TRL_FRACTALS_BRIDGE_SENT" VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"TRL_EXTERNAL_TRANSACTION_ID" VARCHAR2(20 BYTE), 
	"TRL_DEO_NAME" VARCHAR2(50 BYTE), 
	"TRL_DEO_ORG_NAME" VARCHAR2(50 BYTE), 
	"TRL_ACQ_ORG_NAME" VARCHAR2(50 BYTE), 
	"TRL_ISS_NAME" VARCHAR2(50 BYTE), 
	"TRL_ISS_ORG_NAME" VARCHAR2(50 BYTE), 
	"TRL_MESSAGE_UID" VARCHAR2(200 BYTE), 
	"TRL_CRD_RETAIN_IND" CHAR(1 BYTE), 
	"TRL_DATETIME_LOCAL_TXN" TIMESTAMP (6), 
	"TRL_DATETIME_TRANSMISSION" TIMESTAMP (6), 
	"TRL_DATE_CAPTURE" TIMESTAMP (6), 
	"TRL_DEST_REPLY_TIME" TIMESTAMP (6), 
	"TRL_DEST_REQUEST_TIME" TIMESTAMP (6), 
	"TRL_SYSTEM_TIMESTAMP" TIMESTAMP (6) DEFAULT CURRENT_TIMESTAMP NOT NULL ENABLE, 
	"TRL_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"TRL_PAN_EKY_ID" NUMBER(19,0), 
	"TRL_ACCOUNT_1_ACN_ID_EKY_ID" NUMBER(19,0), 
	"TRL_ACCOUNT_2_ACN_ID_EKY_ID" NUMBER(19,0), 
	"TRL_CARD_TRACK_DATA_EKY_ID" NUMBER(19,0), 
	"TRL_CUSTOM_DATA_EKY_ID" NUMBER(19,0), 
	"TRL_CUST_NUMBER" VARCHAR2(50 CHAR), 
	"TRL_DCC_OUTCOME" VARCHAR2(10 BYTE), 
	"TRL_DCC_ORIG_AMOUNT" NUMBER(22,6), 
	"TRL_DCC_ORIG_CUR_ISO_ID" NUMBER(5,0), 
	"TRL_DCC_CONV_RATE_EXCL_MARKUP" NUMBER(22,6), 
	"TRL_DCC_CONV_RATE_INCL_MARKUP" NUMBER(22,6), 
	"TRL_DCC_CONV_AMT_EXCL_MARKUP" NUMBER(22,6), 
	"TRL_DCC_CONV_AMT_INCL_MARKUP" NUMBER(22,6), 
	"TRL_DCC_CONV_CUR_ISO_ID" NUMBER(5,0), 
	"TRL_ROUTING_LIST" VARCHAR2(500 BYTE), 
	"TRL_AMT_OTHER" NUMBER(19,0), 
	"TRL_TERMINAL_ATTENDANCE" VARCHAR2(2 BYTE), 
	"TRL_PREV_TXN_MESSAGE_UID" VARCHAR2(200 BYTE), 
	 CONSTRAINT "TRL_PK" PRIMARY KEY ("TRL_SYSTEM_TIMESTAMP", "TRL_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE CBC_BIN 
   (	
    "CBI_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CBI_CBA_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CBI_BIN" NUMBER(19,0) NOT NULL ENABLE, 
	"CBI_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "CBI_PK" PRIMARY KEY ("CBI_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE ENCRYPTION_KEY 
   (	
    "EKY_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"EKY_CLASS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"EKY_CHECK_VALUE" VARCHAR2(50 BYTE), 
	"EKY_KEY_DATA" BLOB, 
	"EKY_CATEGORY" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"EKY_CREATION_TS" TIMESTAMP (6), 
	"EKY_CRYPTO_PERIOD_ELAPSED_TS" TIMESTAMP (6), 
	"EKY_CRYPTO_PERIOD_WARN_TS" TIMESTAMP (6), 
	"EKY_DECOMMISSION_TS" TIMESTAMP (6), 
	"EKY_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "EKY_PK" PRIMARY KEY ("EKY_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS;
  
  CREATE TABLE SECURE_KEY
   (	
    "SECK_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"SECK_NAME" VARCHAR2(40 BYTE) NOT NULL ENABLE, 
	"SECK_CATEGORY" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SECK_DATA" BLOB, 
	"SECK_ACCESS" BLOB, 
	"SECK_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"SECK_CRYPTO_PERIOD_WARN_TS" TIMESTAMP (6), 
	"SECK_CRYPTO_PERIOD_ELAPSED_TS" TIMESTAMP (6), 
	"SECK_CREATION_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	 CONSTRAINT "SECK_PK" PRIMARY KEY ("SECK_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS;
  
  CREATE TABLE SECURITY_PARAMETERS 
   (	
    "SECP_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"SECP_NAME" VARCHAR2(40 BYTE) NOT NULL ENABLE, 
	"SECP_CATEGORY" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SECP_STATUS" VARCHAR2(20 BYTE), 
	"SECP_CURRENT_EKY_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"SECP_DATABASE_FORMAT" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SECP_LOG_FORMAT" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SECP_SCREEN_FORMAT" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SECP_LOG_TRACK_DATA" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"SECP_MASK_CHAR" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"SECP_MASK_CLASS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"SECP_INTERNAL_ENCRYPT_CLASS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"SECP_KEY_ENCRYPT_CLASS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"SECP_HASH_CLASS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"SECP_VALIDATION_FAIL_ACTION" VARCHAR2(20 BYTE) DEFAULT 'warn' NOT NULL ENABLE, 
	"SECP_MONITOR_CRYPTO_PERIOD" VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"SECP_CRYPTO_PERIOD_WARN_DAYS" NUMBER(10,0), 
	"SECP_CRYPTO_PERIOD_DAYS" NUMBER(10,0), 
	"SECP_DEFAULT_ENCRYPT_CLASS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"SECP_FALLBACK_EKY_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"SECP_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"SECP_MAC_CLASS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"SECP_LAST_UPDATE_USER" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"SECP_MAC" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	"SECP_DEFAULT_TLS_PROTOCOL" VARCHAR2(10 BYTE), 
	"SECP_LOCAL_KEYSTORES_STORAGE" VARCHAR2(1 BYTE), 
	 CONSTRAINT "SECP_PK" PRIMARY KEY ("SECP_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS ;
  
  CREATE TABLE "ATM_JOURNAL_LOG" 
   (	
    "AJL_BUS_DATE" DATE NOT NULL ENABLE, 
	"AJL_SEQ_NBR" NUMBER(19,0) NOT NULL ENABLE, 
	"AJL_EJ_DATA" VARCHAR2(350 BYTE) NOT NULL ENABLE, 
	"AJL_AST_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"AJL_TIMESTAMP" TIMESTAMP (6) DEFAULT CURRENT_TIMESTAMP NOT NULL ENABLE, 
	"AJL_LAST_UPDATE_TS" TIMESTAMP (6) DEFAULT systimestamp, 
	"AJL_AST_TERMINAL_ID" VARCHAR2(15 BYTE),
	CONSTRAINT "ATM_JOURNAL_LOG_PK" PRIMARY KEY ("AJL_AST_ID","AJL_SEQ_NBR")
   ) TABLESPACE AUTH_REPORT_DATA_TS ;
 
  CREATE TABLE USER_EXTRA_BRANCHES
   (
    "BRANCH_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"USER_EXTRA_ID" NUMBER(38,0) NOT NULL ENABLE, 
	 CONSTRAINT "USER_EXTRA_BRANCHES_PK" PRIMARY KEY ("USER_EXTRA_ID", "BRANCH_ID"),
	 CONSTRAINT "FK_USER_EXTRA_BRANCHES_USER_EXTRA_ID" FOREIGN KEY ("USER_EXTRA_ID") REFERENCES USER_EXTRA(ID), 
	 CONSTRAINT "FK_USER_EXTRA_BRANCHES_BRANCH_ID" FOREIGN KEY ("BRANCH_ID") REFERENCES ATM_BRANCHES(ABR_ID)
	) TABLESPACE AUTH_REPORT_DATA_TS ;
	