-- Tracking				Date			Name	Description
-- Rel-20210730			30-JUL-2021		KW		Revise

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'BIR-EFPS Transactions and Expense';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- BIR-EFPS Transactions and Expense

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"REPORT ID:","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BIR - EFPS TRANSACTIONS AND EXPENSE","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","pdfLength":"","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"COUNT","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"COUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"TOTAL EXPENSE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"TOTAL EXPENSE","firstField":false,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL COUNT","csvTxtLength":"10","pdfLength":"","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL EXPENSE","csvTxtLength":"10","pdfLength":"","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"OVER-ALL TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":4,"sectionName":"4","fieldName":"TOTAL EXPENSE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');

-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING SAVINGS","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"REPORT ID:","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BIR - EFPS TRANSACTIONS AND EXPENSE","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","pdfLength":"","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"COUNT","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"COUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"TOTAL EXPENSE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","defaultValue":"TOTAL EXPENSE","firstField":false,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL COUNT","csvTxtLength":"10","pdfLength":"","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL EXPENSE","csvTxtLength":"10","pdfLength":"","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","defaultValue":"OVER-ALL TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":4,"sectionName":"4","fieldName":"TOTAL EXPENSE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
     BRC.BRC_CODE "BRANCH CODE",
     BRC.BRC_NAME "BRANCH NAME",
     COUNT(TXN.TRL_ID) "TOTAL COUNT",
     COUNT(TXN.TRL_ID) * 7.00 "TOTAL EXPENSE"
	FROM
     TRANSACTION_LOG TXN
     JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
     JOIN BRANCH BRC ON BRC.BRC_CODE = TXNC.TRL_CARD_BRANCH
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = ''019''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	GROUP BY
      BRC.BRC_CODE,
      BRC.BRC_NAME
	ORDER BY
      BRC.BRC_CODE ASC
	');
	
i_TRAILER_QUERY := TO_CLOB('
	SELECT
      COUNT(TXN.TRL_ID) "TOTAL COUNT",
      COUNT(TXN.TRL_ID) * 7.00 "TOTAL EXPENSE"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = ''019''
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