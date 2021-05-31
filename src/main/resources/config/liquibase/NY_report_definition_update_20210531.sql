DECLARE
	i_BODY_QUERY CLOB;
BEGIN 

-- ATM Transaction List (On-Us/Acquirer)
	i_BODY_QUERY := TO_CLOB('		
	  SELECT * FROM(
SELECT
      DISTINCT TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, ''0'') "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_TSC_CODE IN (SELECT CTR_CODE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = ''BNT'')
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT in (''DEBIT'', ''CREDIT'') AND ROWNUM=1)
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_TQU_ID != ''R'' AND TXN.TRL_TSC_CODE IN (SELECT CTR_CODE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = ''BNT'')
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT in (''DEBIT'', ''CREDIT'') AND ROWNUM=1)
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
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_MCC_ID = 6011
	  AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date})
	ORDER BY
      "BRANCH CODE" ASC,
      "BRANCH NAME" ASC,
      "TERMINAL" ASC,
      "DATE" ASC,
      "TIME" ASC,
      "SEQ NUMBER" ASC
	');
	
	UPDATE REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Transaction List (On-Us/Acquirer)';
	
END;
/