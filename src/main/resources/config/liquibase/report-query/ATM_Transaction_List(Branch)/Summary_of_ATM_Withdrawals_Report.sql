-- Tracking				Date			Name	Description
-- Report revision		15-JUL-2021		NY		Initial from UAT environment
-- Report revision		23-JUL-2021		NY		Update based on excel spec

DECLARE
    i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Summary of ATM Withdrawals Report
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":"","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":"","defaultValue":"SUMMARY OF ATM WITHDRAWALS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":"","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":"","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"61","pdfLength":"61","fieldType":"String","defaultValue":"(DEBITED/POSTED ATM TRANSACTIONS)","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":"","defaultValue":"EFP000-0","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":"","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":"","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":"","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TERM","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":"","defaultValue":"TERM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","defaultValue":"BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ON-US/","csvTxtLength":"72","pdfLength":"72","fieldType":"String","delimiter":"","defaultValue":"ON-US/","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"MOVING CASH","csvTxtLength":"36","pdfLength":"36","fieldType":"String","delimiter":"","defaultValue":"MOVING CASH","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":"","defaultValue":"CODE","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"NO","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"NAME","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"INTER-BRANCH","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"INTER-BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"INTER-ENTITY","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"INTER-ENTITY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"OTHER BANKS","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"OTHER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"CASH CARD","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"CASH CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NOW","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"NOW","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"JUMP","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"JUMP","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":"","defaultValue":"TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"BRANCH NAME","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"ON-US","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"INTER-ENTITY","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"OTHER BANKS","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CASH CARD","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"NOW","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"JUMP","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SUB-TOTAL","csvTxtLength":"28","pdfLength":"28","fieldType":"String","defaultValue":"SUB-TOTAL","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"ON-US","csvTxtLength":"20","pdfLength":"20","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"INTER-ENTITY","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"OTHER BANKS","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CASH CARD","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"NOW","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"JUMP","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL","csvTxtLength":"19","pdfLength":"18","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_BODY_QUERY := TO_CLOB('		
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      SUM("ON-US") "ON-US",
      SUM("INTER-ENTITY") "INTER-ENTITY",
      SUM("OTHER BANKS") "OTHER BANKS",
      SUM("CASH CARD") "CASH CARD",
      SUM("NOW") "NOW",
      SUM("JUMP") "JUMP",
      SUM("ON-US" + "INTER-ENTITY" + "OTHER BANKS" + "CASH CARD" + "NOW" + "JUMP") "TOTAL"
	FROM (
	SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ON-US",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name} AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "INTER-ENTITY",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "OTHER BANKS",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH CARD",
      CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "NOW",
      CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "JUMP"
	FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 142, 143)
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE IN (''ATM'', ''BRM'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
	  AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != 12345
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
	)
	GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION"
	ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC
	');	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      SUM("ON-US") "ON-US",
      SUM("INTER-ENTITY") "INTER-ENTITY",
      SUM("OTHER BANKS") "OTHER BANKS",
      SUM("CASH CARD") "CASH CARD",
      SUM("NOW") "NOW",
      SUM("JUMP") "JUMP",
      SUM("ON-US" + "INTER-ENTITY" + "OTHER BANKS" + "CASH CARD" + "NOW" + "JUMP") "TOTAL"
	FROM (
	SELECT
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ON-US",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name} AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "INTER-ENTITY",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "OTHER BANKS",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH CARD",
      CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "NOW",
      CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "JUMP"
	FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 142, 143)
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE IN (''ATM'', ''BRM'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
	  AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != 12345
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Branch_Name}
      AND {Txn_Date})		
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Summary of ATM Withdrawals Report';
	
END;
/