-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Revise report		25-JULY-2021	WY		Revise IE reports based on spec
-- Revise report		05-AUG-2021		WY		Use CDM channel mnem for BRM channel
-- JIRA-830				06-AUG-2021		WY		Display amount for failed transaction

DECLARE
    i_BODY_FIELDS CLOB;
	i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Inter-Entity ATM Withdrawal as Issuer Bank
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACQUIRER BRCH","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"ACQUIRER BRCH","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"ACQUIRER TERM","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"ACQUIRER TERM","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"DATE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"SEQUENCE NO ACQUIRER","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"SEQUENCE NO ACQUIRER","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"SEQUENCE NO BANCNET","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"SEQUENCE NO BANCNET","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRAN MNEM","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN MNEM","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ACCT TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"ACCT TYPE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"ACCOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DR AMOUNT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"DR AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CR AMOUNT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"CR AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"REPLY","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"REPLY","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"COMMENT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMMENT","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" ","bodyHeader":true,"eol":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"ACCT TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"DR AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"CR AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TRAN MNEM", "csvTxtLength":"10", "fieldType":"String","delimiter":";","fieldFormat":"", "firstField":true, "leftJustified":true, "padFieldLength":0,"decrypt":false,"pdfLength":"10"},{"sequence":2,"sectionName":"2","fieldName":"TOTAL TRAN", "csvTxtLength":"10", "fieldType":"Number", "delimiter":";", "fieldFormat":",", "leftJustified":false, "padFieldLength":0, "decrypt":false,"pdfLength":"10"},{"sequence":3,"sectionName":"3","fieldName":"NET SETTLEMENT", "csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"pdfLength":"10"}]');
	
	i_BODY_QUERY := TO_CLOB('SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      LPAD(CBA.CBA_CODE, 4, ''0'') "BANK CODE",
      CBA.CBA_NAME "BANK NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "ACCT TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TQU_ID != ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DR AMOUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CR AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
WHERE
      (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC');
	  
	  i_TRAILER_QUERY := TO_CLOB('
	  SELECT "TRAN MNEM", COUNT(TRL_ID) "TOTAL TRAN", SUM(TRL_AMT_TXN) "NET SETTLEMENT"
	  FROM(SELECT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_ID,TXN.TRL_AMT_TXN
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      JOIN ACCOUNT_TYPE ATP ON TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = ATP.ATP_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
	  AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
      AND {Txn_Date})
GROUP BY "TRAN MNEM"
ORDER BY "TRAN MNEM"');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'Inter-Entity ATM Withdrawal as Issuer Bank';
	
END;
/