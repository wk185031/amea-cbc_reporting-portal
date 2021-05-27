-- script used to enable back scheme reports removed from NY_disable_scheme_report_20210527
DECLARE
	HEADER_FIELD CLOB;
	BODY_FIELD CLOB;
	TRAILER_FIELD CLOB;
	BODY_QUERY CLOB;
	TRAILER_QUERY CLOB;

BEGIN
	HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CUP WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERM NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"34","fieldName":"Terminal Name","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"32","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Count","defaultValue":"COUNT"},{"sequence":7,"sectionName":"33","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"35","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"5","fieldName":"Transaction Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANSACTION FEE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"36","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"37","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Access Fee","defaultValue":"SHARE IN ACCESS FEE"},{"sequence":13,"sectionName":"7","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Total Share","defaultValue":"TOTAL SHARE","eol":true},{"sequence":14,"sectionName":"8","fieldName":"Space1","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":15,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space2"},{"sequence":16,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space3"},{"sequence":17,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space4"},{"sequence":18,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Withdrawal","defaultValue":"WITHDRAWAL"},{"sequence":19,"sectionName":"13","fieldName":"Inquiry","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INQUIRY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"14","fieldName":"Total Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Withdrawal","defaultValue":"WITHDRAWAL"},{"sequence":22,"sectionName":"16","fieldName":"Inquiry","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"INQUIRY","bodyHeader":true},{"sequence":23,"sectionName":"17","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL SHARE","bodyHeader":true},{"sequence":24,"sectionName":"18","fieldName":"Conversion Rate","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"CONVERSION RATE","bodyHeader":true,"eol":true},{"sequence":25,"sectionName":"19","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"BRANCH CODE","csvTxtLength":"10","firstField":true,"group":true},{"sequence":26,"sectionName":"20","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":27,"sectionName":"21","fieldName":"TERM NO.","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"22","fieldName":"TERMINAL NAME","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"23","fieldName":"COUNT WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":30,"sectionName":"24","fieldName":"COUNT INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":31,"sectionName":"25","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":32,"sectionName":"26","fieldName":"WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":33,"sectionName":"27","fieldName":"INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":34,"sectionName":"28","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":35,"sectionName":"29","fieldName":"CONVERSION RATE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":36,"sectionName":"30","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":37,"sectionName":"31","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');
	TRAILER_FIELD := null;
	BODY_QUERY := TO_CLOB('
	
	with FEE as (
  	select 
    	''0.10'' "WITHDRAWAL_FEE",
    	''0.05'' "INQUIRY_FEE",
    	''1.0'' "CONVERSION_RATE",
    	''0.01'' "ACCESS_FEE"
  		from dual
	)
	SELECT 
	  "BRANCH CODE",
	  "BRANCH NAME",
	  "TERM NO",
	  "TERMINAL NAME",
	  SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) "WITHDRAWAL COUNT",
      SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) "INQUIRY COUNT",
      COUNT(TRL_ID) "TOTAL COUNT",
	  SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select WITHDRAWAL_FEE from fee) "TOTAL WITHDRAWAL FEE",
	  SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) * (select INQUIRY_FEE from fee) "TOTAL INQUIRY FEE",
      (SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select WITHDRAWAL_FEE from fee)) + (SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) * (select INQUIRY_FEE from fee)) "TOTAL TXN SHARE",
      (select CONVERSION_RATE from fee) "CONVERSION RATE",
      (COUNT(TRL_ID) * (select ACCESS_FEE from fee)) "SHARE IN ACCESS FEE",
	  (SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select WITHDRAWAL_FEE from fee)) + (SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) * (select INQUIRY_FEE from fee)) + (COUNT(TRL_ID) *(select ACCESS_FEE from fee)) "TOTAL SHARE"
	FROM (
	    SELECT 
	      ABR.ABR_CODE "BRANCH CODE",
	      ABR.ABR_NAME "BRANCH NAME",
	      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERM NO",
	      AST.AST_ALO_LOCATION_ID "TERMINAL NAME",
	      TXN.TRL_ID "TRL_ID",
          TXN.TRL_TSC_CODE "TSC_CODE"        
	    FROM 
	      ATM_BRANCHES ABR
	      LEFT JOIN ATM_STATIONS AST ON AST.AST_ABR_ID = ABR.ABR_ID
	      LEFT JOIN TRANSACTION_LOG TXN ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
	      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	    WHERE 
	      TXN.TRL_TQU_ID = ''F''
	      AND TRL_TSC_CODE in (1,128,30,31)
	      AND TXN.TRL_ACTION_RESPONSE_CODE < 100
	      AND CBA.CBA_NAME = ''CUP''
	      AND {Txn_Date}
	)
	GROUP BY "BRANCH CODE", "BRANCH NAME", "TERM NO", "TERMINAL NAME"
	ORDER BY "BRANCH CODE", "BRANCH NAME", "TERM NO"	
	');
	TRAILER_QUERY := null;

	INSERT INTO REPORT_DEFINITION (RED_ID, RED_REC_ID, RED_NAME, RED_DESCRIPTION, RED_FILE_NAME_PREFIX, RED_FILE_FORMAT, 
		RED_FILE_LOCATION, RED_PROCESSING_CLASS, RED_HEADER_FIELDS, RED_BODY_FIELDS, RED_TRAILER_FIELDS, RED_BODY_QUERY, 
		RED_TRAILER_QUERY, RED_FREQUENCY, CREATED_BY, CREATED_DATE, RED_BRANCH_FLAG, RED_DAILY_SCHEDULE_TIME, RED_INS_ID) VALUES 
	(
		88, 
		13, 
		'CUP Share In Fee Income', 
		'Total volume of acquired CUP withdrawal transactions on CBC branch and offsite terminals for computation of our acquirer share and its corresponding transaction and access fee income', 
		'CUP Share In Fee Income', 
		'CSV,', 
		'/tmp/Reporting/reports/BillingAllocationInterbank/', 
		'my.com.mandrill.base.cbc.processor.SimpleReportProcessor', 
		HEADER_FIELD, 
		BODY_FIELD, 
		TRAILER_FIELD, 
		BODY_QUERY, 
		TRAILER_QUERY, 
		'Daily,Monthly,', 
		'mandrill', 
		CURRENT_TIMESTAMP, 
		'master', 
		CURRENT_TIMESTAMP, 
		(select id  from institution  where name = 'ChinaBank (CBC)')
	);

	HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"JCB WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERM NO.","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":4,"sectionName":"4","fieldName":"Terminal Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":5,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"6","fieldName":"Share In Interchange Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"SHARE IN INTERCHANGE FEE","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":7,"sectionName":"7","fieldName":"Share In Access Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"defaultValue":"SHARE IN ACCESS FEE","decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":8,"sectionName":"8","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL SHARE","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":11,"sectionName":"11","fieldName":"TERM NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":14,"sectionName":"14","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":15,"sectionName":"15","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":16,"sectionName":"16","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true}]');
	TRAILER_FIELD := null;
	BODY_QUERY := TO_CLOB('
	
	SELECT 
	  "BRANCH CODE",
	  "BRANCH NAME",
	  "TERM NO",
	  "TERMINAL NAME",
	  COUNT(TRL_ID) "COUNT",
	  (COUNT(TRL_ID) * 0.50) "INTERCHANGE FEE",
	  (COUNT(TRL_ID) * 0.30) "ACCESS FEE",
	  (COUNT(TRL_ID) * 0.50) + (COUNT(TRL_ID) * 0.30) "TOTAL SHARE"
	FROM (
	    SELECT 
	      ABR.ABR_CODE "BRANCH CODE",
	      ABR.ABR_NAME "BRANCH NAME",
	      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERM NO",
	      AST.AST_ALO_LOCATION_ID "TERMINAL NAME",
	      TXN.TRL_ID "TRL_ID"
	    FROM 
	      ATM_BRANCHES ABR
	      LEFT JOIN ATM_STATIONS AST ON AST.AST_ABR_ID = ABR.ABR_ID
	      LEFT JOIN TRANSACTION_LOG TXN ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
	      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	    WHERE 
	      TXN.TRL_TQU_ID = ''F''
	      AND TRL_TSC_CODE = 1
	      AND TXN.TRL_ACTION_RESPONSE_CODE < 100
	      AND CBA.CBA_NAME = ''JCB''
	      AND {Txn_Date}
	)
	GROUP BY "BRANCH CODE", "BRANCH NAME", "TERM NO", "TERMINAL NAME"
	ORDER BY "BRANCH CODE", "BRANCH NAME", "TERM NO"	
	');
	TRAILER_QUERY := null;

	INSERT INTO REPORT_DEFINITION (RED_ID, RED_REC_ID, RED_NAME, RED_DESCRIPTION, RED_FILE_NAME_PREFIX, RED_FILE_FORMAT, 
		RED_FILE_LOCATION, RED_PROCESSING_CLASS, RED_HEADER_FIELDS, RED_BODY_FIELDS, RED_TRAILER_FIELDS, RED_BODY_QUERY, 
		RED_TRAILER_QUERY, RED_FREQUENCY, CREATED_BY, CREATED_DATE, RED_BRANCH_FLAG, RED_DAILY_SCHEDULE_TIME, RED_INS_ID) VALUES 
	(
		89, 
		13, 
		'JCB Share In Fee Income', 
		'Total volume of acquired JCB withdrawal transactions on CBC branch and offsite terminals for computation of our acquirer share and its corresponding interchange and access fee income', 
		'JCB Share In Fee Income', 
		'CSV,', 
		'/tmp/Reporting/reports/BillingAllocationInterbank/', 
		'my.com.mandrill.base.cbc.processor.SimpleReportProcessor', 
		HEADER_FIELD, 
		BODY_FIELD, 
		TRAILER_FIELD, 
		BODY_QUERY, 
		TRAILER_QUERY, 
		'Daily,Monthly,', 
		'mandrill', 
		CURRENT_TIMESTAMP, 
		'master', 
		CURRENT_TIMESTAMP, 
		(select id  from institution  where name = 'ChinaBank (CBC)')
	);
	
	HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"VISA WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERM NO.","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":4,"sectionName":"4","fieldName":"Terminal Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":5,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"6","fieldName":"Share In Interchange Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"SHARE IN INTERCHANGE FEE","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":7,"sectionName":"7","fieldName":"Share In Access Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"defaultValue":"SHARE IN ACCESS FEE","decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":8,"sectionName":"8","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL SHARE","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":11,"sectionName":"11","fieldName":"TERM NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":14,"sectionName":"14","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":15,"sectionName":"15","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":16,"sectionName":"16","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true}]');
	TRAILER_FIELD := null;
	BODY_QUERY := TO_CLOB('
	
	SELECT 
	  "BRANCH CODE",
	  "BRANCH NAME",
	  "TERM NO",
	  "TERMINAL NAME",
	  COUNT(TRL_ID) "COUNT",
	  (COUNT(TRL_ID) * 0.50) "INTERCHANGE FEE",
	  (COUNT(TRL_ID) * 0.30) "ACCESS FEE",
	  (COUNT(TRL_ID) * 0.50) + (COUNT(TRL_ID) * 0.30) "TOTAL SHARE"
	FROM (
	    SELECT 
	      ABR.ABR_CODE "BRANCH CODE",
	      ABR.ABR_NAME "BRANCH NAME",
	      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERM NO",
	      AST.AST_ALO_LOCATION_ID "TERMINAL NAME",
	      TXN.TRL_ID "TRL_ID"
	    FROM 
	      ATM_BRANCHES ABR
	      LEFT JOIN ATM_STATIONS AST ON AST.AST_ABR_ID = ABR.ABR_ID
	      LEFT JOIN TRANSACTION_LOG TXN ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
	      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	    WHERE 
	      TXN.TRL_TQU_ID = ''F''
	      AND TRL_TSC_CODE = 1
	      AND TXN.TRL_ACTION_RESPONSE_CODE < 100
	      AND CBI.CBI_BIN IS NULL
	      AND {Txn_Date}
	)
	GROUP BY "BRANCH CODE", "BRANCH NAME", "TERM NO", "TERMINAL NAME"
	ORDER BY "BRANCH CODE", "BRANCH NAME", "TERM NO"	
	');
	TRAILER_QUERY := null;

	INSERT INTO REPORT_DEFINITION (RED_ID, RED_REC_ID, RED_NAME, RED_DESCRIPTION, RED_FILE_NAME_PREFIX, RED_FILE_FORMAT, 
		RED_FILE_LOCATION, RED_PROCESSING_CLASS, RED_HEADER_FIELDS, RED_BODY_FIELDS, RED_TRAILER_FIELDS, RED_BODY_QUERY, 
		RED_TRAILER_QUERY, RED_FREQUENCY, CREATED_BY, CREATED_DATE, RED_BRANCH_FLAG, RED_DAILY_SCHEDULE_TIME, RED_INS_ID) VALUES 
	(
		90, 
		13, 
		'VISA Share In Fee Income', 
		'Total volume of acquired VISA withdrawal transactions on CBC branch and offsite terminals for computation of our acquirer share and its corresponding interchange and access fee income', 
		'VISA Share In Fee Income', 
		'CSV,', 
		'/tmp/Reporting/reports/BillingAllocationInterbank/', 
		'my.com.mandrill.base.cbc.processor.SimpleReportProcessor', 
		HEADER_FIELD, 
		BODY_FIELD, 
		TRAILER_FIELD, 
		BODY_QUERY, 
		TRAILER_QUERY, 
		'Daily,Monthly,', 
		'mandrill', 
		CURRENT_TIMESTAMP, 
		'master', 
		CURRENT_TIMESTAMP, 
		(select id  from institution  where name = 'ChinaBank (CBC)')
	);
	
	HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"NYCE WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Interchange Fee (INQ)","defaultValue":"SHARE IN INTERCHANGE FEE (INQ)"},{"sequence":5,"sectionName":"30","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"25","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"29","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Interchange Fee (WDL)","defaultValue":"SHARE IN INTERCHANGE FEE (WDL)"},{"sequence":10,"sectionName":"26","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"27","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"7","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Total Share","defaultValue":"TOTAL SHARE","eol":true},{"sequence":13,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false},{"sequence":14,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":false},{"sequence":15,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"CBC Share","defaultValue":"CBC SHARE"},{"sequence":17,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BN Share","defaultValue":"BN SHARE"},{"sequence":18,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"14","fieldName":"CBC Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"CBC SHARE"},{"sequence":20,"sectionName":"28","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BN Share","defaultValue":"BN SHARE"},{"sequence":22,"sectionName":"16","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":23,"sectionName":"17","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":24,"sectionName":"18","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"19","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"20","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":27,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"22","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"23","fieldName":"Local Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LOCAL FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"24","fieldName":"Intl Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INT''L FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"31","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":32,"sectionName":"32","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":33,"sectionName":"33","fieldName":"INQUIRY COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":34,"sectionName":"34","fieldName":"CBC INQ SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":35,"sectionName":"35","fieldName":"BN INQ SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":36,"sectionName":"36","fieldName":"WITHDRAWAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":37,"sectionName":"37","fieldName":"CBC LOCAL WDL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":38,"sectionName":"38","fieldName":"CBC INT WDL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":39,"sectionName":"39","fieldName":"BN WDL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":40,"sectionName":"40","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');
	TRAILER_FIELD := null;
	BODY_QUERY := TO_CLOB('
	
	with FEE as (
  	select 
    	''0.05'' "CBC_INQ_FEE",
    	''0.03'' "BN_INQ_FEE",
    	''0.10'' "CBC_LOCAL_WDL_FEE",
    	''1.0'' "CBC_INT_WDL_FEE",
    	''0.03'' "BN_WDL_FEE"
  	from dual
	)
	SELECT 
		  "BRANCH CODE",
		  "BRANCH NAME",
		  SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) "WITHDRAWAL COUNT",
	      SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) "INQUIRY COUNT",
	      SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) * (select CBC_INQ_FEE from fee) "CBC INQ SHARE",
	      SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) * (select BN_INQ_FEE from fee) "BN INQ SHARE",    
		  SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select CBC_LOCAL_WDL_FEE from fee) "CBC LOCAL WDL SHARE",
	      SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select CBC_INT_WDL_FEE from fee) "CBC INT WDL SHARE",
	      SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select BN_WDL_FEE from fee) "BN WDL SHARE",
		  (SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) * (select CBC_INQ_FEE from fee)) +  (SUM(CASE WHEN TSC_CODE IN (30,31) THEN 1 ELSE 0 END) * (select BN_INQ_FEE from fee)) + 
	        (SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select CBC_LOCAL_WDL_FEE from fee)) + (SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select CBC_INT_WDL_FEE from fee)) + 
	        (SUM(CASE WHEN TSC_CODE IN (1,128) THEN 1 ELSE 0 END) * (select BN_WDL_FEE from fee)) "TOTAL SHARE"
		FROM (
		    SELECT 
		      ABR.ABR_CODE "BRANCH CODE",
		      ABR.ABR_NAME "BRANCH NAME",
		      TXN.TRL_ID "TRL_ID",
	          TXN.TRL_TSC_CODE "TSC_CODE"        
		    FROM 
		      ATM_BRANCHES ABR
		      LEFT JOIN ATM_STATIONS AST ON AST.AST_ABR_ID = ABR.ABR_ID
		      LEFT JOIN TRANSACTION_LOG TXN ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
		      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
		      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
		      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
		    WHERE 
		      TXN.TRL_TQU_ID = ''F''
		      AND TRL_TSC_CODE in (1,128,30,31)
		      AND TXN.TRL_ACTION_RESPONSE_CODE < 100
		      AND CBA.CBA_NAME = ''MASTERCARD''
	      	  AND {Txn_Date}
		)
	GROUP BY "BRANCH CODE", "BRANCH NAME"
	ORDER BY "BRANCH CODE", "BRANCH NAME"	
	');
	TRAILER_QUERY := null;

	INSERT INTO REPORT_DEFINITION (RED_ID, RED_REC_ID, RED_NAME, RED_DESCRIPTION, RED_FILE_NAME_PREFIX, RED_FILE_FORMAT, 
		RED_FILE_LOCATION, RED_PROCESSING_CLASS, RED_HEADER_FIELDS, RED_BODY_FIELDS, RED_TRAILER_FIELDS, RED_BODY_QUERY, 
		RED_TRAILER_QUERY, RED_FREQUENCY, CREATED_BY, CREATED_DATE, RED_BRANCH_FLAG, RED_DAILY_SCHEDULE_TIME, RED_INS_ID) VALUES 
	(
		91, 
		13, 
		'MasterCard Share In Fee Income', 
		'Total volume of issuer MasterCard withdrawal transactions of CBC cardholders and its corresponding interchange and issuer fee income', 
		'MasterCard Share In Fee Income', 
		'CSV,', 
		'/tmp/Reporting/reports/BillingAllocationInterbank/', 
		'my.com.mandrill.base.cbc.processor.SimpleReportProcessor', 
		HEADER_FIELD, 
		BODY_FIELD, 
		TRAILER_FIELD, 
		BODY_QUERY, 
		TRAILER_QUERY, 
		'Daily,Monthly,', 
		'mandrill', 
		CURRENT_TIMESTAMP, 
		'master', 
		CURRENT_TIMESTAMP, 
		(select id  from institution  where name = 'ChinaBank (CBC)')
	);
END;

/