-- Tracking					Date			Name	Description
-- Rel-20210730				04-JUL-2021		KW		Revise report based on specification
-- JIRA 950					04-OCT-2021		WY		Change dps format

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Bills Payment Extract Files (Detailed Transactions)';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Header Indicator","csvTxtLength":"2","fieldType":"String","defaultValue":"HR","firstField":true,"leftJustified":true,"padFieldLength":0},
{"sequence":2,"sectionName":"2","fieldName":"Process Date","csvTxtLength":"8","fieldType":"Date","fieldFormat":"yyyyMMdd","leftJustified":true,"padFieldLength":0}]');

	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Institution Header Indicator","csvTxtLength":"2","fieldType":"String","defaultValue":"IH","firstField":true, "bodyHeader":true,"leftJustified":true,"padFieldLength":0},
{"sequence":2,"sectionName":"2","fieldName":"BILLER CODE","csvTxtLength":"4","fieldType":"String","defaultValue":"","firstField":true, "bodyHeader":true,"leftJustified":true,"padFieldLength":0},
{"sequence":3,"sectionName":"3","fieldName":"Institution Detail Indicator","csvTxtLength":"2","fieldType":"String","defaultValue":"ID","firstField":true, "bodyHeader":false,"leftJustified":true,"padFieldLength":0,"eol":true},
{"sequence":4,"sectionName":"4","fieldName":"ISSUER BANK CODE","csvTxtLength":"4","fieldType":"String","defaultValue":"","firstField":false, "bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":5,"sectionName":"5","fieldName":"ACQUIRER BANK CODE","csvTxtLength":"4","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":6,"sectionName":"6","fieldName":"SEQ NUMBER","csvTxtLength":"6","fieldType":"Number","bodyHeader":false,"defaultValue":"", "leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":7,"sectionName":"7","fieldName":"DATE","csvTxtLength":"8","fieldType":"Date","defaultValue":"","fieldFormat":"yyyyMMdd","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":8,"sectionName":"8","fieldName":"TIME","csvTxtLength":"6","fieldType":"Date","defaultValue":"","fieldFormat":"HHmmss","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":9,"sectionName":"9","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"20","fieldType":"String","fieldFormat":"","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":"20","decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros","tagValue":"BILLERSUBN"},
{"sequence":10,"sectionName":"10","fieldName":"ATM CARD NUMBER","csvTxtLength":"19","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},
{"sequence":11,"sectionName":"11","fieldName":"FROM ACCOUNT NO","csvTxtLength":"16","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},
{"sequence":12,"sectionName":"12","fieldName":"Tran Amount","csvTxtLength":"12","fieldType":"String","bodyHeader":false,"defaultValue":"","fieldFormat":"","leftJustified":false,"padFieldLength":"12","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},
{"sequence":13,"sectionName":"13","fieldName":"TELEPHONE NUMBER","csvTxtLength":"7","fieldType":"Number","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":14,"sectionName":"14","fieldName":"BILLER CODE","csvTxtLength":"4","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":15,"sectionName":"15","fieldName":"CARDHOLDER NAME","csvTxtLength":"30","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":16,"sectionName":"16","fieldName":"PAYMENT MODE","csvTxtLength":"1","fieldType":"Number","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":17,"sectionName":"17","fieldName":"TERMINAL","csvTxtLength":"8","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	
 	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Trailer Indicator ","csvTxtLength":"2","fieldType":"Number","defaultValue":"TR", "firstField":true,"delimiter":"","leftJustified":true},
	{"sequence":2,"sectionName":"2","fieldName":"Total Count","csvTxtLength":"16","fieldType":"Number","defaultValue":"","fieldFormat":"","leftJustified":false,"padFieldLength":"16","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},
	{"sequence":3,"sectionName":"3","fieldName":"Total Payments","csvTxtLength":"18","fieldType":"String","fieldFormat":"","leftJustified":false,"padFieldLength":"18","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"}]');
 	    
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
      LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') "BILLER CODE",
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
	  left JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      left JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      left JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      left JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	  AND NVL(CPD.CPD_CODE, ''O'') IN (''80'',''81'',''82'',''83'')
	  AND LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') = {BILLER CODE}
    ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
	 START SELECT * FROM(
	SELECT distinct
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
      LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') "BILLER CODE",
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
      left JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      left JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      left JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      left JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
      AND NVL(CPD.CPD_CODE, ''O'') not IN (''80'',''81'',''82'',''83'')
	  AND LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') = {BILLER CODE})
	ORDER BY "DATE", "TIME",  "SEQ NUMBER" ASC
	END BODY
	SELECT DISTINCT LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') "BILLER CODE"
	FROM TRANSACTION_LOG TXN
    JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
    JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
    JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	END CRITERIA'); 
  
  i_TRAILER_QUERY := TO_CLOB('
    SELECT
      LPAD(COUNT(TXN.TRL_ID), 16, 0) "Total Count",
      LPAD(SUM((TXN.TRL_AMT_TXN) * 100), 15, 0) "Total Payments"
    FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	  left JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      left JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      left JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      left JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  {BILLER CODE}
	 START SELECT
      LPAD(COUNT("ID"), 16, 0) "Total Count",
      LPAD(SUM(("AMT") * 100), 15, 0) "Total Payments"
    FROM(
	SELECT DISTINCT TXN.TRL_ID "ID", TXN.TRL_AMT_TXN "AMT"
	FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	  left JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      left JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      left JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      left JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	  {BILLER CODE}
	  AND NVL(CPD.CPD_CODE, ''O'') not IN (''80'',''81'',''82'',''83''))
	 END'); 
	  
	UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_FILE_NAME_PREFIX = 'CBC_'
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_FILE_NAME_PREFIX = 'CBS_'
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	  
END;
/