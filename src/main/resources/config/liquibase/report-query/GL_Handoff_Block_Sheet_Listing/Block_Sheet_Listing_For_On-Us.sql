-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-742	25-JUN-2021		NY		Initial config from UAT environment

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Block Sheet Listing For On-Us
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"BLOCK SHEET LISTING","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"72","pdfLength":"72","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"45","pdfLength":"45","fieldType":"String","defaultValue":"FOR ON-US","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL001P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL001P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"CODE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"DEBIT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"DEBIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"CREDIT","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"CREDIT","bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT NUMBER","csvTxtLength":"30","pdfLength":"30","fieldType":"String","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"DESCRIPTION","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"GL ACCOUNT NAME","csvTxtLength":"26","pdfLength":"26","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"CODE","csvTxtLength":"12","pdfLength":"12","fieldType":"String","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":14,"sectionName":"14","fieldName":"DEBIT","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"CREDIT","csvTxtLength":"14","pdfLength":"14","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"FROM ACCOUNT NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"DESCRIPTION","csvTxtLength":"36","pdfLength":"36","fieldType":"String","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"67","pdfLength":"67","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Line1","csvTxtLength":"29","pdfLength":"29","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"30","pdfLength":"30","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"38","pdfLength":"38","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"14","pdfLength":"14","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
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
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''On-Us'')
	  AND AST.AST_TERMINAL_TYPE NOT IN (''CDM'',''BRM'')
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
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''On-Us'')
	  AND AST.AST_TERMINAL_TYPE NOT IN (''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      TXN.TRL_DEST_STAN ASC
END		
	');	
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
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''On-Us'')
	  AND AST.AST_TERMINAL_TYPE NOT IN (''CDM'',''BRM'')
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
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''On-Us'')
	  AND AST.AST_TERMINAL_TYPE NOT IN (''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      TXN.TRL_DEST_STAN ASC
END		
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Block Sheet Listing For On-Us';
	
END;
/