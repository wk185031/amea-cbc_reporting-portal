-- Tracking					Date			Name	Description
-- Report Revise			04-JULy-2021	KW		Revise report based on specification
-- 							14-JUL-2021		KW		Solve duplicate due to multiple biller with same code

DECLARE
	i_BODY_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_FIELD CLOB;
	i_TRAILER_QUERY CLOB;
	i_HEADER_FIELD CLOB;

BEGIN
  i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":" ","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":"","defaultValue":"DAILY PAYMENT TRANSACTION REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":"","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"48","pdfLength":"48","fieldType":"String","delimiter":"","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"TELLERCARD SUMMARY BY UTILITY COMPANY","delimiter":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EFC004-02","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":"","defaultValue":"EFC004-02","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":"","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":"","fieldFormat":"HH:mm:ss","eol":false,"leftJustified":true,"padFieldLength":0}]');
  
  i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"6","pdfLength":"","fieldType":"String","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"PAYMENT RECEIVED FOR","csvTxtLength":"45","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"PAYMENT RECEIVED FOR","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL TRANSACTION COUNT","csvTxtLength":"40","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"TOTAL TRANSACTION COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"AMOUNT RECEIVED","csvTxtLength":"30","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"AMOUNT RECEIVED","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","csvTxtLength":"6","pdfLength":"","fieldType":"String","fieldName":"Space","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"BILLER NAME","csvTxtLength":"45","pdfLength":"","fieldType":"String","delimiter":" ","firstField":false,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL TRANS","csvTxtLength":"15","pdfLength":"","fieldType":"Number","delimiter":" ","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL AMOUNT","csvTxtLength":"40","pdfLength":"","fieldType":"Decimal","delimiter":" ","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
   	  
  i_BODY_QUERY := TO_CLOB('
    SELECT
      COALESCE(CBL.CBL_NAME, LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'')) "BILLER NAME",
      COUNT(TXN.TRL_ID) "TOTAL TRANS",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
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
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
    GROUP BY
      TRL_BILLER_CODE, CBL.CBL_NAME
    ORDER BY
       CBL.CBL_NAME ASC
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
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
  '); 
  
  i_TRAILER_FIELD := TO_CLOB('
    [{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"28","pdfLength":"","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL:","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":"","defaultValue":"TOTAL:","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL TRANS","csvTxtLength":"28","pdfLength":"","fieldType":"Number","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":4,"sectionName":"4","fieldName":"TOTAL AMOUNT","csvTxtLength":"40","pdfLength":"","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
  ');  
	  
UPDATE REPORT_DEFINITION SET RED_HEADER_FIELDS=i_HEADER_FIELD, RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY=i_BODY_QUERY, RED_TRAILER_FIELDS=i_TRAILER_FIELD, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'Bills Payment Extract Files (Summary)';
	  
END;
/