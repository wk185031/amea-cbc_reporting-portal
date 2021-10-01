-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-742	25-JUN-2021		NY		Initial config from UAT environment
-- CBCAXUPISSLOG-645	28-JUN-2021		NY		Clean up for new introduced CBS GL Account set
-- Rel-20210805			05-Aug-2021		KW		Revise report based on specification
-- CBCAXUPISSLOG-947	28/Sep/2021		KW		Include other transactions

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Final Proof Sheet For Cash Card';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_BODY_QUERY_1 CLOB;
	i_BODY_QUERY_2 CLOB;
	i_TRAILER_QUERY CLOB;
	i_PROCESSING_CLASS VARCHAR2(200) := 'my.com.mandrill.base.reporting.glHandoffFinalProofSheet.DefaultHandoffFinalProofSheet';
BEGIN 
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"FINAL PROOF SHEET","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"70","pdfLength":"70","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"47","pdfLength":"47","fieldType":"String","defaultValue":"FOR CASH_CARD","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL002P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL002P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DEBITS","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"DEBITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CREDITS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"CREDITS","bodyHeader":true,"fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"GL ACCOUNT NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DEBIT","csvTxtLength":"39","pdfLength":"39","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"3","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"72","pdfLength":"72","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"FINAL PROOF SHEET","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"70","pdfLength":"70","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"47","pdfLength":"47","fieldType":"String","defaultValue":"FOR CASH_CARD","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL002P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL002P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DEBITS","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"DEBITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CREDITS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"CREDITS","bodyHeader":true,"fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"GL ACCOUNT NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DEBIT","csvTxtLength":"39","pdfLength":"39","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"3","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"72","pdfLength":"72","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT
      "GROUP_ID",
      "BRANCH CODE",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "DEBIT CREDIT",
      SUM("DEBIT") "DEBIT",
      SUM("CREDIT") "CREDIT"
FROM (
SELECT
      ''ONUS'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''On-Us'')
	  AND AST.AST_TERMINAL_TYPE NOT IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
UNION ALL
SELECT
      ''ONUS'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''On-Us'')
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
UNION ALL
SELECT
      ''ISSUING'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE CCRD.CRD_BRANCH_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN CARD_CUSTOM CCRD ON CRD.CRD_ID = CCRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Issuer'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME  = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND (TXN.TRL_DEO_NAME != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id})
      AND {Txn_Date}
UNION ALL
SELECT
      ''ISSUING'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE CCRD.CRD_BRANCH_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN CARD_CUSTOM CCRD ON CRD.CRD_ID = CCRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Issuer'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND (TXN.TRL_DEO_NAME != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id})
      AND {Txn_Date}
UNION ALL
SELECT
      ''ISSUING-F'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE CCRD.CRD_BRANCH_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN CARD_CUSTOM CCRD ON CRD.CRD_ID = CCRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) > 0
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Issuer'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME  = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND (TXN.TRL_DEO_NAME != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id})
      AND {Txn_Date}
UNION ALL
SELECT
      ''ISSUING-F'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE CCRD.CRD_BRANCH_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN CARD_CUSTOM CCRD ON CRD.CRD_ID = CCRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) > 0
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Issuer'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND (TXN.TRL_DEO_NAME != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id})
      AND {Txn_Date}
UNION ALL 
SELECT
      ''BP'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N'' AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''ATM BILLS PAYMENT''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND BIL.CBL_SETTLEMENT_TYPE = ''AP''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {Txn_Date}
UNION ALL
SELECT
      ''BP'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N'' AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''ATM BILLS PAYMENT''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND BIL.CBL_SETTLEMENT_TYPE = ''AP''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {Txn_Date}
