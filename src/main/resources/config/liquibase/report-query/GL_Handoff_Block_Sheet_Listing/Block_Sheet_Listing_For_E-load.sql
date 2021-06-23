-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-645	08-JUN-2021		NY		Filter by CBC/CBS institution
-- CBCAXUPISSLOG-645	23-JUN-2021		NY 		Fix wrong CBS GL account print in report

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Block Sheet Listing For E-load
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"BLOCK SHEET LISTING","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"72","pdfLength":"72","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"45","pdfLength":"45","fieldType":"String","defaultValue":"FOR ELOAD","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL001P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL001P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"CODE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"DEBIT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"DEBIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"CREDIT","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"CREDIT","bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT NUMBER","csvTxtLength":"30","pdfLength":"30","fieldType":"String","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"DESCRIPTION","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"5008","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"18","pdfLength":"18","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"GL ACCOUNT NAME","csvTxtLength":"30","pdfLength":"30","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":14,"sectionName":"14","fieldName":"DEBIT","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"CREDIT","csvTxtLength":"14","pdfLength":"14","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"FROM ACCOUNT NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"DESCRIPTION","csvTxtLength":"36","pdfLength":"36","fieldType":"String","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"67","pdfLength":"67","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Line1","csvTxtLength":"29","pdfLength":"29","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"30","pdfLength":"30","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"38","pdfLength":"38","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"14","pdfLength":"14","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_BODY_QUERY := TO_CLOB('		
SELECT
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      CASE WHEN GLA.GLA_NAME IN (''ACD Eload SVC Charge Bridge'', ''Accts. Payable - Bancnet Eload Tfee'') THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) ELSE TXN.TRL_AMT_TXN END AS "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
	  AND GLA.GLA_INSTITUTION = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Eload'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TLC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {GL_Description}
      AND {Txn_Date}
GROUP BY
      GLA.GLA_NUMBER,
      GLA.GLA_NAME,
      TXN.TRL_DEST_STAN,
      TXN.TRL_AMT_TXN,
      TXN.TRL_ISS_CHARGE_AMT,
      TXN.TRL_ACCOUNT_1_ACN_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION
ORDER BY
      TXN.TRL_DEST_STAN ASC,
      GLE.GLE_DEBIT_DESCRIPTION DESC
START SELECT
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      CASE WHEN GLA.GLA_NAME IN (''ACD Eload SVC Charge Bridge'', ''Accts. Payable - Bancnet Eload Tfee'') THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) ELSE TXN.TRL_AMT_TXN END AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
	  AND GLA.GLA_INSTITUTION = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Eload'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TLC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {GL_Description}
      AND {Txn_Date}
GROUP BY
      GLA.GLA_NUMBER,
      GLA.GLA_NAME,
      TXN.TRL_DEST_STAN,
      TXN.TRL_AMT_TXN,
      TXN.TRL_ISS_CHARGE_AMT,
      TXN.TRL_ACCOUNT_1_ACN_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION
ORDER BY
      TXN.TRL_DEST_STAN ASC,
      GLE.GLE_CREDIT_DESCRIPTION DESC
END
	');
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      SUM("TOTAL DEBIT") "TOTAL DEBIT",
      "TOTAL CREDIT"
FROM(
SELECT
      CASE WHEN GLA.GLA_NAME IN (''ACD Eload SVC Charge Bridge'', ''Accts. Payable - Bancnet Eload Tfee'') THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) ELSE TXN.TRL_AMT_TXN END AS "TOTAL DEBIT",
      0 AS "TOTAL CREDIT"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
	  AND GLA.GLA_INSTITUTION = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Eload'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TLC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {GL_Description}
      AND {Txn_Date}
)
GROUP BY
      "TOTAL CREDIT"
START SELECT
      "TOTAL DEBIT",
      SUM("TOTAL CREDIT") "TOTAL CREDIT"
FROM(
SELECT
      0 AS "TOTAL DEBIT",
      CASE WHEN GLA.GLA_NAME IN (''ACD Eload SVC Charge Bridge'', ''Accts. Payable - Bancnet Eload Tfee'') THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) ELSE TXN.TRL_AMT_TXN END AS "TOTAL CREDIT"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
	  AND GLA.GLA_INSTITUTION = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Eload'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TLC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {GL_Description}
      AND {Txn_Date}
)
GROUP BY
      "TOTAL DEBIT"
END
	');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Block Sheet Listing For E-load';
	
END;
/