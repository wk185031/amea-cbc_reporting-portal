CREATE TABLE "ISSUER" (	
	"ISS_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"ISS_NAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ISS_REFERENCE_1" VARCHAR2(30 BYTE), 
	"ISS_REFERENCE_2" VARCHAR2(30 BYTE), 
	"ISS_EFFECTIVE_DATE" DATE, 
	"ISS_STATUS" VARCHAR2(10 BYTE) DEFAULT 'ACTIVE' NOT NULL ENABLE, 
	"ISS_DEFAULT_CUR_ID" NUMBER(5,0) NOT NULL ENABLE, 
	"ISS_ERG_NAME" VARCHAR2(100 BYTE), 
	"ISS_CLEARING_HOUSE" VARCHAR2(50 BYTE), 
	"ISS_COUNTRY_CODE" VARCHAR2(3 BYTE), 
	"ISS_CUSTOM_DATA" VARCHAR2(4000 BYTE), 
	"ISS_SMBR_ID" NUMBER(19,0), 
	"ISS_ORG_ID" NUMBER(19,0), 
	"ISS_PRIMARY_CON_ID" NUMBER(19,0), 
	"ISS_SECONDARY_CON_ID" NUMBER(19,0), 
	"ISS_ISSUING_INST_IDENT_CODE" VARCHAR2(30 BYTE), 
	"ISS_STATUS_TS" TIMESTAMP (6), 
	"ISS_LAST_UPDATE_TS" TIMESTAMP (6), 
	 CONSTRAINT "ISS_NAME_UK" UNIQUE ("ISS_NAME")
) TABLESPACE AUTH_REPORT_DATA_TS;

update job set table_sync='ACCOUNT,ACCOUNT_TYPE,ATM_SUMMARY_COUNTERS,ATM_SUMMARY_VALUES,BRANCH,CARD,CARD_ACCOUNT,CARD_PRODUCT,CUSTOMER,CBC_MOVING_CASH,CBC_BANK,CBC_BIN,CBC_BILLER,CBC_TRAN_CODE,CBC_GL_TRANSACTION,CBC_GL_ACCOUNT,CBC_GL_ENTRY,ATM_STATIONS,ATM_BRANCHES,ATM_STATUS,ATM_STATUS_HISTORY,ATM_DEVICE_STATUS,ATM_DEVICE_TOTALS,ATM_TXN_ACTIVITY_LOG,ATM_JOURNAL_LOG,AUTH_RESULT_CODE,ENCRYPTION_KEY,SECURE_KEY,SECURITY_PARAMETERS,TRANSACTION_CODE,TRANSACTION_LOG,MERCHANT,TABLE_DETAILS,DEVICE_ESTATE_OWNER,ISSUER' where name='DB_SYNC';