UNION ALL 
SELECT
      ''POS'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_MCC_ID = 6012
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 0
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''POS'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''POS'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_MCC_ID = 6012
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 0
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''POS'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''IBFTT'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''IBFT'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''BANCNET INTERBANK TRANSFER DR''
	  AND TXN.TRL_TSC_CODE IN (1, 44) AND (TXN.TRL_ISS_NAME = {V_Iss_Name} OR TXN.TRL_ISS_NAME IS NULL) AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''IBFTT'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''IBFT'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''BANCNET INTERBANK TRANSFER DR''
	  AND TXN.TRL_TSC_CODE IN (1, 44) AND (TXN.TRL_ISS_NAME = {V_Iss_Name} OR TXN.TRL_ISS_NAME IS NULL) AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''IBFTF'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      TXN.TRL_ISS_CHARGE_AMT "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND NVL(TXN.TRL_ISS_CHARGE_AMT, 0) > 0
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''IBFT'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''BANCNET SERVICE CHARGE''
	  AND TXN.TRL_TSC_CODE IN (1, 44) AND (TXN.TRL_ISS_NAME = {V_Iss_Name} OR TXN.TRL_ISS_NAME IS NULL) AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''IBFTF'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      TXN.TRL_ISS_CHARGE_AMT "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND NVL(TXN.TRL_ISS_CHARGE_AMT, 0) > 0
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''IBFT'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''BANCNET SERVICE CHARGE''
	  AND TXN.TRL_TSC_CODE IN (1, 44) AND (TXN.TRL_ISS_NAME = {V_Iss_Name} OR TXN.TRL_ISS_NAME IS NULL) AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''IBFTR'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''IBFT'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''BANCNET INTERBANK TRANSFER CR''
	  AND TXN.TRL_TSC_CODE = 41 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id}
      AND {Txn_Date}
UNION ALL
SELECT
      ''IBFTR'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''IBFT'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''BANCNET INTERBANK TRANSFER CR''
	  AND TXN.TRL_TSC_CODE = 41 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id}
      AND {Txn_Date}	
	');	
	
	i_BODY_QUERY_1 := TO_CLOB('
	UNION ALL 
SELECT
      ''ELOAD'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Eload'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''ELOAD'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Eload'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''IE-F'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_TSC_CODE IN (44, 48, 49) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND (TXN.TRL_DEO_NAME IN ({V_IE_Acq_Name},{V_Acq_Name}) OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN ({V_IE_Acqr_Inst_Id},{V_Acqr_Inst_Id})) AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}  
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''INTER-ENTITY IBFT CHARGE''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
UNION ALL
SELECT
      ''IE-F'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_TSC_CODE IN (44, 48, 49) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND (TXN.TRL_DEO_NAME IN ({V_IE_Acq_Name},{V_Acq_Name}) OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN ({V_IE_Acqr_Inst_Id},{V_Acqr_Inst_Id})) AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}      
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''INTER-ENTITY IBFT CHARGE''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
UNION ALL 
SELECT
      ''IET'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_TSC_CODE IN (44, 48, 49) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND (TXN.TRL_DEO_NAME IN ({V_IE_Acq_Name},{V_Acq_Name}) OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN ({V_IE_Acqr_Inst_Id},{V_Acqr_Inst_Id})) AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}  
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''INTER-ENTITY FUND TRANSFER DR''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
UNION ALL
SELECT
      ''IET'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_TSC_CODE IN (44, 48, 49) AND TXN.TRL_ISS_NAME = {V_Iss_Name} AND (TXN.TRL_DEO_NAME IN ({V_IE_Acq_Name},{V_Acq_Name}) OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN ({V_IE_Acqr_Inst_Id},{V_Acqr_Inst_Id})) AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}      
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''INTER-ENTITY FUND TRANSFER DR''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
	UNION ALL 
SELECT
      ''IEAR'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''INTER-ENTITY AR ATM WITHDRAWAL''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
UNION ALL
SELECT
      ''IEAR'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''INTER-ENTITY AR ATM WITHDRAWAL''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
UNION ALL 
SELECT
      ''IEAP'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = {V_Iss_Name}  AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''INTER-ENTITY AP ATM WITHDRAWAL''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
UNION ALL
SELECT
      ''IEAP'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = {V_Iss_Name}  AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''INTER-ENTITY AP ATM WITHDRAWAL''
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Txn_Date}
	UNION ALL 
SELECT
      ''BEEP'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Beep Loading'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''CBC BEEP LOADING''  
	  AND {Txn_Date}
UNION ALL
SELECT
      ''BEEP'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Beep Loading'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''CBC BEEP LOADING''  
	  AND {Txn_Date}
