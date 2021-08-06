-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Revised Report		06-JULY-2021	WY		Revised reports based on spec
-- Report revision		23-JUL-2021		NY		Update based on excel spec
-- CBCAXUPISSLOG-830	27-JUL-2021		NY		Rejected Transaction must still contain transaction amount
-- Cross Checking		04-AUG-2021		NY		Fix cross checking to master not match
-- Acquirer				06-AUG-2021		NY		Use left join consistently to avoid data mismatch to master 

DECLARE
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- ATM Withdrawal as Acquirer Bank

-- CBC header/body/trailer fields
    i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"130","pdfLength":"130","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"REPORT ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"REPORT ID : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"EFP002-01","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"EFP002-01","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Type","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"File Type : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TXT","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"TXT","fieldFormat":"","delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"File Type","csvTxtLength":"131","pdfLength":"131","fieldType":"String","defaultValue":"Acquired International Transactions Log (Issuer)","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","defaultValue":"","eol":false,"delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"RunTime","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"RUNTIME : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm","csvTxtLength":"10","pdfLength":"10","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"TRAN DATE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","firstField":true,"delimiter":";","fieldFormat":"","defaultValue":"TRAN DATE : ","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"120","pdfLength":"120","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Frequency","csvTxtLength":"11","pdfLength":"11","fieldType":"String","fieldFormat":"","delimiter":";","defaultValue":"FREQUENCY : ","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Daily","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"Daily","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"Branch Code","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Term No","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Term No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Issuing Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Issuing Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Seq No","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Trace No","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Account","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DR Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"DR Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CR Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"CR Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Reply","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"Reply","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Comment","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"Comment","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" ","bodyHeader":true,"eol":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":33,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"DR AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"CR AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[]');
	
-- CBS header/body/trailer fields
    i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"130","pdfLength":"130","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"REPORT ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"REPORT ID : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"EFP002-01","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"EFP002-01","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Type","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"File Type : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TXT","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"TXT","fieldFormat":"","delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"File Type","csvTxtLength":"131","pdfLength":"131","fieldType":"String","defaultValue":"Acquired International Transactions Log (Issuer)","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","defaultValue":"","eol":false,"delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"RunTime","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"RUNTIME : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm","csvTxtLength":"10","pdfLength":"10","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"TRAN DATE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","firstField":true,"delimiter":";","fieldFormat":"","defaultValue":"TRAN DATE : ","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"120","pdfLength":"120","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Frequency","csvTxtLength":"11","pdfLength":"11","fieldType":"String","fieldFormat":"","delimiter":";","defaultValue":"FREQUENCY : ","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Daily","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"Daily","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"Branch Code","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Term No","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Term No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Issuing Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Issuing Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Seq No","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Trace No","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Account","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DR Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"DR Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CR Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"CR Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Reply","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"Reply","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Comment","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"Comment","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" ","bodyHeader":true,"eol":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":33,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"DR AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"CR AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[]');
	
	i_BODY_QUERY := TO_CLOB('SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM AS "BANK MNEM",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TQU_ID != ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DR AMOUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CR AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT''
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
	  AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != 12345
      AND TXN.TRL_TQU_ID IN (''F'',''R'')
      AND (TXN.TRL_ISS_NAME IS NULL OR TXN.TRL_ISS_NAME = {V_IE_Iss_Name})
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
	ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
	  ');	
	  
    i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM Withdrawal as Acquirer Bank' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM Withdrawal as Acquirer Bank' AND RED_INS_ID = 2;
	
END;
/