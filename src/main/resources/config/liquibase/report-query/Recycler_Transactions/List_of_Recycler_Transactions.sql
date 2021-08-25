-- Tracking				Date			Name	Description
-- Report revision		15-JUL-2021		NY		Initial from UAT environment
-- Report revision		23-JUL-2021		NY		Update based on excel spec
-- Report revision		24-JUL-2021		NY		Separate update query to CBC/CBS report definition
-- Rel-20210730			28-JUL-2021		KW		Revise Recycler transaction

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'List of Recycler Transactions';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- List of Recycler Transactions

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LIST OF RECYCLER TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"26","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"27","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"28","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"29","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":13,"sectionName":"9","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":16,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":19,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":20,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":23,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":false},{"sequence":26,"sectionName":"22","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":27,"sectionName":"23","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":28,"sectionName":"25","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":29,"sectionName":"24","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"25","fieldName":"BRANCH","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"26","fieldName":"TERMINAL","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"27","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"28","fieldName":"TRANSACTION TYPE","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":5,"sectionName":"1","fieldName":"Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"3","fieldName":"Seq No","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"SEQ NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"4","fieldName":"Trace No","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRACE NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"6","fieldName":"Tran Type","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BANK MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"8","fieldName":"Card Number","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CARD NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"9","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Acc No","csvTxtLength":"10","defaultValue":"ACCOUNT NUMBER","bodyHeader":true},{"sequence":14,"sectionName":"10","fieldName":"Trans Amt","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANS AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"11","fieldName":"Tran Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"12","fieldName":"Tran Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN CODE/REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"13","fieldName":"DATE","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"14","fieldName":"TIME","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"15","fieldName":"SEQ NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"16","fieldName":"TRACE NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":21,"sectionName":"17","fieldName":"TRAN MNEM","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"18","fieldName":"TRAN TYPE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"19","fieldName":"BANK MNEM","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"20","fieldName":"CARD NO","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":null,"tagValue":null},{"sequence":25,"sectionName":"21","fieldName":"ACC NO","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":null,"tagValue":null},{"sequence":26,"sectionName":"22","fieldName":"TRANS AMOUNT","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":27,"sectionName":"23","fieldName":"TRAN FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"24","fieldName":"REMARKS","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS_CBC := null;
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LIST OF RECYCLER TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"26","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"27","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"28","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"29","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":13,"sectionName":"9","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":16,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":19,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":20,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":23,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":false},{"sequence":26,"sectionName":"22","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":27,"sectionName":"23","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":28,"sectionName":"25","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":29,"sectionName":"24","fieldName":"EMPTY","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"25","fieldName":"BRANCH","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"26","fieldName":"TERMINAL","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"27","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"28","fieldName":"TRANSACTION TYPE","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":5,"sectionName":"1","fieldName":"Date","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DATE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"3","fieldName":"Seq No","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"SEQ NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"4","fieldName":"Trace No","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRACE NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"6","fieldName":"Tran Type","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BANK MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"8","fieldName":"Card Number","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CARD NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"9","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Acc No","csvTxtLength":"10","defaultValue":"ACCOUNT NUMBER","bodyHeader":true},{"sequence":14,"sectionName":"10","fieldName":"Trans Amt","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANS AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"11","fieldName":"Tran Fee","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"12","fieldName":"Tran Code","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRAN CODE/REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"13","fieldName":"DATE","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"14","fieldName":"TIME","csvTxtLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"15","fieldName":"SEQ NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"16","fieldName":"TRACE NO","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":21,"sectionName":"17","fieldName":"TRAN MNEM","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"18","fieldName":"TRAN TYPE","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"19","fieldName":"BANK MNEM","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"20","fieldName":"CARD NO","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":null,"tagValue":null},{"sequence":25,"sectionName":"21","fieldName":"ACC NO","csvTxtLength":"50","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":null,"tagValue":null},{"sequence":26,"sectionName":"22","fieldName":"TRANS AMOUNT","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":27,"sectionName":"23","fieldName":"TRAN FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"24","fieldName":"REMARKS","csvTxtLength":"20","fieldType":"String","delimiter":",","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS_CBS := null;
	
	i_BODY_QUERY := TO_CLOB('
select 
	  (ABR.ABR_CODE || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(AST.AST_TERMINAL_ID, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
           CASE WHEN TXN.TRL_TSC_CODE IN (250,251,252,246)  THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=1 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    ELSE ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT''
	    END AS "TRANSACTION GROUP",
	  CASE WHEN TSC.TSC_CODE = 31 THEN ''BALANCE INQURY'' 
	    WHEN (TSC.TSC_CODE = 1 OR TSC.TSC_CODE = 128) THEN ''ATM WITHDRAWAL'' 
	    WHEN TSC.TSC_CODE = 142 THEN ''MOVING CASH - EMERGENCY CASH (NOW)''
	    WHEN TSC.TSC_CODE = 143 THEN ''MOVING CASH - PAY TO MOBILE (JUMP)''
	    WHEN TSC.TSC_CODE = 46 THEN ''INSTAPAY FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 47 THEN ''PESONET FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 26 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN (TSC.TSC_CODE = 50 OR TSC.TSC_CODE = 250) THEN ''BILLS PAYMENT''
	    WHEN (TSC.TSC_CODE = 52 OR TSC.TSC_CODE = 252) THEN ''PREPAID AUTO RELOAD''
	    WHEN (TSC.TSC_CODE = 146 OR TSC.TSC_CODE = 246) THEN ''BEEP LOADING''
	    WHEN (TSC.TSC_CODE = 51 OR TSC.TSC_CODE = 251) THEN ''RFID LOADING''
            WHEN (TSC.TSC_CODE = 42 AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''Inter-Entity Transfer (CBC to CBS or CBS to CBC)''
	    ELSE TSC.TSC_DESCRIPTION 
	    END AS "TRANSACTION TYPE",
	  TXN.TRL_SYSTEM_TIMESTAMP "DATE",
	  TXN.TRL_SYSTEM_TIMESTAMP "TIME",
	  TXN.TRL_DEST_STAN "SEQ NO",
	  SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NO",
	  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END "TRAN MNEM",
	  CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE ''DF'' END AS "TRAN TYPE",
	  CBA.CBA_MNEM "BANK MNEM",
	  TXN.TRL_PAN "CARD NO",
	  TXN.TRL_PAN_EKY_ID "CARD NO_ENCKEY",
	  TXN.TRL_ACCOUNT_1_ACN_ID "ACC NO",
	  TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID "ACC NO_ENCKEY",
	  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN (TXN.TRL_AMT_TXN * -1) ELSE NVL(TXN.TRL_AMT_TXN,0) END "TRANS AMOUNT",
	  TXN.TRL_ACQ_CHARGE_AMT "TRAN FEE",
	  CASE WHEN (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0) THEN ''000 - Full Reversal'' ELSE (TXN.TRL_ACTION_RESPONSE_CODE || '' - '' || ARC.ARC_NAME) END "REMARKS"
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	  LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE 
	    AND CTR.CTR_CHANNEL = CASE WHEN (TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''I-CDM'' ELSE ''CDM'' END
	    AND CTR_DEBIT_CREDIT = ''DEBIT''
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
          LEFT JOIN CBC_BANK CBAA ON CBAA.CBA_CODE = TXN.TRL_FRD_REV_INST_ID
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	where 
	  TXN.TRL_TQU_ID in (''F'', ''R'')
	  AND TXN.TRL_TSC_CODE != 26
	  AND AST.AST_TERMINAL_TYPE = ''BRM''
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
	  AND {Txn_Date}
union all select 
	  (ABR.ABR_CODE || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(AST.AST_TERMINAL_ID, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
           CASE WHEN TXN.TRL_TSC_CODE IN (250,251,252,246)  THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=1 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    ELSE ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT''
	    END AS "TRANSACTION GROUP",
	  CASE WHEN TSC.TSC_CODE = 31 THEN ''BALANCE INQURY'' 
	    WHEN (TSC.TSC_CODE = 1 OR TSC.TSC_CODE = 128) THEN ''ATM WITHDRAWAL'' 
	    WHEN TSC.TSC_CODE = 142 THEN ''MOVING CASH - EMERGENCY CASH (NOW)''
	    WHEN TSC.TSC_CODE = 143 THEN ''MOVING CASH - PAY TO MOBILE (JUMP)''
	    WHEN TSC.TSC_CODE = 46 THEN ''INSTAPAY FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 47 THEN ''PESONET FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 26 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN (TSC.TSC_CODE = 50 OR TSC.TSC_CODE = 250) THEN ''BILLS PAYMENT''
	    WHEN (TSC.TSC_CODE = 52 OR TSC.TSC_CODE = 252) THEN ''PREPAID AUTO RELOAD''
	    WHEN (TSC.TSC_CODE = 146 OR TSC.TSC_CODE = 246) THEN ''BEEP LOADING''
	    WHEN (TSC.TSC_CODE = 51 OR TSC.TSC_CODE = 251) THEN ''RFID LOADING''
            WHEN (TSC.TSC_CODE = 42 AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''Inter-Entity Transfer (CBC to CBS or CBS to CBC)''
	    ELSE TSC.TSC_DESCRIPTION 
	    END AS "TRANSACTION TYPE",
	  TXN.TRL_SYSTEM_TIMESTAMP "DATE",
	  TXN.TRL_SYSTEM_TIMESTAMP "TIME",
	  TXN.TRL_DEST_STAN "SEQ NO",
	  SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NO",
	  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END "TRAN MNEM",
	  CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE ''DF'' END AS "TRAN TYPE",
	  CBA.CBA_MNEM "BANK MNEM",
	  TXN.TRL_PAN "CARD NO",
	  TXN.TRL_PAN_EKY_ID "CARD NO_ENCKEY",
	  TXN.TRL_ACCOUNT_1_ACN_ID "ACC NO",
	  TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID "ACC NO_ENCKEY",
	  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN (TXN.TRL_AMT_TXN * -1) ELSE NVL(TXN.TRL_AMT_TXN,0) END "TRANS AMOUNT",
	  TXN.TRL_ACQ_CHARGE_AMT "TRAN FEE",
	  (TXN.TRL_ACTION_RESPONSE_CODE || '' - '' || ARC.ARC_NAME) "REMARKS"
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE AND TXN.TRL_TSC_CODE = 26
	  LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE 
	    AND CTR.CTR_CHANNEL = CASE WHEN (TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''I-CDM'' ELSE ''CDM'' END
	    AND CTR_DEBIT_CREDIT = ''CREDIT''
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
          LEFT JOIN CBC_BANK CBAA ON CBAA.CBA_CODE = TXN.TRL_FRD_REV_INST_ID
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	where 
	  TXN.TRL_TQU_ID in (''F'', ''R'')
	  AND AST.AST_TERMINAL_TYPE = ''BRM''
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
	  AND {Txn_Date}
	order by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE", "DATE", "TIME"		
	');	
	i_TRAILER_QUERY := null;
	
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