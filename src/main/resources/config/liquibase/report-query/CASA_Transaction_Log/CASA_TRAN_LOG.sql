-- Tracking					Date			Name	Description
-- CBCAXUPISSLOG-686		18-JUN-2021		WY		Filter out IBFT tran from tran code 1

DECLARE

	i_BODY_QUERY CLOB;
	i_BODY_FIELD CLOB;

BEGIN 
	  
	  i_BODY_QUERY := TO_CLOB('
	SELECT
      SUBSTR(LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0''), -4) "ACQUIRER BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
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
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009997'') AND TXN.TRL_TQU_ID = ''F'' THEN ''SAL''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009997'') AND TXN.TRL_TQU_ID = ''R'' THEN ''SLR''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000009991'' AND TXN.TRL_TQU_ID = ''F'' THEN ''ESH''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000009991'' AND TXN.TRL_TQU_ID = ''R'' THEN ''ESC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009991'', ''0000009997'') THEN TXN.TRL_CARD_ACPT_TERMINAL_IDENT ELSE ''0'' END AS "MERCHANT ID",
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') NOT IN (''0000000010'', ''0000000112'')
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC');  
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'CASA (Issuer)';
	  
	  i_BODY_QUERY := TO_CLOB('SELECT
      SUBSTR(LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0''), -4) "ACQUIRER BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
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
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009997'') AND TXN.TRL_TQU_ID = ''F'' THEN ''SAL''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009997'') AND TXN.TRL_TQU_ID = ''R'' THEN ''SLR''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000009991'' AND TXN.TRL_TQU_ID = ''F'' THEN ''ESH''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000009991'' AND TXN.TRL_TQU_ID = ''R'' THEN ''ESC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009991'', ''0000009997'') THEN TXN.TRL_CARD_ACPT_TERMINAL_IDENT ELSE ''0'' END AS "MERCHANT ID",
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000000010''
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'CASA (On-Us)';
	  
	  i_BODY_QUERY := TO_CLOB('SELECT
      SUBSTR(LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0''), -4) "ACQUIRER BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
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
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009997'') AND TXN.TRL_TQU_ID = ''F'' THEN ''SAL''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009997'') AND TXN.TRL_TQU_ID = ''R'' THEN ''SLR''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000009991'' AND TXN.TRL_TQU_ID = ''F'' THEN ''ESH''
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000009991'' AND TXN.TRL_TQU_ID = ''R'' THEN ''ESC''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009991'', ''0000009997'') THEN TXN.TRL_CARD_ACPT_TERMINAL_IDENT ELSE ''0'' END AS "MERCHANT ID",
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128, 40, 42, 43, 44, 45, 50, 52) OR (TXN.TRL_TSC_CODE = 1 AND 
      (TXN.TRL_FRD_REV_INST_ID IS NULL OR TXN.TRL_FRD_REV_INST_ID IN (''8882'', ''0000008882''))))
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000000112''
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'CASA (Inter-Entity)';
	  
END;
/