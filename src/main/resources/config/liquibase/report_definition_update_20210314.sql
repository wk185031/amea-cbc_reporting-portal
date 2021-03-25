DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- List of Recycler Transactions
i_BODY_QUERY := TO_CLOB('
select 
	  (ABR.ABR_CODE || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(AST.AST_TERMINAL_ID, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
	  CASE WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''DEBIT'' THEN ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=1 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    ELSE ''CARDLESS TRANSACTIONS - OTHERS''
	    END AS "TRANSACTION GROUP",
	  CASE WHEN (TSC.TSC_CODE = 1 OR TSC.TSC_CODE = 128) THEN ''ATM WITHDRAWAL'' 
	    WHEN TSC.TSC_CODE = 142 THEN ''MOVING CASH - EMERGENCY CASH (NOW)''
	    WHEN TSC.TSC_CODE = 143 THEN ''MOVING CASH - PAY TO MOBILE (JUMP)''
	    WHEN TSC.TSC_CODE = 46 THEN ''INSTAPAY FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 47 THEN ''PESONET FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 21 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN TSC.TSC_CODE = 26 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN (TSC.TSC_CODE = 50 OR TSC.TSC_CODE = 250) THEN ''BILLS PAYMENT''
	    WHEN (TSC.TSC_CODE = 52 OR TSC.TSC_CODE = 252) THEN ''PREPAID AUTO RELOAD''
	    WHEN (TSC.TSC_CODE = 146 OR TSC.TSC_CODE = 246) THEN ''BEEP LOADING''
	    WHEN (TSC.TSC_CODE = 51 OR TSC.TSC_CODE = 251) THEN ''RFID LOADING''
	    ELSE TSC.TSC_DESCRIPTION 
	    END AS "TRANSACTION TYPE",
	  TXN.TRL_SYSTEM_TIMESTAMP "DATE",
	  TXN.TRL_SYSTEM_TIMESTAMP "TIME",
	  TXN.TRL_DEST_STAN "SEQ NO",
	  SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NO",
	  CTR.CTR_MNEM "TRAN MNEM",
	  CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TRAN TYPE",
	  CBA.CBA_MNEM "BANK MNEM",
	  TXN.TRL_PAN "CARD NO",
	  TXN.TRL_PAN_EKY_ID "CARD NO_ENCKEY",
	  NVL(TXN.TRL_ACCOUNT_1_ACN_ID, TXN.TRL_ACCOUNT_2_ACN_ID) "ACC NO",
	  NVL(TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID, TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID) "ACC NO_ENCKEY",
	  NVL(TXN.TRL_AMT_TXN,0) "TRANS AMOUNT",
	  NVL(TRL_ISS_CHARGE_AMT, NVL(TRL_ACQ_CHARGE_AMT,0)) "TRAN FEE",
	  (TXN.TRL_ACTION_RESPONSE_CODE || '' - '' || ARC.ARC_NAME) "REMARKS" 
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''CDM''
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	  LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
	where 
	  TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_ACTION_RESPONSE_CODE < 100
          AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
          AND (TRL_AMT_TXN > 0 OR NVL(TRL_ISS_CHARGE_AMT, NVL(TRL_ACQ_CHARGE_AMT,0)) > 0 ) 
	  AND {Txn_Date}
	order by ABR_CODE, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE", "DATE", "TIME"
);
  
UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'List of Recycler Transactions';

-- Summary of Recycler Transactions
i_BODY_QUERY := TO_CLOB('
select 
  	  BRANCH,
	  TERMINAL,
	  "TRANSACTION GROUP",
	  "TRANSACTION TYPE",
	  SUM(CASE WHEN TRL_ISS_NAME IN (''CBC'', ''CBS'') AND TRL_IS_INTER_ENTITY = 0 AND CPD_CODE NOT IN (''80'',''81'',''82'',''83'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "ONUS",
	  SUM(CASE WHEN TRL_IS_INTER_ENTITY = 1 AND CPD_CODE NOT IN (''80'',''81'',''82'',''83'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "INTER ENTITY",
	  SUM(CASE WHEN TRL_ISS_NAME IS NULL THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "OTHER BANKS",
	  SUM(CASE WHEN CPD_CODE IN (''80'',''81'',''82'',''83'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "CASH CARD",
	  SUM(CASE WHEN "TRANSACTION GROUP" = ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT'' THEN NVL(TRL_AMT_TXN,0) ELSE NULL END) AS "TOTAL DISPENSED",
	  SUM(CASE WHEN "TRANSACTION GROUP" != ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT'' THEN NVL(TRL_AMT_TXN,0) ELSE NULL END) AS "TOTAL DEPOSIT"
	FROM (
    select (ABR.ABR_CODE || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(AST.AST_TERMINAL_ID, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
	  CASE WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''DEBIT'' THEN ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=1 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    ELSE ''CARDLESS TRANSACTIONS - OTHERS''
	    END AS "TRANSACTION GROUP",
	  CASE WHEN (TSC.TSC_CODE = 1 OR TSC.TSC_CODE = 128) THEN ''ATM WITHDRAWAL''
	    WHEN TSC.TSC_CODE = 142 THEN ''MOVING CASH - EMERGENCY CASH (NOW)''
	    WHEN TSC.TSC_CODE = 143 THEN ''MOVING CASH - PAY TO MOBILE (JUMP)''
	    WHEN TSC.TSC_CODE = 46 THEN ''INSTAPAY FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 47 THEN ''PESONET FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 21 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN TSC.TSC_CODE = 26 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN (TSC.TSC_CODE = 50 OR TSC.TSC_CODE = 250) THEN ''BILLS PAYMENT''
	    WHEN (TSC.TSC_CODE = 52 OR TSC.TSC_CODE = 252) THEN ''PREPAID AUTO RELOAD''
	    WHEN (TSC.TSC_CODE = 146 OR TSC.TSC_CODE = 246) THEN ''BEEP LOADING''
	    WHEN (TSC.TSC_CODE = 51 OR TSC.TSC_CODE = 251) THEN ''RFID LOADING''
	    ELSE TSC.TSC_DESCRIPTION 
      END AS "TRANSACTION TYPE",
      TXNC.TRL_IS_INTER_ENTITY,
      CPD.CPD_CODE,
      TXN.TRL_AMT_TXN,
      TXN.TRL_ISS_NAME
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''CDM''
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE   
	where 
	  TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_ACTION_RESPONSE_CODE < 100
           AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
	  AND (TRL_AMT_TXN > 0 OR NVL(TRL_ISS_CHARGE_AMT, NVL(TRL_ACQ_CHARGE_AMT,0)) > 0 ) 
	  AND {Txn_Date}
	)
	group by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"
	order by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'Summary of Recycler Transactions';

-- Block Sheet Listing For Recycler

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"19","fieldName":"BRANCH","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":2,"sectionName":"20","fieldName":"TERMINAL","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":3,"sectionName":"21","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":4,"sectionName":"1","fieldName":"Transaction","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TRANSACTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"2","fieldName":"On-us","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"ON-US /","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"3","fieldName":"Description","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"DESCRIPTION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"4","fieldName":"Inter-branch","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INTER-BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"5","fieldName":"Inter-Entity","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"INTER-ENTITY","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"6","fieldName":"Other Banks","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"OTHER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"7","fieldName":"Cash Card","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CASH CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"8","fieldName":"Total Dispensed","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"9","fieldName":"Total Deposit","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TOTAL DEPOSIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"10","fieldName":"Net Total","csvTxtLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"NET-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"11","fieldName":"TRANSACTION TYPE","csvTxtLength":"","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true,"eol":false,"defaultValue":""},{"sequence":15,"sectionName":"12","fieldName":"ONUS","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":16,"sectionName":"13","fieldName":"INTER ENTITY","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":17,"sectionName":"14","fieldName":"OTHER BANKS","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":18,"sectionName":"15","fieldName":"CASH CARD","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":19,"sectionName":"16","fieldName":"TOTAL DISPENSED","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":20,"sectionName":"17","fieldName":"TOTAL DEPOSIT","csvTxtLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true}]
');

i_BODY_QUERY := TO_CLOB('
select 
  	  BRANCH,
	  TERMINAL,
	  "TRANSACTION GROUP",
	  "TRANSACTION TYPE",
	  SUM(CASE WHEN TRL_ISS_NAME IN (''CBC'', ''CBS'') AND TRL_IS_INTER_ENTITY = 0 AND CPD_CODE NOT IN (''80'',''81'',''82'',''83'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "ONUS",
	  SUM(CASE WHEN TRL_IS_INTER_ENTITY = 1 AND CPD_CODE NOT IN (''80'',''81'',''82'',''83'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "INTER ENTITY",
	  SUM(CASE WHEN TRL_ISS_NAME IS NULL THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "OTHER BANKS",
	  SUM(CASE WHEN CPD_CODE IN (''80'',''81'',''82'',''83'') THEN NVL(TRL_AMT_TXN,0) ELSE 0 END) AS "CASH CARD",
	  SUM(CASE WHEN "TRANSACTION GROUP" = ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT'' THEN NVL(TRL_AMT_TXN,0) ELSE NULL END) AS "TOTAL DISPENSED",
	  SUM(CASE WHEN "TRANSACTION GROUP" != ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT'' THEN NVL(TRL_AMT_TXN,0) ELSE NULL END) AS "TOTAL DEPOSIT"
	FROM (
    select (ABR.ABR_CODE || '' '' || ABR.ABR_NAME) "BRANCH",
	  (SUBSTR(AST.AST_TERMINAL_ID, -4) || '' '' || AST.AST_ALO_LOCATION_ID) "TERMINAL",
	  CASE WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''DEBIT'' THEN ''CARDED TRANSACTIONS - DEBIT FROM ACCOUNT''
	    WHEN TXNC.TRL_IS_CARDLESS=0 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDED TRANSACTIONS - CASH DEPOSIT''
	    WHEN TXNC.TRL_IS_CARDLESS=1 AND CTR.CTR_DEBIT_CREDIT=''CREDIT'' THEN ''CARDLESS TRANSACTIONS - CASH DEPOSIT''
	    ELSE ''CARDLESS TRANSACTIONS - OTHERS''
	    END AS "TRANSACTION GROUP",
	  CASE WHEN (TSC.TSC_CODE = 1 OR TSC.TSC_CODE = 128) THEN ''ATM WITHDRAWAL''
	    WHEN TSC.TSC_CODE = 142 THEN ''MOVING CASH - EMERGENCY CASH (NOW)''
	    WHEN TSC.TSC_CODE = 143 THEN ''MOVING CASH - PAY TO MOBILE (JUMP)''
	    WHEN TSC.TSC_CODE = 46 THEN ''INSTAPAY FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 47 THEN ''PESONET FUND TRANSFER''
	    WHEN TSC.TSC_CODE = 21 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN TSC.TSC_CODE = 26 THEN ''CASH DEPOSIT TRANSFER''
	    WHEN (TSC.TSC_CODE = 50 OR TSC.TSC_CODE = 250) THEN ''BILLS PAYMENT''
	    WHEN (TSC.TSC_CODE = 52 OR TSC.TSC_CODE = 252) THEN ''PREPAID AUTO RELOAD''
	    WHEN (TSC.TSC_CODE = 146 OR TSC.TSC_CODE = 246) THEN ''BEEP LOADING''
	    WHEN (TSC.TSC_CODE = 51 OR TSC.TSC_CODE = 251) THEN ''RFID LOADING''
	    ELSE TSC.TSC_DESCRIPTION 
      END AS "TRANSACTION TYPE",
      TXNC.TRL_IS_INTER_ENTITY,
      CPD.CPD_CODE,
      TXN.TRL_AMT_TXN,
      TXN.TRL_ISS_NAME
	from 
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN TRANSACTION_CODE TSC ON TXN.TRL_TSC_CODE = TSC.TSC_CODE
	  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''CDM''
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
	  LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE   
	where 
	  TXN.TRL_TQU_ID = ''F''
	  AND TXN.TRL_ACTION_RESPONSE_CODE < 100
           AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
	  AND (TRL_AMT_TXN > 0 OR NVL(TRL_ISS_CHARGE_AMT, NVL(TRL_ACQ_CHARGE_AMT,0)) > 0 ) 
	  AND {Txn_Date}
	)
	group by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"
	order by BRANCH, TERMINAL, "TRANSACTION GROUP", "TRANSACTION TYPE"
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_BODY_FIELDS = i_BODY_FIELD WHERE RED_NAME = 'Block Sheet Listing For Recycler';

END;
/