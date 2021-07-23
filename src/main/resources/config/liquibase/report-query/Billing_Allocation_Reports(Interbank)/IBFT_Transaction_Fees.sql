-- Tracking				Date			Name	Description
-- Report revision		23-JUL-2021		NY		Initial

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- IBFT Transaction Fees
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Report ID","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"REPORT ID:","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Daily Billing Allocation","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"Frequency","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"Title","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"INTERBANK FUND TRANSFER TRANSACTIONS AND TOTAL BILLING (ALL CHANNELS)","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","firstField":false,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Date","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","pdfLength":"","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"EXPENSE FOR TRANSMITTING","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"EXPENSE FOR TRANSMITTING","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"INCOME AS TRANSMITTING","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"INCOME AS TRANSMITTING","firstField":false,"bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"INCOME AS ACQUIRER BANK","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","firstField":false,"defaultValue":"INCOME AS ACQUIRER BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"INCOME AS RECEIVING BANK","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"defaultValue":"INCOME AS RECEIVING BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"TOTAL BILLING","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL BILLING","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"RATE PER COUNT = 25.00","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"RATE PER COUNT = 25.00","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"RATE PER COUNT = 7.00","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"RATE PER COUNT = 7.00","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"17","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","fieldName":"RATE PER COUNT = 6.00","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"RATE PER COUNT = 6.00","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":19,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":20,"sectionName":"20","fieldName":"RATE PER COUNT = 7.00","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"RATE PER COUNT = 7.00","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":21,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":22,"sectionName":"22","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":23,"sectionName":"23","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":24,"sectionName":"24","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":25,"sectionName":"25","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"EXPENSE","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":27,"sectionName":"27","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":28,"sectionName":"28","fieldName":"INCOME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"INCOME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":29,"sectionName":"29","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":30,"sectionName":"30","fieldName":"INCOME","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"INCOME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":31,"sectionName":"31","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":32,"sectionName":"32","fieldName":"INCOME","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"INCOME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":33,"sectionName":"33","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":34,"sectionName":"34","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":35,"sectionName":"35","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":36,"sectionName":"36","fieldName":"TRANSMITTING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":37,"sectionName":"37","fieldName":"TRANSMITTING EXPENSE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":38,"sectionName":"38","fieldName":"TRANSMITTING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":39,"sectionName":"39","fieldName":"TRANSMITTING INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":40,"sectionName":"40","fieldName":"ACQUIRER COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":41,"sectionName":"41","fieldName":"ACQUIRER INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":42,"sectionName":"42","fieldName":"RECEIVING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":43,"sectionName":"43","fieldName":"RECEIVING INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":44,"sectionName":"44","fieldName":"TOTAL BILLING","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"OVER-ALL TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TRANSMITTING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":4,"sectionName":"4","fieldName":"TRANSMITTING EXPENSE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"TRANSMITTING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"TRANSMITTING INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"ACQUIRER COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":8,"sectionName":"8","fieldName":"ACQUIRER INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"RECEIVING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":10,"sectionName":"10","fieldName":"RECEIVING INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"TOTAL BILLING","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_BODY_QUERY := TO_CLOB('
START ISSUING
SELECT
      BRC.BRC_CODE "BRANCH CODE",
      BRC.BRC_NAME "BRANCH NAME",
      COUNT(TXN.TRL_ID) "TRANSMITTING COUNT",
      COUNT(TXN.TRL_ID) * 25.00 "TRANSMITTING EXPENSE",
      COUNT(TXN.TRL_ID) * 7.00 "TRANSMITTING INCOME",
      0 "ACQUIRER COUNT",
      0 "ACQUIRER INCOME",
      0 "RECEIVING COUNT",
      0 "RECEIVING INCOME"
FROM
      TRANSACTION_LOG TXN
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
      AND {Branch_Code}
      AND {Txn_Date}
GROUP BY
      BRC.BRC_CODE,
      BRC.BRC_NAME
END ISSUING
START ACQUIRING
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      0 "TRANSMITTING COUNT",
      0 "TRANSMITTING EXPENSE",
      0 "TRANSMITTING INCOME",
      COUNT(TXN.TRL_ID) "ACQUIRER COUNT",
      COUNT(TXN.TRL_ID) * 6.00 "ACQUIRER INCOME",
      0 "RECEIVING COUNT",
      0 "RECEIVING INCOME"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 44
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME IS NULL
      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000000112''
      AND {Branch_Code}
      AND {Txn_Date}
GROUP BY
      ABR.ABR_CODE,
      ABR.ABR_NAME
END ACQUIRING
START RECEIVING
SELECT
      {Receiving_Branch_Code} "BRANCH CODE",
      {Branch_Name} "BRANCH NAME",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      0 "TRANSMITTING COUNT",
      0 "TRANSMITTING EXPENSE",
      0 "TRANSMITTING INCOME",
      0 "ACQUIRER COUNT",
      0 "ACQUIRER INCOME",
      COUNT(TXN.TRL_ID) "RECEIVING COUNT",
      COUNT(TXN.TRL_ID) * 7.00 "RECEIVING INCOME"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE = 41
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000000010''
      AND {To_Account}
      AND {Txn_Date}
GROUP BY
      TXN.TRL_ACCOUNT_2_ACN_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID
END RECEIVING
	');	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'IBFT Transaction Fees';
	
END;
/