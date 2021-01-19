DECLARE
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Daily Payment Transaction Report by Utility Company
	i_BODY_QUERY := TO_CLOB('		
SELECT
      LPAD(CBL.CBL_CODE, 3, ''0'') "BILLER CODE",
      CBL.CBL_MNEM "BILLER MNEM",
      CTR.CTR_CHANNEL "CHANNEL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CBL.CBL_SETTLEMENT_TYPE "MN",
      CTR.CTR_MNEM "TRAN MNEM",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_AMT_TXN  "AMOUNT",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BILLER CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND {Biller_Code}
	  AND {Iss_Name}
      AND {Txn_Date}
ORDER BY
      CBL.CBL_CODE ASC,
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC  
	');
	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND {Iss_Name}
      AND {Txn_Date}  
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY where RED_NAME = 'Daily Payment Transaction Report by Utility Company';

-- Summary of Recycler Transactions (fix for missing body field/trailer field)
   	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"19","fieldName":"BRANCH","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"20","fieldName":"TERMINAL","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"21","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"1","fieldName":"Transaction","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANSACTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"2","fieldName":"On-us","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"ON-US /","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"3","fieldName":"Description","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DESCRIPTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"4","fieldName":"Inter-branch","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INTER-BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"5","fieldName":"Inter-Entity","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INTER-ENTITY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","fieldName":"Other Banks","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"OTHER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"7","fieldName":"Cash Card","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CASH CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"8","fieldName":"Total Dispensed","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"9","fieldName":"Total Deposit","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL DEPOSIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"10","fieldName":"Net Total","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"NET-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"11","fieldName":"TRANSACTION TYPE","csvTxtLength":"","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false,"defaultValue":""},{"sequence":15,"sectionName":"12","fieldName":"ONUS","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":16,"sectionName":"13","fieldName":"INTER ENTITY","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":17,"sectionName":"14","fieldName":"OTHER BANKS","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":18,"sectionName":"15","fieldName":"CASH CARD","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":19,"sectionName":"16","fieldName":"TOTAL DISPENSED","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":20,"sectionName":"17","fieldName":"TOTAL DEPOSIT","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');
	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"","fieldType":"String","delimiter":"","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD where RED_NAME = 'Summary of Recycler Transactions';
END;
/