-- Tracking					Date			Name	Description
-- Release-20210814			13-AUG-2021		KW		Revise CASA
-- Release-20210823			22-AUG-2021		KW		Fix 24h format

DECLARE

	i_REPORT_NAME VARCHAR2(100) := 'CASA (POS)';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 
	  
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Header","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"[Header]","firstField":true,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Type","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"Type = CASA","firstField":true,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Txns","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"[Txns]","firstField":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACQUIRER BANK CODE","csvTxtLength":"4","pdfLength":"","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"DATE","csvTxtLength":"8","pdfLength":"","fieldType":"Date","fieldFormat":"MMddyyyy","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TIME","csvTxtLength":"6","pdfLength":"","fieldType":"Date","fieldFormat":"HHmmss","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TERMINAL","csvTxtLength":"4","pdfLength":"","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"FROM ACCOUNT NO","csvTxtLength":"16","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID"},{"sequence":6,"sectionName":"6","fieldName":"TRANSACTION CODE","csvTxtLength":"3","pdfLength":"","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"AMOUNT","csvTxtLength":"9","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TRACE NUMBER","csvTxtLength":"6","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"RECEIVING BANK CODE","csvTxtLength":"4","pdfLength":"","fieldType":"Number","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"eol":false},{"sequence":10,"sectionName":"10","fieldName":"TO ACCOUNT NO","csvTxtLength":"16","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID"},{"sequence":11,"sectionName":"11","fieldName":"MERCHANT ID","csvTxtLength":"15","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"BILLER CODE","csvTxtLength":"4","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"16","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"BILLERSUBN","eol":false},{"sequence":14,"sectionName":"14","fieldName":"BRANCH CODE","csvTxtLength":"4","pdfLength":"","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBC := null;
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Header","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"[Header]","firstField":true,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Type","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"Type = CASA","firstField":true,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Txns","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"[Txns]","firstField":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACQUIRER BANK CODE","csvTxtLength":"4","pdfLength":"","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"DATE","csvTxtLength":"8","pdfLength":"","fieldType":"Date","fieldFormat":"MMddyyyy","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TIME","csvTxtLength":"6","pdfLength":"","fieldType":"Date","fieldFormat":"HHmmss","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TERMINAL","csvTxtLength":"4","pdfLength":"","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"FROM ACCOUNT NO","csvTxtLength":"16","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID"},{"sequence":6,"sectionName":"6","fieldName":"TRANSACTION CODE","csvTxtLength":"3","pdfLength":"","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"AMOUNT","csvTxtLength":"9","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TRACE NUMBER","csvTxtLength":"6","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"RECEIVING BANK CODE","csvTxtLength":"4","pdfLength":"","fieldType":"Number","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"eol":false},{"sequence":10,"sectionName":"10","fieldName":"TO ACCOUNT NO","csvTxtLength":"16","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID"},{"sequence":11,"sectionName":"11","fieldName":"MERCHANT ID","csvTxtLength":"15","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"BILLER CODE","csvTxtLength":"4","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"16","pdfLength":"","fieldType":"Number","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"BILLERSUBN","eol":false},{"sequence":14,"sectionName":"14","fieldName":"BRANCH CODE","csvTxtLength":"4","pdfLength":"","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := null;
	  
	  
	  i_BODY_QUERY := TO_CLOB('
SELECT
      SUBSTR(LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0''), -4) "ACQUIRER BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN ''SLR'' ELSE ''SAL''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT AS "MERCHANT ID",
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
WHERE
      TXN.TRL_MCC_ID = 6012
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_TSC_CODE = 0
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
	  ');
	  
	i_TRAILER_QUERY := null;
	  
	UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	  
END;
/