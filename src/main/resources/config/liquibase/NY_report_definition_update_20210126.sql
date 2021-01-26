DECLARE
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- (EFDLY001) ATM Transaction List (On-Us/Acquirer)
	i_BODY_QUERY := TO_CLOB('		
	SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, ''0'') "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID <> ''R'' 
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN CTR.CTR_REV_MNEM
    	ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TO ACC TYPE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_MCC_ID = 6011
      AND {Deo_Name}
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
	
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Transaction List (On-Us/Acquirer)';

-- (EFDLY003) ATM Transaction List (Summary)
	i_BODY_QUERY := TO_CLOB('		
	SELECT
      "TRAN MNEM",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      SUM("SHORT DISP") "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL/INS PAYMENTS") "BILL/INS PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
	FROM (
	SELECT
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_POST_COMPLETION_CODE = ''R'' 
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT=''DEBIT'')
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_POST_COMPLETION_CODE IS NULL
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT=''DEBIT'')
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_POST_COMPLETION_CODE = ''R'' 
	        THEN CTR.CTR_REV_MNEM 
		ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_POST_COMPLETION_CODE IS NULL THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 100 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_MCC_ID = 6011
      AND {Deo_Name}
      AND {Txn_Date}
	)
	GROUP BY
      "TRAN MNEM"
	ORDER BY
      "TRAN MNEM" ASC
	START SELECT 
      "TRAN MNEM",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      SUM("SHORT DISP") "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL/INS PAYMENTS") "BILL/INS PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
	FROM (
	SELECT
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_POST_COMPLETION_CODE IS NULL THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 100 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 and TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_MCC_ID = 6011
      AND TXN.TRL_DEO_NAME IS NULL
      AND {Iss_Name}
      AND {Txn_Date}
	)
	GROUP BY
      "TRAN MNEM"
	ORDER BY
      "TRAN MNEM" ASC
	END	
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Transaction List (Summary)';
	
-- (TRAN) Transaction Count Report
	i_BODY_QUERY := TO_CLOB('
SELECT
      "DATE",
      "TERMINAL",
      "BANK MNEM",
      "TRAN MNEM",
      "BANK CODE",
      SUM("APPROVED TRAN COUNT") "APPROVED TRAN COUNT",
      SUM("REJECTED TRAN COUNT") "REJECTED TRAN COUNT",
      COUNT("TOTAL TRAN COUNT") "TOTAL TRAN COUNT",
      0 "SHORT DISPENSE COUNT",
      0 "NO DISPENSE COUNT",
      0 "OVER DISPENSE COUNT",
      0 "HARDWARE FAILURE COUNT",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL PAYMENTS") "BILL PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
FROM (
SELECT
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      CBA.CBA_MNEM "BANK MNEM",
      CASE 
		WHEN TXN.TRL_ISS_NAME IS NULL 
			THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CHANNEL=''BNT'' AND CTR_CODE=TXN.TRL_TSC_CODE AND CTR_DEBIT_CREDIT=''DEBIT'')
        ELSE CTR.CTR_MNEM END AS "TRAN MNEM", 
      LPAD(CBA.CBA_CODE, 4, 0) "BANK CODE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "APPROVED TRAN COUNT",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN 1 ELSE 0 END AS "REJECTED TRAN COUNT",
      TXN.TRL_ID "TOTAL TRAN COUNT",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 26) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE = 50 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 21, 26, 31, 40, 42, 43, 44, 45, 50, 52)
      AND TXN.TRL_TQU_ID = ''F''
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND {Txn_Date}
)
GROUP BY
      "DATE",
      "TERMINAL",
      "BANK MNEM",
      "TRAN MNEM",
      "BANK CODE"
ORDER BY
      "TRAN MNEM" ASC,
      "TERMINAL" ASC,
      "BANK CODE" ASC
	');
	
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Transaction Count Report';
	
-- (EFDLY004) ATM Withdrawal as Acquirer Bank
	i_BODY_QUERY := TO_CLOB('
	SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM AS "BANK MNEM",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID <> ''R'' 
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN CTR.CTR_REV_MNEM
	    ELSE CTR.CTR_MNEM END AS "TRAN MNEM", 
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TQU_ID != ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DR AMOUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CR AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F'' 
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Deo_Name}
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
	
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Withdrawal as Acquirer Bank';
	
-- EFT - ATM Transaction List (Other Banks)
	i_BODY_QUERY := TO_CLOB('
	SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
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
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID <> ''R'' 
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN CTR.CTR_REV_MNEM
	    ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TYPE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 31)
      AND TXN.TRL_TQU_ID = ''F'' 
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME IS NULL
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
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
	
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'EFT - ATM Transaction List (Other Banks)';

-- List of ATM Withdrawals Report
	i_BODY_QUERY := TO_CLOB('
    SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      CTR.CTR_CHANNEL "CHANNEL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID <> ''R'' 
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN CTR.CTR_REV_MNEM
	    ELSE CTR.CTR_MNEM END AS "TRAN MNEM", 	
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TYPE",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 142, 143)
      AND TXN.TRL_TQU_ID = ''F'' 
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND AST.AST_TERMINAL_TYPE IN (''ATM'', ''BRM'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
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
	
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'List of ATM Withdrawals Report';
	
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
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL 
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	    ELSE CTR.CTR_MNEM END AS "TRAN MNEM", 
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
	
-- Transaction Summary Grand Total for Other Banks
	i_BODY_QUERY := TO_CLOB('
	SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "TRAN MNEM",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      0 "DEPOSITS",
      0 "BILL/INS PAYMENTS",
      0 "LOAN PAYMENTS",
      0 "TRANSFERS"
	FROM (
	SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID <> ''R'' 
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_TQU_ID = ''R'' 
	        THEN CTR.CTR_REV_MNEM
	    ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 31)
      AND TXN.TRL_TQU_ID = ''F'' 
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME IS NULL
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
	)
	GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "TRAN MNEM"
	ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC,
      "TRAN MNEM" ASC	
	');
	
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Transaction Summary Grand Total for Other Banks';
	
END;
/