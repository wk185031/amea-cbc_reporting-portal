-- Tracking					Date			Name	Description
-- Report Revise			04-JULy-2021	KW		Revise report based on specification
-- Rel-20210730				14-JUL-2021		KW		Solve duplicate due to multiple biller with same code

DECLARE
	i_REPORT_NAME VARCHAR2(200) := 'Bills Payment Extract Files (Summary)';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN
	
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","leftJustified":true,"padFieldLength":0,"firstField":true,"eol":true},{"sequence":2,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"BANCNET DIRECT PAYMENT SUMMARY","delimiter":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":3,"sectionName":"3","fieldName":"space","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"csvTxtLength":"10","pdfLength":"10","eol":true}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"9","fieldName":"INST CODE","csvTxtLength":"56","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"INST CODE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"PAYMENT RECEIVED FOR","csvTxtLength":"45","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"PAYMENT RECEIVED FOR","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL TRANSACTION COUNT","csvTxtLength":"40","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"TOTAL TRANSACTION COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"AMOUNT RECEIVED","csvTxtLength":"30","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"AMOUNT RECEIVED","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"10","fieldName":"INST CODE","csvTxtLength":"56","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":6,"sectionName":"6","fieldName":"BILLER NAME","csvTxtLength":"45","pdfLength":"","fieldType":"String","delimiter":" ","firstField":false,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL TRANS","csvTxtLength":"15","pdfLength":"","fieldType":"Number","delimiter":" ","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL AMOUNT","csvTxtLength":"40","pdfLength":"","fieldType":"Decimal","delimiter":" ","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"24","pdfLength":"","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL:","csvTxtLength":"64","pdfLength":"","fieldType":"String","delimiter":"","defaultValue":"TOTAL:","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL TRANS","csvTxtLength":"28","pdfLength":"","fieldType":"Number","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":4,"sectionName":"4","fieldName":"TOTAL AMOUNT","csvTxtLength":"40","pdfLength":"","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"CHINA BANKING SAVING","leftJustified":true,"padFieldLength":0,"firstField":true,"eol":true},{"sequence":2,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"BANCNET DIRECT PAYMENT SUMMARY","delimiter":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":3,"sectionName":"3","fieldName":"space","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"csvTxtLength":"10","pdfLength":"10","eol":true}]');
 	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"9","fieldName":"INST CODE","csvTxtLength":"56","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"INST CODE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"PAYMENT RECEIVED FOR","csvTxtLength":"45","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"PAYMENT RECEIVED FOR","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL TRANSACTION COUNT","csvTxtLength":"40","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"TOTAL TRANSACTION COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"AMOUNT RECEIVED","csvTxtLength":"30","pdfLength":"","fieldType":"String","delimiter":" ","defaultValue":"AMOUNT RECEIVED","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"10","fieldName":"INST CODE","csvTxtLength":"56","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":6,"sectionName":"6","fieldName":"BILLER NAME","csvTxtLength":"45","pdfLength":"","fieldType":"String","delimiter":" ","firstField":false,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL TRANS","csvTxtLength":"15","pdfLength":"","fieldType":"Number","delimiter":" ","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL AMOUNT","csvTxtLength":"40","pdfLength":"","fieldType":"Decimal","delimiter":" ","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"24","pdfLength":"","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL:","csvTxtLength":"64","pdfLength":"","fieldType":"String","delimiter":"","defaultValue":"TOTAL:","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL TRANS","csvTxtLength":"28","pdfLength":"","fieldType":"Number","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":4,"sectionName":"4","fieldName":"TOTAL AMOUNT","csvTxtLength":"40","pdfLength":"","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	    
	 
  i_BODY_QUERY := TO_CLOB('
    
    SELECT
	COALESCE(LPAD(TXNC.TRL_BILLER_CODE, 3, ''0''), CBL.CBL_NAME) "INST CODE",
      COALESCE(CBL.CBL_NAME, LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'')) "BILLER NAME",
      COUNT(TXN.TRL_ID) "TOTAL TRANS",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
    FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      LEFT JOIN (select CBL_CODE, CBL_NAME, ROW_NUMBER() OVER (partition by CBL_CODE order by cbl_id) "ROWCNT" from CBC_BILLER) CBL ON CBL.ROWCNT=1 
        AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
	  JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
    GROUP BY
      TRL_BILLER_CODE, CBL.CBL_NAME
    ORDER BY
       CBL.CBL_NAME ASC
	START SELECT
	COALESCE(LPAD(TXNC.TRL_BILLER_CODE, 3, ''0''), CBL.CBL_NAME) "INST CODE",
	COALESCE(CBL.CBL_NAME, LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'')) "BILLER NAME",
      COUNT(TXN.TRL_ID) "TOTAL TRANS",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
    FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      LEFT JOIN (select CBL_CODE, CBL_NAME, ROW_NUMBER() OVER (partition by CBL_CODE order by cbl_id) "ROWCNT" from CBC_BILLER) CBL ON CBL.ROWCNT=1 
        AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
	 WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	  AND TXN.TRL_ID NOT IN (SELECT TXN.TRL_ID
     FROM TRANSACTION_LOG TXN
      JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      WHERE CPD.CPD_CODE IN (''80'',''81'',''82'',''83''))
	 GROUP BY
      TRL_BILLER_CODE, CBL.CBL_NAME
    ORDER BY
       CBL.CBL_NAME ASC
	 END'); 
  
  i_TRAILER_QUERY := TO_CLOB('
    SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRANS",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
    FROM
      TRANSACTION_LOG TXN
	  JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	 START SELECT
	 COUNT(TXN.TRL_ID) "TOTAL TRANS",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
    FROM
      TRANSACTION_LOG TXN
	WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
	  AND TXN.TRL_ID NOT IN (SELECT TXN.TRL_ID
     FROM TRANSACTION_LOG TXN
      JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      WHERE CPD.CPD_CODE IN (''80'',''81'',''82'',''83''))
	 END'); 

	  
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
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_FILE_NAME_PREFIX = 'cbs'
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	  
END;
/