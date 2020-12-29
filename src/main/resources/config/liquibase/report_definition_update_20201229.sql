DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- List of Possible Adjustments
	i_BODY_QUERY := TO_CLOB('		
    SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CTR.CTR_MNEM "TRAN MNEM",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TYPE",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      substr(ATA.ATA_TXN_STATE, 1, INSTR(ATA.ATA_TXN_STATE, ''('') - 1) "COMMENT"
	FROM
      ATM_TXN_ACTIVITY_LOG ATA
      JOIN TRANSACTION_LOG TXN ON ATA.ATA_TRL_ID = TXN.TRL_ID 
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_POST_COMPLETION_CODE IS NULL 
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND (
        ATA.ATA_TXN_STATE like ''%(Reversal)'' OR 
        ATA.ATA_TXN_STATE like ''%(Reversal completed)'' OR 
        ATA.ATA_TXN_STATE like ''%(Force post reversal)'' OR 
        ATA.ATA_TXN_STATE like ''%(Force post partial reversal)'' OR
        ATA.ATA_TXN_STATE like ''%(Force post partial reversal)'' OR
        ATA.ATA_TXN_STATE like ''%(Partial reversal completed)'' OR 
        ATA.ATA_TXN_STATE like ''%unknown dispense reported''
      )
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

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'List of Possible Adjustments';

-- ATM Availability
	i_BODY_QUERY := TO_CLOB('		
    SELECT
     AST.AST_ARE_NAME "REGION",
     ABR.ABR_CODE "BRANCH CODE",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     AST.AST_ID "STATION ID",
     round(SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100), 2) "UNAVAILABLE",
     round(100 - (SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100)), 2) "AVAILABLE",    
     CASE WHEN SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100) < 5 THEN ''1'' ELSE ''0'' END "STANDARD"
FROM
      ATM_STATIONS AST
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD_AST_ID AND {Txn_Date} 
GROUP BY
      AST.AST_ARE_NAME,
      ABR.ABR_CODE,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID,
      AST.AST_ID
ORDER BY
      AST.AST_ARE_NAME  ASC,
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC	
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Availability';
	update report_definition set red_header_fields='[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"ATM CENTER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"ATM CENTER","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"CBC ATM AVAILABILITY REPORT (INTERNAL)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CBC ATM AVAILABILITY REPORT (INTERNAL)","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"FROM  :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FROM  :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Defect","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Defect","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"5%","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"5%","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"TO    :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TO    :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Bancnet Standard","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Bancnet Standard","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"95%","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"95%","eol":true,"leftJustified":true,"padFieldLength":0}]' where RED_NAME = 'ATM Availability';
    update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'ATM Availability';

