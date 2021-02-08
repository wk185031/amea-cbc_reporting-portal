DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- Inter-Entity IBFT Transaction Fees
i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"17","csvTxtLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"18","csvTxtLength":"","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"19","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"5","fieldName":"Report ID","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"REPORT ID:","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"6","fieldName":"Daily Billing Allocation","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"7","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"8","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"9","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"21","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"22","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"23","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"24","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"10","fieldName":"Frequency","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"11","fieldName":"Title","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"INTERBANK FUND TRANSFER TRANSACTIONS AND TOTAL BILLING (ALL CHANNELS)","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"12","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","firstField":false,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"13","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"14","fieldName":"","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"26","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"27","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":26,"sectionName":"15","fieldName":"Date","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":27,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","pdfLength":"","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"EXPENSE FOR TRANSMITTING","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"EXPENSE FOR TRANSMITTING","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"INCOME AS ACQUIRER BANK","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","firstField":false,"defaultValue":"INCOME AS ACQUIRER BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"INCOME AS RECEIVING BANK","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"defaultValue":"INCOME AS RECEIVING BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"TOTAL BILLING","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL BILLING","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"RATE PER COUNT = 5.00","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"RATE PER COUNT = 5.00","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"RATE PER COUNT = 5.00","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"RATE PER COUNT = 5.00","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"RATE PER COUNT = 5.00","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"RATE PER COUNT = 5.00","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"17","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":19,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":20,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":21,"sectionName":"21","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":22,"sectionName":"22","fieldName":"EXPENSE","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":23,"sectionName":"23","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":24,"sectionName":"24","fieldName":"INCOME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"INCOME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":25,"sectionName":"25","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"INCOME","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"INCOME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":27,"sectionName":"27","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":28,"sectionName":"28","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":29,"sectionName":"29","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":30,"sectionName":"30","fieldName":"TRANSMITTING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":31,"sectionName":"31","fieldName":"TRANSMITTING EXPENSE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":32,"sectionName":"32","fieldName":"ACQUIRER COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":33,"sectionName":"33","fieldName":"ACQUIRER INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":34,"sectionName":"34","fieldName":"RECEIVING COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":35,"sectionName":"35","fieldName":"RECEIVING INCOME","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":36,"sectionName":"36","fieldName":"TOTAL BILLING","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true}]');

i_BODY_QUERY := TO_CLOB('
	SELECT
  "BRANCH CODE",
  "BRANCH NAME",
  "TRANSMITTING COUNT",
  "TRANSMITTING EXPENSE",
  "ACQUIRER COUNT",
  "ACQUIRER INCOME",
  "RECEIVING COUNT",
  "RECEIVING INCOME",
  "TRANSMITTING EXPENSE" + "ACQUIRER INCOME" + "RECEIVING INCOME" AS "TOTAL BILLING"
FROM (
SELECT
  BRC.BRC_CODE "BRANCH CODE",
  BRC.BRC_NAME "BRANCH NAME",
  COUNT(TXN.TRL_ID) "TRANSMITTING COUNT",
  COUNT(TXN.TRL_ID) * 5.00 "TRANSMITTING EXPENSE",
  0 "ACQUIRER COUNT",
  0 "ACQUIRER INCOME",
  0 "RECEIVING COUNT",
  0 "RECEIVING INCOME"      		
FROM
  BRANCH BRC
  LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON BRC.BRC_CODE = TXNC.TRL_CARD_BRANCH
  LEFT JOIN TRANSACTION_LOG TXN ON TXNC.TRL_ID = TXN.TRL_ID 
  AND TXN.TRL_TSC_CODE IN (42,48,49)
  AND TXN.TRL_TQU_ID = ''F''
  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
  AND ((TXN.TRL_ISS_NAME = ''CBC'' AND TXN.TRL_FRD_REV_INST_ID = ''0112'') 
    OR TXN.TRL_ISS_NAME=''CBC'' AND TRL_DEO_NAME = ''CBS'' AND TRL_FRD_REV_INST_ID=''0010'')
  AND {Txn_Date}
GROUP BY
  BRC.BRC_CODE,
  BRC.BRC_NAME
UNION  
SELECT
  BRC.BRC_CODE "BRANCH CODE",
  BRC.BRC_NAME "BRANCH NAME",
  0 "TRANSMITTING COUNT",
  0 "TRANSMITTING EXPENSE",
  COUNT(TXN.TRL_ID) "ACQUIRER COUNT",
  COUNT(TXN.TRL_ID) * 5.00 "ACQUIRER INCOME",
  0 "RECEIVING COUNT",
  0 "RECEIVING INCOME"      		
FROM
  BRANCH BRC
  LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON BRC.BRC_CODE = TXNC.TRL_CARD_BRANCH
  LEFT JOIN TRANSACTION_LOG TXN ON TXNC.TRL_ID = TXN.TRL_ID 
  AND TXN.TRL_TSC_CODE IN (42,48,49)
  AND TXN.TRL_TQU_ID = ''F''
  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
  AND TXN.TRL_ACQR_INST_ID = ''10''
  AND TXN.TRL_ISS_NAME = ''CBS''
  AND TXN.TRL_FRD_REV_INST_ID=''0112''
  AND {Txn_Date}
GROUP BY
  BRC.BRC_CODE,
  BRC.BRC_NAME
UNION  
SELECT
  BRC.BRC_CODE "BRANCH CODE",
  BRC.BRC_NAME "BRANCH NAME",
  0 "TRANSMITTING COUNT",
  0 "TRANSMITTING EXPENSE",
  0 "ACQUIRER COUNT",
  0 "ACQUIRER INCOME",
  COUNT(TXN.TRL_ID) "RECEIVING COUNT",
  COUNT(TXN.TRL_ID) * 5.00 "RECEIVING INCOME"      		
FROM
  BRANCH BRC
  LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON BRC.BRC_CODE = TXNC.TRL_CARD_BRANCH
  LEFT JOIN TRANSACTION_LOG TXN ON TXNC.TRL_ID = TXN.TRL_ID 
  AND TXN.TRL_TSC_CODE IN (42,48,49)
  AND TXN.TRL_TQU_ID = ''F''
  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
  AND TXN.TRL_FRD_REV_INST_ID=''0010''
  AND {Txn_Date}
GROUP BY
  BRC.BRC_CODE,
  BRC.BRC_NAME 
)  
ORDER BY "BRANCH CODE"
	');
	
	update REPORT_DEFINITION set RED_PROCESSING_CLASS='my.com.mandrill.base.cbc.processor.SimpleReportProcessor', RED_BODY_QUERY = i_BODY_QUERY, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_BODY_FIELDS = i_BODY_FIELD where RED_NAME = 'Inter-Entity IBFT Transaction Fees';
	
END;
/