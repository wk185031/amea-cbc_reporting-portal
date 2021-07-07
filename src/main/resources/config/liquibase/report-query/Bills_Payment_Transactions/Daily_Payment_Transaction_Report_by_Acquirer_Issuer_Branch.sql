-- Tracking			Date			Name	Description
-- JIRA 691			06-JULy-2021	WY		Display biller mnem instead of bank code in field company code

DECLARE
	i_BODY_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_FIELD CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 	  
  i_BODY_QUERY := TO_CLOB('
    SELECT
      {Branch_Code} "BRANCH CODE",
      {Branch_Name} "BRANCH NAME",
      TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, 0) "BANK CODE",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      CBA.CBA_MNEM "BANK MNEM",
      CBL.CBL_SETTLEMENT_TYPE "MN",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_AMT_TXN  "AMOUNT",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
	  CBL.CBL_MNEM "BILLER MNEM"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CBC_BILLER CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      {Join_Criteria}
WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Txn_Criteria}
	  AND {Deo_Name}
	  AND {Iss_Name}
      AND {Txn_Date}
ORDER BY
      CBA.CBA_CODE ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
  '); 

  i_BODY_FIELD := TO_CLOB('
	[{"sequence":1,"sectionName":"1","fieldName":"ACCOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"BANK","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"BANK CODE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TERMINAL","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"TERMINAL NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"COMPANY","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"COMPANY CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"MN","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"MN","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"POSTING","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"POSTING DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TIME","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"SEQUENCE","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"SEQUENCE NUMBER","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"TRANSACTION","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"TRANSACTION AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"SUBSCRIBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"SUBSCRIBER ACCOUNT NUMBER","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"CODE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"CODE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"DATE","csvTxtLength":"32","pdfLength":"32","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"AMOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"ACCOUNT NUMBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"20","fieldName":"BANK CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"TERMINAL","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"BILLER MNEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"MN","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"SEQ NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"27","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"BILLERSUBN"}]
  ');
  
  i_TRAILER_QUERY := TO_CLOB('
    SELECT
      CBL.CBL_SETTLEMENT_TYPE "MN",
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CBC_BILLER CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      {Join_Criteria}
WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Txn_Criteria}
	  AND {Deo_Name}
	  AND {Iss_Name}
      AND {Txn_Date}
GROUP BY
      CBL.CBL_SETTLEMENT_TYPE
  '); 
  
  i_TRAILER_FIELD := TO_CLOB('
    [{"sequence":1,"sectionName":"1","fieldName":"MN","csvTxtLength":"3","pdfLength":"3","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL TRAN","csvTxtLength":"20","pdfLength":"20","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
  ');  
	  
UPDATE REPORT_DEFINITION SET 
RED_BODY_FIELDS=i_BODY_FIELD, 
RED_BODY_QUERY=i_BODY_QUERY, 
RED_TRAILER_FIELDS=i_TRAILER_FIELD, 
RED_TRAILER_QUERY=i_TRAILER_QUERY 
WHERE RED_NAME = 'Daily Payment Transaction Report by Acquirer/Issuer Branch';
	  
END;
/