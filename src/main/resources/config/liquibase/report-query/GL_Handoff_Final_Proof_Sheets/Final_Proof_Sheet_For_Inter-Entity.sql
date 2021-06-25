-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-742	25-JUN-2021		NY		Initial config from UAT environment

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Final Proof Sheet For Inter-Entity
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"FINAL PROOF SHEET","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"68","pdfLength":"68","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"49","pdfLength":"49","fieldType":"String","defaultValue":"FOR INTER-ENTITY","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL002P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL002P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DEBITS","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"DEBITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CREDITS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"CREDITS","bodyHeader":true,"fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"GL ACCOUNT NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DEBITS","csvTxtLength":"49","pdfLength":"49","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CREDITS","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"3","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"77","pdfLength":"77","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_BODY_QUERY := TO_CLOB('
SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "BRANCH CODE",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
FROM(
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      CASE WHEN GLE.GLE_DEBIT_DESCRIPTION IN (''INTER-ENTITY AP ATM WITHDRAWAL'', ''INTER-ENTITY AR ATM WITHDRAWAL'', ''INTER-ENTITY FUND TRANSFER DR'', ''INTER-ENTITY FUND TRANSFER CR'') THEN TXN.TRL_AMT_TXN ELSE NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) END AS "DEBITS",
      0 AS "CREDITS"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND {Branch_Code}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TLC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND TLC.TRL_ORIGIN_CHANNEL = ''ATM''
      AND {GL_Description}
      AND {Txn_Date}
)
GROUP BY
    "BRANCH CODE",
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
ORDER BY
     "BRANCH CODE" ASC,
     "Tran Particular" DESC
START SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "BRANCH CODE",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
FROM(
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      GLE.GLE_CREDIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      0 AS "DEBITS",
      CASE WHEN GLE.GLE_CREDIT_DESCRIPTION IN (''INTER-ENTITY AP ATM WITHDRAWAL'', ''INTER-ENTITY AR ATM WITHDRAWAL'', ''INTER-ENTITY FUND TRANSFER DR'', ''INTER-ENTITY FUND TRANSFER CR'') THEN TXN.TRL_AMT_TXN ELSE NVL(TXN.TRL_ACQ_CHARGE_AMT, 0) END AS "CREDITS"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND {Branch_Code}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Inter-Entity'')
      AND GLE.GLE_ENTRY_ENABLED = ''Y''
	  AND TLC.TRL_ORIGIN_CHANNEL NOT IN (''CDM'',''BRM'')
	  AND TLC.TRL_ORIGIN_CHANNEL = ''ATM''
      AND {GL_Description}
      AND {Txn_Date}
)
GROUP BY
    "BRANCH CODE",
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
ORDER BY
     "BRANCH CODE" ASC,
     "Tran Particular" DESC
END		
	');	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Final Proof Sheet For Inter-Entity';
	
END;
/