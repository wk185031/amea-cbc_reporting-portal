-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- JIRA 790				14-JUL-2021		WY		Fix report to display transmitting bank as CBC or CBS accounts
-- Report revision		26-JUL-2021		NY		Revised reports based on spec

DECLARE
    i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Approved IBFT Transactions as Transmitting Bank
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACQUIRING BANK","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"ACQUIRING BANK","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRACE","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TRACE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"BRANCH","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"TRANSMITTING","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRANSMITTING","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TRANS","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"TRANS","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"RECEIVING","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"RECEIVING","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"fieldFormat":"","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"BRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"BRAN","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TERM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TERM","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"SEQ NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" SEQ NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CARD NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" CARD NO","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"4","pdfLength":"4","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"32","fieldName":"ISSUER BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"35","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"Space6","csvTxtLength":"30","pdfLength":"30","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"Space7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"Space8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"Space9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"IBFT TRANSACTION FEE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"IBFT TRANSACTION FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"RECEIVING BANK","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"RECEIVING BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"Space10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":44,"sectionName":"44","fieldName":"COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"ISSUER EXPENSE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ISSUER EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":47,"sectionName":"47","fieldName":"ISSUER INCOME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ISSUER INCOME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":48,"sectionName":"48","fieldName":"CORP. INCOME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"CORP. INCOME","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":49,"sectionName":"49","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":50,"sectionName":"50","fieldName":"NAME","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":51,"sectionName":"51","fieldName":"Space11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":52,"sectionName":"52","fieldName":"Space12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":53,"sectionName":"53","fieldName":"(P25.00)","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"(P25.00)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":54,"sectionName":"54","fieldName":"(P7.00)","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"(P7.00)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":55,"sectionName":"55","fieldName":"(P125.00)","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"(P125.00)","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":56,"sectionName":"56","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":57,"sectionName":"57","fieldName":"BANK NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":58,"sectionName":"58","fieldName":"TRAN COUNT","csvTxtLength":"25","pdfLength":"25","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":59,"sectionName":"59","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":60,"sectionName":"60","fieldName":"ISSUER EXPENSE","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":61,"sectionName":"61","fieldName":"ISSUER INCOME","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":62,"sectionName":"62","fieldName":"CORP. INCOME","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
	      BRC.BRC_CODE "ISSUER BRANCH CODE",
	      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
	      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
	      TXN.TRL_DEST_STAN "SEQ NUMBER",
	      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
	      TXN.TRL_PAN "ATM CARD NUMBER",
	      TXN.TRL_PAN_EKY_ID,
	      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
	      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
	      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
	      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
	      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
	      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
	      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
	      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
	      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
	      TXN.TRL_AMT_TXN "AMOUNT"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
	      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	      JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'')
          AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
          AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882''
	      AND {IBFT_Criteria}
	      AND {Bank_Code}
	      AND {Txn_Date}
	ORDER BY
	      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
	      TXN.TRL_SYSTEM_TIMESTAMP ASC,
	      TXN.TRL_DEST_STAN ASC
	START SELECT
	      {Corporate_Income},
	      "BANK CODE",
	      "BANK NAME",
	      COUNT("TRAN COUNT") "TRAN COUNT",
	      SUM("AMOUNT") "AMOUNT",
	      125.00 * COUNT("TRAN COUNT") AS "CORP. INCOME",
	      25.00 * COUNT("TRAN COUNT") AS "ISSUER EXPENSE",
	      7.00 * COUNT("TRAN COUNT") AS "ISSUER INCOME"
	FROM(
	SELECT
	      {Corporate_Count},
	      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
	      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
	      TXN.TRL_ID "TRAN COUNT",
	      TXN.TRL_AMT_TXN "AMOUNT"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'')
          AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
          AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882''
	      AND {IBFT_Criteria}
	      AND {Txn_Date}
	)
	GROUP BY
	      "BANK CODE",
	      "BANK NAME"
	ORDER BY
	      "BANK CODE" ASC
	END');
	
	
	i_TRAILER_QUERY := TO_CLOB('
	
	SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
	FROM
	      TRANSACTION_LOG TXN
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'')
	      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
	      AND {IBFT_Criteria}
	      AND {Bank_Code}
	      AND {Txn_Date}
	START SELECT
	      {Corporate_Income},
	      COUNT(TXN.TRL_ID) "TOTAL TRAN",
	      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT",
	      SUM(125.00 * COUNT(TXN.TRL_ID)) AS "CORP. INCOME",
	      SUM(25.00 * COUNT(TXN.TRL_ID)) AS "ISSUER EXPENSE",
	      SUM(7.00 * COUNT(TXN.TRL_ID)) AS "ISSUER INCOME"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'')
          AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
          AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882''
	      AND {IBFT_Criteria}
	      AND {Txn_Date}
	GROUP BY
	      TXN.TRL_AMT_TXN,
	      TXN.TRL_ID
	END');
	
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'Approved IBFT Transactions as Transmitting Bank';
	
END;
/