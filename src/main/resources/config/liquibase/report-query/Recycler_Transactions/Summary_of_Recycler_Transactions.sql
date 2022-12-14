-- Tracking				Date			Name	Description
-- Report revision		15-JUL-2021		NY		Initial from UAT environment
-- Report revision		23-JUL-2021		NY		Update based on excel spec
-- Report revision		24-JUL-2021		NY		Separate update query to CBC/CBS report definition
-- Rel-20210730			28-JUL-2021		KW		Fix Recycler transaction summary
-- Rel-20210920			20-SEP-2021		NY		Move recycler to branch report
-- CBCAXUPISSLOG-946	30-SEP-2021		KW		Fix Total deposit count
-- CBCAXUPISSLOG-1167   27-JUL-2022		LJL		Revise Branch Code/ Terminal / ATM_Branchs table

DECLARE
    i_REPORT_NAME VARCHAR2(100) := 'Summary of Recycler Transactions';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Summary of Recycler Transactions

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SUMMARY OF RECYCLER TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"19","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","csvTxtLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":12,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":15,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":16,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":19,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":true}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"19","fieldName":"BRANCH","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"20","fieldName":"TERMINAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"21","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"1","fieldName":"Transaction","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRANSACTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"2","fieldName":"On-us","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ON-US /","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"3","fieldName":"Description","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DESCRIPTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"4","fieldName":"Inter-branch","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INTER-BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"5","fieldName":"Inter-Entity","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INTER-ENTITY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","fieldName":"Other Banks","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"OTHER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"7","fieldName":"Cash Card","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CASH CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"8","fieldName":"Total Dispensed","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"9","fieldName":"Total Deposit","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DEPOSIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"10","fieldName":"Net Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NET-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"11","fieldName":"TRANSACTION TYPE","csvTxtLength":"","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false,"defaultValue":""},{"sequence":15,"sectionName":"12","fieldName":"ONUS","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":16,"sectionName":"13","fieldName":"INTER ENTITY","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":17,"sectionName":"14","fieldName":"OTHER BANKS","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":18,"sectionName":"15","fieldName":"CASH CARD","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":19,"sectionName":"16","fieldName":"TOTAL DISPENSED","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":20,"sectionName":"17","fieldName":"TOTAL DEPOSIT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SUMMARY OF RECYCLER TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"19","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","csvTxtLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":12,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":15,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":16,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":19,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":true}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"19","fieldName":"BRANCH","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"20","fieldName":"TERMINAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"21","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"1","fieldName":"Transaction","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRANSACTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"2","fieldName":"On-us","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ON-US /","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"3","fieldName":"Description","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DESCRIPTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"4","fieldName":"Inter-branch","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INTER-BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"5","fieldName":"Inter-Entity","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INTER-ENTITY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","fieldName":"Other Banks","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"OTHER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"7","fieldName":"Cash Card","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CASH CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"8","fieldName":"Total Dispensed","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"9","fieldName":"Total Deposit","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DEPOSIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"10","fieldName":"Net Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NET-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"11","fieldName":"TRANSACTION TYPE","csvTxtLength":"","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false,"defaultValue":""},{"sequence":15,"sectionName":"12","fieldName":"ONUS","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":16,"sectionName":"13","fieldName":"INTER ENTITY","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":17,"sectionName":"14","fieldName":"OTHER BANKS","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":18,"sectionName":"15","fieldName":"CASH CARD","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":19,"sectionName":"16","fieldName":"TOTAL DISPENSED","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":20,"sectionName":"17","fieldName":"TOTAL DEPOSIT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
		
	i_BODY_QUERY := TO_CLOB('
select 
  	  BRANCH,
	  TERMINAL,
	  "TRANSACTION GROUP",
	  "TRANSACTION TYPE",
	  SUM(CASE WHEN TRL_TSC_CODE != 48 AND TRL_ISS_NAME = {V_Iss_Name} AND CPD_CODE NOT IN (''81'',''83'') THEN NVL("TRANS AMOUNT",0) ELSE 0 END) AS "ONUS",
	  SUM(CASE WHEN (TRL_TSC_CODE = 48 OR TRL_ISS_NAME = {V_IE_Iss_Name}) AND CPD_CODE NOT IN (''81'',''83'') THEN NVL("TRANS AMOUNT",0) ELSE 0 END) AS "INTER ENTITY",
	  SUM(CASE WHEN TRL_ISS_NAME IS NULL THEN NVL("TRANS AMOUNT",0) ELSE 0 END) AS "OTHER BANKS",
	  SUM(CASE WHEN CPD_CODE IN (''81'',''83'') THEN NVL("TRANS AMOUNT",0) ELSE 0 END) AS "CASH CARD",
	  SUM(CASE WHEN TRL_TSC_CODE IN (1,128,142,143) THEN NVL("TRANS AMOUNT",0) ELSE 0 END) AS "TOTAL DISPENSED",
	  SUM(CASE WHEN TRL_TSC_CODE = 26 THEN NVL("TRANS AMOUNT",0) ELSE 0 END) AS "TOTAL DEPOSIT"
	FROM (
    select 
	  (SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
           CASE WHEN TXN.TRL_TSC_CODE IN (250,251,252,246)  THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND TXN.TRL_TSC_CODE < 40 AND TXN.TRL_TSC_CODE > 49 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
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
        WHEN ((TSC.TSC_CODE = 42 OR TSC.TSC_CODE = 40) AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''Inter-Entity Transfer (CBC to CBS or CBS to CBC)''
	    ELSE TSC.TSC_DESCRIPTION 
	    END AS "TRANSACTION TYPE",
	  CASE WHEN TXN.TRL_TSC_CODE = 122 AND TXN.TRL_TQU_ID = ''F'' THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) 
	    ELSE NVL(TXN.TRL_AMT_TXN, 0) END "TRANS AMOUNT",
	  TXN.TRL_TSC_CODE as TRL_TSC_CODE,
      TXN.TRL_ISS_NAME as TRL_ISS_NAME,
      CPD.CPD_CODE as CPD_CODE,
      TXN.TRL_FRD_REV_INST_ID as TRL_FRD_REV_INST_ID
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	  LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE 
	    AND CTR.CTR_CHANNEL = CASE WHEN (TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''I-CDM'' 
	    	WHEN (TXN.TRL_TSC_CODE not in (145,146) and TXN.TRL_ISS_NAME IS NULL) THEN ''BNT'' 
	    	ELSE ''CDM'' END
	    AND CTR_DEBIT_CREDIT = ''DEBIT''
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	  LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
	  JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	where 
	  TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND TXN.TRL_TSC_CODE != 26
	  AND TXNC.TRL_ORIGIN_CHANNEL = ''BRM''
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      AND SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = {BRANCH_CODE}
	  AND {Txn_Date}
union all select 
	  (SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
           CASE WHEN TXN.TRL_TSC_CODE IN (250,251,252,246)  THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND TXN.TRL_TSC_CODE < 40 AND TXN.TRL_TSC_CODE > 49 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
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
        WHEN ((TSC.TSC_CODE = 42 OR TSC.TSC_CODE = 40) AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''Inter-Entity Transfer (CBC to CBS or CBS to CBC)''
	    ELSE TSC.TSC_DESCRIPTION 
	    END AS "TRANSACTION TYPE",
	  CASE WHEN TXN.TRL_TSC_CODE = 122 AND TXN.TRL_TQU_ID = ''F'' THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) 
	    ELSE NVL(TXN.TRL_AMT_TXN, 0) END "TRANS AMOUNT",
	  TXN.TRL_TSC_CODE as TRL_TSC_CODE,
      TXN.TRL_ISS_NAME as TRL_ISS_NAME,
      CPD.CPD_CODE as CPD_CODE,
      TXN.TRL_FRD_REV_INST_ID as TRL_FRD_REV_INST_ID
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE AND TXN.TRL_TSC_CODE IN (21,26,40,41,42,43,44,45,48,49)
	  LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE 
	    AND CTR.CTR_CHANNEL = CASE WHEN (TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN ''I-CDM'' ELSE ''CDM'' END
	    AND CTR_DEBIT_CREDIT = ''CREDIT''
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	  LEFT JOIN ACCOUNT ACN on ACN.ACN_ACCOUNT_NUMBER = (CASE WHEN TXN.TRL_TSC_CODE = 21 THEN TXN.TRL_ACCOUNT_1_ACN_ID ELSE TXN.TRL_ACCOUNT_2_ACN_ID END)
	  LEFT JOIN ISSUER ISS on ISS.ISS_ID = ACN.ACN_ISS_ID
	  LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
	  JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	where 
	  TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND TXNC.TRL_ORIGIN_CHANNEL = ''BRM''
	  AND (TXN.TRL_TSC_CODE IN (21,26) OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_Acqr_Inst_Id} OR ISS.ISS_NAME = {V_Iss_Name})
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      AND SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = {BRANCH_CODE}
	  AND {Txn_Date}
	)
	group by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"
	order by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"		
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