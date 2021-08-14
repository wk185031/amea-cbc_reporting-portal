-- Tracking				Date			Name	Description
-- Revise report		12-AUG-2021		WY		Original script

DECLARE
	i_BODY_QUERY CLOB;
	
BEGIN 

	i_BODY_QUERY := TO_CLOB('SELECT
  "BRANCH CODE",
  "BRANCH NAME",
  COUNT("TRANSMITTING ID") "TRANSMITTING COUNT",
  COUNT("TRANSMITTING ID")  * 5.00 AS "TRANSMITTING EXPENSE",
  COUNT("ACQUIRER ID") AS "ACQUIRER COUNT",
  COUNT("ACQUIRER ID") * 5.00 AS "ACQUIRER INCOME",
  COUNT("RECEIVING ID") AS "RECEIVING COUNT",
  COUNT("RECEIVING ID") * 5.00 AS "RECEIVING INCOME",
  (COUNT("TRANSMITTING ID")  + COUNT("ACQUIRER ID")  +  COUNT("RECEIVING ID")) * 5.00 AS "TOTAL BILLING"
FROM (
SELECT
  CASE WHEN ABR.ABR_CODE IS NOT NULL THEN ABR.ABR_CODE ELSE BRC.BRC_CODE END AS "BRANCH CODE",
  CASE WHEN ABR.ABR_NAME IS NOT NULL THEN ABR.ABR_NAME ELSE BRC.BRC_NAME END AS "BRANCH NAME",
  TXN.TRL_ID AS "TRANSMITTING ID",
  NULL AS "ACQUIRER ID",
  NULL AS "RECEIVING ID"     		
FROM
  TRANSACTION_LOG TXN
  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
  JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
  JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
  AND TXN.TRL_TSC_CODE IN (41, 44, 48, 49)
  AND TXN.TRL_TQU_ID = ''F''
  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
  AND TXN.TRL_ISS_NAME = {V_Iss_Name}
  AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
  AND {Txn_Date}
UNION  
SELECT
  CASE WHEN ABR.ABR_CODE IS NOT NULL THEN ABR.ABR_CODE ELSE BRC.BRC_CODE END AS "BRANCH CODE",
  CASE WHEN ABR.ABR_NAME IS NOT NULL THEN ABR.ABR_NAME ELSE BRC.BRC_NAME END AS "BRANCH NAME",
  NULL AS "TRANSMITTING ID",
  TXN.TRL_ID "ACQUIRER ID",
  NULL AS "RECEIVING ID"
FROM
  TRANSACTION_LOG TXN
  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
  JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
  JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
  AND TXN.TRL_TSC_CODE IN (41, 44, 48, 49)
  AND TXN.TRL_TQU_ID = ''F''
  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
  AND TXN.TRL_ISS_NAME IN ({V_Iss_Name}, {V_IE_Iss_Name})
  AND {Txn_Date}
UNION  
SELECT
  CASE WHEN ABR.ABR_CODE IS NOT NULL THEN ABR.ABR_CODE ELSE BRC.BRC_CODE END AS "BRANCH CODE",
  CASE WHEN ABR.ABR_NAME IS NOT NULL THEN ABR.ABR_NAME ELSE BRC.BRC_NAME END AS "BRANCH NAME",
  NULL AS "TRANSMITTING ID",
  NULL AS "ACQUIRER ID",
  TXN.TRL_ID "RECEIVING ID"     		
FROM
  TRANSACTION_LOG TXN
  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
  JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
  JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
  AND TXN.TRL_TSC_CODE IN (41, 44, 48, 49)
  AND TXN.TRL_TQU_ID = ''F''
  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
  AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Recv_Inst_Id}
   AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}
  AND {Txn_Date})  
GROUP BY "BRANCH CODE", "BRANCH NAME"
ORDER BY "BRANCH CODE"');	
	
	
	UPDATE REPORT_DEFINITION SET 
		RED_BODY_QUERY = i_BODY_QUERY
	WHERE RED_NAME = 'Inter-Entity IBFT Transaction Fees';
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = 'Inter-Entity IBFT Transaction Fees' AND red_ins_id = 2;
	
END;
/