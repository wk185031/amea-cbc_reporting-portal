DECLARE
	i_BODY_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	
BEGIN 

	-- Daily Payment Transaction Report by Utility Company
   	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACCOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":2,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"MN","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"MN","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TRAN","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRAN MNEM","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TERMINAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"TERMINAL NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"POSTING","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"POSTING DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"SEQUENCE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"SEQUENCE NUMBER","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TRAN","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"TRAN AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"SUBSCRIBER","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"SUBSCRIBER ACCT. NUMBER","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"NUMBER","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"MNEM","csvTxtLength":"16","pdfLength":"16","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"16","pdfLength":"16","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"NUMBER","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"ACCT. NUMBER","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":"2","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"20","fieldName":"MN","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"TRAN MNEM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"TERMINAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"SEQ NUMBER","csvTxtLength":"20","pdfLength":"20","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":27,"sectionName":"27","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"27","pdfLength":"27","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"BILLERSUBN"}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
      LPAD(CBL.CBL_CODE, 3, ''0'') "BILLER CODE",
      CBL.CBL_MNEM "BILLER MNEM",
      CTR.CTR_CHANNEL "CHANNEL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CBL.CBL_SETTLEMENT_TYPE "MN",
      CTR.CTR_MNEM "TRAN MNEM",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_AMT_TXN  "AMOUNT",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND {Biller_Code}
	  AND {Iss_Name}
      AND {Txn_Date}
ORDER BY
      CBL.CBL_CODE ASC,
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC');
	

	UPDATE REPORT_DEFINITION SET RED_BODY_FIELDS = i_BODY_FIELD , RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'Daily Payment Transaction Report by Utility Company';
	
-- Block Sheet Recycler --
	i_BODY_QUERY := TO_CLOB('
	SELECT
      ABR.ABR_CODE "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      TXN.TRL_AMT_TXN "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND CPD.CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND AST.AST_TERMINAL_TYPE = ''BRM''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      ABR.ABR_CODE "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      TXN.TRL_AMT_TXN "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND CPD.CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND AST.AST_TERMINAL_TYPE = ''BRM''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      TXN.TRL_DEST_STAN ASC
END');

	i_TRAILER_QUERY := TO_CLOB('
	SELECT
      SUM(TXN.TRL_AMT_TXN) "TOTAL DEBIT",
      0 AS "TOTAL CREDIT"
FROM
      TRANSACTION_LOG TXN
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND CPD.CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND AST.AST_TERMINAL_TYPE = ''BRM''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      0 AS "TOTAL DEBIT",
      SUM(TXN.TRL_AMT_TXN) "TOTAL CREDIT"
FROM
      TRANSACTION_LOG TXN
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND CPD.CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND AST.AST_TERMINAL_TYPE = ''BRM''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      TXN.TRL_DEST_STAN ASC
END');
	
	UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY , RED_TRAILER_QUERY = i_TRAILER_QUERY WHERE RED_NAME = 'Block Sheet Listing For Recycler';
	
	
-- ATM Availability
	i_BODY_QUERY := TO_CLOB('
	SELECT
     AST.AST_ARE_NAME "REGION",
     ABR.ABR_CODE "BRANCH CODE",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     AST.AST_ID "STATION ID",
     round(SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100), 2) "UNAVAILABLE",
     NVL(round(100 + (SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100)), 2) , 100) "AVAILABLE",    
     CASE WHEN SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100) < 5 THEN ''1'' ELSE ''0'' END "STANDARD"
FROM
      ATM_STATIONS AST
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD_AST_ID AND {Txn_Date} 
WHERE
	AST_ALO_LOCATION_ID NOT LIKE ''CBS%''
GROUP BY
      AST.AST_ARE_NAME,
      ABR.ABR_CODE,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID,
      AST.AST_ID
ORDER BY
      AST.AST_ARE_NAME  ASC,
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'ATM Availability';
	
END;
/