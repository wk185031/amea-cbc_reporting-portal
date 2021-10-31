-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-852	29-OCT-2021		LJL		Revise POS Layout tally with POS approved report


DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'POS Transaction Fees';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	
BEGIN 

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"REPORT ID:","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"8","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"9","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"POINT OF SALE TRANSACTIONS AND INCOME (PER MERCHANT AND PER BRANCH)","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","pdfLength":"","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH NO","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NO","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL COUNT","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"TOTAL COUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":false,"bodyHeader":true,"fieldName":"Total Amount Purchased","defaultValue":"Total Amount Purchased","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"fieldName":"POS Commission Share","defaultValue":"POS Commission Share (30%)","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"16","fieldName":"BRANCH NO","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"17","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"18","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"19","fieldName":"TOTAL AMOUNT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"20","fieldName":"POS COMMISION SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"OVER-ALL TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"TOTAL AMOUNT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"POS COMMISION","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING SAVINGS","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"REPORT ID:","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"8","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"9","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"POINT OF SALE TRANSACTIONS AND INCOME (PER MERCHANT AND PER BRANCH)","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","pdfLength":"","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH NO","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NO","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL COUNT","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"TOTAL COUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":false,"bodyHeader":true,"fieldName":"Total Amount Purchased","defaultValue":"Total Amount Purchased","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"fieldName":"POS Commission Share","defaultValue":"POS Commission Share (30%)","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"16","fieldName":"BRANCH NO","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"17","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"18","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"19","fieldName":"TOTAL AMOUNT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"20","fieldName":"POS COMMISION SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"OVER-ALL TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"TOTAL AMOUNT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"POS COMMISION","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	
i_BODY_QUERY := TO_CLOB('
SELECT
     BRC.BRC_CODE "BRANCH NO",
     BRC.BRC_NAME "BRANCH NAME",
     COUNT(*) "TOTAL COUNT",
     SUM(TXN.TRL_AMT_TXN ) "TOTAL AMOUNT",
     SUM(TXN.TRL_AMT_TXN * 30 / 100) AS "POS COMMISION SHARE"
FROM
     TRANSACTION_LOG TXN
 JOIN TRANSACTION_LOG_CUSTOM TXNC on TXN.TRL_ID = TXNC.TRL_ID
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
WHERE
     TXN.TRL_MCC_ID = ''6012''
      AND TXN.TRL_TQU_ID IN (''F'',''R'')
      AND TXN.TRL_TSC_CODE = 0
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
GROUP BY
      BRC.BRC_CODE,
	  BRC.BRC_NAME
ORDER BY
     "BRANCH NO" ASC
');

i_TRAILER_QUERY := TO_CLOB('
SELECT
     COUNT(*) "TOTAL COUNT",
     SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT",
     SUM(TXN.TRL_AMT_TXN * 30/100) "POS COMMISION"
FROM
     TRANSACTION_LOG TXN
WHERE
      TXN.TRL_MCC_ID = ''6012''
      AND TXN.TRL_TQU_ID IN (''F'',''R'')
      AND TXN.TRL_TSC_CODE = 0
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
');

	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/