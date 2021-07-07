-- Tracking					Date			Name	Description
-- Report Revise			04-JUL-2021		KW		Revise report based on specification

DECLARE
	i_BODY_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_FIELD CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 	  
  i_BODY_QUERY := TO_CLOB('
 	SELECT
	  "BILLER NAME",
	  COUNT("TOTAL TRANS") "TOTAL TRANS",
	  SUM("TOTAL AMOUNT") "TOTAL AMOUNT"
    FROM (
	  SELECT
        CBL.CBL_NAME "BILLER NAME",
      	TXN.TRL_ID "TOTAL TRANS",
      	TXN.TRL_AMT_TXN "TOTAL AMOUNT"
	  FROM
      	TRANSACTION_LOG TXN
      	JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      	JOIN CBC_BILLER CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
	  WHERE
      	TXN.TRL_TSC_CODE = 50
      	AND TXN.TRL_TQU_ID = ''F''
      	AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      	AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
        AND {Iss_Name}
      	AND {Txn_Date}
	)
    GROUP BY
      "BILLER NAME"
    ORDER BY
      "BILLER NAME" ASC	
  '); 

  i_BODY_FIELD := TO_CLOB('
	[{"sequence":1,"sectionName":"1","fieldName":"PAYMENT RECEIVED FOR","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","defaultValue":"PAYMENT RECEIVED FOR","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL TRANS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"TOTAL TRANS COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"TOTAL AMOUNT PER UTILITY","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"COUNT","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"PER UTILITY","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"","csvTxtLength":"110","pdfLength":"110","fieldType":"String","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"9","fieldName":"BILLER NAME","csvTxtLength":"36","pdfLength":"36","fieldType":"String","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"11","fieldName":"TOTAL TRANS","csvTxtLength":"29","pdfLength":"29","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"12","fieldName":"TOTAL AMOUNT","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
  ');
  
  i_TRAILER_QUERY := TO_CLOB('
	SELECT
	  COUNT(TXN.TRL_ID) "TOTAL TRANS",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
	FROM
      TRANSACTION_LOG TXN
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''	  
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Iss_Name}
      AND {Txn_Date}
  '); 
  
  i_TRAILER_FIELD := TO_CLOB('
    [{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"46","pdfLength":"46","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Line1","csvTxtLength":"19","pdfLength":"19","fieldType":"String","delimiter":";","defaultValue":"_","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Line2","csvTxtLength":"19","pdfLength":"19","fieldType":"String","delimiter":";","defaultValue":"_","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","defaultValue":"TOTAL","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Space3","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL TRANS","csvTxtLength":"30","pdfLength":"30","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL AMOUNT","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
  ');  
	  
UPDATE REPORT_DEFINITION SET RED_FILE_FORMAT='CSV,', RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY=i_BODY_QUERY, RED_TRAILER_FIELDS=i_TRAILER_FIELD, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'Daily Payment Transaction Report TellerCard Summary  by Utility Company';
	  
END;
/