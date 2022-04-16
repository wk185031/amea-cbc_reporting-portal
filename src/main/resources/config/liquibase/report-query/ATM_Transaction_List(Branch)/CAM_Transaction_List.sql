-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Rel-20210730			30-JUL-2021		KW		Fix Recycler transaction summary
-- CBCAXUPISSLOG-916	09-SEP-2021		NY		Deposit to 'To Account' print 0 account number

DECLARE
    i_REPORT_NAME VARCHAR2(100) := 'CAM Transaction List';
    i_PROCESSING_CLASS VARCHAR2(200) := 'my.com.mandrill.base.reporting.reportProcessor.BranchReportSplitFileProcessor';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- CAM Transaction List

	-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"CAM TRANSACTION LIST","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"111","pdfLength":"111","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"EFC015-07","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"EFC015-07","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"ATM CARD NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DATE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TIME","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"AMOUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"VOID","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"VOID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"COMMENT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMMENT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"MNEM","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":17,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","firstField":true,"defaultValue":"","leftJustified":true,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","defaultValue":"","leftJustified":true,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":19,"sectionName":"18","fieldName":"ATM CARD NUMBER","csvTxtLength":"21","pdfLength":"21","fieldType":"String","leftJustified":true,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"19","fieldName":"DATE","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"20","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"21","fieldName":"TRAN MNEM","csvTxtLength":"5","pdfLength":"5","fieldType":"String","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"22","fieldName":"FROM ACCOUNT NO","csvTxtLength":"30","pdfLength":"30","fieldType":"String","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"23","fieldName":"TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"25","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"40","pdfLength":"40","fieldType":"String","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBC := null;

	-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"CAM TRANSACTION LIST","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"111","pdfLength":"111","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"EFC015-07","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"EFC015-07","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"ATM CARD NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DATE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TIME","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"AMOUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"VOID","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"VOID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"COMMENT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMMENT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"MNEM","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":17,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","firstField":true,"defaultValue":"","leftJustified":true,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","defaultValue":"","leftJustified":true,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":19,"sectionName":"18","fieldName":"ATM CARD NUMBER","csvTxtLength":"21","pdfLength":"21","fieldType":"String","leftJustified":true,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"19","fieldName":"DATE","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"20","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"21","fieldName":"TRAN MNEM","csvTxtLength":"5","pdfLength":"5","fieldType":"String","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"22","fieldName":"FROM ACCOUNT NO","csvTxtLength":"30","pdfLength":"30","fieldType":"String","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"23","fieldName":"TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"25","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"40","pdfLength":"40","fieldType":"String","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBS := null;
	

	i_BODY_QUERY := TO_CLOB('	
	SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
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
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE 
	    AND CTR.CTR_CHANNEL = CASE WHEN (TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''I-CDM'' ELSE ''CDM'' END
	    AND CTR_DEBIT_CREDIT = ''DEBIT''
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
	WHERE
      (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_TSC_CODE != 26
      AND AST.AST_TERMINAL_TYPE = ''CDM''
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      -- AND ABR.ABR_CODE = {BRANCH_CODE}
      AND {Txn_Date}
    UNION ALL 
    SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_ACCOUNT_2_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TYPE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE 
	    AND CTR.CTR_CHANNEL = CASE WHEN (TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''I-CDM'' ELSE ''CDM'' END
	    AND CTR_DEBIT_CREDIT = ''CREDIT''
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
	WHERE
      (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_TSC_CODE = 26
      AND AST.AST_TERMINAL_TYPE = ''CDM''
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      -- AND ABR.ABR_CODE = {BRANCH_CODE}
      AND {Txn_Date}
	ORDER BY
      "BRANCH CODE",
      "TERMINAL",
      "DATE",
      "TIME"
	');

	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/