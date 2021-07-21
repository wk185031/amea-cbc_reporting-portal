-- Tracking				Date			Name	Description
-- Report revision		16-JUL-2021		NY		Initial from UAT environment

DECLARE
    i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Issuer ATM Withdrawal Expense
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"Report ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"48","pdfLength":"48","fieldType":"String","delimiter":";","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"FileName1","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"INQUIRY TRANSACTIONS AND EXPENSE AS ISSUER (PER BRANCH AND BANK)","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"BANCNET MEMBER BANKS","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BANCNET MEMBER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"defaultValue":"TOTAL INCOME"},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":13,"sectionName":"13","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":15,"sectionName":"15","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"eol":true}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"Space2","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"OVER-ALL TOTAL","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"OVER-ALL TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":5,"sectionName":"5","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":7,"sectionName":"7","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_BODY_QUERY := TO_CLOB('
SELECT
     BRC.BRC_CODE "BRANCH CODE",
     BRC.BRC_NAME "BRANCH NAME",
     (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
     COUNT(TXN.TRL_ID) "SUBTOTAL COUNT",
     COUNT(TXN.TRL_ID) * 13.00 "SUBTOTAL EXPENSE",
     COUNT(TXN.TRL_ID) "TOTAL COUNT",
     COUNT(TXN.TRL_ID) * 13.00 "TOTAL EXPENSE",
     COUNT(TXN.TRL_ID) * 2.00 "TOTAL INCOME"
FROM
     TRANSACTION_LOG TXN
     JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
     JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ORIGIN_ICH_NAME = ''Bancnet_Interchange''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Txn_Date}
GROUP BY
      BRC.BRC_CODE,
      BRC.BRC_NAME,
      TXN.TRL_ACQR_INST_ID
ORDER BY
      "BRANCH CODE" ASC,
      "ACQUIRER BANK MNEM" ASC
	');	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "SUBTOTAL COUNT",
      COUNT(TXN.TRL_ID) * 13.00 "SUBTOTAL EXPENSE",
      COUNT(TXN.TRL_ID) "TOTAL COUNT",
      COUNT(TXN.TRL_ID) * 13.00 "TOTAL EXPENSE",
      COUNT(TXN.TRL_ID) * 2.00 "TOTAL INCOME"
FROM
      TRANSACTION_LOG TXN
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ORIGIN_ICH_NAME = ''Bancnet_Interchange''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Txn_Date}
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Issuer ATM Withdrawal Expense';
	
END;
/