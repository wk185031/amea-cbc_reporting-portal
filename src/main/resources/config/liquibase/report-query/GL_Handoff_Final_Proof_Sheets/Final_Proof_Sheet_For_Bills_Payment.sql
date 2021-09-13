-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-742	25-JUN-2021		NY		Initial config from UAT environment
-- CBCAXUPISSLOG-645	28-JUN-2021		NY		Clean up for new introduced CBS GL Account set
-- Report Revise		06-JUL-2021		NY		Revise report based on specification
-- Rel-20210730			30-JUL-2021		KW		Cater for CBS
-- CBCAXUPISSLOG-855	10-SEP-2021		KW		Fix branch code for CBS

DECLARE
	i_REPORT_NAME VARCHAR2(200) := 'Final Proof Sheet For Bills Payment';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY_CBC CLOB;
	i_TRAILER_QUERY_CBC CLOB;
	i_BODY_QUERY_CBS CLOB;
	i_TRAILER_QUERY_CBS CLOB;
BEGIN 

	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"FINAL PROOF SHEET","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"68","pdfLength":"68","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"49","pdfLength":"49","fieldType":"String","defaultValue":"FOR BILLS_PAYMENT","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL002P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL002P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DEBITS","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"DEBITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CREDITS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"CREDITS","bodyHeader":true,"fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"5008","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"GL ACCOUNT NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DEBITS","csvTxtLength":"49","pdfLength":"49","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CREDITS","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"3","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"77","pdfLength":"77","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"FINAL PROOF SHEET","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"68","pdfLength":"68","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"49","pdfLength":"49","fieldType":"String","defaultValue":"FOR BILLS_PAYMENT","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL002P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL002P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DEBITS","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"DEBITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CREDITS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"CREDITS","bodyHeader":true,"fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"8001","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"GL ACCOUNT NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DEBITS","csvTxtLength":"49","pdfLength":"49","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CREDITS","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"3","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"77","pdfLength":"77","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	
	i_BODY_QUERY_CBC := TO_CLOB('
    SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
	FROM(
	SELECT
      GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_AMT_TXN "DEBITS",
      0 AS "CREDITS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE NOT IN (''80'',''81'',''82'',''83'')
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
	  AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND BIL.CBL_SETTLEMENT_TYPE = ''AP''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	)
	GROUP BY
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
	ORDER BY
     "Tran Particular" DESC
	START SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
	FROM(
	SELECT
      GLE.GLE_CREDIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      0 AS "DEBITS",
      TXN.TRL_AMT_TXN "CREDITS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE NOT IN (''80'',''81'',''82'',''83'')
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND BIL.CBL_SETTLEMENT_TYPE = ''AP''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	)
	GROUP BY
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
	ORDER BY
     "Tran Particular" DESC
	END		
	');	
	
i_TRAILER_QUERY_CBC := TO_CLOB('
   SELECT
      SUM(TXN.TRL_AMT_TXN) "TOTAL DEBIT",
      0 AS "TOTAL CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	  JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE NOT IN (''80'',''81'',''82'',''83'')
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND BIL.CBL_SETTLEMENT_TYPE = ''AP''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLE.GLE_DEBIT_DESCRIPTION
	ORDER BY
      GLE.GLE_DEBIT_DESCRIPTION DESC
	START SELECT
      0 AS "TOTAL DEBIT",
     SUM(TXN.TRL_AMT_TXN) "TOTAL CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	  JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND BIL.CBL_SETTLEMENT_TYPE = ''AP''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLE.GLE_CREDIT_DESCRIPTION
	ORDER BY
      GLE.GLE_CREDIT_DESCRIPTION DESC
	END		
	');
	
UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY_CBC,
		RED_TRAILER_QUERY = i_TRAILER_QUERY_CBC
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;

-- CBS
	i_BODY_QUERY_CBS := TO_CLOB('
    SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
	FROM(
	SELECT
      GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_AMT_TXN "DEBITS",
      0 AS "CREDITS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE NOT IN (''80'',''81'',''82'',''83'')
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
	  AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	)
	GROUP BY
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
	ORDER BY
     "Tran Particular" DESC
	START SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
	FROM(
	SELECT
      GLE.GLE_CREDIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      0 AS "DEBITS",
      TXN.TRL_AMT_TXN "CREDITS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE NOT IN (''80'',''81'',''82'',''83'')
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	)
	GROUP BY
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
	ORDER BY
     "Tran Particular" DESC
	END		
	');	
	
i_TRAILER_QUERY_CBS := TO_CLOB('
   SELECT
      SUM(TXN.TRL_AMT_TXN) "TOTAL DEBIT",
      0 AS "TOTAL CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	  JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_CARD_PRODUCT_TYPE NOT IN (''80'',''81'',''82'',''83'')
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLE.GLE_DEBIT_DESCRIPTION
	ORDER BY
      GLE.GLE_DEBIT_DESCRIPTION DESC
	START SELECT
      0 AS "TOTAL DEBIT",
     SUM(TXN.TRL_AMT_TXN) "TOTAL CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	  JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) BIL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(BIL.CBL_CODE, 3, ''0'')
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND (TRL_ISS_NAME={V_Iss_Name} and (NVL(TRL_DEO_NAME, '''') != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id}))
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLE.GLE_CREDIT_DESCRIPTION
	ORDER BY
      GLE.GLE_CREDIT_DESCRIPTION DESC
	END		
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY_CBS,
		RED_TRAILER_QUERY = i_TRAILER_QUERY_CBS
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/