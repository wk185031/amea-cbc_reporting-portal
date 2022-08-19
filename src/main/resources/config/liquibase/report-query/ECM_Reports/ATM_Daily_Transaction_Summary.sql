-- Tracking				Date			Name	Description
-- Revise Report	 	25-JULY-2021	WY		Revise report according to requirement
-- CBCAXUPISSLOG-1335	19-AUG-202		NY		NVL change for improvement

DECLARE
	
	i_HEADER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","firstField":true},{"sequence":2,"sectionName":"2","fieldName":"REPORT ID","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":false,"delimiter":";","defaultValue":"REPORT ID:"},{"sequence":3,"sectionName":"3","fieldName":"EFPXX-XX","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"EFPXX-XX","firstField":false,"eol":true},{"sequence":4,"sectionName":"4","fieldName":"File Name","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"ATM DAILY TRANSACTION SUMMARY REPORT","firstField":true},{"sequence":5,"sectionName":"5","fieldName":"As of Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"DATE FROM:"},{"sequence":6,"sectionName":"6","fieldName":"From Date","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","eol":true},{"sequence":7,"sectionName":"7","fieldName":"","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":""},{"sequence":8,"sectionName":"8","fieldName":"As of Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"DATE TO:"},{"sequence":9,"sectionName":"9","fieldName":"Report To Date","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","eol":true}]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT
      COUNT("REJECTED COUNT") "REJECTED COUNT",
      COUNT("APPROVED COUNT") "APPROVED COUNT",
      COUNT("REJECTED COUNT") + COUNT("APPROVED COUNT") "TOTAL COUNT",
      SUM("AMOUNT") "AMOUNT"
FROM(
SELECT
      AST.AST_TERMINAL_ID "Terminal",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN 1 END AS "REJECTED COUNT",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 END AS "APPROVED COUNT",
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE
      TXN.TRL_TQU_ID = ''F'' 
	  AND (TXN.TRL_POST_COMPLETION_CODE IS NULL OR TXN.TRL_POST_COMPLETION_CODE NOT IN (''R''))
	  AND DEO.DEO_NAME = {V_Deo_Name}
      AND {Txn_Time}
	  AND {Terminal}
)
GROUP BY
      "Terminal"
ORDER BY
      "Terminal" ASC');
	
	i_TRAILER_QUERY := TO_CLOB('
	SELECT
      COUNT("REJECTED COUNT") "REJECTED COUNT",
      COUNT("APPROVED COUNT") "APPROVED COUNT",
      COUNT("REJECTED COUNT") + COUNT("APPROVED COUNT") "TOTAL COUNT",
      SUM("AMOUNT") "AMOUNT"
FROM(
SELECT
      AST.AST_TERMINAL_ID "Terminal",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN 1 END AS "REJECTED COUNT",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 END AS "APPROVED COUNT",
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE
      TXN.TRL_TQU_ID = ''F'' 
      AND (TXN.TRL_POST_COMPLETION_CODE IS NULL OR TXN.TRL_POST_COMPLETION_CODE NOT IN (''R''))
	  AND DEO.DEO_NAME = {V_Deo_Name}
      AND {Txn_Time})');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'ATM Daily Transaction Summary';
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = 'ATM Daily Transaction Summary' AND red_ins_id = 2;
	
END;
/