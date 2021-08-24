-- Tracking				Date			Name	Description
-- Revise report		25-JULY-2021	WY		Revise IE reports based on spec
-- Revise report 		22-AUG-2021		WY		Revise fee amount based on amount sent in Lady's email

DECLARE
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	
	
BEGIN 

	i_BODY_QUERY := TO_CLOB('SELECT
     ABR.ABR_CODE "BRANCH CODE",
     ABR.ABR_NAME "BRANCH NAME",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     COUNT(TXN.TRL_ID) "TOTAL COUNT",
     COUNT(TXN.TRL_ID) * 8.00 "TOTAL INCOME"
FROM
     TRANSACTION_LOG TXN
     JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
     JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL))
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
GROUP BY
      ABR.ABR_CODE,
      ABR.ABR_NAME,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC
	');	
	
	i_TRAILER_QUERY := TO_CLOB('SELECT
     COUNT(TXN.TRL_ID) "TOTAL COUNT",
     COUNT(TXN.TRL_ID) * 8.00 "TOTAL INCOME"
FROM
     TRANSACTION_LOG TXN
     JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
     JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      (TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL))
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
     AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Inter-Entity Acquirer ATM Withdrawal Income';
	
END;
/