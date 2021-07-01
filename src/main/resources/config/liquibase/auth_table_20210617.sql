CREATE TABLE DEVICE_ESTATE_OWNER 
   (	
    "DEO_ID" NUMBER(19,0) NOT NULL ENABLE,
	"DEO_NAME" VARCHAR2(50 BYTE),
	"DEO_REFERENCE_1" VARCHAR2(30 BYTE),
	"DEO_REFERENCE_2" VARCHAR2(30 BYTE),
	"DEO_INST_IDENT_CODE" VARCHAR2(30 BYTE),
	"DEO_EFFECTIVE_DATE" DATE,
	"DEO_STATUS" VARCHAR2(10 BYTE),
	"DEO_CUSTOM_DATA" VARCHAR2(4000 BYTE),
	"DEO_PRIMARY_CON_ID" NUMBER(19,0),
	"DEO_SECONDARY_CON_ID" NUMBER(19,0),
	"DEO_ORG_ID" NUMBER(19,0),
	"DEO_CODE" VARCHAR2(8 BYTE),
	"DEO_STATUS_TS"	TIMESTAMP(6),
	"DEO_LAST_UPDATE_TS" TIMESTAMP(6),
	"DEO_DCG_ID" NUMBER(19,0),
	CONSTRAINT "DEO_PK" PRIMARY KEY ("DEO_ID")
  ) TABLESPACE AUTH_REPORT_DATA_TS;
 
-- update job table to include DEVICE_ESTATE_OWNER 
UPDATE JOB SET TABLE_SYNC = 'ACCOUNT,ACCOUNT_TYPE,ATM_SUMMARY_COUNTERS,ATM_SUMMARY_VALUES,BRANCH,CARD,CARD_ACCOUNT,CARD_PRODUCT,CUSTOMER,CBC_MOVING_CASH,CBC_BANK,CBC_BIN,CBC_BILLER,CBC_TRAN_CODE,CBC_GL_TRANSACTION,CBC_GL_ACCOUNT,CBC_GL_ENTRY,ATM_STATIONS,ATM_BRANCHES,ATM_STATUS,ATM_STATUS_HISTORY,ATM_DEVICE_STATUS,ATM_DEVICE_TOTALS,ATM_TXN_ACTIVITY_LOG,ATM_JOURNAL_LOG,AUTH_RESULT_CODE,ENCRYPTION_KEY,SECURE_KEY,SECURITY_PARAMETERS,TRANSACTION_CODE,TRANSACTION_LOG,MERCHANT,TABLE_DETAILS,DEVICE_ESTATE_OWNER' WHERE NAME = 'DB_SYNC';	