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




-- 

END;
/