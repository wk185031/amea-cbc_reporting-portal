-- Tracking				Date			Name	Description
-- Report revision		26-JUL-2021		WY		Revised reports based on spec
-- CBCAXUPISSLOG-531	10-AUG-2021		KW		Only include acquiring and OnUs txn from terminal
-- Report revision		14-AUG-2021		WY		Include reverse and failed txn
-- Report revision		21-AUG-2021		WY		Fix for count and amt display

DECLARE
	i_BODY_FIELDS CLOB;
	i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	
BEGIN 

	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TRAN","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":"","defaultValue":"TRAN","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GOOD TRANS","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":"","defaultValue":"GOOD TRANS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"BAD TRANS","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":"","defaultValue":"BAD TRANS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TOTAL TRANS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","defaultValue":"TOTAL TRANS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"SHORT DISP","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","defaultValue":"SHORT DISP","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"NO DISP","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":"","defaultValue":"NO DISP","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"CASH DISPENSED","csvTxtLength":"19","pdfLength":"19","fieldType":"String","delimiter":"","defaultValue":"CASH DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"DEPOSITS","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":"","defaultValue":"DEPOSITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"BILL/INS","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":"","defaultValue":"BILL/INS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"LOAN PAYMENTS","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":"","defaultValue":"LOAN PAYMENTS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TRANSFERS","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":"","defaultValue":"TRANSFERS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"MNEM","csvTxtLength":"109","pdfLength":"109","fieldType":"String","delimiter":"","defaultValue":"MNEM","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"PAYMENTS","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":"","defaultValue":"PAYMENTS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"GOOD TRANS","csvTxtLength":"15","pdfLength":"15","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"BAD TRANS","csvTxtLength":"12","pdfLength":"12","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TOTAL TRANS","csvTxtLength":"15","pdfLength":"15","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"SHORT DISP","csvTxtLength":"14","pdfLength":"14","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NO DISP","csvTxtLength":"12","pdfLength":"12","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"CASH DISPENSED","csvTxtLength":"20","pdfLength":"20","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"DEPOSITS","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"BILL/INS PAYMENTS","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"LOAN PAYMENTS","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"TRANSFERS","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","delimiter":"","firstField":true,"eol":true,"defaultValue":"_","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GOOD TRANS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"BAD TRANS","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TOTAL TRANS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"SHORT DISP","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"NO DISP","csvTxtLength":"12","pdfLength":"12","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CASH DISPENSED","csvTxtLength":"20","pdfLength":"20","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"DEPOSITS","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"BILL/INS PAYMENTS","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"LOAN PAYMENTS","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"TRANSFERS","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
		
	i_BODY_QUERY := TO_CLOB('
	SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "TRAN MNEM",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("GOOD TRANS") + COUNT("BAD TRANS")  "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      0 "DEPOSITS",
      0 "BILL/INS PAYMENTS",
      0 "LOAN PAYMENTS",
      0 "TRANSFERS"
	FROM (
	SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_POST_COMPLETION_CODE IS NULL) THEN 1 ELSE NULL END AS "GOOD TRANS",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE > 0 OR (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''R'')) THEN 1 ELSE NULL END AS "BAD TRANS",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE > 0 OR (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''R'')) THEN TXN.TRL_AMT_TXN ELSE NULL END AS "NO DISP",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_POST_COMPLETION_CODE IS NULL) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''I-'' || TXNC.TRL_ORIGIN_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      (TXN.TRL_TSC_CODE IN (128, 31) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL))
      AND TXN.TRL_TQU_ID IN (''F'',''R'') 
      AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
	)
	GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "TRAN MNEM"
	ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC,
      "TRAN MNEM" ASC		
	');	
	
	i_TRAILER_QUERY := TO_CLOB('
	SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("GOOD TRANS") + COUNT("BAD TRANS")  "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      0 "DEPOSITS",
      0 "BILL/INS PAYMENTS",
      0 "LOAN PAYMENTS",
      0 "TRANSFERS"
	FROM (
	SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_POST_COMPLETION_CODE IS NULL) THEN 1 ELSE NULL END AS "GOOD TRANS",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE > 0 OR (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''R'')) THEN 1 ELSE NULL END AS "BAD TRANS",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE > 0 OR (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''R'')) THEN TXN.TRL_AMT_TXN ELSE NULL END AS "NO DISP",
      CASE WHEN (TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_POST_COMPLETION_CODE IS NULL) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''I-'' || TXNC.TRL_ORIGIN_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      (TXN.TRL_TSC_CODE IN (128, 31) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL))
      AND TXN.TRL_TQU_ID IN (''F'',''R'') 
      AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}
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
	
	
	UPDATE REPORT_DEFINITION SET 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Transaction Summary Grand Total for Inter-Entity';
	
END;
/