-- Tracking					Date			Name	Description
-- Report Revise			04-JUL-2021		KW		Revise report based on specification
-- 							14-JUL-2021		KW		Solve duplicate due to multiple biller with same code

DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_FIELD CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 	  
  i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"DAILY PAYMENT TRANSACTION REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"48","pdfLength":"48","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"TELLERCARD SUMMARY BY UTILITY COMPANY","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EFC004-02","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","defaultValue":"EFC004-02","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');

  i_BODY_QUERY := TO_CLOB('
 	SELECT
	  "BILLER NAME",
      COUNT(CASE WHEN ISCASH=1 THEN NULL ELSE "TRANS" END) "TOTAL TRANS ATM",
      SUM(CASE WHEN ISCASH=1 THEN 0 ELSE "AMOUNT" END) "TOTAL AMOUNT ATM",
      COUNT(CASE WHEN ISCASH=1 THEN "TRANS" ELSE NULL END) "TOTAL TRANS CASH",
      SUM(CASE WHEN ISCASH=1 THEN "AMOUNT" ELSE 0 END) "TOTAL AMOUNT ATM",
	  COUNT("TRANS") "TOTAL TRANS",
	  SUM("AMOUNT") "TOTAL AMOUNT"
    FROM (
	  SELECT
        CBL.CBL_NAME "BILLER NAME",
      	TXN.TRL_ID "TRANS",
      	TXN.TRL_AMT_TXN "AMOUNT",
        CASE WHEN TXNC.TRL_CARD_PRODUCT_TYPE = ''81'' THEN 1 WHEN TXNC.TRL_CARD_PRODUCT_TYPE = ''83'' THEN 1 ELSE 0 END "ISCASH"
	  FROM
      	TRANSACTION_LOG TXN
      	JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      	LEFT JOIN (select CBL_CODE, CBL_NAME, ROW_NUMBER() OVER (partition by CBL_CODE order by cbl_id) "ROWCNT" from CBC_BILLER) CBL ON CBL.ROWCNT=1 
          AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
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
	[{"sequence":1,"sectionName":"1","fieldName":"PAYMENT RECEIVED FOR","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","defaultValue":"PAYMENT RECEIVED FOR","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"13","fieldName":"TOTAL COUNT ATM","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL COUNT (ATM CARD)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"15","fieldName":"TOTAL AMOUNT ATM","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL AMOUNT (ATM CARD)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"14","fieldName":"TOTAL COUNT CASH","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL COUNT (CASH CARD)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"16","fieldName":"TOTAL AMOUNT CASH","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL AMOUNT (CASH CARD)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"2","fieldName":"TOTAL COUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"TOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"3","fieldName":"TOTAL AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"TOTAL AMOUNT ","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"9","fieldName":"BILLER NAME","csvTxtLength":"36","pdfLength":"36","fieldType":"String","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"17","fieldName":"TOTAL TRANS ATM","csvTxtLength":"29","pdfLength":"29","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"18","fieldName":"TOTAL AMOUNT ATM","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"19","fieldName":"TOTAL TRANS CASH","csvTxtLength":"29","pdfLength":"29","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"20","fieldName":"TOTAL TRANS CASH","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"11","fieldName":"TOTAL TRANS","csvTxtLength":"29","pdfLength":"29","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"12","fieldName":"TOTAL AMOUNT","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
  ');
  
  i_TRAILER_QUERY := TO_CLOB('
	SELECT
	  COUNT(CASE WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''81'' THEN NULL WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''83'' THEN NULL ELSE 1 END) "TOTAL TRANS ATM",
      SUM(CASE WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''81'' THEN 0 WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''83'' THEN 0 ELSE TXN.TRL_AMT_TXN END) "TOTAL AMOUNT ATM",
      COUNT(CASE WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''81'' THEN 1 WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''83'' THEN 1 ELSE NULL END) "TOTAL TRANS CASH",
      SUM(CASE WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''81'' THEN TXN.TRL_AMT_TXN WHEN TXNC.TRL_CARD_PRODUCT_TYPE=''83'' THEN TXN.TRL_AMT_TXN ELSE 0 END) "TOTAL AMOUNT CASH",
	  COUNT(TXN.TRL_ID) "TOTAL TRANS",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''	  
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Iss_Name}
      AND {Txn_Date}
  '); 
  
  i_TRAILER_FIELD := TO_CLOB('
    [{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"46","pdfLength":"46","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Line1","csvTxtLength":"19","pdfLength":"19","fieldType":"String","delimiter":";","defaultValue":"_","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Line2","csvTxtLength":"19","pdfLength":"19","fieldType":"String","delimiter":";","defaultValue":"_","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","defaultValue":"TOTAL","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Space3","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"9","fieldName":"TOTAL TRANS ATM","csvTxtLength":"30","pdfLength":"30","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"10","fieldName":"TOTAL AMOUNT ATM","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"11","fieldName":"TOTAL TRANS CASH","csvTxtLength":"30","pdfLength":"30","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"12","fieldName":"TOTAL ATM CASH","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"7","fieldName":"TOTAL TRANS","csvTxtLength":"30","pdfLength":"30","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"8","fieldName":"TOTAL AMOUNT","csvTxtLength":"30","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
  ');  
	  
UPDATE REPORT_DEFINITION SET RED_HEADER_FIELDS = i_HEADER_FIELD, RED_FILE_FORMAT='CSV,', RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY=i_BODY_QUERY, RED_TRAILER_FIELDS=i_TRAILER_FIELD, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'Daily Payment Transaction Report TellerCard Summary  by Utility Company';
	  
END;
/