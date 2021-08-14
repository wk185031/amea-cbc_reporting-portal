-- Tracking					Date			Name	Description
-- Release-20210814			13-AUG-2021		KW		Revise CASA

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
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN ''SLR'' ELSE ''SAL''
      END AS "TRANSACTION CODE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_DEST_STAN "TRACE NUMBER",
      SUBSTR(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), -4) "RECEIVING BANK CODE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT AS "MERCHANT ID",
      CASE WHEN TXN.TRL_TSC_CODE = 50 THEN LPAD(TXNC.TRL_BILLER_CODE, 4, ''0'') END AS "BILLER CODE",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
WHERE
      TXN.TRL_MCC_ID = 6012
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_TSC_CODE = 0
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
	  ');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'CASA (POS)';
	  
END;
/