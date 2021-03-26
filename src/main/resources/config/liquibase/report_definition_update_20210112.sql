DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- additional update
    -- update cbc_tran_code set ctr_channel='BNT' where ctr_channel='OB';
    -- insert into cbc_tran_code values((select max(ctr_id) + 1 from cbc_tran_code), '41','BNT','BXC','BXR','CREDIT',current_timestamp);
    -- update cbc_tran_code set ctr_debit_credit='DEBIT' where ctr_code='40' and ctr_channel='BNT' and ctr_mnem='BXD';
    -- update cbc_tran_code set ctr_debit_credit='CREDIT' where ctr_code='40' and ctr_channel='BNT' and ctr_mnem='BXC';

    -- temporary update to 1001
    -- update atm_branches set abr_code='1001';

-- ATM Transaction List (Issuer)
	i_BODY_QUERY := TO_CLOB('		
    SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      CBA.CBA_NAME "BANK NAME",
      CONCAT(LPAD(CBA.CBA_CODE, 4, ''0''),  TXN.TRL_CARD_ACPT_TERMINAL_IDENT) "ATM CODE",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, ''0'') "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
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
      JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
      JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_DEO_NAME IS NULL
      AND TXN.TRL_MCC_ID=6011
      AND {Iss_Name}
      AND {Bank_Code}
      AND {Txn_Date}
	ORDER BY
      CBA.CBA_NAME ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Transaction List (Issuer)';

-- ATM Transaction List (On-Us/Acquirer)
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
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
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
	
-- ATM Transaction List (Summary)	
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
	update REPORT_DEFINITION set RED_FILE_FORMAT='CSV,', RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Transaction List (Summary)';

-- Block Sheet Listing For Bills Payment
   i_BODY_QUERY := TO_CLOB('
   SELECT
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      TXN.TRL_AMT_TXN "DEBIT",
      0 AS "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION "DESCRIPTION"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLA.GLA_NUMBER,
      GLA.GLA_NAME,
      TXN.TRL_DEST_STAN,
      TXN.TRL_AMT_TXN,
      TXN.TRL_ACCOUNT_1_ACN_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_DEBIT_DESCRIPTION
	ORDER BY
      TXN.TRL_DEST_STAN ASC,
      GLE.GLE_DEBIT_DESCRIPTION DESC
	START SELECT
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_DEST_STAN "CODE",
      0 AS "DEBIT",
      TXN.TRL_AMT_TXN "CREDIT",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION "DESCRIPTION"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLA.GLA_NUMBER,
      GLA.GLA_NAME,
      TXN.TRL_DEST_STAN,
      TXN.TRL_AMT_TXN,
      TXN.TRL_ACCOUNT_1_ACN_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      GLE.GLE_CREDIT_DESCRIPTION
	ORDER BY
      TXN.TRL_DEST_STAN ASC,
      GLE.GLE_CREDIT_DESCRIPTION DESC
	END
   ');	
   
    i_TRAILER_QUERY := TO_CLOB('
    SELECT
      SUM(TXN.TRL_AMT_TXN) "TOTAL DEBIT",
      0 AS "TOTAL CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLE.GLE_DEBIT_DESCRIPTION
	ORDER BY
      GLE.GLE_DEBIT_DESCRIPTION DESC
	START SELECT
      0 AS "TOTAL DEBIT",
     SUM(TXN.TRL_AMT_TXN) "TOTAL CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID 
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND {GL_Description}
      AND {Txn_Date}
	GROUP BY
      GLE.GLE_CREDIT_DESCRIPTION
	ORDER BY
      GLE.GLE_CREDIT_DESCRIPTION DESC
	END
    ');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY  where RED_NAME = 'Block Sheet Listing For Bills Payment';


-- Final Proof Sheet For Bills Payment
	i_BODY_QUERY := TO_CLOB('		
    SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
	FROM(
	SELECT
      GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_AMT_TXN "DEBITS",
      0 AS "CREDITS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND {GL_Description}
      AND {Txn_Date}
	)
	GROUP BY
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
	ORDER BY
     "Tran Particular" DESC
	START SELECT
      SUM("DEBITS") "DEBITS",
      SUM("CREDITS") "CREDITS",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME",
      "Tran Particular"
	FROM(
	SELECT
      GLE.GLE_CREDIT_DESCRIPTION "Tran Particular",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      0 AS "DEBITS",
      TXN.TRL_AMT_TXN "CREDITS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
	WHERE
      TXN.TRL_TSC_CODE = 50
      AND TXN.TRL_TQU_ID IN (''A'', ''F'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND {Channel}
      AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Bills Payment'')
      AND {GL_Description}
      AND {Txn_Date}
	)
	GROUP BY
    "GL ACCOUNT NUMBER",
    "GL ACCOUNT NAME",
    "Tran Particular"
	ORDER BY
     "Tran Particular" DESC
	END
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Final Proof Sheet For Bills Payment';

END;
/