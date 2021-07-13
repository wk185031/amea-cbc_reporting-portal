-- Tracking					    Date			Name	Description
-- Eload Reports Specification	02-JUL-2021		GS		Modify and restructure the logic of Eload Reports
-- CBCAXUPISSLOG-527 			05-JUL-2021		GS		Modify Trace No pad length to 6 digits

-- SHOULD NOT USED THIS ANYMORE! USE INDIVIDUAL SCRIPT.

DECLARE

	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 
	  
-- Approved Eload Acquirer Transactions
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACQUIRING BANK","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"ACQUIRING BANK","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRACE","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TRACE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"BRANCH","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"TRANSMITTING","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRANSMITTING","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TRANS","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"TRANS","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"RECEIVING","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"RECEIVING","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"fieldFormat":"","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"BRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"BRAN","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TERM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TERM","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"SEQ NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" SEQ NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CARD NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" CARD NO","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"4","pdfLength":"4","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"32","fieldName":"ISSUER BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"35","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"ISSUER BANK","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"ISSUER BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"Space10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"AMOUNT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"NAME","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"Space11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":44,"sectionName":"44","fieldName":"Space12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"BANK NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":47,"sectionName":"47","fieldName":"TRAN COUNT","csvTxtLength":"25","pdfLength":"25","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":48,"sectionName":"48","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');

	i_BODY_QUERY := TO_CLOB('
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "ISSUER BRANCH CODE",
      ABR.ABR_CODE "BRANCH CODE",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      ''CBC'' AS "ACQUIRER BANK MNEM",
      CBA.CBA_CODE AS "BANK CODE",
      CBA.CBA_NAME AS "BANK NAME",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Bank_Code}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      CBA.CBA_CODE AS "BANK CODE",
      CBA.CBA_NAME AS "BANK NAME",
      COUNT(TXN.TRL_ID) "TRAN COUNT",
      SUM(TXN.TRL_AMT_TXN) "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Txn_Date}
GROUP BY
      CBA.CBA_CODE,
      CBA.CBA_NAME
ORDER BY
      CBA.CBA_CODE ASC
END
	');

	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Bank_Code}
      AND {Txn_Date}
START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Txn_Date}
END
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Approved Eload Acquirer Transactions';


-- Approved Eload Issuer Transactions
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACQUIRING BANK","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"ACQUIRING BANK","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRACE","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TRACE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"BRANCH","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"TRANSMITTING","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRANSMITTING","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TRANS","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"TRANS","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"RECEIVING","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"RECEIVING","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"fieldFormat":"","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"BRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"BRAN","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TERM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TERM","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"SEQ NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" SEQ NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CARD NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" CARD NO","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"4","pdfLength":"4","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"32","fieldName":"ISSUER BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"35","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"ACQUIRER BANK","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"ACQUIRER BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"Space10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"AMOUNT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"NAME","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"Space11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":44,"sectionName":"44","fieldName":"Space12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"BANK NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":47,"sectionName":"47","fieldName":"TRAN COUNT","csvTxtLength":"25","pdfLength":"25","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":48,"sectionName":"48","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');

	i_BODY_QUERY := TO_CLOB('
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "ISSUER BRANCH CODE",
      ABR.ABR_CODE "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM "ACQUIRER BANK MNEM",
      LPAD(CBA.CBA_CODE, 4, ''0'') "BANK CODE",
      CBA.CBA_NAME "BANK NAME",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TLC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_FRD_REV_INST_ID = 8882
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Bank_Code}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      "BANK CODE",
      "BANK NAME",
      COUNT("TRAN COUNT") "TRAN COUNT",
      SUM("AMOUNT") "AMOUNT"
FROM(
SELECT
      LPAD(CBA.CBA_CODE, 4, ''0'') "BANK CODE",
      CBA.CBA_NAME "BANK NAME",
      TXN.TRL_ID "TRAN COUNT",
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TLC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_FRD_REV_INST_ID = 8882
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Txn_Date}
)
GROUP BY
      "BANK CODE",
      "BANK NAME"
ORDER BY
      "BANK CODE" ASC
END
	');

	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TLC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_FRD_REV_INST_ID = 8882
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Bank_Code}
      AND {Txn_Date}
START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TLC ON TXN.TRL_ID = TLC.TRL_ID
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TLC.TRL_ORIGIN_CHANNEL = ''BNT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_FRD_REV_INST_ID = 8882
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Txn_Date}
END
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Approved Eload Issuer Transactions';
	

-- Approved Eload On-Us Transactions
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TRACE","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TRACE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"BRANCH","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TRANSMITTING","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRANSMITTING","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TRANS","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"TRANS","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"RECEIVING","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"RECEIVING","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"DATE","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"SEQ NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":"SEQ NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":"NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"CARD NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"CARD NO","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":23,"sectionName":"23","fieldName":"ISSUER BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":25,"sectionName":"25","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":26,"sectionName":"26","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":28,"sectionName":"28","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"BRANCH","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"TERM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"TERM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"BRANCH","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":31,"sectionName":"31","fieldName":"CODE","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"CODE","bodyHeader":true,"eol":false,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NO","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"NAME","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"VOL","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"AMOUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"defaultValue":"AMOUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"BRANCH NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"TRAN COUNT","csvTxtLength":"25","pdfLength":"25","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');

	i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "ISSUER BRANCH CODE",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      COUNT(TXN.TRL_ID) "TRAN COUNT",
      SUM(TXN.TRL_AMT_TXN) "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
GROUP BY
      ABR.ABR_CODE,
      ABR.ABR_NAME,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC
END
	');
	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Txn_Date}
END
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Approved Eload On-Us Transactions';
	
END;
/