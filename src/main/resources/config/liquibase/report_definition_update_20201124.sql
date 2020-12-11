DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 
-- EFT - ATM Transaction List (Other Branch)
  
  i_BODY_QUERY := TO_CLOB('SELECT
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
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
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
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 31)
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND CPD.CPD_NAME NOT IN (''CASH CARD'', ''EMV CASH CARD'')
      AND ABR.ABR_CODE != TXNC.TRL_CARD_BRANCH
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC'
  );

  update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'EFT - ATM Transaction List (Other Branch)';

-- POS Transactions as Cardholder Branch
  i_BODY_QUERY := TO_CLOB('
  	SELECT
  	  TXN.TRL_TQU_ID "TXN QUALIFIER",
      TRIM(SUBSTR(TXN.TRL_CARD_ACPT_NAME_LOCATION, 1, 25)) "MERCHANT NAME",
      BRC.BRC_CODE "BRANCH CODE",
      BRC.BRC_NAME "BRANCH NAME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CRD.CRD_CARDHOLDER_NAME "ACCOUNT NAME",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      ''POS'' "TRAN MNEM",
      TXN.TRL_AMT_TXN "AMOUNT",
      MER.MER_CUSTOM_DATA "CUSTOM DATA"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC on TXN.TRL_ID = TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
      JOIN MERCHANT MER ON TRIM(SUBSTR(TXN.TRL_CARD_ACPT_NAME_LOCATION, 1, 25)) = MER.MER_NAME
	WHERE
      LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009991'', ''0000009997'')
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '''') != ''R''
      AND {Branch_Code}
      AND {Merchant}
      AND {Txn_Date}
	ORDER BY
      TXN.TRL_CARD_ACPT_NAME_LOCATION ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
  ');
  
  i_TRAILER_QUERY := TO_CLOB('
    SELECT
      TRIM(SUBSTR(TXN.TRL_CARD_ACPT_NAME_LOCATION, 1, 25)) "MERCHANT NAME",
      CASE WHEN TXN.TRL_TQU_ID = ''F'' THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "TRAN COUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "REV TRAN COUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''F'' THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "AMOUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "REV AMOUNT",
      MER.MER_CUSTOM_DATA "CUSTOM DATA"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC on TXN.TRL_ID = TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
      JOIN MERCHANT MER ON TRIM(SUBSTR(TXN.TRL_CARD_ACPT_NAME_LOCATION, 1, 25)) = MER.MER_NAME
	WHERE
      LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009991'', ''0000009997'')
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '''') != ''R''
      AND {Branch_Code}
      AND {Merchant}
      AND {Txn_Date}
	GROUP BY
      TXN.TRL_CARD_ACPT_NAME_LOCATION,
      TXN.TRL_TQU_ID,
      MER.MER_CUSTOM_DATA
	ORDER BY
      TXN.TRL_CARD_ACPT_NAME_LOCATION ASC
  ');

   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY where RED_NAME = 'POS Transactions as Cardholder Branch';	
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'POS Transactions as Cardholder Branch';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'POS Transactions as Cardholder Branch';
   update report_definition set red_trailer_fields=replace(red_trailer_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'POS Transactions as Cardholder Branch';

-- Inter-Entity Approved IBFT Transactions as Receiving Bank
  i_BODY_QUERY := TO_CLOB('SELECT
      CBA.CBA_CODE "BANK CODE",
      CBA.CBA_NAME "BANK NAME",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	WHERE
      TXNC.TRL_IS_INTER_ENTITY = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''     
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Bank_Code}
      AND {Txn_Date}
	ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
	START SELECT
      CBA.CBA_CODE "BANK CODE",
      CBA.CBA_NAME "BANK NAME",
      COUNT(TXN.TRL_ID) "TRAN COUNT",
      SUM(TXN.TRL_AMT_TXN) "AMOUNT",
      COUNT(TXN.TRL_ID) * 5.00 "RECEIVING INCOME"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	WHERE
      TXNC.TRL_IS_INTER_ENTITY = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Txn_Date}
	GROUP BY
      CBA.CBA_CODE,
      CBA.CBA_NAME
	ORDER BY
      CBA.CBA_CODE ASC
	END');
	
  i_TRAILER_QUERY := TO_CLOB('SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	WHERE
      TXNC.TRL_IS_INTER_ENTITY = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Bank_Code}
      AND {Txn_Date}
	START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT",
      SUM(5.00 * COUNT(TXN.TRL_ID)) AS "RECEIVING INCOME"
	FROM
      TRANSACTION_LOG TXN 
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	WHERE
      TXNC.TRL_IS_INTER_ENTITY = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND {Txn_Date}
	GROUP BY
      TXN.TRL_AMT_TXN,
      TXN.TRL_ID
	END');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Receiving Bank';
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Receiving Bank';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Receiving Bank';
   update report_definition set red_trailer_fields=replace(red_trailer_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Receiving Bank';
   
-- Inter-Entity Approved IBFT Transactions as Acquiring Bank
  i_BODY_QUERY := TO_CLOB('SELECT
      ''CBC'' AS "ACQUIRER BANK MNEM",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ISS_NAME AS "ISSUER BANK MNEM",
	  '' '' AS "ISSUER BRANCH NAME",
	  '' '' AS "RECEIVING BANK MNEM",
	  '' '' AS "RECEIVING BRANCH NAME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID
	FROM
	      TRANSACTION_LOG TXN
		  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	WHERE
	      TXNC.TRL_IS_INTER_ENTITY = 1
	      AND TXN.TRL_TQU_ID = ''F''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000000010''
	      AND TXN.TRL_ISS_NAME != ''CBC''
	      AND {Txn_Date}
	ORDER BY
	      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
	      TXN.TRL_SYSTEM_TIMESTAMP ASC,
	      TXN.TRL_DEST_STAN ASC
	START SELECT
	      "BRANCH CODE",
	      "BRANCH NAME",
	      "TERMINAL",
	      "LOCATION",
	      "ONLINE RETAIL COUNT",
	      "ONLINE RETAIL",
	      "ONLINE CORPORATE COUNT",
	      "ONLINE CORPORATE",
	      "ATM COUNT",
	      "ATM",
	      "IVRS COUNT",
	      "IVRS",
	      "TOTAL COUNT",
	      SUM("ONLINE RETAIL" + "ONLINE CORPORATE" + "ATM" + "IVRS") "TOTAL"
	FROM(
	SELECT
	      "BRANCH CODE",
	      "BRANCH NAME",
	      "TERMINAL",
	      "LOCATION",
	      COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL COUNT",
	      5.00 * COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL",
	      COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE COUNT",
	      5.00 * COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE",
	      COUNT("ATM COUNT") "ATM COUNT",
	      5.00 * COUNT("ATM COUNT") "ATM",
	      COUNT("IVRS COUNT") "IVRS COUNT",
	      5.00 * COUNT("IVRS COUNT") "IVRS",
	      SUM(NVL("ONLINE RETAIL COUNT", 0) + NVL("ONLINE CORPORATE COUNT", 0) + NVL("ATM COUNT", 0) + NVL("IVRS COUNT", 0) ) "TOTAL COUNT"
	FROM (
	SELECT
	      BRC.BRC_CODE "BRANCH CODE",
	      BRC.BRC_NAME "BRANCH NAME",
	      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
	      AST.AST_ALO_LOCATION_ID "LOCATION",
	      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL=''EBK'' AND TXNC.TRL_IS_CORPORATE_CARD = 0 THEN 1 END AS "ONLINE RETAIL COUNT",
	      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL=''EBK'' AND TXNC.TRL_IS_CORPORATE_CARD = 1 THEN 1  END AS "ONLINE CORPORATE COUNT",
	      CASE WHEN TXN.TRL_MCC_ID = 6011 THEN 1 END AS "ATM COUNT",
	      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL=''IVRS'' THEN 1 END AS "IVRS COUNT"
	FROM
	      TRANSACTION_LOG TXN
		  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
	WHERE
	      TXNC.TRL_IS_INTER_ENTITY = 1
	      AND TXN.TRL_TQU_ID = ''F''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
		  AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000000010''
	      AND TXN.TRL_ISS_NAME != ''CBC''
	      AND {Branch_Code}
	      AND {Terminal}
	      AND {Txn_Date}
	)
	GROUP BY
	      "BRANCH CODE",
	      "BRANCH NAME",
	      "TERMINAL",
	      "LOCATION"
	)
	GROUP BY
	      "BRANCH CODE",
	      "BRANCH NAME",
	      "TERMINAL",
	      "LOCATION",
	      "ONLINE RETAIL COUNT",
	      "ONLINE RETAIL",
	      "ONLINE CORPORATE COUNT",
	      "ONLINE CORPORATE",
	      "ATM COUNT",
	      "ATM",
	      "IVRS COUNT",
	      "IVRS",
	      "TOTAL COUNT"
	ORDER BY
	      "BRANCH CODE" ASC,
	      "TERMINAL" ASC
	END');
	
  i_TRAILER_QUERY := TO_CLOB('SELECT
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM COUNT",
      "ATM",
      "IVRS COUNT",
      "IVRS",
      "TOTAL COUNT",
      SUM("ONLINE RETAIL" + "ONLINE CORPORATE" + "ATM" + "IVRS") "TOTAL"
FROM(
SELECT
      COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL COUNT",
      5.00 * COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL",
      COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE COUNT",
      5.00 * COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE",
      COUNT("ATM COUNT") "ATM COUNT",
      5.00 * COUNT("ATM COUNT") "ATM",
      COUNT("IVRS COUNT") "IVRS COUNT",
      5.00 * COUNT("IVRS COUNT") "IVRS",
      SUM(NVL("ONLINE RETAIL COUNT", 0) + NVL("ONLINE CORPORATE COUNT", 0) + NVL("IVRS COUNT", 0) + NVL("ATM COUNT", 0)) "TOTAL COUNT"
FROM (
SELECT
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL=''EBK'' AND TXNC.TRL_IS_CORPORATE_CARD = 0 THEN 1 END AS "ONLINE RETAIL COUNT",
	  CASE WHEN TXNC.TRL_ORIGIN_CHANNEL=''EBK'' AND TXNC.TRL_IS_CORPORATE_CARD = 1 THEN 1  END AS "ONLINE CORPORATE COUNT",
	  CASE WHEN TXN.TRL_MCC_ID = 6011 THEN 1 END AS "ATM COUNT",
	  CASE WHEN TXNC.TRL_ORIGIN_CHANNEL=''IVRS'' THEN 1 END AS "IVRS COUNT"
FROM
      TRANSACTION_LOG TXN 
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
WHERE
	  TXNC.TRL_IS_INTER_ENTITY = 1
	  AND TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	  AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000000010''
	  AND TXN.TRL_ISS_NAME != ''CBC''
      AND {Txn_Date}
))
GROUP BY
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM COUNT",
      "ATM",
      "IVRS COUNT",
      "IVRS",
      "TOTAL COUNT"');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Acquiring Bank';
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Acquiring Bank';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Acquiring Bank';
   update report_definition set red_trailer_fields=replace(red_trailer_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Acquiring Bank';
  
-- Inter-Entity Approved IBFT Transactions as Transmitting Bank
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
		  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
	WHERE
	      TXNC.TRL_IS_INTER_ENTITY = 1
	      AND TXN.TRL_TQU_ID = ''F''
		  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	      AND TXN.TRL_ISS_NAME = ''CBC''
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
		  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	WHERE
	      TXNC.TRL_IS_INTER_ENTITY = 1
	      AND TXN.TRL_TQU_ID = ''F''
		  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	      AND TXN.TRL_ISS_NAME = ''CBC''
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
	      AND TXN.TRL_TQU_ID = ''F''
	      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	      AND TXN.TRL_ISS_NAME = ''CBC''
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
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	WHERE
	      TXNC.TRL_IS_INTER_ENTITY = 1
	      AND TXN.TRL_TQU_ID = ''F''
		  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	      AND TXN.TRL_ISS_NAME = ''CBC''
	      AND {IBFT_Criteria}
	      AND {Txn_Date}
	GROUP BY
	      TXN.TRL_AMT_TXN,
	      TXN.TRL_ID
	END
  ');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Transmitting Bank';
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Transmitting Bank';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Transmitting Bank';
   update report_definition set red_trailer_fields=replace(red_trailer_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Transmitting Bank';
 
  
  
  
  
  
-- Inter-Entity Summary of Approved IBFT Transactions Net Settlement
  i_BODY_QUERY := TO_CLOB('
  	START ISSUING
	SELECT
	      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
	      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
	      COUNT(TXN.TRL_ID) "TRANSMITTING COUNT",
	      SUM(TXN.TRL_AMT_TXN) "TRANSMITTING TOTAL",
	      0 "RECEIVING COUNT",
	      0 "RECEIVING TOTAL"
	FROM
	      TRANSACTION_LOG TXN
		  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
	WHERE
	      TXNC.TRL_IS_INTER_ENTITY = 1
	      AND TXN.TRL_TQU_ID = ''F''
		  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	      AND TXN.TRL_ISS_NAME = ''CBC''
	      AND {Bank_Code}
	      AND {Txn_Date}
	GROUP BY
	      TXN.TRL_FRD_REV_INST_ID
	ORDER BY
	      "BANK NAME" ASC
	END ISSUING
	START RECEIVING
	SELECT
	      CBA.CBA_CODE "BANK CODE",
	      CBA.CBA_NAME "BANK NAME",
	      0 "TRANSMITTING COUNT",
	      0 "TRANSMITTING TOTAL",
	      COUNT(TXN.TRL_ID) "RECEIVING COUNT",
	      SUM(TXN.TRL_AMT_TXN) "RECEIVING TOTAL"
	FROM
	      TRANSACTION_LOG TXN
	      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	WHERE
	      TXNC.TRL_IS_INTER_ENTITY = 1
	      AND TXN.TRL_TQU_ID = ''F''
		  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
		  AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	      AND TXN.TRL_ISS_NAME != ''CBC''
	      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000000010''
	      AND {Bank_Code}
	      AND {Txn_Date}
	GROUP BY
	      CBA.CBA_CODE,
	      CBA.CBA_NAME
	ORDER BY
	      "BANK NAME" ASC
	END RECEIVING
  ');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Inter-Entity Summary of Approved IBFT Transactions Net Settlement';
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Summary of Approved IBFT Transactions Net Settlement';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Summary of Approved IBFT Transactions Net Settlement'; 
    
-- Cash Card Withdrawals per Channel
   i_BODY_QUERY := TO_CLOB('
   	SELECT
    	"CHANNEL",
      	COUNT("TOTAL TXN COUNT") "TOTAL TXN COUNT",
      	SUM("TOTAL TXN AMT") "TOTAL TXN AMT",
      	SUM("TOTAL TXN AMT")/COUNT("TOTAL TXN COUNT") "AVE TXN AMT"
	FROM (
		SELECT
      		CASE WHEN TXN.TRL_ORIGIN_ICH_NAME = ''NDC'' THEN ''ChinaBank ATM''
            WHEN TXN.TRL_ORIGIN_ICH_NAME = ''Bancnet_Interchange'' AND TXN.TRL_ACQR_INST_ID NOT IN (''9990'', ''0000009990'') THEN ''Other Bank ATM''
      		END AS "CHANNEL",
      		TXN.TRL_ID "TOTAL TXN COUNT",
      		TXN.TRL_AMT_TXN "TOTAL TXN AMT"
		FROM
      		TRANSACTION_LOG TXN
      		JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      		JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
		WHERE
      		CPD.CPD_NAME IN (''CASH CARD'', ''EMV CASH CARD'')
      		AND TXN.TRL_TSC_CODE IN (1, 128)
      		AND TXN.TRL_TQU_ID = ''F''
      		AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      		AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '''') != ''R''
      		AND TRL_MCC_ID = 6011
      		AND {Txn_Date}
		)
		GROUP BY
      		"CHANNEL"
		ORDER BY
      		"CHANNEL" ASC');
  
   	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Cash Card Withdrawals per Channel';
	
-- Cash Card POS Purchase Transactions
   i_BODY_QUERY := TO_CLOB('
   	SELECT
      "MERCHANT NAME",
      COUNT("TOTAL TXN COUNT") "TOTAL TXN COUNT",
      SUM("TOTAL TXN AMT") "TOTAL TXN AMT",
      SUM("TOTAL TXN AMT")/COUNT("TOTAL TXN COUNT") "AVE TXN AMT"
	  FROM (
		SELECT
      		SUBSTR(TXN.TRL_CARD_ACPT_NAME_LOCATION, 1, 25) "MERCHANT NAME",
      		TXN.TRL_ID "TOTAL TXN COUNT",
      		TXN.TRL_AMT_TXN "TOTAL TXN AMT"
		FROM
      		TRANSACTION_LOG TXN
      		JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      		JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
		WHERE
		    CPD.CPD_NAME IN (''CASH CARD'', ''EMV CASH CARD'')
      		AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') IN (''0000008883'', ''0000009991'', ''0000009997'')
      		AND TXN.TRL_TQU_ID = ''F''
      		AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      		AND coalesce(TRL_POST_COMPLETION_CODE, '''') != ''R''
      		AND {Txn_Date}
		)
		GROUP BY
      		"MERCHANT NAME"
		ORDER BY
      		"MERCHANT NAME" ASC
   	');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Cash Card POS Purchase Transactions';
		
-- Inter-Entity Issuer Balance Inquiry Transaction Fees
   i_BODY_QUERY := TO_CLOB('
   	SELECT
    	BRC.BRC_CODE "BRANCH CODE",
    	BRC.BRC_NAME "BRANCH NAME",
    	coalesce(COUNT(TXN.TRL_ID), 0) "TOTAL COUNT",
    	coalesce(SUM(TXN.TRL_ISS_CHARGE_AMT), 0) "TOTAL EXPENSE"
	FROM BRANCH BRC 
    	LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON BRC.BRC_CODE = TXNC.TRL_CARD_BRANCH
    	LEFT JOIN TRANSACTION_LOG TXN ON TXNC.TRL_ID = TXN.TRL_ID 
    		AND TXN.TRL_TSC_CODE = 31 
    		AND TXN.TRL_TQU_ID = ''F'' 
    		AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
    		AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R'' 
    		AND TXNC.TRL_IS_INTER_ENTITY = 1
    		AND  {Txn_Date}
   	GROUP BY
      BRC.BRC_CODE,
      BRC.BRC_NAME
	ORDER BY
      "BRANCH CODE" ASC			
   ');
   
   i_TRAILER_QUERY := TO_CLOB('
   	SELECT
      coalesce(COUNT(TXN.TRL_ID), 0) "TOTAL COUNT",
      coalesce(SUM(TXN.TRL_ISS_CHARGE_AMT), 0) "TOTAL EXPENSE"
	FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXNC.TRL_ID = TXN.TRL_ID 
	WHERE
      TXN.TRL_TSC_CODE = 31
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXNC.TRL_IS_INTER_ENTITY = 1
      AND {Txn_Date} 
   ');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY where RED_NAME = 'Inter-Entity Issuer Balance Inquiry Transaction Fees';
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Issuer Balance Inquiry Transaction Fees';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Issuer Balance Inquiry Transaction Fees';
   update report_definition set red_trailer_fields=replace(red_trailer_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Issuer Balance Inquiry Transaction Fees';
   
-- Inter-Entity Issuer ATM Withdrawal Expense
   i_BODY_QUERY := TO_CLOB('
   	SELECT
    	BRC.BRC_CODE "BRANCH CODE",
    	BRC.BRC_NAME "BRANCH NAME",
    	coalesce(COUNT(TXN.TRL_ID),0) "TOTAL COUNT",
    	coalesce(SUM(TXN.TRL_ISS_CHARGE_AMT),0) "TOTAL EXPENSE"
	FROM BRANCH BRC 
    	LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON BRC.BRC_CODE = TXNC.TRL_CARD_BRANCH
    	LEFT JOIN TRANSACTION_LOG TXN ON TXNC.TRL_ID = TXN.TRL_ID 
    		AND TXN.TRL_TSC_CODE IN (1,128) 
    		AND TXN.TRL_TQU_ID = ''F'' 
    		AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
    		AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R'' 
    		AND TXNC.TRL_IS_INTER_ENTITY = 1
    		AND  {Txn_Date}
   	GROUP BY
      BRC.BRC_CODE,
      BRC.BRC_NAME
	ORDER BY
      "BRANCH CODE" ASC			
   ');
   
   i_TRAILER_QUERY := TO_CLOB('
   SELECT
      coalesce(COUNT(TXN.TRL_ID), 0) "TOTAL COUNT",
      coalesce(SUM(TXN.TRL_ISS_CHARGE_AMT), 0) "TOTAL EXPENSE"
	FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXNC.TRL_ID = TXN.TRL_ID 
	WHERE
      TXN.TRL_TSC_CODE in (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND coalesce(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXNC.TRL_IS_INTER_ENTITY = 1
      AND {Txn_Date} 
   ');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY where RED_NAME = 'Inter-Entity Issuer ATM Withdrawal Expense';
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Issuer ATM Withdrawal Expense';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Issuer ATM Withdrawal Expense';
   update report_definition set red_trailer_fields=replace(red_trailer_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity Issuer ATM Withdrawal Expense';




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
      		BRC.BRC_NAME
		END RECEIVING			
   		');
  
   update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Inter-Entity IBFT Transaction Fees';
   update report_definition set red_header_fields=replace(red_header_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity IBFT Transaction Fees';
   update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity IBFT Transaction Fees';
   update report_definition set red_trailer_fields=replace(red_trailer_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'Inter-Entity IBFT Transaction Fees';


-- Issuer ATM Withdrawal Expense
   i_BODY_FIELD := TO_CLOB('
   	[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"BANCNET MEMBER BANKS","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BANCNET MEMBER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"defaultValue":"TOTAL INCOME"},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":13,"sectionName":"13","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":15,"sectionName":"15","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"eol":true}]		
   ');
 
   update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD where RED_NAME = 'Issuer ATM Withdrawal Expense';


-- Issuer Balance Inquiry Transaction Fees
   i_BODY_FIELD := TO_CLOB('
   	[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"BANCNET MEMBER BANKS","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BANCNET MEMBER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"SUBTOTAL INCOME","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL INCOME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"defaultValue":"TOTAL INCOME"},{"sequence":10,"sectionName":"10","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":14,"sectionName":"14","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"SUBTOTAL INCOME","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":17,"sectionName":"17","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"eol":true}]		
   ');
 
   update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD where RED_NAME = 'Issuer Balance Inquiry Transaction Fees';


-- DAYANG

-- List of Recycler Transactions
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"LIST OF CDM TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":12,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":15,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":16,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":19,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":true}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Seq No","csvTxtLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SEQ NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Trace No","csvTxtLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRANCE NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRAN MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"Tran Type","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRAN TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BANK MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"Card Number","csvTxtLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CARD NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Acc No","csvTxtLength":"10","defaultValue":"ACCOUNT NUMBER","bodyHeader":true},{"sequence":10,"sectionName":"10","fieldName":"Trans Amt","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRANS AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"Tran Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRAN FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"Tran Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRAN CODE/REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"DATE","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"dd/MM/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"TIME","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","fieldName":"SEQ NO.","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","fieldName":"TRACE NO","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"17","fieldName":"TRAN MNEM","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","fieldName":"TRAN TYPE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"19","fieldName":"BANK MNEM","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"20","fieldName":"CARD NO","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"21","fieldName":"ACC NO","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"22","fieldName":"TRANS AMT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"23","fieldName":"TRAN FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"24","fieldName":"TRAN CODE","csvTxtLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space1"},{"sequence":2,"sectionName":"2","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space2"},{"sequence":3,"sectionName":"3","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space3"},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space4"},{"sequence":5,"sectionName":"5","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space5"},{"sequence":6,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space6"},{"sequence":7,"sectionName":"7","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space7"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space8"},{"sequence":9,"sectionName":"10","fieldName":"Over-All Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"OVER-ALL TOTAL DEBITS:","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"11","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space12"}]');

	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD  where RED_NAME = 'List of Recycler Transactions';
	

-- Summary of Recycler Transactions
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"LIST OF CDM TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Page","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"As of Date","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"AS OF DATE"},{"sequence":12,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"EFP000-0","eol":true},{"sequence":15,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","eol":false,"leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":16,"sectionName":"14","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"20","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","fieldName":"RunDate","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"defaultValue":"RUNDATE","firstField":false},{"sequence":19,"sectionName":"16","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"Time","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"Time Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"firstField":false,"eol":true}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Transaction","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRANSACTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"On-us","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ON-US /","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Description","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DESCRIPTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Inter-branch","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INTER-BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"Inter-Entity","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INTER-ENTITY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"Other Banks","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"OTHER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"Cash Card","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CASH CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"Total Dispensed","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"Total Deposit","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DEPOSIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"Net Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NET-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"TRANSACTION","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false},{"sequence":12,"sectionName":"12","fieldName":"INTER BRANCH","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"INTER ENTITY","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"OTHER BANKS","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","fieldName":"CASH CARD","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","fieldName":"TOTAL DISPENSED","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"17","fieldName":"TOTAL DEPOSIT","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","fieldName":"NET-TOTAL","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"","csvTxtLength":"","fieldType":"String","delimiter":"","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD where RED_NAME = 'Summary of Recycler Transactions';

-- Bills Payment Earnings  (Per Branch)
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILLS PAYMENT TRANSACTIONS AND INCOME (PER BRANCH AND TERMINAL)","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Terminal Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERMINAL NAME","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"","bodyHeader":true},{"sequence":6,"sectionName":"6","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":7,"sectionName":"7","fieldName":"Thru ATM","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true,"defaultValue":"THRU ATM"},{"sequence":8,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"Thru EBK","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Thru EBK","defaultValue":"THRU EBK"},{"sequence":12,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"Thru Tellerphone","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"THRU TELLERPHONE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"17","fieldName":"Thru Mobile","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"THRU MOBILE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"19","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"20","fieldName":"Thru Bancnet Online","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"THRU BANCNET ONLINE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"22","fieldName":"Total Amount","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL AMOUNT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"23","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"24","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"25","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"44","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"26","fieldName":"Issuer","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ISSUER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"27","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"28","fieldName":"Acquirer","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ACQUIRER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"29","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"30","fieldName":"Bill Amount","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILL AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"31","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"32","fieldName":"Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SHARE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"33","fieldName":"Bill Amount","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILL AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":35,"sectionName":"34","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"35","fieldName":"Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SHARE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":37,"sectionName":"36","fieldName":"Bill Amount","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILL AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":38,"sectionName":"37","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":39,"sectionName":"38","fieldName":"Share","csvTxtLength":"10","pdfLength":"","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SHARE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":40,"sectionName":"39","fieldName":"Bill Amount","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILL AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":41,"sectionName":"40","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":42,"sectionName":"41","fieldName":"Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SHARE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":43,"sectionName":"42","fieldName":"Bill Amount","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILL AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":44,"sectionName":"43","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":45,"sectionName":"45","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":46,"sectionName":"46","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":47,"sectionName":"47","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":48,"sectionName":"48","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":49,"sectionName":"49","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":50,"sectionName":"50","fieldName":"Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"SHARE"},{"sequence":51,"sectionName":"51","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":52,"sectionName":"52","fieldName":"Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SHARE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":53,"sectionName":"53","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":54,"sectionName":"54","fieldName":"BRANCH NAME","csvTxtLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":55,"sectionName":"55","fieldName":"TERM NO.","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":56,"sectionName":"56","fieldName":"TERMINAL NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":57,"sectionName":"57","fieldName":"ISSUER COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":58,"sectionName":"58","fieldName":"ISSUER SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":59,"sectionName":"59","fieldName":"ACQUIRER COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":60,"sectionName":"60","fieldName":"ACQUIRER SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":61,"sectionName":"61","fieldName":"ATM BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":62,"sectionName":"62","fieldName":"EBK COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":63,"sectionName":"63","fieldName":"EBK SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":64,"sectionName":"64","fieldName":"EBK BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":65,"sectionName":"65","fieldName":"TP COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":66,"sectionName":"66","fieldName":"TP SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":67,"sectionName":"67","fieldName":"TP BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":68,"sectionName":"68","fieldName":"MOBILE COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":69,"sectionName":"69","fieldName":"MOBILE SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":70,"sectionName":"70","fieldName":"MOBILE BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":71,"sectionName":"71","fieldName":"BANCNET COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":72,"sectionName":"72","fieldName":"BANCNET SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":73,"sectionName":"73","fieldName":"BANCNET BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":74,"sectionName":"74","fieldName":"TOTAL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
 	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Over-All Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"defaultValue":"OVER-ALL TOTAL"},{"sequence":5,"sectionName":"5","fieldName":"ISSUER COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"ISSUER SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"ACQUIRER COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"ACQUIRER SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"ATM BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"EBK COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"EBK SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"EBK BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"TP COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"TP SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","fieldName":"TP BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","fieldName":"MOBILE COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"17","fieldName":"MOBILE SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","fieldName":"MOBILE BIL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"19","fieldName":"BANCNET COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"20","fieldName":"BANCNET SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"21","fieldName":"BANCNET BILL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"22","fieldName":"TOTAL AMT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

 	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD where RED_NAME = 'Bills Payment Earnings (Per Branch)';

-- CUP Share in fee Income Report

	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CUP WITHDRAWAL TRANSACTIONS AND SHARE IN TRANSACTION AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"34","fieldName":"Terminal Name","csvTxtLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERMINAL NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"32","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Count","defaultValue":"COUNT"},{"sequence":7,"sectionName":"33","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"35","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"5","fieldName":"Transaction Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TRANSACTION FEE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"36","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"37","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Access Fee","defaultValue":"SHARE IN ACCESS FEE"},{"sequence":13,"sectionName":"7","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Total Share","defaultValue":"TOTAL SHARE","eol":true},{"sequence":14,"sectionName":"8","fieldName":"Space1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":15,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space2"},{"sequence":16,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space3"},{"sequence":17,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Space4"},{"sequence":18,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Withdrawal","defaultValue":"WITHDRAWAL"},{"sequence":19,"sectionName":"13","fieldName":"Inquiry","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INQUIRY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"14","fieldName":"Total Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Withdrawal","defaultValue":"WITHDRAWAL"},{"sequence":22,"sectionName":"16","fieldName":"Inquiry","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"INQUIRY","bodyHeader":true},{"sequence":23,"sectionName":"17","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL SHARE","bodyHeader":true},{"sequence":24,"sectionName":"18","fieldName":"Conversion Rate","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"CONVERSION RATE","bodyHeader":true,"eol":true},{"sequence":25,"sectionName":"19","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"BRANCH CODE","csvTxtLength":"10","firstField":true},{"sequence":26,"sectionName":"20","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"21","fieldName":"TERM NO.","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"22","fieldName":"TERMINAL NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"23","fieldName":"COUNT WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"24","fieldName":"COUNT INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"25","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"26","fieldName":"WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"27","fieldName":"INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"28","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":35,"sectionName":"29","fieldName":"CONVERSION RATE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"30","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},"sequence":37,"sectionName":"31","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"Over-All Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"defaultValue":"OVER-ALL TOTAL"},{"sequence":6,"sectionName":"6","fieldName":"COUNT WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"COUNT INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"TOTAL COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"WITHDRAWAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"INQUIRY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"CONVERSION RATE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"SHARE IN ACCESS FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD where RED_NAME = 'CUP Share In Fee Income';

-- JCB Share in fee Income Report

	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"JCB WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NO.","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":4,"sectionName":"4","fieldName":"Terminal Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERMINAL NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":5,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"6","fieldName":"Share In Interchange Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SHARE IN INTERCHANGE FEE","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":7,"sectionName":"7","fieldName":"Share In Access Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"defaultValue":"SHARE IN ACCESS FEE","decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":8,"sectionName":"8","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL SHARE","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"TERM NO.","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Over-All Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"defaultValue":"OVER-ALL TOTAL"},{"sequence":5,"sectionName":"5","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD where RED_NAME = 'JCB Share In Fee Income';
	
-- VISA Share In Fee Income

	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VISA WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE AND ACCESS FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":3,"sectionName":"3","fieldName":"Term No","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NO.","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":4,"sectionName":"4","fieldName":"Terminal Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERMINAL NAME","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":5,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"6","fieldName":"Share In Interchange Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SHARE IN INTERCHANGE FEE","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":7,"sectionName":"7","fieldName":"Share In Access Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"defaultValue":"SHARE IN ACCESS FEE","decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":8,"sectionName":"8","fieldName":"Total Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL SHARE","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"TERM NO.","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Over-All Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"defaultValue":"OVER-ALL TOTAL"},{"sequence":5,"sectionName":"5","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"INTERCHANGE FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"ACCESS FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

 	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD where RED_NAME = 'VISA Share In Fee Income';

-- MasterCard Share In Fee Income
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPORT ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NYCE WITHDRAWAL TRANSACTIONS AND SHARE IN INTERCHANGE FEES","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Branch Code","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Branch Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Interchange Fee (INQ)","defaultValue":"SHARE IN INTERCHANGE FEE (INQ)"},{"sequence":5,"sectionName":"30","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"5","fieldName":"Count","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"25","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"29","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Share In Interchange Fee (WDL)","defaultValue":"SHARE IN INTERCHANGE FEE (WDL)"},{"sequence":10,"sectionName":"26","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"27","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"7","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Total Share","defaultValue":"TOTAL SHARE","eol":true},{"sequence":13,"sectionName":"8","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false},{"sequence":14,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":false},{"sequence":15,"sectionName":"10","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"CBC Share","defaultValue":"CBC SHARE"},{"sequence":17,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BN Share","defaultValue":"BN SHARE"},{"sequence":18,"sectionName":"13","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"14","fieldName":"CBC Share","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"CBC SHARE"},{"sequence":20,"sectionName":"28","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"15","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BN Share","defaultValue":"BN SHARE"},{"sequence":22,"sectionName":"16","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":23,"sectionName":"17","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":24,"sectionName":"18","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"19","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"20","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":27,"sectionName":"21","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"22","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"23","fieldName":"Local Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"LOCAL FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"24","fieldName":"Intl Fee","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INT''L FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"31","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"32","fieldName":"BRANCH NAME","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"33","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"34","fieldName":"CBC SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":35,"sectionName":"35","fieldName":"BN SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"36","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":37,"sectionName":"37","fieldName":"LOCAL FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":38,"sectionName":"38","fieldName":"INTL FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":39,"sectionName":"39","fieldName":"BN SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":40,"sectionName":"40","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Over-All Total","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"OVER-ALL TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"INQ CBC SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"INQ BN SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"COUNT","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"LOCAL FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"INTL FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"WDL BN SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TOTAL SHARE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

 	update REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELD, RED_HEADER_FIELDS = i_HEADER_FIELD, RED_TRAILER_FIELDS = i_TRAILER_FIELD where RED_NAME = 'MasterCard Share In Fee Income';

-- 

END;
/