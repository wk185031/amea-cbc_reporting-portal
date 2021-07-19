-- Tracking					Date			Name	Description
-- Report Revise			04-JULy-2021	KW		Revise report based on specification

DECLARE
	i_BODY_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_FIELD CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 	  
  i_BODY_QUERY := TO_CLOB('
    SELECT
      LPAD(CBA.CBA_CODE, 4, ''0'') "ISSUER BANK CODE",
      SUBSTR(LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0''), -4) "ACQUIRER BANK CODE",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      (TXN.TRL_AMT_TXN * 100)  "Tran Amount",
      0 "TELEPHONE NUMBER",
      LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') "BILLER CODE",
      '''' "CARDHOLDER NAME",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN ''1''
               WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''2''
               WHEN TXNC.TRL_ORIGIN_CHANNEL = ''IVR'' THEN ''4''
               WHEN TXNC.TRL_ORIGIN_CHANNEL = ''EBK'' THEN ''5''
               WHEN TXNC.TRL_ORIGIN_CHANNEL = ''MBK'' THEN ''6''
      END AS "PAYMENT MODE",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL"
    FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
    WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
    ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
  '); 

  i_BODY_FIELD := TO_CLOB('
	[{"sequence":1,"sectionName":"1","fieldName":"ISSUER BANK CODE","csvTxtLength":"4","fieldType":"String","defaultValue":"","firstField":false,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"ACQUIRER BANK CODE","csvTxtLength":"4","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"SEQ NUMBER","csvTxtLength":"6","fieldType":"Number","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DATE","csvTxtLength":"6","fieldType":"Date","defaultValue":"","fieldFormat":"yyMMdd","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TIME","csvTxtLength":"6","fieldType":"Date","defaultValue":"","fieldFormat":"HHmmss","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"20","fieldType":"String","fieldFormat":"","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":"20","decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros","tagValue":"BILLERSUBN"},{"sequence":7,"sectionName":"7","fieldName":"ATM CARD NUMBER","csvTxtLength":"19","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":8,"sectionName":"8","fieldName":"FROM ACCOUNT NO","csvTxtLength":"16","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":9,"sectionName":"9","fieldName":"Tran Amount","csvTxtLength":"10","fieldType":"String","bodyHeader":false,"defaultValue":"","fieldFormat":"","leftJustified":false,"padFieldLength":"12","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":10,"sectionName":"10","fieldName":"TELEPHONE NUMBER","csvTxtLength":"7","fieldType":"Number","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"BILLER CODE","csvTxtLength":"3","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"CARDHOLDER NAME","csvTxtLength":"30","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"PAYMENT MODE","csvTxtLength":"1","fieldType":"Number","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"TERMINAL","csvTxtLength":"8","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"Space1","csvTxtLength":"15","fieldType":"String","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
  ');
  
  i_TRAILER_QUERY := TO_CLOB('
    SELECT
      COUNT(TXN.TRL_ID) "Total Count",
      (SUM(TXN.TRL_AMT_TXN) * 100) "Total Payments"
    FROM
      TRANSACTION_LOG TXN
    WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
  '); 
  
  i_TRAILER_FIELD := TO_CLOB('
    [{"sequence":1,"sectionName":"1","fieldName":"Filler 1","csvTxtLength":"69","fieldType":"Number","defaultValue":"9999","firstField":false,"delimiter":"","leftJustified":true,"padFieldLength":"69","decrypt":false,"decryptionKey":null,"padFieldType":"Trailing","padFieldValue":"Zeros"},{"sequence":2,"sectionName":"2","fieldName":"Total Count","csvTxtLength":"16","fieldType":"Number","defaultValue":"","fieldFormat":"","leftJustified":false,"padFieldLength":"16","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":3,"sectionName":"3","fieldName":"Total Payments","csvTxtLength":"12","fieldType":"String","fieldFormat":"","leftJustified":false,"padFieldLength":"12","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":4,"sectionName":"4","fieldName":"Filler 2","csvTxtLength":"60","fieldType":"Number","eol":false,"defaultValue":"0","leftJustified":true,"padFieldLength":"60","decrypt":false,"decryptionKey":null,"padFieldType":"Trailing","padFieldValue":"Zeros"}]
  ');  
	  
UPDATE REPORT_DEFINITION SET RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY=i_BODY_QUERY, RED_TRAILER_FIELDS=i_TRAILER_FIELD, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'Bills Payment Extract Files (Detailed Transactions)';
	  
END;
/