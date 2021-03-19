DECLARE

	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	i_HEADER_FIELD CLOB;
	
BEGIN 

	-- BNOB
	i_BODY_QUERY := TO_CLOB('SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      SUM("A/R PER TERMINAL") "A/R PER TERMINAL",
      COUNT("ITEMS") "ITEMS",
      SUM("A/R PER TERMINAL") "TOTAL A/R AMOUNT"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      TXN.TRL_AMT_TXN "A/R PER TERMINAL",
      TXN.TRL_ID "ITEMS"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
	  AND TXN.TRL_ISS_NAME IS NULL
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL"
ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC');
	
	UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'BNOB File';
	
	-- ATM Transaction List (Summary) --
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"54","pdfLength":"54","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"56","pdfLength":"56","fieldType":"String","delimiter":";","defaultValue":"ATM TRANSACTION LIST SUMMARY","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"21","fieldName":"Space1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"22","fieldName":"Space2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"23","fieldName":"Space3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"24","fieldName":"Space4","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"8","fieldName":"Space1","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"9","fieldName":"Space2","csvTxtLength":"69","pdfLength":"69","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"10","fieldName":"Space3","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"13","fieldName":"EFP001-03","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","defaultValue":"EFP001-03","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"14","fieldName":"Space4","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"15","fieldName":"Space5","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"16","fieldName":"Space6","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	update REPORT_DEFINITION set RED_HEADER_FIELDS = i_HEADER_FIELD where RED_NAME = 'ATM Transaction List (Summary)';
	
	
	-- Summary of ATM Withdrawals Report--
	i_BODY_QUERY := TO_CLOB('SELECT
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
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = ''CBC'' AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ON-US",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = ''CBS'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "INTER-ENTITY",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "OTHER BANKS",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = ''CBC''  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH CARD",
      CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "NOW",
      CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "JUMP"
	FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 142, 143)
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND AST.AST_TERMINAL_TYPE IN (''ATM'', ''BRM'')
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
      "TERMINAL" ASC');
	  
	  i_TRAILER_QUERY := TO_CLOB('SELECT
      SUM("ON-US") "ON-US",
      SUM("INTER-ENTITY") "INTER-ENTITY",
      SUM("OTHER BANKS") "OTHER BANKS",
      SUM("CASH CARD") "CASH CARD",
      SUM("NOW") "NOW",
      SUM("JUMP") "JUMP",
      SUM("ON-US" + "INTER-ENTITY" + "OTHER BANKS" + "CASH CARD" + "NOW" + "JUMP") "TOTAL"
	FROM (
	SELECT
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = ''CBC'' AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ON-US",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = ''CBS'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "INTER-ENTITY",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "OTHER BANKS",
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_ISS_NAME = ''CBC'' AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'') THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH CARD",
      CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "NOW",
      CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "JUMP"
	FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 142, 143)
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND AST.AST_TERMINAL_TYPE IN (''ATM'', ''BRM'')
      AND {Branch_Code}
      AND {Branch_Name}
      AND {Txn_Date})'
	);
	
	UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY =  i_TRAILER_QUERY WHERE RED_NAME = 'Summary of ATM Withdrawals Report';
	
END;
/