-- Tracking					Date			Name	Description
-- CBCAXUPISSLOG-686		18-JUN-2021		WY		Filter out IBFT tran from tran code 1

DECLARE

	i_BODY_QUERY CLOB;

BEGIN 
	  
	  i_BODY_QUERY := TO_CLOB('
	SELECT
      CBA.CBA_CODE "ISSUER BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''F'' THEN ''CWD''
               WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''R'' THEN ''CWC''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''F'' THEN ''TFR''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''R'' THEN ''TFC''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''F'' THEN ''BPS''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''R'' THEN ''BPC''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''F'' THEN ''IBF''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''R'' THEN ''IBC''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''F'' THEN ''ELD''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''R'' THEN ''ELC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      TXN.TRL_ACTION_RESPONSE_CODE "RESPONSE CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "EDP TIME",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))
	  AND TRL_MCC_ID = ''6011'' AND TXN.TRL_AMT_TXN - FLOOR(TXN.TRL_AMT_TXN) = 0))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME =  {V_Iss_Name}
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC');  
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'SWIT (Issuer)';
	  
	  i_BODY_QUERY := TO_CLOB('SELECT
      CBA.CBA_CODE "ISSUER BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''F'' THEN ''CWD''
               WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''R'' THEN ''CWC''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''F'' THEN ''TFR''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''R'' THEN ''TFC''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''F'' THEN ''BPS''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''R'' THEN ''BPC''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''F'' THEN ''IBF''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''R'' THEN ''IBC''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''F'' THEN ''ELD''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''R'' THEN ''ELC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      TXN.TRL_ACTION_RESPONSE_CODE "RESPONSE CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "EDP TIME",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))
	  AND TRL_MCC_ID = ''6011'' AND TXN.TRL_AMT_TXN - FLOOR(TXN.TRL_AMT_TXN) = 0))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id}
	  AND TXN.TRL_ISS_NAME IS NULL
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'SWIT (Acquirer)';
	  
	   i_BODY_QUERY := TO_CLOB('SELECT
      CBA.CBA_CODE "ISSUER BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''F'' THEN ''CWD''
               WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''R'' THEN ''CWC''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''F'' THEN ''TFR''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''R'' THEN ''TFC''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''F'' THEN ''BPS''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''R'' THEN ''BPC''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''F'' THEN ''IBF''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''R'' THEN ''IBC''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''F'' THEN ''ELD''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''R'' THEN ''ELC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      TXN.TRL_ACTION_RESPONSE_CODE "RESPONSE CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "EDP TIME",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
     (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))
	  AND TRL_MCC_ID = ''6011'' AND TXN.TRL_AMT_TXN - FLOOR(TXN.TRL_AMT_TXN) = 0))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME =  {V_Iss_Name}
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'SWIT (On-Us)';
	  
	  i_BODY_QUERY := TO_CLOB('
	  SELECT * FROM(
	  SELECT
      CBA.CBA_CODE "ISSUER BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''F'' THEN ''CWD''
               WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''R'' THEN ''CWC''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''F'' THEN ''TFR''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''R'' THEN ''TFC''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''F'' THEN ''BPS''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''R'' THEN ''BPC''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''F'' THEN ''IBF''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''R'' THEN ''IBC''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''F'' THEN ''ELD''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''R'' THEN ''ELC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      TXN.TRL_ACTION_RESPONSE_CODE "RESPONSE CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "EDP TIME",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
     (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))
	  AND TRL_MCC_ID = ''6011'' AND TXN.TRL_AMT_TXN - FLOOR(TXN.TRL_AMT_TXN) = 0))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME =  {V_IE_Acqr_Inst_Id}
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id}
      AND {Txn_Date}
UNION
	SELECT
      CBA.CBA_CODE "ISSUER BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''F'' THEN ''CWD''
               WHEN TXN.TRL_TSC_CODE IN (1, 128) AND TXN.TRL_TQU_ID = ''R'' THEN ''CWC''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''F'' THEN ''TFR''
               WHEN TXN.TRL_TSC_CODE IN (40, 42, 43, 45) AND TXN.TRL_TQU_ID = ''R'' THEN ''TFC''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''F'' THEN ''BPS''
               WHEN TXN.TRL_TSC_CODE = 50 AND TXN.TRL_TQU_ID = ''R'' THEN ''BPC''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''F'' THEN ''IBF''
               WHEN TXN.TRL_TSC_CODE = 44 AND TXN.TRL_FRD_REV_INST_ID NOT IN (''8882'', ''0000008882'') AND TXN.TRL_TQU_ID = ''R'' THEN ''IBC''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''F'' THEN ''ELD''
               WHEN TXN.TRL_TSC_CODE = 52 AND TXN.TRL_TQU_ID = ''R'' THEN ''ELC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      TXN.TRL_ACTION_RESPONSE_CODE "RESPONSE CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "EDP TIME",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
     (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))
	  AND TRL_MCC_ID = ''6011'' AND TXN.TRL_AMT_TXN - FLOOR(TXN.TRL_AMT_TXN) = 0))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME =  {V_Iss_Name}
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}
      AND {Txn_Date})
ORDER BY
       "EDP TIME" ASC,
      "TRACE NUMBER" ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'SWIT (Inter-Entity)';
	  
END;
/