UNION ALL 
SELECT
      ''BEEP-F'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      NVL(TXN.TRL_ISS_CHARGE_AMT, 0) "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(TXN.TRL_ISS_CHARGE_AMT, 0) > 0
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Beep Loading'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TRIM(GLE.GLE_DEBIT_DESCRIPTION) = ''CBC BEEP SERVICE CHARGE''  
	  AND {Txn_Date}
UNION ALL
SELECT
      ''BEEP-F'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      NVL(TXN.TRL_ISS_CHARGE_AMT, 0) "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(TXN.TRL_ISS_CHARGE_AMT, 0) > 0
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Beep Loading'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TRIM(GLE.GLE_CREDIT_DESCRIPTION) = ''CBC BEEP SERVICE CHARGE''  
	  AND {Txn_Date}
UNION ALL 
SELECT
      ''MVC'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TSC_CODE IN (142, 143)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Moving Cash'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}  
	  AND {Txn_Date}
UNION ALL
SELECT
      ''MVC'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TXN.TRL_TSC_CODE IN (142, 143)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Moving Cash'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND {Txn_Date}
UNION ALL 
SELECT
      ''REC'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE 
         AND GLE.GLE_TRAN_CHANNEL=''CDM''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')
		 AND GLE.GLE_MAIN_DIRECTION = ''ACQUIRER''
         AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TRL_TSC_CODE in (1,128) 
      AND TXN.TRL_TQU_ID = ''F''
	  AND TRL_FRD_REV_INST_ID is null
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_DEO_NAME = {V_Deo_Name} 
	  AND NVL(TXN.TRL_ISS_NAME, '' '') != {V_IE_Iss_Name}
	  AND {Txn_Date}
UNION ALL
SELECT
      ''REC'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE 
         AND GLE.GLE_TRAN_CHANNEL=''CDM''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')
		 AND GLE.GLE_MAIN_DIRECTION = ''ACQUIRER''
         AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
	  TRL_TSC_CODE in (1,128) 
      AND TXN.TRL_TQU_ID = ''F''
	  AND TRL_FRD_REV_INST_ID is null
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND TXN.TRL_DEO_NAME = {V_Deo_Name}
	  AND NVL(TXN.TRL_ISS_NAME, '' '') != {V_IE_Iss_Name}
	  AND {Txn_Date}
	');
	
	dbms_lob.append(i_BODY_QUERY, i_BODY_QUERY_1);
	
	i_BODY_QUERY_2 := TO_CLOB('
	UNION ALL 
SELECT
      ''PESONET'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''PesoNet'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''PESONET'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''PesoNet'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''PESONET-F'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      TXN.TRL_ISS_CHARGE_AMT "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''PesoNet'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''PESONET-F'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      TXN.TRL_ISS_CHARGE_AMT "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''PesoNet'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}	  
UNION ALL 
SELECT
      ''INSTAPAY'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''InstaPay'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''INSTAPAY'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''InstaPay'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''INSTAPAY-F'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      TXN.TRL_ISS_CHARGE_AMT "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''InstaPay'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''INSTAPAY-F'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      TXN.TRL_ISS_CHARGE_AMT "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''InstaPay'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''RFID'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''RFID'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''RFID'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
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
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''N''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''RFID'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL 
SELECT
      ''RFID-F'' AS "GROUP_ID",
	  ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      TXN.TRL_ISS_CHARGE_AMT "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLA.GLA_NAME = ''Accts. Payable - Cash Card - Reg''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''RFID'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
UNION ALL
SELECT
      ''RFID-F'' AS "GROUP_ID",
	  ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      TXN.TRL_ISS_CHARGE_AMT "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE AND NVL(GLE.GLE_SVC_ENABLED, ''N'') = ''Y''
      LEFT JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''RFID'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
)
GROUP BY
      "GROUP_ID",
      "BRANCH CODE",
	  "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "DEBIT CREDIT"
ORDER BY    
      "GROUP_ID", 
	  "BRANCH CODE",
	  "DEBIT CREDIT" DESC
	');
	
	dbms_lob.append(i_BODY_QUERY, i_BODY_QUERY_2);
	
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