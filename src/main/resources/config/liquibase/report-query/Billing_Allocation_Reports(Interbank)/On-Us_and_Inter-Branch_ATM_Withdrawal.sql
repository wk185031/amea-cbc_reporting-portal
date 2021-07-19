-- Tracking				Date			Name	Description
-- Report revision		16-JUL-2021		NY		Initial from UAT environment

DECLARE
    i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- On-Us and Inter-Branch ATM Withdrawal
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"Report ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"48","pdfLength":"48","fieldType":"String","delimiter":";","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"FileName","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"WITHDRAWAL TRANSACTIONS PER BRANCH AND TERMINAL (ON - US AND INTERBRANCH)","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TERM NO.","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TERM NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"TERMINAL NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TERMINAL NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"eol":true},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"TERMINAL","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"LOCATION","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"CARD BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":",","eol":true}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"Space2","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"Space3","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"Space4","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL COUNT","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"eol":false},{"sequence":6,"sectionName":"6","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":",","firstField":false,"eol":true}]');
	i_BODY_QUERY := TO_CLOB('
SELECT
     ABR.ABR_CODE "BRANCH CODE",
     ABR.ABR_NAME "BRANCH NAME",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     BRC.BRC_CODE "CARD BRANCH CODE",
     COUNT(TXN.TRL_ID) "TOTAL COUNT"
FROM
     TRANSACTION_LOG TXN
     JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
     JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
     JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
     JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE IN (42, 45, 48)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Txn_Date}
GROUP BY
      ABR.ABR_CODE,
      ABR.ABR_NAME,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID,
      BRC.BRC_CODE
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      BRC.BRC_CODE	
	');	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL COUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE IN (42, 45, 48)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Txn_Date}
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'On-Us and Inter-Branch ATM Withdrawal';
	
END;
/