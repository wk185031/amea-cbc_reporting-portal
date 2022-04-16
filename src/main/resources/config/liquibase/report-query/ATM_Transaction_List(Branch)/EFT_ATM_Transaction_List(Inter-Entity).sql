-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Revise report		25-JULY-2021	WY		Revise IE reports based on spec
-- CBCAXUPISSLOG-531	10-AUG-2021		KW		Only include acquiring and OnUs txn from terminal
-- CBCAXUPISSLOG-868	02-SEP-2021		WY		To display **NO TRANSACTIONS FOR THE DAY** for reports with no data
-- CBCAXUPISSLOG-1171	24-MAR-2022		WY		Add terminal name (location) in the report

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'EFT - ATM Transaction List (Inter-Entity)';
	i_PROCESSING_CLASS VARCHAR2(100) := 'my.com.mandrill.base.reporting.reportProcessor.BranchReportSplitFileProcessor';
    i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	
BEGIN 

-- EFT - ATM Transaction List (Inter-Entity)
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"ATM CARD NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"TYPE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"AMOUNT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"VOID","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"VOID","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"COMMENT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMMENT","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"TERMINAL","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"","decrypt":false,"padFieldLength":0,"group":true},{"sequence":14,"sectionName":"14","fieldName":"NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0}, {"sequence":15,"sectionName":"15","fieldName":"NUMBER","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"MNEM","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},
	{"sequence":18,"sectionName":"18","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"6","padFieldType":"Leading","padFieldValue":"Zeros"},
	{"sequence":19,"sectionName":"19","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"6","padFieldType":"Leading","padFieldValue":"Zeros"},
	{"sequence":20,"sectionName":"20","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldLength":"19","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":21,"sectionName":"21","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":22,"sectionName":"22","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},
	{"sequence":23,"sectionName":"23","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},
	{"sequence":24,"sectionName":"24","fieldName":"FROM ACCOUNT NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldLength":"16","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":25,"sectionName":"25","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":26,"sectionName":"26","fieldName":"AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},
	{"sequence":27,"sectionName":"27","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"3","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":28,"sectionName":"28","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) || '' - '' || AST.AST_ALO_LOCATION_ID "TERMINAL",
      --AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TYPE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''I-'' || TXNC.TRL_ORIGIN_CHANNEL
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
	WHERE
      (TXN.TRL_TSC_CODE IN (128, 31, 142, 143) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL))
      AND (TXN.TRL_TQU_ID =''F'' OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))  
	  AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      -- AND ABR.ABR_CODE = {BRANCH_CODE}
      AND {Txn_Date}
	ORDER BY
      "BRANCH CODE" ASC,
	  "BRANCH NAME" ASC,
      "TERMINAL" ASC,
      "DATE" ASC,
	  "TIME" ASC,
      "SEQ NUMBER" ASC
	');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS
	where RED_NAME = i_REPORT_NAME;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, '0010', '0112') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
END;
/