-- List of Recycler Transactions
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LIST OF CDM TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":12,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":15,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":16,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":19,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":true}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"25","fieldName":"BRANCH","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"26","fieldName":"TERMINAL","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"27","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"28","fieldName":"TRANSACTION TYPE","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":5,"sectionName":"1","fieldName":"Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"3","fieldName":"Seq No","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"SEQ NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"4","fieldName":"Trace No","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANCE NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"6","fieldName":"Tran Type","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BANK MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"8","fieldName":"Card Number","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CARD NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"9","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Acc No","csvTxtLength":"10","defaultValue":"ACCOUNT NUMBER","bodyHeader":true},{"sequence":14,"sectionName":"10","fieldName":"Trans Amt","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANS AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"11","fieldName":"Tran Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"12","fieldName":"Tran Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN CODE/REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"13","fieldName":"DATE","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"dd/MM/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"14","fieldName":"TIME","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"15","fieldName":"SEQ NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"16","fieldName":"TRACE NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"17","fieldName":"TRAN MNEM","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"18","fieldName":"TRAN TYPE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"19","fieldName":"BANK MNEM","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"20","fieldName":"CARD NO","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":null,"tagValue":null},{"sequence":25,"sectionName":"21","fieldName":"ACC NO","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":null,"tagValue":null},{"sequence":26,"sectionName":"22","fieldName":"TRANS AMOUNT","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":27,"sectionName":"23","fieldName":"TRAN FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"24","fieldName":"REMARKS","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

	i_BODY_QUERY := TO_CLOB('
	select 
	  (ABR.ABR_CODE || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(AST.AST_TERMINAL_ID, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
	  CASE WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''DEBIT'' THEN ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=1 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    ELSE ''CARDLESS TRANSACTIONS - OTHERS''
	    END AS "TRANSACTION GROUP",
	  CASE WHEN TSC.TSC_CODE = 1 THEN ''ATM WITHDRAWAL'' 
	    WHEN TSC.TSC_CODE = 128 THEN ''ATM WITHDRAWAL'' 
	    WHEN TSC.TSC_CODE = 142 THEN ''MOVING CASH - EMERGENCY CASH (NOW)''
	    WHEN TSC.TSC_CODE = 143 THEN ''MOVING CASH - PAY TO MOBILE (JUMP)''
	    WHEN TSC.TSC_CODE = 46 THEN ''INSTAPAY FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 47 THEN ''PESONET FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 21 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN TSC.TSC_CODE = 26 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN TSC.TSC_CODE = 250 THEN ''BILLS PAYMENT''
	    WHEN TSC.TSC_CODE = 252 THEN ''PREPAID AUTO RELOAD''
	    WHEN TSC.TSC_CODE = 246 THEN ''BEEP LOADING''
	    WHEN TSC.TSC_CODE = 251 THEN ''RFID LOADING''
	    ELSE TSC.TSC_DESCRIPTION 
	    END AS "TRANSACTION TYPE",
	  TXN.TRL_SYSTEM_TIMESTAMP "DATE",
	  TXN.TRL_SYSTEM_TIMESTAMP "TIME",
	  TXN.TRL_DEST_STAN "SEQ NO",
	  SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NO",
	  CTR.CTR_MNEM "TRAN MNEM",
	  CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TRAN TYPE",
	  CBA.CBA_MNEM "BANK MNEM",
	  TXN.TRL_PAN "CARD NO",
	  TXN.TRL_PAN_EKY_ID "CARD NO_ENCKEY",
	  NVL(TXN.TRL_ACCOUNT_1_ACN_ID, TXN.TRL_ACCOUNT_2_ACN_ID) "ACC NO",
	  NVL(TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID, TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID) "ACC NO_ENCKEY",
	  NVL(TXN.TRL_AMT_TXN,0) "TRANS AMOUNT",
	  NVL(TRL_ISS_CHARGE_AMT, NVL(TRL_ACQ_CHARGE_AMT,0)) "TRAN FEE",
	  (TXN.TRL_ACTION_RESPONSE_CODE || '' - '' || ARC.ARC_NAME) "REMARKS" 
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	where 
	  TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_ACTION_RESPONSE_CODE < 100
	  AND TXNC.TRL_ORIGIN_CHANNEL = ''BRM''
	  AND {Txn_Date}
	order by ABR_CODE, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE", "DATE", "TIME"	
	');
	
	update report_definition set red_header_fields=i_HEADER_FIELD where RED_NAME = 'List of Recycler Transactions';
	update report_definition set red_processing_class = 'my.com.mandrill.base.reporting.newTransactionReports.ListRecyclerTransactionProcessor' where RED_NAME = 'List of Recycler Transactions';
	update report_definition set red_body_fields = i_BODY_FIELD where RED_NAME = 'List of Recycler Transactions';
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'List of Recycler Transactions';
	update report_definition set red_trailer_fields = null where RED_NAME = 'List of Recycler Transactions';

-- Summary of Recycler Transactions
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LIST OF CDM TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":12,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":15,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":16,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":19,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":true}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"19","fieldName":"BRANCH","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"20","fieldName":"TERMINAL","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"21","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"1","fieldName":"Transaction","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANSACTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"2","fieldName":"On-us","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"ON-US /","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"3","fieldName":"Description","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DESCRIPTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"4","fieldName":"Inter-branch","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INTER-BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"5","fieldName":"Inter-Entity","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INTER-ENTITY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","fieldName":"Other Banks","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"OTHER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"7","fieldName":"Cash Card","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CASH CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"8","fieldName":"Total Dispensed","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"9","fieldName":"Total Deposit","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL DEPOSIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"10","fieldName":"Net Total","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"NET-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"11","fieldName":"TRANSACTION TYPE","csvTxtLength":"","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false,"defaultValue":""},{"sequence":15,"sectionName":"12","fieldName":"ONUS","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":16,"sectionName":"13","fieldName":"INTER ENTITY","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":17,"sectionName":"14","fieldName":"OTHER BANKS","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":18,"sectionName":"15","fieldName":"CASH CARD","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":19,"sectionName":"16","fieldName":"TOTAL DISPENSED","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":20,"sectionName":"17","fieldName":"TOTAL DEPOSIT","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');

	i_BODY_QUERY := TO_CLOB('select 
  	  BRANCH,
	  TERMINAL,
	  "TRANSACTION GROUP",
	  "TRANSACTION TYPE",
	  SUM(CASE WHEN TRL_ISS_NAME IN (''CBC'', ''CBS'') AND TRL_IS_INTER_ENTITY = 0 AND CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "ONUS",
	  SUM(CASE WHEN TRL_IS_INTER_ENTITY = 1 AND CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "INTER ENTITY",
	  SUM(CASE WHEN TRL_ISS_NAME IS NULL AND CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "OTHER BANKS",
	  SUM(CASE WHEN CPD_NAME IN (''CASH CARD'', ''EMV CASH CARD'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "CASH CARD",
	  SUM(CASE WHEN "TRANSACTION GROUP" = ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT'' THEN NVL(TRL_AMT_TXN,0) ELSE NULL END) AS "TOTAL DISPENSED",
	  SUM(CASE WHEN "TRANSACTION GROUP" != ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT'' THEN NVL(TRL_AMT_TXN,0) ELSE NULL END) AS "TOTAL DEPOSIT"
	FROM (
    select (ABR.ABR_CODE || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(AST.AST_TERMINAL_ID, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
	  CASE WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''DEBIT'' THEN ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=1 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    ELSE ''CARDLESS TRANSACTIONS - OTHERS''
	    END AS "TRANSACTION GROUP",
	  CASE WHEN TSC.TSC_CODE = 1 THEN ''ATM WITHDRAWAL'' 
	    WHEN TSC.TSC_CODE = 128 THEN ''ATM WITHDRAWAL'' 
	    WHEN TSC.TSC_CODE = 142 THEN ''MOVING CASH - EMERGENCY CASH (NOW)''
	    WHEN TSC.TSC_CODE = 143 THEN ''MOVING CASH - PAY TO MOBILE (JUMP)''
	    WHEN TSC.TSC_CODE = 46 THEN ''INSTAPAY FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 47 THEN ''PESONET FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 21 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN TSC.TSC_CODE = 26 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN TSC.TSC_CODE = 250 THEN ''BILLS PAYMENT''
	    WHEN TSC.TSC_CODE = 252 THEN ''PREPAID AUTO RELOAD''
	    WHEN TSC.TSC_CODE = 246 THEN ''BEEP LOADING''
	    WHEN TSC.TSC_CODE = 251 THEN ''RFID LOADING''
	    ELSE TSC.TSC_DESCRIPTION 
      END AS "TRANSACTION TYPE",
      TXNC.TRL_IS_INTER_ENTITY,
      CPD.CPD_NAME,
      TXN.TRL_AMT_TXN,
      TXN.TRL_ISS_NAME
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE   
	where 
	  TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_ACTION_RESPONSE_CODE < 100
	  AND TXNC.TRL_ORIGIN_CHANNEL = ''BRM''
	  AND {Txn_Date}
	)
	group by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"
	order by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"
');

	update report_definition set red_header_fields=i_HEADER_FIELD where RED_NAME = 'Summary of Recycler Transactions';
	update report_definition set red_processing_class = 'my.com.mandrill.base.reporting.newTransactionReports.SummaryRecyclerTransactionProcessor' where RED_NAME = 'Summary of Recycler Transactions';
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Summary of Recycler Transactions';

-- JCB Share In Fee Income
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"JCB WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERM NO.","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":4,"sectionName":"4","fieldName":"Terminal Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":5,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"6","fieldName":"Share In Interchange Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"SHARE IN INTERCHANGE FEE","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":7,"sectionName":"7","fieldName":"Share In Access Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"defaultValue":"SHARE IN ACCESS FEE","decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":8,"sectionName":"8","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL SHARE","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":11,"sectionName":"11","fieldName":"TERM NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":14,"sectionName":"14","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":15,"sectionName":"15","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":16,"sectionName":"16","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true}]');

	i_BODY_QUERY := TO_CLOB('
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
	
	update report_definition set red_header_fields=i_HEADER_FIELD where RED_NAME = 'JCB Share In Fee Income';
	update report_definition set red_processing_class = 'my.com.mandrill.base.cbc.processor.SimpleReportProcessor' where RED_NAME = 'JCB Share In Fee Income';
	update report_definition set red_body_fields = i_BODY_FIELD where RED_NAME = 'JCB Share In Fee Income';
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'JCB Share In Fee Income';
	update report_definition set red_trailer_fields = null where RED_NAME = 'JCB Share In Fee Income';

-- VISA Share In Fee Income
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"VISA WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERM NO.","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":4,"sectionName":"4","fieldName":"Terminal Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":5,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"6","fieldName":"Share In Interchange Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"SHARE IN INTERCHANGE FEE","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":7,"sectionName":"7","fieldName":"Share In Access Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"defaultValue":"SHARE IN ACCESS FEE","decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":8,"sectionName":"8","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL SHARE","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"group":true},{"sequence":11,"sectionName":"11","fieldName":"TERM NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":14,"sectionName":"14","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":15,"sectionName":"15","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true},{"sequence":16,"sectionName":"16","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"sumAmount":true}]');

	i_BODY_QUERY := TO_CLOB('
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
	
	update report_definition set red_header_fields=i_HEADER_FIELD where RED_NAME = 'VISA Share In Fee Income';
	update report_definition set red_processing_class = 'my.com.mandrill.base.cbc.processor.SimpleReportProcessor' where RED_NAME = 'VISA Share In Fee Income';
	update report_definition set red_body_fields = i_BODY_FIELD where RED_NAME = 'VISA Share In Fee Income';
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'VISA Share In Fee Income';
	update report_definition set red_trailer_fields = null where RED_NAME = 'VISA Share In Fee Income';

-- CUP Share In Fee Income
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CUP WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERM NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"34","fieldName":"Terminal Name","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"32","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Count","defaultValue":"COUNT"},{"sequence":7,"sectionName":"33","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"35","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"5","fieldName":"Transaction Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANSACTION FEE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"36","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"37","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Access Fee","defaultValue":"SHARE IN ACCESS FEE"},{"sequence":13,"sectionName":"7","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Total Share","defaultValue":"TOTAL SHARE","eol":true},{"sequence":14,"sectionName":"8","fieldName":"Space1","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":15,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space2"},{"sequence":16,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space3"},{"sequence":17,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space4"},{"sequence":18,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Withdrawal","defaultValue":"WITHDRAWAL"},{"sequence":19,"sectionName":"13","fieldName":"Inquiry","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INQUIRY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"14","fieldName":"Total Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Withdrawal","defaultValue":"WITHDRAWAL"},{"sequence":22,"sectionName":"16","fieldName":"Inquiry","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"INQUIRY","bodyHeader":true},{"sequence":23,"sectionName":"17","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL SHARE","bodyHeader":true},{"sequence":24,"sectionName":"18","fieldName":"Conversion Rate","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"CONVERSION RATE","bodyHeader":true,"eol":true},{"sequence":25,"sectionName":"19","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"BRANCH CODE","csvTxtLength":"10","firstField":true,"group":true},{"sequence":26,"sectionName":"20","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":27,"sectionName":"21","fieldName":"TERM NO.","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"22","fieldName":"TERMINAL NAME","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"23","fieldName":"COUNT WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":30,"sectionName":"24","fieldName":"COUNT INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":31,"sectionName":"25","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":32,"sectionName":"26","fieldName":"WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":33,"sectionName":"27","fieldName":"INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":34,"sectionName":"28","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":35,"sectionName":"29","fieldName":"CONVERSION RATE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":36,"sectionName":"30","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":37,"sectionName":"31","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');

	i_BODY_QUERY := TO_CLOB('
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
	
	update report_definition set red_header_fields=i_HEADER_FIELD where RED_NAME = 'CUP Share In Fee Income';
	update report_definition set red_processing_class = 'my.com.mandrill.base.cbc.processor.SimpleReportProcessor' where RED_NAME = 'CUP Share In Fee Income';
	update report_definition set red_body_fields = i_BODY_FIELD where RED_NAME = 'CUP Share In Fee Income';
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'CUP Share In Fee Income';
	update report_definition set red_trailer_fields = null where RED_NAME = 'CUP Share In Fee Income';

-- MasterCard Share In Fee Income
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"NYCE WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Interchange Fee (INQ)","defaultValue":"SHARE IN INTERCHANGE FEE (INQ)"},{"sequence":5,"sectionName":"30","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"25","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"29","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Interchange Fee (WDL)","defaultValue":"SHARE IN INTERCHANGE FEE (WDL)"},{"sequence":10,"sectionName":"26","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"27","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"7","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Total Share","defaultValue":"TOTAL SHARE","eol":true},{"sequence":13,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false},{"sequence":14,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":false},{"sequence":15,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"CBC Share","defaultValue":"CBC SHARE"},{"sequence":17,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BN Share","defaultValue":"BN SHARE"},{"sequence":18,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"14","fieldName":"CBC Share","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"CBC SHARE"},{"sequence":20,"sectionName":"28","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BN Share","defaultValue":"BN SHARE"},{"sequence":22,"sectionName":"16","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":23,"sectionName":"17","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":24,"sectionName":"18","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"19","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"20","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":27,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"22","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"23","fieldName":"Local Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LOCAL FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"24","fieldName":"Intl Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INT''L FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"31","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":32,"sectionName":"32","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":33,"sectionName":"33","fieldName":"INQUIRY COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":34,"sectionName":"34","fieldName":"CBC INQ SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":35,"sectionName":"35","fieldName":"BN INQ SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":36,"sectionName":"36","fieldName":"WITHDRAWAL COUNT","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":37,"sectionName":"37","fieldName":"CBC LOCAL WDL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":38,"sectionName":"38","fieldName":"CBC INT WDL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":39,"sectionName":"39","fieldName":"BN WDL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":40,"sectionName":"40","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');

	i_BODY_QUERY := TO_CLOB('
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
	
	update report_definition set red_header_fields=i_HEADER_FIELD where RED_NAME = 'MasterCard Share In Fee Income';
	update report_definition set red_processing_class = 'my.com.mandrill.base.cbc.processor.SimpleReportProcessor' where RED_NAME = 'MasterCard Share In Fee Income';
	update report_definition set red_body_fields = i_BODY_FIELD where RED_NAME = 'MasterCard Share In Fee Income';
	update REPORT_DEFINITION set red_body_query = i_BODY_QUERY where RED_NAME = 'MasterCard Share In Fee Income';
	update report_definition set red_trailer_fields = null where RED_NAME = 'MasterCard Share In Fee Income';

-- Approved IBFT Transactions as Transmitting Bank
	i_BODY_QUERY := TO_CLOB('
	SELECT
	      BRC.BRC_CODE "ISSUER BRANCH CODE",
	      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
	      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
	      TXN.TRL_DEST_STAN "SEQ NUMBER",
	      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
	      TXN.TRL_PAN "ATM CARD NUMBER",
	      TXN.TRL_PAN_EKY_ID,
	      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
	      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
	      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
	      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
	      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
	      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
	      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
	      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
	      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
	      TXN.TRL_AMT_TXN "AMOUNT"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
	      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	      JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
	      AND TXN.TRL_ISS_NAME = ''CBC''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
	      AND {IBFT_Criteria}
	      AND {Bank_Code}
	      AND {Txn_Date}
	ORDER BY
	      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
	      TXN.TRL_SYSTEM_TIMESTAMP ASC,
	      TXN.TRL_DEST_STAN ASC
	START SELECT
	      {Corporate_Income},
	      "BANK CODE",
	      "BANK NAME",
	      COUNT("TRAN COUNT") "TRAN COUNT",
	      SUM("AMOUNT") "AMOUNT",
	      125.00 * COUNT("TRAN COUNT") AS "CORP. INCOME",
	      25.00 * COUNT("TRAN COUNT") AS "ISSUER EXPENSE",
	      7.00 * COUNT("TRAN COUNT") AS "ISSUER INCOME"
	FROM(
	SELECT
	      {Corporate_Count},
	      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
	      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
	      TXN.TRL_ID "TRAN COUNT",
	      TXN.TRL_AMT_TXN "AMOUNT"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
	      AND TXN.TRL_ISS_NAME = ''CBC''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
	      AND {IBFT_Criteria}
	      AND {Txn_Date}
	)
	GROUP BY
	      "BANK CODE",
	      "BANK NAME"
	ORDER BY
	      "BANK CODE" ASC
	END
	');
	
	i_TRAILER_QUERY := TO_CLOB('
	SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
	FROM
	      TRANSACTION_LOG TXN
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
	      AND TXN.TRL_ISS_NAME = ''CBC''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
	      AND {IBFT_Criteria}
	      AND {Bank_Code}
	      AND {Txn_Date}
	START SELECT
	      {Corporate_Income},
	      COUNT(TXN.TRL_ID) "TOTAL TRAN",
	      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT",
	      SUM(125.00 * COUNT(TXN.TRL_ID)) AS "CORP. INCOME",
	      SUM(25.00 * COUNT(TXN.TRL_ID)) AS "ISSUER EXPENSE",
	      SUM(7.00 * COUNT(TXN.TRL_ID)) AS "ISSUER INCOME"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	WHERE
	      TXN.TRL_TSC_CODE = 1
	      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
	      AND TXN.TRL_ISS_NAME = ''CBC''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
	      AND {IBFT_Criteria}
	      AND {Txn_Date}
	GROUP BY
	      TXN.TRL_AMT_TXN,
	      TXN.TRL_ID
	END
	');
	
	update REPORT_DEFINITION set red_body_query = i_BODY_QUERY where RED_NAME = 'Approved IBFT Transactions as Transmitting Bank';
	update REPORT_DEFINITION set red_trailer_query = i_TRAILER_QUERY where RED_NAME = 'Approved IBFT Transactions as Transmitting Bank';

-- Inter-Entity IBFT Transaction Fees
	i_BODY_QUERY := TO_CLOB('	
   	START ISSUING
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
      		AND TXN.TRL_TQU_ID = ''F''
      		AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      		AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      		AND TXN.TRL_ISS_NAME = ''CBC''
      		AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000000112''
      		AND TXNC.TRL_IS_INTER_ENTITY = 1
      		AND {Branch_Code}
      		AND {Txn_Date}
		GROUP BY
      		BRC.BRC_CODE,
      		BRC.BRC_NAME
	END ISSUING
	START ACQUIRING
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
      		AND TXN.TRL_TQU_ID = ''F''
      		AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      		AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      		AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000000010''
      		AND TXN.TRL_ISS_NAME = ''CBS''
      		AND TXNC.TRL_IS_INTER_ENTITY = 1
      		AND {Branch_Code}
      		AND {Txn_Date}
		GROUP BY
      		BRC.BRC_CODE,
      		BRC.BRC_NAME
	END ACQUIRING
	START RECEIVING
		SELECT
			BRC.BRC_CODE "BRANCH CODE",
      		BRC.BRC_NAME "BRANCH NAME",
      		TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      		TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
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
      		AND TXN.TRL_TQU_ID = ''F''
      		AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      		AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      		AND TXN.TRL_ISS_NAME = ''CBS''
      		AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000000010''
      		AND {Txn_Date}
		GROUP BY
      		BRC.BRC_CODE,
      		BRC.BRC_NAME,
      		TXN.TRL_ACCOUNT_2_ACN_ID,
            TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID
		END RECEIVING			   		
	');
	update REPORT_DEFINITION set red_body_query = i_BODY_QUERY where RED_NAME = 'Inter-Entity IBFT Transaction Fees';
	
-- Cash Card Successful Transactions
	i_BODY_QUERY := TO_CLOB('
	SELECT
      "CHANNEL",
      "TRANSACTION TYPE",
      COUNT("TOTAL TXN COUNT") "TOTAL TXN COUNT",
      SUM("TOTAL TXN AMT") "TOTAL TXN AMT",
      SUM("TOTAL TXN AMT")/COUNT("TOTAL TXN COUNT") "AVE TXN AMT"
	FROM (
	SELECT
	      {Channel} "CHANNEL",
	      {Txn_Type} "TRANSACTION TYPE",
	      TXN.TRL_ID "TOTAL TXN COUNT",
	      TXN.TRL_AMT_TXN "TOTAL TXN AMT"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	      JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	WHERE
	      CPD.CPD_NAME IN (''CASH CARD'', ''EMV CASH CARD'')
	      AND TXN.TRL_TQU_ID = ''F''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	      AND {Txn_Criteria}
	      AND {Txn_Date}
	)
	GROUP BY
	      "CHANNEL",
	      "TRANSACTION TYPE"
	ORDER BY
	      "CHANNEL" ASC,
	      "TRANSACTION TYPE" ASC		   		
	');
	update REPORT_DEFINITION set red_body_query = i_BODY_QUERY where RED_NAME = 'Cash Card Successful Transactions';
	
-- Cash Card Unsuccessful Transactions
	i_BODY_QUERY := TO_CLOB('
	SELECT
      "CHANNEL",
      "TRANSACTION TYPE",
      "REASON",
      COUNT("TOTAL TXN COUNT") "TOTAL TXN COUNT",
      SUM("TOTAL TXN AMT") "TOTAL TXN AMT",
      SUM("TOTAL TXN AMT")/COUNT("TOTAL TXN COUNT") "AVE TXN AMT"
	FROM (
	SELECT
	      {Channel} "CHANNEL",
	      {Txn_Type} "TRANSACTION TYPE",
	      ARC.ARC_NAME "REASON",
	      TXN.TRL_ID "TOTAL TXN COUNT",
	      TXN.TRL_AMT_TXN "TOTAL TXN AMT"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	      JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	WHERE
	      CPD.CPD_NAME IN (''CASH CARD'', ''EMV CASH CARD'')
	      AND TXN.TRL_TQU_ID = ''F''
	      AND TXN.TRL_ACTION_RESPONSE_CODE != 0
	      AND {Txn_Criteria}
	      AND {Txn_Date}
	)
	GROUP BY
	      "CHANNEL",
	      "TRANSACTION TYPE",
	      "REASON"
	ORDER BY
	      "CHANNEL" ASC,
	      "TRANSACTION TYPE" ASC	   		
	');
	update REPORT_DEFINITION set red_body_query = i_BODY_QUERY where RED_NAME = 'Cash Card Unsuccessful Transactions';
		
END;
/